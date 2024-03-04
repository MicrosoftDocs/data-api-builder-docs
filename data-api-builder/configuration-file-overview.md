---
title: Overview Configuration
description: Part of the configuration documentation for Data API builder, focusing on Overview Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

# Configuration File Overview

The Data API builder configuration file is in JSON format. 

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

#### Latest version
The latest version of the schema is always available [here](https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json). 

```https
https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json
```

## data-source

The `data-source` section outlines backend database connectivity, specifying both the `database-type` and `connection-string`.

```json
{
  "$schema": "...",
  "data-source": {
    "database-type": "...",
    "connection-string": "..."
  }
}
```

### database-type

+ `mssql`: Azure SQL DB, Azure SQL MI and SQL Server
+ `postgresql`: PostgreSQL
+ `mysql`: MySQL
+ `cosmosdb_nosql`: Cosmos DB NoSQL API
+ `cosmosdb_postgresql`: Cosmos DB PostgreSQL API

### database-type

The ADO.NET connection string that Data API builder uses to connect to the backend database. [Learn more](/dotnet/framework/data/adonet/connection-strings)
