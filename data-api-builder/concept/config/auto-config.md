---
title: Auto configuration in Data API builder
description: Learn how autoentities in Data API builder (DAB) use pattern-based rules to automatically expose matching database objects as API entities at startup.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: conceptual
ms.date: 03/24/2026
# Customer Intent: As a developer, I want to understand how autoentities patterns and templates work so I can wire up an entire schema without writing individual entity blocks.
---

# Auto configuration concepts

Auto configuration lets you define patterns that automatically find and expose database objects in your configuration. Auto configuration can dramatically shrink a configuration file, especially when objects and permissions are predictable. In addition, `autoentities` reevaluate and apply the patterns each time DAB starts, so new tables that match the pattern are automatically added as entities without manual config changes.

When `autoentities` is present in the configuration, the `entities` section is no longer required. The schema requires either `autoentities` or `entities` (or both).

> [!TIP]
> Use the [`dab auto-config`](../../command-line/dab-auto-config.md) command to create `autoentities` definitions from the CLI, and [`dab auto-config-simulate`](../../command-line/dab-auto-config-simulate.md) to preview matched objects before committing changes. For the JSON configuration reference, see [`Autoentities` configuration](../../configuration/autoentities.md).

## Definitions

Each `autoentities` definition is a named configuration block that combines a set of patterns with a template and permissions. The definition name is case-sensitive and acts as a logical identifier. You can have multiple definitions, each targeting different sets of database objects and permissions.

```json
{
  "autoentities": {
    "my-def-name": {
      "patterns": { 
        "include": [ "dbo.table1", "dbo.table2" ], 
        "exclude": [ ], 
        "name": "{schema}{object}" 
      },
      "template": { 
        "rest": { "enabled": true },
        "graphql": { "enabled": true },
        "mcp": { "dml-tools": true },
        "health": { "enabled": false },
        "cache": { "enabled": false }
       },
      "permissions": [ 
        { 
          "role": "anonymous", 
          "actions": [ "*" ] }
       ]
    }
  }
}
```

> [!NOTE]
> `Autoentities` currently support **MSSQL** data sources only.

## Patterns

Patterns control which database objects are discovered and how they're named as entities. DAB evaluates patterns using [T-SQL `LIKE` syntax](/sql/t-sql/language-elements/like-transact-sql) against the `schema.object` format of each database object.

### Include and exclude

The `include` array specifies which objects to match. Use `%` as a wildcard. For example, `dbo.%` matches all objects in the `dbo` schema. The default is `%.%` (all objects in all schemas).

Since `include` is a string array, you can combine multiple patterns to target different schemas, prefixes, or even list specific tables by name. When listing individual tables, always include the schema name (for example, `dbo.Products` not just `Products`).

#### Include examples

| Pattern | Matches | Description |
| --- | --- | --- |
| `%.%` | All objects in all schemas | Default. Matches everything. |
| `dbo.%` | All objects in `dbo` schema | Single-schema wildcard. |
| `dbo.Product%` | `dbo.Products`, `dbo.ProductDetails`, etc. | Object name prefix in one schema. |
| `%.Product%` | `dbo.Products`, `sales.ProductOrders`, etc. | Object name prefix across all schemas. |
| `dbo.Products` | `dbo.Products` only | Exact match, no wildcard. |
| `dbo.%` `sales.%` | All objects in `dbo` and `sales` | Multiple wildcard patterns combined. |
| `dbo.Products` `dbo.Orders` `dbo.Customers` | Those three tables only | Explicit table list. Schema name required. |
| `dbo.%` `sales.Invoices` | All `dbo` objects plus `sales.Invoices` | Mix of wildcard and explicit table. |

The `exclude` array removes objects from the matched set. Exclude patterns are evaluated after include patterns. The exclude pattern is useful for keeping internal or staging tables out of your API. Like `include`, `exclude` is a string array and supports multiple patterns.

#### Exclude examples

| Pattern | Excludes | Description |
| --- | --- | --- |
| `dbo.internal%` | `dbo.internalLogs`, `dbo.internalAudit`, etc. | Remove objects with a name prefix. |
| `%.%_staging` | `dbo.Orders_staging`, `sales.Items_staging`, etc. | Remove staging tables across all schemas. |
| `dbo.__migration%` | `dbo.__migrationHistory`, etc. | Remove migration-tracking tables. |
| `dbo.sysdiagrams` | `dbo.sysdiagrams` only | Remove a single specific object. |
| `%.vw_%` | `dbo.vw_Summary`, `reports.vw_Daily`, etc. | Remove views by naming convention. |
| `dbo.Logs` `dbo.AuditTrail` | Those two tables only | Exclude specific tables by name. |

#### Command line

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --patterns.exclude "dbo.internal%"
```

Multiple patterns are space-separated on the CLI:

```bash
dab auto-config my-def \
  --patterns.include "dbo.Products" "dbo.Orders" "dbo.Customers" \
  --permissions "anonymous:read"
