# Dab Developer agent resources

This folder is the **self-contained reference set** for the `dab-developer` Copilot agent.

Scope:

- DAB CLI workflows: install/verify, init/configure/add/update/export/validate/start
- Config schema “source of truth” usage
- Relationships (GraphQL) modeling via config + `dab update`
- Authentication & authorization troubleshooting (local + Azure)
- SQL MCP Server (preview) setup and operational guardrails

Design goals:

- Optimized for agent success (checklists, decision tables, minimal prose)
- Prefer authoritative sources: live `dab <cmd> --help`, generated `dab-config.json`, and config JSON schema

Start here:

- `cli-workflows.md`
- `cli-commands.md`
- `config-schema.md`
- `relationships.md`
- `authentication.md`
- `sql-mcp-server.md`
