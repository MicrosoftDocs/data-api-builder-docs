# DAB CLI version notes (v1.6 vs v1.7 RC)

Use this note when authoring CLI docs that may apply to multiple DAB versions.

Captured help outputs in this repo:

- v1.6.84: `dab-cli-help-1.6.84.md`
- v1.7.81-rc: `dab-cli-help-1.7.81-rc.md`

## Guidance

- Prefer the latest *stable* CLI help output for authoritative option lists.
- Treat v1.7.81 as **RC**: options, defaults, and surface area may change before GA.
- When a doc page must cover both versions, call out version-specific differences explicitly.

## Differences observed in captured help outputs

### `dab configure`

- v1.7.81-rc includes MCP options (`--runtime.mcp.*` and `--runtime.mcp.dml-tools.*`).
- v1.6.84 does not list MCP options.

### `dab init`

- v1.7.81-rc includes MCP options (`--mcp.path`, `--mcp.disabled`, `--mcp.enabled`).
- v1.6.84 does not list MCP options.

### `dab add` and `dab update`

- Option surfaces are effectively the same between v1.6.84 and v1.7.81-rc in the captured outputs.
- v1.7.81-rc adds stored procedure parameter metadata flags on `add` and `update` (`--parameters.name|description|required|default`).
  - These flags are present in the v1.7.81-rc capture (`dab-cli-help-1.7.81-rc.md`).
  - They are not present in the provided v1.6.84 capture.

### `dab start`

- No differences observed between v1.6.84 and v1.7.81-rc in the captured outputs.
