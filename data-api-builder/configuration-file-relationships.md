---
title: Entity Relationship Configuration
description: Part of the configuration documentation for Data API builder, focusing on Entity Relationships.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

# Configuration File Entity Relationships

This section outlines options that define relationships between entities. 

```json
{
  "entities": {
    "relationships": {
      "<name>": "...",
      ...
    }
   }
}
```

The `relationships` section outlines how entities interact within the Data API builder, detailing associations and potential database support for these relationships. The `name` property for each relationship is both required and must be unique across all relationships for a given entity. This ensures clear, identifiable connections and maintains the integrity of the GraphQL schema generated from these configurations.

## One-To-Many relationship

A one-to-many relationship connects one entity to multiple entities in another table. This relationship allows you to model scenarios where a single entity can be associated with several instances of another entity. For instance, a single category can refence many todo tasks.

```json
"relationships": {
  "<relationshipName>": {
    "cardinality": "many",
    "target.entity": "<foreignEntityName>",
    "source.fields": ["<localKey>"],
    "target.fields": ["<foreignKey>"]
  }
}
```

This syntax specifies that the entity (for example, `Category`) has a relationship with another entity (`Todo`), identified by a unique relationship name. The `source.fields` and `target.fields` define the local and foreign keys that link these entities together.

### Example 

Consider a scenario where a `Category` entity is related to multiple `Todo` items. The configuration indicates that each category can be linked to many todos. The relationship is defined by matching the `Category` entity's ID (`source.fields`) with the `Todo` entity's category ID (`target.fields`).

```json
"entities": {
  "Category": {
    "relationships": {
      "todos": {
        "cardinality": "many",
        "target.entity": "Todo",
        "source.fields": ["id"],
        "target.fields": ["category_id"]
      }
    }
  }
}
```

### GraphQL Schema

The resulting GraphQL schema reflects this relationship by allowing queries on the `Category` entity to retrieve all related `Todo` items. This relationship enhances data retrieval efficiency and the relational context within your API.

```graphql
type Category
{
  id: Int!
  ...
  todos: [TodoConnection]!
}
```

| Field           | Description
|-----------------|------------
| `source.fields` | Database fields in the *source* entity that are used to connect to the related item in the `target` entity. |
| `target.fields` | Database fields in the *target* entity that are used to connect to the related item in the `source` entity. |

These fields are optional and can be inferred automatically if there's a Foreign Key constraint between the two tables in the database.

## Many-To-One relationship

Similar to the One-To-Many but cardinality is set to `one`. Using the following configuration snippet as an example:

```json
"entities": {
  "Todo": {
    "relationships": {
      "category": {
        "cardinality": "one",
        "target.entity": "Category",
        "source.fields": ["category_id"],
        "target.fields": ["id"]
      }
    }
  }
}
```

the configuration is telling Data API builder that the exposed `Todo` entity has a Many-To-One relationship with the `Category` entity (defined elsewhere in the configuration file) and so the resulting exposed GraphQL schema (limited to the `Todo` entity) should look like the following:

```graphql
type Todo
{
  id: Int!
  ...
  category: Category
}
```

`source.fields` and `target.fields` are optional and can be used to specify which database columns are used to create the query behind the scenes:

+ `source.fields`: database fields in the *source* entity (`Todo` in the example) that are used to connect to the related item in the `target` entity
+ `target.fields`: database fields in the *target* entity (`Category` in the example) that are used to connect to the related item in the `source` entity

These are optional if there's a Foreign Key constraint on the database between the two tables that can be used to infer that information automatically.

##### Many-To-Many relationship

A many-to-many relationship is configured in the same way the other relationships type are configured, with the additional information about the association table or entity used to create the M:N relationship in the backend database.

```json
"entities": {
  "Todo": {
    "relationships": {
      "assignees": {
        "cardinality": "many",
        "target.entity": "User",
        "source.fields": ["id"],
        "target.fields": ["id"],
        "linking.object": "s005.users_todos",
        "linking.source.fields": ["todo_id"],
        "linking.target.fields": ["user_id"]
      }
    }
  }
}
```

the `linking` prefix in elements identifies those elements used to provide association table or entity information:

+ `linking.object`: the database object (if not exposed via Hawaii) that is used in the backend database to support the M:N relationship
+ `linking.source.fields`: database fields, in the *linking* object (`s005.users_todos` in the example), that is used to connect to the related item in the `source` entity (`Todo` in the sample)
+ `linking.target.fields`: database fields, in the *linking* object (`s005.users_todos` in the example), that is used to connect to the related item in the `target` entity (`User` in the sample)

The expected GraphQL schema generated by the above configuration is something like:

```graphql
type User
{
  id: Int!
  ...
  todos: [TodoConnection]!
}

type Todo
{
  id: Int!
  ...
  assignees: [UserConnection]!
}
```

#### Permissions

The section `permissions` defines who (in terms of roles) can access the related entity and using which actions. Actions are the usual CRUD operations: `create`, `read`, `update`, `delete`.

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          "role": "...",
          "actions": ["create", "read", "update", "delete"],
        }
      ]
    }
  }
}
```

##### Roles

The `role` string contains the name of the role to which the defined permission applies.

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          "role": "reader"
          ...
        }
      ]
    }
  }
}
```

##### Actions

The `actions` array details what actions are allowed on the associated role. When the entity is either a table or view, roles can be configured with a combination of the actions: `create`, `read`, `update`, `delete`.

