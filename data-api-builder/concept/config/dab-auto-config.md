---
title: Create autoentities with the DAB CLI
description: Use the Data API builder (DAB) CLI to create or update autoentities definitions that automatically expose matching database objects as API entities.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/24/2026
# Customer Intent: As a developer, I want to define pattern-based rules that automatically expose matching database objects as DAB entities, so that I can wire up an entire schema without writing individual entity blocks.
---

# Create autoentities with the DAB CLI

Auto configuration is a powerful feature that allows you to define patterns that automatically find and expose database objects in your configuration. This can dramatically shrink a configuration file, especially when objects and permissions are predictable. In addition, `autoentities` reevaluate and apply the patterns each time DAB starts, so new tables that match the pattern are automatically added as entities without manual config changes.

> [!NOTE]
> Autoentities currently support **MSSQL** data sources only.

## `dab auto-config` command

With `auto-config`, you can wire up an entire database schema as a DAB API without writing a single entity block by hand. Define your patterns once and DAB does the rest.

Create or update an `autoentities` definition in an existing Data API builder configuration file. Autoentities define pattern-based rules that automatically expose matching database objects as DAB entities at startup.

> [!TIP]
> Use `dab auto-config` to define autoentities patterns, and [`dab auto-config-simulate`](#auto-config-simulate-command) to preview matched objects before committing changes.

## Syntax

```bash
dab auto-config <definition-name> [options]
```

When `autoentities` is present in the configuration, the `entities` section is no longer required. The schema requires either `autoentities` or `entities` (or both).

### Quick glance

| Option | Summary |
| --- | --- |
| `<definition-name>` | Required positional argument. Name of the autoentities definition. |
| [`-c, --config`](#-c---config) | Config file path. Default `dab-config.json`. |

#### Patterns

| Option | Summary |
| --- | --- |
| [`--patterns.include`](#--patternsinclude) | MSSQL LIKE patterns for objects to include. |
| [`--patterns.exclude`](#--patternsexclude) | MSSQL LIKE patterns for objects to exclude. |
| [`--patterns.name`](#--patternsname) | Interpolation pattern for entity naming. |

#### Template

| Option | Summary |
| --- | --- |
| [`--template.rest.enabled`](#--templaterestenabled) | Enable REST for matched entities. |
| [`--template.graphql.enabled`](#--templategraphqlenabled) | Enable GraphQL for matched entities. |
| [`--template.mcp.dml-tools`](#--templatemcpdml-tools) | Enable Model Context Protocol (MCP) data manipulation language (DML) tools for matched entities. |
| [`--template.health.enabled`](#--templatehealthenabled) | Enable health checks for matched entities. |
| [`--template.cache.enabled`](#--templatecacheenabled) | Enable caching for matched entities. |
| [`--template.cache.ttl-seconds`](#--templatecachettl-seconds) | Cache time-to-live in seconds. |
| [`--template.cache.level`](#--templatecachelevel) | Cache level (`L1L2`). |

#### Permissions

| Option | Summary |
| --- | --- |
| [`--permissions`](#--permissions) | Permissions applied to all matched entities. |

---

## `<definition-name>`

Logical name of the autoentities definition. Case-sensitive. If the definition already exists, the command updates it; otherwise, the command creates it.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "patterns": {
        "include": [ "dbo.%" ]
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ]
    }
  }
}
```

## `-c, --config`

Path to the config file. Defaults to `dab-config.json` unless `dab-config.<DAB_ENVIRONMENT>.json` exists, where `DAB_ENVIRONMENT` is an environment variable.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --config ./dab-config.json \
  --patterns.include "dbo.%"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --config ./dab-config.json ^
  --patterns.include "dbo.%"
```

---

## `--patterns.include`

One or more MSSQL `LIKE` patterns specifying which database objects to include. Use `%` as a wildcard. The pattern format is `schema.object` (for example, `dbo.%` matches all objects in the `dbo` schema).

Default: `["%.%"]` (all objects in all schemas).

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "patterns": {
        "include": [ "dbo.%" ]
      }
    }
  }
}
```

## `--patterns.exclude`

One or more MSSQL `LIKE` patterns specifying which database objects to exclude. Exclude patterns are evaluated after include patterns.

Default: `null` (no objects excluded).

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --patterns.exclude "dbo.internal%" \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --patterns.exclude "dbo.internal%" ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "patterns": {
        "include": [ "dbo.%" ],
        "exclude": [ "dbo.internal%" ]
      }
    }
  }
}
```

## `--patterns.name`

Interpolation pattern that controls how matched database objects are named as entities. Supports `{schema}` and `{object}` placeholders.

Default: `"{object}"` (entity name matches the database object name).

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --patterns.name "{schema}_{object}" \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --patterns.name "{schema}_{object}" ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "patterns": {
        "include": [ "dbo.%" ],
        "name": "{schema}_{object}"
      }
    }
  }
}
```

With this pattern, a database object `dbo.Products` becomes an entity named `dbo_Products`.

## `--template.rest.enabled`

Enable REST endpoints for all matched entities. Default is `true`.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.rest.enabled true \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --template.rest.enabled true ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "rest": { "enabled": true }
      }
    }
  }
}
```

## `--template.graphql.enabled`

Enable GraphQL for all matched entities. Default is `true`.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.graphql.enabled true \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --template.graphql.enabled true ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

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

## `--template.mcp.dml-tools`

Enable MCP DML tools for all matched entities.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.mcp.dml-tools true \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --template.mcp.dml-tools true ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

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

## `--template.health.enabled`

Enable health checks for all matched entities.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.health.enabled true \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --template.health.enabled true ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

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

## `--template.cache.enabled`

Enable response caching for all matched entities. Default is `false`.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.cache.enabled true \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --template.cache.enabled true ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "cache": { "enabled": true }
      }
    }
  }
}
```

## `--template.cache.ttl-seconds`

Cache time-to-live in seconds for all matched entities.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.cache.enabled true \
  --template.cache.ttl-seconds 30 \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --template.cache.enabled true ^
  --template.cache.ttl-seconds 30 ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "cache": { "enabled": true, "ttl-seconds": 30 }
      }
    }
  }
}
```

