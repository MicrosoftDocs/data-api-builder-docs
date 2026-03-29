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
