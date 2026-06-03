---
title: |
  Quickstart: Use Data API builder with SQL
description: Get started quickly using Data API builder with a local Docker-hosted SQL database.
author: jerrynixon
ms.author: jnixon
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/02/2026
# Customer Intent: As a developer, I want to use Data API builder with my local SQL database so I can quickly develop my API before deploying it.
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

## Use GitHub Copilot to recreate this quickstart

Open the workspace where you want to create the sample in Visual Studio Code, switch GitHub Copilot to agent mode, and paste this prompt.

````copilot-prompt
You are GitHub Copilot running in agent mode. Recreate the Data API builder basic SQL quickstart as a complete, runnable local project in the current VS Code workspace under `quickstart-00-basic-sql`. Build a local Docker-based sample that starts one database engine, creates and seeds a `todos` database, configures Data API builder (DAB), exposes REST, GraphQL, and MCP endpoints, adds MCP Inspector for DAB MCP testing, and creates a small static web app that calls DAB. Keep the implementation minimal, but make the web interface neat and approachable: responsive layout, accessible labels, clear loading and error states, and simple styling that is polished rather than austere.

Source repository guidance: no dedicated Azure-Samples repository currently appears for this basic SQL quickstart. However, https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_anon-db_sql_auth is very close and features such as the database and the web site can be reused. If internet access is available, review that site and reuse shared file patterns when they match this local Docker quickstart. Otherwise, implement from this article and the current Data API builder docs. Do not invent a different architecture or add extra services beyond this prompt.

Minimize user interaction. Use the defaults in this prompt and make reasonable best guesses for noncritical choices. Do not ask for a root folder or project folder name; use the current VS Code workspace and the default subfolder. Ask only when you need approval for resource changes, secrets, permissions, materially higher cost, external account choices, or an ambiguous requirement that affects the architecture.

Start with a short plan and proceed with safe defaults before you create files or run commands. Use SQL Server, the default `todos` schema and seed data, SQL Commander, the listed non-default host ports, and local Docker only unless the user explicitly asks for a different database engine or an Azure extension. Ask only these questions if the values aren't already available from the environment or prior context:

- If you want an Azure extension, which Azure subscription, primary region, fallback region, and resource group should it use? Default fallback region: `westus2`.

Show a short checklist before implementation. Include phases for project scaffold, Docker Compose, database initialization, DAB configuration, web app, MCP Inspector, validation, and cleanup. Proceed with local files and local Docker validation without asking for extra confirmation. Do not create Azure resources for this quickstart unless the user explicitly asks for an Azure extension and approves the exact Azure command set.

After you start, continue working without asking status-check questions. If a command, build, container, endpoint, or validation step fails, inspect the error, adjust the project, rerun the step, and continue. Keep iterating until the sample runs end-to-end or you hit a blocker that requires user action.

Use cost-first defaults. The default solution is local Docker only with no Azure cost. If the user asks for an Azure extension, choose the cheapest option that satisfies the selected database engine: use a free Azure SQL database offer when SQL Server is selected and the subscription and region support it; otherwise choose the lowest-cost Azure database option that supports the selected SQL Server, PostgreSQL, or MySQL scenario. Use Azure Container Apps consumption, minimal CPU and memory, Basic Azure Container Registry, minimal Log Analytics retention, and no always-on or dedicated plans unless required. Prioritize finishing the project. Treat regional provisioning limits as expected adjustment points, not failures: if the primary region can't provision a required service or free SQL option, use the approved fallback region such as `westus2`, and continue the deployment. Ask the user only when both the primary and fallback regions can't satisfy the requirements, when a change would materially increase cost, when a new permission is required, or when you need approval for Azure commands that create or change resources beyond the already-approved plan.

Verify prerequisites and report only missing items: Docker Desktop running, .NET SDK, DAB CLI, and a shell that can run Docker Compose. Use the DAB CLI docs while building: https://learn.microsoft.com/azure/data-api-builder/command-line/.

Use these docs during implementation:

- DAB CLI reference: https://learn.microsoft.com/azure/data-api-builder/command-line/
- `dab init`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-init
- `dab add`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-add
- `dab validate`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-validate
- `dab start`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-start
- DAB MCP overview: https://learn.microsoft.com/azure/data-api-builder/mcp/overview
- DAB configuration: https://learn.microsoft.com/azure/data-api-builder/configuration/

