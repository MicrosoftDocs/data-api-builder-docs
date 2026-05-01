---
title: Configuration schema - Autoentities section
description: The Data API Builder configuration file's Autoentities top-level section with details for each property.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/24/2026
show_latex: true
---

# `Autoentities`

Configuration settings for automatic entity generation based on pattern-matching rules. `Autoentities` is a peer to the [`entities`](entities.md) section—when `autoentities` is present, `entities` is no longer required. The schema allows either `autoentities` or `entities` (or both). If both are present, explicitly defined entities take precedence over `autoentities` matches with the same name.

> [!TIP]
> Use [`dab auto-config`](../command-line/dab-auto-config.md) to create and update `autoentities` definitions from the CLI, and [`dab auto-config-simulate`](../command-line/dab-auto-config-simulate.md) to preview which objects match before committing changes.

## Patterns

| Property | Description |
|-|-|
| [`patterns.include`](#patterns-definition-name-autoentities) | MSSQL `LIKE` patterns for objects to include |
| [`patterns.exclude`](#patterns-definition-name-autoentities) | MSSQL `LIKE` patterns for objects to exclude |
| [`patterns.name`](#name-patterns-definition-name-autoentities) | Interpolation pattern for entity naming |

## Template

| Property | Description |
|-|-|
| [`template.rest.enabled`](#rest-template-definition-name-autoentities) | Enable REST for matched entities |
| [`template.graphql.enabled`](#graphql-template-definition-name-autoentities) | Enable GraphQL for matched entities |
| [`template.mcp.dml-tools`](#mcp-template-definition-name-autoentities) | Enable Model Context Protocol (MCP) data manipulation language (DML) tools for matched entities |
| [`template.health.enabled`](#health-template-definition-name-autoentities) | Enable health checks for matched entities |
| [`template.cache.enabled`](#cache-template-definition-name-autoentities) | Enable response caching for matched entities |
| [`template.cache.ttl-seconds`](#cache-template-definition-name-autoentities) | Cache time-to-live in seconds |
| [`template.cache.level`](#cache-template-definition-name-autoentities) | Cache level: `L1` or `L1L2` |

## Permissions

| Property | Description |
|-|-|
| [`permissions[].role`](#permissions-definition-name-autoentities) | Role name string |
| [`permissions[].actions`](#permissions-definition-name-autoentities) | One or more of: `create`, `read`, `update`, `delete`, or `*` |

## Format overview

```json
{
  "autoentities": {
    "<definition-name>": {
      "patterns": {
        "include": [ "<string>" ],    // default: ["%.%"]
        "exclude": [ "<string>" ],    // default: null
        "name": "<string>"            // default: "{schema}_{object}"
      },
      "template": {
        "rest": { "enabled": <boolean> },      // default: true
        "graphql": { "enabled": <boolean> },   // default: true
        "mcp": { "dml-tools": <boolean> },     // default: true
        "health": { "enabled": <boolean> },    // default: true
        "cache": {
          "enabled": <boolean>,                // default: false
          "ttl-seconds": <integer>,            // default: null
          "level": "<string>"                  // default: "L1L2"
        }
      },
      "permissions": [
        {
          "role": "<string>",
          "actions": [ { "action": "<string>" } ]
        }
      ]
    }
  }
}
```

## Definition name (`autoentities`)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities` | `<definition-name>` | object | ✔️ Yes | None |

Each key in the `autoentities` object is a named definition. The name is case-sensitive and serves as a logical identifier. You can define multiple definitions with different patterns and permissions.

### Format

```json
{
  "autoentities": {
    "<definition-name>": { ... }
  }
}
```

### Example

```json
{
  "autoentities": {
    "public-tables": {
      "patterns": { "include": [ "dbo.%" ] },
      "permissions": [ { "role": "anonymous", "actions": [ { "action": "read" } ] } ]
    },
    "admin-tables": {
      "patterns": { "include": [ "admin.%" ] },
      "permissions": [ { "role": "authenticated", "actions": [ { "action": "*" } ] } ]
    }
  }
}
```

## Patterns (definition-name `autoentities`)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>` | `patterns` | object | ❌ No | None |

Defines include, exclude, and naming rules that determine which database objects are exposed as entities.

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.patterns` | `include` | string array | ❌ No | `["%.%"]` |
| `autoentities.<definition-name>.patterns` | `exclude` | string array | ❌ No | `null` |
| `autoentities.<definition-name>.patterns` | `name` | string | ❌ No | `"{schema}_{object}"` |

- **`include`**—One or more MSSQL `LIKE` patterns specifying which database objects to include. Use `%` as a wildcard. The pattern format is `schema.object` (for example, `dbo.%` matches all objects in the `dbo` schema). When `null` or omitted, defaults to `["%.%"]` (all objects in all schemas).

- **`exclude`**—One or more MSSQL `LIKE` patterns specifying which database objects to exclude. Exclude patterns are evaluated after include patterns. When `null` or omitted, no objects are excluded.

- **`name`**—Interpolation pattern that controls how matched database objects are named as entities. Supports `{schema}` and `{object}` placeholders. Each resolved name must be unique across all entities in the configuration.

### Format

```json
{
  "autoentities": {
    "<definition-name>": {
      "patterns": {
        "include": [ "<string>" ],
        "exclude": [ "<string>" ],
        "name": "<string>"
      }
    }
  }
}
```

### Example

```json
{
  "autoentities": {
    "my-def": {
      "patterns": {
        "include": [ "dbo.%" ],
        "exclude": [ "dbo.internal%" ],
        "name": "{schema}_{object}"
      }
    }
  }
}
```

With this configuration, every table in the `dbo` schema (except those matching `dbo.internal%`) is exposed as an entity. A table named `dbo.Products` becomes an entity named `dbo_Products`.

## Name (patterns definition-name `autoentities`)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.patterns` | `name` | string | ❌ No | `"{schema}_{object}"` |

Controls how matched database objects are named as entities. Supports two placeholders:

| Placeholder | Resolves to |
|-|-|
| `{schema}` | The schema name of the matched database object |
| `{object}` | The object name of the matched database object |

When omitted, the default `"{schema}_{object}"` combines the schema and object name with an underscore, helping keep generated entity names unique across schemas.

### Format

```json
{
  "autoentities": {
    "<definition-name>": {
      "patterns": {
        "name": "<string>"
      }
    }
  }
}
```

### Examples

| Pattern | Database object | Entity name |
|-|-|-|
| `"{schema}_{object}"` | `dbo.Products` | `dbo_Products` |
| `"{object}"` | `dbo.Products` | `Products` |
| `"{schema}.{object}"` | `sales.Orders` | `sales.Orders` |

## REST (template definition-name `autoentities`)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template` | `rest` | object | ❌ No | None |

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template.rest` | `enabled` | boolean | ❌ No | `true` |

### Format

```json
{
  "autoentities": {
    "<definition-name>": {
      "template": {
        "rest": { "enabled": <boolean> }
      }
    }
  }
}
```

### Example

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "rest": { "enabled": false }
      }
    }
  }
}
```

## GraphQL (template definition-name `autoentities`)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template` | `graphql` | object | ❌ No | None |

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template.graphql` | `enabled` | boolean | ❌ No | `true` |

### Format

```json
{
  "autoentities": {
    "<definition-name>": {
      "template": {
        "graphql": { "enabled": <boolean> }
      }
    }
  }
}
```

### Example

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "graphql": { "enabled": true }
      }
    }
  }
}
```

## MCP (template definition-name `autoentities`)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template` | `mcp` | object | ❌ No | None |

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template.mcp` | `dml-tools` | boolean | ❌ No | `true` |

Enables or disables MCP data manipulation language (DML) tools for all matched entities.

### Format

```json
{
  "autoentities": {
    "<definition-name>": {
      "template": {
        "mcp": { "dml-tools": <boolean> }
      }
    }
  }
}
```

### Example

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "mcp": { "dml-tools": true }
      }
    }
  }
}
```

## Health (template definition-name `autoentities`)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template` | `health` | object | ❌ No | None |

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template.health` | `enabled` | boolean | ❌ No | `true` |

### Format

```json
{
  "autoentities": {
    "<definition-name>": {
      "template": {
        "health": { "enabled": <boolean> }
      }
    }
  }
}
```

### Example

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "health": { "enabled": true }
      }
    }
  }
}
```

## Cache (template definition-name `autoentities`)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template` | `cache` | object | ❌ No | None |

Enables and configures response caching for all matched entities.

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.template.cache` | `enabled` | boolean | ❌ No | `false` |
| `autoentities.<definition-name>.template.cache` | `ttl-seconds` | integer | ❌ No | `null` |
| `autoentities.<definition-name>.template.cache` | `level` | enum (`L1` \| `L1L2`) | ❌ No | `"L1L2"` |

The `level` property controls which cache tiers are used:

| Value | Description |
|---|---|
| `L1` | In-memory cache only. Fastest, but not shared across instances. |
| `L1L2` | In-memory cache plus distributed (Redis) cache. Shared across scaled-out instances. Default. |

> [!NOTE]
> When `ttl-seconds` is `null` or omitted, it inherits the global value from `runtime.cache.ttl-seconds`.

### Format

```json
{
  "autoentities": {
    "<definition-name>": {
      "template": {
        "cache": {
          "enabled": <boolean>,
          "ttl-seconds": <integer>,
          "level": "<L1 | L1L2>"
        }
      }
    }
  }
}
```

### Example

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "cache": {
          "enabled": true,
          "ttl-seconds": 30,
          "level": "L1L2"
        }
      }
    }
  }
}
```

## Permissions (definition-name `autoentities`)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>` | `permissions` | array | ❌ No | None |

Permissions applied to every entity matched by this `autoentities` definition. Each element is an object with a `role` and an `actions` array.

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `autoentities.<definition-name>.permissions[]` | `role` | string | ✔️ Yes | None |
| `autoentities.<definition-name>.permissions[]` | `actions` | array or string | ✔️ Yes | None |
| `autoentities.<definition-name>.permissions[].actions[]` | `action` | string | ✔️ Yes | None |

Supported action values: `create`, `read`, `update`, `delete`, or `*` (wildcard expands to all four CRUD actions).

### Format

```json
{
  "autoentities": {
    "<definition-name>": {
      "permissions": [
        {
          "role": "<string>",
          "actions": [ { "action": "<string>" } ]
        }
      ]
    }
  }
}
```

### Example

```json
{
  "autoentities": {
    "my-def": {
      "patterns": {
        "include": [ "dbo.%" ]
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] },
        { "role": "authenticated", "actions": [ { "action": "*" } ] }
      ]
    }
  }
}
```

## Full example

```json
{
  "autoentities": {
    "my-def": {
      "patterns": {
        "include": [ "dbo.%" ],
        "exclude": [ "dbo.internal%" ],
        "name": "{schema}_{object}"
      },
      "template": {
        "rest": { "enabled": true },
        "graphql": { "enabled": true },
        "mcp": { "dml-tools": true },
        "health": { "enabled": true },
        "cache": { "enabled": true, "ttl-seconds": 30, "level": "L1L2" }
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ]
    }
  }
}
```

With this configuration, every table in the `dbo` schema (except those matching `dbo.internal%`) is automatically exposed as a DAB entity. Each entity is named using the `{schema}_{object}` pattern (for example, `dbo_Products`), has REST, GraphQL, MCP, and health checks enabled, uses caching with a 30-second time-to-live, and grants `read` access to the `anonymous` role.

## Related content

- [`dab auto-config` command reference](../command-line/dab-auto-config.md)
- [`dab auto-config-simulate` command reference](../command-line/dab-auto-config-simulate.md)
- [What's new in version 2.0](../whats-new/version-2-0.md)
- [Entities configuration](entities.md)
