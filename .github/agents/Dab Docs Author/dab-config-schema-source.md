# DAB config schema (source)

Authoritative source (raw):

- https://raw.githubusercontent.com/Azure/data-api-builder/refs/heads/main/schemas/dab.draft.schema.json

Use this schema as the source of truth for:

- Top-level config shape (`data-source`, `runtime`, `entities`, etc.).
- Property names (kebab-case vs camelCase) and allowed values.
- Which properties are required vs optional.

When writing docs, prefer confirming config shapes against this schema rather than inferring from examples.

## Key excerpts (non-exhaustive)

The snippets below are included for quick reference only. Always consult the source link above for the complete schema.

### Top-level

```json
{
  "$schema": "http://json-schema.org/draft-07/schema",
  "$id": "https://github.com/Azure/data-api-builder/releases/download/vmajor.minor.patch/dab.draft.schema.json",
  "type": "object",
  "required": ["data-source", "entities"],
  "properties": {
    "$schema": { "type": "string", "default": null },
    "data-source": { "type": "object" },
    "data-source-files": { "type": "array", "default": null },
    "runtime": { "type": "object" },
    "azure-key-vault": { "type": "object" },
    "entities": { "type": "object" }
  }
}
```

### `data-source`

```json
{
  "data-source": {
    "type": "object",
    "additionalProperties": false,
    "required": ["database-type", "connection-string"],
    "properties": {
      "database-type": {
        "type": "string",
        "enum": ["mssql", "postgresql", "mysql", "cosmosdb_nosql", "cosmosdb_postgresql"]
      },
      "connection-string": { "type": "string" },
      "options": { "type": "object" },
      "health": { "type": ["object", "null"] }
    }
  }
}
```

### `runtime` endpoints

```json
{
  "runtime": {
    "type": "object",
    "properties": {
      "rest": {
        "type": "object",
        "properties": {
          "path": { "type": "string", "default": "/api" },
          "enabled": { "type": "boolean" },
          "request-body-strict": { "type": "boolean", "default": true }
        }
      },
      "graphql": {
        "type": "object",
        "properties": {
          "path": { "type": "string", "default": "/graphql" },
          "enabled": { "type": "boolean" },
          "allow-introspection": { "type": "boolean" },
          "depth-limit": { "type": ["integer", "null"], "default": null }
        }
      },
      "mcp": {
        "type": "object",
        "properties": {
          "path": { "type": "string", "default": "/mcp" },
          "enabled": { "type": "boolean", "default": true }
        }
      }
    }
  }
}
```

### `entities` (high-level)

```json
{
  "entities": {
    "type": "object",
    "patternProperties": {
      "^.*$": {
        "type": "object",
        "additionalProperties": false,
        "required": ["source", "permissions"],
        "properties": {
          "description": { "type": "string" },
          "source": { "oneOf": [{ "type": "string" }, { "type": "object" }] },
          "rest": { "oneOf": [{ "type": "boolean" }, { "type": "object" }] },
          "graphql": { "oneOf": [{ "type": "boolean" }, { "type": "object" }] },
          "permissions": { "type": "array" },
          "mappings": { "type": "object" },
          "relationships": { "type": "object" },
          "cache": { "type": "object" }
        }
      }
    }
  }
}
```