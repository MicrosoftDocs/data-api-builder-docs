---
title: Policies Configuration
description: Part of the configuration documentation for Data API builder, focusing on Policies Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

## Configuration File

1. [Overview](./configuration-file-overview.md)
1. [Runtime](./configuration-file-runtime.md)
1. [Entities.{entity}](./configuration-file-entities.md)
1. [Entities.{entity}.relationships](./configuration-file-entity-relationships.md)
1. [Entities.{entity}.permissions](./configuration-file-entity-permissions.md)
1. [Entities.{entity}.policy](./configuration-file-entity-policy.md)
1. [Sample](./configuration-file-sample.md)

# Entity & Database Policies

## {entity}.policy

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

**Syntax**

The `database` policy: an OData-like expression that is translated into a query predicate that will be evaluated by the database. This include opreators like `eq`, `lt`, and `gt`. In order for results to be returned for a request, the request's query predicate resolved from a database policy must evaluate to `true` when executing against the database.

|Example Item Policy|Predicate
|-|-
|`@item.OwnerId eq 2000`|`WHERE Table.OwnerId = 2000`
|`@item.OwnerId gt 2000`|`WHERE Table.OwnerId > 2000`
|`@item.OwnerId lt 2000`|`WHERE Table.OwnerId < 2000`

> A `predicate` is an expression that evaluates to TRUE or FALSE. Predicates are used in the search condition of [WHERE](/sql/t-sql/queries/where-transact-sql) clauses and [HAVING](/sql/t-sql/queries/select-having-transact-sql) clauses, the join conditions of [FROM](/sql/t-sql/queries/from-transact-sql) clauses, and other constructs where a Boolean value is required.
([Microsoft Learn Docs](/sql/t-sql/queries/predicates?view=sql-server-ver16&preserve-view=true))

**Database policy**

Two types of directives can be used when authoring a database policy expression:

- `@claims`: access a claim within the validated access token provided in the request.
- `@item`: represents a field of the entity for which the database policy is defined.

> [!NOTE]
> When Azure Static Web Apps authentication (EasyAuth) is configured, a limited number of claims types are available for use in database policies: `identityProvider`, `userId`, `userDetails`, and `userRoles`. See Azure Static Web App's [Client principal data](/azure/static-web-apps/user-information?tabs=javascript#client-principal-data) documentation for more details.

|Example Database Policy
|-
|`@claims.UserId eq @item.OwnerId`
|`@claims.UserId gt @item.OwnerId`
|`@claims.UserId lt @item.OwnerId`

Data API builder compares the value of the `UserId` claim to the value of the database field `OwnerId`. The result payload only includes records that fulfill **both** the request metadata and the database policy expression.


xxx
##### Limitations

Database policies are supported for tables and views. Stored procedures can't be configured with policies.

Database policies can't be used to prevent a request from executing within a database. This is because database policies are resolved as query predicates in the generated database queries and are ultimately evaluated by the database engine.

Database policies are only supported for the `actions` **create**, **read**, **update**, and **delete**.

Database policy OData expression syntax only supports:

- Binary operators [BinaryOperatorKind - Microsoft Learn](/dotnet/api/microsoft.odata.uriparser.binaryoperatorkind?view=odata-core-7.0&preserve-view=true) such as `and`, `or`, `eq`, `gt`, `lt`, and more.
- Unary operators [UnaryOperatorKind - Microsoft Learn](/dotnet/api/microsoft.odata.uriparser.unaryoperatorkind?view=odata-core-7.0&preserve-view=true) such as the negate (`-`) and `not` operators.
- Entity field names must "start with a letter or underscore, followed by at most 127 letters, underscores or digits" per [OData Common Schema Definition Language Version 4.01](https://docs.oasis-open.org/odata/odata-csdl-json/v4.01/odata-csdl-json-v4.01.html#sec_SimpleIdentifier)
    - Fields which do not conform to the mentioned restrictions can't be referenced in database policies. As a workaround, configure the entity with a `mappings` section to assign conforming aliases to the fields.