The following example tells Data API builder that the contributor role permits the `read` and `create` actions on the entity:

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          "role": "contributor",
          "actions": ["read", "create"]
        }
      ]
    }
  }
}
```

In case all actions are allowed, the wildcard character `*` can be used as a shortcut to represent all actions supported for the type of entity:

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          "role": "editor",
          "actions": ["*"]
        }
      ]
    }
  }
}
```

For stored procedures, roles can only be configured with the `execute` action or the wildcard `*`. The wildcard `*` expands to the `execute` action for stored procedures.
For tables and views, the wildcard `*` action expands to the actions `create, read, update, delete`.

##### Fields

Role configuration supports granularly defining which database columns (fields) are permitted access in the section `fields`:

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          {
            "role": "read-only",
            "action": "read",
            "fields": {
              "include": ["*"],
              "exclude": ["field_xyz"]
            }
          }
        }
      ]
    }
  }
}
```

That indicates to Data API builder that the role *read-only* can `read` from all fields except from `field_xyz`.

Both the simplified and granular `action` definitions can be used at the same time. For example, the following configuration limits the `read` action to specific fields, while implicitly allowing the `create` action to operate on all fields:

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          "role": "reader",
          "action": "read",
          "fields": {
            "include": ["*"],
            "exclude": ["last_updated"]
        },
        {
          "role": "writer",
          "actions": ["create", "read", "update", "delete"]
        }
      ]
    }
  }
}
```

In the `fields` section above, the wildcard `*` in the `include` section indicates all fields. The fields noted in the `exclude` section have precedence over fields noted in the `include` section. The definition translates to *include all fields except for the field 'last_updated'*.

##### Policies

The `policy` section, defined per `action`, defines item-level security rules (database policies) which limit the results returned from a request. The sub-section `database` denotes the database policy expression that is evaluated during request execution.

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "policy": {
        "database": "<Expression>"
      }
    }
  }
}
```

- `database` policy: an OData expression that is translated into a query predicate that will be evaluated by the database.
  - for example The policy expression `@item.OwnerId eq 2000` is translated to the query predicate `WHERE Table.OwnerId  = 2000`

> A *predicate* is an expression that evaluates to TRUE, FALSE, or UNKNOWN. Predicates are used in the search condition of [WHERE](/sql/t-sql/queries/where-transact-sql) clauses and [HAVING](/sql/t-sql/queries/select-having-transact-sql) clauses, the join conditions of [FROM](/sql/t-sql/queries/from-transact-sql) clauses, and other constructs where a Boolean value is required.
([Microsoft Learn Docs](/sql/t-sql/queries/predicates?view=sql-server-ver16&preserve-view=true))

In order for results to be returned for a request, the request's query predicate resolved from a database policy must evaluate to `true` when executing against the database.

Two types of directives can be used when authoring a database policy expression:

- `@claims`: access a claim within the validated access token provided in the request.
- `@item`: represents a field of the entity for which the database policy is defined.

> [!NOTE]
> When Azure Static Web Apps authentication (EasyAuth) is configured, a limited number of claims types are available for use in database policies: `identityProvider`, `userId`, `userDetails`, and `userRoles`. See Azure Static Web App's [Client principal data](/azure/static-web-apps/user-information?tabs=javascript#client-principal-data) documentation for more details.

For example, a policy that utilizes both directive types, pulling the UserId from the access token and referencing the entity's OwnerId field would look like:

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "policy": {
        "database": "@claims.UserId eq @item.OwnerId"
      }
    }
  }
}
```

Data API builder compares the value of the `UserId` claim to the value of the database field `OwnerId`. The result payload only includes records that fulfill **both** the request metadata and the database policy expression.

##### Limitations

Database policies are supported for tables and views. Stored procedures can't be configured with policies.

Database policies can't be used to prevent a request from executing within a database. This is because database policies are resolved as query predicates in the generated database queries and are ultimately evaluated by the database engine.

Database policies are only supported for the `actions` **create**, **read**, **update**, and **delete**.

Database policy OData expression syntax only supports:

- Binary operators [BinaryOperatorKind - Microsoft Learn](/dotnet/api/microsoft.odata.uriparser.binaryoperatorkind?view=odata-core-7.0&preserve-view=true) such as `and`, `or`, `eq`, `gt`, `lt`, and more.
- Unary operators [UnaryOperatorKind - Microsoft Learn](/dotnet/api/microsoft.odata.uriparser.unaryoperatorkind?view=odata-core-7.0&preserve-view=true) such as the negate (`-`) and `not` operators.
- Entity field names must "start with a letter or underscore, followed by at most 127 letters, underscores or digits" per [OData Common Schema Definition Language Version 4.01](https://docs.oasis-open.org/odata/odata-csdl-json/v4.01/odata-csdl-json-v4.01.html#sec_SimpleIdentifier)
    - Fields which do not conform to the mentioned restrictions can't be referenced in database policies. As a workaround, configure the entity with a `mappings` section to assign conforming aliases to the fields.

#### Mappings

The `mappings` section enables configuring aliases, or exposed names, for database object fields. The configured exposed names apply to both the GraphQL and REST endpoints. For entities with GraphQL enabled, the configured exposed name **must** meet GraphQL naming requirements. [GraphQL - October 2021 - Names ](https://spec.graphql.org/October2021/#sec-Names)

The format is: `<database_field>: <entity_field>`

For example:

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "mappings": {
        "sku_title": "title",
        "sku_status": "status"
      }
    }
  }
}
```

means the `sku_title` field in the related database object is mapped to the exposed name `title` and `sku_status` is mapped to `status`. Both GraphQL and REST require using `title` and `status` instead of `sku_title` and `sku_status` and will additionally use those mapped values in all response payloads.