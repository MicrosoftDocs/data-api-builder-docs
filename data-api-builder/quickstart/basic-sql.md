---
title: |
  Quickstart: Use Data API builder with SQL
description: Get started quickly using Data API builder with a local Docker-hosted SQL database.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 03/29/2026
#Customer Intent: As a developer, I want to use Data API builder with my local SQL database so I can quickly develop my API before deploying it.
---

# Quickstart: Use Data API builder with SQL

In this quickstart, you create REST and GraphQL endpoints for a local SQL database using Data API builder (DAB). Choose your database engine to get started.

## Prerequisites

- [Docker](https://www.docker.com/products/docker-desktop/) *(optional if you already have a database)*
- [.NET 8 (or newer)](https://dotnet.microsoft.com/download/dotnet/8.0)

## Install the Data API builder CLI

[!INCLUDE[Install CLI](../includes/install-cli.md)]

## Pull the database image

> [!TIP]
> **Already have a database?** Skip to [Create and seed the database](#create-and-seed-the-database), run the SQL script for your engine, then jump to [Configure Data API builder](#configure-data-api-builder) with your own connection string.

Download the Docker image for your database engine. This step can take a few minutes depending on your connection speed.

# [SQL Server](#tab/mssql)

```shell
docker pull mcr.microsoft.com/mssql/server:2025-latest
```

# [PostgreSQL](#tab/postgresql)

```shell
docker pull postgres:16
```

# [MySQL](#tab/mysql)

```shell
docker pull mysql:8
```

---

## Start the database

Run a local database instance in Docker.

# [SQL Server](#tab/mssql)

```shell
docker run --name dab-mssql --env "ACCEPT_EULA=Y" --env "MSSQL_SA_PASSWORD=P@ssw0rd1" --publish 1433:1433 --detach mcr.microsoft.com/mssql/server:2025-latest
```

> [!TIP]
> If port `1433` is already in use (for example, by a local SQL Server installation), change `--publish` to a different host port like `1434:1433` and update `Server=localhost,1433` to `Server=localhost,1434` in later steps.

Verify the database engine is ready before running the next command.

```shell
docker exec dab-mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "P@ssw0rd1" -C -Q "SELECT 1"
```

If this returns an error, wait a few seconds and try again.

# [PostgreSQL](#tab/postgresql)

```shell
docker run --name dab-postgres --env "POSTGRES_PASSWORD=P@ssw0rd1" --publish 5432:5432 --detach postgres:16
```

# [MySQL](#tab/mysql)

```shell
docker run --name dab-mysql --env "MYSQL_ROOT_PASSWORD=P@ssw0rd1" --publish 3306:3306 --detach mysql:8
```

Verify the database engine is ready before running the next command.

```shell
docker exec dab-mysql mysql -uroot -pP@ssw0rd1 -e "SELECT 1"
```

If this returns an error, wait a few seconds and try again.

---

## Create and seed the database

Create a `todos` database and table, then add sample data. If you're using Docker, no SQL client is needed—`docker exec` runs the commands directly inside the container. If you're using your own database, run the SQL script in your preferred tool.

# [SQL Server](#tab/mssql)

1. Create the database.

    ```shell
    docker exec dab-mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "P@ssw0rd1" -C -Q "CREATE DATABASE todos;"
    ```

1. Create the table and add sample data.

    ```shell
    docker exec dab-mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "P@ssw0rd1" -C -d todos -Q "CREATE TABLE dbo.todos (id int PRIMARY KEY, title nvarchar(100) NOT NULL, completed bit NOT NULL DEFAULT 0); INSERT INTO dbo.todos VALUES (1, 'Walk the dog', 0), (2, 'Feed the fish', 0), (3, 'Comb the cat', 1);"
    ```

> [!TIP]
> **Using your own SQL Server?** Run this script directly:
>
> ```sql
> CREATE DATABASE todos;
> GO
> USE todos;
> GO
> CREATE TABLE dbo.todos (id int PRIMARY KEY, title nvarchar(100) NOT NULL, completed bit NOT NULL DEFAULT 0);
> INSERT INTO dbo.todos VALUES (1, 'Walk the dog', 0), (2, 'Feed the fish', 0), (3, 'Comb the cat', 1);
> ```

# [PostgreSQL](#tab/postgresql)

1. Create the database.

    ```shell
    docker exec dab-postgres psql -U postgres -c "CREATE DATABASE todos;"
    ```

1. Create the table and add sample data.

    ```shell
    docker exec dab-postgres psql -U postgres -d todos -c "CREATE TABLE todos (id int PRIMARY KEY, title varchar(100) NOT NULL, completed boolean NOT NULL DEFAULT false); INSERT INTO todos VALUES (1, 'Walk the dog', false), (2, 'Feed the fish', false), (3, 'Comb the cat', true);"
    ```

> [!TIP]
> **Using your own PostgreSQL server?** Run this script directly:
>
> ```sql
> CREATE DATABASE todos;
> \c todos
> CREATE TABLE todos (id int PRIMARY KEY, title varchar(100) NOT NULL, completed boolean NOT NULL DEFAULT false);
> INSERT INTO todos VALUES (1, 'Walk the dog', false), (2, 'Feed the fish', false), (3, 'Comb the cat', true);
> ```

# [MySQL](#tab/mysql)

1. Create the database.

    ```shell
    docker exec dab-mysql mysql -uroot -pP@ssw0rd1 -e "CREATE DATABASE todos;"
    ```

1. Create the table and add sample data.

    ```shell
    docker exec dab-mysql mysql -uroot -pP@ssw0rd1 -e "USE todos; CREATE TABLE todos (id int PRIMARY KEY, title varchar(100) NOT NULL, completed bool NOT NULL DEFAULT false); INSERT INTO todos VALUES (1, 'Walk the dog', false), (2, 'Feed the fish', false), (3, 'Comb the cat', true);"
    ```

> [!TIP]
> **Using your own MySQL server?** Run this script directly:
>
> ```sql
> CREATE DATABASE todos;
> USE todos;
> CREATE TABLE todos (id int PRIMARY KEY, title varchar(100) NOT NULL, completed bool NOT NULL DEFAULT false);
> INSERT INTO todos VALUES (1, 'Walk the dog', false), (2, 'Feed the fish', false), (3, 'Comb the cat', true);
> ```

---

## Configure Data API builder

Create a DAB configuration file and add a **Todo** entity.

> [!TIP]
> **Using your own database?** Replace the connection string in `dab init` with your own:
>
> - **SQL Server:** `Server=<host>,<port>;Database=todos;User Id=<user>;Password=<password>;TrustServerCertificate=true;Encrypt=true;`
> - **PostgreSQL:** `Host=<host>;Port=5432;Database=todos;User ID=<user>;Password=<password>;`
> - **MySQL:** `Server=<host>;Port=3306;Database=todos;User=<user>;Password=<password>;`

# [SQL Server](#tab/mssql)

1. Initialize the configuration.

    ```dotnetcli
    dab init --database-type "mssql" --host-mode "Development" --connection-string "Server=localhost,1433;Database=todos;User Id=sa;Password=P@ssw0rd1;TrustServerCertificate=true;Encrypt=true;"
    ```

1. Add the **Todo** entity.

    ```dotnetcli
    dab add Todo --source "dbo.todos" --permissions "anonymous:*"
    ```

# [PostgreSQL](#tab/postgresql)

1. Initialize the configuration.

    ```dotnetcli
    dab init --database-type "postgresql" --host-mode "Development" --connection-string "Host=localhost;Port=5432;Database=todos;User ID=postgres;Password=P@ssw0rd1;"
    ```

1. Add the **Todo** entity.

    ```dotnetcli
    dab add Todo --source "public.todos" --permissions "anonymous:*"
    ```

# [MySQL](#tab/mysql)

1. Initialize the configuration.

    ```dotnetcli
    dab init --database-type "mysql" --host-mode "Development" --connection-string "Server=localhost;Port=3306;Database=todos;User=root;Password=P@ssw0rd1;"
    ```

1. Add the **Todo** entity.

    ```dotnetcli
    dab add Todo --source "todos" --permissions "anonymous:*"
    ```

---

Your `dab-config.json` file should now look similar to the following example:

# [SQL Server](#tab/mssql)

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/download/vmajor.minor.patch/dab.draft.schema.json",
  "data-source": {
    "database-type": "mssql",
    "connection-string": "Server=localhost,1433;Database=todos;User Id=sa;Password=P@ssw0rd1;TrustServerCertificate=true;Encrypt=true;"
  },
  "runtime": {
    "rest": {
      "enabled": true
    },
    "graphql": {
      "enabled": true
    },
    "host": {
      "mode": "development",
      "cors": {
        "origins": ["*"]
      }
    }
  },
  "entities": {
    "Todo": {
      "source": "dbo.todos",
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

# [PostgreSQL](#tab/postgresql)

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/download/vmajor.minor.patch/dab.draft.schema.json",
  "data-source": {
    "database-type": "postgresql",
    "connection-string": "Host=localhost;Port=5432;Database=todos;User ID=postgres;Password=P@ssw0rd1;"
  },
  "runtime": {
    "rest": {
      "enabled": true
    },
    "graphql": {
      "enabled": true
    },
    "host": {
      "mode": "development",
      "cors": {
        "origins": ["*"]
      }
    }
  },
  "entities": {
    "Todo": {
      "source": "public.todos",
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

# [MySQL](#tab/mysql)

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/download/vmajor.minor.patch/dab.draft.schema.json",
  "data-source": {
    "database-type": "mysql",
    "connection-string": "Server=localhost;Port=3306;Database=todos;User=root;Password=P@ssw0rd1;"
  },
  "runtime": {
    "rest": {
      "enabled": true
    },
    "graphql": {
      "enabled": true
    },
    "host": {
      "mode": "development",
      "cors": {
        "origins": ["*"]
      }
    }
  },
  "entities": {
    "Todo": {
      "source": "todos",
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

---

> [!TIP]
> You can skip the `dab init` and `dab add` commands and create the `dab-config.json` file directly with the content shown here.

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

1. Open your browser and navigate to the REST endpoint for the **Todo** entity.

    ```text
    http://localhost:5000/api/Todo
    ```

1. The JSON response should include all three todo items.

    ```json
    {
      "value": [
        { "id": 1, "title": "Walk the dog", "completed": false },
        { "id": 2, "title": "Feed the fish", "completed": false },
        { "id": 3, "title": "Comb the cat", "completed": true }
      ]
    }
    ```

1. Navigate to the Swagger documentation page at `/swagger`.

    ```text
    http://localhost:5000/swagger
    ```

[!INCLUDE[Build a web app](includes/section-web-app-todo.md)]

## Clean up

Stop and remove the Docker container when you're done.

# [SQL Server](#tab/mssql)

```shell
docker stop dab-mssql && docker rm dab-mssql
```

# [PostgreSQL](#tab/postgresql)

```shell
docker stop dab-postgres && docker rm dab-postgres
```

# [MySQL](#tab/mysql)

```shell
docker stop dab-mysql && docker rm dab-mysql
```

---

## Next step

> [!div class="nextstepaction"]
> [REST endpoints](../concept/rest/overview.md)