```

##### Resulting configuration

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

In this example, all objects in the `dbo` schema are included except objects whose names start with `internal`.

### Entity naming

The `name` property is an interpolation pattern that controls how matched database objects are named as entities. It supports `{schema}` and `{object}` placeholders. You can also include literal strings alongside placeholders. The default is `{object}`, which uses the database object name directly.

#### Examples

The following examples assume a database object `dbo.Products`:

| Pattern | Resulting entity name | Description |
| --- | --- | --- |
| `{object}` | `Products` | Default. Object name only. |
| `{schema}_{object}` | `dbo_Products` | Schema and object separated by underscore. |
| `{schema}-{object}` | `dbo-Products` | Schema and object separated by hyphen. |
| `{schema}.{object}` | `dbo.Products` | Schema and object separated by dot. |
| `api_{object}` | `api_Products` | Literal prefix with object name. |
| `{object}_entity` | `Products_entity` | Object name with literal suffix. |
| `tbl_{schema}_{object}` | `tbl_dbo_Products` | Literal prefix with both placeholders. |
| `{schema}_{object}_v1` | `dbo_Products_v1` | Both placeholders with literal version suffix. |
| `{object}Resource` | `ProductsResource` | Object name with literal suffix, no separator. |

Using `{schema}` in the pattern is especially useful when you include multiple schemas and need to avoid naming conflicts.

#### Command line

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --patterns.name "{schema}_{object}"
```

##### Resulting configuration

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

## Template

The template defines the default configuration applied to every entity matched by the definition. Template settings cover which API protocols are enabled and how caching behaves. Any setting you omit uses its default value.

### API protocols

You can enable or disable REST, GraphQL, and Model Context Protocol (MCP) independently for matched entities.

#### Command line
  

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.rest.enabled true \
  --template.graphql.enabled true \
  --template.mcp.dml-tools true
```

##### Resulting configuration

```json
{
  "autoentities": {
    "my-def": {
      "template": {
        "rest": { "enabled": true },
        "graphql": { "enabled": true },
        "mcp": { "dml-tools": true }
      }
    }
  }
}
```

| Property | Default | Description |
| --- | --- | --- |
| `rest.enabled` | `true` | Expose REST endpoints for matched entities. |
| `graphql.enabled` | `true` | Expose GraphQL operations for matched entities. |
| `mcp.dml-tools` | `true` | Expose MCP data manipulation language (DML) tools for matched entities. |

### Health checks

When enabled, DAB includes matched entities in its health check endpoint, verifying database connectivity for each entity.

#### Command line

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.health.enabled true
```

##### Resulting configuration

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

### Caching

Response caching can be enabled for all matched entities with a configurable time-to-live (TTL) and cache level.

#### Command line

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --template.cache.enabled true \
  --template.cache.ttl-seconds 30 \
  --template.cache.level L1L2
```

##### Resulting configuration

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

| Property | Default | Description |
| --- | --- | --- |
| `cache.enabled` | `false` | Enable response caching for matched entities. |
| `cache.ttl-seconds` | `null` | Cache time-to-live in seconds. |
| `cache.level` | `L1L2` | Cache level. Supported values: `L1`, `L1L2`. |

## Permissions

Permissions define role-based access control applied to every entity matched by the definition. Each permission entry specifies a role and the actions allowed for that role.

#### Command line

```bash
dab auto-config my-def \
  --patterns.include "dbo.%" \
  --permissions "anonymous:read"
```

##### Resulting configuration

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

Supported actions include `create`, `read`, `update`, `delete`, and `*` (all). You can assign multiple roles with different action sets.

## Full configuration example
A complete `autoentities` definition combining patterns, template, and permissions.

### Command line

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

#### Resulting configuration

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

This definition includes all objects in the `dbo` schema except objects starting with `internal`, names them using the `schema_object` format, enables REST and GraphQL, caches responses for 30 seconds, and grants anonymous read access.

## Simulation

Before committing `autoentities` patterns to your configuration, you can simulate the results to preview which database objects would be matched. The simulation connects to the database, resolves each pattern, and reports the matched objects without writing any changes. Simulation output shows each definition's matches with entity names and their corresponding database objects.

> [!TIP]
> Use [`dab auto-config-simulate`](../../command-line/dab-auto-config-simulate.md) to run simulations from the CLI. See the [command reference](../../command-line/dab-auto-config-simulate.md) for all options.


### Command line (console)

```bash
dab auto-config-simulate \
  --config ./dab-config.json
```

#### Resulting console output

```text
AutoEntities Simulation Results

Filter: my-def
Matches: 3
  dbo_Products  →  dbo.Products
  dbo_Inventory →  dbo.Inventory
  dbo_Pricing   →  dbo.Pricing
```

You can also export simulation results to CSV for further analysis.

### Command line (file)

```bash
dab auto-config-simulate \
  --config ./dab-config.json \
  --output results.csv
```

#### Resulting CSV output

```csv
filter_name,entity_name,database_object
my-def,dbo_Products,dbo.Products
my-def,dbo_Inventory,dbo.Inventory
my-def,dbo_Pricing,dbo.Pricing
```

## Related content

- [`dab auto-config` command reference](../../command-line/dab-auto-config.md)
- [`dab auto-config-simulate` command reference](../../command-line/dab-auto-config-simulate.md)
- [`Autoentities` configuration reference](../../configuration/autoentities.md)
- [Entities configuration](../../configuration/entities.md)
- [What's new in version 2.0](../../whats-new/version-2-0.md)
