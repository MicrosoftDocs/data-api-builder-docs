# Agent 2 Report: AutoConfig & AutoEntities Documentation

## Summary

Created CLI reference documentation for `dab auto-config` and `dab auto-config-simulate` commands, added the `autoentities` configuration section to the configuration schema reference, and updated the TOC and CLI landing page.

## Files Created

| File | Description |
|---|---|
| `data-api-builder/command-line/dab-auto-config.md` | CLI reference for the `dab auto-config` command. Covers syntax, all options (patterns, template, permissions), examples with Bash/CMD tabs, and resulting configuration JSON. |
| `data-api-builder/command-line/dab-auto-config-simulate.md` | CLI reference for the `dab auto-config-simulate` command. Covers syntax, `--output` CSV option, console output format, and examples. |

## Files Modified

| File | Changes |
|---|---|
| `data-api-builder/TOC.yml` | Added `dab auto-config` and `dab auto-config-simulate` entries under "Command-Line interface". Added `Autoentities` entry under "Configuration file" linking to `configuration/index.md#autoentities`. |
| `data-api-builder/configuration/index.md` | Updated ms.date. Added `autoentities` to the top-level properties table. Updated multi-config rules to note `entities` or `autoentities` required. Added full `## Autoentities` section with format, properties table, and example. |
| `data-api-builder/command-line/index.yml` | Updated ms.date. Added "Auto-config" tile with links to both new commands and key reference sections. |

## Style Compliance

- YAML front matter follows existing pattern (title, description, author, ms.author, ms.reviewer, ms.service, ms.topic, ms.date)
- ms.date set to `03/24/2026` on all new and modified files
- author: `jerrynixon`, ms.author: `jnixon`, ms.reviewer: `sidandrews`
- Bash/Command Prompt tab pairs used for all CLI examples
- `> [!IMPORTANT]` callouts used for MSSQL-only notes
- Cross-links to what's-new, related CLI docs, and config docs included
- No trailing whitespace; files end with newline

## Key Documentation Decisions

1. **MSSQL-only**: Clearly noted in IMPORTANT callouts on both CLI docs and the config section
2. **entities optional**: Documented that `autoentities` makes `entities` optional (schema requires either one or both)
3. **Naming pattern**: Documented `{schema}` and `{object}` interpolation with concrete examples
4. **Template sub-properties**: Documented all five: `mcp`, `rest`, `graphql`, `health`, `cache`
5. **TOC placement**: CLI entries placed alphabetically after `dab add`; autoentities placed after Entities in the Configuration file section
