# Config schema (source of truth)

## Authoritative schema source

Use the official DAB config JSON schema as the authority for:

- Property names and casing (kebab-case)
- Which properties are required/optional
- Allowed enum values

Schema link (raw):

- https://raw.githubusercontent.com/Azure/data-api-builder/refs/heads/main/schemas/dab.draft.schema.json

Repo pointer (legacy):

- Do not rely on the docs-author folder for this agent. Use the schema URL above.

## How the agent should use the schema

When you need to answer questions like:

- “What’s the exact property name?”
- “Is this required?”
- “What are the allowed values?”

Do this:

1. Check the local `dab` CLI output when the question is about a CLI flag.
2. Check the schema when the question is about `dab-config.json` structure.
3. If a generated config exists from a CLI run, trust the generated JSON.

## Minimal top-level mental model

- `data-source`: connection details and database type
- `runtime`: REST/GraphQL/MCP endpoints and runtime behavior
- `entities`: the security boundary for tables/views/stored-procedures exposed by DAB

Rules of thumb:

- Don’t invent new properties.
- If you’re hand-editing JSON, validate with `dab validate` immediately.
