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

The Data API builder for Azure Cosmos DB engine requires users to provide the schema since the NOSQL API is schema-agnostic. Additionally, the entities utilized in the GraphQL filter query should be included in the schema file.  The engine also expects a GraphQL schema directive @authorize to be used with your object type definitions to enforce "read" permissions, when you want to be more restrictive than "anonymous" read access.

Example 1 :

type Book @model(name:"Book"){
  id: ID
  title: String @authorize(roles:["role1","authenticated"])
  Authors: [Author]
}

The @authorize directive with roles:["role1","authenticated"] restricts access to the title field to only users with the roles "role1" and "authenticated," adhering to the permissions configuration for "included" and "excluded" fields. For authenticated requestors, the system role 'authenticated' is automatically assigned, eliminating the need for x-ms-api-role. However, if anonymous access is desired, omitting the authorize directive is recommended.

The @model(name:"Book") directive is utilized to establish a correlation between this GraphQL object type and the corresponding entity name in the runtime config.

Example 2 :

type Book @model(name:"Book") @authorize(roles:["role1","authenticated"]) {
  id: ID
  title: String
  Authors: [Author]
}

By incorporating the @authorize directive in the top-level type definition, access to this type and its fields will be restricted exclusively to the roles specified within the directive.
