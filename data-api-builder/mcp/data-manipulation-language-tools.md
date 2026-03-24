---
title: Data Manipulation Language Tools (DML)
description: Reference guide for the seven DML tools that SQL MCP Server exposes to AI agents.
author: jnixon
ms.author: jnixon
ms.topic: concept-article
ms.date: 03/24/2026
---

# Data manipulation language (DML) tools in SQL MCP Server

[!INCLUDE[Note - SQL MCP availability](includes/note-availability.md)]

SQL MCP Server exposes seven Data Manipulation Language (DML) tools to AI agents. These tools provide a typed CRUD surface for database operations—creating, reading, updating, and deleting records, aggregating data, plus executing stored procedures. All tools respect role-based access control (RBAC), entity permissions, and policies defined in your configuration.

## What are DML tools?

DML (Data Manipulation Language) tools handle data operations: creating, reading, updating, and deleting records, aggregating data, plus executing stored procedures. Unlike DDL (Data Definition Language) which modifies schema, DML works exclusively on the data plane in existing tables and views.

The seven DML tools are:

- `describe_entities` - Discovers available entities and operations
- `create_record` - Inserts new rows
- `read_records` - Queries tables and views
- `update_record` - Modifies existing rows
- `delete_record` - Removes rows
- `execute_entity` - Runs stored procedures
- `aggregate_records` - Performs aggregation queries

