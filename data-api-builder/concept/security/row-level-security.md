---
title: Implement row-level security with session context
description: Use the session context feature of SQL and Data API builder to manually implement row-level security in your APIs.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 01/21/2026
# Customer Intent: As a developer, I want to implement row-level security, so that I can ensure that users only see records intended for them.
---

# Implement row-level security with session context in Data API builder

Use the **session context** feature of SQL to implement row-level security in Data API builder.

![Diagram showing how Data API builder can set SQL session context to enable row-level security.](media/row-level-security/row-level-security-session-context.svg)

> [!IMPORTANT]
> Session context with SQL Server row-level security differs from Data API builder database policies. Database policies (for example, `--policy-database "@item.owner eq @claims.user_id"`) are translated into WHERE clauses by Data API builder, while session context forwards claims to SQL Server so that SQL-native row-level security handles the filtering.

## Prerequisites

- Existing SQL server and database.
- Data API builder CLI. [Install the CLI](../../command-line/install.md)

> [!NOTE]
> Session context is supported in:
> - SQL Server 2016 and later
> - Azure SQL Database
> - Azure Synapse Analytics (Dedicated SQL pool)
> - Azure Synapse Analytics (Serverless SQL pool) isn't supported

## Create SQL table and data

Create a table with fictitious data to use in this example scenario.

1. Connect to the SQL database using your preferred client or tool.

1. Create a table named `Revenues` with `id`, `category`, `revenue`, and `accessible_role` columns.

    ```sql
    DROP TABLE IF EXISTS dbo.Revenues;

    CREATE TABLE dbo.Revenues(
        id int PRIMARY KEY,  
        category varchar(max) NOT NULL,  
        revenue int,  
        accessible_role varchar(max) NOT NULL  
    );
    GO
    ```

1. Insert four sample rows into the `Revenues` table.

    ```sql
    INSERT INTO dbo.Revenues VALUES
        (1, 'Book', 5000, 'Oscar'),  
        (2, 'Comics', 10000, 'Oscar'),  
        (3, 'Journals', 20000, 'Hannah'),  
        (4, 'Series', 40000, 'Hannah')
    GO
    ```

    In this example, the `accessible_role` column stores the role name that can access the row.

> [!TIP]
> Common session context use cases:
> - Role-based filtering (shown here) using `roles`
> - Multitenant isolation using `tenant_id`
> - User-specific filtering using `user_id`

1. Test your data with a simple `SELECT *` query.

    ```sql
    SELECT * FROM dbo.Revenues
    ```

1. Create a function named `RevenuesPredicate`. This function will filter results based on the current session context.

    ```sql
    CREATE FUNCTION dbo.RevenuesPredicate(@accessible_role varchar(max))
    RETURNS TABLE
    WITH SCHEMABINDING
    AS RETURN SELECT 1 AS fn_securitypredicate_result
    WHERE @accessible_role = CAST(SESSION_CONTEXT(N'roles') AS varchar(max));
    ```

1. Create a security policy named `RevenuesSecurityPolicy` using the function.

    ```sql
    CREATE SECURITY POLICY dbo.RevenuesSecurityPolicy
    ADD FILTER PREDICATE dbo.RevenuesPredicate(accessible_role)
    ON dbo.Revenues;
    ```

> [!NOTE]
> The `WITH SCHEMABINDING` clause is required for functions used in security policies so underlying schema changes do not invalidate the predicate.

## (Optional) Create a stored procedure

This section shows a simple "hello world" pattern for using session context values directly in T-SQL.

1. Create a stored procedure that reads the `roles` session context value and uses it to filter results.

    ```sql
    CREATE OR ALTER PROCEDURE dbo.GetRevenuesForCurrentRole
    AS
    BEGIN
        SET NOCOUNT ON;

        DECLARE @role varchar(max) = CAST(SESSION_CONTEXT(N'roles') AS varchar(max));

        SELECT id, category, revenue, accessible_role
        FROM dbo.Revenues
        WHERE accessible_role = @role;
    END
    GO
    ```

## Run tool

Run the Data API builder (DAB) tool to generate a configuration file and a single entity.

