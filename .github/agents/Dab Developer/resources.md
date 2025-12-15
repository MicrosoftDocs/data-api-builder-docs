# DAB developer reference (Copilot resources)

Use this file as the **single source of guidance** when acting as a Data API builder (DAB) developer assistant.

## Authoritative sources

- CLI help output: `dab <command> --help` (authoritative for flags, defaults, and constraints)
- DAB config schema (authoritative for config shape and enums): https://raw.githubusercontent.com/Azure/data-api-builder/refs/heads/main/schemas/dab.draft.schema.json

If an enum/value isn’t explicitly listed in CLI help, don’t invent it—verify via schema or omit.

## Core CLI workflows

### Initialize and run locally

- Create a new config: `dab init`
- Configure connection/runtime options: `dab configure`
- Add entities: `dab add`
- Update existing entities: `dab update`
- Validate config: `dab validate`
- Run the engine: `dab start`

### Debugging workflow (minimal)

- Confirm CLI version: `dab --version`
- Confirm supported flags: `dab <command> --help`
- Validate the current config: `dab validate`
- If behavior differs from expectations, reduce to the smallest repro (single entity, minimal runtime settings).

## Relationships (GraphQL)

- Relationships are GraphQL-focused. When troubleshooting:
  - Confirm both entities exist and have compatible key fields.
  - Confirm relationship names are consistent (and reciprocal relationships exist when required).
  - For many-to-many, confirm the linking entity/object is configured correctly.

When documenting or generating config, prefer the CLI subcommands that manage relationships; avoid hand-editing relationship blocks unless required.

## Authentication and authorization

- DAB evaluates a single role per request (commonly via `X-MS-API-ROLE`).
- When troubleshooting authorization:
  - Confirm the role header/value you’re sending.
  - Confirm entity permissions include that role for the requested operation.
  - Confirm authentication provider settings match the environment (local vs Azure).

## SQL MCP Server (preview)

- Treat the MCP server as a **deterministic tool surface** (CRUD/execute-style operations), not a free-form NL2SQL channel.
- Ensure you:
  - Enable MCP in runtime settings (only if supported by the installed DAB version).
  - Gate operations via the same authz model (roles/permissions) as other endpoints.
  - Prefer smallest-scope operations (single-entity reads/writes) and avoid broad destructive actions.
