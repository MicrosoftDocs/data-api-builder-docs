# Agent 3 — MCP & AI Integration Docs Report

## Summary

Updated MCP documentation across 7 files to reflect DAB 2.0 changes including entity-level MCP configuration, custom MCP tools from stored procedures, granular runtime DML tool settings, the new `aggregate-records` tool, and OpenTelemetry tracing for MCP.

## Files Edited

### 1. `data-api-builder/mcp/overview.md`
- Updated `ms.date` to `03/24/2026`
- Expanded entity settings section with boolean shorthand (`"mcp": true/false`) and object format
- Added `custom-tool` documentation for stored-procedure entities
- Updated DML tools count from six to seven (added `aggregate_records`)
- Added "Custom MCP tools" section explaining stored procedure registration
- Added "OpenTelemetry tracing for MCP" section
- Updated runtime config example to include `aggregate-records`
- Updated CLI configure examples to include `aggregate-records`
- Added cross-link TIP to what's-new article

### 2. `data-api-builder/mcp/data-manipulation-language-tools.md`
- Updated `ms.date` to `03/24/2026`
- Updated tool count from six to seven
- Added `aggregate_records` to tool list and `list_tools` response
- Added `aggregate_records` tool section with configuration (boolean and object with `query-timeout`)
- Updated runtime config section with granular object format and boolean shorthand
- Updated CLI configure examples to include `aggregate-records`
- Expanded entity settings section with boolean shorthand, object format, and custom tools
- Updated scope of per-tool control section
- Added cross-link TIP to what's-new article

### 3. `data-api-builder/configuration/entities.md`
- `ms.date` already set to `03/24/2026` by previous agent
- Added new "MCP (entity-name entities)" section after Health section
- Documented boolean shorthand and object format
- Documented `dml-tools` and `custom-tool` properties with tables
- Added stored-procedure custom tool example with full config
- Added CLI examples for `--mcp.dml-tools` and `--mcp.custom-tool`
- Added cross-link TIP to what's-new article

### 4. `data-api-builder/configuration/runtime.md`
- `ms.date` already set to `03/24/2026` by previous agent
- Added new "MCP (runtime)" section before Health section
- Documented nested properties including `enabled`, `path`, `description`, `dml-tools`
- Documented individual DML tool toggles with property tables
- Documented `aggregate-records` object format with `enabled` and `query-timeout` (1–600s)
- Added format and example blocks
- Added cross-link TIP to what's-new article

### 5. `data-api-builder/command-line/dab-add.md`
- Updated `ms.date` to `03/24/2026`
- MCP flag sections (`--mcp.dml-tools`, `--mcp.custom-tool`) already added by previous agent
- Added cross-link TIP to what's-new article in `--mcp.dml-tools` section

### 6. `data-api-builder/concept/database/stored-procedures.md`
- Updated `ms.date` to `03/24/2026`
- Added "MCP custom tools" section after Limitations
- Documented configuration and CLI examples for `custom-tool`
- Added cross-link TIP to what's-new article

### 7. `data-api-builder/concept/monitor/open-telemetry.md`
- Updated `ms.date` to `03/24/2026`
- Added "MCP tool execution" to the list of OpenTelemetry activities
- Added TIP callout about DAB 2.0 MCP tracing instrumentation
- Updated implementation notes to include MCP alongside REST and GraphQL

## Cross-Links Added
All edited files include `> [!TIP]` callouts linking to `../whats-new/version-2-0.md` (or `../../whats-new/version-2-0.md` from nested paths).
