---
title: Configure Simulator authentication for local testing
description: Learn how to use the Simulator authentication provider to test role-based permissions locally without configuring an identity provider.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 01/21/2026
---

# Configure Simulator authentication for local testing

The Simulator authentication provider lets you test role-based permissions locally without configuring an identity provider. Use it during development to verify that your permission rules work correctly before deploying to production.

## Choose a local authentication provider

During development, you can test authentication and authorization without configuring a production identity provider.

| Provider | Best for | Notes |
|----------|----------|-------|
| **Simulator** | Quick permission testing | Development-only. Treats every request as authenticated. Defaults to `Authenticated` role; override with `X-MS-API-ROLE`. |
| **AppService** | Claim-driven testing | Simulate EasyAuth locally by sending `X-MS-CLIENT-PRINCIPAL` with custom claims. For details, see [Configure App Service authentication](how-to-authenticate-app-service.md). |

## Authentication flow

The Simulator provider treats all requests as authenticated, letting you focus on testing authorization rules:

![Illustration of the Simulator authentication flow showing how requests are automatically treated as authenticated.](media/how-to-authenticate-simulator/sequence-simulator.svg)

| Phase | What happens |
|-------|--------------|
| **Request arrives** | Developer sends HTTP request to DAB |
| **Role assignment** | DAB assigns `Authenticated` (default) or the role from `X-MS-API-ROLE` header |
| **Permission check** | DAB evaluates the request against the entity's permissions for that role |
| **Query execution** | If permitted, DAB queries the database and returns results |

> [!IMPORTANT]
> The Simulator provider is for **development only**. Never use it in production—it bypasses all real authentication.

## Prerequisites

- Data API builder CLI installed ([installation guide](../../command-line/install.md))
- An existing `dab-config.json` with at least one entity

## Quick reference

| Setting | Value |
|---------|-------|
| Provider | `Simulator` |
| Host mode | `development` (required) |
| Default role | `Authenticated` (injected automatically) |
| Role override header | `X-MS-API-ROLE` |
| Token required | No |
| Claims support | Limited (system roles `Anonymous`/`Authenticated` only; no arbitrary claims) |

## Step 1: Configure the Simulator provider

Set the authentication provider to Simulator and ensure development mode is enabled.

### CLI

#### [Bash](#tab/bash)

```bash
# Enable development mode
dab configure \
  --runtime.host.mode development

# Set the Simulator provider
dab configure \
  --runtime.host.authentication.provider Simulator
```

#### [Command Prompt](#tab/cmd)

```cmd
REM Enable development mode
dab configure ^
  --runtime.host.mode development

REM Set the Simulator provider
dab configure ^
  --runtime.host.authentication.provider Simulator
```

---

### Resulting configuration

```json
{
  "runtime": {
    "host": {
      "mode": "development",
      "authentication": {
        "provider": "Simulator"
      }
    }
  }
}
```

> [!NOTE]
> The Simulator provider only works when `mode` is set to `development`. In production mode, DAB rejects the Simulator provider and fails to start.

## Step 2: Configure entity permissions

Define permissions for the roles you want to test. You can test system roles (`Anonymous`, `Authenticated`) and custom roles.

### Example: Multiple roles

#### [Bash](#tab/bash)

```bash
# Allow anonymous read access
dab update Book \
  --permissions "Anonymous:read"

# Allow authenticated users full read access
dab update Book \
  --permissions "Authenticated:read"

# Allow authors to create and update
dab update Book \
  --permissions "author:create,read,update"

# Allow admins full access
dab update Book \
  --permissions "admin:*"
```

#### [Command Prompt](#tab/cmd)

```cmd
REM Allow anonymous read access
dab update Book ^
  --permissions "Anonymous:read"

REM Allow authenticated users full read access
dab update Book ^
  --permissions "Authenticated:read"

REM Allow authors to create and update
dab update Book ^
  --permissions "author:create,read,update"

REM Allow admins full access
dab update Book ^
  --permissions "admin:*"
```

---

### Resulting configuration

```json
{
  "entities": {
    "Book": {
      "source": "dbo.Books",
      "permissions": [
        {
          "role": "Anonymous",
          "actions": ["read"]
        },
        {
          "role": "Authenticated",
          "actions": ["read"]
        },
        {
          "role": "author",
          "actions": ["create", "read", "update"]
        },
        {
          "role": "admin",
          "actions": ["*"]
        }
      ]
    }
  }
}
```

