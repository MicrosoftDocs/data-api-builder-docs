---
title: Configure runtime and data source with the DAB CLI
description: Use the Data API builder (DAB) CLI to configure runtime and data source settings in your API configuration file.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 12/12/2025
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

> [!NOTE]
> OpenTelemetry and Application Insights settings are configured with `dab add-telemetry`, not `dab configure`. See [concept/monitor/open-telemetry.md](../concept/monitor/open-telemetry.md) and [concept/monitor/application-insights.md](../concept/monitor/application-insights.md).

## Quick glance

| Option                                         | Summary                                              |
| ---------------------------------------------- | ---------------------------------------------------- |
| [`-c, --config`](#-c---config)                 | Path to the config file (default `dab-config.json`). |
| [`--data-source.database-type`](#--data-sourcedatabase-type) | Set the database type.                               |
| [`--data-source.connection-string`](#--data-sourceconnection-string) | Set the database connection string.                  |
| [`--data-source.options.database`](#--data-sourceoptionsdatabase) | Database name for Cosmos DB for NoSql.               |
| [`--data-source.options.container`](#--data-sourceoptionscontainer) | Container name for Cosmos DB for NoSql.              |
| [`--data-source.options.schema`](#--data-sourceoptionsschema) | Schema path for Cosmos DB for NoSql.                 |
| [`--data-source.options.set-session-context`](#--data-sourceoptionsset-session-context) | Enable session context.                              |
| [`--runtime.graphql.depth-limit`](#--runtimegraphqldepth-limit) | Limit maximum query depth.                           |
| [`--runtime.graphql.enabled`](#--runtimegraphqlenabled) | Enable or disable GraphQL endpoint.                  |
| [`--runtime.graphql.path`](#--runtimegraphqlpath) | Customize the GraphQL endpoint path.                 |
| [`--runtime.graphql.allow-introspection`](#--runtimegraphqlallow-introspection) | Allow or deny GraphQL introspection.                 |
| [`--runtime.graphql.multiple-mutations.create.enabled`](#--runtimegraphqlmultiple-mutationscreateenabled) | Enable multiple-create mutations.                    |
| [`--runtime.rest.enabled`](#--runtimerestenabled) | Enable or disable REST endpoint.                     |
| [`--runtime.rest.path`](#--runtimerestpath)     | Customize the REST endpoint path.                    |
| [`--runtime.rest.request-body-strict`](#--runtimerestrequest-body-strict) | Enforce strict REST request body validation.         |
| [`--runtime.mcp.enabled`](#--runtimemcpenabled) | Enable or disable MCP endpoint.                      |
| [`--runtime.mcp.path`](#--runtimemcppath)       | Customize the MCP endpoint path.                     |
| [`--runtime.mcp.dml-tools.enabled`](#--runtimemcpdml-toolsenabled) | Enable or disable all MCP DML tools.                 |
| [`--runtime.mcp.dml-tools.describe-entities.enabled`](#--runtimemcpdml-toolsdescribe-entitiesenabled) | Enable or disable the describe-entities tool.        |
| [`--runtime.mcp.dml-tools.create-record.enabled`](#--runtimemcpdml-toolscreate-recordenabled) | Enable or disable the create-record tool.            |
| [`--runtime.mcp.dml-tools.read-records.enabled`](#--runtimemcpdml-toolsread-recordsenabled) | Enable or disable the read-records tool.             |
| [`--runtime.mcp.dml-tools.update-record.enabled`](#--runtimemcpdml-toolsupdate-recordenabled) | Enable or disable the update-record tool.            |
| [`--runtime.mcp.dml-tools.delete-record.enabled`](#--runtimemcpdml-toolsdelete-recordenabled) | Enable or disable the delete-record tool.            |
| [`--runtime.mcp.dml-tools.execute-entity.enabled`](#--runtimemcpdml-toolsexecute-entityenabled) | Enable or disable the execute-entity tool.           |
| [`--runtime.cache.enabled`](#--runtimecacheenabled) | Enable or disable global cache.                      |
| [`--runtime.cache.ttl-seconds`](#--runtimecachettl-seconds) | Global cache TTL in seconds.                         |
| [`--runtime.host.mode`](#--runtimehostmode)     | Set host mode: Development or Production.            |
| [`--runtime.host.cors.origins`](#--runtimehostcorsorigins) | Allowed CORS origins.                                |
| [`--runtime.host.cors.allow-credentials`](#--runtimehostcorsallow-credentials) | Set CORS allow-credentials.                          |
| [`--runtime.host.authentication.provider`](#--runtimehostauthenticationprovider) | Authentication provider.                             |
| [`--runtime.host.authentication.jwt.audience`](#--runtimehostauthenticationjwtaudience) | JWT audience claim.                                  |
| [`--runtime.host.authentication.jwt.issuer`](#--runtimehostauthenticationjwtissuer) | JWT issuer claim.                                    |
| [`--azure-key-vault.endpoint`](#--azure-key-vaultendpoint) | Azure Key Vault base endpoint.                       |
| [`--azure-key-vault.retry-policy.mode`](#--azure-key-vaultretry-policymode) | Retry policy mode.                                   |
| [`--azure-key-vault.retry-policy.max-count`](#--azure-key-vaultretry-policymax-count) | Max retry attempts.                                  |
| [`--azure-key-vault.retry-policy.delay-seconds`](#--azure-key-vaultretry-policydelay-seconds) | Delay between retries.                               |
| [`--azure-key-vault.retry-policy.max-delay-seconds`](#--azure-key-vaultretry-policymax-delay-seconds) | Max delay for exponential retries.                   |
| [`--azure-key-vault.retry-policy.network-timeout-seconds`](#--azure-key-vaultretry-policynetwork-timeout-seconds) | Timeout for network calls.                           |
| [`--runtime.telemetry.azure-log-analytics.enabled`](#--runtimetelemetryazure-log-analyticsenabled) | Enable Azure Log Analytics telemetry.                |
| [`--runtime.telemetry.azure-log-analytics.dab-identifier`](#--runtimetelemetryazure-log-analyticsdab-identifier) | Distinguish log origin.                              |
| [`--runtime.telemetry.azure-log-analytics.flush-interval-seconds`](#--runtimetelemetryazure-log-analyticsflush-interval-seconds) | Flush cadence in seconds.                            |
| [`--runtime.telemetry.azure-log-analytics.auth.custom-table-name`](#--runtimetelemetryazure-log-analyticsauthcustom-table-name) | Custom table name.                                   |
| [`--runtime.telemetry.azure-log-analytics.auth.dcr-immutable-id`](#--runtimetelemetryazure-log-analyticsauthdcr-immutable-id) | Data Collection Rule ID.                             |
| [`--runtime.telemetry.azure-log-analytics.auth.dce-endpoint`](#--runtimetelemetryazure-log-analyticsauthdce-endpoint) | Data Collection Endpoint.                            |
| [`--runtime.telemetry.file.enabled`](#--runtimetelemetryfileenabled) | Enable file sink telemetry.                          |
| [`--runtime.telemetry.file.path`](#--runtimetelemetryfilepath) | Path to log file.                                    |
| [`--runtime.telemetry.file.rolling-interval`](#--runtimetelemetryfilerolling-interval) | Rolling interval.                                    |
| [`--runtime.telemetry.file.retained-file-count-limit`](#--runtimetelemetryfileretained-file-count-limit) | Max number of files retained.                        |
| [`--runtime.telemetry.file.file-size-limit-bytes`](#--runtimetelemetryfilefile-size-limit-bytes) | Max size per file before rolling.                    |
| [`--help`](#--help)                               | Display this help screen.                            |
| [`--version`](#--version)                         | Display version information.                         |

---

## `-c, --config`

Path to the config file. Defaults to `dab-config.json` unless `dab-config.<DAB_ENVIRONMENT>.json` exists, where `DAB_ENVIRONMENT` is an environment variable.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --config ./dab-config.json \
  --runtime.rest.enabled true
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --config ./dab-config.json ^
  --runtime.rest.enabled true
```

---

## `--data-source.database-type`

Database type.

Allowed values:

- `MSSQL`
- `PostgreSQL`
- `CosmosDB_NoSQL`
- `MySQL`

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --data-source.database-type PostgreSQL
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --data-source.database-type PostgreSQL
```

---

### Resulting config

```json
{
  "data-source": {
    "database-type": "postgresql"
  }
}
```

## `--data-source.connection-string`

Connection string for the data source.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --data-source.connection-string "Server=myserver;Database=mydb;User Id=myuser;Password=mypassword;"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --data-source.connection-string "Server=myserver;Database=mydb;User Id=myuser;Password=mypassword;"
```

---

## `--data-source.options.database`

Database name for Cosmos DB for NoSql.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --data-source.options.database MyCosmosDatabase
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --data-source.options.database MyCosmosDatabase
```

---

## `--data-source.options.container`

Container name for Cosmos DB for NoSql.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --data-source.options.container MyCosmosContainer
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --data-source.options.container MyCosmosContainer
```

---

## `--data-source.options.schema`

Schema path for Cosmos DB for NoSql.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --data-source.options.schema ./schema.gql
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --data-source.options.schema ./schema.gql
```

---

## `--data-source.options.set-session-context`

Enable session context.

Allowed values:

- `true` (default)
- `false`

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --data-source.options.set-session-context false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --data-source.options.set-session-context false
```

---

### Resulting config

```json
{
  "data-source": {
    "options": {
      "set-session-context": false
    }
  }
}
```

## `--runtime.graphql.depth-limit`

Max allowed depth of the nested query.

Allowed values:

- $(0,2147483647]$ (inclusive)
- `-1` to remove limit

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.graphql.depth-limit 3
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.graphql.depth-limit 3
```

---

### Resulting config

```json
{
  "runtime": {
    "graphql": {
      "depth-limit": 3
    }
  }
}
```

## `--runtime.graphql.enabled`

Enable DAB's GraphQL endpoint.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.graphql.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.graphql.enabled false
```

---

## `--runtime.graphql.path`

Customize DAB's GraphQL endpoint path. Prefix path with `/`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.graphql.path /graphql
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.graphql.path /graphql
```

---

## `--runtime.graphql.allow-introspection`

Allow or deny GraphQL introspection requests.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.graphql.allow-introspection false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.graphql.allow-introspection false
```

---

## `--runtime.graphql.multiple-mutations.create.enabled`

Enable or disable multiple-mutation create operations in the generated GraphQL schema.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.graphql.multiple-mutations.create.enabled true
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.graphql.multiple-mutations.create.enabled true
```

---

## `--runtime.rest.enabled`

Enable DAB's REST endpoint.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.rest.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.rest.enabled false
```

---

## `--runtime.rest.path`

Customize DAB's REST endpoint path. Prefix path with `/`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.rest.path /myapi
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.rest.path /myapi
```

---

### Resulting config

```json
{
  "runtime": {
    "rest": {
      "path": "/myapi"
    }
  }
}
```

## `--runtime.rest.request-body-strict`

Prohibit extraneous REST request body fields.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.rest.request-body-strict true
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.rest.request-body-strict true
```

---

## `--runtime.mcp.enabled`

Enable DAB's MCP endpoint.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.mcp.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.mcp.enabled false
```

---

### Resulting config

```json
{
  "runtime": {
    "mcp": {
      "enabled": false
    }
  }
}
```

## `--runtime.mcp.path`

Customize DAB's MCP endpoint path. Prefix path with `/`.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.mcp.path /mcp2
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.mcp.path /mcp2
```

---

### Resulting config

```json
{
  "runtime": {
    "mcp": {
      "path": "/mcp2"
    }
  }
}
```

## `--runtime.mcp.dml-tools.enabled`

Enable DAB's MCP DML tools endpoint.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

For more information on MCP DML tools, see [SQL MCP Server data manipulation language tools](../mcp/data-manipulation-language-tools.md).

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.mcp.dml-tools.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.mcp.dml-tools.enabled false
```

---

## `--runtime.mcp.dml-tools.describe-entities.enabled`

Enable DAB's MCP describe entities tool.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.mcp.dml-tools.describe-entities.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.mcp.dml-tools.describe-entities.enabled false
```

---

## `--runtime.mcp.dml-tools.create-record.enabled`

Enable DAB's MCP create record tool.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.mcp.dml-tools.create-record.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.mcp.dml-tools.create-record.enabled false
```

---

## `--runtime.mcp.dml-tools.read-records.enabled`

Enable DAB's MCP read record tool.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.mcp.dml-tools.read-records.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.mcp.dml-tools.read-records.enabled false
```

---

## `--runtime.mcp.dml-tools.update-record.enabled`

Enable DAB's MCP update record tool.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.mcp.dml-tools.update-record.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.mcp.dml-tools.update-record.enabled false
```

---

## `--runtime.mcp.dml-tools.delete-record.enabled`

Enable DAB's MCP delete record tool.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.mcp.dml-tools.delete-record.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.mcp.dml-tools.delete-record.enabled false
```

---

## `--runtime.mcp.dml-tools.execute-entity.enabled`

Enable DAB's MCP execute entity tool.

> [!NOTE]
> This option is available only in the v1.7 prerelease CLI (currently RC). Install with `dotnet tool install microsoft.dataapibuilder --prerelease`.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.mcp.dml-tools.execute-entity.enabled false
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.mcp.dml-tools.execute-entity.enabled false
```

---

## `--runtime.cache.enabled`

Enable DAB's cache globally. You must also enable caching for each entity.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.cache.enabled true
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.cache.enabled true
```

---

### Resulting config

```json
{
  "runtime": {
    "cache": {
      "enabled": true
    }
  }
}
```

## `--runtime.cache.ttl-seconds`

Customize the DAB cache's global default time to live in seconds.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.cache.ttl-seconds 30
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.cache.ttl-seconds 30
```

---

### Resulting config

```json
{
  "runtime": {
    "cache": {
      "enabled": false,
      "ttl-seconds": 30
    }
  }
}
```

## `--runtime.host.mode`

Set the host running mode of DAB.

Allowed values:

- `Development`
- `Production`

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.host.mode Development
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.host.mode Development
```

---

### Resulting config

```json
{
  "runtime": {
    "host": {
      "mode": "development"
    }
  }
}
```

## `--runtime.host.cors.origins`

Overwrite allowed origins in CORS. Provide values as a space-separated list.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.host.cors.origins \
  https://contoso.com \
  https://fabrikam.com
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.host.cors.origins ^
  https://contoso.com ^
  https://fabrikam.com
```

---

### Resulting config

```json
{
  "runtime": {
    "host": {
      "cors": {
        "origins": [
          "https://contoso.com",
          "https://fabrikam.com"
        ]
      }
    }
  }
}
```

## `--runtime.host.cors.allow-credentials`

Set the value for the `Access-Control-Allow-Credentials` header.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.host.cors.allow-credentials true
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.host.cors.allow-credentials true
```

---

## `--runtime.host.authentication.provider`

Configure the name of authentication provider.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.host.authentication.provider AppService
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.host.authentication.provider AppService
```

---

## `--runtime.host.authentication.jwt.audience`

Configure the intended recipient(s) of the JWT token.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.host.authentication.jwt.audience api://my-app
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.host.authentication.jwt.audience api://my-app
```

---

## `--runtime.host.authentication.jwt.issuer`

Configure the entity that issued the JWT token.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.host.authentication.jwt.issuer https://login.microsoftonline.com/common/v2.0
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.host.authentication.jwt.issuer https://login.microsoftonline.com/common/v2.0
```

---

### Resulting config

```json
{
  "runtime": {
    "host": {
      "authentication": {
        "provider": "AppService",
        "jwt": {
          "audience": "api://my-app",
          "issuer": "https://login.microsoftonline.com/common/v2.0"
        }
      }
    }
  }
}
```

## `--azure-key-vault.endpoint`

Configure the Azure Key Vault endpoint URL.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --azure-key-vault.endpoint https://my-vault.vault.azure.net
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --azure-key-vault.endpoint https://my-vault.vault.azure.net
```

---

## `--azure-key-vault.retry-policy.mode`

Configure the retry policy mode.

Allowed values:

- `fixed`
- `exponential`

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --azure-key-vault.retry-policy.mode fixed
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --azure-key-vault.retry-policy.mode fixed
```

---

## `--azure-key-vault.retry-policy.max-count`

Configure the maximum number of retry attempts.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --azure-key-vault.retry-policy.max-count 5
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --azure-key-vault.retry-policy.max-count 5
```

---

## `--azure-key-vault.retry-policy.delay-seconds`

Configure the initial delay between retries in seconds.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --azure-key-vault.retry-policy.delay-seconds 2
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --azure-key-vault.retry-policy.delay-seconds 2
```

---

## `--azure-key-vault.retry-policy.max-delay-seconds`

Configure the maximum delay between retries in seconds (for exponential mode).

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --azure-key-vault.retry-policy.max-delay-seconds 30
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --azure-key-vault.retry-policy.max-delay-seconds 30
```

---

## `--azure-key-vault.retry-policy.network-timeout-seconds`

Configure the network timeout for requests in seconds.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --azure-key-vault.retry-policy.network-timeout-seconds 20
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --azure-key-vault.retry-policy.network-timeout-seconds 20
```

---

### Resulting config

```json
{
  "azure-key-vault": {
    "retry-policy": {
      "mode": "fixed",
      "max-count": 5,
      "delay-seconds": 2,
      "max-delay-seconds": 30,
      "network-timeout-seconds": 20
    }
  }
}
```

## `--runtime.telemetry.azure-log-analytics.enabled`

Enable or disable Azure Log Analytics.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.azure-log-analytics.enabled true
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.azure-log-analytics.enabled true
```

---

## `--runtime.telemetry.azure-log-analytics.dab-identifier`

Configure a DAB identifier string used in Azure Log Analytics.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.azure-log-analytics.dab-identifier MyDab
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.azure-log-analytics.dab-identifier MyDab
```

---

## `--runtime.telemetry.azure-log-analytics.flush-interval-seconds`

Configure flush interval in seconds for Azure Log Analytics.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.azure-log-analytics.flush-interval-seconds 10
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.azure-log-analytics.flush-interval-seconds 10
```

---

## `--runtime.telemetry.azure-log-analytics.auth.custom-table-name`

Configure custom table name for Azure Log Analytics.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.azure-log-analytics.auth.custom-table-name MyDabLogs
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.azure-log-analytics.auth.custom-table-name MyDabLogs
```

---

## `--runtime.telemetry.azure-log-analytics.auth.dcr-immutable-id`

Configure DCR immutable ID for Azure Log Analytics.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.azure-log-analytics.auth.dcr-immutable-id dcr-123
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.azure-log-analytics.auth.dcr-immutable-id dcr-123
```

---

## `--runtime.telemetry.azure-log-analytics.auth.dce-endpoint`

Configure DCE endpoint for Azure Log Analytics.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.azure-log-analytics.auth.dce-endpoint https://example.eastus-1.ingest.monitor.azure.com
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.azure-log-analytics.auth.dce-endpoint https://example.eastus-1.ingest.monitor.azure.com
```

---

### Resulting config

```json
{
  "runtime": {
    "telemetry": {
      "azure-log-analytics": {
        "enabled": true,
        "auth": {
          "custom-table-name": "MyDabLogs",
          "dcr-immutable-id": "dcr-123",
          "dce-endpoint": "https://example.eastus-1.ingest.monitor.azure.com"
        },
        "dab-identifier": "MyDab",
        "flush-interval-seconds": 10
      }
    }
  }
}
```

## `--runtime.telemetry.file.enabled`

Enable or disable file sink logging.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.file.enabled true
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.file.enabled true
```

---

## `--runtime.telemetry.file.path`

Configure path for file sink logging.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.file.path C:\\logs\\dab-log.txt
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.file.path C:\\logs\\dab-log.txt
```

---

## `--runtime.telemetry.file.rolling-interval`

Configure rolling interval for file sink logging.

Allowed values:

- `Minute`
- `Hour`
- `Day`
- `Month`
- `Year`
- `Infinite`

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.file.rolling-interval Month
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.file.rolling-interval Month
```

---

## `--runtime.telemetry.file.retained-file-count-limit`

Configure maximum number of retained files.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.file.retained-file-count-limit 5
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.file.retained-file-count-limit 5
```

---

## `--runtime.telemetry.file.file-size-limit-bytes`

Configure maximum file size limit in bytes.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.telemetry.file.file-size-limit-bytes 2097152
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.telemetry.file.file-size-limit-bytes 2097152
```

---

### Resulting config

```json
{
  "runtime": {
    "telemetry": {
      "file": {
        "enabled": true,
        "path": "C:\\logs\\dab-log.txt",
        "rolling-interval": "Month",
        "retained-file-count-limit": 5,
        "file-size-limit-bytes": 2097152
      }
    }
  }
}
```

## `--help`

Display this help screen.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --help
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --help
```

---

## `--version`

Display version information.

### Example

#### [Bash](#tab/bash)

```bash
dab configure \
  --version
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --version
```

---
