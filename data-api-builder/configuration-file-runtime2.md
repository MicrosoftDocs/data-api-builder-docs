---
title: Entities Configuration
description: Part of the configuration documentation for Data API builder, focusing on Entities Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

# Configuration File

### Entities

The `entities` section is where mapping between database objects to exposed endpoint is done, along with properties mapping and permission definition.

Each exposed entity is enclosed in a dedicated section. The property name is used as the name of the entity to be exposed. For example

```json
"entities" {
  "User": {
    ...
  }
}
```

instructs Data API builder to expose a GraphQL entity named `User` and a REST endpoint reachable via `/User` url path.

Within the entity section, there are feature specific sections:

#### GraphQL settings

##### GraphQL type

The `graphql` property defines the name with which the entity is exposed as a GraphQL type, if that is different from the entity name:

```json
"graphql":{
  "type": "my-alternative-name"
}
```

or, if needed

```json
"graphql":{
  "type": {
    "singular": "my-alternative-name",
    "plural": "my-alternative-name-pluralized"
  }
}
```

which instructs Data API builder runtime to expose the GraphQL type for the related entity and to name it using the provided type name. `plural` is optional and can be used to tell Data API builder the correct plural name for that type. If omitted Data API builder tries to pluralize the name automatically, following the English rules for pluralization (for example: https://engdic.org/singular-and-plural-noun-rules-definitions-examples)

##### GraphQL operation

The `graphql` element contains the `operation` property only for stored-procedures. The `operation` property defines the GraphQL operation that is configured for the stored procedure. It can be one of `Query` or `Mutation`.

For example:

```json
  {
    "graphql": {
      "enabled" : true,
      "operation": "query"
    }
  }
```

instructs the engine that the stored procedure is exposed for graphQL through `Query` operation.

##### GraphQL enabled

The graphql endpoints can be enabled/disabled for a specific entity by using `enabled` property

```json
"graphql": {
  "enabled": false
}
```

or, to enable

```json
"graphql": {
  "enabled": true
}
```

If `type`is not provided, the Entity Name becomes the singular type and pluralise for the plural type.
If this is a Stored Procedure with no provided GraphQL operation, it is set to Mutation by default.

#### REST settings

##### REST path

The `path` property defines the endpoint through which the entity is exposed for REST APIs, if that is different from the entity name:

```json
"rest":{
  "path": "/entity-path"
}
```

##### REST methods

The `methods` property is only valid for stored procedures. This property defines the REST HTTP actions that the stored procedure is configured for.

For example:

```json
"rest":{
  "path": "/entity-path",
  "methods": [ "GET", "POST" ]
}

```

instructs the engine that GET and POST actions are configured for this stored procedure.

##### REST enabled

The rest endpoints can be enabled/disabled for a specific entity by using `enabled` property

```json
"rest": {
  "enabled": false
}
```

or, to enable

```json
"rest": {
  "enabled": true
}
```
If this is a Stored Procedure with no provided REST method, it is set to POST by default.

#### Database object source

The `source` property tells Data API builder what is the underlying database object to which the exposed entity is connected to.

The simplest option is to specify just the name of the table or the collection:

```json
{
  "source": "dbo.users"
}
```

a more complete option is to specify the full description of the database if that isn't a table or a collection:

```json
{
  "source": {
    "object": "<string>",
    "type": "<view> | <stored-procedure> | <table>",
    "key-fields": ["<array-of-strings>"],
    "parameters": {
        "<name>": "<value>",
        "<...>": "<...>"
    }        
  }
}
```

where

+ `object` is the name of the database object to be used.
+ `type` describes if the object is a table, a view or a stored procedure.
+ `key-fields` is a list of columns to be used to uniquely identify an item. Needed if type is `view` or if type is `table` and there's no Primary Key defined on it.
+ `parameters` is optional and can be used if type is `stored-procedure`. The key-value pairs specified in this object will be used to supply values to stored procedures parameters, in case those aren't specified in the HTTP request.

More details on how to use Views and Stored Procedure in the related documentation [Views and Stored Procedures](./views-and-stored-procedures.md)

#### Relationships

The `relationships` section defines how an entity is related to other exposed entities, and optionally provides details on what underlying database objects can be used to support such relationships. Objects defined in the `relationship` section are exposed as GraphQL field in the related entity. The format is the following:

```json
"relationships": {
  "<relationship-name>": {
    "cardinality": "<one> | <many>",
    "target.entity": "<entity-name>",
    "source.fields": ["<array-of-strings>"],
    "target.fields": ["<array-of-strings>"],
    "linking.[object|entity]": "<entity-or-db-object-name",
    "linking.source.fields": ["<array-of-strings>"],
    "linking.target.fields": ["<array-of-strings>"]
  }
}
```

##### One-To-Many relationship

Using the following configuration snippet as an example:

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

the configuration is telling Data API builder that the exposed `category` entity has a One-To-Many relationship with the `Todo` entity (defined elsewhere in the configuration file) and so the resulting exposed GraphQL schema (limited to the `Category` entity) should look like the following:

```graphql
type Category
{
  id: Int!
  ...
  todos: [TodoConnection]!
}
```

`source.fields` and `target.fields` are optional and can be used to specify which database columns are used to create the query behind the scenes:

+ `source.fields`: database fields in the *source* entity (`Category` in the example) that are used to connect to the related item in the `target` entity
+ `target.fields`: database fields in the *target* entity (`Todo` in the example) that are used to connect to the related item in the `source` entity

These are optional if there's a Foreign Key constraint on the database between the two tables that can be used to infer that information automatically.

##### Many-To-One relationship

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