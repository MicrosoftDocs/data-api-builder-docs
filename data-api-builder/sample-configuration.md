---
title: Sample configuration
description: Sample configuration for an Azure SQL using Azure Static Web Apps as the host and multiple common options.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 06/11/2025
---

# Sample Data API builder configuration

This sample configuration illustrated an end-to-end scenario. This scenario uses Azure SQL Database as the backing database and Azure Static Web Apps as the host.

This sample is derived from the tables and data provided in [Library sample SQL script](https://github.com/Azure/data-api-builder/blob/main/samples/getting-started/azure-sql-db/library.azure-sql.sql).

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/download/v0.10.23/dab.draft.schema.json",
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('my-connection-string')",
    "options": {
      "set-session-context": false
    }
  },
  "runtime": {
    "rest": {
      "enabled": true,
      "path": "/api",
      "request-body-strict": false
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
    "authors": {
      "source": {
        "object": "[dbo].[authors]",
        "type": "table",
        "key-fields": [ "id" ]
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "authors",
          "plural": "authors"
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
              "action": "*",
              "fields": {
                "exclude": [ "middle_name" ],
                "include": [
                  "id",
                  "first_name",
                  "last_name"
                ]
              }
            }
          ]
        }
      ],
      "mappings": { "id": "key" },
      "relationships": {
        "books": {
          "cardinality": "many",
          "target.entity": "books",
          "source.fields": [],
          "target.fields": [],
          "linking.object": "dbo.books_authors",
          "linking.source.fields": [ "author_id" ],
          "linking.target.fields": [ "book_id" ]
        }
      }
    },
    "series": {
      "source": {
        "object": "[dbo].[series]",
        "type": "table",
        "key-fields": [ "id" ]
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "series",
          "plural": "series"
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
          "target.entity": "books",
          "source.fields": [ "id" ],
          "target.fields": [ "series_id" ],
          "linking.source.fields": [],
          "linking.target.fields": []
        }
      }
    },
    "books": {
      "source": {
        "object": "[dbo].[books]",
        "type": "table",
        "key-fields": [ "id" ]
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "books",
          "plural": "books"
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
        "series": {
          "cardinality": "one",
          "target.entity": "series",
          "source.fields": [ "series_id" ],
          "target.fields": [ "id" ],
          "linking.source.fields": [],
          "linking.target.fields": []
        },
        "authors": {
          "cardinality": "many",
          "target.entity": "authors",
          "source.fields": [],
          "target.fields": [],
          "linking.object": "dbo.books_authors",
          "linking.source.fields": [ "book_id" ],
          "linking.target.fields": [ "author_id" ]
        }
      }
    },
    "books_authors": {
      "source": {
        "object": "[dbo].[books_authors]",
        "type": "table",
        "key-fields": [
          "book_id",
          "author_id"
        ]
      },
      "graphql": {
        "enabled": false,
        "type": {
          "singular": "books_authors",
          "plural": "books_authors"
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
      ]
    }
  }
}
```

## Related content

- [Functions reference](reference-functions.md)
- [Command-line interface (CLI) reference](reference-command-line-interface.md)
- [Configuration reference](./configuration/index.md)
