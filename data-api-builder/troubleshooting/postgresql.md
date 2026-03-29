---
title: PostgreSQL troubleshooting - Data API builder
description: Troubleshoot common PostgreSQL connection, authentication, and schema configuration issues in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: troubleshooting
ms.date: 03/29/2026
---

# PostgreSQL troubleshooting

> [!div class="checklist"]
> Solutions for common PostgreSQL connectivity, schema, and SSL issues in Data API builder.

## Common questions

### What is PostgreSQL support in DAB?

Data API builder supports PostgreSQL as a relational database back end. DAB connects using the Npgsql driver and translates REST and GraphQL requests into SQL queries. Both self-hosted PostgreSQL instances and managed services such as Azure Database for PostgreSQL are supported.

### What connection string format does PostgreSQL use?

DAB uses an ADO.NET-style connection string for PostgreSQL. A typical string looks like `Host=localhost;Port=5432;Database=mydb;Username=myuser;Password=mypassword;`. Set the connection string in the `data-source.connection-string` field of `dab-config.json` or pass it via `--connection-string` in `dab init`.

### Does DAB support PostgreSQL schemas?

Yes. DAB supports non-public schemas. Reference the schema explicitly in the entity's `source` field using the format `schemaname.tablename` (for example, `sales.orders`). The database user configured in the connection string must have `USAGE` privilege on the schema and `SELECT`, `INSERT`, `UPDATE`, or `DELETE` privileges on the target tables.

## Common issues

### Cannot connect to PostgreSQL container

**Symptom:** DAB fails to start with `Failed to connect to localhost:5432` or a similar network error.

**Cause:** The PostgreSQL container port is not mapped or the container is not ready to accept connections.

**Resolution:** Confirm the container is running with `docker ps` and that port `5432` is mapped to the host. Use `Host=localhost;Port=5432` in the connection string. If the container just started, allow a few seconds for PostgreSQL to initialize before starting DAB.

### Password authentication failed

**Symptom:** DAB logs show `28P01: password authentication failed for user`.

**Cause:** The username or password in the connection string is incorrect, or the PostgreSQL user is configured for a different authentication method such as `peer` or `ident`.

**Resolution:** Verify the credentials match those set when the PostgreSQL instance or container was created. For containers, check the `POSTGRES_PASSWORD` and `POSTGRES_USER` environment variables. If running locally, confirm `pg_hba.conf` allows `md5` or `scram-sha-256` authentication for the connecting host.

### Schema not found when entity references a non-public schema

**Symptom:** DAB returns a `relation "tablename" does not exist` error even though the table exists in the database.

**Cause:** The entity's `source` field omits the schema prefix, so PostgreSQL searches only the `public` schema by default.

**Resolution:** Update the `source` value in `dab-config.json` to include the schema prefix, for example `sales.orders`. Confirm the database user has `USAGE` on the schema by running `GRANT USAGE ON SCHEMA sales TO myuser;` in `psql`.

### SSL required error connecting to Azure Database for PostgreSQL

**Symptom:** Connections to Azure Database for PostgreSQL fail with `SSL connection is required`.

**Cause:** Azure Database for PostgreSQL enforces SSL by default. Connections without SSL are rejected.

**Resolution:** Append `Ssl Mode=Require;` to the connection string. For full certificate validation, also set `Trust Server Certificate=false` and provide the server CA certificate path via `Root Certificate=path/to/ca.pem`. Download the certificate bundle from the Azure portal under the server's **Networking** settings.
