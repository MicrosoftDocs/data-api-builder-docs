---
title: Implement row-level security with session context
description: Use the session context feature of SQL and Data API builder to manually implement row-level security in your APIs.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 04/09/2024
# Customer Intent: As a developer, I want to implement row-level secuirty, so that I can ensure that users only see records intended for them.
---

# Implement row-level security with session context in Data API builder

TODO

## Prerequisites

- Existing SQL server and database.
- Data API builder CLI. [Install the CLI](how-to-install-cli.md)

## Create SQL table and data

TODO

1. Create a table named `Revenues` with `id`, `category`, `revenue`, and `username` columns.

    ```sql
    DROP TABLE IF EXISTS dbo.Revenues;

    CREATE TABLE dbo.Revenues(
        id int PRIMARY KEY,  
        category varchar(max) NOT NULL,  
        revenue int,  
        username varchar(max) NOT NULL  
    );
    GO
    ```

1. Insert four sample book rows into the `Revenues` table.

    ```sql
    INSERT INTO dbo.Revenues VALUES
        (1, 'Book', 5000, 'Sean'),  
        (2, 'Comics', 10000, 'Sean'),  
        (3, 'Journals', 20000, 'Davide'),  
        (4, 'Series', 40000, 'Davide')
    GO
    ```

1. Test your data with a simple `SELECT *` query.

    ```sql
    SELECT * FROM dbo.Revenues
    ```

1. Create a function named `RevenuesPredicate`. This will filter results based on the current session context.

    ```sql
    CREATE FUNCTION dbo.RevenuesPredicate(@username varchar(max))
    RETURNS TABLE
    WITH SCHEMABINDING
    AS RETURN SELECT 1 AS fn_securitypredicate_result
    WHERE @username = CAST(SESSION_CONTEXT(N'name') AS varchar(max));
    ```

1. Create a security policy named `RevenuesSecurityPolicy` using the function.

    ```sql
    CREATE SECURITY POLICY dbo.RevenuesSecurityPolicy
    ADD FILTER PREDICATE dbo.RevenuesPredicate(username)
    ON dbo.Revenues;
    ```

## Create base configuration

TODO

1. Create a new configuration while setting `--set-session-context` to true.

    ```dotnetcli
    dab init \
        --database-type mssql \
        --connection-string "<sql-connection-string>" \
        --set-session-context true
    ```

1. Add a new entity named `revenue` for the `dbo.Revenues` table.

    ```dotnetcli
    dab add revenue \
        --source "dbo.Revenues" \
        --permissions "anonymous:read"
    ```

1. Start the Data API builder tool.

    ```dotnetcli
    dab start
    ```

## Test session context

TODO

1. TODO

    ```sql
    EXEC sp_set_session_context 'name', 'Sean';
    ```

1. TODO

    ```sql
    SELECT * FROM dbo.Revenues;  
    ```

1. Navigate to the `http://localhost:5000/api/revenue` endpoint. Observe that TODO

## Related content

- [Database-specific features](reference-database-specific-features.md)
- [Use local data](how-to-use-local-data.md)
