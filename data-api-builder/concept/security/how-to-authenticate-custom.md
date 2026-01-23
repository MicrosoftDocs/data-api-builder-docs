---
title: Configure custom JWT authentication (Okta, Auth0)
description: Learn how to configure Data API builder with third-party identity providers like Okta or Auth0 using the Custom authentication provider.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 01/21/2026
---

# Configure custom JWT authentication (Okta, Auth0)

Data API builder supports third-party identity providers through the Custom authentication provider. Use this approach when your organization uses Okta, Auth0, or another OAuth 2.0/OpenID Connect-compliant identity provider.

## Authentication flow

With a custom identity provider, your client app handles user authentication and then sends the access token to Data API builder:

![Illustration of the custom JWT authentication flow with a third-party identity provider.](media/how-to-authenticate-custom/sequence-custom-jwt.svg)

| Phase | What happens |
|-------|--------------|
| **User auth** | User signs in through the identity provider (Okta, Auth0, etc.) |
| **Token acquisition** | Client app receives an access token from the IdP |
| **API call** | Client sends the token to DAB in the `Authorization` header |
| **Validation** | DAB validates the JWT (issuer, audience, signature) |
| **Authorization** | DAB extracts roles and evaluates permissions |

## Prerequisites

- An account with your identity provider (Okta, Auth0, etc.)
- An application registered in your identity provider
- Data API builder CLI installed ([installation guide](../../command-line/install.md))
- An existing `dab-config.json` with at least one entity

## Quick reference

| Setting | Value |
|---------|-------|
| Provider | `Custom` |
| Required for validation | `iss`, `aud`, `exp`, valid signature |
| Required for authorization | `roles` claim containing the selected role |
| Token header | `Authorization: Bearer <token>` |
| Role claim type | `roles` (fixed, not configurable) |
| Role selection header | `X-MS-API-ROLE` |

## Step 1: Configure your identity provider

The exact steps depend on your provider. Here are the key values you need:

### Values to collect

| Value | Where to find it | Used for |
|-------|------------------|----------|
| **Issuer URL** | Provider's documentation or OAuth metadata endpoint | DAB `jwt.issuer` (used as JWT Authority) |
| **Audience** | Your application's client ID or a custom API identifier | DAB `jwt.audience` |

> [!NOTE]
> DAB uses the configured `jwt.issuer` as the JWT **Authority**. Signing keys are discovered automatically via standard OpenID Connect metadata (typically `<issuer>/.well-known/openid-configuration`).

### Okta example

