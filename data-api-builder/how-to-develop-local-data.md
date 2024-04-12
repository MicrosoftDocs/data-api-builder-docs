---
title: Connect with local data
description: Use the Data API builder with a local Docker-hosted SQL database as part of your typical development process.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/20/2024
#Customer Intent: As a developer, I want to use the Data API builder with my local database, so that I can quickly develop my API before deploying it.
---

# Connect Data API builder with local data

This guide walks through the steps to build a set of Data API builder configuration files to target a local database. Targeting a local development database early makes it possible to iterate over your configuration and schema quickly as part of your development workflow. The end result configuration files should be flexible enough that a production database configuration can be added in the future with minimal changes.

## Prerequisites

- Data API builder command-line interface (CLI)
  - [Install the CLI](how-to-install-cli.md)
- Database on local development machine
  - This guide uses Microsoft SQL Server 2022 running in a Docker Linux container image, but any supported database can be used

## Configure the local database

Start by configuring the local database to set the relevant credentials and create basic tables.

1. Get the latest copy of the `mcr.microsoft.com/mssql/server:2022-latest` container image from Docker Hub.

    ```bash
    docker pull mcr.microsoft.com/mssql/server:2022-latest
    ```

1. Start the docker container by setting the password, accepting the end-user license agreement (EULA), and publishing port **1433**. Replace `<your-password>` with a custom password.

    ```bash
    docker run \
        --env "ACCEPT_EULA=Y" \
        --env "MSSQL_SA_PASSWORD=<your-password>" \
        --publish 1433:1433 \
        --detach \
        mcr.microsoft.com/mssql/server:2022-latest
    ```

1. Connect to your local database using your preferred database development environment. Examples include, but aren't limited to: [SQL Server Management Studio](/sql/ssms), [Azure Data Studio](/azure-data-studio), and the [SQL Server extension for Visual Studio Code](/sql/tools/visual-studio-code/sql-server-develop-use-vscode).

    > [!TIP]
    > If you're using default networking for your Docker Linux container images, the connection string will likely be `Server=localhost,1433;User Id=sa;Password=<your-password>;TrustServerCertificate=True;Encrypt=True;`. Replace `<your-password>` with the password you set earlier.

1. Create a new `bookshelf` database and use the database for your remaining queries.

    ```sql
    DROP DATABASE IF EXISTS bookshelf;
    GO

    CREATE DATABASE bookshelf;
    GO

    USE bookshelf;
    GO
    ```

1. Create a new `dbo.authors` table and seed the table with basic data.

    ```sql
    DROP TABLE IF EXISTS dbo.authors;
    GO

    CREATE TABLE dbo.authors
    (
        id int not null primary key,
        first_name nvarchar(100) not null,
        middle_name  nvarchar(100) null,
        last_name nvarchar(100) not null
    )
    GO

    INSERT INTO dbo.authors VALUES
        (01, 'Henry', null, 'Ross'),
        (02, 'Jacob', 'A.', 'Hancock'),
        (03, 'Sydney', null, 'Mattos'),
        (04, 'Jordan', null, 'Mitchell'),
        (05, 'Victoria', null, 'Burke'),
        (06, 'Vance', null, 'DeLeon'),
        (07, 'Reed', null, 'Flores'),
        (08, 'Felix', null, 'Henderson'),
        (09, 'Avery', null, 'Howard'),
        (10, 'Violet', null, 'Martinez')
    GO
    ```

## Create a base configuration file

Start by creating a baseline configuration file using the DAB CLI.

1. Create a typical configuration file using `dab init`.

    ```dotnetcli
    dab init --database-type "mssql" --host-mode "Development"
    ```

1. Add an Author entity using `dab add`.

    ```dotnetcli
    dab add Author --source "dbo.authors" --permissions "anonymous:*"
    ```

1. Observe your current *dab-config.json* configuration file. The file should include a baseline implementation of your API with a single entity, a REST API endpoint, and a GraphQL endpoint.

    ```json
    {
      "$schema": "<https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json>",
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
          ]
        }
      }
    }
    ```

1. Run the tool with `dab start`.

    ```dotnetcli
    dab start
    ```

    > [!Note]
    > By default, the engine uses the `dab-config.json` file is a `DAB_ENVIRONMENT` environment variable is not set. Alternatively, you can use `dab start --config <specific-config-file>` to force the engine to use a specific configuration file regardless of the `DAB_ENVIRONMENT` environment variable's value.

1. Observe that the engine fails to start because the default configuration file doesn't specify a connection string for the SQL Server database connection.

## Create a development configuration file

Now, create the environment variables file and a delta configuration file for development-only configuration settings.

1. Create an `.env` file in the same directory as your DAB CLI configuration files.

1. Add a `DAB_ENVIRONMENT` environment variable with a value of `Development`. Also, add an `SQL_DOCKER_CONNECTION_STRING` environment variable with your database connection string from the first section. Replace `<your-password>` with the password you set earlier in this guide.

    ```env
    SQL_DOCKER_CONNECTION_STRING=Server=localhost,1433;User Id=sa;Database=bookshelf;Password=<your-password>;TrustServerCertificate=True;Encrypt=True;
    DAB_ENVIRONMENT=Development
    ```

1. Create a `dab-config.Development.json` file. Add the following content to use the `@env()` function to set your [`connection-string`](reference-configuration.md#connection-string) value in the development environment.

    ```json
    {
      "$schema": "<https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json>",
      "data-source": {
        "database-type": "mssql",
        "connection-string": "@env('SQL_DOCKER_CONNECTION_STRING')"
      }
    }
    ```

1. **Save** your changes to the `.env` and `dab-config.Development.json` files.

## Test API with the local database

Now, start the Data API builder tool to validate that your configuration files are merged during development.

1. Use `dab start` to run the tool and create API endpoints for your entity.

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

1. First, try the API manually by issuing a GET request to `/api/Author`.

    > [!TIP]
    > In this example, the URL would be `https://localhost:5000/api/Author`. You can navigate to this URL using your web browser.

1. Next, navigate to the Swagger documentation page at `/swagger`.

    > [!TIP]
    > In this example, the URL would be `<https://localhost:5000/swagger`. Again, you can navigate to this URL using your web browser.

## Related content

- [Command-line interface (CLI) reference](reference-cli.md)
- [Configuration reference](reference-configuration.md)
