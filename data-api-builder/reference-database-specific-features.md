---
title: Database-specific features reference
description: Reference guide for database-specific behaviors, minimum versions, SESSION_CONTEXT, and Azure Cosmos DB schema directives in Data API builder.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/27/2026
# Customer Intent: As a developer, I want a single reference for database-specific behaviors and features so that I can configure Data API builder correctly for my target database platform.
---

# Database-specific features reference for Data API builder

This reference covers features, behaviors, and requirements that are specific to one or more database platforms supported by Data API builder (DAB). For a cross-database feature comparison matrix, see [Feature availability](feature-availability.md).

## Database version support

DAB supports the following database platforms. Minimum version requirements apply to self-managed deployments. Platform-as-a-service (PaaS) databases don't have a minimum version requirement because the service manages the version.

| Database platform | Abbreviation | Minimum version | Notes |
|---|---|---|---|
| SQL Server | SQL Family | 2016 | |
| Azure SQL | SQL Family | N/A (PaaS) | |
| Microsoft Fabric SQL | SQL Family | N/A (PaaS) | |
| Azure Cosmos DB for NoSQL | Cosmos DB | N/A (PaaS) | GraphQL only; no REST endpoints |
| PostgreSQL | PGSQL | 11 | |
| MySQL | MySQL | 8 | |
| Azure Synapse Analytics (Dedicated SQL pool) | SQLDW | N/A (PaaS) | Serverless SQL pool isn't supported |

> [!IMPORTANT]
> Verify that both your local development database and any deployed database meet the minimum version requirement. DAB connects using the same driver in both environments. An older version in either location causes runtime errors.

## SQL Server and Azure SQL

### SESSION_CONTEXT

For SQL Server and Azure SQL, DAB can propagate authenticated user claims to the database by calling `sp_set_session_context` before executing each query. This mechanism lets SQL-native row-level security policies and stored procedures read the caller's identity from within the database engine.

When `set-session-context` is enabled in the DAB configuration, DAB sends all authenticated claims as key-value pairs:

```sql
EXEC sp_set_session_context 'roles', 'editor', @read_only = 0;
EXEC sp_set_session_context 'oid', 'a1b2c3d4-...', @read_only = 0;
-- Your query executes after claims are set
SELECT * FROM dbo.Documents;
```

Common claims sent include `roles`, `sub`, `oid`, and any custom claims your identity provider includes in the JWT.

#### Enable SESSION_CONTEXT

Set `--set-session-context true` when calling `dab init`:

```bash
dab init \
  --database-type mssql \
  --connection-string "@env('SQL_CONNECTION_STRING')" \
  --set-session-context true
```

Or set the property directly in `dab-config.json`:

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('SQL_CONNECTION_STRING')",
    "options": {
      "set-session-context": true
    }
  }
}
```

> [!WARNING]
> Enabling `set-session-context` disables response caching for that data source. Because each request sets distinct session values, cached responses from one user's session must not be served to another.

#### Use SESSION_CONTEXT in SQL

After enabling `set-session-context`, your SQL objects can read the claim values:

```sql
-- Read a claim in a stored procedure
DECLARE @role NVARCHAR(256) = CAST(SESSION_CONTEXT(N'roles') AS NVARCHAR(256));

