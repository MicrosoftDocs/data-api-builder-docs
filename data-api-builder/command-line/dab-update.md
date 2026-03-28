---
title: Update entities with the DAB CLI
description: Use the Data API builder (DAB) CLI to update existing entities in your API configuration.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 09/29/2025
# Customer Intent: As a developer, I want to update existing entities in my Data API builder configuration, so that I can adjust API behavior without recreating them.
---

# `update` command

Update an existing entity definition in the Data API builder configuration file. Use this command to adjust source metadata, permissions, exposure (REST/GraphQL), policies, caching, relationships, mappings, and descriptive metadata for an existing entity.

> [!TIP]
> Use `dab add` to create new entities, and `dab update` to evolve them. To manage field metadata, use `--fields.name` with `--fields.alias`, `--fields.description`, and `--fields.primary-key`.

## Syntax

```sh
dab update <entity-name> [options]
```

## Quick glance

| Option | Summary |
| - | - |
| `<entity-name>` | Required positional argument. Logical entity name. |
| [`-s, --source`](#-s---source) | Name of the source table, view, or stored procedure. |
| [`-m, --map`](#-m---map) | Mappings between database fields and exposed names. |
| [`--permissions`](#--permissions) | Role and actions in `role:actions` format. |
| [`--description`](#--description) | Replace entity description. |
| [`-c, --config`](#-c---config) | Path to config file. Default resolution applies if omitted. |
| [`--help`](#--help) | Display the help screen. |
| [`--version`](#--version) | Display version information. |

#### Cache

| Option | Summary |
| - | - |
| [`--cache.enabled`](#--cacheenabled) | Enable or disable entity caching. |
| [`--cache.ttl`](#--cachettl) | Cache time-to-live in seconds. |

#### Fields

| Option | Summary |
| - | - |
| [`--fields.exclude`](#--fieldsexclude) | Comma-separated list of excluded fields. |
| [`--fields.include`](#--fieldsinclude) | Comma-separated list of included fields (`*` = all). |

#### Fields metadata

| Option | Summary |
| - | - |
| [`--fields.name`](#--fieldsname) | Name of the database column to describe. |
| [`--fields.alias`](#--fieldsalias) | Alias for the field. |
| [`--fields.description`](#--fieldsdescription) | Description for the field. |
| [`--fields.primary-key`](#--fieldsprimary-key) | Set this field as a primary key. |

#### GraphQL

| Option | Summary |
| - | - |
| [`--graphql`](#--graphql) | GraphQL exposure: `false`, `true`, `singular`, or `singular:plural`. |
| [`--graphql.operation`](#--graphqloperation) | Stored procedures only: `query` or `mutation` (default mutation). |

#### Permissions & Policies

| Option | Summary |
| - | - |
| [`--permissions`](#--permissions) | `role:actions` for a single role. Run multiple times for multiple roles. |
| [`--policy-database`](#--policy-database) | OData-style filter injected in database query. |
| [`--policy-request`](#--policy-request) | Predatabase request filter. |

#### Relationships

| Option | Summary |
| - | - |
| [`--relationship`](#--relationship) | Relationship name. Use with relationship options. |
| [`--cardinality`](#--cardinality) | Relationship cardinality: `one` or `many`. |
| [`--target.entity`](#--targetentity) | Target entity name. |
| [`--linking.object`](#--linkingobject) | Linking object for many-to-many. |
| [`--linking.source.fields`](#--linkingsourcefields) | Linking object fields pointing to source. |
| [`--linking.target.fields`](#--linkingtargetfields) | Linking object fields pointing to target. |
| [`--relationship.fields`](#--relationshipfields) | Field mappings for direct relationships. |

#### REST

| Option | Summary |
| - | - |
| [`--rest`](#--rest) | REST exposure: `false`, `true`, or custom path. |
| [`--rest.methods`](#--restmethods) | Stored procedures only. Replace allowed HTTP verbs. |

#### Mappings

| Option | Summary |
| - | - |
| [`-m, --map`](#-m---map) | Mappings between database fields and exposed names. |

#### MCP

| Option | Summary |
| - | - |
| [`--mcp.dml-tools`](#--mcpdml-tools) | Enable or disable MCP DML tools for this entity. |
| [`--mcp.custom-tool`](#--mcpcustom-tool) | Enable MCP custom tool (stored procedures only). |

#### Source

| Option | Summary |
| - | - |
| [`-s, --source`](#-s---source) | Underlying database object name. |
| [`--source.type`](#--sourcetype) | Source type: `table`, `view`, or `stored-procedure`. |
| [`--source.params`](#--sourceparams) | Default parameter values for stored procedures. |
| [`--source.key-fields`](#--sourcekey-fields) | Primary key field(s) for views or tables. |

#### Parameters (stored procedures)

| Option | Summary |
| - | - |
| [`--parameters.name`](#--parametersname) | Comma-separated list of parameter names. |
| [`--parameters.description`](#--parametersdescription) | Comma-separated list of parameter descriptions. |
| [`--parameters.required`](#--parametersrequired) | Comma-separated list of required flags. |
| [`--parameters.default`](#--parametersdefault) | Comma-separated list of default values. |


## `--cache.enabled`

Enable or disable caching for this entity.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --cache.enabled true
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --cache.enabled true
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "cache": {}
    }
  }
}
```

> [!NOTE]
> When caching is enabled (the default), the CLI writes an empty `cache` object. The `"enabled"` property only appears explicitly when set to `false`.

## `--cache.ttl`

Set cache time-to-live in seconds. Only effective if caching is enabled.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --cache.ttl 600
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --cache.ttl 600
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "cache": {
        "ttl-seconds": 600
      }
    }
  }
}
```

> [!NOTE]
> Supplying TTL (time-to-live) when cache is disabled has no effect until caching is enabled.

## `--description`

Replace entity description.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --description "Updated description"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --description "Updated description"
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "description": "Updated description"
    }
  }
}
```

## `--fields.exclude`

Comma-separated list of fields to exclude.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --permissions "anonymous:read" \
  --fields.exclude "internal_flag,secret_note"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --permissions "anonymous:read" ^
  --fields.exclude "internal_flag,secret_note"
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
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

Comma-separated list of fields to include. `*` includes all fields. Replaces existing include list.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --permissions "anonymous:read" \
  --fields.include "id,title,author"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --permissions "anonymous:read" ^
  --fields.include "id,title,author"
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "fields": {
                "exclude": [],
                "include": [ "id", "title", "author" ]
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

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --graphql book:books
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --graphql book:books
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
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

Stored procedures only. Sets operation type. Default is `mutation`.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  RunReport \
  --graphql.operation query
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  RunReport ^
  --graphql.operation query
```
---
### Resulting config

```json
{
  "entities": {
    "RunReport": {
      "graphql": {
        "operation": "query"
      }
    }
  }
}
```

> [!NOTE]
> Supplying `--graphql.operation` for tables or views is ignored.

## `--permissions`

Adds or updates permissions for a single role and its actions.

You can run `dab update` multiple times (once per role) to add multiple roles.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --permissions "anonymous:read"

dab update \
  Book \
  --permissions "authenticated:create,read,update"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --permissions "anonymous:read"

dab update ^
  Book ^
  --permissions "authenticated:create,read,update"
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read"
            }
          ]
        },
        {
          "role": "authenticated",
          "actions": [
            { "action": "create" },
            { "action": "read" },
            { "action": "update" }
          ]
        }
      ]
    }
  }
}
```

> [!NOTE]
> If the specified role already exists, its actions are updated; otherwise, the role is added.

## `--policy-database`

OData-style filter appended to database query.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --permissions "anonymous:read" \
  --policy-database "region eq 'US'"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --permissions "anonymous:read" ^
  --policy-database "region eq 'US'"
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
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

Request-level policy evaluated before hitting the database.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --permissions "anonymous:read" \
  --policy-request "@claims.role == 'admin'"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --permissions "anonymous:read" ^
  --policy-request "@claims.role == 'admin'"
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
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

## `--relationship`

Define or update a relationship. Use with other relationship options.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  User \
  --relationship profile \
  --target.entity Profile \
  --cardinality one \
  --relationship.fields "id:user_id"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  User ^
  --relationship profile ^
  --target.entity Profile ^
  --cardinality one ^
  --relationship.fields "id:user_id"
```
---
### Resulting config

```json
{
  "entities": {
    "User": {
      "relationships": {
        "profile": {
          "cardinality": "one",
          "target.entity": "Profile",
          "source.fields": [ "id" ],
          "target.fields": [ "user_id" ],
          "linking.source.fields": [],
          "linking.target.fields": []
        }
      }
    }
  }
}
```

## `--cardinality`

Cardinality for the relationship. Use with `--relationship`.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  User \
  --relationship profile \
  --target.entity Profile \
  --cardinality one \
  --relationship.fields "id:user_id"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  User ^
  --relationship profile ^
  --target.entity Profile ^
  --cardinality one ^
  --relationship.fields "id:user_id"
```
---
## `--target.entity`

Target entity name for the relationship. Use with `--relationship`.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  User \
  --relationship profile \
  --target.entity Profile \
  --cardinality one \
  --relationship.fields "id:user_id"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  User ^
  --relationship profile ^
  --target.entity Profile ^
  --cardinality one ^
  --relationship.fields "id:user_id"
```
---
## `--linking.object`

Many-to-many only. Name of the database object to use as the linking object.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --relationship books_authors \
  --target.entity Author \
  --cardinality many \
  --relationship.fields "id:id" \
  --linking.object dbo.books_authors \
  --linking.source.fields book_id \
  --linking.target.fields author_id
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --relationship books_authors ^
  --target.entity Author ^
  --cardinality many ^
  --relationship.fields "id:id" ^
  --linking.object dbo.books_authors ^
  --linking.source.fields book_id ^
  --linking.target.fields author_id
```
---
## `--linking.source.fields`

Many-to-many only. Comma-separated list of linking object fields pointing to the source entity.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --relationship books_authors \
  --target.entity Author \
  --cardinality many \
  --relationship.fields "id:id" \
  --linking.object dbo.books_authors \
  --linking.source.fields book_id \
  --linking.target.fields author_id
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --relationship books_authors ^
  --target.entity Author ^
  --cardinality many ^
  --relationship.fields "id:id" ^
  --linking.object dbo.books_authors ^
  --linking.source.fields book_id ^
  --linking.target.fields author_id
```
---
## `--linking.target.fields`

Many-to-many only. Comma-separated list of linking object fields pointing to the target entity.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --relationship books_authors \
  --target.entity Author \
  --cardinality many \
  --relationship.fields "id:id" \
  --linking.object dbo.books_authors \
  --linking.source.fields book_id \
  --linking.target.fields author_id
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --relationship books_authors ^
  --target.entity Author ^
  --cardinality many ^
  --relationship.fields "id:id" ^
  --linking.object dbo.books_authors ^
  --linking.source.fields book_id ^
  --linking.target.fields author_id
```
---
## `--relationship.fields`

Colon-separated field mappings for direct relationships.

The `--relationship.fields` value is a comma-separated list of `sourceField:targetField` pairs.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  User \
  --relationship profile \
  --target.entity Profile \
  --cardinality one \
  --relationship.fields "id:user_id"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  User ^
  --relationship profile ^
  --target.entity Profile ^
  --cardinality one ^
  --relationship.fields "id:user_id"
```
---
### Resulting config

```json
{
  "entities": {
    "User": {
      "relationships": {
        "profile": {
          "cardinality": "one",
          "target.entity": "Profile",
          "source.fields": [ "id" ],
          "target.fields": [ "user_id" ],
          "linking.source.fields": [],
          "linking.target.fields": []
        }
      }
    }
  }
}
```

## `--rest`

Control REST exposure.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --rest BooksApi
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --rest BooksApi
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "rest": {
        "enabled": true,
        "path": "/BooksApi"
      }
    }
  }
}
```

## `--rest.methods`

Stored procedures only. Replace allowed HTTP methods. Defaults to POST.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  RunReport \
  --rest true \
  --rest.methods GET,POST
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  RunReport ^
  --rest true ^
  --rest.methods GET,POST
```
---
### Resulting config

```json
{
  "entities": {
    "RunReport": {
      "rest": {
        "enabled": true,
        "methods": [ "get", "post" ]
      }
    }
  }
}
```

> [!NOTE]
> Supplying `--rest.methods` while REST is disabled has no effect.

## `-s, --source`

Update the underlying database object.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --source dbo.Books
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --source dbo.Books
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": {
        "object": "dbo.Books",
        "type": "table"
      }
    }
  }
}
```

## `--source.type`

Change the source object type.

> [!NOTE]
> Views require `--source.key-fields`. Changing to `view` without specifying key-fields produces an error.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --source.type view \
  --source.key-fields "id"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --source.type view ^
  --source.key-fields "id"
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": {
        "type": "view",
        "object": "Book"
      },
      "fields": [
        {
          "name": "id",
          "primary-key": true
        }
      ]
    }
  }
}
```

## `--source.params`

Stored procedures only. Default parameter values as `name:value` pairs.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  RunReport \
  --source.params "startDate:2024-01-01,endDate:2024-12-31"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  RunReport ^
  --source.params "startDate:2024-01-01,endDate:2024-12-31"
```
---
### Resulting config

```json
{
  "entities": {
    "RunReport": {
      "source": {
        "type": "stored-procedure",
        "parameters": [
          {
            "name": "startDate",
            "required": false,
            "default": "2024-01-01"
          },
          {
            "name": "endDate",
            "required": false,
            "default": "2024-12-31"
          }
        ]
      }
    }
  }
}
```

## `--source.key-fields`

Specify primary key field(s) for views or tables without an inferred key.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --source.type view \
  --source.key-fields "id"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --source.type view ^
  --source.key-fields "id"
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": {
        "type": "view",
        "object": "Book"
      },
      "fields": [
        {
          "name": "id",
          "primary-key": true
        }
      ]
    }
  }
}
```

> [!NOTE]
> Views always require key-fields. The `--source.key-fields` option adds entries to the `fields` array with `"primary-key": true`.

## `-m, --map`

Specify mappings between database column names and exposed REST/GraphQL field names.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --map "id:bookId,title:bookTitle"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --map "id:bookId,title:bookTitle"
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "fields": [
        {
          "name": "id",
          "alias": "bookId",
          "primary-key": false
        },
        {
          "name": "title",
          "alias": "bookTitle",
          "primary-key": false
        }
      ]
    }
  }
}
```

> [!NOTE]
> The `--map` option creates entries in the `fields` array with the `alias` property set.

## `--parameters.name`

Stored procedures only. Comma-separated list of parameter names.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

> [!TIP]
> To define stored procedure parameters, use `--parameters.name` with `--parameters.description`, `--parameters.required`, and `--parameters.default`.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  GetOrdersByDateRange \
  --parameters.name "StartDate,EndDate" \
  --parameters.required "true,true" \
  --parameters.description "Beginning of date range,End of date range"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  GetOrdersByDateRange ^
  --parameters.name "StartDate,EndDate" ^
  --parameters.required "true,true" ^
  --parameters.description "Beginning of date range,End of date range"
```
---
### Resulting config

```json
{
  "entities": {
    "GetOrdersByDateRange": {
      "source": {
        "parameters": [
          {
            "name": "StartDate",
            "description": "Beginning of date range",
            "required": true
          },
          {
            "name": "EndDate",
            "description": "End of date range",
            "required": true
          }
        ]
      }
    }
  }
}
```

## `--parameters.description`

Stored procedures only. Comma-separated list of parameter descriptions aligned to `--parameters.name`.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  GetOrdersByDateRange \
  --parameters.name "StartDate,EndDate" \
  --parameters.description "Beginning of date range,End of date range"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  GetOrdersByDateRange ^
  --parameters.name "StartDate,EndDate" ^
  --parameters.description "Beginning of date range,End of date range"
```
---
## `--parameters.required`

Stored procedures only. Comma-separated list of `true`/`false` values aligned to `--parameters.name`.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  GetOrdersByDateRange \
  --parameters.name "StartDate,EndDate" \
  --parameters.required "true,true"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  GetOrdersByDateRange ^
  --parameters.name "StartDate,EndDate" ^
  --parameters.required "true,true"
```
---
## `--parameters.default`

Stored procedures only. Comma-separated list of default values aligned to `--parameters.name`.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  GetOrdersByDateRange \
  --parameters.name "CustomerID" \
  --parameters.default "null"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  GetOrdersByDateRange ^
  --parameters.name "CustomerID" ^
  --parameters.default "null"
```
---
## `--fields.name`

Name of the database column to describe.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Products \
  --fields.name Id \
  --fields.primary-key true \
  --fields.description "Product Id"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Products ^
  --fields.name Id ^
  --fields.primary-key true ^
  --fields.description "Product Id"
```
---
### Resulting config

```json
{
  "entities": {
    "Products": {
      "fields": [
        {
          "name": "Id",
          "description": "Product Id",
          "primary-key": true
        }
      ]
    }
  }
}
```

## `--fields.alias`

Alias for the field. Use a comma-separated list aligned to `--fields.name`.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

> [!TIP]
> Use `--fields.alias` with `--fields.name` to define exposed field names.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Products \
  --fields.name "Id,Title" \
  --fields.alias "product_id,product_title"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Products ^
  --fields.name "Id,Title" ^
  --fields.alias "product_id,product_title"
```
---
## `--fields.description`

Description for the field. Use a comma-separated list aligned to `--fields.name`.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Products \
  --fields.name Id \
  --fields.description "Product Id"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Products ^
  --fields.name Id ^
  --fields.description "Product Id"
```
---
## `--fields.primary-key`

Primary key flag for the field. Use a comma-separated list of `true`/`false` values aligned to `--fields.name`.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

> [!TIP]
> Use `--fields.primary-key` with `--fields.name` to define primary key fields for views or tables without an inferred key.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  SalesSummary \
  --fields.name "year,region" \
  --fields.primary-key "true,true"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  SalesSummary ^
  --fields.name "year,region" ^
  --fields.primary-key "true,true"
```
---
### Resulting config

```json
{
  "entities": {
    "SalesSummary": {
      "fields": [
        {
          "name": "year",
          "primary-key": true
        },
        {
          "name": "region",
          "primary-key": true
        }
      ]
    }
  }
}
```

## `--mcp.dml-tools`

Enable or disable MCP DML (data manipulation language) tools for this entity. Default is `true`.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --mcp.dml-tools false
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --mcp.dml-tools false
```
---
### Resulting config

```json
{
  "entities": {
    "Book": {
      "mcp": false
    }
  }
}
```

> [!NOTE]
> When `--mcp.dml-tools` is used alone, the CLI writes the `mcp` property as a boolean shorthand. When combined with `--mcp.custom-tool`, both properties appear in an object form.

## `--mcp.custom-tool`

Stored procedures only. Enable MCP custom tool for this entity. Default is `false`.

[!INCLUDE[Note - DAB 2.0 RC CLI](../includes/note-dab-2-preview-cli.md)]

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  RunReport \
  --mcp.custom-tool true
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  RunReport ^
  --mcp.custom-tool true
```
---
### Resulting config

```json
{
  "entities": {
    "RunReport": {
      "mcp": {
        "custom-tool": true
      }
    }
  }
}
```

## `-c, --config`

Path to the configuration file.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update \
  Book \
  --description "Updated description" \
  --config dab-config.json
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update ^
  Book ^
  --description "Updated description" ^
  --config dab-config.json
```
---
## `--help`

Display the help screen.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update --help
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update --help
```
---
## `--version`

Display version information.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab update --version
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab update --version
```
---
> [!Important]
> Changing source type may invalidate other properties. For example, views always require key-fields; stored procedures cannot define key-fields.
