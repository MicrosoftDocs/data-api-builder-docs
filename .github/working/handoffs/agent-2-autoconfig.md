# Agent 2 Handoff: AutoConfig & AutoEntities

## Your Mission
You are a "DAB Docs Author" agent. The `dab auto-config` and `dab auto-config-simulate` commands are NET-NEW in DAB 2.0, along with the `autoentities` configuration section. Your job is to create new documentation for these features and integrate them into existing docs and TOC.

## Repository Structure
- Docs root: `data-api-builder/`
- CLI docs: `data-api-builder/command-line/` (each command has its own file: dab-init.md, dab-add.md, etc.)
- Config docs: `data-api-builder/configuration/` (index.md, data-source.md, runtime.md, entities.md)
- TOC: `data-api-builder/TOC.yml`
- What's new: `data-api-builder/whats-new/version-2-0.md`

## Changes in DAB 2.0

### 1. `dab auto-config` Command
Creates or updates `autoentities` definitions from the CLI. Autoentities define pattern-based rules that automatically expose matching database objects as DAB entities.

**CLI syntax:**
```bash
dab auto-config <definition-name> \
    --patterns.include "dbo.%" \
    --patterns.exclude "dbo.internal%" \
    --patterns.name "{schema}_{table}" \
    --permissions "anonymous:read"
```

**Template options:**
```bash
dab auto-config <definition-name> \
    --template.rest.enabled true \
    --template.graphql.enabled true \
    --template.cache.enabled true \
    --template.cache.ttl-seconds 30 \
    --template.cache.level L1L2
```

### 2. `dab auto-config-simulate` Command
Previews which database objects match autoentities patterns before committing changes. Connects to the database, resolves each pattern, prints matched objects.

**CLI syntax:**
```bash
dab auto-config-simulate
dab auto-config-simulate --output results.csv
```

Currently supports MSSQL autoentity filters only.

### 3. `autoentities` Configuration Section
New top-level config section. Schema:
```json
{
    "autoentities": {
        "<definition-name>": {
            "patterns": {
                "include": ["dbo.%"],
                "exclude": ["dbo.internal%"],
                "name": "{schema}_{table}"
            },
            "template": {
                "mcp": { "dml-tools": true },
                "rest": { "enabled": true },
                "graphql": { "enabled": true },
                "health": { "enabled": true },
                "cache": { "enabled": false, "ttl-seconds": null, "level": "L1L2" }
            },
            "permissions": [
                { "role": "anonymous", "actions": [{ "action": "read" }] }
            ]
        }
    }
}
```

**Key details:**
- `patterns.include`: MSSQL LIKE patterns for objects to include. Default: `["%.%"]`
- `patterns.exclude`: MSSQL LIKE patterns to exclude. Default: null
- `patterns.name`: Interpolation pattern using `{schema}` and `{object}`. Default: `"{object}"`
- `template`: Default config applied to all matched entities (rest, graphql, mcp, health, cache)
- `permissions`: Permissions applied to all matched entities
- When `autoentities` is present, `entities` section is NOT required (schema allows either)
- Currently MSSQL only

## Files to Create

### `data-api-builder/command-line/dab-auto-config.md`
New CLI reference doc for `dab auto-config`. Follow the same structure as other CLI docs (dab-add.md, dab-init.md, etc.). Include:
- YAML front matter
- Command description
- Syntax
- Options table
- Examples

### `data-api-builder/command-line/dab-auto-config-simulate.md`
New CLI reference doc for `dab auto-config-simulate`. Same structure.

## Files to Update

### `data-api-builder/TOC.yml`
Add entries for both new CLI commands under the "Command-Line interface" section. Also add `autoentities` under the "Configuration file" section.

### `data-api-builder/configuration/index.md`
Add a section describing the `autoentities` top-level property.

### `data-api-builder/command-line/index.yml`
If it lists available commands, add the new ones.

## MS Learn Requirements
- Every .md file needs YAML front matter (title, description, author, ms.author, ms.reviewer, ms.service, ms.topic, ms.date)
- author: jerrynixon, ms.author: jnixon, ms.reviewer: sidandrews, ms.service: data-api-builder
- ms.date: 03/24/2026
- Use `> [!NOTE]`, `> [!IMPORTANT]` for callouts
- Code blocks need language identifiers
- No trailing whitespace, files end with newline

## Cross-Links
- Link from new docs to `../whats-new/version-2-0.md`
- Link from config index to new autoentities content

## Output
Write report to: `.github/working/reports/agent-2-autoconfig-report.md`

Then commit:
```
git add -A
git commit -m "docs: add autoentities and auto-config CLI documentation for DAB 2.0

- Create dab-auto-config.md CLI reference
- Create dab-auto-config-simulate.md CLI reference
- Add autoentities configuration section to config docs
- Update TOC with new entries

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```
