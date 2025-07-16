---
title: |
  Quickstart: Use with MySQL
description: Get started quickly using the Data API builder with a local Docker-hosted MySQL database.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/11/2025
#Customer Intent: As a developer, I want to use the Data API builder with my local MySQL database, so that I can quickly develop my API before deploying it.
---

# Quickstart: Use Data API builder with MySQL

In this Quickstart, you build a set of Data API builder configuration files to target a local MySQL database.

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

1. Get the latest copy of the `mysql:8` container image from Docker Hub.

    ```shell
    docker pull mysql:8
    ```

1. Start the docker container by setting the password and publishing port **3306**. Replace `<your-password>` with a custom password.

    ```shell
    docker run \
        --publish 3306:3306 \
        --env "MYSQL_ROOT_PASSWORD=<your-password>" \
        --detach \
        mysql:8
    ```

1. Connect to your local database using your preferred data management environment. Examples include, but aren't limited to: [MySQL Workbench](https://www.mysql.com/products/workbench/) and the [MySQL shell for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=Oracle.mysql-shell-for-vs-code).

    > [!TIP]
    > If you're using default networking for your Docker Linux container images, the connection string will likely be `Server=localhost;Port=3306;Uid=root;Pwd=<your-password>;`. Replace `<your-password>` with the password you set earlier.

1. Create a new `bookshelf` database and use the database for your remaining queries.

    ```sql
    CREATE DATABASE IF NOT EXISTS bookshelf;

    USE bookshelf;
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
    dab init --database-type "mysql" --host-mode "Development" --connection-string "Server=localhost;Port=3306;Database=bookshelf;Uid=root;Pwd=<your-password>;"
    ```

1. Add an **Author** entity using `dab add`.

    ```dotnetcli
    dab add Author --source "authors" --permissions "anonymous:*"
    ```

1. Observe your current *dab-config.json* configuration file. The file should include a baseline implementation of your API with a single entity, a REST API endpoint, and a GraphQL endpoint.

    ```json
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
