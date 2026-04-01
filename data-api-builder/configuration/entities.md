---
title: Configuration schema - Entities section
description: The Data API Builder configuration file's Entities top-level section with details for each property.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/24/2026
show_latex: true
---

# Entities

Configuration settings for database entities.

## Health

|Property|Description|
|-|-|
|[`entities.entity-name.health.enabled`](#health-entity-name-entities)|Enables health checks for the entity (both REST and GraphQL endpoints)|
|[`entities.entity-name.health.first`](#health-entity-name-entities)|Number of rows returned in health check query (range: 1-500)|
|[`entities.entity-name.health.threshold-ms`](#health-entity-name-entities)|Maximum duration in milliseconds for health check query (min: One)|

## Description

|Property|Description|
|-|-|
|[`entities.entity-name.description`](#description-entity-name-entities)|Human-readable description of the entity|

## Fields

|Property|Description|
|-|-|
|[`entities.entity-name.fields[].name`](#fields-entity-name-entities)|Database field name (required)|
|[`entities.entity-name.fields[].alias`](#fields-entity-name-entities)|API-exposed name (replaces mappings)|
|[`entities.entity-name.fields[].description`](#fields-entity-name-entities)|Human-readable field description|
|[`entities.entity-name.fields[].primary-key`](#fields-entity-name-entities)|Marks field as a primary key (replaces key-fields)|

## Source

|Property|Description|
|-|-|
|[`entities.entity-name.source.type`](#source-entity-name-entities)|Object type: `table`, `view`, or `stored-procedure`|
|[`entities.entity-name.source.object`](#source-entity-name-entities)|Name of the database object|
|[`entities.entity-name.source.object-description`](#source-entity-name-entities)|Human-readable description of the database object|
|[`entities.entity-name.source.parameters`](#source-entity-name-entities)|Parameters for stored procedures or functions|
|[`entities.entity-name.source.key-fields`](#source-entity-name-entities)|~~List of primary key fields for views~~ (deprecated)|
|[`entities.entity-name.mappings`](#mappings-entity-name-entities)|~~Maps API field names to database columns~~ (deprecated)|

## REST

|Property|Description|
|-|-|
|[`entities.entity-name.rest.enabled`](#rest-entity-name-entities)|Enables REST for this entity|
|[`entities.entity-name.rest.path`](#rest-entity-name-entities)|Custom route for REST endpoint|
|[`entities.entity-name.rest.methods`](#rest-entity-name-entities)|Allowed REST methods: `get`, `post`, `put`, `patch`, `delete`|

## GraphQL

|Property|Description|
|-|-|
|[`entities.entity-name.graphql.type`](#type-graphql-entity-name-entities)|Type name or object with `singular` and `plural`|
|[`entities.entity-name.graphql.operation`](#operation-graphql-entity-name-entities)|Operation type: `query` or `mutation`|
|[`entities.entity-name.graphql.enabled`](#enabled-graphql-entity-name-entities)|Enables GraphQL for this entity|

## Permissions

|Property|Description|
|-|-|
|[`entities.entity-name.permissions[].role`](#permissions-entity-name-entities)|Role name string|
|[`entities.entity-name.permissions[].actions`](#actions-string-array-permissions-entity-name-entities)|One or more of: `create`, `read`, `update`, `delete`, `execute`|

## Relationships

|Property|Description|
|-|-|
|[`entities.entity-name.relationships.relationship-name.cardinality`](#relationships-entity-name-entities)|`one` or `many`|
|[`entities.entity-name.relationships.relationship-name.target.entity`](#relationships-entity-name-entities)|Name of the target entity|
|[`entities.entity-name.relationships.relationship-name.source.fields`](#relationships-entity-name-entities)|Fields from this entity used in the relationship|
|[`entities.entity-name.relationships.relationship-name.target.fields`](#relationships-entity-name-entities)|Fields from target entity|
|[`entities.entity-name.relationships.relationship-name.linking.object`](#relationships-entity-name-entities)|Join object used for many-to-many relationships|
|[`entities.entity-name.relationships.relationship-name.linking.source.fields`](#relationships-entity-name-entities)|Fields from source entity used in join|
|[`entities.entity-name.relationships.relationship-name.linking.target.fields`](#relationships-entity-name-entities)|Fields from target entity used in join|

## Cache

|Property|Description|
|-|-|
|[`entities.entity-name.cache.enabled`](#cache-entity-name-entities)|Enables response caching for the entity|
|[`entities.entity-name.cache.ttl-seconds`](#cache-entity-name-entities)|Cache time-to-live in seconds|
|[`entities.entity-name.cache.level`](#cache-entity-name-entities)|Cache level: `L1` (in-memory only) or `L1L2` (in-memory + distributed)|

## MCP

|Property|Description|
|-|-|
|[`entities.entity-name.mcp`](#mcp-entity-name-entities)|Boolean shorthand or object to control Model Context Protocol (MCP) participation for the entity|
|[`entities.entity-name.mcp.dml-tools`](#mcp-entity-name-entities)|Enables or disables data manipulation language (DML) tools for the entity|
|[`entities.entity-name.mcp.custom-tool`](#mcp-entity-name-entities)|Registers the stored procedure as a named MCP tool (stored-procedure entities only)|

## Format overview

```json
{
  "entities": {
    "{entity-name}": {
      "description": <string>,
      "rest": {
        "enabled": <boolean> // default: true
        "path": <string> // default: "{entity-name}"
        "methods": ["GET", "POST"] // default: ["GET", "POST"]
      },
      "graphql": {
        "enabled": <boolean> // default: true
        "type": {
          "singular": <string>,
          "plural": <string>
        },
        "operation": "query" | "mutation" // default: "query"
      },
      "source": {
        "object": <string>,
        "object-description": <string>,
        "type": "view" | "stored-procedure" | "table",
        "key-fields": [<string>], // DEPRECATED: use fields[].primary-key
        "parameters": [ // array format (preferred)
          {
            "name": "<parameter-name>",
            "required": <boolean>,
            "default": <value>,
            "description": "<string>"
          }
        ]
      },
      "fields": [
        {
          "name": "<database-field-name>",
          "alias": "<api-exposed-name>",
          "description": "<string>",
          "primary-key": <boolean>
        }
      ],
      "mappings": { // DEPRECATED: use fields[].alias
        "<database-field-name>": <string>
      },
      "relationships": {
        "<relationship-name>": {
          "cardinality": "one" | "many",
          "target.entity": <string>,
          "source.fields": [<string>],
          "target.fields": [<string>],
          "linking.object": <string>,
          "linking.source.fields": [<string>],
          "linking.target.fields": [<string>]
        }
      },
      "permissions": [
        {
          "role": "anonymous" | "authenticated" | <custom-role>,
          "actions": ["create", "read", "update", "delete", "execute", "*"],
          "fields": {
            "include": [<string>],
            "exclude": [<string>]
          },
          "policy": {
            "database": <string>
          }
        }
      ],
      "cache": {
        "enabled": <boolean>,
        "ttl-seconds": <integer>,
        "level": "L1" | "L1L2" // default: "L1L2"
      },
      "mcp": <boolean> | {
        "dml-tools": <boolean>,       // default: true
        "custom-tool": <boolean>      // stored-procedure only; default: false
      }
    }
  }
}
```

## Source (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}`|`source`|object|✔️ Yes|None|

The database source details of the entity.

### Nested properties

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.source`|`object`|string|✔️ Yes|None|
|`entities.{entity-name}.source`|`object-description`|string|❌ No|None|
|`entities.{entity-name}.source`|`type`|enum (`table`, `view`, `stored-procedure`)|✔️ Yes|None|
|`entities.{entity-name}.source`|`key-fields`|string array|❌ No*|None|
|`entities.{entity-name}.source`|`parameters`|array or object|❌ No**|None|

\* `key-fields` is only required when `type` is `view` and the `fields` array isn't used. The value represents the primary keys.

> [!WARNING]
> The `key-fields` property is deprecated in DAB 2.0. Use the [`fields`](#fields-entity-name-entities) array with `primary-key: true` instead. The schema enforces that `fields` and `key-fields` can't coexist on the same entity.

** `parameters` is only required when `type` is `stored-procedure` and only for parameters with default values. The data type of the parameter is inferred. Parameters without a default can be omitted.

**`object-description`** is an optional human-readable description of the underlying database object. This value is surfaced during MCP tool discovery, helping AI agents understand the purpose of the entity.

> [!TIP]
> If the object belongs to the `dbo` schema, specifying the schema is optional. Additionally, square brackets around object names (for example, `dbo.Users` vs. `[dbo].[Users]`) can be used when required.

### Format
```json
{
  "entities": {
    "{entity-name}": {
      "source": {
        "object": <string>,
        "object-description": <string>,
        "type": <"view" | "stored-procedure" | "table">,
        "key-fields": [ <string> ], // DEPRECATED: use fields[].primary-key
        "parameters": [ // array format (preferred)
          {
            "name": "<parameter-name>",
            "required": <boolean>,
            "default": <value>,
            "description": "<string>"
          }
        ]
      }
    }
  }
}
```

### Parameters array format

In DAB 2.0 preview, `parameters` supports a structured array format with richer metadata. Each parameter is an object with the following properties:

| Property | Type | Required | Description |
|-|-|-|-|
| `name` | string | ✔️ Yes | Parameter name (without the `@` prefix) |
| `required` | boolean | ❌ No | Whether the parameter is required (`true`) or optional (`false`) |
| `default` | any | ❌ No | Default value used when the parameter isn't supplied |
| `description` | string | ❌ No | Human-readable description of the parameter |

#### Example (array format—preferred)

```json
{
  "entities": {
    "GetBookById": {
      "source": {
        "type": "stored-procedure",
        "object": "dbo.get_book_by_id",
        "parameters": [
          {
            "name": "id",
            "required": true,
            "default": null,
            "description": "The unique identifier of the book"
          }
        ]
      }
    }
  }
}
```

> [!WARNING]
> The dictionary format for `parameters` (for example, `{ "id": 0 }`) is deprecated in DAB 2.0. Use the preceding array format. The old format is still accepted for backward compatibility but will be removed in a future release.

[!INCLUDE[Note - DAB 2.0 preview](../includes/note-dab-2-preview.md)]

## Permissions (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.permissions`|`role`|string|✔️ Yes|None|

Specifies the role name to which permissions apply. Use system roles (`Anonymous`, `Authenticated`) or custom roles defined in your identity provider.

> [!TIP]
> For detailed information on role evaluation, system roles, and the `X-MS-API-ROLE` header, see [Authorization and roles](../concept/security/authorization.md).

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "permissions": [
        {
          "role": <"Anonymous" | "Authenticated" | "custom-role">,
          "actions": [ <string> ]
        }
      ]
    }
  }
}
```

### Example

```json
{
  "entities": {
    "User": {
      "permissions": [
        {
          "role": "reader",
          "actions": ["read"]
        }
      ]
    }
  }
}
```

### Role inheritance

DAB 2.0 introduces role inheritance for entity permissions. When a role isn't explicitly configured for an entity, it inherits permissions from a broader role using the following chain:

```text
named-role → authenticated → anonymous
```

- If `authenticated` isn't configured for an entity, it inherits from `anonymous`.
- If a named role isn't configured, it inherits from `authenticated`, or from `anonymous` if `authenticated` is also absent.

This means you can define permissions once on `anonymous` and every broader role gets the same access automatically, with no duplication required.

[!INCLUDE[Note - DAB 2.0 preview](../includes/note-dab-2-preview.md)]

#### Example

```json
{
  "entities": {
    "Book": {
      "source": "dbo.books",
      "permissions": [
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

With this configuration, `anonymous`, `authenticated`, and any unconfigured named role can all read `Book`. Use [`dab configure --show-effective-permissions`](../command-line/dab-configure.md#--show-effective-permissions) to see the resolved permissions for every entity after inheritance is applied.

## Actions (string-array Permissions entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.permissions`|`actions`|oneOf [string, array]|✔️ Yes|None|

A string array detailing what operations are allowed for the associated role.

| Action | SQL Operation |
| - | - |
| `*` | All actions |
| `create` | Insert one or more* rows |
| `read` | Select one or more rows |
| `update` | Modify one or more* rows |
| `delete` | Delete one or more* rows |
| `execute` | Runs a stored procedure |

\* Multiple operations are currently only supported in GraphQL. 

> [!NOTE]
> For stored procedures, the wildcard (`*`) action expands to only the `execute` action. For tables and views, it expands to `create`, `read`, `update`, and `delete`.

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "permissions": [
        {
          "actions": [ <string> ]
        }
      ]
    }
  }
}
```

#### Example

```json
{
  "entities": {
    "{entity-name}": {
      "permissions": [
        {
          "actions": [ "*" ] // equivalent to create, read, update, delete
        }
      ]
    }
  }
}
```

### Alternate format (string-only, when `type=stored-procedure`)

```json
{
  "entities": {
    "{entity-name}": {
      "permissions": [
        {
          "actions": <string>
        }
      ]
    }
  }
}
```

#### Example

```json
{
  "entities": {
    "{entity-name}": {
      "permissions": [
        {
          "actions": "*" // equivalent to execute
        }
      ]
    }
  }
}
```

## Actions (object-array Permissions entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.permissions`|`actions`|string array|✔️ Yes|None|

An object array detailing what operations are allowed for the associated role.

> [!NOTE]
> For stored procedures, the wildcard (`*`) action expands to only `execute`. For tables/views, it expands to `create`, `read`, `update`, and `delete`.

### Nested properties

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.permissions.actions[]`|`action`|string|✔️ Yes|None|
|`entities.{entity-name}.permissions.actions[]`|`fields`|object|❌ No|None|
|`entities.{entity-name}.permissions.actions[]`|`policy`|object|❌ No|None|
|`entities.{entity-name}.permissions.actions[].policy`|`database`|string|✔️ Yes|None|

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "permissions": [
        {
          "role": <string>,
          "actions": [
            {
              "action": <string>,
              "fields": <array of strings>,
              "policy": <object>
            }
          ]
        }
      ]
    }
  }
```
### Example

This grants `read` permission to `auditor` on the `User` entity, with field and policy restrictions.

```json
{
  "entities": {
    "User": {
      "permissions": [
        {
          "role": "auditor",
          "actions": [
            {
              "action": "read",
              "fields": {
                "include": ["*"],
                "exclude": ["last_login"]
              },
              "policy": {
                "database": "@item.IsAdmin eq false"
              }
            }
          ]
        }
      ]
    }
  }
}
```

### Policy notes

Database policies filter query results using OData-style predicates. Use `@item.<field>` to reference entity fields and `@claims.<type>` to inject authenticated user claims.

| Aspect | Details |
|--------|---------|
| Syntax | OData predicates (`eq`, `ne`, `and`, `or`, `gt`, `lt`) |
| Field reference | `@item.<field>` (use mapped name if applicable) |
| Claim reference | `@claims.<claimType>` |
| Supported actions | `read`, `update`, `delete` |
| Not supported | `create`, `execute` |

> [!TIP]
> For comprehensive guidance on database policies, including claim substitution and troubleshooting, see [Configure database policies](../concept/security/database-policies.md).

## Type (GraphQL entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.graphql`|`type`|object|❌ No|{entity-name}|

Sets the naming convention for an entity within the GraphQL schema.

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "graphql": {
        "type": {
          "singular": "<string>",
          "plural": "<string>"
        }
      }
    }
  }
}
```

### Nested properties

|Parent|Property|Required|Type|Default|
|-|-|-|-|-|
|`entities.{entity-name}.graphql.type`|`singular`|✔️ Yes*|string|None|
|`entities.{entity-name}.graphql.type`|`plural`|❌ No|string|N/A (defaults to singular value)|

\* `singular` is required when `type` is specified as an object. When `type` is a plain string, that string is used as the singular name.

### Example

Configuration
```json
{
  "entities": {
    "User": {
      "graphql": {
        "type": {
          "singular": "User",
          "plural": "Users"
        }
      }
    }
  }
}
```

GraphQL query

```graphql
{
  Users {
    items {
      id
      name
      age
      isAdmin
    }
  }
}
```

GraphQL response

```json
{
  "data": {
    "Users": {
      "items": [
        {
          "id": 1,
          "name": "Alice",
          "age": 30,
          "isAdmin": true
        },
        {
          "id": 2,
          "name": "Bob",
          "age": 25,
          "isAdmin": false
        }
        // ...
      ]
    }
  }
}
```

## Operation (GraphQL entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.graphql`|`operation`|enum string|❌ No|mutation|

Designates whether the `stored-procedure` operation appears under the `Query` or `Mutation`.

> [!NOTE]
> When `{entity-name}.type` is set to `stored-procedure`, a new GraphQL type `executeXXX` is automatically created. This `operation` property controls where this type is placed in the GraphQL schema. There's no functional impact, just schema hygiene. 

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "graphql": {
        "operation": "query" | "mutation"
      }
    }
  }
}
```

### Example: operation

When `operation` is set to `query`

```graphql
type Query {
  executeGetUserDetails(userId: Int!): GetUserDetailsResponse
}
```

When `operation` is set to `mutation`

```graphql
type Mutation {
  executeGetUserDetails(userId: Int!): GetUserDetailsResponse
}
```

## Enabled (GraphQL entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.graphql`|`enabled`|boolean|❌ No|True|

Lets developers selectively include entities in the GraphQL schema.

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "graphql": {
        "enabled": <true> (default) | <false>
      }
    }
  }
}
```

### REST (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.rest`|`enabled`|boolean|❌ No|True|
|`entities.rest`|`path`|string|❌ No|`/{entity-name}`|
|`entities.{entity-name}.rest`|`methods`|string array|❌ No*|`POST`|

\* The `methods` property is only for `stored-procedure`
endpoints. 

[!INCLUDE[Note - DAB 2.0 preview](../includes/note-dab-2-preview.md)]

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "rest": {
        "enabled": <true> (default) | <false>,
        "path": <string; default: "{entity-name}">
      }
    }
  }
}
```

## Description (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}`|`description`|string|❌ No|None|

An optional human-readable description of the entity. This value is surfaced in generated API documentation and as a comment in the GraphQL schema.

[!INCLUDE[Note - DAB 2.0 preview](../includes/note-dab-2-preview.md)]

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "description": "<string>"
    }
  }
}
```

### Example

```json
{
  "entities": {
    "Book": {
      "description": "Represents a book in the catalog with title, author, and pricing information.",
      "source": {
        "object": "dbo.books",
        "type": "table"
      }
    }
  }
}
```

## Fields (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}`|`fields`|array|❌ No|None|

Defines metadata for individual database fields, including aliases, descriptions, and primary key designations. The `fields` array replaces both `mappings` (via the `alias` property) and `source.key-fields` (via the `primary-key` property) in a single, unified structure.

[!INCLUDE[Note - DAB 2.0 preview](../includes/note-dab-2-preview.md)]

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `entities.{entity-name}.fields[]` | `name` | string | ✔️ Yes | None |
| `entities.{entity-name}.fields[]` | `alias` | string | ❌ No | None |
| `entities.{entity-name}.fields[]` | `description` | string | ❌ No | None |
| `entities.{entity-name}.fields[]` | `primary-key` | boolean | ❌ No | `false` |

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "fields": [
        {
          "name": "<database-field-name>",
          "alias": "<api-exposed-name>",
          "description": "<string>",
          "primary-key": <boolean>
        }
      ]
    }
  }
}
```

### Example

```json
{
  "entities": {
    "Book": {
      "source": {
        "object": "dbo.books",
        "type": "table"
      },
      "fields": [
        {
          "name": "id",
          "description": "Unique book identifier",
          "primary-key": true
        },
        {
          "name": "sku_title",
          "alias": "title",
          "description": "The display title of the book"
        },
        {
          "name": "sku_status",
          "alias": "status"
        }
      ]
    }
  }
}
```

In this example, `id` is designated as the primary key (replacing the need for `source.key-fields`), while `sku_title` and `sku_status` are aliased as `title` and `status` (replacing the need for `mappings`).

> [!IMPORTANT]
> The schema enforces that `fields` can't coexist with `mappings` or `source.key-fields` on the same entity. Migrate to `fields` and remove the deprecated properties.

## Mappings (entity-name entities)

> [!WARNING]
> The `mappings` property is deprecated in DAB 2.0. Use the [`fields`](#fields-entity-name-entities) array with the `alias` property instead. The schema enforces that `fields` and `mappings` can't coexist on the same entity.

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}`|`mappings`|object|❌ No|None|

Enables custom aliases, or exposed names, for database object fields.

> [!IMPORTANT]
> For entities with GraphQL enabled, the configured exposed name must meet the [GraphQL name requirements](https://spec.graphql.org/October2021/#sec-Names).

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "mappings": {
        "<field-1-name>": "<field-1-alias>",
        "<field-2-name>": "<field-2-alias>",
        "<field-3-name>": "<field-3-alias>"
      }
    }
  }
}
```

### Examples

Database Table

```SQL
CREATE TABLE Books
(
  id INT,
  sku_title VARCHAR(50),
  sku_status VARCHAR(50),
)
```

Configuration

```json
{
  "entities": {
    "Books": {
      ...
      "mappings": {
        "sku_title": "title",
        "sku_status": "status"
      }
    }
  }
}
```

## Cache (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}`|`cache`|object|❌ No|None|

Enables and configures caching for the entity.

### Nested properties

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.cache`|`enabled`|boolean|❌ No|False|
|`entities.{entity-name}.cache`|`ttl-seconds`|integer|❌ No| - |
|`entities.{entity-name}.cache`|`level`|enum (`L1` \| `L1L2`)|❌ No|`L1L2`|

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "cache": {
        "enabled": <true> (default) | <false>,
        "ttl-seconds": <integer; default: 5>,
        "level": <"L1" | "L1L2"> (default: "L1L2")
      }
    }
  }
}
```

The `level` property controls which cache tiers are used:

| Value | Description |
|---|---|
| `L1` | In-memory cache only. Fastest, but not shared across instances. |
| `L1L2` | In-memory cache plus distributed (Redis) cache. Shared across scaled-out instances. Default. |

[!INCLUDE[Note - DAB 2.0 preview](../includes/note-dab-2-preview.md)]

> [!NOTE]
> When not specified, `ttl-seconds` inherits the global value set under `runtime.cache`.

### Example

```json
{
  "entities": {
    "Author": {
      "cache": {
        "enabled": true,
        "ttl-seconds": 30,
        "level": "L1"
      }
    }
  }
}
```

## Relationships (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}`|`relationships`|object|❌ No|None|

Configures how GraphQL entities are related to other exposed entities. For more information, see [Data API builder relationships breakdown](https://devblogs.microsoft.com/azure-sql/data-api-builder-relationships/).

> [!NOTE]
> The `relationship-name` property for each relationship must be unique across all relationships for that entity.

### Nested properties

These properties are used in different combinations depending on the relationship cardinality.

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.relationships`|`cardinality`|string|✔️ Yes|None|
|`entities.{entity-name}.relationships`|`target.entity`|string|✔️ Yes|None|
|`entities.{entity-name}.relationships`|`target.fields`|string array|❌ No|None|
|`entities.{entity-name}.relationships`|`source.fields`|string array|❌ No|None|
|`entities.{entity-name}.relationships`|`linking.object`|string|❌ No|None|
|`entities.{entity-name}.relationships`|`linking.source.fields`|string array|❌ No|None|
|`entities.{entity-name}.relationships`|`linking.target.fields`|string array|❌ No|None|

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "relationships": {
        "<relationship-name>": {
          "cardinality": "one" | "many",
          "target.entity": "<string>",
          "source.fields": ["<string>"],
          "target.fields": ["<string>"],
          "linking.object": "<string>",
          "linking.source.fields": ["<string>"],
          "linking.target.fields": ["<string>"]
        }
      }
    }
  }
}
```

| Relationship | Cardinality | Example |
| - | - | - |
| one-to-many | `many` | One category entity can relate to many todo entities |
| many-to-one | `one` | Many todo entities can relate to one category entity |
| many-to-many| `many` | One todo entity can relate to many user entities, and one user entity can relate to many todo entities |

### Example: One-to-one cardinality

Each `Profile` is related to exactly one `User`, and each `User` has exactly one related `Profile`.

```json
{
  "entities": {
    "User": {
      "relationships": {
        "user_profile": {
          "cardinality": "one",
          "target.entity": "Profile",
          "source.fields": [ "id" ],
          "target.fields": [ "user_id" ]
        }
      }
    },
    "Profile": {
      ...
    }
  }
}
```

GraphQL schema

```graphql
type User
{
  id: Int!
  ...
  profile: Profile
}
```

Command-line

```bash
dab update User \
  --relationship profile \
  --target.entity Profile \
  --cardinality one \
  --relationship.fields "id:user_id"
```

### Example: One-to-many cardinality

A `Category` can have one or more related `Book` entities, while each `Book` can have one related `Category`.

```json
{
  "entities": {
    "Book": {
      ...
    },
    "Category": {
      "relationships": {
        "category_books": {
          "cardinality": "many",
          "target.entity": "Book",
          "source.fields": [ "id" ],
          "target.fields": [ "category_id" ]
        }
      }
    }
  }
}
```

GraphQL schema

```graphql
type Category
{
  id: Int!
  ...
  books: [BookConnection]!
}
```

Command line

```bash
dab update Category \
  --relationship category_books \
  --target.entity Book \
  --cardinality many \
  --relationship.fields "id:category_id"
```

### Example: Many-to-one cardinality

Many `Book` entities can have one related `Category`, while a `Category` can have one or more related `Book` entries.

```json
{
  "entities": {
    "Book": {
      "relationships": {
        "books_category": {
          "cardinality": "one",
          "target.entity": "Category",
          "source.fields": [ "category_id" ],
          "target.fields": [ "id" ]
        }
      },
      "Category": {
        ...
      }
    }
  }
}
```

GraphQL schema

```graphql
type Book
{
  id: Int!
  ...
  category: Category
}
```

Command line

```bash
dab update Book \
  --relationship books_category \
  --target.entity "Category" \
  --cardinality one \
  --relationship.fields "category_id:id"
```

### Example: Many-to-many cardinality

Many `Book` entities can have many related `Author` entities, while many `Author` entities can have many related `Book` entries.

> [!NOTE]
> This relationship is possible with a third table, `dbo.books_authors`, which we refer to as the *linking object*.

```json
{
  "entities": {
    "Book": {
      "relationships": {
        ...,
        "books_authors": {
          "cardinality": "many",
          "target.entity": "Author",
          "source.fields": [ "id" ],
          "target.fields": [ "id" ],
          "linking.object": "dbo.books_authors",
          "linking.source.fields": [ "book_id" ],
          "linking.target.fields": [ "author_id" ]
        }
      },
      "Category": {
        ...
      },
      "Author": {
        ...
      }
    }
  }
}

```  

GraphQL schema

```graphql
type Book
{
  id: Int!
  ...
  authors: [AuthorConnection]!
}

type Author
{
  id: Int!
  ...
  books: [BookConnection]!
}
```

Command line

```bash
dab update Book \
  --relationship books_authors \
  --target.entity "Author" \
  --cardinality many \
  --relationship.fields "id:id" \
  --linking.object "dbo.books_authors" \
  --linking.source.fields "book_id" \
  --linking.target.fields "author_id"
```

## Health (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}`|`health`|object|❌ No|None|

Enables and configures health checks for the entity.

### Nested properties

| Parent | Property | Type | Required | Default | 
|-|-|-|-|-|
| `entities.{entity-name}.health` | `enabled` | boolean | ❌ No | `true` | 
| `entities.{entity-name}.health` | `first` | integer | ❌ No | `100` | 
| `entities.{entity-name}.health` | `threshold-ms` | integer | ❌ No | `1000` | 

### Example

```json
{
  "entities": {
    "Book": {
      "health": {
        "enabled": true,
        "first": 3,
        "threshold-ms": 500
      }
    }
  }
}
```

> [!NOTE]
> The `first` value must be less than or equal to the `runtime.pagination.max-page-size` setting. Smaller values help health checks complete faster.

> [!IMPORTANT]
> Stored procedures are automatically excluded from entity health checks because they require parameters and might not be deterministic.

## MCP (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}`|`mcp`|boolean or object|❌ No|`true`|

Controls MCP participation for the entity. When MCP is enabled globally, entities participate by default. Use this property to opt out or to enable custom MCP tools for stored-procedure entities.

[!INCLUDE[Note - DAB 2.0 preview](../includes/note-dab-2-preview.md)]

### Boolean shorthand

Use the boolean shorthand to enable or disable all DML tools for the entity:

```json
{
  "entities": {
    "Book": {
      "mcp": true
    }
  }
}
```

Setting `"mcp": false` removes the entity from all MCP tool surfaces.

### Object format

Use the object format for granular control:

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.{entity-name}.mcp`|`dml-tools`|boolean|❌ No|`true`|
|`entities.{entity-name}.mcp`|`custom-tool`|boolean|❌ No|`false`|

```json
{
  "entities": {
    "Book": {
      "mcp": {
        "dml-tools": true
      }
    }
  }
}
```

### Custom tool (stored procedures only)

For stored-procedure entities, set `custom-tool` to `true` to register the procedure as a named MCP tool:

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
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": ["execute"]
        }
      ]
    }
  }
}
```

> [!IMPORTANT]
> The `custom-tool` property is only valid for stored-procedure entities. Setting it on a table or view entity results in a configuration error.

### CLI examples

```bash
dab add Book --source books --permissions "anonymous:*" --mcp.dml-tools true
```

```bash
dab add GetBookById --source dbo.get_book_by_id --source.type stored-procedure --permissions "anonymous:execute" --mcp.custom-tool true
```
