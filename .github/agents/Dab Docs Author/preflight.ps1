[CmdletBinding()]
param(
  [switch]$Staged,
  [switch]$All,
  [switch]$WarnOnly,
  [string]$ConfigPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
  $ConfigPath = Join-Path $PSScriptRoot 'preflight-config.json'
}

function Resolve-RepoRoot {
  try {
    $root = (git rev-parse --show-toplevel 2>$null)
    if ([string]::IsNullOrWhiteSpace($root)) { return $null }
    return $root.Trim()
  } catch {
    return $null
  }
}

function Add-Issue {
  param(
    [ValidateNotNull()][System.Collections.Generic.List[object]]$Issues,
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][int]$Line,
    [Parameter(Mandatory = $true)][string]$Code,
    [Parameter(Mandatory = $true)][string]$Message,
    [ValidateSet('error', 'warning')][string]$Severity = 'error'
  )

  $Issues.Add([pscustomobject]@{
      Severity = $Severity
      Code     = $Code
      Path     = $Path
      Line     = $Line
      Message  = $Message
    })
}

function Get-ChangedPaths {
  param([switch]$Staged)

  $paths = New-Object System.Collections.Generic.List[string]

  $statusLines = @(git status --porcelain)
  foreach ($s in $statusLines) {
    if ([string]::IsNullOrWhiteSpace($s)) { continue }

    # Format: XY <path> or ?? <path> or R  <old> -> <new>
    $x = $s.Substring(0, 1)
    $y = $s.Substring(1, 1)
    $rest = $s.Substring(3).Trim()
    if ([string]::IsNullOrWhiteSpace($rest)) { continue }

    $path = $rest
    if ($rest -match '\s->\s') {
      $path = ($rest -split '\s->\s')[-1].Trim()
    }

    if ($Staged) {
      # Include staged changes only.
      if ($x -ne ' ' -and $x -ne '?') {
        $paths.Add($path)
      }
      continue
    }

    # Include any working tree/index change + untracked.
    if (($x -ne ' ' -and $x -ne '?') -or ($y -ne ' ') -or ($x -eq '?' -and $y -eq '?')) {
      $paths.Add($path)
    }
  }

  return $paths | Sort-Object -Unique
}

function Get-AllPaths {
  return (git ls-files) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Sort-Object -Unique
}

function Get-LinkTargetsFromLine {
  param([string]$Line)
  $targets = @()

  $matches = [regex]::Matches($Line, '\]\((?<url>[^)]+)\)')
  foreach ($m in $matches) {
    $url = $m.Groups['url'].Value
    if (-not [string]::IsNullOrWhiteSpace($url)) {
      $targets += $url.Trim()
    }
  }

  return $targets
}

function Get-ImageTargetsFromLine {
  param([string]$Line)
  $results = @()

  $matches = [regex]::Matches($Line, '!\[(?<alt>[^\]]*)\]\((?<url>[^)]+)\)')
  foreach ($m in $matches) {
    $alt = $m.Groups['alt'].Value
    $url = $m.Groups['url'].Value
    $results += [pscustomobject]@{ Alt = $alt; Url = $url }
  }

  return $results
}

function Is-LearnLink {
  param([string]$Url)

  if ($Url -match '^https?://learn\.microsoft\.com/') { return $true }
  if ($Url -match '^https?://docs\.microsoft\.com/') { return $true }
  if ($Url -match '^/') { return $true } # site-relative Learn links
  return $false
}

$repoRoot = Resolve-RepoRoot
if (-not $repoRoot) {
  throw 'preflight.ps1 must be run inside a git repo.'
}

if (-not (Test-Path -LiteralPath $ConfigPath)) {
  throw "Config file not found: $ConfigPath"
}

$config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
$includeExtensions = @($config.includeExtensions | ForEach-Object { $_.ToString().ToLowerInvariant() })
$allowedDuplicateAltTexts = @($config.allowedDuplicateAltTexts | ForEach-Object { $_.ToString().ToLowerInvariant() })
$maxNameLength = [int]$config.maxNameLength
$skipH1PathGlobs = @()
if ($null -ne $config.skipH1PathGlobs) {
  $skipH1PathGlobs = @($config.skipH1PathGlobs | ForEach-Object { $_.ToString() })
}

$paths = if ($All) { Get-AllPaths } else { Get-ChangedPaths -Staged:$Staged }

