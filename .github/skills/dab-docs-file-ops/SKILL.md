---
name: dab-docs-file-ops
description: 'Rename, move, or delete documentation files in the Data API builder docs repo. Handles all side effects: redirects, TOC, index.yml, media, includes, and cross-references.'
argument-hint: 'Provide: operation (rename/move/delete), source file path, and destination path (for rename/move).'
user-invocable: true
---

# DAB Docs File Operations

Use this skill whenever you rename, move, or delete a documentation file in this repo. Every file operation has side effects that must all be handled atomically. Never perform a file operation without completing every step in the checklist.

## Repository structure

```text
data-api-builder/
├── breadcrumb/toc.yml          # Breadcrumb navigation
├── TOC.yml                     # Main table of contents
├── index.yml                   # Landing page (superset of links)
├── .openpublishing.redirection.json  # Redirect rules (repo root)
├── command-line/
│   └── index.yml               # CLI landing page
├── deployment/
│   └── index.yml               # Deployment landing page
├── concept/
│   ├── api/
│   ├── cache/
│   ├── config/
│   ├── database/
│   ├── monitor/
│   └── security/
│       └── index.md            # Security overview
├── configuration/
├── whats-new/
├── quickstart/
├── mcp/
├── vscode-extension/
└── keywords/
```

## Checklist

Complete every applicable step for each file operation. Do not skip steps.

### 1. Execute the file operation

- [ ] Use `git mv` for renames and moves (preserves git history).
- [ ] Use `git rm` for deletions.
- [ ] If the file has a matching **media folder** (e.g., `media/old-name/`), rename or move it too.
- [ ] If the file has **include files** in an `includes/` folder that only it uses, delete them.

### 2. Update internal links in the moved/renamed file

- [ ] Fix all **relative links** (`../`, `./`, sibling references) inside the file itself — the path depth may have changed.
- [ ] Fix all **media references** (`media/old-name/image.png` → `media/new-name/image.png`) inside the file.
- [ ] Fix all **include references** (`[!INCLUDE [...]]`) inside the file.

### 3. Update all incoming references across the repo

Search the entire repo for references to the old path. Every one of these files may need updating:

- [ ] **`TOC.yml`** — Update `href:` entries.
- [ ] **`index.yml`** (root landing page) — Update `url:` entries.
- [ ] **Folder-level `index.yml`** files (e.g., `command-line/index.yml`, `deployment/index.yml`) — Update `url:` entries.
- [ ] **`breadcrumb/toc.yml`** — Update `topicHref:` or `tocHref:` if applicable.
- [ ] **Other `.md` files** — Search with `grep` for the old filename across all `.md` files and update relative links.
- [ ] **Other `.yml` files** — Search for the old filename across all `.yml` files.
- [ ] **`overview.md`** or section `index.md` files — These often link to sibling files.

### 4. Update the redirect file

The redirect file is `.openpublishing.redirection.json` at the repo root.

- [ ] **Add a new redirect entry** for the old source path pointing to the new URL:
  ```json
  {
    "source_path_from_root": "/data-api-builder/old-path/old-file.md",
    "redirect_url": "/azure/data-api-builder/new-path/new-file",
    "redirect_document_id": false
  }
  ```
- [ ] **Update existing redirect targets** — If any existing entries have `redirect_url` pointing to the old URL, update them to point to the new URL (avoids redirect chains).
- [ ] **Validate the JSON** — Run `Get-Content .openpublishing.redirection.json -Raw | ConvertFrom-Json | Out-Null` to confirm valid JSON.

### 5. Clean up orphaned assets

- [ ] Check if the old **media folder** is now empty and delete it if so.
- [ ] Check if any **media files** inside the folder are no longer referenced by any `.md` file and delete orphans.
- [ ] Check if any **include files** are no longer referenced and delete orphans.

### 6. Verify completeness

- [ ] Run `grep` for the old filename across all `.md`, `.yml`, and `.json` files. The only remaining matches should be `source_path_from_root` entries in the redirect file.
- [ ] Validate the redirect JSON parses without errors.

## Rules

### Redirect rules

- Every renamed, moved, or deleted file MUST get a redirect entry.
- `source_path_from_root` uses the format `/data-api-builder/path/file.md` (with leading slash, with `.md`).
- `redirect_url` uses the format `/azure/data-api-builder/path/file` (with leading slash, WITHOUT `.md`).
- `redirect_document_id` is `false` for moves/renames, `true` only when the old URL should transfer its document ID.
- Never create redirect chains — if A → B already exists and B is being renamed to C, update A → C directly.

### Naming conventions

- Files in `command-line/` use the `dab-` prefix (e.g., `dab-add.md`, `dab-init.md`).
- Files everywhere else do NOT use prefixes like `how-to-` or `dab-`.
- Media folders match their parent file's name (e.g., `authenticate-entra.md` → `media/authenticate-entra/`).

### Link format rules

- Same-folder links: just the filename (e.g., `sibling-file.md`).
- Cross-folder links: relative paths (e.g., `../concept/api/graphql.md`).
- Links in `.yml` files use `url:` (relative) or `href:` (relative) — no leading `/azure/`.
- Links in the redirect file use absolute URL paths starting with `/azure/data-api-builder/`.

## Search commands

Use these to find all references before and after a file operation:

```powershell
# Find all references to a filename (excluding redirect source entries)
git --no-pager grep -n "old-filename" -- "*.md" "*.yml"

# Find redirect entries targeting the old URL
grep -n "old-path/old-filename" .openpublishing.redirection.json

# Verify no stale references remain after the operation
git --no-pager grep -n "old-filename" -- "*.md" "*.yml"

# Validate redirect JSON
Get-Content .openpublishing.redirection.json -Raw | ConvertFrom-Json | Out-Null; Write-Host "Valid JSON"
```

## Procedure

1. **Before starting:** Grep for all references to the file being operated on. Understand the full scope.
2. **Execute** the file operation (step 1).
3. **Fix internal links** in the moved/renamed file (step 2).
4. **Fix all incoming references** across the repo (step 3).
5. **Update redirects** (step 4).
6. **Clean up orphans** (step 5).
7. **Verify** no stale references remain (step 6).

Always complete all steps before reporting the operation as done.
