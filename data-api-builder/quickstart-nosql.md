---
title: |
  Quickstart: Use with NoSQL
description: Get started quickly using the Data API builder with a local Docker-hosted Azure Cosmos DB for NoSQL instance.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 04/29/2024
#Customer Intent: As a developer, I want to use the Data API builder with my local Azure Cosmos DB for NoSQL instance, so that I can quickly develop my API before deploying it.
---

# Quickstart: Use Data API builder with NoSQL

In this Quickstart, you build a set of Data API builder configuration files to target the Azure Cosmos DB for NoSQL emulator.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- [.NET 6](https://dotnet.microsoft.com/download/dotnet/6.0)
- A data management client
  - If you don't have a client installed, [install Azure Data Studio](/azure-data-studio/download-azure-data-studio)

> [!TIP]
> Alternatively, open this Quickstart in GitHub Codespaces with all developer prerequisites already installed. Simply bring your own Azure subscription. GitHub accounts include an entitlement of storage and core hours at no cost. For more information, see [included storage and core hours for GitHub accounts](https://docs.github.com/billing/managing-billing-for-github-codespaces/about-billing-for-github-codespaces#monthly-included-storage-and-core-hours-for-personal-accounts).
>
> [![Open in GitHub Codespaces](https://img.shields.io/badge/Open-Open?style=for-the-badge&label=GitHub+Codespaces&logo=github&labelColor=0078D7&color=303030)](https://codespaces.new/azure-samples/dab-quickstart?template=true&quickstart=1)

## Install the Data API builder CLI

[!INCLUDE[Install CLI](includes/install-cli.md)]

## Configure the local database

Start by running the local emulator. Then, you can seed a new container with sample data.

1. Get the latest copy of the `mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest` container image from Docker Hub.

    ```shell
    docker pull mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
    ```

1. Start the docker container by publishing port **8081** and the port range **10250-10255**.

    ```shell
    docker run \
        --publish 8081:8081 \
        --publish 10250-10255:10250-10255 \
        --detach \
        mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
    ```

1. Download the self-signed certificate for the emulator

    ```shell
    curl -k https://localhost:8081/_explorer/emulator.pem > ~/emulatorcert.crt
    ```

1. Install the self-signed certificate using either the **Bash** steps for Linux, or the **PowerShell** steps for Windows.

    ```bash
    sudo cp ~/emulatorcert.crt /usr/local/share/ca-certificates/
    sudo update-ca-certificates
    ```

    ```powershell
    certutil -f -addstore "Root" emulatorcert.crt
    ```

1. Connect to your local database using your preferred data management environment. Examples include, but aren't limited to: [Azure Data Studio](/azure-data-studio), and the [Azure Databases extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-cosmosdb).

    > [!TIP]
    > The default connection string for the emulator is `AccountEndpoint=https://localhost:8081;AccountKey=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==;`.

1. Create a new `bookshelf` database and `authors` container.

1. Seed the container with this basic JSON data.

    ```json
    [
      {
        "id": "01",
        "firstName": "Henry",
        "lastName": "Ross"
      },
      {
        "id": "02",
        "firstName": "Jacob",
        "middleName": "A.",
        "lastName": "Hancock"
      },
      {
        "id": "03",
        "firstName": "Sydney",
        "lastName": "Mattos"
      },
      {
        "id": "04",
        "firstName": "Jordan",
        "lastName": "Mitchell"
      },
      {
        "id": "05",
        "firstName": "Victoria",
        "lastName": "Burke"
      },
      {
        "id": "06",
        "firstName": "Vance",
        "lastName": "DeLeon"
      },
      {
        "id": "07",
        "firstName": "Reed",
        "lastName": "Flores"
      },
      {
        "id": "08",
        "firstName": "Felix",
        "lastName": "Henderson"
      },
      {
        "id": "09",
        "firstName": "Avery",
        "lastName": "Howard"
      },
      {
        "id": "10",
        "firstName": "Violet",
        "lastName": "Martinez"
      }
    ]
    ```

    > [!TIP]
    > The method used to seed data will largely depend on the data management tool. For Azure Data Studio, you can save this JSON array as a *.json* file and then use the **Import** feature.

## Create configuration files

Create a baseline configuration file using the DAB CLI. Then, add a development configuration file with your current credentials.

1. Create a new file named *schema.graphql* with this schema content.

    ```graphql
    type Author @model {
      id: ID!
      firstName: String!
      middleName: String
      lastName: String!
    }
    ```

1. Create a typical configuration file using `dab init`. Add the `--connection-string` argument with the emulator's default connection string.

    ```dotnetcli
    dab init --database-type "cosmosdb_nosql" --host-mode "Development" --cosmosdb_nosql-database bookshelf --graphql-schema schema.graphql --connection-string "AccountEndpoint=https://localhost:8081;AccountKey=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==;"
    ```

1. Add an **Author** entity using `dab add`.

    ```dotnetcli
    dab add Author --source "authors" --permissions "anonymous:*"
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

1. Go to the GraphQL endpoint by navigating to `/graphql` and running this operation.

    ```graphql
    query {
      authors {
        items {
          id
          firstName
          lastName
        }
      }
    }
    ```

    > [!TIP]
    > In this example, the URL would be `https://localhost:5000/graphql`. You can navigate to this URL using your web browser.

## Next step

> [!div class="nextstepaction"]
> [Quickstart: Deploy Data API builder to Azure](quickstart-azure-cosmos-db-nosql.md)
