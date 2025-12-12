---
title: Add entities with the DAB CLI
description: Use the Data API builder (DAB) CLI to add new entities to your API configuration.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 09/29/2025
# Customer Intent: As a developer, I want to add entities to my Data API builder configuration, so that I can expose database objects as APIs.
---

# `add` command

Add a new entity definition to an existing Data API builder configuration file. You must already have a config created with `dab init`. Use `dab update` to modify entities after creation.

> [!TIP]
> Use `dab add` to create new entities, and [`dab update`](./dab-update.md) to evolve them.

## Syntax

```bash
dab add <entity-name> [options]
```

### Quick glance

| Option                                       | Summary                                                              |
| -------------------------------------------- | -------------------------------------------------------------------- |
| `<entity-name>`                              | Required positional argument. Logical entity name.                   |
| [`-c, --config`](#-c---config)               | Config file path. Default `dab-config.json`.                         |
| [`--cache.enabled`](#--cacheenabled)         | Enable/disable caching for entity.                                   |
| [`--cache.ttl`](#--cachettl)                 | Cache time-to-live in seconds.                                       |
| [`--description`](#--description)            | Free-form description for entity.                                    |
| [`--fields.exclude`](#--fieldsexclude)       | Comma-separated excluded fields.                                     |
| [`--fields.include`](#--fieldsinclude)       | Comma-separated allowed fields (`*` = all).                          |
| [`--fields.name`](#--fieldsname)             | Field names to describe (repeatable or comma-separated).             |
| [`--fields.alias`](#--fieldsalias)           | Field aliases (comma-separated, aligned to `--fields.name`).         |
| [`--fields.description`](#--fieldsdescription) | Field descriptions (comma-separated, aligned to `--fields.name`).  |
| [`--fields.primary-key`](#--fieldsprimary-key) | Primary key flags (comma-separated, aligned to `--fields.name`).    |
| [`--graphql`](#--graphql)                    | GraphQL exposure: `false`, `true`, `singular`, or `singular:plural`. |
| [`--graphql.operation`](#--graphqloperation) | Stored procedures only. `Query` or `Mutation` (default mutation).    |
| [`--permissions`](#--permissions)            | Required. `role:actions` for a single role.                          |
| [`--policy-database`](#--policy-database)    | OData-style filter applied in DB query.                              |
| [`--policy-request`](#--policy-request)      | Request policy evaluated before DB call.                             |
| [`--parameters.name`](#--parametersname)     | Stored procedures only. Parameter names (comma-separated).           |
| [`--parameters.description`](#--parametersdescription) | Stored procedures only. Parameter descriptions.              |
| [`--parameters.required`](#--parametersrequired) | Stored procedures only. Parameter required flags.                 |
| [`--parameters.default`](#--parametersdefault) | Stored procedures only. Parameter default values.                  |
| [`--rest`](#--rest)                          | REST exposure: `false`, `true`, or custom route.                     |
| [`--rest.methods`](#--restmethods)           | Stored procedures only. Allowed verbs: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`. Default POST. |
| [`-s, --source`](#-s---source)               | Required. Database object name (table, view, or stored procedure).   |
| [`--source.key-fields`](#--sourcekey-fields) | The field(s) to be used as primary keys.                             |
| [`--source.params`](#--sourceparams)         | Stored procedures only. Default parameter values.                    |
| [`--source.type`](#--sourcetype)             | Source type: `table`, `view`, `stored-procedure` (default table).    |
| [`--help`](#--help)                          | Display this help screen.                                            |
| [`--version`](#--version)                    | Display version information.                                         |

---

## `<entity-name>`

Logical name of the entity in config. Case-sensitive.

### Quick examples for tables, views, and stored procedures

#### Add a table

```bash
dab add Book \
  --source dbo.Books \
  --source.type table \
  --permissions "anonymous:read" \
  --description "Example for managing book inventory"
```

#### Add a view

```bash
dab add BookView \
  --source dbo.MyView \
  --source.type view \
  --source.key-fields "id,region" \
  --permissions "anonymous:read" \
  --description "Example for managing book inventory from view"
```

#### Add a stored procedure

```bash
dab add BookProc \
  --source dbo.MyProc \
  --source.type stored-procedure \
  --source.params "year:2024,active:true" \
  --permissions "anonymous:execute" \
  --graphql.operation query \
  --description "Example for executing a stored procedure"
```

## `-c, --config`

Config file path. Default is `dab-config.json`.

### Example

```bash
dab add Book --config ./dab-config.mssql.json --source dbo.Books --permissions "anonymous:read"
```

---

## `--cache.enabled`

Enable or disable caching.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --cache.enabled true
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": {
        "type": "table",
        "object": "dbo.Books"
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ],
      "cache": {
        "enabled": true
      }
    }
  }
}
```

## `--cache.ttl`

Cache time-to-live in seconds.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --cache.ttl 300
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": {
        "type": "table",
        "object": "dbo.Books"
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ],
      "cache": {
        "enabled": false,
        "ttl-seconds": 300
      }
    }
  }
}
```

## `--description`

Free-text description of the entity.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --description "Entity for managing book inventory"
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": {
        "type": "table",
        "object": "dbo.Books"
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ],
      "description": "Entity for managing book inventory"
    }
  }
}
```

## `--fields.exclude`

Comma-separated list of fields to exclude.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --fields.exclude "internal_flag,secret_note"
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": { "type": "table", "object": "dbo.Books" },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "fields": {
                "exclude": [ "internal_flag", "secret_note" ]
              }
            }
          ]
        }
      ]
    }
  }
}
```

## `--fields.include`

Comma-separated list of fields to expose.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --fields.include "id,title,price"
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": { "type": "table", "object": "dbo.Books" },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "fields": {
                "include": [ "id", "title", "price" ]
              }
            }
          ]
        }
      ]
    }
  }
}
```

## `--graphql`

Control GraphQL exposure.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --graphql book:books
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": { "type": "table", "object": "dbo.Books" },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ],
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "book",
          "plural": "books"
        }
      }
    }
  }
}
```

## `--graphql.operation`

Stored procedures only. GraphQL operation type. Default is `mutation`.

### Example

```bash
dab add BookProc --source dbo.MyProc --source.type stored-procedure --permissions "admin:execute" --graphql.operation Query
```

### Resulting config

```json
{
  "entities": {
    "BookProc": {
      "source": { "type": "stored-procedure", "object": "dbo.MyProc" },
      "permissions": [
        { "role": "admin", "actions": [ { "action": "execute" } ] }
      ],
      "graphql": {
        "enabled": true,
        "operation": "query"
      }
    }
  }
}
```

## `--permissions`

Defines role→actions pairs.

`--permissions` isn't repeatable. To add more roles, run `dab add` with one role and then run `dab update` for additional roles.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read"

dab update Book --permissions "authenticated:create,read,update,delete"
```

## `--parameters.name`

Stored procedures only. Comma-separated list of parameter names.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```bash
dab add GetOrdersByDateRange \
  --source dbo.usp_GetOrdersByDateRange \
  --source.type stored-procedure \
  --permissions "authenticated:execute" \
  --description "Retrieves all orders placed within a specified date range" \
  --parameters.name "StartDate,EndDate,CustomerID" \
  --parameters.description "Beginning of date range (inclusive),End of date range (inclusive),Optional customer ID filter" \
  --parameters.required "true,true,false" \
  --parameters.default ",,null"
```

### Resulting config

```json
{
  "entities": {
    "GetOrdersByDateRange": {
      "description": "Retrieves all orders placed within a specified date range",
      "source": {
        "object": "dbo.usp_GetOrdersByDateRange",
        "type": "stored-procedure",
        "parameters": [
          {
            "name": "StartDate",
            "required": true,
            "description": "Beginning of date range (inclusive)"
          },
          {
            "name": "EndDate",
            "required": true,
            "description": "End of date range (inclusive)"
          },
          {
            "name": "CustomerID",
            "required": false,
            "default": "null",
            "description": "Optional customer ID filter"
          }
        ]
      },
      "permissions": [
        {
          "role": "authenticated",
          "actions": [
            {
              "action": "execute"
            }
          ]
        }
      ]
    }
  }
}
```

## `--parameters.description`

Stored procedures only. Comma-separated list of parameter descriptions aligned to `--parameters.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```bash
dab add GetOrdersByDateRange --source dbo.usp_GetOrdersByDateRange --source.type stored-procedure --permissions "authenticated:execute" --parameters.name "StartDate,EndDate" --parameters.description "Beginning of date range (inclusive),End of date range (inclusive)"
```

## `--parameters.required`

Stored procedures only. Comma-separated list of `true`/`false` values aligned to `--parameters.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```bash
dab add GetOrdersByDateRange --source dbo.usp_GetOrdersByDateRange --source.type stored-procedure --permissions "authenticated:execute" --parameters.name "StartDate,EndDate" --parameters.required "true,true"
```

## `--parameters.default`

Stored procedures only. Comma-separated list of default values aligned to `--parameters.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```bash
dab add GetOrdersByDateRange --source dbo.usp_GetOrdersByDateRange --source.type stored-procedure --permissions "authenticated:execute" --parameters.name "CustomerID" --parameters.default "null"
```

## `--fields.name`

Name of the database column to describe.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```bash
dab add Products \
  --source dbo.Products \
  --permissions "anonymous:*" \
  --fields.name "ProductID,ProductName" \
  --fields.alias "product_id,product_name" \
  --fields.description "Unique identifier for each product,Display name of the product" \
  --fields.primary-key "true,false"
```

### Resulting config

```json
{
  "entities": {
    "Products": {
      "source": { "type": "table", "object": "dbo.Products" },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "*" } ] }
      ],
      "fields": [
        {
          "name": "ProductID",
          "alias": "product_id",
          "description": "Unique identifier for each product",
          "primary-key": true
        },
        {
          "name": "ProductName",
          "alias": "product_name",
          "description": "Display name of the product",
          "primary-key": false
        }
      ]
    }
  }
}
```

## `--fields.alias`

Alias for the field. Use a comma-separated list aligned to `--fields.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```bash
dab add Products --source dbo.Products --permissions "anonymous:*" --fields.name "ProductID" --fields.alias "product_id"
```

## `--fields.description`

Description for the field. Use a comma-separated list aligned to `--fields.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```bash
dab add Products --source dbo.Products --permissions "anonymous:*" --fields.name "ProductID" --fields.description "Unique identifier"
```

## `--fields.primary-key`

Primary key flag for the field. Use a comma-separated list of `true`/`false` values aligned to `--fields.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```bash
dab add Products --source dbo.Products --permissions "anonymous:*" --fields.name "ProductID" --fields.primary-key "true"
```

### Resulting config

```json
{
  "entities": {
    "Products": {
      "source": { "type": "table", "object": "dbo.Products" },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "*" } ] }
      ],
      "fields": [
        {
          "name": "ProductID",
          "primary-key": true
        }
      ]
    }
  }
}
```

## `--policy-database`

Database-level policy.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --policy-database "region eq 'US'"
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": { "type": "table", "object": "dbo.Books" },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "policy": {
                "database": "region eq 'US'"
              }
            }
          ]
        }
      ]
    }
  }
}
```

## `--policy-request`

Request-level policy.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --policy-request "@claims.role == 'admin'"
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": { "type": "table", "object": "dbo.Books" },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "policy": {
                "request": "@claims.role == 'admin'"
              }
            }
          ]
        }
      ]
    }
  }
}
```

## `--rest`

Control REST exposure.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read" --rest BooksApi
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": { "type": "table", "object": "dbo.Books" },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ],
      "rest": {
        "enabled": true,
        "path": "/BooksApi"
      }
    }
  }
}
```

