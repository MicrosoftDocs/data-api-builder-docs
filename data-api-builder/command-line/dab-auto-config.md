---
title: Auto-config command reference for DAB CLI
description: Use the Data API builder (DAB) CLI auto-config command to create or update autoentities definitions from the command line.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/24/2026
# Customer Intent: As a developer, I want a quick CLI reference for dab auto-config so I can create autoentities definitions from the command line.
---

# `auto-config` command

Create or update an `autoentities` definition in an existing Data API builder configuration file. Autoentities define pattern-based rules that automatically expose matching database objects as DAB entities at startup.

> [!TIP]
> For in-depth explanations, examples with resulting configuration output, and conceptual guidance, see [Auto configuration](../concept/config/auto-config.md). For the JSON configuration reference, see [Autoentities configuration](../configuration/autoentities.md).

> [!IMPORTANT]
> Autoentities currently support **MSSQL** data sources only.

## Syntax

```sh
dab auto-config <definition-name> [options]
```

### Quick glance

| Option | Summary |
| --- | --- |
| `<definition-name>` | Required. Name of the autoentities definition to configure. |
| [`-c, --config`](#-c---config) | Config file path. Default `dab-config.json`. |
| [`--patterns.include`](#--patternsinclude) | T-SQL `LIKE` pattern(s) to include database objects. Default: `%.%`. |
| [`--patterns.exclude`](#--patternsexclude) | T-SQL `LIKE` pattern(s) to exclude database objects. Default: `null`. |
| [`--patterns.name`](#--patternsname) | Interpolation syntax for entity naming. Default: `{object}`. |
| [`--template.rest.enabled`](#--templaterestenabled) | Enable/disable REST for matched entities. Default: `true`. |
| [`--template.graphql.enabled`](#--templategraphqlenabled) | Enable/disable GraphQL for matched entities. Default: `true`. |
| [`--template.mcp.dml-tool`](#--templatemcpdml-tool) | Enable/disable MCP DML tools for matched entities. Default: `true`. |
| [`--template.health.enabled`](#--templatehealthenabled) | Enable/disable health checks for matched entities. Default: `true`. |
| [`--template.cache.enabled`](#--templatecacheenabled) | Enable/disable caching for matched entities. Default: `false`. |
| [`--template.cache.ttl-seconds`](#--templatecachettl-seconds) | Cache time-to-live in seconds. Default: `null`. |
| [`--template.cache.level`](#--templatecachelevel) | Cache level. Allowed values: `L1`, `L1L2`. Default: `L1L2`. |
| [`--permissions`](#--permissions) | Permissions in `role:actions` format. Default: `null`. |

## `<definition-name>`

Required positional argument. Logical name of the autoentities definition. Case-sensitive. If the definition already exists, it's updated; otherwise it's created.

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

Path to config file. Defaults to `dab-config.json` unless `dab-config.<DAB_ENVIRONMENT>.json` exists, where `DAB_ENVIRONMENT` is an environment variable.

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

## `--patterns.include`

T-SQL `LIKE` pattern(s) to include database objects. Space-separated array. The pattern format is `schema.object` (for example, `dbo.%`). Default: `%.%`.

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
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

## `--patterns.exclude`

T-SQL `LIKE` pattern(s) to exclude database objects. Space-separated array. Exclude patterns are evaluated after include patterns. Default: `null`.

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
      },
      "permissions": [
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

## `--patterns.name`

Interpolation syntax for entity naming. Supports `{schema}` and `{object}` placeholders. Must be unique for each generated entity. Default: `{object}`.

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
      },
      "permissions": [
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

## `--template.rest.enabled`

Enable or disable REST endpoints for all matched entities. Allowed values: `true`, `false`. Default: `true`.

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

Enable or disable GraphQL for all matched entities. Allowed values: `true`, `false`. Default: `true`.

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

## `--template.mcp.dml-tool`

Enable or disable MCP DML tools for all matched entities. Allowed values: `true`, `false`. Default: `true`.

### Example

#### [Bash](#tab/bash)

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.mcp.dml-tool true \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab auto-config my-def ^
  --patterns.include "dbo.%" ^
  --template.mcp.dml-tool true ^
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

Enable or disable health checks for all matched entities. Allowed values: `true`, `false`. Default: `true`.

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

Enable or disable response caching for all matched entities. Allowed values: `true`, `false`. Default: `false`.

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

Cache time-to-live in seconds for all matched entities. Default: `null`.

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

Cache level for all matched entities. Allowed values: `L1`, `L1L2`. Default: `L1L2`.

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

## `--permissions`

Permissions for all matched entities in `role:actions` format. Default: `null`.

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
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

## Related content

- [Auto configuration (concept)](../concept/config/auto-config.md)
- [`dab auto-config-simulate` command](dab-auto-config-simulate.md)
- [Autoentities configuration](../configuration/autoentities.md)
- [What's new in version 2.0](../whats-new/version-2-0.md)
