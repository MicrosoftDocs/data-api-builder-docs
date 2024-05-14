---
title: Multiple mutations in GraphQL
description: Use multiple mutations in Data API builder to batch related GraphQL mutations together as a single operation.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 05/14/2024
# Customer Intent: As a developer, I want to implement multiple mutations, so that I can rudimentary transactions.
---

# Multiple mutations in GraphQL for Data API builder

Data API builder (DAB) supports combining multiple mutation operations together into a single transition. Multiple mutations supports scenarios where you need to create multiple items belonging to the same entity or create mulitple items belonging to a related entity. This guide walks through a sample scenario using a multiple mutation operation.

## Prerequisites

- Existing SQL server and database.
- Data API builder CLI. [Install the CLI](how-to-install-cli.md)
- A database client (SQL Server Management Studio, Azure Data Studio, etc.)
  - If you don't have a client installed, [install Azure Data Studio](/azure-data-studio/download-azure-data-studio)

## Create tables

Start by creating two basic tables to represent books and their respective chapters. Books will have a **one-to-many** relationship with their corresponding chapters.

1. TODO

1. Create a table named `Books` with `id`, `title`, `year`, and `pages` columns.

    ```sql
    DROP TABLE IF EXISTS dbo.Books;

    CREATE TABLE dbo.Books
    (
        id int NOT NULL PRIMARY KEY,
        title nvarchar(1000) NOT NULL,
        [year] int null,
        [pages] int null
    )
    GO
    ```

1. TODO

    ```sql
    DROP TABLE IF EXISTS dbo.Chapters;
    
    CREATE TABLE dbo.Chapters
    (
        id int NOT NULL PRIMARY KEY,
        [name] nvarchar(1000) NOT NULL,
        [pages] int null,
        book_id int NOT NULL,
        FOREIGN KEY (book_id) REFERENCES dbo.Books(id)
    )
    GO
    ```

1. TODO

## TODO

TODO

1. TODO

1. TODO

    ```bash
    SQL_CONNECTION_STRING="<your-sql-connection-string>"
    ```
  
1. TODO

    ```dotnetcli
    dab init --database-type "mssql" --graphql.multiple-create.enabled true --host-mode "development" --connection-string $SQL_CONNECTION_STRING
    ```
  
1. TODO

    ```dotnetcli
    dab add Book --source "dbo.Books" --permissions "anonymous:*"
    ```
  
1. TODO

    ```dotnetcli
    dab add Chapter --source "dbo.Chapters" --permissions "anonymous:*"  
    ```
  
1. TODO

    ```dotnetcli
    dab update Book --relationship chapters --target.entity Chapter --cardinality many
    ```
  
1. TODO

    ```dotnetcli
    dab update Chapter --relationship book --target.entity Book --cardinality one
    ```
  
1. TODO

    ```dotnetcli
    dab start
    ```

1. TODO  

## TODO

TODO

1. TODO

    ```graphql
    mutation {
      createBook(
        item: {
          id: 1
          title: "Hello World"
          pages: 200
          year: 2024
          chapters: [
            {
                id: 2
                name: "Intro", pages: 150 
            }
            {
                id: 3
                name: "Outro", pages: 50
            }
          ]
        }
      ) {
        id
        title
        pages
        year
        chapters {
          items {
            name
            pages
          }
        }
      }
    }
    ```

1. TODO

    ```json
    {
      "data": {
        "createBook": {
          "id": 1,
          "title": "Hello World",
          "pages": 200,
          "year": 2024,
          "chapters": {
            "items": [
              {
                "name": "Intro",
                "pages": 150
              },
              {
                "name": "Outro",
                "pages": 50
              }
            ]
          }
        }
      }
    }
    ```

1. TODO

    ```graphql
    query {
      books {
        items {
          pages
          title
          year
          chapters {
            items {
              name
              pages
            }
          }
        }
      }
    }
    ```

1. TODO

    ```json
    {
      "data": {
        "books": {
          "items": [
            {
              "pages": 200,
              "title": "Hello World",
              "year": 2024,
              "chapters": {
                "items": [
                  {
                    "name": "Intro",
                    "pages": 150
                  },
                  {
                    "name": "Outro",
                    "pages": 50
                  }
                ]
              }
            }
          ]
        }
      }
    }
    ```

## Related content

- [Relationships](relationships.md)
- [GraphQL](graphql.md)
