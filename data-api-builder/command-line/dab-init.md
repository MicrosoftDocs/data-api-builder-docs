---
title: Initialize a config with the DAB CLI
description: Use the Data API builder (DAB) CLI to initialize a new API configuration file.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 09/29/2025
# Customer Intent: As a developer, I want to initialize a Data API builder configuration, so that I can begin defining APIs for my database.
---

# `init` command

Initialize a new Data API builder configuration file. The resulting JSON captures data source details, enabled endpoints (REST, GraphQL, MCP), authentication, and runtime behaviors.

## Syntax

```bash
dab init [options]
```

If the target config file already exists, the command overwrites it. There is no merge. Use version control or backups if you need to preserve the previous file.

### Quick glance

| Option                         | Summary                                           |
| ------------------------------ | ------------------------------------------------- |
| [`-c, --config`](#-c---config) | Output config file name (default dab-config.json) |

#### Authentication

| Option                               | Summary                                   |
| ------------------------------------ | ----------------------------------------- |
| [`--auth.audience`](#--authaudience) | JWT audience claim                        |
| [`--auth.issuer`](#--authissuer)     | JWT issuer claim                          |
| [`--auth.provider`](#--authprovider) | Identity provider (default StaticWebApps) |

#### Data Source

| Option                                                      | Summary                                                                                |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| [`--connection-string`](#--connection-string)               | Database connection string (supports `@env()`)                                         |
| [`--cosmosdb_nosql-container`](#--cosmosdb_nosql-container) | Cosmos DB NoSQL container name (optional)                                              |
| [`--cosmosdb_nosql-database`](#--cosmosdb_nosql-database)   | Cosmos DB NoSQL database name (required for cosmosdb_nosql)                            |
| [`--database-type`](#--database-type)                       | Database type: `mssql`, `mysql`, `postgresql`, `cosmosdb_postgresql`, `cosmosdb_nosql` |
| [`--set-session-context`](#--set-session-context)           | Enable SQL Server session context (mssql only)                                         |

#### GraphQL

| Option                                                                  | Summary                                                      |
| ----------------------------------------------------------------------- | ------------------------------------------------------------ |
| [`--graphql.disabled`](#--graphqldisabled)                              | Deprecated. Disables GraphQL (use `--graphql.enabled false`) |
| [`--graphql.enabled`](#--graphqlenabled)                                | Enable GraphQL (default true)                                |
| [`--graphql.multiple-create.enabled`](#--graphqlmultiple-createenabled) | Allow multiple create mutations (default false)              |
| [`--graphql.path`](#--graphqlpath)                                      | GraphQL endpoint prefix (default /graphql)                   |
| [`--graphql-schema`](#--graphql-schema)                                 | Path to GraphQL schema (required for cosmosdb_nosql)         |

#### Host and authentication

| Option                                         | Summary                                                   |
| ---------------------------------------------- | --------------------------------------------------------- |
| [`--host-mode`](#--host-mode)                  | Host mode: Development or Production (default Production) |
| [`--cors-origin`](#--cors-origin)              | Allowed origins list (comma-separated)                    |
| [`--runtime.base-route`](#--runtimebase-route) | Global prefix for all endpoints                           |

#### MCP

| Option                             | Summary                                              |
| ---------------------------------- | ---------------------------------------------------- |
| [`--mcp.disabled`](#--mcpdisabled) | Deprecated. Disables MCP (use `--mcp.enabled false`) |
| [`--mcp.enabled`](#--mcpenabled)   | Enable MCP (default true)                            |
| [`--mcp.path`](#--mcppath)         | MCP endpoint prefix (default /mcp)                   |

> [!Note]
> MCP capability will be part of version 1.7.

#### REST

| Option                                                     | Summary                                                                           |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------- |
| [`--rest.disabled`](#--restdisabled)                       | Deprecated. Disables REST (use `--rest.enabled false`)                            |
| [`--rest.enabled`](#--restenabled)                         | Enable REST (default true, prefer over `--rest.disabled`)                         |
| [`--rest.path`](#--restpath)                               | REST endpoint prefix (default /api, ignored for cosmosdb_nosql)                   |
| [`--rest.request-body-strict`](#--restrequest-body-strict) | Enforce strict request body validation (default true, ignored for cosmosdb_nosql) |

> [!IMPORTANT]
> Do not mix the new `--*.enabled` flags and the legacy `--*.disabled` flags for the same subsystem in the same command. Prefer the `--*.enabled` pattern; the `--rest.disabled`, `--graphql.disabled`, and `--mcp.disabled` options log warnings and will be removed in future versions.

## `-c, --config`

Output configuration file name. Default is `dab-config.json`.

### Example

```bash
dab init --database-type mssql --config dab-config.local.json
```

### Resulting config

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('MSSQL_CONNECTION_STRING')"
  }
}
```

## `--auth.audience`

JWT audience claim.

### Example

```bash
dab init --database-type mssql --auth.audience "https://example.com/api"
```

### Resulting config

```json
{
  "runtime": {
    "authentication": {
      "audience": "https://example.com/api"
    }
  }
}
```

## `--auth.issuer`

JWT issuer claim.

### Example

```bash
dab init --database-type mssql --auth.issuer "https://login.microsoftonline.com/{tenant-id}/v2.0"
```

### Resulting config

```json
{
  "runtime": {
    "authentication": {
      "issuer": "https://login.microsoftonline.com/{tenant-id}/v2.0"
    }
  }
}
```

## `--auth.provider`

Identity provider. Default is `StaticWebApps`.

### Example

```bash
dab init --database-type mssql --auth.provider AzureAD
```

### Resulting config

```json
{
  "runtime": {
    "authentication": {
      "provider": "AzureAD"
    }
  }
}
```

## `--connection-string`

Database connection string. Supports `@env()`.

### Example

```bash
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')"
```

### Resulting config

```json
{
  "data-source": {
    "connection-string": "@env('MSSQL_CONNECTION_STRING')"
  }
}
```

## `--cors-origin`

Comma-separated list of allowed origins.

### Example

```bash
dab init --database-type mssql --cors-origin "https://app.example.com,https://admin.example.com"
```

### Resulting config

```json
{
  "runtime": {
    "cors": {
      "origins": [ "https://app.example.com", "https://admin.example.com" ]
    }
  }
}
```

## `--cosmosdb_nosql-container`

Cosmos DB NoSQL container name.

### Example

```bash
dab init --database-type cosmosdb_nosql --cosmosdb_nosql-container MyContainer
```

### Resulting config

```json
{
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "options": {
      "container": "MyContainer"
    }
  }
}
```

## `--cosmosdb_nosql-database`

Cosmos DB NoSQL database name. Required for `cosmosdb_nosql`.

### Example

```bash
dab init --database-type cosmosdb_nosql --cosmosdb_nosql-database MyDb
```

### Resulting config

```json
{
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "options": {
      "database": "MyDb"
    }
  }
}
```

## `--database-type`

Specifies the target database engine. Supported values: `mssql`, `mysql`, `postgresql`, `cosmosdb_postgresql`, `cosmosdb_nosql`.

### Example

```bash
dab init --database-type mssql
```

### Resulting config

```json
{
  "data-source": {
    "database-type": "mssql"
  }
}
```

## `--graphql.disabled`

Deprecated. Disables GraphQL. Prefer `--graphql.enabled false`.

## `--graphql.enabled`

Enable GraphQL endpoint. Default is `true`.

### Example

```bash
dab init --database-type mssql --graphql.enabled false
```

### Resulting config

```json
{
  "runtime": {
    "graphql": {
      "enabled": false
    }
  }
}
```

## `--graphql.multiple-create.enabled`

Allows multiple row creation in a single mutation. Default is `false`.

### Example

```bash
dab init --database-type mssql --graphql.multiple-create.enabled true
```

### Resulting config

```json
{
  "runtime": {
    "graphql": {
      "multiple-create": { "enabled": true }
    }
  }
}
```

## `--graphql.path`

GraphQL endpoint prefix. Default is `/graphql`.

### Example

```bash
dab init --database-type mssql --graphql.path /gql
```

### Resulting config

```json
{
  "runtime": {
    "graphql": {
      "path": "/gql"
    }
  }
}
```

## `--graphql-schema`

Path to a GraphQL schema file. Required for `cosmosdb_nosql`.

### Example

```bash
dab init --database-type cosmosdb_nosql --graphql-schema ./schema.gql
```

### Resulting config

```json
{
  "runtime": {
    "graphql": {
      "schema": "./schema.gql"
    }
  }
}
```

## `--host-mode`

Host mode. Default is `Production`.

Valid values: `Development`, `Production`.

### Example

```bash
dab init --database-type mssql --host-mode development
```

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

## `--mcp.disabled`

Deprecated. Disables MCP. Prefer `--mcp.enabled false`.

## `--mcp.enabled`

Enable MCP endpoint. Default is `true`.

### Example

```bash
dab init --database-type mssql --mcp.enabled false
```

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

## `--mcp.path`

MCP endpoint prefix. Default is `/mcp`.

### Example

```bash
dab init --database-type mssql --mcp.path /model
```

### Resulting config

```json
{
  "runtime": {
    "mcp": {
      "path": "/model"
    }
  }
}
```

## `--rest.disabled`

Deprecated. Disables REST. Prefer `--rest.enabled false`.

## `--rest.enabled`

Enable REST endpoint. Default is `true`.

### Example

```bash
dab init --database-type mssql --rest.enabled false
```

### Resulting config

```json
{
  "runtime": {
    "rest": {
      "enabled": false
    }
  }
}
```

## `--rest.path`

REST endpoint prefix. Default is `/api`.

> [!Note]
> Ignored for `cosmosdb_nosql`.

### Example

```bash
dab init --database-type mssql --rest.path /rest
```

### Resulting config

```json
{
  "runtime": {
    "rest": {
      "path": "/rest"
    }
  }
}
```

## `--rest.request-body-strict`

Controls handling of extra fields in request bodies. Default is `true`.

* `true`: Rejects extraneous fields (HTTP 400).
* `false`: Ignores extra fields.

> [!Note]
> Ignored for `cosmosdb_nosql`.

### Example

```bash
dab init --database-type mssql --rest.request-body-strict false
```

### Resulting config

```json
{
  "runtime": {
    "rest": {
      "request-body-strict": false
    }
  }
}
```

## `--runtime.base-route`

Global prefix prepended to all endpoints. Must begin with `/`.

### Example

```bash
dab init --database-type mssql --runtime.base-route /v1
```

### Resulting config

```json
{
  "runtime": {
    "base-route": "/v1"
  }
}
```

## `--set-session-context`

Enable sending data to SQL Server using session context. Only valid for `mssql`. Default is `false`.

### Example

```bash
dab init --database-type mssql --set-session-context true
```

### Resulting config

```json
{
  "runtime": {
    "mssql": {
      "set-session-context": true
    }
  }
}
```
