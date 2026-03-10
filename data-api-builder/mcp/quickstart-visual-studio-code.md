---
title: Quickstart - Visual Studio Code local
description: Learn how to start a SQL Model Context Protocol (MCP) Server locally using Data API builder without Aspire. Connect Visual Studio Code (VS Code) to your database and execute queries in minutes.
author: jnixon
ms.author: jnixon
ms.topic: quickstart
ms.date: 03/04/2026
---

# Quickstart: Use SQL MCP Server with Visual Studio Code locally

[!INCLUDE[Section - Quickstart selector](includes/section-quickstart-selector.md)]

![Diagram showing a local SQL MCP Server connected to Visual Studio Code.](media/quickstart-visual-studio-code/diagram.svg)

[!INCLUDE[Note - SQL MCP availability](includes/note-availability.md)]

This quickstart uses the Data API builder CLI to run a SQL Model Context Protocol (MCP) Server locally without Aspire. You create a database, configure a config file, start SQL MCP Server, and connect to it from Visual Studio Code (VS Code) using a custom tool. This path is the easiest way to explore SQL MCP Server without containers or hosting frameworks.

## Prerequisites

Install these tools before you start.

### .NET 9+

You may already have this tool installed. Run `dotnet --version` and confirm it reports version 9.0 or later. If .NET is already present, reinstalling is safe and only refreshes your runtime.

### SQL Server 2016+

You need access to a SQL Server database. Any of the following work:

* SQL Server (Developer or Express)
* LocalDB (file-based SQL Server)
* SQL Server in Docker

### Install the Data API builder CLI

```bash
dotnet new tool-manifest
dotnet tool install microsoft.dataapibuilder
dotnet tool restore
```

> [!NOTE]
> SQL MCP Server features are available in Data API builder version 1.7 and later.

## Step 1: Create your sample database

In this step, you create a database named `ProductsDb` and seed it with a single table named `Products`.

Connect to your SQL instance using SQLCMD, SQL Server Management Studio, or any preferred tool, then run:

```sql
CREATE DATABASE ProductsDb;
GO

USE ProductsDb;
GO

CREATE TABLE dbo.Products (
    Id INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Inventory INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Cost DECIMAL(10,2) NOT NULL
);

INSERT INTO dbo.Products (Id, Name, Inventory, Price, Cost)
VALUES
    (1, 'Action Figure', 40, 14.99, 5.00),
    (2, 'Building Blocks', 25, 29.99, 10.00),
    (3, 'Puzzle 500 pcs', 30, 12.49, 4.00),
    (4, 'Toy Car', 50, 7.99, 2.50),
    (5, 'Board Game', 20, 34.99, 12.50),
    (6, 'Doll House', 10, 79.99, 30.00),
    (7, 'Stuffed Bear', 45, 15.99, 6.00),
    (8, 'Water Blaster', 35, 19.99, 7.00),
    (9, 'Art Kit', 28, 24.99, 8.00),
    (10,'RC Helicopter', 12, 59.99, 22.00);
```

Your sample database is ready.

## Step 2: Configure SQL MCP Server

Run all commands in the folder where you want to create your `dab-config.json` file.

### Create your environment file

Create a file named `.env` in your working directory and add the following line (customize with your SQL Server information):

```text
MSSQL_CONNECTION_STRING=Server=localhost;Database=ProductsDb;Trusted_Connection=True;TrustServerCertificate=True
```

> [!NOTE]
> Integrated authentication (`Trusted_Connection=True`) works on Windows. For SQL authentication (common with Docker or cross-platform), use `Server=localhost,1433;Database=ProductsDb;User Id=sa;Password=<YourPassword>;TrustServerCertificate=True` instead (assuming your container maps port 1433 to localhost).

Data API builder can read variables from a local `.env` file when present in the working directory. If your environment doesn't support `.env` files, set `MSSQL_CONNECTION_STRING` as an environment variable in your terminal session before running the following commands.

### Initialize and configure the server

Run the following commands:

```bash
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --host-mode Development --config dab-config.json

dab add Products --source dbo.Products --permissions "anonymous:read" --description "Toy store products with inventory, price, and cost."
```

### Optionally add field descriptions

```bash
dab update Products --fields.name Id --fields.primary-key true --fields.description "Product Id"
dab update Products --fields.name Name --fields.description "Product name"
dab update Products --fields.name Inventory --fields.description "Units in stock"
dab update Products --fields.name Price --fields.description "Retail price"
dab update Products --fields.name Cost --fields.description "Store cost"
```

Your SQL MCP Server is fully configured.

## Step 3: Start SQL MCP Server

SQL MCP Server supports two transport modes. Choose the one that fits your workflow.

### Option A: HTTP transport (server runs separately)

In HTTP mode, you start DAB as a long-running process in a terminal and VS Code connects to it over a local HTTP endpoint.

