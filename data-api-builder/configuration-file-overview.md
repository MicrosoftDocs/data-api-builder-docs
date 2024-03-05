---
title: Overview Configuration
description: Part of the configuration documentation for Data API builder, focusing on Overview Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

## Configuration File

1. [Overview](./configuration-file-overview.md)
1. [Environment](./configuration-file-environment.md)
1. [Runtime](./configuration-file-runtime.md)
1. [Entities.{entity}](./configuration-file-entities.md)
1. [Entities.{entity}.relationships](./configuration-file-entity-relationships.md)
1. [Entities.{entity}.permissions](./configuration-file-entity-permissions.md)
1. [Entities.{entity}.policy](./configuration-file-entity-policy.md)
1. [Sample](./configuration-file-sample.md)

# Overview

The Data API Builder configuration file provides a structured and comprehensive approach to setting up your API, detailing everything from environmental variables to entity-specific configurations. This JSON-formatted document begins with a `$schema` property for validation purposes, guiding through various sections including `data-source` which establishes the connection to your backend database. 

By specifying the `database-type` and `connection-string`, it ensures seamless integration with a variety of database systems, from Azure SQL DB to Cosmos DB NoSQL API, making it a cornerstone for developers to customize and leverage the Data API Builder's capabilities efficiently.

## $schema

Each configuration file begins with a `$schema` property, specifying the [JSON schema](https://code.visualstudio.com/Docs/languages/json#_json-schemas-and-settings) for validation.

```json
{
  "$schema": "..."
}
```

Schema files are available for versions 0.3.7-alpha onwards at specific URLs, ensuring you use the correct version or the latest available schema.

```https
https://github.com/Azure/data-api-builder/releases/download/<VERSION>-<suffix>/dab.draft.schema.json
```

Replace `VERSION-suffix` with the version you want.

```https
https://github.com/Azure/data-api-builder/releases/download/v0.3.7-alpha/dab.draft.schema.json
```

**Latest version**

The latest version of the schema is always available [here](https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json). 

```https
https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json
```

## data-source

The `data-source` section outlines backend database connectivity, specifying both the `database-type` and `connection-string`.

```json
{
  ...
  "data-source": {
    "database-type": "..",
    "connection-string": "..."
  }
}
```

### database-source.database-type

The `type` property indicates the kind of backend database.

|Type|Description
|-|-
|`mssql`| Azure SQL DB, Azure SQL MI and SQL Server
|`postgresql`| PostgreSQL
|`mysql`| MySQL
|`cosmosdb_nosql`| Cosmos DB NoSQL API
|`cosmosdb_postgresql`| Cosmos DB PostgreSQL API

### database-source.database-type

The ADO.NET connection string to connect to the backend database. [Learn more.](/dotnet/framework/data/adonet/connection-strings)

**Example**

```
Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;
```