---
title: Configure the Unauthenticated provider
description: Learn how to use the Unauthenticated authentication provider in Data API builder, where every request runs as the anonymous role.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/26/2026
---

# Configure the Unauthenticated provider

The `Unauthenticated` provider tells Data API builder (DAB) not to inspect or validate any JSON Web Token (JWT). Every request runs as the `anonymous` role. There are no exceptions inside DAB.

[!INCLUDE[Note - DAB 2.0 preview](../../includes/note-dab-2-preview.md)]

Use this provider when you want DAB to treat every request as `anonymous`, even if another service in front of DAB performs authentication or applies access policy.

> [!IMPORTANT]
> The `Unauthenticated` provider never turns upstream identity into DAB identity. If you need DAB to validate tokens, activate the `authenticated` role, use custom roles, or pass user claims to downstream policies, use a validating provider such as `EntraId`, `Custom`, or `AppService`.

## Authentication flow

With the `Unauthenticated` provider, DAB skips token validation entirely and evaluates permissions as `anonymous`:

| Phase | What happens |
|-------|--------------|
| **Client request** | The client sends a request to DAB, either directly or through another service |
| **Upstream controls** | A front end, gateway, or proxy can authenticate the caller or enforce coarse-grained access before forwarding the request |
| **Forward request** | The request reaches DAB |
| **DAB processing** | DAB doesn't validate JWTs and always treats the request as `anonymous` |
| **Authorization** | DAB evaluates entity permissions for the `anonymous` role |

## When to use this provider

Use `Unauthenticated` in these scenarios:

| Scenario | Good fit? | Why |
|----------|-----------|-----|
| API Management or gateway authenticates users first | Yes | The front end can gate access, while DAB still authorizes requests only for the `anonymous` role |
| Internal-only service behind a private network boundary | Yes | Network access is controlled outside DAB, and DAB can stay `anonymous`-only |
| Quick local setup without configuring JWT validation | Yes | Simplest way to get started |
| DAB exposed directly to browsers or public clients | No | DAB doesn't validate identity tokens |
| You need `authenticated` or custom role activation inside DAB | No | Only `anonymous` is active with this provider |

## Quick reference

| Setting | Value |
|---------|-------|
| Provider | `Unauthenticated` |
| Token required | No |
| Active DAB role | `anonymous` |
| Supports JWT validation | No |
| Supports `authenticated` role | No |
| Supports custom roles | No |

## Step 1: Configure the provider

Set the authentication provider to `Unauthenticated`.

### CLI

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.host.authentication.provider Unauthenticated
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.host.authentication.provider Unauthenticated
```

---

### Resulting configuration

```json
{
  "runtime": {
    "host": {
      "authentication": {
        "provider": "Unauthenticated"
      }
    }
  }
}
```

> [!NOTE]
> The `Unauthenticated` provider is the default for new configurations in DAB 2.0. Running `dab init` creates a working configuration without any JWT settings.

## Step 2: Configure entity permissions for `anonymous`

Because DAB treats all requests as `anonymous`, your entities must grant access to the `anonymous` role for any operation you want to allow.

### Example configuration

```json
{
  "entities": {
    "Book": {
      "source": "dbo.Books",
      "permissions": [
        {
          "role": "anonymous",
          "actions": ["read"]
        }
      ]
    }
  }
}
```

If an entity grants access only to `authenticated` or a custom role, requests fail because those roles are never activated when `Unauthenticated` is configured.

> [!IMPORTANT]
> When `Unauthenticated` is active, `authenticated` and custom roles defined in entity permissions are never activated. If your configuration contains those roles, DAB emits a warning at startup.

## Step 3: Optionally place another service in front of DAB

Another service can still authenticate callers or apply coarse-grained access rules before the request reaches DAB. That doesn't change DAB's behavior:

1. Authenticate the caller in the front end, gateway, or proxy.
2. Apply coarse-grained access policy there.
3. Forward approved requests to DAB.
4. Use DAB entity permissions to control what the `anonymous` role can do.

This pattern works well when a surrounding platform controls who can reach DAB, while DAB remains intentionally `anonymous`-only.

## What this provider doesn't do

The `Unauthenticated` provider doesn't:

- validate bearer tokens
- activate the `authenticated` role
- activate custom roles from claims
- make claims available to database policies
- perform user-specific authorization inside DAB

If you need those capabilities, use a provider that supplies identity to DAB.

## Complete configuration example

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json",
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('SQL_CONNECTION_STRING')"
  },
  "runtime": {
    "host": {
      "authentication": {
        "provider": "Unauthenticated"
      }
    }
  },
  "entities": {
    "Book": {
      "source": "dbo.Books",
      "permissions": [
        {
          "role": "anonymous",
          "actions": ["read"]
        }
      ]
    }
  }
}
```

## Related content

- [Secure your Data API builder solution](index.md)
- [Authorization overview](authorization-overview.md)
- [Configure App Service authentication](authenticate-easy-auth.md)
- [Configure Microsoft Entra ID authentication](authenticate-entra.md)
- [Runtime configuration reference](../../configuration/runtime.md#provider-authentication-host-runtime)