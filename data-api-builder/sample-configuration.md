---
title: Sample configuration
description: Sample configuration for an Azure SQL using Azure Static Web Apps as the host and multiple common options.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/20/2024
---

# Sample Data API builder configuration

This sample configuration illustrated an end-to-end scenario. This scenario uses Azure SQL Database as the backing database and Azure Static Web Apps as the host.

This sample is derived from the tables and data provided in [Library sample SQL script](https://github.com/Azure/data-api-builder/blob/main/samples/getting-started/azure-sql-db/library.azure-sql.sql).

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/download/v0.10.23/dab.draft.schema.json",
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('AZURE_SQL_CONNECTION_STRING')",
    "options": {
      "set-session-context": false
    }
  },
  "runtime": {
    "rest": {
      "enabled": true,
      "path": "/api",
      "request-body-strict": true
    },
    "graphql": {
      "enabled": true,
      "path": "/graphql",
      "allow-introspection": true
    },
    "host": {
      "cors": {
        "origins": [],
        "allow-credentials": false
      },
      "authentication": {
        "provider": "StaticWebApps"
      },
      "mode": "development"
    }
  },
  "entities": {
    "Author": {
      "source": {
        "object": "dbo.authors",
        "type": "table"
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "Author",
          "plural": "Authors"
        }
      },
      "rest": {
        "enabled": true
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "*"
            }
          ]
        }
      ],
      "relationships": {
        "books": {
          "cardinality": "many",
          "target.entity": "Book",
          "source.fields": [],
          "target.fields": [],
          "linking.object": "dbo.books_authors",
          "linking.source.fields": [],
          "linking.target.fields": []
        }
      }
    },
    "Book": {
      "source": {
        "object": "dbo.books",
        "type": "table"
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "Book",
          "plural": "Books"
        }
      },
      "rest": {
        "enabled": true
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "*"
            }
          ]
        }
      ],
      "relationships": {
        "authors": {
          "cardinality": "many",
          "target.entity": "Author",
          "source.fields": [],
          "target.fields": [],
          "linking.object": "dbo.books_authors",
          "linking.source.fields": [],
          "linking.target.fields": []
        }
      }
    }
  }
}
```

## Related content

- [Functions reference](reference-functions.md)
- [Command-line interface (CLI) reference](reference-cli.md)

## Next step

> [!div class="nextstepaction"]
> [Configuration reference](reference-configuration.md)