1. Create a new configuration while setting `--set-session-context` to true.

    ```dotnetcli
    dab init \
        --database-type mssql \
        --connection-string "<sql-connection-string>" \
        --set-session-context true \
        --auth.provider Simulator
    ```

    When session context is enabled for SQL Server, Data API builder sends authenticated user claims to SQL by calling `sp_set_session_context` (for example, `roles`). Enabling session context also disables response caching for that data source.

> [!WARNING]
> When `set-session-context` is enabled, response caching is disabled for the data source. For high-traffic scenarios, consider testing performance, indexing the predicate column, or using Data API builder database policies when they meet your needs.

1. Add a new entity named `revenue` for the `dbo.Revenues` table.

    ```dotnetcli
    dab add revenue \
        --source "dbo.Revenues" \
        --permissions "Authenticated:read"
    ```

1. Start the Data API builder tool.

    ```dotnetcli
    dab start
    ```

1. Query the endpoint without specifying an effective role. Observe that no data is returned because:
    - The effective role defaults to `Authenticated`.
    - No rows have `accessible_role = 'Authenticated'`.
    - The security policy filters results when the role doesn't match.

    ```bash
    curl http://localhost:5000/api/revenue
    ```

1. Query the endpoint while setting the effective role to `Oscar`. Observe that the filtered results include only the `Oscar` rows.

    ```bash
    curl -H "X-MS-API-ROLE: Oscar" http://localhost:5000/api/revenue
    ```

1. Repeat using the `Hannah` role.

    ```bash
    curl -H "X-MS-API-ROLE: Hannah" http://localhost:5000/api/revenue
    ```

### Test with GraphQL

Session context also works with GraphQL queries.

```graphql
query {
    revenues {
        items {
            id
            category
            revenue
            accessible_role
        }
    }
}
```

Pass the role header:

```bash
curl -X POST http://localhost:5000/graphql \
    -H "Content-Type: application/json" \
    -H "X-MS-API-ROLE: Oscar" \
    -d '{"query": "{ revenues { items { id category revenue accessible_role } } }"}'
```

## What Data API builder sends to SQL Server

When session context is enabled, Data API builder sets session context values on every request before executing your query.

```sql
EXEC sp_set_session_context 'roles', 'Oscar', @read_only = 0;
-- Then executes your query
SELECT * FROM dbo.Revenues;
```

All authenticated user claims are sent as key-value pairs. Common claims include `roles`, `sub` or `oid`, and any custom claims from your identity provider.

## Test in SQL

Test the filter and predicate in SQL directly to ensure it's working.

1. Connect to the SQL server again using your preferred client or tool.

1. Run the `sp_set_session_context` to manually set your session context's `roles` claim to the static value `Oscar`.

    ```sql
    EXEC sp_set_session_context 'roles', 'Oscar';
    ```

1. Run a typical `SELECT *` query. Observe that the results are automatically filtered using the predicate.

    ```sql
    SELECT * FROM dbo.Revenues;  
    ```

1. (Optional) Query the table using the stored procedure.

    ```sql
    EXEC dbo.GetRevenuesForCurrentRole;
    ```

## Clean up resources

If you want to remove the sample objects, run:

```sql
DROP SECURITY POLICY IF EXISTS dbo.RevenuesSecurityPolicy;
DROP FUNCTION IF EXISTS dbo.RevenuesPredicate;
DROP PROCEDURE IF EXISTS dbo.GetRevenuesForCurrentRole;
DROP TABLE IF EXISTS dbo.Revenues;
```

## Troubleshooting

- **No results returned**: Verify the security policy is active (`SELECT * FROM sys.security_policies`), check the session context value (`SELECT SESSION_CONTEXT(N'roles')`), and confirm `--set-session-context true` is set in your Data API builder configuration.
- **All rows returned**: Confirm the security policy isn't disabled (`WITH STATE = OFF`) and that the predicate returns `1` only for authorized rows.
- **Performance issues**: Index the predicate column (`accessible_role`), and consider temporarily disabling the policy to isolate performance impact.

## Related content

- [Database-specific features](../../reference-database-specific-features.md)
- [Use environments](../config/environments.md)
