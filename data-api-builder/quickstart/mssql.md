---
title: |
  Quickstart: Use with SQL
description: Get started quickly using the Data API builder with a local Docker-hosted SQL database.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/11/2025
#Customer Intent: As a developer, I want to use the Data API builder with my local SQL database, so that I can quickly develop my API before deploying it.
---

# Quickstart: Use Data API builder with SQL

In this Quickstart, you build a set of Data API builder configuration files to target a local SQL database.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- [.NET 8](https://dotnet.microsoft.com/download/dotnet/8.0)
- A data management client
  - If you don't have a client installed, [install Azure Data Studio](/azure-data-studio/download-azure-data-studio)

> [!TIP]
> Alternatively, open this Quickstart in GitHub Codespaces with all developer prerequisites already installed. Simply bring your own Azure subscription. GitHub accounts include an entitlement of storage and core hours at no cost. For more information, see [included storage and core hours for GitHub accounts](https://docs.github.com/billing/managing-billing-for-github-codespaces/about-billing-for-github-codespaces#monthly-included-storage-and-core-hours-for-personal-accounts).
>
> [![Open in GitHub Codespaces](https://img.shields.io/badge/Open-Open?style=for-the-badge&label=GitHub+Codespaces&logo=github&labelColor=0078D7&color=303030)](https://codespaces.new/azure-samples/dab-quickstart?template=true&quickstart=1)

## Install the Data API builder CLI

[!INCLUDE[Install CLI](../includes/install-cli.md)]

## Configure the local database

Start by configuring and running the local database to set the relevant credentials. Then, you can seed the database with sample data.

1. Get the latest copy of the `mcr.microsoft.com/mssql/server:2022-latest` container image from Docker Hub.

    ```shell
    docker pull mcr.microsoft.com/mssql/server:2022-latest
    ```

1. Start the docker container by setting the password, accepting the end-user license agreement (EULA), and publishing port **1433**. Replace `<your-password>` with a custom password.

    ```shell
    docker run \
        --env "ACCEPT_EULA=Y" \
        --env "MSSQL_SA_PASSWORD=<your-password>" \
        --publish 1433:1433 \
        --detach \
        mcr.microsoft.com/mssql/server:2022-latest
    ```

1. Connect to your local database using your preferred data management environment. Examples include, but aren't limited to: [SQL Server Management Studio](/sql/ssms) and and the [SQL Server extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-mssql.mssql).

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
        middle_name nvarchar(100) null,
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

## Create configuration files

Create a baseline configuration file using the DAB CLI. Then, add a development configuration file with your current credentials.

1. Create a typical configuration file using `dab init`. Add the `--connection-string` argument with your database connection string from the first section. Replace `<your-password>` with the password you set earlier in this guide. Also, add the `Database=bookshelf` value to the connection string.

    ```dotnetcli
    dab init --database-type "mssql" --host-mode "Development" --connection-string "Server=localhost,1433;User Id=sa;Database=bookshelf;Password=<your-password>;TrustServerCertificate=True;Encrypt=True;"
    ```

1. Add an **Author** entity using `dab add`.

    ```dotnetcli
    dab add Author --source "dbo.authors" --permissions "anonymous:*"
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
> [Quickstart: Deploy Data API builder to Azure](azure-sql.md)