# Expand directory paths (for example, when git status reports `?? .github/`).
$expandedPaths = New-Object System.Collections.Generic.List[string]
foreach ($p in $paths) {
  if ([string]::IsNullOrWhiteSpace($p)) { continue }

  $full = Join-Path $repoRoot $p
  if (Test-Path -LiteralPath $full -PathType Container) {
    $children = Get-ChildItem -LiteralPath $full -Recurse -File
    foreach ($c in $children) {
      $rel = $c.FullName.Substring($repoRoot.Length).TrimStart('\')
      $expandedPaths.Add(($rel -replace '\\', '/'))
    }
  } else {
    $expandedPaths.Add($p)
  }
}

$paths = $expandedPaths | Sort-Object -Unique

$paths = $paths | Where-Object {
  $ext = [System.IO.Path]::GetExtension($_).ToLowerInvariant()
  $includeExtensions -contains $ext
}

if (-not $paths -or $paths.Count -eq 0) {
  Write-Host 'No matching files to scan.'
  exit 0
}

$issues = New-Object 'System.Collections.Generic.List[object]'

foreach ($relPath in $paths) {
  $fullPath = Join-Path $repoRoot $relPath
  if (-not (Test-Path -LiteralPath $fullPath)) {
    continue
  }

  $lines = Get-Content -LiteralPath $fullPath

  $inFence = $false
  $fenceStartLine = 0
  $imageAltCounts = @{}
  $h2Counts = @{}

  for ($i = 0; $i -lt $lines.Count; $i++) {
    $lineNumber = $i + 1
    $line = $lines[$i]

    if ($line -match '^\s*```') {
      if (-not $inFence) {
        $inFence = $true
        $fenceStartLine = $lineNumber
      } else {
        $inFence = $false
        $fenceStartLine = 0
      }
      continue
    }

    if (-not $inFence) {
      $scanLine = [regex]::Replace($line, '`[^`]*`', '')

      # H2 uniqueness
      if ($line -match '^##\s+(?<h>.+?)\s*$') {
        $h = $Matches['h'].Trim().ToLowerInvariant()
        if ($h2Counts.ContainsKey($h)) {
          Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'duplicate-h2s' -Message "Duplicate H2 heading: '$($Matches['h'].Trim())'"
        } else {
          $h2Counts[$h] = $true
        }
      }

      # Link rules (scan markdown link targets)
      foreach ($url in (Get-LinkTargetsFromLine -Line $scanLine)) {
        if ($url -match '^https?://learn\.microsoft\.com/') {
          Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'docs-link-absolute' -Message 'Use a site-relative Learn link (starts with /) instead of an absolute learn.microsoft.com URL.'
        }

        if ($url -match '^https?://(?:learn\.microsoft\.com|docs\.microsoft\.com)/[a-z]{2}-[a-z]{2}/') {
          Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'hard-coded-locale' -Message 'Remove locale from Microsoft links (for example, /en-us/).' 
        }
        if ($url -match '^/[a-z]{2}-[a-z]{2}/') {
          Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'hard-coded-locale' -Message 'Remove locale from site-relative Learn links (for example, /en-us/).' 
        }

        if (Is-LearnLink -Url $url) {
          $hasView = $url -match '(\?|&)view='
          $hasPreserve = $url -match '(\?|&)preserve-view=true'

          if ($hasView -and -not $hasPreserve) {
            Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'preserve-view-not-set' -Message 'If you include view=..., also include preserve-view=true (or remove view=... if not essential).' 
          }

          if ($hasPreserve -and -not $hasView) {
            Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'preserve-view-not-set' -Message 'preserve-view=true is present without view=...; remove preserve-view=true unless view=... is also needed.' -Severity 'warning'
          }
        }
      }

      # Image/alt-text rules
      foreach ($img in (Get-ImageTargetsFromLine -Line $scanLine)) {
        $alt = if ($null -eq $img.Alt) { '' } else { [string]$img.Alt }
        $alt = $alt.Trim()
        $url = if ($null -eq $img.Url) { '' } else { [string]$img.Url }
        $url = $url.Trim()

        if ([string]::IsNullOrWhiteSpace($alt)) {
          Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'alt-text-missing' -Message 'Image alt text is missing.'
        } else {
          $altKey = $alt.ToLowerInvariant()
          if (-not ($allowedDuplicateAltTexts -contains $altKey)) {
            if ($imageAltCounts.ContainsKey($altKey)) {
              Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'duplicate-alt-text' -Message "Duplicate image alt text: '$alt'"
            } else {
              $imageAltCounts[$altKey] = $true
            }
          }
        }

        $basename = [System.IO.Path]::GetFileName($url)
        $isExternalImage = $url -match '^https?://'
        if (-not $isExternalImage -and -not [string]::IsNullOrWhiteSpace($basename)) {
          # Strip query/fragment from local relative URLs, if present.
          $basename = ($basename -split '[?#]')[0]
          $nameNoExt = [System.IO.Path]::GetFileNameWithoutExtension($basename)
          if (-not [string]::IsNullOrWhiteSpace($alt) -and ($alt -ieq $basename -or $alt -ieq $nameNoExt)) {
            Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'alt-text-bad-value' -Message 'Alt text should not be the image filename.'
          }

          if ($basename.Length -gt $maxNameLength) {
            Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'image-name-exceeds-max-length' -Message "Image filename exceeds $maxNameLength characters: $basename"
          }

          if ($basename -cmatch '[A-Z]' -or $basename -match '_') {
            Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'filename-invalid-character' -Message "Image filename should be lowercase and hyphen-separated: $basename" -Severity 'warning'
          }

          $tokens = $nameNoExt.Split('-', [System.StringSplitOptions]::RemoveEmptyEntries)
          if ($tokens.Count -lt 2) {
            Add-Issue -Issues $issues -Path $relPath -Line $lineNumber -Code 'image-name-incomplete' -Message "Image filename should use multiple complete words separated by hyphens: $basename" -Severity 'warning'
          }
        }
      }
    }
  }

  # H1 rules (after optional front matter)
  $shouldCheckH1 = $true
  foreach ($glob in $skipH1PathGlobs) {
    if ($relPath -like $glob) {
      $shouldCheckH1 = $false
      break
    }
  }

  if ($shouldCheckH1) {
    $startIndex = 0
    if ($lines.Count -gt 0 -and $lines[0].Trim() -eq '---') {
      for ($j = 1; $j -lt $lines.Count; $j++) {
        if ($lines[$j].Trim() -eq '---') {
          $startIndex = $j + 1
          break
        }
      }
    }
    for ($k = $startIndex; $k -lt $lines.Count; $k++) {
      if (-not [string]::IsNullOrWhiteSpace($lines[$k])) {
        if ($lines[$k] -notmatch '^#\s+\S') {
          Add-Issue -Issues $issues -Path $relPath -Line ($k + 1) -Code 'h1-not-first' -Message 'First non-empty content must be an H1 (# ...), after YAML front matter if present.'
        }
        break
      }
    }
  }

  # Unclosed code fence
  if ($inFence) {
    Add-Issue -Issues $issues -Path $relPath -Line $fenceStartLine -Code 'code-block-unclosed' -Message 'Fenced code block is not closed.'
  }

  # Indented code blocks (heuristic: 2+ consecutive indented lines outside fences, preceded by blank)
  $runStart = 0
  $runLen = 0
  for ($n = 0; $n -lt $lines.Count; $n++) {
    $l = $lines[$n]
    $isIndented = ($l -match '^\t\S' -or $l -match '^\s{4}\S')
    if ($isIndented) {
      if ($runLen -eq 0) { $runStart = $n }
      $runLen++
    } else {
      if ($runLen -ge 2) {
        $prevBlank = ($runStart -gt 0) -and [string]::IsNullOrWhiteSpace($lines[$runStart - 1])
        if ($prevBlank) {
          Add-Issue -Issues $issues -Path $relPath -Line ($runStart + 1) -Code 'code-block-indented' -Message 'Possible indented code block; prefer fenced code blocks with a language.' -Severity 'warning'
        }
      }
      $runLen = 0
    }
  }
}

if ($issues.Count -eq 0) {
  Write-Host 'Preflight OK.'
  exit 0
}

$ordered = $issues | Sort-Object Severity, Path, Line, Code
foreach ($issue in $ordered) {
  $prefix = if ($issue.Severity -eq 'warning') { 'WARN' } else { 'ERROR' }
  Write-Host "$prefix [$($issue.Code)] $($issue.Path):$($issue.Line) $($issue.Message)"
}

if ($WarnOnly) {
  exit 0
}

exit 1
