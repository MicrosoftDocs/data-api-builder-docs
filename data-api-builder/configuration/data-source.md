---
title: Configuration schema - Data Source section
description: The Data API Builder configuration file's Data Source top-level section with details for each property.
author: jnixon
ms.author: sidandrews
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 06/06/2025
show_latex: true
---

# Data source

The `data-source` section defines the database access details. It also defines database options.

### Data source settings

|Property|Description|
|-|-|
|[data-source](#data-source-1)|Object containing database connectivity settings|
|[data-source.database-type](#data-source-1)|Database used in the backend: `mssql`, `postgresql`, `mysql`, `cosmosdb_nosql`, `cosmosdb_postgresql`|
|[data-source.connection-string](#data-source-1)|Connection string for the selected database type|
|[data-source.options](#data-source-1)|Database-specific properties (for example, options for SQL Server, Cosmos DB, etc.)|
|[data-source.options.database](#data-source-1)|Name of the Azure Cosmos DB for NoSQL database (required when `database-type = cosmosdb_nosql`)|
|[data-source.options.container](#data-source-1)|Name of the Azure Cosmos DB for NoSQL container (required when `database-type = cosmosdb_nosql`)|
|[data-source.options.schema](#data-source-1)|Path to the GraphQL schema file (required when `database-type = cosmosdb_nosql`)|
|[data-source.options.set-session-context](#data-source-1)|Enables sending JSON Web Token (JWT) claims as session context (SQL Server only)|
|[data-source.health](#health-data-source)|Object configuring health checks for the data source|
|[data-source.health.enabled](#health-data-source)|Enables the health check endpoint|
|[data-source.health.name](#health-data-source)|Identifier used in the health report|
|[data-source.health.threshold-ms](#health-data-source)|Maximum duration in milliseconds for health check query|

## Format overview

```json
{
  "data-source": {
    "database-type": <string>,
    "connection-string": <string>,
    "options": {
      // mssql only
      "set-session-context": <true> (default) | <false>,
      // cosmosdb_nosql only
      "database": <string>,
      "container": <string>,
      "schema": <string>
    },
    "health": {
      "enabled": <true> (default) | <false>,
      "name": <string>,
      "threshold-ms": <integer; default: 1000>
    }
  },
  "data-source-files": ["<string>"]
}
```

## Data source

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`$root`|`database-source`|object|✔️ Yes|-|

### Nested properties

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`data-source`|`database-type`|enum|✔️ Yes|None|
|`data-source`|`connection-string`|string|✔️ Yes|None|
|`data-source`|`options`|object|❌ No|None|

### Property values

|`database-type`|Description|Min Version|
|-|-|-|
|`mssql`|SQL in Fabric|-
|`mssql`|Azure SQL Database|-
|`mssql`|Azure SQL MI|-
|`mssql`|SQL Server|2016
|`dwsql`|Azure Synapse Analytics|-
|`dwsql`|Fabric Warehouse|-
|`dwsql`|Fabric SQL Analytics endpoint|-
|`postgresql`|PostgreSQL|ver. 11
|`mysql`|MySQL|ver. 8
|`cosmosdb_nosql`|Azure Cosmos DB for NoSQL|-
|`cosmosdb_postgresql`|Azure Cosmos DB for PostgreSQL|-

### Format

```json
{
  "data-source": {
    "database-type": <string>,
    "connection-string": <string>,
    "options": {
      "<key-name>": <string>
    }
  }
}
```

### Example: Azure SQL & SQL Server

```json
"data-source": {
  "database-type": "mssql",
  "connection-string": "Server=tcp:myserver.database.windows.net,1433;Initial Catalog=MyDatabase;User ID=MyUser;Password=MyPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;",
    "options": {
      "set-session-context": true
    }
}
```

 > [!NOTE]
 > We use [`SqlClient`](https://www.nuget.org/packages/Microsoft.Data.SqlClient) for Azure SQL and SQL Server, which supports [these](/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring) connection strings variants.

 #### Consuming `SESSION_CONTEXT`

For Azure SQL and SQL Server, Data API builder can include Claims info in SQL's [`SESSION_CONTEXT`](../reference-database-specific-features.md#session_context).

```sql
CREATE PROC GetUser @userId INT AS
BEGIN
    -- Use claims
    IF SESSION_CONTEXT(N'user_role') = 'admin' 
    BEGIN
        RAISERROR('Unauthorized access', 16, 1);
    END

    SELECT Id, Name, Age, IsAdmin
    FROM Users
    WHERE Id = @userId;
END;
```

### Example: Azure Cosmos DB

```json
"data-source": {
  "database-type": "cosmosdb_nosql",
  "connection-string": "@env('SQL_CONNECTION_STRING')",
  "options": {
    "database": "Your_CosmosDB_Database_Name",
    "container": "Your_CosmosDB_Container_Name",
    "schema": "Path_to_Your_GraphQL_Schema_File"
  }
}
```

> [!NOTE]
> The "options" specified (`database`, `container`, and `schema`) are specific to Azure Cosmos DB.

### Environment variables

Use environment variables to keep plain text secrets out of your configuration file. 

> [!TIP]
> Data API builder supports both the [`@env()` function`](../reference-functions.md#env) and [`.env` files](https://www.dotenv.org/docs/security/env.html). 

```json
"data-source": {
  "database-type": "mssql",
  "connection-string": "@env('SQL_CONNECTION_STRING')"
}
```

### Connection resiliency

Data API builder uses Exponential Backoff to retry database requests after transient errors.

|Attempts|First|Second|Third|Fourth|Fifth|
|-|-|-|-|-|-|
|Seconds|2s|4s|8s|16s|32s|

### Managed Service Identities (MSI)

Managed Service Identities (MSI) are supported with `DefaultAzureCredential` defined in [`Azure.Identity`](https://www.nuget.org/packages/Azure.Identity) library. Learn more about [Managed identities in Microsoft Entra for Azure SQL](/azure/azure-sql/database/authentication-azure-ad-user-assigned-managed-identity?view=azuresql&preserve-view=true).

#### User-Assigned Managed Identities (UAMI)

For User Assigned Managed Identity, append the *Authentication* and *User Id* properties to your connection string while substituting in your User Assigned Managed Identity's client id: `Authentication=Active Directory Managed Identity; User Id=<UMI_CLIENT_ID>;`.

#### System-Assigned Managed Identity (SAMI)

For System Assigned Managed Identity, append the *Authentication* property and exclude the *UserId* and *Password* arguments from your connection string: `Authentication=Active Directory Managed Identity;`. 


## Health (Data source)

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`data-source`|`health`|object|No|–|

Data API builder supports multiple configuration files, each with its own data source. This configuration block allows each data source to have its own health configuration.

### Nested properties

|Parent|Property|Type|Required|Default|
|-|-|-|-|-|
|`data-source.health`|`enabled`|boolean|No|true|
|`data-source.health`|`name`|string|No|database-type|
|`data-source.health`|`threshold-ms`|integer|No|1000|

### Check name

Because multiple configuration files can point to data sources of the same type, those data sources can't be distinguished in the health report. Use `name` to assign a unique, identifiable label used only in the health report.

### Check behavior

The simplest possible query—specific to the database type—is executed against the given data source to validate that the connection can be opened. Use the `threshold-ms` property to configure the maximum acceptable duration (in milliseconds) for that query to complete.

### Format

```json
{
  "data-source": {
    "health": {
      "enabled": <true> (default) | <false>,
      "name": <string>,
      "threshold-ms": <integer; default: 1000>
    }
  }
}
```