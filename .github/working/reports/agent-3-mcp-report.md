# Agent 3 — MCP & AI Integration Docs Report

## Summary

Updated MCP documentation across multiple files to reflect DAB 2.0 changes including entity-level MCP configuration, custom MCP tools from stored procedures, granular runtime DML tool settings, the new `aggregate-records` tool, and OpenTelemetry tracing for MCP.

## Files Edited

### 1. `data-api-builder/configuration/entities.md`
- Added **MCP** summary table in the top-level property index (between Cache and Format overview)
- Added `mcp` property to the **Format overview** JSON schema (boolean or object with `dml-tools` and `custom-tool`)
- Added full **MCP (entity-name entities)** section at end with:
  - Property tables (parent, property, type, required, default)
  - Nested properties (`dml-tools`, `custom-tool`)
  - Boolean shorthand example
  - Object format example with `custom-tool` for stored procedures
  - Cross-link TIP to what's-new article
  - Important callout: `custom-tool` valid only for stored-procedure entities

### 2. `data-api-builder/configuration/runtime.md`
- Added **MCP settings** table in the top-level property index (after Telemetry settings)
- Added `mcp` block to the **Format overview** JSON schema (all 7 DML tools including `aggregate-records` object config)
- Added full **MCP (runtime)** section at end with:
  - Top-level property table
  - Nested properties tables (mcp, dml-tools, aggregate-records)
  - `query-timeout` documentation (1–600 seconds, default 30)
  - Format JSON, default example, granular example
  - CLI commands for all MCP settings
  - Cross-link TIP to what's-new article

### 3. `data-api-builder/command-line/dab-add.md`
- Added `--mcp.dml-tools` and `--mcp.custom-tool` to the **Quick glance** table
- Added full `--mcp.dml-tools` section with Bash/CMD examples and resulting config
- Added full `--mcp.custom-tool` section with Bash/CMD examples, resulting config, and important callout

### 4. `data-api-builder/mcp/overview.md`
- Added note about `aggregate-records` object config with cross-link to runtime configuration reference

### 5. `data-api-builder/mcp/data-manipulation-language-tools.md`
- Updated YAML front matter description from "six" to "seven"
- Added cross-links to entity-level and runtime MCP configuration in Related content
- Added link to what's-new article in Related content

### 6. `data-api-builder/mcp/stdio-transport.md`
- Added `aggregate_records` to the Available MCP tools table
- Added `aggregate-records` to the required configuration JSON example

### 7. `data-api-builder/concept/database/stored-procedures.md`
- Added **Custom MCP tools** section explaining stored procedure registration as named MCP tools
- Included JSON config example and CLI example
- Added cross-links to what's-new article and DML tools doc

## Files Reviewed but Not Modified
- `data-api-builder/mcp/how-to-configure-authentication.md` — Already has Unauthenticated provider reference
- `data-api-builder/mcp/how-to-add-descriptions.md` — No MCP config changes needed
- `data-api-builder/mcp/quickstart-*.md` — Config examples are generic enough
- `data-api-builder/whats-new/version-2-0.md` — Source of truth, already complete

## Cross-Links Added
All edited files include `> [!TIP]` callouts linking to `../whats-new/version-2-0.md`.
