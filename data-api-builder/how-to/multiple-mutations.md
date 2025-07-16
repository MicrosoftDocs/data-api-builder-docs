---
title: Multiple mutations in GraphQL
description: Use multiple mutations in Data API builder to batch related GraphQL mutations together as a single operation.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 06/11/2025
# Customer Intent: As a developer, I want to implement multiple mutations, so that I can rudimentary transactions.
---

# Multiple mutations in GraphQL for Data API builder

Data API builder (DAB) supports combining multiple mutation operations together into a single transaction. Multiple mutations support scenarios where you need to create multiple items belonging to the same entity or create multiple items belonging to a related entity. This guide walks through a sample scenario using a multiple mutation operation.

## Prerequisites

- Existing SQL server and database.
- Data API builder CLI. [Install the CLI](install-cli.md)
- A database client (SQL Server Management Studio, Azure Data Studio, etc.)
  - If you don't have a client installed, [install Azure Data Studio](/azure-data-studio/download-azure-data-studio)

## Create tables

Start by creating two basic tables to represent books and their respective chapters. Books have a **one-to-many** relationship with their corresponding chapters.

1. Connect to the SQL database using your preferred client or tool.

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

1. Create another table named `Chapters` with `id`, `name`, and `pages` columns. Create a `book_id` column with a **foreign key** relationship to the `id` column of the `Books` table.

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

1. Validate that your tables are created with some common SQL queries.

    ```sql
    SELECT * FROM dbo.Books
    ```
  
    ```sql
    SELECT * FROM dbo.Chapters
    ```

    > [!NOTE]
    > At this point, the queries should not return any data.

## Build configuration file

Now, use the DAB CLI to create a configuration file, entities, and entity relationships.

1. Open a terminal

1. Store your SQL database connection string as a shell variable named `SQL_CONNECTION_STRING`.

    ```bash
    SQL_CONNECTION_STRING="<your-sql-connection-string>"
    ```

    ```powershell
    $SQL_CONNECTION_STRING="<your-sql-connection-string>"
    ```
  
1. Run [`dab init`](../reference-command-line-interface.md#init) specifying the following properties.

    | | Value |
    | --- | --- |
    | **`database-type`** | `mssql` |
    | **`graphql.multiple-create.enabled`** | `true` |
    | **`host-mode`** | `development` |
    | **`connection-string`** | *Use the `SQL_CONNECTION_STRING` shell variable created in the previous step.* |

    ```dotnetcli
    dab init --database-type "mssql" --graphql.multiple-create.enabled true --host-mode "development" --connection-string $SQL_CONNECTION_STRING
    ```
  
1. Run [`dab add`](../reference-command-line-interface.md#add) to add a **Book** entity specifying the following properties.

    | | Value |
    | --- | --- |
    | **`source`** | `dbo.Books` |
    | **`permissions`** | `anonymous:*` |

    ```dotnetcli
    dab add Book --source "dbo.Books" --permissions "anonymous:*"
    ```
  
1. Run `dab add` again to add a **Chapter** entity now specifying the following properties.

    | | Value |
    | --- | --- |
    | **`source`** | `dbo.Chapters` |
    | **`permissions`** | `anonymous:*` |

    ```dotnetcli
    dab add Chapter --source "dbo.Chapters" --permissions "anonymous:*"  
    ```
  
1. Run [`dab update`](../reference-command-line-interface.md#update) to create the **Book to Chapter** relationship specifying the following properties.

    | | Value |
    | --- | --- |
    | **`relationship`** | `chapters` |
    | **`cardinality`** | `many` |

    ```dotnetcli
    dab update Book --relationship chapters --target.entity Chapter --cardinality many
    ```
  
1. Finally, run `dab update` one last time to create the **Chapter to Book** relationship specifying the following properties.

    | | Value |
    | --- | --- |
    | **`relationship`** | `book` |
    | **`cardinality`** | `one` |

    ```dotnetcli
    dab update Chapter --relationship book --target.entity Book --cardinality one
    ```

## Execute multiple create mutation

To wrap up things, use the DAB CLI to run the API and test the GraphQL endpoint using [Banana Cake Pop](https://chillicream.com/products/bananacakepop).
  
1. Start the runtime engine using the current configuration.

    ```dotnetcli
    dab start
    ```

1. Navigate to the `/graphql` relative endpoint for your running application. This endpoint opens the Banana Cake Pop interface.

    > [!NOTE]
    > By default, this would be `https://localhost:5001/graphql`.

1. Author a GraphQL mutation to create three distinct rows across two tables in your database. This mutation uses both the `Book` and `Chapter` entities in a single "multiple create" operation. Use the following properties for the mutation.

    | Entity type | ID | Name | Pages | Year |
    | --- | --- | --- | --- | --- |
    | Book | 1 | Introduction to Data API builder | 200 | 2024 |
    | Chapter | 2 | Configuration files | 150 | |
    | Chapter | 3 | Running | 50 | |

    ```graphql
    mutation {
      createBook(
        item: {
          id: 1
          title: "Introduction to Data API builder"
          pages: 200
          year: 2024
          chapters: [
            {
                id: 2
                name: "Configuration files", pages: 150 
            }
            {
                id: 3
                name: "Running", pages: 50
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

1. Observe the output from the mutation. The mutation created related data for both entity types.

    ```json
    {
      "data": {
        "createBook": {
          "id": 1,
          "title": "Introduction to Data API builder",
          "pages": 200,
          "year": 2024,
          "chapters": {
            "items": [
              {
                "name": "Configuration files",
                "pages": 150
              },
              {
                "name": "Running",
                "pages": 50
              }
            ]
          }
        }
      }
    }
    ```

1. Use a GraphQL query to retrieve all books in your database including their related chapters.

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

    > [!NOTE]
    > At this point, the query should return the single book with two chapters.

1. Observe the output from this query with an array of books including their nested array of chapters.

    ```json
    {
      "data": {
        "books": {
          "items": [
            {
              "pages": 200,
              "title": "Introduction to Data API builder",
              "year": 2024,
              "chapters": {
                "items": [
                  {
                    "name": "Configuration files",
                    "pages": 150
                  },
                  {
                    "name": "Running",
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

1. Connect to the SQL database again using your preferred client or tool.

1. Validate that your data was successfully created using a SQL query.

    ```sql
    SELECT 
        c.name AS chapterName,
        c.pages AS chapterPages,
        b.title AS bookName,
        b.year AS releaseYear
    FROM dbo.Chapters c
    LEFT JOIN dbo.Books b ON b.id = c.book_id
    ```

    > [!NOTE]
    > This query should return two chapter records.

## Related content

- [Relationships](../concept/relationships.md)
- [GraphQL](../concept/graphql.md)
