---
title: Overview Configuration Datasource
description: Details the data-source property in Configuration
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/27/2024
---

# Data-source property

The `data-source` section outlines backend database connectivity, specifying both the `database-type` and `connection-string`.

## Syntax overview

```json
{
  "data-source": {
    "database-type": "...",
    "connection-string": "your-connection-string",
    
    // mssql-only
    "options": {
      "set-session-context": true (default) | false
    },
    
    // cosmosdb_nosql-only
    "options": {
      "database": "your-cosmosdb-database-name", 
      "container": "your-cosmosdb-container-name",
      "schema": "path-to-your-graphql-schema-file"
    }
  }
}
```

### Database-type property

The `type` property indicates the kind of backend database.

| Type                  | Description              | Min Version |
| --------------------- | ------------------------ | ----------- |
| `mssql`               | Azure SQL DB             | n/a         |
| `mssql`               | Azure SQL MI             | n/a         |
| `mssql`               | SQL Server               | SQL 2016    |
| `sqldw`               | Azure SQL Data Warehouse | n/a         |
| `postgresql`          | PostgreSQL               | v11         |
| `mysql`               | MySQL                    | v8          |
| `cosmosdb_nosql`      | Azure Cosmos DB<br/>NoSQL API      | n/a         |
| `cosmosdb_postgresql` | Azure Cosmos DB<br/>PostgreSQL API | n/a         |

### Set-session-context property

For Azure SQL and SQL Server, Data API builder can take advantage of `SESSION_CONTEXT` to send user specified metadata to the underlying database. Such metadata is available to Data API builder by virtue of the claims present in the access token. The `SESSION_CONTEXT` data is available to the database during the database connection until that connection is closed. [Learn more about session context](/data-api-builder/azure-sql-session-context-rls.md).

### Connection-string property

The ADO.NET connection string to connect to the backend database. [Learn more.](/dotnet/framework/data/adonet/connection-strings)

#### Connection resiliency

Data API builder automatically retries database requests after detecting transient errors. The retry logic follows an Exponential Backoff strategy where the maximum number of retries is 5. The retry backoff duration after subsequent requests is `power(2, retryAttempt)`. The first retry is attempted after 2 seconds. The second through fifth retries are attempted after 4, 8, 16, and 32 seconds, respectively.

#### Azure SQL and SQL Server

Data API builder uses the SqlClient library to connect to Azure SQL or SQL Server using the connection string you provide in the configuration file. A list of all the supported connection string options is available here: [SqlConnection.ConnectionString Property](/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring).

Data API builder can also connect to the target database using Managed Service Identities (MSI). It uses DefaultAzureCredential defined in [Azure Identity client library for .NET](/dotnet/api/overview/azure/Identity-readme#defaultazurecredential) when you don't specify a username or password in your connection string.

## Example

These samples just illustrate how each database type might be configured. Your scenario may be unique, but this sample is a good starting place. Replace the placeholders such as `myserver`, `myDataBase`, `mylogin`, and `myPassword` with the actual values specific to your environment.

**Sample - mssql**

```json
"data-source": {
  "database-type": "mssql",
  "connection-string": "$env('my-connection-string')",
  "options": {
    "set-session-context": true
  }
}
```

Typical connection string format: `"Server=tcp:myserver.database.windows.net,1433;Initial Catalog=myDataBase;Persist Security Info=False;User ID=mylogin;Password=myPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"`

**Sample - postgres**

```json
"data-source": {
  "database-type": "postgresql",
  "connection-string": "$env('my-connection-string')"
}
```

Typical connection string format: `"Host=myserver.postgres.database.azure.com;Database=myDataBase;Username=mylogin@myserver;Password=myPassword;"`

**Sample - mysql**

```json
"data-source": {
  "database-type": "mysql",
  "connection-string": "$env('my-connection-string')"
}
```

Typical connection string format: `"Server=myserver.mysql.database.azure.com;Database=myDataBase;Uid=mylogin@myserver;Pwd=myPassword;"`

**Sample - Cosmos nosql**

```json
"data-source": {
  "database-type": "cosmosdb_nosql",
  "connection-string": "$env('my-connection-string')",
  "options": {
    "database": "Your_CosmosDB_Database_Name",
    "container": "Your_CosmosDB_Container_Name",
    "schema": "Path_to_Your_GraphQL_Schema_File"
  }
}
```

Typical connection string format: `"AccountEndpoint=https://mycosmosdb.documents.azure.com:443/;AccountKey=myAccountKey;"`

**Sample - Cosmos pg**

```json
"data-source": {
  "database-type": "cosmosdb_postgresql",
  "connection-string": "$env('my-connection-string')"
}
```

Typical connection string format: `"Host=mycosmosdb.postgres.database.azure.com;Database=myDataBase;Username=mylogin@mycosmosdb;Password=myPassword;Port=5432;SSL Mode=Require;"`

> The "options" specified such as `database`, `container`, and `schema` are specific to Azure Cosmos DB's NoSQL API rather than the PostgreSQL API. For Azure Cosmos DB using the PostgreSQL API, the "options" would not include `database`, `container`, or `schema` as in the NoSQL setup.