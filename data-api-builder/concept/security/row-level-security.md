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

![Illustration of how Data API builder can set SQL session context to enable row-level security.](media/row-level-security/row-level-security-session-context.svg)

## Prerequisites

- Existing SQL server and database.
- Data API builder CLI. [Install the CLI](../../command-line/install.md)

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

1. Query the endpoint without specifying an effective role. Observe that no data is returned because the effective role defaults to `Authenticated`.

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

## Related content

- [Database-specific features](../../reference-database-specific-features.md)
- [Use environments](../config/environments.md)