## Step 3: Test different roles

Start Data API builder and send requests to test each role.

```bash
dab start
```

### Test as authenticated (default)

Without any special headers, requests are evaluated as the `Authenticated` role:

```bash
curl -X GET "http://localhost:5000/api/Book"
```

### Test as anonymous

Use the `X-MS-API-ROLE` header to test as `Anonymous`:

```bash
curl -X GET "http://localhost:5000/api/Book" \
  -H "X-MS-API-ROLE: Anonymous"
```

### Test as a custom role

Use the `X-MS-API-ROLE` header to test any custom role:

```bash
curl -X GET "http://localhost:5000/api/Book" \
  -H "X-MS-API-ROLE: author"
```

> [!NOTE]
> With Simulator, custom role testing works because DAB evaluates permissions based on the `X-MS-API-ROLE` header value. System roles (`Anonymous`, `Authenticated`) are always available. If a custom role request returns 403, verify the role name matches your entity permissions exactly.

### Test an action that should be denied

Try an action that the role doesn't have permission for:

```bash
# This should fail—Anonymous can only read
curl -X POST "http://localhost:5000/api/Book" \
  -H "X-MS-API-ROLE: Anonymous" \
  -H "Content-Type: application/json" \
  -d '{"title": "New Book", "author": "Test"}'
```

Expected response: `403 Forbidden`

## Testing scenarios

Use the Simulator to test these common scenarios:

| Scenario | How to test |
|----------|-------------|
| Anonymous access | Set `X-MS-API-ROLE: Anonymous` |
| Authenticated access | Omit headers (default) or set `X-MS-API-ROLE: Authenticated` |
| Custom role access | Set `X-MS-API-ROLE: <role-name>` |
| Denied action | Request an action the role lacks permission for |
| Field restrictions | Configure field-level permissions and verify response fields |
| Missing role | Set `X-MS-API-ROLE: nonexistent` to test error handling |

## Limitations

The Simulator provider has these limitations:

| Limitation | Workaround |
|------------|------------|
| No custom claims | Use the AppService provider with `X-MS-CLIENT-PRINCIPAL` header |
| No database policies with claims | Test policies using the AppService provider |
| No token validation | Switch to Entra or Custom provider for production |
| Development mode only | Use a real provider in production |

> [!TIP]
> If you need to test database policies that use claims (like `@claims.userId`), use the [AppService provider](how-to-authenticate-app-service.md) instead. It lets you provide custom claims via the `X-MS-CLIENT-PRINCIPAL` header.

## Transition to production

When you're ready to deploy, replace the Simulator provider with a production provider:

1. Change `mode` from `development` to `production`
2. Change `provider` from `Simulator` to your chosen provider (`EntraID`/`AzureAD`, `AppService`, or `Custom`)
3. Configure the required JWT settings (audience, issuer)

```json
{
  "runtime": {
    "host": {
      "mode": "production",
      "authentication": {
        "provider": "EntraID",
        "jwt": {
          "audience": "api://<your-app-id>",
          "issuer": "https://login.microsoftonline.com/<tenant-id>/v2.0"
        }
      }
    }
  }
}
```

## Complete configuration example

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json",
  "data-source": {
    "database-type": "mssql",
    "connection-string": "Server=localhost;Database=Library;Trusted_Connection=true;TrustServerCertificate=true;"
  },
  "runtime": {
    "host": {
      "mode": "development",
      "authentication": {
        "provider": "Simulator"
      }
    }
  },
  "entities": {
    "Book": {
      "source": "dbo.Books",
      "permissions": [
        {
          "role": "Anonymous",
          "actions": ["read"]
        },
        {
          "role": "Authenticated",
          "actions": ["read"]
        },
        {
          "role": "author",
          "actions": ["create", "read", "update"]
        },
        {
          "role": "admin",
          "actions": ["*"]
        }
      ]
    }
  }
}
```

## Related content

- [Authorization and roles](authorization.md)
- [Configure App Service authentication](how-to-authenticate-app-service.md)
- [Configure Microsoft Entra ID authentication](how-to-authenticate-entra.md)
- [Runtime configuration reference](../../configuration/runtime.md)