Create this structure under the sample folder:

- `docker-compose.yml` for the selected database, DAB, MCP Inspector, and the web app.
- `.env` for local passwords and connection strings.
- `.gitignore` with `.env`, `**/bin`, and `**/obj`.
- `database/` for selected-engine initialization scripts.
- `data-api/dab-config.json` for DAB configuration.
- `web-app/` for static HTML, CSS, and JavaScript.
- `mcp-inspector/README.md` with the auto-connect URL.
- `README.md` with run, validation, troubleshooting, and cleanup steps.

Handle secrets first. Add `.env` to `.gitignore` before writing passwords. Use `DATABASE_PASSWORD` and `DATABASE_CONNECTION_STRING`. Never print secret values. Use `@env('DATABASE_CONNECTION_STRING')` in `dab-config.json`. Avoid `$` in Docker Compose passwords because Compose treats `$` as variable interpolation.

Use Docker Compose, not raw `docker run`, for the generated project. Containers must talk by service name, not `localhost`. Mount `data-api/dab-config.json` into DAB read-only at `/App/dab-config.json`. Use health checks and `depends_on` so DAB starts after the selected database is healthy.

Implement database initialization explicitly. For PostgreSQL and MySQL, mount selected-engine scripts into `/docker-entrypoint-initdb.d` for first-run initialization. For SQL Server, add a one-shot init service or setup script that waits for the `db` service to become healthy and then runs `sqlcmd` to create the `todos` database, table, and seed rows. Do not assume the database health check creates the database or schema.

Use one of these selected-engine configurations.

SQL Server:

```yaml
services:
  db:
    image: mcr.microsoft.com/mssql/server:2025-latest
    environment:
      ACCEPT_EULA: "Y"
      MSSQL_SA_PASSWORD: ${DATABASE_PASSWORD}
    ports:
      - "14330:1433"
    healthcheck:
      test: /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${DATABASE_PASSWORD}" -C -Q "SELECT 1" || exit 1
      interval: 10s
      timeout: 5s
      retries: 10
```

PostgreSQL:

```yaml
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: ${DATABASE_PASSWORD}
    ports:
      - "54320:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 10
```

MySQL:

```yaml
services:
  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: ${DATABASE_PASSWORD}
    ports:
      - "33060:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 10
```

Use the selected database engine only. Do not scaffold all three engines unless the user asks for a matrix sample.

Use the matching schema and connection details.

SQL Server:

```sql
CREATE DATABASE todos;
GO
USE todos;
GO
CREATE TABLE dbo.todos (id int PRIMARY KEY, title nvarchar(100) NOT NULL, completed bit NOT NULL DEFAULT 0);
INSERT INTO dbo.todos VALUES (1, 'Walk the dog', 0), (2, 'Feed the fish', 0), (3, 'Comb the cat', 1);
```

```text
DATABASE_CONNECTION_STRING=Server=db;Database=todos;User Id=sa;Password=<password>;TrustServerCertificate=true;Encrypt=true;
```

PostgreSQL:

```sql
CREATE DATABASE todos;
\c todos
CREATE TABLE todos (id int PRIMARY KEY, title varchar(100) NOT NULL, completed boolean NOT NULL DEFAULT false);
INSERT INTO todos VALUES (1, 'Walk the dog', false), (2, 'Feed the fish', false), (3, 'Comb the cat', true);
```

```text
DATABASE_CONNECTION_STRING=Host=db;Port=5432;Database=todos;User ID=postgres;Password=<password>;
```

MySQL:

```sql
CREATE DATABASE todos;
USE todos;
CREATE TABLE todos (id int PRIMARY KEY, title varchar(100) NOT NULL, completed bool NOT NULL DEFAULT false);
INSERT INTO todos VALUES (1, 'Walk the dog', false), (2, 'Feed the fish', false), (3, 'Comb the cat', true);
```

```text
DATABASE_CONNECTION_STRING=Server=db;Port=3306;Database=todos;User=root;Password=<password>;
```

Use the DAB CLI workflow for the selected engine and validate after each config change.

SQL Server:

```dotnetcli
dab init --config data-api/dab-config.json --database-type mssql --host-mode Development --connection-string "@env('DATABASE_CONNECTION_STRING')" --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todo --config data-api/dab-config.json --source dbo.todos --source.type table --permissions "anonymous:*" --mcp.dml-tools true
dab validate --config data-api/dab-config.json
```

