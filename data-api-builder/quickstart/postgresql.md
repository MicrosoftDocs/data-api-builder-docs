---
title: |
  Quickstart: Use with PostgreSQL
description: Get started quickly using the Data API builder with a local Docker-hosted PostgreSQL database.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/11/2025
#Customer Intent: As a developer, I want to use the Data API builder with my local PostgreSQL database, so that I can quickly develop my API before deploying it.
---

# Quickstart: Use Data API builder with PostgreSQL

In this Quickstart, you build a set of Data API builder configuration files to target a local PostgreSQL database.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- [.NET 8](https://dotnet.microsoft.com/download/dotnet/8.0)

> [!TIP]
> Alternatively, open this Quickstart in GitHub Codespaces with all developer prerequisites already installed. Simply bring your own Azure subscription. GitHub accounts include an entitlement of storage and core hours at no cost. For more information, see [included storage and core hours for GitHub accounts](https://docs.github.com/billing/managing-billing-for-github-codespaces/about-billing-for-github-codespaces#monthly-included-storage-and-core-hours-for-personal-accounts).
>
> [![Open in GitHub Codespaces](https://img.shields.io/badge/Open-Open?style=for-the-badge&label=GitHub+Codespaces&logo=github&labelColor=0078D7&color=303030)](https://codespaces.new/azure-samples/dab-quickstart?template=true&quickstart=1)

## Install the Data API builder CLI

[!INCLUDE[Install CLI](../includes/install-cli.md)]

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

1. Connect to your local database using your preferred data management environment. Examples include, but aren't limited to: [pgAdmin](https://www.pgadmin.org/) and the [PostgreSQL extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-postgresql).

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

1. Create a typical configuration file using `dab init`. Add the `--connection-string` argument with your database connection string from the first section. Replace `<your-password>` with the password you set earlier in this guide. Also, add the `Database=bookshelf` value to the connection string.

    ```dotnetcli
    dab init --database-type "postgresql" --host-mode "Development" --connection-string "Host=localhost;Port=5432;Database=bookshelf;User ID=postgres;Password=<your-password>;"
    ```

1. Add an **Author** entity using `dab add`.

    ```dotnetcli
    dab add Author --source "public.authors" --permissions "anonymous:*"
    ```

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
    > In this example, the URL would be `https://localhost:5000/swagger`. Again, you can navigate to this URL using your web browser.

## Next step

> [!div class="nextstepaction"]
> [REST endpoints](../concepts/rest.md)