## `--rest.methods`

Stored procedures only. HTTP verbs allowed for execution: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`. Defaults to POST. Ignored for tables/views.

### Example

```bash
dab add BookProc --source dbo.MyProc --source.type stored-procedure --permissions "admin:execute" --rest true --rest.methods GET,POST
```

### Resulting config

```json
{
  "entities": {
    "BookProc": {
      "source": { "type": "stored-procedure", "object": "dbo.MyProc" },
      "permissions": [
        { "role": "admin", "actions": [ { "action": "execute" } ] }
      ],
      "rest": {
        "enabled": true,
        "methods": [ "get", "post" ]
      }
    }
  }
}
```

## `-s, --source`

Required. Name of the database object: table, view, container, or stored procedure.

### Example

```bash
dab add Book --source dbo.Books --permissions "anonymous:read"
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": {
        "type": "table",
        "object": "dbo.Books"
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ]
    }
  }
}
```

## `--source.key-fields`

The field(s) to be used as primary keys. Required for views when generated through the CLI.

### Example

```bash
dab add BookView --source dbo.MyView --source.type view --source.key-fields "id,region" --permissions "anonymous:read"
```

### Resulting config

```json
{
  "entities": {
    "BookView": {
      "source": {
        "type": "view",
        "object": "dbo.MyView",
        "key-fields": [ "id", "region" ]
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ]
    }
  }
}
```

## `--source.params`

Stored procedures only. Comma-separated `name:value` pairs. Not allowed for tables or views.

> [!NOTE]
> In the v1.7 prerelease CLI (currently RC), `--source.params` is deprecated. Use `--parameters.name`, `--parameters.default`, and related `--parameters.*` options instead.

### Example

```bash
dab add BookProc --source dbo.MyProc --source.type stored-procedure --source.params "year:2024,active:true" --permissions "admin:execute"
```

### Resulting config

```json
{
  "entities": {
    "BookProc": {
      "source": {
        "type": "stored-procedure",
        "object": "dbo.MyProc",
        "parameters": [
          {
            "name": "year",
            "required": false,
            "default": "2024"
          },
          {
            "name": "active",
            "required": false,
            "default": "True"
          }
        ]
      },
      "permissions": [
        { "role": "admin", "actions": [ { "action": "execute" } ] }
      ]
    }
  }
}
```

## `--help`

Display this help screen.

### Example

```bash
dab add --help
```

## `--version`

Display version information.

### Example

```bash
dab add --version
```

## `--source.type`

Type of database object. Default: `table`.

### Example

```bash
dab add Book --source dbo.Books --source.type table --permissions "anonymous:read"
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": {
        "type": "table",
        "object": "dbo.Books"
      },
      "permissions": [
        { "role": "anonymous", "actions": [ { "action": "read" } ] }
      ]
    }
  }
}
```
