# Agent 3 Handoff: MCP & AI Integration

## Your Mission
You are a "DAB Docs Author" agent. Hunt through ALL MCP-related docs and entity configuration docs to update them for DAB 2.0 MCP changes. The MCP feature set has expanded significantly.

## Repository Structure
- Docs root: `data-api-builder/`
- MCP docs: `data-api-builder/mcp/` (overview.md, TOC.yml, quickstart files, DML tools doc, etc.)
- Config docs: `data-api-builder/configuration/` (entities.md, runtime.md, index.md)
- What's new: `data-api-builder/whats-new/version-2-0.md`
- TOC: `data-api-builder/TOC.yml`

## Changes in DAB 2.0

### 1. Entity-Level MCP Configuration
NEW `mcp` property at the entity level. Controls MCP participation per entity.

**Boolean shorthand:**
```json
{ "entities": { "Book": { "source": "books", "mcp": true } } }
```
`true` enables DML tools. `false` disables MCP for this entity entirely.

**Object format:**
```json
{
    "entities": {
        "GetBookById": {
            "source": { "object": "dbo.get_book_by_id", "type": "stored-procedure" },
            "mcp": { "dml-tools": false, "custom-tool": true }
        }
    }
}
```

- `dml-tools` and `custom-tool` are independent
- `custom-tool` is valid ONLY for stored-procedure entities (schema enforces this)
- If `mcp` is omitted from an entity, DML tools remain enabled by default

**CLI:**
```bash
dab add Book --source books --permissions "anonymous:*" --mcp.dml-tools true
dab add GetBookById --source dbo.get_book_by_id --source.type stored-procedure \
    --permissions "anonymous:execute" --mcp.custom-tool true
```

### 2. Custom MCP Tools from Stored Procedures
When `custom-tool: true` on a stored-procedure entity, DAB dynamically registers that procedure as a named MCP tool. Exposed through standard `tools/list` and `tools/call` methods.

```json
{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": { "name": "get_book_by_id", "arguments": { "id": 1 } },
    "id": 1
}
```

### 3. Runtime MCP Granular DML Tools Configuration
The `runtime.mcp` section now supports granular control over individual DML tools:

```json
{
    "runtime": {
        "mcp": {
            "path": "/mcp",
            "enabled": true,
            "dml-tools": {
                "describe-entities": true,
                "create-record": true,
                "read-records": true,
                "update-record": true,
                "delete-record": true,
                "execute-entity": true,
                "aggregate-records": {
                    "enabled": true,
                    "query-timeout": 30
                }
            }
        }
    }
}
```

- `dml-tools` can be boolean (enable/disable all) or object (individual tools)
- `aggregate-records` can be boolean or object with `enabled` and `query-timeout` (1-600 seconds, default 30)
- New tools listed: `describe-entities`, `create-record`, `read-records`, `update-record`, `delete-record`, `execute-entity`, `aggregate-records`

### 4. OpenTelemetry Tracing for MCP
MCP tool execution is now included in OTEL traces alongside REST and GraphQL traffic. Works automatically when OTEL is configured.

## Files to Update

### `data-api-builder/mcp/` folder
- `overview.md` — Update to mention entity-level MCP config, custom tools, granular DML control
- `data-manipulation-language-tools.md` — Update with granular tool config, entity-level enable/disable
- Any quickstart files that show MCP config — ensure they reflect new options
- `how-to-configure-authentication.md` — check for auth references affected by Unauthenticated default
- `how-to-add-descriptions.md` — check if entity descriptions relate to MCP tool discovery

### `data-api-builder/configuration/entities.md`
- Add `mcp` property documentation in entity configuration section

### `data-api-builder/configuration/runtime.md`
- Add/update `runtime.mcp` section with granular DML tools configuration

### `data-api-builder/command-line/dab-add.md`
- Add `--mcp.dml-tools` and `--mcp.custom-tool` flags

### `data-api-builder/concept/database/stored-procedures.md`
- Mention that stored procedures can now be exposed as custom MCP tools

## MS Learn Requirements
- YAML front matter required on all .md files
- author: jerrynixon, ms.author: jnixon, ms.reviewer: sidandrews, ms.service: data-api-builder
- ms.date: 03/24/2026
- Callout syntax: `> [!NOTE]`, `> [!IMPORTANT]`, `> [!TIP]`
- Code blocks need language identifiers
- Relative links between docs

## Cross-Links
Add cross-links to `../whats-new/version-2-0.md` from updated MCP docs.

## Output
Write report to: `.github/working/reports/agent-3-mcp-report.md`

Then commit:
```
git add -A
git commit -m "docs: update MCP & AI integration docs for DAB 2.0

- Add entity-level MCP configuration documentation
- Document custom MCP tools from stored procedures
- Add runtime.mcp granular DML tools configuration
- Note OTEL tracing support for MCP execution
- Update CLI docs with MCP flags
- Add cross-links to what's-new article

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```
