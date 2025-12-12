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

Update an existing entity definition in the Data API builder configuration file. Use this command to adjust source metadata, permissions, exposure (REST/GraphQL), policies, caching, relationships, mappings, and descriptive metadata after the entity has already been added.

> [!TIP]
> Use `dab add` to create new entities, and `dab update` to evolve them. Field name remapping (`--map`) is only available in `update`, not in `add`.

## Syntax

```sh
dab update <entity-name> [options]
```

### Quick glance

| Option                            | Summary                                                     |
| --------------------------------- | ----------------------------------------------------------- |
| `<entity-name>`                   | Required positional argument. Logical entity name.          |
| [`-s, --source`](#-s---source)    | Name of the source table, view, or stored procedure.        |
| [`--permissions`](#--permissions) | Role and actions in `role:actions` format.                  |
| [`--description`](#--description) | Replace entity description.                                 |
| [`-c, --config`](#-c---config)    | Path to config file. Default resolution applies if omitted. |
| [`--help`](#--help)               | Display the help screen.                                    |
| [`--version`](#--version)         | Display version information.                                |

#### Cache

| Option                               | Summary                           |
| ------------------------------------ | --------------------------------- |
| [`--cache.enabled`](#--cacheenabled) | Enable or disable entity caching. |
| [`--cache.ttl`](#--cachettl)         | Cache time-to-live in seconds.    |

#### Fields

| Option                                 | Summary                                                |
| -------------------------------------- | ------------------------------------------------------ |
| [`--fields.exclude`](#--fieldsexclude) | Comma-separated list of excluded fields.               |
| [`--fields.include`](#--fieldsinclude) | Comma-separated list of included fields (`*` = all).   |
| [`-m, --map`](#-m---map)               | Field mapping pairs `name:alias`. Replaces entire set. |

#### GraphQL

| Option                                       | Summary                                                              |
| -------------------------------------------- | -------------------------------------------------------------------- |
| [`--graphql`](#--graphql)                    | GraphQL exposure: `false`, `true`, `singular`, or `singular:plural`. |
| [`--graphql.operation`](#--graphqloperation) | Stored procedures only: `query` or `mutation` (default mutation).    |

#### Permissions & Policies

| Option                                    | Summary                                                   |
| ----------------------------------------- | --------------------------------------------------------- |
| [`--permissions`](#--permissions)         | `role:actions` for a single role. Run multiple times for multiple roles. |
| [`--policy-database`](#--policy-database) | OData-style filter injected in DB query.                  |
| [`--policy-request`](#--policy-request)   | Pre-database request filter.                              |

#### Relationships

| Option                                           | Summary                                           |
| ------------------------------------------------ | ------------------------------------------------- |
| [`--relationship`](#--relationship)              | Relationship name. Use with relationship options. |
| [`--cardinality`](#--cardinality)                | Relationship cardinality: `one` or `many`.        |
| [`--target.entity`](#--targetentity)             | Target entity name.                               |
| [`--linking.object`](#--linkingobject)           | Linking object for many-to-many.                  |
| [`--linking.source.fields`](#--linkingsourcefields) | Linking object fields pointing to source.      |
| [`--linking.target.fields`](#--linkingtargetfields) | Linking object fields pointing to target.      |
| [`--relationship.fields`](#--relationshipfields) | Field mappings for direct relationships.          |

#### REST

| Option                             | Summary                                             |
| ---------------------------------- | --------------------------------------------------- |
| [`--rest`](#--rest)                | REST exposure: `false`, `true`, or custom path.     |
| [`--rest.methods`](#--restmethods) | Stored procedures only. Replace allowed HTTP verbs. |

#### Source

| Option                                       | Summary                                              |
| -------------------------------------------- | ---------------------------------------------------- |
| [`-s, --source`](#-s---source)               | Underlying database object name.                     |
| [`--source.key-fields`](#--sourcekey-fields) | Required for views or non-PK tables.                 |
| [`--source.params`](#--sourceparams)         | Stored procedures only. Replace default params.      |
| [`--source.type`](#--sourcetype)             | Source type: `table`, `view`, or `stored-procedure`. |


## `--cache.enabled`

Enable or disable caching for this entity.

### Example

```sh
dab update Book --cache.enabled true
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "cache": {
        "enabled": true
      }
    }
  }
}
```

## `--cache.ttl`

Set cache time-to-live in seconds. Only effective if caching is enabled.

### Example

```sh
dab update Book --cache.ttl 600
```

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
> Supplying TTL when cache is disabled has no effect until caching is enabled.

## `--description`

Replace entity description.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```sh
dab update Book --description "Updated description"
```

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

```sh
dab update Book --permissions "anonymous:read" --fields.exclude "internal_flag,secret_note"
```

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

```sh
dab update Book --permissions "anonymous:read" --fields.include "id,title,author"
```

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

```sh
dab update Book --graphql book:books
```

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

```sh
dab update RunReport --graphql.operation query
```

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

## `-m, --map`

Map database fields to exposed names. Replaces the entire mapping set.

### Example

```sh
dab update Book --map "id:bookId,title:bookTitle"
```

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

> [!IMPORTANT]
> Any existing mappings are overwritten. Restate all mappings you want to keep.

## `--permissions`

Adds or updates permissions for a single role and its actions.

You can run `dab update` multiple times (once per role) to add multiple roles.

### Example

```sh
dab update Book --permissions "anonymous:read"
dab update Book --permissions "authenticated:create,read,update"
```

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

OData-style filter appended to DB query.

### Example

```sh
dab update Book --permissions "anonymous:read" --policy-database "region eq 'US'"
```

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

```sh
dab update Book --permissions "anonymous:read" --policy-request "@claims.role == 'admin'"
```

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

```sh
dab update User --relationship profile --target.entity Profile --cardinality one --relationship.fields "id:user_id"
```

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
          "target.fields": [ "user_id" ]
        }
      }
    }
  }
}
```

## `--cardinality`

Cardinality for the relationship. Use with `--relationship`.

### Example

```sh
dab update User --relationship profile --target.entity Profile --cardinality one --relationship.fields "id:user_id"
```

## `--target.entity`

Target entity name for the relationship. Use with `--relationship`.

### Example

```sh
dab update User --relationship profile --target.entity Profile --cardinality one --relationship.fields "id:user_id"
```

## `--linking.object`

Many-to-many only. Database object name used as the linking object.

### Example

```sh
dab update Book --relationship books_authors --target.entity Author --cardinality many --relationship.fields "id:id" --linking.object dbo.books_authors --linking.source.fields book_id --linking.target.fields author_id
```

## `--linking.source.fields`

Many-to-many only. Comma-separated list of linking object fields pointing to the source entity.

### Example

```sh
dab update Book --relationship books_authors --target.entity Author --cardinality many --relationship.fields "id:id" --linking.object dbo.books_authors --linking.source.fields book_id --linking.target.fields author_id
```

## `--linking.target.fields`

Many-to-many only. Comma-separated list of linking object fields pointing to the target entity.

### Example

```sh
dab update Book --relationship books_authors --target.entity Author --cardinality many --relationship.fields "id:id" --linking.object dbo.books_authors --linking.source.fields book_id --linking.target.fields author_id
```

## `--relationship.fields`

Colon-separated field mappings for direct relationships.

The `--relationship.fields` value is a comma-separated list of `sourceField:targetField` pairs.

### Example

```sh
dab update User --relationship profile --target.entity Profile --cardinality one --relationship.fields "id:user_id"
```

### Resulting config

```json
{
  "entities": {
    "User": {
      "relationships": {
        "profile": {
          "source.fields": [ "id" ],
          "target.fields": [ "user_id" ]
        }
      }
    }
  }
}
```

## `--rest`

Control REST exposure.

### Example

```sh
dab update Book --rest BooksApi
```

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

```sh
dab update RunReport --rest true --rest.methods GET,POST
```

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

```sh
dab update Book --source dbo.Books
```

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

## `--source.key-fields`

For views or tables without an inferred PK. Replaces existing keys. Not valid for stored procedures.

### Example

```sh
dab update SalesSummary --source.type view --source.key-fields "year,region"
```

### Resulting config

```json
{
  "entities": {
    "SalesSummary": {
      "fields": [
        { "name": "year", "primary-key": true },
        { "name": "region", "primary-key": true }
      ]
    }
  }
}
```

> [!NOTE]
> Using `--source.key-fields` with stored procedures is not allowed.

## `--source.params`

Stored procedures only. Replace parameter defaults.

> [!NOTE]
> In the v1.7 prerelease CLI, `--source.params` is deprecated. Use `--parameters.name`/`--parameters.description`/`--parameters.required`/`--parameters.default`.

### Example

```sh
dab update RunReport --source.type stored-procedure --source.params "year:2024,region:west"
```

### Resulting config

```json
{
  "entities": {
    "RunReport": {
      "source": {
        "parameters": [
          { "name": "year", "required": false, "default": "2024" },
          { "name": "region", "required": false, "default": "west" }
        ]
      }
    }
  }
}
```

> [!NOTE]
> Using `--source.params` with tables or views is not allowed.

## `--source.type`

Change the source object type.

### Example

```sh
dab update Book --source.type view
```

### Resulting config

```json
{
  "entities": {
    "Book": {
      "source": {
        "type": "view",
        "object": "Book"
      }
    }
  }
}
```

## `--parameters.name`

Stored procedures only. Comma-separated list of parameter names.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```sh
dab update GetOrdersByDateRange --parameters.name "StartDate,EndDate" --parameters.required "true,true" --parameters.description "Beginning of date range,End of date range"
```

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

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```sh
dab update GetOrdersByDateRange --parameters.name "StartDate,EndDate" --parameters.description "Beginning of date range,End of date range"
```

## `--parameters.required`

Stored procedures only. Comma-separated list of `true`/`false` values aligned to `--parameters.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```sh
dab update GetOrdersByDateRange --parameters.name "StartDate,EndDate" --parameters.required "true,true"
```

## `--parameters.default`

Stored procedures only. Comma-separated list of default values aligned to `--parameters.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```sh
dab update GetOrdersByDateRange --parameters.name "CustomerID" --parameters.default "null"
```

## `--fields.name`

Name of the database column to describe.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```sh
dab update Products --fields.name Id --fields.primary-key true --fields.description "Product Id"
```

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

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```sh
dab update Products --fields.name Id --fields.alias product_id
```

## `--fields.description`

Description for the field. Use a comma-separated list aligned to `--fields.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```sh
dab update Products --fields.name Id --fields.description "Product Id"
```

## `--fields.primary-key`

Primary key flag for the field. Use a comma-separated list of `true`/`false` values aligned to `--fields.name`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

```sh
dab update Products --fields.name Id --fields.primary-key true
```

## `-c, --config`

Path to the configuration file.

### Example

```sh
dab update Book --description "Updated description" --config dab-config.json
```

## `--help`

Display the help screen.

### Example

```sh
dab update --help
```

## `--version`

Display version information.

### Example

```sh
dab update --version
```

> [!Important]
> Changing source type may invalidate other properties. For example, views always require key-fields; stored procedures cannot define key-fields.
