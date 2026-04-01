---
title: Configure SQL Server command timeout for DAB
description: Learn how to configure query timeout for Data API builder to allow longer-running database operations to complete.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 03/11/2026
# Customer Intent: As a developer, I want to configure query timeout for my database in DAB so my long-running stored procedures and queries can complete successfully.
---

# Configure query timeout for Data API builder

Query timeout errors occur when database operations exceed the configured timeout. Data API builder doesn't have a global timeout setting—you configure timeouts through your database connection string or MCP-specific settings.

> [!NOTE]
> There's no `runtime.query-timeout` or similar setting in the DAB configuration file. Configure timeouts using database-specific connection string parameters.

## Database timeout configuration

Configure timeout by adding the appropriate parameter to your connection string. The timeout applies to REST, GraphQL, and Model Context Protocol (MCP) endpoints.

> [!IMPORTANT]
> Increasing timeouts can mask performance issues. Optimize queries, add indexes, and implement pagination before raising timeout limits.

# [SQL Server](#tab/sql-server)

Add `Command Timeout=<seconds>` to your connection string:

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "Server=myServer;Database=myDb;Trusted_Connection=True;Encrypt=True;Command Timeout=240;"
  }
}
```

**Provider default**: 30 seconds  

# [PostgreSQL](#tab/postgresql)

Add `CommandTimeout=<seconds>` to your connection string:

```json
{
  "data-source": {
    "database-type": "postgresql",
    "connection-string": "Host=myServer;Database=myDb;Username=myUser;Password=myPassword;CommandTimeout=240"
  }
}
```

**Provider default**: 30 seconds

# [MySQL](#tab/mysql)

Add `DefaultCommandTimeout=<seconds>` to your connection string:

```json
{
  "data-source": {
    "database-type": "mysql",
    "connection-string": "Server=myServer;Database=myDb;User=myUser;Password=myPassword;DefaultCommandTimeout=240"
  }
}
```

**Provider default**: 30 seconds

# [Cosmos DB](#tab/cosmos-db)

Service-level settings (not connection string parameters) control Cosmos DB timeout:

```json
{
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "options": {
      "database": "myDatabase",
      "container": "myContainer"
    },
    "connection-string": "AccountEndpoint=https://myaccount.documents.azure.com:443/;AccountKey=myKey;"
  }
}
```

For long-running queries, consider:
- Partitioning strategy optimization
- Query optimization with indexes
- Using continuation tokens for large result sets

---

## MCP aggregate-records timeout

MCP operations use both the connection string timeout and an extra MCP-specific timeout. Whichever is shorter triggers first.

> [!NOTE]
> The `aggregate-records` feature is part of Data API builder 2.0, which is currently in preview.

```json
{
  "runtime": {
    "mcp": {
      "dml-tools": {
        "aggregate-records": {
          "query-timeout": 120
        }
      }
    }
  }
}
```