> [!TIP]
> For a complete list of DAB 2.0 features, see [What's new in version 2.0](../whats-new/version-2-0.md).

When DML tools are enabled globally and for an entity, SQL MCP Server exposes them through the MCP protocol. Agents never interact directly with your database schema - they work through the Data API builder abstraction layer.

## The tools

### list_tools response

When an agent calls `list_tools`, SQL MCP Server returns:

```json
{
  "tools": [
    { "name": "describe_entities" },
    { "name": "create_record" },
    { "name": "read_records" },
    { "name": "update_record" },
    { "name": "delete_record" },
    { "name": "execute_entity" },
    { "name": "aggregate_records" }
  ]
}
```

### describe_entities

Returns the entities available to the current role. Each entry includes field names, data types, primary keys, and allowed operations. This tool doesn't query the database. Instead, it reads from the in-memory configuration built from your config file.

> [!IMPORTANT]
> The `fields` information in `describe_entities` is derived from the `fields` data you provide in the configuration. Because field metadata is optional, if you don't include it, agents only see entity names with an empty `fields` array. It's a best practice to include both field names and field descriptions in your configuration. This metadata gives agents more context to generate accurate queries and updates. Learn more about [field descriptions here](./how-to-add-descriptions.md#2-add-field-descriptions).

```json
{
  "entities": [
    {
      "name": "Products",
      "description": "Product catalog with pricing and inventory",
      "fields": [
        {
          "name": "ProductId",
          "type": "int",
          "isKey": true,
          "description": "Unique product identifier"
        },
        {
          "name": "ProductName",
          "type": "string",
          "description": "Display name of the product"
        },
        {
          "name": "Price",
          "type": "decimal",
          "description": "Retail price in USD"
        }
      ],
      "operations": [
        "read_records",
        "update_record"
      ]
    }
  ]
}
```

> [!NOTE]
> The entity options used by any of the CRUD and execute DML tools come directly from `describe_entities`. The internal semantic description attached to each tool enforces this two-step flow.

### create_record

Creates a new row in a table. Requires create permission on the entity for the current role. The tool validates input against the entity schema, enforces field-level permissions, applies create policies, and returns the created record with any generated values.

### read_records

Queries a table or view. Supports filtering, sorting, pagination, and field selection. The tool builds deterministic SQL from structured parameters, applies read permissions and field projections, and enforces row-level security policies.

> [!IMPORTANT]
> Results from `read_records` are automatically cached using Data API builder's caching system. You can configure cache [time-to-live (TTL) globally](../configuration/runtime.md#cache-runtime) or [per-entity](../configuration/entities.md#cache) to reduce database load.

#### JOIN operations

The `read_records` tool is designed for a single table or view. As a result, JOIN operations aren't supported in this tool. This design helps isolate responsibility, improve performance, and limit the impact on your session’s context window.

However, JOIN operations aren't an edge case, and Data API builder (DAB) already supports sophisticated querying through the GraphQL endpoint. For more complex queries, we recommend using a view instead of a table. You can also use the `execute_entity` tool to run stored procedures to encapsulate parameterized queries.

### update_record

Modifies an existing row. Requires the primary key and fields to update. The tool validates the primary key exists, enforces update permissions and policies, and only updates fields the current role can modify.

### delete_record

Removes an existing row. Requires the primary key. The tool validates the primary key exists, enforces delete permissions and policies, and performs safe deletion with transaction support.

> [!NOTE]
> Some production scenarios disable this tool globally to broadly constrain models. This choice is up to you, and it's worth remembering that entity-level permissions remain the most important way to control access. Even with `delete-record` enabled, if a role doesn't have delete permission on an entity, that role can't use this tool for that entity.

### execute_entity

Runs a stored procedure. Supports input parameters and output results. The tool validates input parameters against the procedure signature, enforces execute permissions, and passes parameters safely.

### aggregate_records

Performs aggregation queries on tables and views. Supports common aggregate functions such as count, sum, average, minimum, and maximum. The tool builds deterministic SQL from structured parameters, applies read permissions and field projections, and enforces row-level security policies.

The `aggregate-records` tool can be configured as a boolean or as an object with additional settings:

```json
{
  "runtime": {
    "mcp": {
      "dml-tools": {
        "aggregate-records": {
          "enabled": true,
          "query-timeout": 30
        }
      }
    }
  }
}
```

The `query-timeout` property specifies the maximum execution time in seconds (range: 1–600). This setting helps prevent long-running aggregation queries from consuming excessive resources.

## Runtime configuration

Configure DML tools globally in the runtime section of your `dab-config.json`:

```json
{
  "runtime": {
    "mcp": {
      "enabled": true,
      "path": "/mcp",
      "dml-tools": {
        "describe-entities": true,
        "create-record": true,
        "read-records": true,
        "update-record": true,
        "delete-record": true,
        "execute-entity": true,
        "aggregate-records": true
      }
    }
  }
}
```

Each DML tool can also accept an object with an `enabled` property. The `aggregate-records` tool additionally supports a `query-timeout` property:

```json
{
  "runtime": {
    "mcp": {
      "enabled": true,
      "dml-tools": {
        "describe-entities": true,
        "create-record": true,
        "read-records": true,
        "update-record": true,
        "delete-record": true,
        "execute-entity": true,
        "aggregate-records": {
          "enabled": true,
          "query-timeout": 30
        }
      }
    }
  }
}
```

The `dml-tools` property also accepts a boolean shorthand. Setting `"dml-tools": true` enables all tools; `"dml-tools": false` disables all tools.

### Using the CLI

Set properties individually using the Data API builder CLI:

```bash
dab configure --runtime.mcp.enabled true
dab configure --runtime.mcp.path "/mcp"
dab configure --runtime.mcp.dml-tools.describe-entities.enabled true
dab configure --runtime.mcp.dml-tools.create-record.enabled true
dab configure --runtime.mcp.dml-tools.read-records.enabled true
dab configure --runtime.mcp.dml-tools.update-record.enabled true
dab configure --runtime.mcp.dml-tools.delete-record.enabled true
dab configure --runtime.mcp.dml-tools.execute-entity.enabled true
dab configure --runtime.mcp.dml-tools.aggregate-records.enabled true
```

### Disabling tools

When you disable a tool at the runtime level, it never appears to agents, regardless of entity permissions or role configuration. This setting is useful when you need strict operational boundaries.

#### Common scenarios

- Disable `delete-record` to prevent data loss in production
- Disable `create-record` for read-only reporting endpoints
- Disable `execute-entity` when stored procedures aren't used
- Disable `aggregate-records` when aggregation queries aren't needed

When a tool is disabled globally, the tool is hidden from the `list_tools` response and can't be invoked.

## Entity settings

Entities participate in MCP automatically unless you explicitly restrict them. The `mcp` property on an entity controls its MCP participation. You can use a boolean shorthand or an object format.

### Boolean shorthand

```json
{
  "entities": {
    "Products": {
      "mcp": true
    },
    "SensitiveData": {
      "mcp": false
    }
  }
}
```

Setting `"mcp": true` enables DML tools for the entity. Setting `"mcp": false` disables MCP entirely for the entity.

### Object format

```json
{
  "entities": {
    "Products": {
      "mcp": {
        "dml-tools": true
      }
    },
    "SensitiveData": {
      "mcp": {
        "dml-tools": false
      }
    }
  }
}
```

If you don't specify `mcp` on an entity, DML tools default to enabled when MCP is enabled globally.

### Custom tools for stored procedures

For stored-procedure entities, use the `custom-tool` property to register the procedure as a named MCP tool:

```json
{
  "entities": {
    "GetBookById": {
      "source": {
        "type": "stored-procedure",
        "object": "dbo.get_book_by_id"
      },
      "mcp": {
        "custom-tool": true
      }
    }
  }
}
```

> [!IMPORTANT]
> The `custom-tool` property is only valid for stored-procedure entities. Setting it on a table or view entity results in a configuration error.

### Scope of per-tool control

Per-tool toggles are configured only at the global runtime level under `runtime.mcp.dml-tools`.

At the entity level, `mcp` is a boolean gate or an object with `dml-tools` and `custom-tool` properties.

```json
{
  "entities": {
    "AuditLogs": {
      "mcp": {
        "dml-tools": false
      }
    }
  }
}
```

```json
{
  "runtime": {
    "mcp": {
      "dml-tools": {
        "describe-entities": true,
        "create-record": true,
        "read-records": true,
        "update-record": true,
        "delete-record": false,
        "execute-entity": true,
        "aggregate-records": true
      }
    }
  }
}
```

A tool is available only if enabled globally and the entity allows DML tools.

## RBAC integration

Every DML tool operation enforces your role-based access control rules. An agent's role determines which entities are visible, which operations are allowed, which fields are included, and whether row-level policies apply.

If the `anonymous` role only allows read permission on `Products`:

- `describe_entities` only shows `read_records` in operations
- `create_record`, `update_record`, and `delete_record` aren't available
- Only fields allowed for `anonymous` appear in the schema

### Configure roles in your `dab-config.json`:

```json
{
  "entities": {
    "Products": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "fields": {
                "include": ["ProductId", "ProductName", "Price"],
                "exclude": ["Cost"]
              }
            }
          ]
        },
        {
          "role": "admin",
          "actions": ["*"]
        }
      ]
    }
  }
}
```

## Related content

- [Overview of SQL MCP Server](overview.md)
- [Adding semantic descriptions to SQL MCP Server](how-to-add-descriptions.md)
- [Data API builder (DAB) configuration reference](/azure/data-api-builder/configuration)
- [Deploy SQL MCP Server to Azure Container Apps](quickstart-azure-container-apps.md)
