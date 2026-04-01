---
title: |
  Quickstart: Use Data API builder with NoSQL
description: Get started quickly using Data API builder with the Azure Cosmos DB for NoSQL emulator.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 03/29/2026
#Customer Intent: As a developer, I want to use Data API builder with my local Cosmos DB emulator so I can quickly develop my API before deploying it.
---

# Quickstart: Use Data API builder with NoSQL

In this quickstart, you create GraphQL endpoints for a local Azure Cosmos DB for NoSQL emulator using Data API builder (DAB).

> [!NOTE]
> Azure Cosmos DB for NoSQL in Data API builder supports **GraphQL endpoints only**. REST endpoints aren't available for this database type.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)
- [.NET 8](https://dotnet.microsoft.com/download/dotnet/8.0)

## Install the Data API builder CLI

[!INCLUDE[Install CLI](../includes/install-cli.md)]

## Pull the emulator image

Download the Azure Cosmos DB for NoSQL emulator image. This download can take a few minutes because the emulator image is large.

```shell
docker pull mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
```

## Start the emulator

Run the Cosmos DB emulator in Docker. The `AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE` setting is required so the emulator advertises `127.0.0.1` for its network endpoints, making them reachable from your host machine.

```shell
docker run --name dab-cosmos --publish 8081:8081 --publish 10250-10255:10250-10255 --env AZURE_COSMOS_EMULATOR_IP_ADDRESS_OVERRIDE=127.0.0.1 --detach mcr.microsoft.com/cosmosdb/linux/azure-cosmos-emulator:latest
```

> [!NOTE]
> The emulator starts 11 internal partitions and can take **30 to 60 seconds** to become ready. You can verify it's running by opening `https://localhost:8081/_explorer/index.html` in your browser. Your browser may warn about the self-signed certificate—it's safe to proceed.

## Install the emulator certificate

The Cosmos DB emulator uses a self-signed SSL certificate. Download and trust this certificate so Data API builder can connect to the emulator.

# [Linux](#tab/linux)

```bash
curl -k https://localhost:8081/_explorer/emulator.pem > ~/emulatorcert.crt
sudo cp ~/emulatorcert.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

# [macOS](#tab/macos)

```bash
curl -k https://localhost:8081/_explorer/emulator.pem > ~/emulatorcert.crt
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ~/emulatorcert.crt
```

# [Windows](#tab/windows)

```powershell
curl.exe -k https://localhost:8081/_explorer/emulator.pem -o "$env:USERPROFILE\emulatorcert.crt"
Import-Certificate -CertStoreLocation "Cert:\CurrentUser\Root" -FilePath "$env:USERPROFILE\emulatorcert.crt"
```

> [!NOTE]
> Windows displays a security dialog asking whether to trust the certificate. Select **Yes** to continue.

---

## Create the database and seed data

Use the emulator's built-in Data Explorer to create a database, a container, and sample items. No extra tools are needed—the Data Explorer runs in your browser as part of the emulator.

1. Open the Data Explorer at `https://localhost:8081/_explorer/index.html`.

1. Select **New Database**. Enter **todos** as the database id and select **OK**.

1. Expand the **todos** database, select the ellipsis (**...**) menu, and choose **New Container**. Enter **todos** as the container id and **/id** as the partition key, then select **OK**.

1. Expand the **todos** container and select **Items**. Then select **New Item**, replace the default JSON with the following content, and select **Save**. Repeat for each item.

    **Item 1:**

    ```json
    {
      "id": "1",
      "title": "Walk the dog",
      "completed": false
    }
    ```

    **Item 2:**

    ```json
    {
      "id": "2",
      "title": "Feed the fish",
      "completed": false
    }
    ```

    **Item 3:**

    ```json
    {
      "id": "3",
      "title": "Comb the cat",
      "completed": true
    }
    ```

## Create a GraphQL schema file

Azure Cosmos DB for NoSQL requires a GraphQL schema file. Create a file named `schema.gql` with the following content.

```graphql
type Todo @model {
  id: ID!
  title: String!
  completed: Boolean!
}
```

## Configure Data API builder

1. Initialize the configuration with the emulator's default connection string.

    ```dotnetcli
    dab init --database-type "cosmosdb_nosql" --host-mode "Development" --cosmosdb_nosql-database todos --graphql-schema schema.gql --connection-string "AccountEndpoint=https://localhost:8081/;AccountKey=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw=="
    ```

1. Add the **Todo** entity.

    ```dotnetcli
    dab add Todo --source "todos" --permissions "anonymous:*"
    ```

Your `dab-config.json` file should now look similar to the following example:

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json",
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "connection-string": "AccountEndpoint=https://localhost:8081/;AccountKey=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==",
    "options": {
      "database": "todos",
      "schema": "schema.gql"
    }
  },
  "runtime": {
    "graphql": {
      "enabled": true
    },
    "host": {
      "mode": "development"
    }
  },
  "entities": {
    "Todo": {
      "source": {
        "object": "todos",
        "type": "table"
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            "*"
          ]
        }
      ]
    }
  }
}
```

> [!TIP]
> You can skip the `dab init` and `dab add` commands and create the `dab-config.json` and `schema.gql` files directly with the content shown here.

## Start the API

Use `dab start` to run the tool and create API endpoints for your entity.

```dotnetcli
dab start
```

The output should include the address of the running API.

```output
      Successfully completed runtime initialization.
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: <http://localhost:5000>
```

> [!TIP]
> In this example, the application is running on `localhost` at port **5000**. Your running application may have a different address and port.

## Test the API

1. Open your browser and navigate to the GraphQL endpoint.

    ```text
    http://localhost:5000/graphql
    ```

    In Development mode, this URL opens the **Nitro** GraphQL IDE.

1. Create a new document and run the following query to retrieve all todo items.

    ```graphql
    query {
      todos {
        items {
          id
          title
          completed
        }
      }
    }
    ```

1. The response should include all three todo items.

    ```json
    {
      "data": {
        "todos": {
          "items": [
            { "id": "1", "title": "Walk the dog", "completed": false },
            { "id": "2", "title": "Feed the fish", "completed": false },
            { "id": "3", "title": "Comb the cat", "completed": true }
          ]
        }
      }
    }
    ```

## Clean up

Stop and remove the Docker container when you're done.

```shell
docker stop dab-cosmos && docker rm dab-cosmos
```

## Next step

> [!div class="nextstepaction"]
> [GraphQL endpoints](../concept/graphql/overview.md)

## Related content

- [Set up Data API builder for Azure Cosmos DB for NoSQL](../concept/database/set-up-cosmosdb.md)
- [Feature availability for Data API builder](../feature-availability.md)
