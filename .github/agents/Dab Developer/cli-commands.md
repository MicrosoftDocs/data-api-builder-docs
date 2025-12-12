# DAB CLI commands (quick reference)

Principles:

- **CLI help is authoritative**: if a flag/value is uncertain, run `dab <cmd> --help`.
- **Prefer CLI mutations** over hand-editing JSON.
- **Always validate** after changes: `dab validate`.

## Command map

| Task | Command |
| --- | --- |
| Create base config | `dab init` |
| Add an entity | `dab add <entity>` |
| Update an entity | `dab update <entity>` |
| Configure non-entity properties | `dab configure` |
| Validate config | `dab validate` |
| Run locally | `dab start` |
| Export GraphQL schema | `dab export` |
| Version | `dab --version` or `dab version` |
| Help | `dab <cmd> --help` |

## Universal flags

Most commands support:

- `-c, --config` (respects `dab-config.<DAB_ENVIRONMENT>.json` override)
- `--help`
- `--version`

## Capturing help output (for debugging / “source of truth”)

Command Prompt:

```cmd
mkdir .github\agents\Dab Developer\cli-help-live-local

dab update --help > .github\agents\Dab Developer\cli-help-live-local\dab-update--help.txt
```

PowerShell:

```powershell
New-Item -ItemType Directory -Force .github/agents/Dab\ Developer/cli-help-live-local | Out-Null

dab update --help | Out-File -Encoding utf8 .github/agents/Dab\ Developer/cli-help-live-local/dab-update--help.txt
```

## Flags that commonly trip people

- Role/action strings: `--permissions "role:action1,action2"`.
- Views/non-PK tables: `--source.key-fields` is often required.
- Stored procedures:
  - `--source.type stored-procedure`
  - REST method control: `--rest.methods GET,POST,...`
  - GraphQL operation control: `--graphql.operation Query|Mutation`
  - Params: `--parameters.*` (v1.7 RC)
- Relationships:
  - Use `dab update <entity> --relationship <name> ...` (see `relationships.md`).
