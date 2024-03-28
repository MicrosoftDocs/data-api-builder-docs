---
title: What's new for version 0.4.11
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 0.4.11.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 03/28/2024
---

# What's new in Data API builder version 0.4.11

The full list of release notes for this version is available on GitHub: <https://github.com/Azure/data-api-builder/releases/tag/v0.4.11-alpha>.

## Public JSON Schema

JSON schema is published here: <https://dataapibuilder.azureedge.net/schemas/v0.4.11-alpha/dab.draft.schema.json>.

This schema gives you support for "intellisense," if you're using an IDE like Visual Studio Code that supports JSON Schemas. The `basic-empty-dab-config.json` file in the `samples` folder has an example starting point when manually creating the `dab-config.json` file.

If you're using DAB CLI to create and manage the `dab-config.json` file, DAB CLI isn't yet creating the configuration file using the reference to the JSON schema file.

## Updated JSON schema for `data-source` section

The `data-source` section in the configuration file is updated to be consistent across all supported databases but still allow each database to have custom configurations. A new section `options` is introduced to group all the properties that are specific to a database. For example:

```json
{
  "$schema": "https://dataapibuilder.azureedge.net/schemas/v0.4.11-alpha/dab.draft.schema.json",
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "options": {
      "database": "PlaygroundDB",
      "graphql-schema": "schema.gql"
    },
    "connection-string": "AccountEndpoint=https://localhost:8081/;AccountKey=REPLACEME;"
  }
}
```

The elements available in the `options` section depend on the chosen `database-type`.

## Support for filter on nested objects within a document in Azure SQL and SQL Server

With Azure SQL and SQL Server, you can use the object or array relationship defined in your schema, which enables to do filter operations on the nested objects.

```graphql
query {
  books(filter: { series: { name: { eq: "Foundation" } } }) {
    items {
      title
      year
      pages
    }
  }
}
```

## Improved stored procedure support

Full support for stored procedure in REST and GraphQL. Stored procedure with parameters now 100% supported. Check out the [Stored Procedures](../views-and-stored-procedures.md#stored-procedures) documentation to learn how to use Data API builder with stored procedures.

## New `database-type` value renamed for Cosmos DB

We added support for PostgreSQL API with Cosmos DB. With a consolidated `data-source` section, the attribute `database-type` denotes the type of database. Since Cosmos DB supports multiple APIs, the currently supported database types are `cosmosdb_nosql` and `cosmosdb_postgresql`.

```json
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "options": {
      "database": "PlaygroundDB",
      "graphql-schema": "schema.gql"
    }
  }
```

## Renaming CLI properties for `cosmosdb_nosql`

Following the configuration changes described in previous sections, now CLI properties are renamed accordingly as `cosmosdb_nosql-database` and `cosmosdb_nosql-container` for Cosmos DB NoSQL API.

```bash
dab init --database-type "cosmosdb_nosql" --graphql-schema schema.gql --cosmosdb_nosql-database PlaygroundDB  --cosmosdb_nosql-container "books" --connection-string "AccountEndpoint=https://localhost:8081/;AccountKey=REPLACEME;" --host-mode "Development"
```

## Managed Identity now supported with Postgres

Now the user can alternatively specify the access token in the config to authenticate with a Managed Identity. Alternatively, now the user  just can't specify the password in the connection string and the runtime attempts to fetch the default managed identity token. If this fails, connection is attempted without a password in the connection string.

## Support Microsoft Entra ID user authentication for Azure MySQL

Added user token as password field to authenticate with MySQL with Microsoft Entra ID plugin.
