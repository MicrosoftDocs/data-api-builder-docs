# CLI workflows (Copilot playbooks)

This is written for an agent to reliably execute common developer tasks.

## Workflow: new project → running API locally

1) Verify install

- `dab --version`

2) Initialize config

- Choose `--database-type` and set `--connection-string`.
- Set `--host-mode Development` when iterating locally.

3) Add one entity (table/view/stored-procedure)

- Always set `--permissions`.
- Set `--source.type` when not a table.

4) Validate

- `dab validate -c dab-config.json`

5) Run

- `dab start -c dab-config.json`

6) Smoke test

- REST default path is usually `/api`; GraphQL is usually `/graphql`; MCP is usually `/mcp`.
- Don’t assume enabled: check `dab-config.json`.

## Workflow: add a relationship (GraphQL)

- Ensure **both entities exist** in config.
- Use `dab update <sourceEntity>` with `--relationship`, `--target.entity`, `--cardinality`.
- If many-to-many without exposing join table, use the linking-object flags.
- Validate and then test with a nested GraphQL query.

See `relationships.md`.

## Workflow: auth/role debugging

- Confirm runtime authentication provider in config.
- Confirm the request role selection header (`X-MS-API-ROLE`) matches the token roles (Azure) or desired role (local simulators).
- Validate permissions on the entity.

See `authentication.md`.

## Workflow: SQL MCP Server (preview)

- Confirm `dab` version >= 1.7 and `runtime.mcp.enabled`.
- Confirm entity permissions: MCP tools respect the same RBAC.
- Prefer disabling entire MCP or individual tools only when required.

See `sql-mcp-server.md`.
