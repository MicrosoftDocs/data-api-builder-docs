---

title: Quickstart: Run a local SQL MCP Server with the Data API builder CLI
description: Start a SQL MCP Server locally using Data API builder without Aspire.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 12/05/2025

# Customer Intent: As a developer, I want a fast local experience to try SQL MCP Server and test in VS Code.

---

# Quickstart: Run a local SQL MCP Server with VS Code

This quickstart uses the Data API builder CLI to run a SQL MCP Server locally without Aspire. You will create a simple database, configure a config file, start SQL MCP Server, and connect to it from VS Code using a custom tool. This path is the simplest way to explore SQL MCP Server without containers or hosting frameworks.

## Prerequisites

Install these before you start.

### 1. .NET 9+

You may already have this installed. Run `dotnet --version` and confirm it reports version 10 or later. If .NET is already present, reinstalling is safe and will only refresh your runtime.

### 2. SQL Server 2016+

You need access to a SQL Server database. Any of the following work:

* SQL Server (Developer or Express)
* LocalDB (file-based SQL Server)
* SQL Server in Docker

### 3. Install the Data API builder CLI

```
dotnet new tool-manifest
dotnet tool install microsoft.dataapibuilder --prerelease
```

## 1. Create your sample database

In this step, you will create a database named `ProductsDb` and seed it with a single table named `Products`.

Connect to your SQL instance using SQLCMD, Azure Data Studio, SQL Server Management Studio, or any preferred tool, then run:

```sql
CREATE DATABASE ProductsDb;
GO

USE ProductsDb;
GO

SELECT *
INTO dbo.Products
FROM (VALUES
    (1, 'Action Figure', 40, 14.99, 5.00),
    (2, 'Building Blocks', 25, 29.99, 10.00),
    (3, 'Puzzle 500 pcs', 30, 12.49, 4.00),
    (4, 'Toy Car', 50, 7.99, 2.50),
    (5, 'Board Game', 20, 34.99, 12.50),
    (6, 'Doll House', 10, 79.99, 30.00),
    (7, 'Stuffed Bear', 45, 15.99, 6.00),
    (8, 'Water Blaster', 35, 19.99, 7.00),
    (9, 'Art Kit', 28, 24.99, 8.00),
    (10,'RC Helicopter', 12, 59.99, 22.00)
) AS x (Id, Name, Inventory, Price, Cost);

ALTER TABLE dbo.Products
ADD CONSTRAINT PK_Products PRIMARY KEY (Id);
```

Your sample database is ready.

## 2. Configure SQL MCP Server 

### Create a file named:

```
.env
```

Place it in the same folder as your `dab-config.json`, then add the following line (customize with your SQL Server information):

```
MSSQL_CONNECTION_STRING=Server=localhost;Database=ProductsDb;Trusted_Connection=True;TrustServerCertificate=True
```

SQL MCP Server automatically loads variables from a local `.env` file, so the following command will now work without setting anything in your terminal.

### Run the following script:

```
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --host-mode Development --config dab-config.json

dab add Products --source dbo.Products --permissions "anonymous:*" --description "Toy store products with inventory, price, and cost."
```

### Optionally add field descriptions:

```
dab update Products --fields.name Id --fields.primary-key true --fields.description "Product Id"
dab update Products --fields.name Name --fields.description "Product name"
dab update Products --fields.name Inventory --fields.description "Units in stock"
dab update Products --fields.name Price --fields.description "Retail price"
dab update Products --fields.name Cost --fields.description "Store cost"
```

Your SQL MCP Server is fully configured.

## 3. Start SQL MCP Server

### Run:

```
dab start --config dab-config.json --mcp-stdio
```

This starts SQL MCP Server in MCP mode. It waits for a client such as VS Code or an AI agent to connect over standard input and output. The server is now ready for MCP-aware tools and extensions.

## 4. Connect your MCP to VS Code 

> [!IMPORTANT]
> A workspace is the root folder that VS Code treats as your project. Settings and MCP server definitions only apply inside that folder. If you open a single file, you are not in a workspace. You must open a folder.

### In VS Code:

1. Select File > Open Folder
2. Open the folder that contains your `dab-config.json` file

### Create your MCP server definition

#### Create a file named:

```
$/.vscode/mcp.json
```

#### Add the following content:

```
{
  "servers": {
    "sql-mcp-server": {
      "command": "dab",
      "args": [ "start" ]
    }
  }
}
```

Save the file. VS Code will automatically detect the MCP server and list the available tools created by your SQL MCP Server. The `Products` entity will appear as MCP tools such as `read_records`, `list_records`, and `create_record`.

### Try a tool call

#### Open the VS Code chat and try this prompt:

```
@sql-mcp-server Which products have an invesntory under 30?
```

You should see the toy store data you inserted earlier.