## `--template.cache.level`

Cache level for all matched entities. Supported value: `L1L2`.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.cache.enabled true \
  --template.cache.ttl-seconds 30 \
  --template.cache.level L1L2 \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --template.cache.enabled true ^
  --template.cache.ttl-seconds 30 ^
  --template.cache.level L1L2 ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "cache": { "enabled": true, "ttl-seconds": 30, "level": "l1l2" }
      }
    }
  }
}
```

[Autoentities configuration](../../configuration/autoentities.md).

## `--permissions`

Permissions applied to every entity matched by this autoentities definition. Uses the `role:actions` format.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ]
    }
  }
}
```

## Full example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --patterns.exclude "dbo.internal%" \
  --patterns.name "{schema}_{object}" \
  --template.rest.enabled true \
  --template.graphql.enabled true \
  --template.cache.enabled true \
  --template.cache.ttl-seconds 30 \
  --template.cache.level L1L2 \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --patterns.exclude "dbo.internal%" ^
  --patterns.name "{schema}_{object}" ^
  --template.rest.enabled true ^
  --template.graphql.enabled true ^
  --template.cache.enabled true ^
  --template.cache.ttl-seconds 30 ^
  --template.cache.level L1L2 ^
  --permissions "anonymous:read"
```

---

### Resulting configuration

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
        "cache": { "enabled": true, "ttl-seconds": 30, "level": "l1l2" }
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ]
    }
  }
}
```

## `auto-config-simulate` command

Preview which database objects match the autoentities patterns defined in your Data API builder configuration file. The command connects to the database, resolves each pattern, and prints the matched objects. No changes are written to the configuration.

> [!TIP]
> Use `dab auto-config` to define autoentities patterns, and `dab auto-config-simulate` to verify them.

> [!IMPORTANT]
> `dab auto-config-simulate` currently supports **MSSQL** data sources only.

### Syntax

```bash
dab auto-config-simulate [options]
```

| Option | Summary |
| --- | --- |
| [`-c, --config`](#-c---config-1) | Config file path. Default `dab-config.json`. |
| [`--output`](#--output) | Write results to a CSV file instead of the console. |

### `-c, --config`

Path to the config file. Defaults to `dab-config.json` unless `dab-config.<DAB_ENVIRONMENT>.json` exists, where `DAB_ENVIRONMENT` is an environment variable.

#### Example

##### [Bash](#tab/bash)

```bash
dab auto-config-simulate \
  --config ./dab-config.json
```

##### [Command Prompt](#tab/cmd)

```cmd
dab auto-config-simulate ^
  --config ./dab-config.json
```

---

### `--output`

Write simulation results to a CSV file instead of printing to the console. The CSV includes columns for the filter name, entity name, and database object.

#### Example

##### [Bash](#tab/bash)

```bash
dab auto-config-simulate \
  --output results.csv
```

##### [Command Prompt](#tab/cmd)

```cmd
dab auto-config-simulate ^
  --output results.csv
```

---

#### Example CSV output

```csv
filter_name,entity_name,database_object
my-def,dbo_Products,dbo.Products
my-def,dbo_Inventory,dbo.Inventory
my-def,dbo_Pricing,dbo.Pricing
```

### Console output

When `--output` isn't specified, results print directly to the console.

#### Example

##### [Bash](#tab/bash)

```bash
dab auto-config-simulate
```

##### [Command Prompt](#tab/cmd)

```cmd
dab auto-config-simulate
```

---

#### Example console output

```text
AutoEntities Simulation Results

Filter: my-def
Matches: 3
  dbo_Products  →  dbo.Products
  dbo_Inventory →  dbo.Inventory
  dbo_Pricing   →  dbo.Pricing
```

## Related content

- [What's new in version 2.0](../../whats-new/version-2-0.md)
- [Autoentities configuration](../../configuration/autoentities.md)
- [Entities configuration](../../configuration/entities.md)
