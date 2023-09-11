---
title: Database-specific features for Data API builder
description: This document lists the database specific features.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: database-specific-features
ms.date: 04/06/2023
---

# Database-specific features

Data API builder allows each database to have its own specific features. This page lists the features that are supported for each database.

### Azure SQL and SQL Server

#### SESSION_CONTEXT and row level security

Azure SQL and SQL Server support the use of the SESSION_CONTEXT function to access the current user's identity. This is useful when you want to leverage the native support for row level security (RLS) available in Azure SQL and SQL Server. For more information, see [Azure SQL session context and RLS](./azure-sql-session-context-rls.md).

### Azure Cosmos DB

#### User-Provided GraphQL schema

The Azure Cosmos DB NOSQL API is schema-agnostic. In order to use Data API builder with Azure Cosmos DB, you must create a GraphQL schema file that includes the object type definitions representing your Azure Cosmos DB container's data model. Data API builder also expects your GraphQL object type definitions and fields to include the GraphQL schema directive `authorize` when you want to enforce more restrictive read access than `anonymous`.

Example 1 :

```graphql 
type Book @model(name:"Book"){
  id: ID
  title: String @authorize(roles:["role1","authenticated"])
  Authors: [Author]
}
```
and the corresponding entities section in config.json

```json
{
  "Book": {
    "source": "Book",
    "permissions": [
      {
        "role": "anonymous",
        "actions": [
          "read"
        ]
      }
    ]
  }
}

```

The @authorize directive with roles:["role1","authenticated"] restricts access to the title field to only users with the roles "role1" and "authenticated". For authenticated requestors, the system role 'authenticated' is automatically assigned, eliminating the need for `X-MS-API-ROLE` header. If the authenticated request needs to be executed in context of `role1`, it should be accompanied with the value of request header `X-MS-API-ROLE` set to `role1`. However, if anonymous access is desired, you must omit the authorize directive.

The `@model` directive is utilized to establish a correlation between this GraphQL object type and the corresponding entity name in the runtime config. The directive is formatted as: `@model(name:"<Entity_Name>")`

Example 2 :

```graphql 
type Book @model(name:"Book") @authorize(roles:["role1","authenticated"]) {
  id: ID
  title: String
  Authors: [Author]
}
```
and the corresponding entities section in config.json

```json
{
  "Book": {
    "source": "Book",
    "permissions": [
      {
        "role": "authenticated",
        "actions": [
          "read"
        ]
      }
    ]
  }
}

```

By incorporating the @authorize directive in the top-level type definition, you restrict access to the type and its fields will be restricted exclusively to the roles specified within the directive.

#### Cross Container Operations

Currently, GraphQL operations across containers are unsupported. The engine responds with an error message stating, "Adding/updating Relationships is currently not supported in CosmosDB." You can work around this limitation updating your data model to store entities within the same container in an embedded format. To learn more, reference our CosmosDB NOSQL data modeling [documentation](/azure/cosmos-db/nosql/modeling-data).