---
title: Use configuration file environments
description: Use environments to change configuration file values depending on whether you are in development or not.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/11/2025
#Customer Intent: As a developer, I want to use environments, so that I can swap between various configuration values.
---

# Use configuration file environments with Data API builder

This guide walks through the steps to target a development environment using a configuration file. The end result configuration files should be flexible enough that a production database configuration can be added in the future with minimal changes.

## Prerequisites

- Existing SQL database.
- Data API builder CLI. [Install the CLI](install-cli.md)

## Create SQL table and data

Create a table with fictitious data to use in this example scenario.

1. Connect to the SQL server and database using your preferred client or tool. Examples include, but aren't limited to: [SQL Server Management Studio](/sql/ssms) and the [SQL Server extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql).

1. Create a table named `Books` with `id` and `name` columns.

    ```sql
    DROP TABLE IF EXISTS dbo.Books;

    CREATE TABLE dbo.Books
    (
        id int NOT NULL PRIMARY KEY,
        title nvarchar(1000) NOT NULL,
        [year] int null,
        [pages] int null
    );
    GO
    ```

1. Insert four sample book rows into the `Books` table.

    ```sql
    INSERT INTO dbo.Books VALUES
        (1000, 'Practical Azure SQL Database for Modern Developers', 2020, 326),
        (1001, 'SQL Server 2019 Revealed: Including Big Data Clusters and Machine Learning', 2019, 444),
        (1002, 'Azure SQL Revealed: A Guide to the Cloud for SQL Server Professionals', 2020, 528),
        (1003, 'SQL Server 2022 Revealed: A Hybrid Data Platform Powered by Security, Performance, and Availability', 2022, 506)
    GO
    ```

1. Test your data with a simple `SELECT *` query.

    ```sql
    SELECT * FROM dbo.Books
    ```

## Create base configuration file

Create a baseline configuration file using the DAB CLI.

1. Create a typical configuration file using `dab init`.

    ```dotnetcli
    dab init --database-type "mssql" --host-mode "Development"
    ```

1. Add an **Book** entity using `dab add`.

    ```dotnetcli
    dab add Book --source "dbo.Books" --permissions "anonymous:*"
    ```

1. Observe your current *dab-config.json* configuration file. The file should include a baseline implementation of your API with a single entity, a REST API endpoint, and a GraphQL endpoint.

    ```json
    {
      "$schema": "https://github.com/Azure/data-api-builder/releases/download/v0.10.23/dab.draft.schema.json",
      "data-source": {
        "database-type": "mssql",
        "connection-string": "",
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
        "Book": {
          "source": {
            "object": "dbo.Books",
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
          ]
        }
      }
    }
    ```

## Create environment variables file

Now, add an environment file to store environment variables for DAB.

1. Create a file named `.env` in the same directory as your DAB CLI configuration files.

> [!NOTE]
> The `.env` filename, like `.gitignore` and `.editorconfig` files has no filename, only a file extension. The name is case insensitive but the convention is lower-case.

1. Add a `DAB_ENVIRONMENT` environment variable with a value of `Development`. Also, add an `SQL_DOCKER_CONNECTION_STRING` environment variable with your database connection string.

    ```env
    SQL_DOCKER_CONNECTION_STRING=<connection-string>
    DAB_ENVIRONMENT=Development
    ```

## Create environment configuration file

Finally, add a development configuration file with the delta between your current configuration and desired environment configuration.

1. Create a `dab-config.Development.json` file. Add the following content to use the `@env()` function to set your [`connection-string`](../reference-configuration.md#connection-string) value in the development environment.

    ```json
    {
      "$schema": "<https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json>",
      "data-source": {
        "database-type": "mssql",
        "connection-string": "@env('SQL_DOCKER_CONNECTION_STRING')"
      }
    }
    ```

1. **Save** your changes to the *.env*, *dab-config.json*, and *dab-config.Development.json* files.

## Test setup

1. Use `dab start` to validate the tool starts as expected.

    ```dotnetcli
    dab start
    ```

1. The output of the tool should include the address to use to navigate to the running API.

    ```output
          Successfully completed runtime initialization.
    info: Microsoft.Hosting.Lifetime[14]
          Now listening on: <http://localhost:5000>
    info: Microsoft.Hosting.Lifetime[0]
    ```

    > [!TIP]
    > In this example, the application is running on `localhost` at port **5000**. Your running application may have a different address and port.

1. First, try the API manually by issuing a GET request to `/api/Book`.

    > [!TIP]
    > In this example, the URL would be `https://localhost:5000/api/Book`. You can navigate to this URL using your web browser.

1. Next, navigate to the Swagger documentation page at `/swagger`.

    > [!TIP]
    > In this example, the URL would be `<https://localhost:5000/swagger`. Again, you can navigate to this URL using your web browser.

1. Finally, try the GraphQL endpoint by navigating to `/graphql` and running this operation.

    ```graphql
    query {
      books(filter: {
        pages: {
          lt: 500
        }
      }) {
        items {
          id
          title
          year
          pages
        }
      }
    }
    ```

    > [!TIP]
    > In this example, the URL would be `https://localhost:5000/graphql`. Again, you can navigate to this URL using your web browser.

## Related content

- [How-to: Add application insights](../deployment/how-to/use-application-insights.md)
- [How-to: Run from a container](run-container.md)