PostgreSQL:

```dotnetcli
dab init --config data-api/dab-config.json --database-type postgresql --host-mode Development --connection-string "@env('DATABASE_CONNECTION_STRING')" --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todo --config data-api/dab-config.json --source public.todos --source.type table --permissions "anonymous:*" --mcp.dml-tools true
dab validate --config data-api/dab-config.json
```

MySQL:

```dotnetcli
dab init --config data-api/dab-config.json --database-type mysql --host-mode Development --connection-string "@env('DATABASE_CONNECTION_STRING')" --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todo --config data-api/dab-config.json --source todos --source.type table --permissions "anonymous:*" --mcp.dml-tools true
dab validate --config data-api/dab-config.json
```

Use this DAB container pattern in Compose:

```yaml
  data-api:
    image: mcr.microsoft.com/azure-databases/data-api-builder:latest
    environment:
      DATABASE_CONNECTION_STRING: ${DATABASE_CONNECTION_STRING}
    ports:
      - "5000:5000"
    volumes:
      - ./data-api/dab-config.json:/App/dab-config.json:ro
    depends_on:
      db:
        condition: service_healthy
```

Configure DAB CORS before you start the browser-based web app. Do not leave `runtime.host.cors.origins` as `[]`. Set it to include the exact web app origin, including scheme and port, such as `http://localhost:8000` for this Docker Compose web app. Keep `allow-credentials` set to `false` unless the sample explicitly uses browser credentials or cookies. Direct REST, GraphQL, or Swagger requests can succeed even when the browser blocks JavaScript fetch calls, so browser-origin CORS must be configured and validated separately.

Add MCP Inspector with the auto-connect URL. Use Streamable HTTP and omit auth only for local development.

```yaml
  mcp-inspector:
    image: ghcr.io/modelcontextprotocol/inspector:latest
    environment:
      HOST: 0.0.0.0
      MCP_AUTO_OPEN_ENABLED: "false"
      DANGEROUSLY_OMIT_AUTH: "true"
    ports:
      - "6274:6274"
      - "6277:6277"
    depends_on:
      - data-api
```

```text
http://localhost:6274/?transport=streamable-http&serverUrl=http%3A%2F%2Fdata-api%3A5000%2Fmcp
```

Use the Compose service name `data-api` in the MCP Inspector auto-connect URL because MCP Inspector runs in the Compose network. Also document a host-side MCP URL for VS Code or direct browser testing:

```text
http://localhost:5000/mcp
```

For SQL Server only, include SQL Commander if the user wants a database browser. Use env var `ConnectionStrings__db` and include `TrustServerCertificate=true`.

```yaml
  sql-commander:
    image: jerrynixon/sql-commander:latest
    environment:
      ConnectionStrings__db: ${DATABASE_CONNECTION_STRING}
    ports:
      - "8080:8080"
    depends_on:
      db:
        condition: service_healthy
```

Build the static web app with minimal code and a polished UI. It should show the todo list, loading state, empty state, error state, API base URL, and quick links to REST, GraphQL, Swagger, and MCP Inspector. Keep dependencies minimal; use plain HTML, CSS, and JavaScript unless the user asks for a framework.

Validate before reporting success:

- `docker compose up -d` starts the selected database, DAB, MCP Inspector, and web app.
- The selected database health check passes.
- The `todos` database and table exist with three seeded rows.
- A direct database query returns the three seeded todo rows.
- `dab validate --config data-api/dab-config.json` exits with code 0.
- DAB `/health` returns a 2xx response.
- REST returns the three todo rows at `http://localhost:5000/api/Todo`.
- GraphQL returns the three todo rows.
- Swagger opens at `http://localhost:5000/swagger`.
- A browser-origin request from the web app origin, for example `http://localhost:8000`, receives an `Access-Control-Allow-Origin` response header that matches that origin.
- MCP Inspector opens with the auto-connect URL and can list DAB tools.
- The web site returns a successful HTTP response.
- The web app displays the todo rows and looks neat, not austere.
- `README.md` includes run, validation, troubleshooting, and cleanup steps.

Do not report final URLs, asset locations, or a success summary until you directly verify database connectivity and query results, a 2xx DAB health response, and a successful web site response. This validation ensures the sample works without requiring the developer to check.
````

## Next step

> [!div class="nextstepaction"]
> [REST endpoints](../concept/rest/overview.md)
