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
| `-c, --config`    | Path to config file. Default resolution applies if omitted. |
| [`--description`](#--description) | Replace entity description.                                 |

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
| [`--permissions`](#--permissions)         | One or more `role:actions` pairs. Replaces existing list. |
| [`--policy-database`](#--policy-database) | OData-style filter injected in DB query.                  |
| [`--policy-request`](#--policy-request)   | Pre-database request filter.                              |

#### Relationships

| Option                                           | Summary                                           |
| ------------------------------------------------ | ------------------------------------------------- |
| [`--relationship`](#--relationship)              | Relationship name. Use with relationship options. |
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

**Example**

```sh
dab update Book --cache.enabled true
```

**Resulting config**

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

**Example**

```sh
dab update Book --cache.ttl 600
```

**Resulting config**

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

> [!Note]
> Supplying TTL when cache is disabled has no effect until caching is enabled.

## `--description`

Replace entity description.

**Example**

```sh
dab update Book --description "Updated description"
```

**Resulting config**

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

**Example**

```sh
dab update Book --fields.exclude "internal_flag,secret_note"
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "graphql": {
        "fields": {
          "exclude": [ "internal_flag", "secret_note" ]
        }
      }
    }
  }
}
```

## `--fields.include`

Comma-separated list of fields to include. `*` includes all fields. Replaces existing include list.

**Example**

```sh
dab update Book --fields.include "id,title,author"
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "graphql": {
        "fields": {
          "include": [ "id", "title", "author" ]
        }
      }
    }
  }
}
```

## `--graphql`

Control GraphQL exposure.

**Example**

```sh
dab update Book --graphql book:books
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "graphql": {
        "singular": "book",
        "plural": "books"
      }
    }
  }
}
```

## `--graphql.operation`

Stored procedures only. Sets operation type. Default is `mutation`.

**Example**

```sh
dab update RunReport --graphql.operation query
```

**Resulting config**

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

> [!Note]
> Supplying `--graphql.operation` for tables or views is ignored.

## `-m, --map`

Map database fields to exposed names. Replaces the entire mapping set.

**Example**

```sh
dab update Book --map "id:bookId,title:bookTitle"
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "mappings": {
        "id": "bookId",
        "title": "bookTitle"
      }
    }
  }
}
```

> [!Important]
> Any existing mappings are overwritten. Restate all mappings you want to keep.

## `--permissions`

Replace all permissions with new role/action sets. Repeat flag for multiple roles.

**Example**

```sh
dab update Book --permissions "anonymous:read" --permissions "authenticated:create,read,update"
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [ "read" ]
        },
        {
          "role": "authenticated",
          "actions": [ "create", "read", "update" ]
        }
      ]
    }
  }
}
```

> [!Important]
> Permissions replace the existing list. Previous permissions are discarded.

## `--policy-database`

OData-style filter appended to DB query.

**Example**

```sh
dab update Book --policy-database "region eq 'US'"
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "policies": {
        "database": "region eq 'US'"
      }
    }
  }
}
```

## `--policy-request`

Request-level policy evaluated before hitting the database.

**Example**

```sh
dab update Book --policy-request "@claims.role == 'admin'"
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "policies": {
        "request": "@claims.role == 'admin'"
      }
    }
  }
}
```

## `--relationship`

Define or update a relationship. Use with other relationship options.

**Example**

```sh
dab update Book --relationship publisher --cardinality one --target.entity Publisher --relationship.fields "publisher_id:id"
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "relationships": {
        "publisher": {
          "cardinality": "one",
          "target.entity": "Publisher",
          "fields": {
            "publisher_id": "id"
          }
        }
      }
    }
  }
}
```

## `--relationship.fields`

Colon-separated field mappings for direct relationships.

**Example**

```sh
dab update Book --relationship author --cardinality one --target.entity Author --relationship.fields "author_id:id"
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "relationships": {
        "author": {
          "cardinality": "one",
          "target.entity": "Author",
          "fields": {
            "author_id": "id"
          }
        }
      }
    }
  }
}
```

## `--rest`

Control REST exposure.

**Example**

```sh
dab update Book --rest BooksApi
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "rest": {
        "path": "BooksApi"
      }
    }
  }
}
```

## `--rest.methods`

Stored procedures only. Replace allowed HTTP methods. Defaults to POST.

**Example**

```sh
dab update RunReport --rest true --rest.methods GET,POST
```

**Resulting config**

```json
{
  "entities": {
    "RunReport": {
      "rest": {
        "path": "RunReport",
        "methods": [ "GET", "POST" ]
      }
    }
  }
}
```

> [!Note]
> Supplying `--rest.methods` while REST is disabled has no effect.

## `-s, --source`

Update the underlying database object.

**Example**

```sh
dab update Book --source dbo.Books
```

**Resulting config**

```json
{
  "entities": {
    "Book": {
      "source": {
        "type": "table",
        "object": "dbo.Books"
      }
    }
  }
}
```

## `--source.key-fields`

For views or tables without an inferred PK. Replaces existing keys. Not valid for stored procedures.

**Example**

```sh
dab update SalesSummary --source.type view --source.key-fields "year,region"
```

**Resulting config**

```json
{
  "entities": {
    "SalesSummary": {
      "source": {
        "type": "view",
        "object": "SalesSummary",
        "keyFields": [ "year", "region" ]
      }
    }
  }
}
```

> [!Note]
> Using `--source.key-fields` with stored procedures is not allowed.

## `--source.params`

Stored procedures only. Replace parameter defaults.

**Example**

```sh
dab update RunReport --source.type stored-procedure --source.params "year:2024,region:west"
```

**Resulting config**

```json
{
  "entities": {
    "RunReport": {
      "source": {
        "type": "stored-procedure",
        "object": "RunReport",
        "params": {
          "year": 2024,
          "region": "west"
        }
      }
    }
  }
}
```

> [!Note]
> Using `--source.params` with tables or views is not allowed.

## `--source.type`

Change the source object type.

**Example**

```sh
dab update Book --source.type view
```

**Resulting config**

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

> [!Important]
> Changing source type may invalidate other properties. For example, views always require key-fields; stored procedures cannot define key-fields.
