---
title: Overview Configuration
description: Part of the configuration documentation for Data API builder, focusing on Overview Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

# Configuration file

The Data API Builder configuration file provides a structured and comprehensive approach to setting up your API, detailing everything from environmental variables to entity-specific configurations. This JSON-formatted document begins with a `$schema` property for validation purposes, guiding through various sections including `data-source` which establishes the connection to your backend database. 

By specifying the `database-type` and `connection-string`, it ensures seamless integration with a variety of database systems, from Azure SQL DB to Cosmos DB NoSQL API, making it a cornerstone for developers to customize and leverage the Data API Builder's capabilities efficiently.

## Syntax overview

```json
{
  "$schema": "...",
  "data-source": { ... },
  "runtime": {
    "rest": { ... },
    "graphql": { .. },
    "host": { ... },
    "authentication":{ ... },
    "cache": { ... },
    "telemetry": { ... }
  }
  "entities": { ... }
}
```

## $schema property

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

## [Data-source](/data-api-builder/configuration-file-datasource.md) property

The `data-source` section defines the database and access to the database through the connection string. It also defines db options.

## [Runtime](/data-api-builder/configuration-file-runtime.md) property

The `runtime` section outlines options that influence the runtime behavior and settings for all exposed entities.

## [Entities](/data-api-builder/configuration-file-entities.md) property

The `entities` section serves as the core of the configuration file, establishing a bridge between database objects and their corresponding API endpoints. 