# Data API builder documentation — workspace instructions

This repo contains the Microsoft Learn documentation for Data API builder (DAB). All content is authored in DocFX-flavored Markdown and published to `learn.microsoft.com/azure/data-api-builder/`.

## Author identity (required first step)

Before making any edit to any `.md` file, you must know the current user's **GitHub username** and **Microsoft alias** (`ms.author`). If you do not already have these values, **ask the user before proceeding**. Do not guess or use placeholder values.

Every file edit must update the YAML frontmatter:

- `author` — set to the current user's GitHub username.
- `ms.author` — set to the current user's Microsoft alias (without `@microsoft.com`).
- `ms.date` — set to today's date in `MM/DD/YYYY` format.

This applies to new files, reworked files, and any file where content is substantially changed.

## Microsoft Learn writing rules

### Voice and tone

- Write in **second person** ("you", "your"). Never use first person ("we", "our", "let's").
- Use **active voice**. Avoid passive constructions.
- Use **present tense** unless describing a completed past event.
- Do not say "we recommend" — use "Consider..." or a direct imperative instead.
- Be direct and concise. Cut filler words, introductory phrases, and marketing language.

### Headings

- Use **sentence case** for all headings (capitalize only the first word and proper nouns).
- Use `##` for top-level sections, `###` for subsections. Avoid skipping levels.
- Do not use gerunds in headings ("Configuring..." → "Configure...").

### Images

- Use **standard Markdown image syntax** `![alt text](path)` for all images.
- Do NOT use `:::image` DocFX syntax in any form (`type="complex"`, `type="content"`, or otherwise).
- Every image must have **descriptive alt text** (10–250 characters). Start with "Diagram showing" or "Screenshot of" and end with a period.
- Place images in a **page-specific media subfolder** matching the filename: `media/<page-name>/`.
- Do not share media folders between docs. If two docs need the same image, copy it to each folder.

### Links

- **Same-folder** links: just the filename (`sibling-file.md`).
- **Cross-folder** links: relative paths (`../concept/config/env-function.md`).
- **Microsoft Learn** cross-service links: site-relative paths starting with `/` (`/cli/azure/install-azure-cli`). Never use absolute `https://learn.microsoft.com/...` URLs.
- **External** links: full HTTPS URLs.

### Code blocks

Use the correct language tag:

| Content | Tag |
|---|---|
| DAB CLI commands (`dab init`, `dab add`, `dab start`) | `dotnetcli` |
| .NET CLI commands (`dotnet tool install`) | `dotnetcli` |
| Azure CLI commands (`az group create`) | `azurecli` |
| PowerShell | `powershell` |
| Bash | `bash` |
| JSON | `json` |
| YAML | `yaml` |
| Dockerfile | `dockerfile` |
| Plain text / URLs | `text` |

### Alerts

Use standard Learn alert blocks. Do not bold the alert keyword or invent custom alert types.

```markdown
> [!NOTE]
> [!TIP]
> [!IMPORTANT]
> [!WARNING]
```

### Tab groups

Use tabs for terminal commands and any code samples that differ by platform. Prefer `powershell` / `bash` tab IDs for terminal commands.

```markdown
### [PowerShell](#tab/powershell)

```powershell
$env:DATABASE_CONNECTION_STRING = "<your-connection-string>"
```

### [Bash](#tab/bash)

```bash
export DATABASE_CONNECTION_STRING="<your-connection-string>"
```

---
```

Rules:

- Close every tab group with `---` on its own line.
- Use consistent tab IDs across the entire page — every tab group must use the same IDs in the same order.
- The `---` delimiter is only for closing tab groups — never use it as a decorative separator.
- Use `azurecli` code fences (not `bash`) for Azure CLI commands even inside a Bash tab.

## YAML frontmatter

Every `.md` file must start with YAML frontmatter containing at minimum:

```yaml
---
title: <Sentence case title>
description: <75–300 characters, no brand name at start>
author: <GitHub username>
ms.author: <Microsoft alias>
ms.reviewer: <Microsoft alias>
ms.service: data-api-builder
ms.topic: <how-to | concept-article | quickstart | tutorial | whats-new | reference>
ms.date: <MM/DD/YYYY>
# Customer Intent: As a <role>, I want to <action> so that I can <outcome>.
---
```

## File and folder conventions

- **Filenames**: lowercase kebab-case (`azure-app-service.md`, `authenticate-entra.md`). Do not use abbreviations in filenames (use `azure-container-apps.md`, not `aca.md`).
- Only files in `command-line/` use the `dab-` prefix (`dab-init.md`).
- **Media folders**: match the doc filename without `.md` (`deployment/media/azure-app-service/`).

## Information architecture

When adding or modifying files, keep these integration points in sync:

- **`TOC.yml`** — main table of contents for the entire doc set.
- **Folder `index.yml`** — landing pages in `deployment/`, `mcp/`, `quickstart/`, etc.
- **`overview.md`** — product overview that enumerates key features and options.
- **Peer docs** — related content and cross-reference sections in sibling files.

## Peer consistency

When editing a file in a group (e.g., deployment docs, MCP quickstarts), compare against peers for:

- Frontmatter fields and format
- Heading structure and section order
- Prerequisites format
- Intro paragraph pattern ("This guide shows you how to...")
- Clean-up section presence
- Related content / Next step pattern
- Image placement and alt text pattern

## Review workflow

After any major edit — creating a new file, reworking an existing file, or making cross-cutting changes — spin up a **sub-agent using a different model** to review the work. The reviewer should check:

1. Technical accuracy of commands and configuration
2. Style and voice compliance with the rules above
3. Cross-reference and link correctness
4. Peer consistency within the file's section group
5. Information architecture integration (TOC, index.yml, overview.md)

Evaluate the reviewer's feedback critically. Implement changes that are valid and actionable. Discard feedback that is purely stylistic preference or would over-engineer the content.

After implementing reviewer feedback, use the `dab-docs-audit` skill for a final compliance audit against Microsoft Learn publishing requirements.

Finally, run a DocFX build to verify no build errors:

```powershell
Set-Location "data-api-builder"
docfx build docfx.json --warningsAsErrors 2>&1 | Out-File -FilePath "..\docfx-output.log" -Encoding utf8
```

Review the log for `InvalidFileLink` warnings — these indicate broken internal links. Ignore `UnknownContentType` warnings for `.yml` landing pages (`YamlMime:Landing`, `YamlMime:FAQ`) as these are a DocFX limitation and build correctly in the Learn pipeline.

> **Known DocFX limitations:**
>
> - DocFX cannot parse `YamlMime:Landing`, `YamlMime:FAQ`, or custom Learn YAML page types. These appear as `UnknownContentType` warnings and cause `Unable to find file` errors for any `.yml` files referenced in `TOC.yml`. These are false positives — the Learn build pipeline handles them correctly.
> - TOC entries pointing to `.yml` landing pages (e.g., `index.yml`, `faq.yml`) will always produce `Unable to find file for Href/TopicHref` warnings locally. These are safe to ignore.
> - Only `InvalidFileLink` warnings from `.md` files indicate real broken links that must be fixed.
