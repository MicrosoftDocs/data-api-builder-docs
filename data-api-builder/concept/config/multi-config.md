---
title: Add more than one data source to enable hybrid endpoints
description: Add more than one data source to enable hybrid endpoints
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 07/16/2025
# Customer Intent: As a developer, I want to add multiple data sources, so I can query more than one backend database
---

# Add more than one data source

Data API builder supports hybrid endpoints by using **data source files**, allowing you to define multiple data sources and their entities in separate configuration files.

This approach is useful for scenarios such as:

* You need to expose entities from more than one database
* You want to organize configurations modularly
* You need to manage different data backends independently

## Structure

To define multiple data sources, create multiple configuration files and reference them in the `data-source-files` array of the top-level config.

### Top-level file

```json
{
  "data-source-files": [
    "dab-config-sql.json",
    "dab-config-cosmos.json"
  ],
  "runtime": {
    "rest": {
      "enabled": true
    },
    "graphql": {
      "enabled": true
    },
    "mcp": {
      "enabled": true
    }

  }
}
```

### Child file: dab-config-sql.json

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('SQL_CONNECTION_STRING')"
  },
  "entities": {
    "Book": {
      "source": {
        "object": "dbo.Books"
      },
      "permissions": [
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

### Child file: dab-config-cosmos.json

```json
{
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "connection-string": "@env('COSMOS_CONNECTION_STRING')",
    "options": {
      "database": "library"
    }
  },
  "entities": {
    "LoanRecord": {
      "source": {
        "object": "LoanRecords"
      },
      "permissions": [
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

## Behavior

* Only the top-level file's `runtime` settings are respected
* Every child file must contain both a `data-source` and `entities` section
* Entity names must be globally unique across all files
* Entities defined in separate files **cannot reference each other** via relationships
* Files can be nested in subfolders as needed

## Benefits

* Clean separation of configuration per backend
* Enables scalable multi-database APIs
* Simplifies maintenance for complex systems

## Limitations

* No relationships across configuration files
* Circular file references aren't allowed
* Only the top-level file controls runtime behavior

