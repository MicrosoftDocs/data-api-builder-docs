# SQL MCP Server (preview) — agent guide

Goal: help users correctly configure, run, and use SQL MCP Server (DAB 1.7+) and debug tool/permission issues.

## Non-negotiables

- No NL2SQL: the server exposes deterministic DML tools.
- DML tools are gated by the same DAB entity abstraction + RBAC.
- Prefer a two-step agent flow:
  1) `describe_entities`
  2) `read_records` / `create_record` / `update_record` / `delete_record` / `execute_entity`

## Minimum viable local setup (CLI)

1) Create config

- `dab init --database-type mssql --connection-string "<...>" --host-mode Development --config dab-config.json`

2) Add at least one entity

- `dab add Products --source dbo.Products --permissions "anonymous:read" --description "..."`

3) Start

- `dab start --config dab-config.json`

## Runtime config facts

Defaults (typical):

- MCP enabled: `true`
- MCP path: `/mcp`

Runtime knobs:

```json
{
  "runtime": {
    "mcp": {
      "enabled": true,
      "path": "/mcp",
      "dml-tools": {
        "describe-entities": true,
        "create-record": true,
        "read-records": true,
        "update-record": true,
        "delete-record": true,
        "execute-entity": true
      }
    }
  }
}
```

Entity knob:

- Entities participate by default when MCP is enabled globally.
- You can disable MCP per entity via `entities.<name>.mcp.dml-tools`.

## The six DML tools (what to expect)

- `describe_entities`: returns entities, fields, keys, allowed operations for the current role.
- `read_records`: structured query (filter/sort/paging/field selection); results are cacheable.
- `create_record`: insert; enforces create permissions + field-level restrictions.
- `update_record`: update by key; enforces update permissions + field-level restrictions.
- `delete_record`: delete by key; enforces delete permissions (often disabled in prod).
- `execute_entity`: execute stored procedure; validates parameters; enforces execute permissions.

## Common failure modes (and fixes)

### Tool not listed / not callable

1) MCP disabled globally (`runtime.mcp.enabled=false`)
2) Tool disabled globally (`runtime.mcp.dml-tools.<tool>=false`)
3) Entity excluded (`entities.<name>.mcp.dml-tools=false`)
4) RBAC denies it (role lacks action on entity)

Fix: start with `describe_entities` under the same role; confirm operations list.

### 401/403 from MCP

- MCP uses the same auth/role selection rules as REST/GraphQL.
- Confirm the selected role and that the entity’s permissions include required actions.

See `authentication.md`.

## VS Code MCP connection (local)

The local quickstart uses `.vscode/mcp.json` with an HTTP MCP endpoint:

```json
{
  "servers": {
    "sql-mcp-server": {
      "type": "http",
      "url": "http://localhost:5000/mcp"
    }
  }
}
```

## Agent behavior guidance

- Always call `describe_entities` first.
- Never ask for raw SQL.
- Narrow fields aggressively to only what’s needed.
- For write operations, prefer small, explicit updates and confirm keys.
