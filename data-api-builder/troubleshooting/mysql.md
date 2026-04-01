---
title: MySQL troubleshooting - Data API builder
description: Troubleshoot common MySQL connection, authentication, and compatibility issues in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: troubleshooting
ms.date: 03/29/2026
---

# MySQL troubleshooting

> [!div class="checklist"]
> Solutions for common MySQL connectivity, authentication, and data type issues in Data API builder.

## Common questions

### What is MySQL support in DAB?

Data API builder supports MySQL as a relational database back end. DAB connects using the MySqlConnector driver and translates REST and GraphQL requests into SQL queries. Both self-hosted MySQL instances and managed services such as Azure Database for MySQL are supported.

### What connection string format does MySQL use?

DAB uses a standard MySQL ADO.NET connection string. A typical string looks like `Server=localhost;Port=3306;Database=mydb;Uid=myuser;Pwd=mypassword;`. Set the connection string in the `data-source.connection-string` field of `dab-config.json` or pass it via `--connection-string` in `dab init`.

### What MySQL versions are supported?

DAB supports MySQL 8.0 and later. MySQL 5.7 may work but is not officially supported. Confirm your server version with `SELECT VERSION();` in the MySQL shell. If you are on a managed service such as Azure Database for MySQL, use the Flexible Server tier, which supports MySQL 8.0.

## Common issues

### Cannot connect to MySQL container

**Symptom:** DAB fails to start with `Unable to connect to any of the specified MySQL hosts`.

**Cause:** The MySQL container port is not mapped, the hostname is wrong, or the container has not finished initializing.

**Resolution:** Confirm the container is running with `docker ps` and that port `3306` is mapped to the host. Use `Server=localhost;Port=3306` in the connection string. Allow a few seconds after container start for MySQL to finish initializing before starting DAB.

### Access denied for user

**Symptom:** DAB logs show `Access denied for user 'myuser'@'172.x.x.x'` or similar.

**Cause:** The MySQL user account is restricted to a specific host. When DAB runs in Docker, connections originate from the container network IP, not `localhost`.

**Resolution:** Grant the user access from any host by running `GRANT ALL PRIVILEGES ON mydb.* TO 'myuser'@'%' IDENTIFIED BY 'mypassword'; FLUSH PRIVILEGES;`. For production, replace `%` with the specific host or subnet. Verify the password matches by running `mysql -u myuser -p` from the same network.

### Unknown database error

**Symptom:** DAB returns `Unknown database 'mydb'` during startup.

**Cause:** The database specified in the connection string has not been created on the MySQL server.

**Resolution:** Create the database before starting DAB by running `CREATE DATABASE mydb;` in the MySQL shell. If using a container, set the `MYSQL_DATABASE` environment variable so MySQL creates the database on first start.

### Unsupported column type warning

**Symptom:** DAB logs a warning about an unsupported column type and the field is missing from the generated schema.

**Cause:** Certain MySQL-specific types such as `SET`, `ENUM`, or spatial types may not have a direct mapping in DAB's type system.

**Resolution:** Review the DAB logs to identify the column and type. Consider altering the column to a supported type such as `VARCHAR` for `ENUM` fields, or exclude the column from the entity definition using the `mappings` configuration to omit it from the exposed schema.

### Update fails on views

**Symptom:** A PUT or PATCH request on an entity backed by a MySQL view fails with an error or has no effect.

**Cause:** Data API builder does not currently support update operations on MySQL views. This is a known limitation tracked in [GitHub issue #938](https://github.com/Azure/data-api-builder/issues/938).

**Resolution:** Use a base table entity for write operations. If the view is read-only by design, set "update": false in the entity's permissions to make the limitation explicit.

### Update fails on tables with computed columns

**Symptom:** A PUT or PATCH request on a MySQL table that contains computed columns fails or returns an error.

**Cause:** Data API builder does not correctly handle computed columns during update operations in MySQL. This is a known limitation tracked in [GitHub issue #1001](https://github.com/Azure/data-api-builder/issues/1001).

**Resolution:** There is no workaround at this time. Exclude computed columns from the entity's mappings if possible, or avoid update operations on affected entities until the issue is resolved.

### Nested filtering is not supported

**Symptom:** A REST \ or GraphQL ilter query that filters on a related entity field returns an error or unexpected results on a MySQL-backed entity.

**Cause:** Data API builder does not currently support nested filtering for MySQL. This is a known limitation tracked in [GitHub issue #1019](https://github.com/Azure/data-api-builder/issues/1019).

**Resolution:** Apply filtering on the top-level entity fields only. For nested data, retrieve the parent and filter client-side, or restructure the query to avoid nested predicates.

### Stored procedures are not supported

**Symptom:** Configuring a MySQL stored procedure as an entity source fails or the entity does not behave as expected.

**Cause:** Data API builder does not currently support stored procedures for MySQL. This is a known limitation tracked in [GitHub issue #1024](https://github.com/Azure/data-api-builder/issues/1024).

**Resolution:** Use a table or view as the entity source instead. Follow the GitHub issue for updates on when MySQL stored procedure support is added.

### Database policy is not enforced for Create operations

**Symptom:** A create mutation or POST request succeeds even when a database policy should restrict the operation.

**Cause:** Database policy support for Create actions in MySQL is not yet implemented. This is a known limitation tracked in [GitHub issue #1329](https://github.com/Azure/data-api-builder/issues/1329).

**Resolution:** Use role-based permissions to restrict create access until database policy support for MySQL Create is available.

### Database policy is not enforced for PUT and PATCH operations

**Symptom:** A PUT or PATCH request on a MySQL entity succeeds even when a database policy should restrict it.

**Cause:** Database policy support for PUT and PATCH operations in MySQL is not yet implemented. This is a known limitation tracked in [GitHub issue #1371](https://github.com/Azure/data-api-builder/issues/1371).

**Resolution:** Use role-based permissions to restrict update access until database policy support for MySQL update operations is available.

### On-Behalf-Of (OBO) authentication is not supported

**Symptom:** Configuring On-Behalf-Of (OBO) authentication for a MySQL-backed DAB instance fails or the token is not forwarded to the database as expected.

**Cause:** OBO authentication is currently only supported for SQL Server and Azure SQL. Support for MySQL has not yet been implemented. This is a known limitation tracked in [GitHub issue #3159](https://github.com/Azure/data-api-builder/issues/3159).

**Resolution:** Use a supported authentication method such as connection string credentials for MySQL. Follow the GitHub issue for updates on when OBO support is expanded to non-SQL Server databases.