Before connecting from VS Code, start the SQL MCP Server in a separate terminal.

#### Open a terminal and run

```bash
dab start --config dab-config.json
```

This command starts the SQL MCP Server. After startup, the terminal output shows the listening URLs. This quickstart assumes the MCP endpoint is `http://localhost:5000/mcp`. Keep this terminal running - Visual Studio Code connects to this HTTP endpoint.

> [!NOTE]
> You can customize the port by configuring the runtime settings in your `dab-config.json` or by setting environment variables such as `ASPNETCORE_URLS`.

### Option B: `stdio` transport (VS Code manages the process)

In `stdio` mode, DAB launches as a child process managed directly by VS Code. You do **not** need to run `dab start` in a terminal—VS Code starts and stops DAB automatically when you open the workspace.

This mode is recommended for local development. There's no HTTP port to manage and no terminal process to keep running.

> [!NOTE]
> The `stdio` transport requires `"mcp": { "enabled": true }` in the `runtime` section of your `dab-config.json`. For full details, see [`stdio` transport for SQL MCP Server](stdio-transport.md).

Skip to [Step 4](#step-4-connect-from-vs-code) to configure the VS Code MCP server definition for your chosen transport.

## Step 4: Connect from VS Code

> [!IMPORTANT]
> A workspace is the root folder that VS Code treats as your project. Settings and MCP server definitions only apply inside that folder. If you open a single file, you aren't in a workspace. You must open a folder.

### Open your project folder

1. Select **File** > **Open Folder**.
2. Open the folder that contains your `dab-config.json` file.

### Create your MCP server definition

Create a file named `.vscode/mcp.json` and add the content for your chosen transport.

#### [`stdio` transport (Option B—recommended for local dev)](#tab/stdio)

In `stdio` mode, VS Code launches DAB as a child process. You don't need a running terminal—VS Code manages the process lifecycle.

```json
{
  "servers": {
    "sql-mcp-server": {
      "type": "stdio",
      "command": "dab",
      "args": [
        "start",
        "--mcp-stdio",
        "role:anonymous",
        "--loglevel",
        "none",
        "--config",
        "${workspaceFolder}/dab-config.json"
      ]
    }
  }
}
```

To install this exact configuration, use the following button.

[![Screenshot that shows Add MCP Server.](https://img.shields.io/badge/Add%20MCP%20Server-VS%20Code-blue?logo=visualstudiocode)](vscode:mcp/install?%7B%22name%22%3A%22sql-mcp-server%22%2C%22type%22%3A%22stdio%22%2C%22command%22%3A%22dab%22%2C%22args%22%3A%5B%22start%22%2C%22--mcp-stdio%22%2C%22role%3Aanonymous%22%2C%22--config%22%2C%22%24%7BworkspaceFolder%7D%2Fdab-config.json%22%5D%7D)

> [!NOTE]
> Replace `role:anonymous` with a role defined in your entity permissions if you want to restrict or expand access. For more information about roles and transport options, see [`stdio` transport for SQL MCP Server](stdio-transport.md).

#### [HTTP transport (Option A)](#tab/http)

In HTTP mode, VS Code connects to the DAB server you started in Step 3. Keep your `dab start` terminal running.

```json
{
  "servers": {
    "sql-mcp-server": {
      "type": "http",
      "url": "http://localhost:5000/mcp"
    }
  }
}
```

To install this exact configuration, use the following button.

[![Screenshot that shows Add MCP Server to VS Code.](https://img.shields.io/badge/Add%20MCP%20Server-VS%20Code-blue?logo=visualstudiocode)](vscode:mcp/install?%7B%22name%22%3A%22sql-mcp-server%22%2C%22type%22%3A%22http%22%2C%22url%22%3A%22http%3A%2F%2Flocalhost%3A5000%2Fmcp%22%7D)

### Start the MCP server connection

1. Open the Command Palette (**Ctrl+Shift+P** or **Cmd+Shift+P** on macOS).
1. Run **MCP: List Servers** to view available servers.
1. Select **sql-mcp-server** (or whatever you name it) and choose **Start** to connect.

Once connected, the `Products` entity appears as MCP tools such as `describe_entities` and `read_records`. Tool names may vary based on your configuration.

> [!NOTE]
> VS Code MCP support is evolving. The configuration schema may change in future releases. For the latest guidance, see the VS Code documentation for MCP integration.

### Try a tool call

Open the VS Code Copilot Chat and try this prompt:

```text
Which products have an inventory under 30?
```

## Related content

- [Overview of SQL MCP Server](overview.md)
- [`stdio` transport for SQL MCP Server](stdio-transport.md)
- [Data manipulation tools in SQL MCP Server](data-manipulation-language-tools.md)
- [Adding semantic descriptions to SQL MCP Server](how-to-add-descriptions.md)
