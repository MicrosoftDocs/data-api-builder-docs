---
title: Run in a Docker container
description: Use the Docker container image in Microsoft Container Registry to run Data API builder locally or in an Azure hosting service.
author: jerrynixon
ms.author: jnixon
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 05/14/2026
# Customer Intent: As a developer, I want to use the Docker container image, so that I can run Data API builder anywhere in a portable fashion.
---

# Run Data API builder in a Docker container

Data API builder (DAB) is published as a container image to the Microsoft Container Registry. Any Docker host can pull down the container image and run DAB with minimal configuration. This guide uses the container image and a local configuration file to quickly host and run DAB without the need to install any extra tooling.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/)

## Create sample data

For this short guide, a simple table with a few rows of data is sufficient to demonstrate how to use DAB in a Docker container. To simplify things further, we use SQL Server for Linux in a Docker container image.

1. Pull the `mcr.microsoft.com/mssql/server:2022-latest` container image.

    ```bash
    docker pull mcr.microsoft.com/mssql/server:2022-latest
    ```

1. Run the container image publishing the `1433` port and setting the `sa` account password to a unique password that you use throughout this guide.

    ```bash
    docker run \
        --name mssql \
        --publish 1433:1433 \
        --detach \
        --env "ACCEPT_EULA=Y" \
        --env "MSSQL_SA_PASSWORD=<your-password>" \
        mcr.microsoft.com/mssql/server:2022-latest
    ```

    > [!IMPORTANT]
    > This password is a simple fictitious value for this guide. In the real world, you would use a different authentication mechanism and ideally a different account.

1. Connect to the SQL server using your preferred client or tool. The connection string is `Server=localhost,1433;User Id=sa;Password=<your-password>;TrustServerCertificate=true;`.

1. Create a new database named `Library` if it doesn't already exist.

    ```sql
    IF NOT EXISTS(SELECT name FROM sys.databases WHERE name = 'Library')
    BEGIN
        CREATE DATABASE Library;
    END
    GO

    USE Library
    ```

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

## Create configuration file

Create a configuration file that maps to the table created in the previous steps. This configuration file describes to DAB how to map REST and GraphQL endpoints to your actual data.

1. Create a file named `dab-config.json`.

    > [!TIP]
    > This filename is the default for configuration files. By using the default filename, you avoid having to specify the configuration file when running the container.

1. Add this JSON content to your file. This configuration creates a single entity named `book` mapped to the existing `dbo.Books` table.

    ```json
    {
      "$schema": "https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json",
      "data-source": {
        "database-type": "mssql",
        "connection-string": "Server=host.docker.internal\\mssql,1433;Initial Catalog=Library;User Id=sa;Password=<your-password>;TrustServerCertificate=true;"
      },
      "runtime": {
        "rest": {
          "enabled": true
        },
        "graphql": {
          "enabled": true
        }
      },
      "entities": {
        "book": {
          "source": "dbo.Books",
          "permissions": [
            {
              "actions": [
                "read"
              ],
              "role": "anonymous"
            }
          ]
        }
      }
    }
    ```

## Build and run a custom Docker container image

Build a custom image that includes `dab-config.json`, then run the image locally.

1. Create a Dockerfile in the same folder as `dab-config.json`.

    ```dockerfile
    FROM mcr.microsoft.com/azure-databases/data-api-builder:latest
    COPY dab-config.json /App/dab-config.json
    ```


1. Build the image.

    ```bash
    docker build -t dab-local:1 .
    ```

1. Run the container publishing the `5000` port.

    ```bash
    docker run \
      --name dab \
      --publish 5000:5000 \
      --detach \
      dab-local:1
    ```

1. Use a web browser to navigate to `http://localhost:5000/api/book`. The output should be a JSON array of book items from the REST API endpoint.

    ```json
    {
      "value": [
        {
          "id": 1000,
          "title": "Practical Azure SQL Database for Modern Developers",
          "year": 2020,
          "pages": 326
        },
        {
          "id": 1001,
          "title": "SQL Server 2019 Revealed: Including Big Data Clusters and Machine Learning",
          "year": 2019,
          "pages": 444
        },
        {
          "id": 1002,
          "title": "Azure SQL Revealed: A Guide to the Cloud for SQL Server Professionals",
          "year": 2020,
          "pages": 528
        },
        {
          "id": 1003,
          "title": "SQL Server 2022 Revealed: A Hybrid Data Platform Powered by Security, Performance, and Availability",
          "year": 2022,
          "pages": 506
        }
      ]
    }
    ```

    > [!NOTE]
    > This guide uses an HTTP connection. When running a Data API builder container in Docker, you see that only the HTTP endpoint is mapped. If you want your Docker container to support HTTPS for local development, you need to provide your own SSL/TLS certificate and private key files required for SSL/TLS encryption and expose the HTTPS port.
    > A reverse proxy can also be used to enforce that clients connect to your server over HTTPS to ensure that the communication channel is encrypted before forwarding the request to your container.

## Port resolution

Data API builder determines which HTTP port to use for internal operations (health checks, internal HTTP calls) using this precedence:

| Priority | Environment variable | Notes |
|----------|---------------------|-------|
| 1 | `ASPNETCORE_URLS` | Parses the first port from the URL list (for example, `http://*:8080`). |
| 2 | `ASPNETCORE_HTTP_PORTS` | .NET 8+ container variable. Uses the first port specified. |
| 3 | `DEFAULT_PORT` | DAB-specific fallback. Not recognized by .NET or Azure Container Apps. |
| 4 | *(none set)* | Defaults to port `5000`. |

If a variable is set but contains an invalid value, DAB falls through to the next option.

| Scenario | Port used |
|----------|-----------|
| `ASPNETCORE_URLS=http://*:8080` | `8080` |
| `ASPNETCORE_HTTP_PORTS=7071` | `7071` |
| `DEFAULT_PORT=6000` | `6000` |
| No environment variable set | `5000` |

> [!NOTE]
> `DEFAULT_PORT` is a DAB-specific environment variable. .NET, Azure Container Apps, and other hosting platforms don't recognize it. Use it only as a fallback for custom deployment scenarios.

## Platform support

DAB container images are built for x86-64 (amd64) only. ARM64 isn't currently supported.

## Related content

- [Run from source](run-from-source.md)
- [Install the CLI](../command-line/install.md)
- [`mcr.microsoft.com/azure-databases/data-api-builder` on Microsoft Artifact Registry](https://mcr.microsoft.com/artifact/mar/azure-databases/data-api-builder)
