---
title: SQL Server troubleshooting - Data API builder
description: Troubleshoot common SQL Server connection, authentication, and configuration issues in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: troubleshooting
ms.date: 03/29/2026
---

# SQL Server troubleshooting

> [!div class="checklist"]
> Solutions for common SQL Server connectivity, authentication, and entity configuration issues in Data API builder.

## Common questions

### What is SQL Server support in DAB?

Data API builder supports Microsoft SQL Server and Azure SQL as relational database back ends. DAB connects using the Microsoft.Data.SqlClient driver and translates REST and GraphQL requests into T-SQL queries. Both on-premises SQL Server instances and Azure SQL Database are supported.

### What connection string format does SQL Server use?

DAB uses ADO.NET-style connection strings for SQL Server. A typical string looks like `Server=localhost,1433;Database=mydb;User Id=sa;Password=yourpassword;TrustServerCertificate=True;`. Set the connection string in the `data-source.connection-string` field of `dab-config.json` or pass it via the `--connection-string` option in `dab init`.

### What authentication modes are supported?

DAB supports SQL authentication (username and password), Windows Integrated Authentication, and Microsoft Entra authentication (formerly Azure Active Directory) for Azure SQL. To use Entra authentication, set `Authentication=Active Directory Default` or `Active Directory Managed Identity` in the connection string and ensure the managed identity or service principal has been granted database access.

## Common issues

### Cannot connect to SQL Server container

**Symptom:** DAB fails to start with a connection error such as `A network-related or instance-specific error occurred`.

**Cause:** The SQL Server container port is not mapped correctly, the hostname is wrong, or the container is not yet ready to accept connections.

**Resolution:** Verify the container is running with `docker ps`. Confirm the port mapping (default `1433`) and use `localhost,1433` in the connection string. Add `TrustServerCertificate=True` if using a self-signed certificate. If the container just started, wait a few seconds for SQL Server to initialize before starting DAB.

### Login failed for user

**Symptom:** DAB logs show `Login failed for user 'sa'` or a similar authentication error.

**Cause:** The username, password, or authentication mode in the connection string does not match the SQL Server configuration. SQL Server may also be running in Windows Authentication-only mode.

**Resolution:** Confirm the credentials match those set when the container or server was created. If using a container, check the `SA_PASSWORD` environment variable. To enable SQL authentication on an existing instance, set the server authentication mode to *SQL Server and Windows Authentication mode* in SQL Server Management Studio under **Server Properties > Security**.

### Entity not found error

**Symptom:** REST or GraphQL requests return a `404` or schema error indicating the entity's source table does not exist.

**Cause:** The table name or schema prefix in the entity's `source` field does not match the actual database object. SQL Server table names are case-insensitive by default but the schema prefix (for example, `dbo`) must be present if the default schema is not used.

**Resolution:** Check the `source` value in `dab-config.json`. Use a fully qualified name such as `dbo.Products`. Run `SELECT * FROM INFORMATION_SCHEMA.TABLES` in the target database to confirm the table name and schema.

### Firewall or network error connecting to Azure SQL

**Symptom:** Connections to Azure SQL Database time out or return `Cannot open server ... requested by the login`.

**Cause:** The client IP address is not allowed by the Azure SQL server firewall rules, or the Azure service access setting is disabled.

**Resolution:** In the Azure portal, navigate to the SQL server resource and select **Networking**. Add the client IP address to the firewall allow list, or enable **Allow Azure services and resources to access this server** if DAB is running in Azure. For managed identity authentication, verify the identity has been added as a database user with `CREATE USER [identity-name] FROM EXTERNAL PROVIDER`.

### JSON columns are not detected automatically

**Symptom:** A column with a JSON or NVARCHAR(MAX) type that stores JSON data is not exposed as a structured object in the API schema.

**Cause:** Data API builder does not yet automatically detect and map JSON columns in Azure SQL. This is a known limitation tracked in [GitHub issue #444](https://github.com/Azure/data-api-builder/issues/444).

**Resolution:** There is no workaround at this time. The column will be exposed as a plain string value. Follow the GitHub issue for updates on when native JSON column support is added.
