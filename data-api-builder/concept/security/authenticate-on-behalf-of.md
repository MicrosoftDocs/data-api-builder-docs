---
title: Configure On-Behalf-Of (OBO) user-delegated authentication
description: Learn how to configure On-Behalf-Of (OBO) user-delegated authentication for Data API builder so the SQL database authenticates as the actual calling user.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/24/2026
---

# Configure On-Behalf-Of (OBO) user-delegated authentication

Data API builder 2.0 supports On-Behalf-Of (OBO) authentication, sometimes referred to as pass-through authentication, for Microsoft SQL databases using Microsoft Entra ID. When enabled, DAB exchanges the incoming user token for a downstream SQL token so the database authenticates as the actual calling user.

With standard authentication, DAB validates the caller's token but connects to the database using its own credentials (managed identity or connection string). With OBO, DAB performs a token exchange so the database sees the real user identity.

[!INCLUDE[Note - DAB 2.0 preview](../../includes/note-dab-2-preview.md)]

## When to use OBO

OBO is the right choice when the SQL database must know who the actual caller is:

| Scenario | Use OBO? |
|----------|----------|
| Row-level security policies that depend on user identity | Yes |
| Compliance auditing that requires per-user database access logs | Yes |
| MCP scenarios where transparent user identification matters | Yes |
| Simple API access where DAB connects with its own credentials | No |
| Non-MSSQL databases | No |

> [!IMPORTANT]
> Today, OBO is supported only for Microsoft SQL databases with Entra ID. 

## Prerequisites

- Data API builder CLI version 2.0 or later
- `dab-config.json` with `data-source.database-type` set to `mssql`
- An Entra ID app registration with the appropriate API permissions to request tokens for the database
- An upstream identity provider that issues JWTs accepted by DAB (Entra ID or a custom provider you configure)
- An MSSQL database configured to accept Microsoft Entra ID tokens

## Connection string requirement

> [!IMPORTANT]
> When OBO is enabled, the connection string must **not** include an `Authentication=` keyword (such as `Authentication=Active Directory Managed Identity`). The `Microsoft.Data.SqlClient` library throws an exception if `AccessToken` is set on a connection that already has `Authentication=` in its connection string. Use a bare connection string containing only server, database, and encryption settings:
>
> ```
> Server=tcp:<server>.database.windows.net,1433;Database=<db>;Encrypt=true;TrustServerCertificate=true
> ```
>
> DAB 2.0 with OBO acquires an MSI token automatically for health checks and internal operations, and injects the per-user OBO token for authenticated requests.

## Step 1: Set the required environment variables

DAB reads the following environment variables for the OBO token exchange:

| Variable | Description |
|----------|-------------|
| `DAB_OBO_CLIENT_ID` | Application (client) ID of the Entra ID app registration |
| `DAB_OBO_TENANT_ID` | Entra ID tenant ID |
| `DAB_OBO_CLIENT_SECRET` | Client secret for the app registration |

#### [Bash](#tab/bash)

```bash
export DAB_OBO_CLIENT_ID="1234-abcd-5678-efgh"
export DAB_OBO_TENANT_ID="abcd-1234-efgh-5678"
export DAB_OBO_CLIENT_SECRET="supersecretvalue"
```

#### [Command Prompt](#tab/cmd)

```cmd
set DAB_OBO_CLIENT_ID=1234-abcd-5678-efgh
set DAB_OBO_TENANT_ID=abcd-1234-efgh-5678
set DAB_OBO_CLIENT_SECRET=supersecretvalue
```

> [!IMPORTANT]
> Never hard-code these values in your configuration file. Use environment variables or a secret manager.

## Step 2: Configure the data source

Enable OBO in your `dab-config.json` under the `data-source` section. The data source must be `mssql`.

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('SQL_CONNECTION_STRING')",
    "user-delegated-auth": {
      "enabled": true,
      "provider": "EntraId",
      "database-audience": "https://database.windows.net"
    }
  }
}
```

| Property | Description |
|----------|-------------|
| `enabled` | Turns OBO on or off |
| `provider` | The identity provider for the token exchange. Currently only `EntraId` is supported |
| `database-audience` | The target audience for the downstream SQL token (required when OBO is enabled) |

## Step 3: Disable caching

Caching must be disabled when OBO is configured. Because each user gets a distinct database connection, cached results from one user's connection must not be served to another.

```json
{
  "runtime": {
    "cache": {
      "enabled": false
    }
  }
}
```

## Step 4: Configure using the CLI

You can also configure OBO entirely from the CLI:

```bash
dab configure --data-source.database-type mssql
dab configure --runtime.cache.enabled false
dab configure --data-source.user-delegated-auth.enabled true
dab configure --data-source.user-delegated-auth.provider EntraId
dab configure --data-source.user-delegated-auth.database-audience "https://database.windows.net"
```

## Full configuration example

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('SQL_CONNECTION_STRING')",
    "user-delegated-auth": {
      "enabled": true,
      "provider": "EntraId",
      "database-audience": "https://database.windows.net"
    }
  },
  "runtime": {
    "cache": {
      "enabled": false
    }
  }
}
```

Where `SQL_CONNECTION_STRING` must be a bare connection string with no `Authentication=` keyword — for example:

```
Server=tcp:<server>.database.windows.net,1433;Database=<db>;Encrypt=true;TrustServerCertificate=true
```

## Per-user connection pooling

When OBO is enabled, DAB maintains separate SQL connection pools per user so that one user's access token is never reused for another user's request. When row-level security depends on who is connected, you can be confident that connection reuse across users doesn't silently grant the wrong access.

## Related content

- [User-delegated auth configuration reference](../../configuration/data-source.md#user-delegated-auth)
- [Configure Microsoft Entra ID authentication](authenticate-entra.md)
- [Row-level security](row-level-security.md)
- [What's new in version 2.0](../../whats-new/version-2-0.md#introducing-on-behalf-of-obo-user-delegation)