-- Use a claim in a row-level security predicate function
CREATE FUNCTION dbo.RlsPredicate(@claimRole NVARCHAR(256))
RETURNS TABLE
WITH SCHEMABINDING
AS RETURN SELECT 1 AS result
WHERE @claimRole = CAST(SESSION_CONTEXT(N'roles') AS NVARCHAR(256));
```

For a complete walkthrough, see [Implement row-level security with session context](concept/security/row-level-security.md).

#### SESSION_CONTEXT and connection pooling

DAB resets all session context values at the start of each request. However, because `set-session-context` forces per-user connection semantics, connection reuse across users is avoided automatically when this option is enabled.

### Connection string variants

DAB uses `Microsoft.Data.SqlClient` for SQL Server and Azure SQL. The library supports [these connection string formats](/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring).

Common formats:

| Authentication method | Connection string pattern |
|---|---|
| SQL login | `Server=tcp:<server>.database.windows.net;Database=<db>;User ID=<user>;Password=<pwd>;` |
| Managed identity | `Server=tcp:<server>.database.windows.net;Database=<db>;Authentication=Active Directory Managed Identity;` |
| User-Assigned Managed Identity | `Server=tcp:<server>.database.windows.net;Database=<db>;Authentication=Active Directory Managed Identity;User ID=<client-id>;` |
| Default Azure credential | `Server=tcp:<server>.database.windows.net;Database=<db>;Authentication=Active Directory Default;` |

> [!TIP]
> Store connection strings in environment variables and reference them with `@env('SQL_CONNECTION_STRING')`. For production deployments, store the connection string in Azure Key Vault and reference it with [`@akv()`](concept/config/akv-function.md).

### Unsupported data types

The following SQL Server and Azure SQL data types aren't supported by DAB:

| Data type | Reason |
|---|---|
| `geography` | Geospatial type; serialization not supported |
| `geometry` | Planar spatial type; serialization not supported |
| `hierarchyid` | Hierarchical data type; serialization not supported |
| `json` | Native JSON type (currently in preview) |
| `rowversion` | Row versioning type; not included in API responses |
| `sql_variant` | Variable-type columns; type inference not supported |
| `vector` | Vector type (currently in preview) |
| `xml` | XML type; serialization not supported |

## Azure Cosmos DB for NoSQL

### Schema requirement

Unlike relational databases, Azure Cosmos DB for NoSQL is schema-agnostic. DAB can't introspect a Cosmos DB container to generate GraphQL types. You must provide a GraphQL schema file (`.gql`) that defines your document structure.

The schema file uses standard GraphQL Schema Definition Language (SDL) with two custom directives:

| Directive | Required | Description |
|---|---|---|
| `@model` | Yes | Maps a GraphQL type to a DAB entity name |
| `@authorize` | No | Restricts field or type access to specific roles |

#### @model directive

The `@model(name: "...")` directive is required on every GraphQL type you expose through DAB. The `name` value must exactly match the entity name in your DAB configuration file.

```graphql
type Book @model(name: "Book") {
  id: ID
  title: String
  year: Int
}
```

#### @authorize directive

The `@authorize` directive provides field-level and type-level access control for Cosmos DB GraphQL queries. It accepts a `roles` parameter listing the roles that can access the field or type.

```graphql
type Book @model(name: "Book") {
  id: ID
  title: String @authorize(roles: ["authenticated", "librarian"])
  internalNotes: String @authorize(roles: ["editor"])
}
```

You can also apply `@authorize` at the type level:

```graphql
type InternalReport @model(name: "InternalReport") @authorize(roles: ["auditor"]) {
  id: ID
  summary: String
}
```

> [!IMPORTANT]
> The `@authorize` directive **adds** to entity-level permissions. Both the directive and the entity's permission block must allow the request for access to succeed. If a field has `@authorize(roles: ["editor"])` but the entity has no permission entry for `editor`, the request is denied.

> [!NOTE]
> `@authorize(policy: "...")` isn't supported. Use `@authorize(roles: [...])` only.

For a complete setup guide, see [Set up Data API builder for Azure Cosmos DB for NoSQL](concept/database/set-up-cosmosdb.md).

### REST API unavailability

DAB doesn't generate REST endpoints for Azure Cosmos DB for NoSQL. Azure Cosmos DB provides a comprehensive native REST API for document operations. Only GraphQL endpoints are generated. OpenAPI documents aren't generated for Cosmos DB entities.

To access data over REST, use the [Azure Cosmos DB REST API](/rest/api/cosmos-db/) directly.

### Unsupported features for Cosmos DB

The following features aren't supported for Azure Cosmos DB for NoSQL:

| Feature | Notes |
|---|---|
| REST endpoints | Use the native Cosmos DB REST API instead |
| Database policies | Policy predicates require relational query semantics |
| Stored procedures | Not supported as DAB entities |
| Relationships | Cross-container relationships aren't supported |
| Sorting (`$orderby`) | Not supported in GraphQL queries |
| Aggregation | Not supported |
| Multiple mutations | Not supported |
| Session context | SQL-specific feature |

## PostgreSQL

### Minimum version

PostgreSQL 11 or later is required. DAB uses `Npgsql` as its PostgreSQL driver.

### Unsupported data types

The following PostgreSQL data types aren't supported by DAB:

| Data type | Notes |
|---|---|
| `bytea` | Binary string; serialization not supported |
| `date` | Use `timestamp` or `timestamptz` |
| `smalldatetime` | Not a native PostgreSQL type |
| `datetime2` | Not native; typically handled by `timestamp` |
| `timestamptz` | Timestamp with time zone; not supported |
| `time` | Time of day without date |
| `localtime` | System clock–based time |

### Stored procedures

Stored procedures aren't supported for PostgreSQL entities. Use tables and views instead.

## MySQL

### Minimum version

MySQL 8 or later is required.

### Unsupported data types

The following MySQL data types aren't supported by DAB:

| Data type | Notes |
|---|---|
| `UUID` | Universally Unique Identifiers |
| `DATE` | Calendar dates |
| `SMALLDATETIME` | Less precise date and time storage |
| `DATETIME2` | Not native; use `datetime` |
| `DATETIMEOFFSET` | Dates and times with time zone |
| `TIME` | Time of day without date |
| `LOCALTIME` | Current time based on the system clock |

### Stored procedures

Stored procedures aren't supported for MySQL entities. Use tables instead.

## Azure Synapse Analytics (Dedicated SQL pool)

### Supported objects

Dedicated SQL pool supports tables, views, and stored procedures—the same as SQL Server and Azure SQL. Serverless SQL pool isn't supported.

### Unsupported features

| Feature | Notes |
|---|---|
| Multiple mutations | Not supported |

## Related content

- [Feature availability](feature-availability.md)
- [Data source configuration reference](configuration/data-source.md)
- [Implement row-level security with session context](concept/security/row-level-security.md)
- [Set up Data API builder for Azure Cosmos DB for NoSQL](concept/database/set-up-cosmosdb.md)
- [Release and versioning policies](reference-code-policies.md)
