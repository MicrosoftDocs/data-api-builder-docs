---
title: Configuration schema - Entities section
description: The Data API Builder configuration file's Entities top-level section with details for each property.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 06/06/2025
show_latex: true
---

# Entities

Configuration settings for database entities.

## Health

|Property|Description|
|-|-|
|[`entities.entity-name.health.enabled`](#health-entity-name-entities)|Enables health checks for the entity (both REST and GraphQL endpoints)|
|[`entities.entity-name.health.first`](#health-entity-name-entities)|Number of rows returned in health check query (range: 1-500)|
|[`entities.entity-name.health.threshold-ms`](#health-entity-name-entities)|Maximum duration in milliseconds for health check query (min: 1)|

## Source

|Property|Description|
|-|-|
|[`entities.entity-name.source.type`](#source-entity-name-entities)|Object type: `table`, `view`, or `stored-procedure`|
|[`entities.entity-name.source.object`](#source-entity-name-entities)|Name of the database object|
|[`entities.entity-name.source.parameters`](#source-entity-name-entities)|Parameters for stored procedures or functions|
|[`entities.entity-name.source.key-fields`](#source-entity-name-entities)|List of primary key fields for views|
|[`entities.entity-name.mappings`](#mappings-entity-name-entities)|Maps API field names to database columns|

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

## Format overview

```json
{
  "entities": {
    "{entity-name}": {
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
        "type": "view" | "stored-procedure" | "table",
        "key-fields": [<string>], // primary keys for the view
        "parameters": { // only for stored-procedure
          "<parameter-name>": <default-value>,
          "<parameter-name>": <default-value>
        }
      },
      "mappings": {
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
      ]
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
|`entities.{entity-name}.source`|`type`|enum (`table`, `view`, `stored-procedure`)|✔️ Yes|None|
|`entities.{entity-name}.source`|`key-fields`|string array|✔️ Yes*|None|
|`entities.{entity-name}.source`|`parameters`|object|✔️ Yes**|None|

* `key-fields` is only required when `type` is `view`. The value represents the primary keys.

** `parameters` is only required when `type` is `stored-procedure` and only for parameters with default values. The data type of the parameter is inferred. Parameters without a default can be omitted.

> [!TIP]
> If the object belongs to the `dbo` schema, specifying the schema is optional. Additionally, square brackets around object names (for example, `dbo.Users` vs. `[dbo].[Users]`) can be used when required.

### Format
```json
{
  "entities": {
    "{entity-name}": {
      "source": {
        "object": <string>,
        "type": <"view" | "stored-procedure" | "table">,
        "key-fields": [ <string> ], // primary keys of the view
        "parameters": { // only for option stored-procedure parameters
          "<parameter-name-1>": <default-value>
          "<parameter-name-2>": <default-value>
        }
      }
    }
  }
}
```

## Permissions (entity-name entities)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`entities.permissions`|`role`|string|✔️ Yes|None|

A string specifying the name of the role to which permissions apply.

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "permissions": [
        {
          "role": <"anonymous" | "authenticated" | "custom-role">
        }
      ]
    }
  }
}
```

### Example

This example defines the role `custom-role` with only `read` permissions on the `User` entity.

```json
{
  "entities": {
    "User": {
      "permissions": [
        {
          "role": "custom-role",
          "actions": ["read"]
        }
      ]
    }
  }
}
```

### Usage examples

### [HTTP](#tab/http)

```http
GET https://localhost:5001/api/User
Authorization: Bearer <your_access_token>
X-MS-API-ROLE: custom-role
```

### [C#](#tab/csharp)

```csharp
using System.Net.Http;
using System.Net.Http.Headers;

var client = new HttpClient();
client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", "<your_access_token>");
client.DefaultRequestHeaders.Add("X-MS-API-ROLE", "custom-role");
var response = await client.GetAsync("https://localhost:5001/api/User");
// To read the response content:
// var content = await response.Content.ReadAsStringAsync();
```

### [JavaScript/TypeScript](#tab/javascript-typescript)

```typescript
const response = await fetch('https://localhost:5001/api/User', {
  headers: {
    "Authorization": "Bearer <your_access_token>",
    "X-MS-API-ROLE": "custom-role"
  }
});
// To read the response body as JSON:
// const data = await response.json();
```

### [Python](#tab/python)

```python
import requests

headers = {
    "Authorization": "Bearer <your_access_token>",
    "X-MS-API-ROLE": "custom-role"
}
response = requests.get('https://localhost:5001/api/User', headers=headers)
# To print the response JSON:
print(response.json())
```

---

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

- Policies support OData operators like `eq`.
- Policies support compound predicates using `and` and `or`. 
- Only supported for actions: `create`, `read`, `update`, and `delete`. (Not `execute`)
- Policies filter results but don't prevent query execution in the database.
- Field must use the field alias, if mapped.

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
|`entities.{entity-name}.graphql.type`|`singular`|❌ No|string|None|
|`entities.{entity-name}.graphql.type`|`plural`|❌ No|string|N/A (defaults to singular value)|

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

## Mappings (entity-name entities)

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

### Format

```json
{
  "entities": {
    "{entity-name}": {
      "cache": {
        "enabled": <true> (default) | <false>,
        "ttl-seconds": <integer; default: 5>
      }
    }
  }
}
```

> [!NOTE]
> When not specified, `ttl-seconds` inherits the global value set under `runtime.cache`.

### Example

```json
{
  "entities": {
    "Author": {
      "cache": {
        "enabled": true,
        "ttl-seconds": 30
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
> Stored procedures are automatically excluded from entity health checks because they require parameters and may not be deterministic.
