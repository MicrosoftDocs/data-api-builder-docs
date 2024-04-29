---
title: |
  Quickstart: Use with PostgreSQL
description: Get started quickly using the Data API builder with a local Docker-hosted PostgreSQL database.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 04/29/2024
#Customer Intent: As a developer, I want to use the Data API builder with my local PostgreSQL database, so that I can quickly develop my API before deploying it.
---

# Quickstart: Use Data API builder with PostgreSQL

In this Quickstart, you build a set of Data API builder configuration files to target a local PostgreSQL database.

[!INCLUDE[Quickstart overview](includes/quickstart-overview.md)]

## Prerequisites

[!INCLUDE[Quickstart prerequisites](includes/quickstart-prerequisites.md)]

## Install the Data API builder CLI

[!INCLUDE[Install CLI](includes/install-cli.md)]

## Configure the local database

Start by configuring and running the local database. Then, you can seed a new container with sample data.

1. Get the latest copy of the `postgres:16` container image from Docker Hub.

    ```shell
    docker pull postgres:16
    ```

1. Start the docker container by setting the password and publishing port **5432**. Replace `<your-password>` with a custom password.

    ```shell
    docker run \
        --publish 5432:5432 \
        --env "POSTGRES_PASSWORD=<your-password>" \
        --detach \
        postgres:16
    ```

1. Connect to your local database using your preferred data management environment. Examples include, but aren't limited to: [pgAdmin](https://www.pgadmin.org/), [Azure Data Studio](/azure-data-studio), and the [PostgreSQL extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-postgresql).

    > [!TIP]
    > If you're using default networking for your Docker Linux container images, the connection string will likely be `Host=localhost;Port=5432;User ID=postgres;Password=<your-password>;`. Replace `<your-password>` with the password you set earlier.

1. Create a new `bookshelf` database.

    ```sql
    DROP DATABASE IF EXISTS bookshelf;
    
    CREATE DATABASE bookshelf;
    ```

1. Create a new `dbo.authors` table and seed the table with basic data.

    ```sql
    CREATE TABLE IF NOT EXISTS authors
    (
        id INT NOT NULL PRIMARY KEY,
        first_name VARCHAR(100) NOT NULL,
        middle_name VARCHAR(100),
        last_name VARCHAR(100) NOT NULL
    );

    INSERT INTO authors VALUES
        (01, 'Henry', NULL, 'Ross'),
        (02, 'Jacob', 'A.', 'Hancock'),
        (03, 'Sydney', NULL, 'Mattos'),
        (04, 'Jordan', NULL, 'Mitchell'),
        (05, 'Victoria', NULL, 'Burke'),
        (06, 'Vance', NULL, 'DeLeon'),
        (07, 'Reed', NULL, 'Flores'),
        (08, 'Felix', NULL, 'Henderson'),
        (09, 'Avery', NULL, 'Howard'),
        (10, 'Violet', NULL, 'Martinez');
    ```

## Create configuration files

Create a baseline configuration file using the DAB CLI. Then, add a development configuration file with your current credentials.

1. Create a typical configuration file using `dab init`.

    ```dotnetcli
    dab init --database-type "postgresql" --host-mode "Development"
    ```

1. Add an Author entity using `dab add`.

    ```dotnetcli
    dab add Author --source "public.authors" --permissions "anonymous:*"
    ```

1. Observe your current *dab-config.json* configuration file. The file should include a baseline implementation of your API with a single entity, a REST API endpoint, and a GraphQL endpoint.

    ```json
    {
      "$schema": "https://github.com/Azure/data-api-builder/releases/download/v0.10.23/dab.draft.schema.json",
      "data-source": {
        "database-type": "postgresql",
        "connection-string": "",
        "options": {}
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
            "object": "public.authors",
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

1. Create an *.env* file in the same directory as your DAB CLI configuration files.

1. Add a `DAB_ENVIRONMENT` environment variable with a value of `Development`. Also, add an `POSTGRESQL_DOCKER_CONNECTION_STRING` environment variable with your database connection string from the first section. Replace `<your-password>` with the password you set earlier in this guide.

    ```env
    POSTGRESQL_DOCKER_CONNECTION_STRING=Host=localhost;Port=5432;Database=bookshelf;User ID=postgres;Password=<your-password>;
    DAB_ENVIRONMENT=Development
    ```

1. Create a `dab-config.Development.json` file. Add the following content to use the `@env()` function to set your [`connection-string`](reference-configuration.md#connection-string) value in the development environment.

    ```json
    {
      "$schema": "<https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json>",
      "data-source": {
        "database-type": "postgresql",
        "connection-string": "@env('POSTGRESQL_DOCKER_CONNECTION_STRING')"
      }
    }
    ```

1. **Save** your changes to the *.env*, *dab-config.json*, and *dab-config.Development.json* files.

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

## Next step

> [!div class="nextstepaction"]
> [REST endpoints](rest.md)
