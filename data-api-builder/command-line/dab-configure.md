---
title: Configure runtime and data source with the DAB CLI
description: Use the Data API builder (DAB) CLI to configure runtime and data source settings in your API configuration file.
author: seesharprun
ms.author: jerrynixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: command-line
ms.date: 09/29/2025
# Customer Intent: As a developer, I want to configure runtime and data source settings in Data API builder, so that my API runs correctly.
---

# `configure` command

Configure non-entity runtime and data source properties in an existing Data API builder configuration file.
Unspecified options leave existing values unchanged. If any provided option is invalid, the entire update fails (all-or-nothing).

## Syntax

```bash
dab configure [options]
```

> [!NOTE]
> This command does not alter the `entities` section. Use `dab update` for entity changes.

## Quick glance

| Option         | Summary                                              |
| -------------- | ---------------------------------------------------- |
| `-c, --config` | Path to the config file (default `dab-config.json`). |

### Azure Key Vault

| Option                                                   | Summary                                   |
| -------------------------------------------------------- | ----------------------------------------- |
| `--azure-key-vault.endpoint`                             | Azure Key Vault base endpoint.            |
| `--azure-key-vault.retry-policy.delay-seconds`           | Delay between retries.                    |
| `--azure-key-vault.retry-policy.max-count`               | Max retry attempts.                       |
| `--azure-key-vault.retry-policy.max-delay-seconds`       | Max delay for exponential retries.        |
| `--azure-key-vault.retry-policy.mode`                    | Retry policy mode (fixed or exponential). |
| `--azure-key-vault.retry-policy.network-timeout-seconds` | Timeout for network calls.                |

### Cache

| Option                        | Summary                         |
| ----------------------------- | ------------------------------- |
| `--runtime.cache.enabled`     | Enable or disable global cache. |
| `--runtime.cache.ttl-seconds` | Global cache TTL in seconds.    |

### Data Source

| Option                                      | Summary                                                                                |
| ------------------------------------------- | -------------------------------------------------------------------------------------- |
| `--data-source.connection-string`           | Set the database connection string.                                                    |
| `--data-source.database-type`               | Set the database type (mssql, mysql, postgresql, cosmosdb_postgresql, cosmosdb_nosql). |
| `--data-source.options.container`           | Container name (Cosmos DB).                                                            |
| `--data-source.options.database`            | Database name (Cosmos DB, PostgreSQL).                                                 |
| `--data-source.options.schema`              | Schema name (SQL Server, PostgreSQL).                                                  |
| `--data-source.options.set-session-context` | Enable SQL Server session context (mssql only).                                        |

### GraphQL

| Option                                                | Summary                                  |
| ----------------------------------------------------- | ---------------------------------------- |
| `--runtime.graphql.allow-introspection`               | Enable or disable GraphQL introspection. |
| `--runtime.graphql.depth-limit`                       | Limit maximum query depth.               |
| `--runtime.graphql.enabled`                           | Enable or disable GraphQL endpoint.      |
| `--runtime.graphql.multiple-mutations.create.enabled` | Enable multiple create mutations.        |
| `--runtime.graphql.path`                              | Path prefix for GraphQL endpoint.        |

### Host

| Option                                       | Summary                                   |
| -------------------------------------------- | ----------------------------------------- |
| `--runtime.host.authentication.jwt.audience` | JWT audience claim.                       |
| `--runtime.host.authentication.jwt.issuer`   | JWT issuer claim.                         |
| `--runtime.host.authentication.provider`     | Authentication provider.                  |
| `--runtime.host.cors.allow-credentials`      | Whether CORS allows credentials.          |
| `--runtime.host.cors.origins`                | Allowed CORS origins.                     |
| `--runtime.host.mode`                        | Set host mode: Development or Production. |

### MCP

| Option                  | Summary                         |
| ----------------------- | ------------------------------- |
| `--runtime.mcp.enabled` | Enable or disable MCP endpoint. |
| `--runtime.mcp.path`    | Path prefix for MCP endpoint.   |

### MCP DML Tools

| Option                                              | Summary                                       |
| --------------------------------------------------- | --------------------------------------------- |
| `--runtime.mcp.dml-tools.create-record.enabled`     | Enable or disable the create-record tool.     |
| `--runtime.mcp.dml-tools.delete-record.enabled`     | Enable or disable the delete-record tool.     |
| `--runtime.mcp.dml-tools.describe-entities.enabled` | Enable or disable the describe-entities tool. |
| `--runtime.mcp.dml-tools.enabled`                   | Enable or disable all MCP DML tools.          |
| `--runtime.mcp.dml-tools.execute-entity.enabled`    | Enable or disable the execute-entity tool.    |
| `--runtime.mcp.dml-tools.read-records.enabled`      | Enable or disable the read-records tool.      |
| `--runtime.mcp.dml-tools.update-record.enabled`     | Enable or disable the update-record tool.     |

### REST

| Option                               | Summary                                 |
| ------------------------------------ | --------------------------------------- |
| `--runtime.rest.enabled`             | Enable or disable REST endpoint.        |
| `--runtime.rest.path`                | Path prefix for REST endpoint.          |
| `--runtime.rest.request-body-strict` | Enforce strict request body validation. |

### Telemetry – Azure Log Analytics

| Option                                                           | Summary                               |
| ---------------------------------------------------------------- | ------------------------------------- |
| `--runtime.telemetry.azure-log-analytics.auth.custom-table-name` | Custom table name.                    |
| `--runtime.telemetry.azure-log-analytics.auth.dce-endpoint`      | Data Collection Endpoint.             |
| `--runtime.telemetry.azure-log-analytics.auth.dcr-immutable-id`  | Data Collection Rule ID.              |
| `--runtime.telemetry.azure-log-analytics.dab-identifier`         | Distinguishes log origin.             |
| `--runtime.telemetry.azure-log-analytics.enabled`                | Enable Azure Log Analytics telemetry. |
| `--runtime.telemetry.azure-log-analytics.flush-interval-seconds` | Flush cadence in seconds.             |

### Telemetry – File Sink

| Option                                               | Summary                                                      |
| ---------------------------------------------------- | ------------------------------------------------------------ |
| `--runtime.telemetry.file.enabled`                   | Enable file sink telemetry.                                  |
| `--runtime.telemetry.file.file-size-limit-bytes`     | Max size per file before rolling.                            |
| `--runtime.telemetry.file.path`                      | Path to log file.                                            |
| `--runtime.telemetry.file.retained-file-count-limit` | Max number of files retained.                                |
| `--runtime.telemetry.file.rolling-interval`          | Rolling interval (Minute, Hour, Day, Month, Year, Infinite). |
