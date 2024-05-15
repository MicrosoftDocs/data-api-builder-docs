---
title: What's new for version 1.1
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 1.1.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 05/15/2024
---

# What's new in Data API builder version 1.1

Release notes and information about the updates and enhancements in Data API builder (DAB) version 1.1.

> [!IMPORTANT]
> This is the first general availability (GA) release on Data API builder (DAB).

## GitHub release notes

Review these release pages for a comprehensive list of all the changes and improvements:

| | Link |
| --- | --- |
| **2024-05-14 - Version 1.1.7** | <https://github.com/azure/data-api-builder/releases/tag/v1.1.7> |

## .NET 8 support

DAB now uses multi-targeting to support both .NET 6 and .NET 8 long-term support (LTS) versions.

For more information, see [azure/data-api-builder - .NET multi-framework targeting](https://github.com/azure/data-api-builder/pull/2181).

## GraphQL multiple mutations support

DAB now supports combining multiple mutation operations together into a single GraphQL transaction. The current support is scoped to `create` operations only.

For example, assume we have `Book` and `Chapter` entities that are related. With multiple mutations, you can create the primary book entity and all related chapter entities as a single operation.

```graphql
mutation {
  createBook(
    item: {
      title: "Data API builder deep-dive"
      chapters: [
        { name: "Multiple mutations" }
        { name: "Relationships" }
      ]
    }
  ) {
    title
    chapters {
      items {
        name
      }
    }
  }
}
```

This feature is documented in-depth in our [Multiple mutations guide](../how-to-multiple-mutations.md).

For more information, see [azure/data-api-builder - Multiple mutations in GraphQL](https://github.com/azure/data-api-builder/pull/2122).

## Pagination enhancements

DAB now has a `paginationOptions` configuration property to adjust various characteristics of the built-in pagination support. The subproperties include:

| | Default value | Description |
| --- | --- | --- |
| **`default-page-size`** | 100 | Page size if a request is made without page size specified. |
| **`max-page-size`** | 100,000 | Page size if a request is made with `-1` specified for page size. |

For more information, see [azure/data-api-builder - Add pagination limits](https://github.com/azure/data-api-builder/pull/2153).

## Health status

In earlier versions of DAB, the API would return a string **status** message of `healthy` at the root (`/`) endpoint. Now, the tool returns a JSON object containing the **status**, **version**, and the **application name** indicating whether DAB is hosted or the open-source software (OSS) version.

For example, version `0.12.0` of the OSS container image would return this status message by default:

```json
{
    "status": "Healthy",
    "version": "0.12.0",
    "app-name": "dab_oss_0.12.0"
}
```

For more information, see [azure/data-api-builder - Improved health endpoint metadata](https://github.com/azure/data-api-builder/pull/2086).

## REST Multiple database support

In the REST API, multiple databases (or data sources) are now supported. The database name is determined based on each entity.

For more information, see [azure/data-api-builder - Multiple database support in REST](https://github.com/azure/data-api-builder/pull/2169).

## Azure Cosmos DB for NoSQL enhancements

There were a few enhancements to the existing Azure Cosmos DB for NoSQL support in DAB.

### Patch operation support

Azure Cosmos DB patch operations are now supported using the `patch<entity-name>` mutation.

For example, assume that there's a small container with various author items partitioned by `publisher`. Now assume that the container has this item and schema:

```json
{
  "id": "04511cbc-459d-4e39-b957-363f26771fc0",
  "firstName": "Jacob",
  "lastName": "Hancock",
  "publisher": "Contoso Books"
}
```

```graphql
type Author @model {
  id: ID!
  firstName: String!
  middleName: String
  lastName: String!
  publisher: String!
}
```

To patch using GraphQL, use the `patchAuthor` mutation specifying both the unique identifier and the partition key:

```graphql
mutation {
  patchAuthor(
    item: { 
      middleName: "A." 
    }
    id: "04511cbc-459d-4e39-b957-363f26771fc0"
    _partitionKeyValue: "Contoso Books"
  ) {
    middleName
  }
}
```

For more information, see [azure/data-api-builder - Patch support](https://github.com/azure/data-api-builder/pull/2161).

### Item-level security

Item-level security (database policies) is now supported with Azure Cosmos DB for NoSQL. The database policy expression is evaluated to determine what items the current role can access.

For example, this role definition would define a new role named `scoped-reader` that can only read items where the `ownerId` is equivalent to the existing `UserId` from the identity provider's `@claims` object.

```json
{
  "<entity-name>": {
    "permissions": [
      {
        "role": "scoped-reader",
        "actions": [
          {
            "action": "read",
            "policy": {
              "database": "@item.ownerId eq @claims.UserId"
            }
          }
        ]
      }
    ]
  }
}
```

For more information, see [azure/data-api-builder - Item-level authentication support using database policy](https://github.com/azure/data-api-builder/pull/2106).

### In-memory cache support

Updates existing Azure Cosmos DB for NoSQL query engine to use Azure Cosmos DB's in-memory cache.

For more information, see [azure/data-api-builder - In-memory cache support](https://github.com/azure/data-api-builder/pull/2015).

## PostgreSQL enhancements

There's an enhancement to the existing PostgreSQL support in DAB.

### Concatenate application name to connection string

DAB now supplements the PostgreSQL connection string with the DAB application name. The tool checks to see if an application name already exists in the connection string, and either:

- Adds a new DAB application name if one doesn't exist or
- Adds the DAB application name after the existing application name with a `,` separator.

For more information, see [azure/data-api-builder - Add application name for PostgreSQL connections](https://github.com/azure/data-api-builder/pull/2208).