1. Sign in to the [Okta Admin Console](https://developer.okta.com/).
1. Navigate to **Applications** > **Applications**.
1. Create or select an application.
1. Note the **Client ID** (use as audience).
1. Your issuer is typically `https://<your-domain>.okta.com`.

### Auth0 example

1. Sign in to the [Auth0 Dashboard](https://auth0.com/).
1. Navigate to **Applications** > **APIs**.
1. Create or select an API.
1. Note the **Identifier** (use as audience).
1. Your issuer is `https://<your-tenant>.auth0.com/`.

> [!IMPORTANT]
> Data API builder uses a fixed claim type of `roles` for role-based authorization. This value can't be configured. If your identity provider emits roles in a different claim (such as `groups` or `permissions`), you must configure your provider to also emit a `roles` claim, or use a post-login action to copy values into a `roles` claim.

## Step 2: Configure Data API builder

Set the authentication provider to `Custom` and configure the JWT settings:

### CLI

#### [Bash](#tab/bash)

```bash
# Set the authentication provider
dab configure \
  --runtime.host.authentication.provider Custom

# Set the expected audience
dab configure \
  --runtime.host.authentication.jwt.audience "<your-api-identifier>"

# Set the expected issuer
dab configure \
  --runtime.host.authentication.jwt.issuer "https://<your-issuer>/"
```

#### [Command Prompt](#tab/cmd)

```cmd
REM Set the authentication provider
dab configure ^
  --runtime.host.authentication.provider Custom

REM Set the expected audience
dab configure ^
  --runtime.host.authentication.jwt.audience "<your-api-identifier>"

REM Set the expected issuer
dab configure ^
  --runtime.host.authentication.jwt.issuer "https://<your-issuer>/"
```

---

### Resulting configuration

```json
{
  "runtime": {
    "host": {
      "authentication": {
        "provider": "Custom",
        "jwt": {
          "audience": "<your-api-identifier>",
          "issuer": "https://<your-issuer>/"
        }
      }
    }
  }
}
```

## Step 3: Configure entity permissions

Define permissions for the roles your identity provider assigns:

### CLI

#### [Bash](#tab/bash)

```bash
# Allow authenticated users to read
dab update Book \
  --permissions "authenticated:read"

# Allow users with 'admin' role full access
dab update Book \
  --permissions "admin:*"
```

#### [Command Prompt](#tab/cmd)

```cmd
REM Allow authenticated users to read
dab update Book ^
  --permissions "authenticated:read"

REM Allow users with 'admin' role full access
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
          "role": "authenticated",
          "actions": ["read"]
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

## Step 4: Configure roles in your identity provider

DAB expects roles in a `roles` claim. Configure your identity provider to include this claim.

### Okta: Add groups as roles

1. In the Okta Admin Console, go to **Security** > **API**.
1. Select your authorization server.
1. Go to the **Claims** tab.
1. Add a claim:
   - **Name**: `roles`
   - **Include in token type**: Access Token
   - **Value type**: Groups
   - **Filter**: Select the groups to include

### Auth0: Add roles with an Action

1. In the Auth0 Dashboard, go to **Actions** > **Library**.
1. Create a new Action (Post Login trigger).
1. Add code to include roles:

```javascript
exports.onExecutePostLogin = async (event, api) => {
  const roles = event.authorization?.roles || [];
  if (roles.length > 0) {
    api.accessToken.setCustomClaim('roles', roles);
  }
};
```

4. Deploy the Action and add it to your Login flow.

> [!TIP]
> For detailed guidance on configuring JWT claims with Okta, see [Implementing Advanced JWT Claims with Okta's SDK](https://blog.poespas.me/posts/2025/02/13/implementing-advanced-jwt-claims-with-oktas-sdk/).

## Step 5: Test the configuration

1. Start Data API builder:

   ```bash
   dab start
   ```

1. Acquire a token from your identity provider. Use your provider's SDK or a tool like Postman.

1. Inspect the token at [jwt.io](https://jwt.io) to verify:
   - The `aud` claim matches your configured audience
   - The `iss` claim matches your configured issuer
   - The `roles` claim contains the expected values

1. Call the API:

   ```bash
   curl -X GET "http://localhost:5000/api/Book" \
     -H "Authorization: Bearer <your-token>"
   ```

1. To use a custom role, include the `X-MS-API-ROLE` header:

   ```bash
   curl -X GET "http://localhost:5000/api/Book" \
     -H "Authorization: Bearer <your-token>" \
     -H "X-MS-API-ROLE: admin"
   ```

## JWT validation details

Data API builder validates these aspects of the JWT:

| Check | Description |
|-------|-------------|
| **Signature** | Validated using signing keys discovered via the configured `jwt.issuer` authority (OpenID Connect metadata / JWKS) |
| **Issuer** | Must exactly match `jwt.issuer` configuration |
| **Audience** | Must exactly match `jwt.audience` configuration |
| **Expiration** | Token must not be expired (`exp` claim) |
| **Not Before** | Token must be valid (`nbf` claim, if present) |

## Troubleshooting

| Symptom | Possible cause | Solution |
|---------|----------------|----------|
| `401 Unauthorized` | Issuer mismatch | Check the `iss` claim matches exactly (including trailing slash) |
| `401 Unauthorized` | Audience mismatch | Check the `aud` claim matches your configured value |
| `401 Unauthorized` | Token expired | Acquire a fresh token |
| `401 Unauthorized` | Metadata unavailable | Ensure DAB can reach `<issuer>/.well-known/openid-configuration` |
| `403 Forbidden` | Role not in token | Add the role to your IdP configuration |
| `403 Forbidden` | Roles claim missing | Configure your IdP to include a `roles` claim |
| `403 Forbidden` | Wrong claim name | DAB uses claim type `roles` (fixed, not configurable) |

> [!IMPORTANT]
> DAB currently uses the claim type `roles` for all role checks. This value is hardcoded and can't be changed to `groups`, `permissions`, or other claim names. Configure your identity provider to emit roles in a claim named `roles`.

### Common issuer formats

| Provider | Issuer format |
|----------|---------------|
| Okta | `https://<domain>.okta.com` or `https://<domain>.okta.com/oauth2/default` |
| Auth0 | `https://<tenant>.auth0.com/` (note the trailing slash) |
| Azure AD B2C | `https://<tenant>.b2clogin.com/<tenant-id>/v2.0/` |
| Keycloak | `https://<host>/realms/<realm>` |

## Complete configuration example

### Okta configuration

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
        "provider": "Custom",
        "jwt": {
          "audience": "0oa1234567890abcdef",
          "issuer": "https://dev-12345.okta.com"
        }
      }
    }
  },
  "entities": {
    "Book": {
      "source": "dbo.Books",
      "permissions": [
        {
          "role": "authenticated",
          "actions": ["read"]
        },
        {
          "role": "editor",
          "actions": ["create", "read", "update"]
        }
      ]
    }
  }
}
```

### Auth0 configuration

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
        "provider": "Custom",
        "jwt": {
          "audience": "https://my-api.example.com",
          "issuer": "https://my-tenant.auth0.com/"
        }
      }
    }
  },
  "entities": {
    "Book": {
      "source": "dbo.Books",
      "permissions": [
        {
          "role": "authenticated",
          "actions": ["read"]
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
- [Configure Microsoft Entra ID authentication](how-to-authenticate-entra.md)
- [Configure Simulator authentication for testing](how-to-authenticate-simulator.md)
- [Runtime configuration reference](../../configuration/runtime.md)
