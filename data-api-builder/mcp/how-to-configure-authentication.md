---
title: Configure Authentication for SQL MCP Server
description: Learn how to configure authentication between Microsoft AI Foundry agents and SQL MCP Server (Data API builder). Covers Foundry authentication modes and matching DAB configuration with CLI and JSON examples.
ms.topic: how-to
ms.date: 01/07/2026
---

# Configure authentication for SQL MCP Server

[!INCLUDE[Note - Preview](includes/note-preview.md)]

When you connect an agent in Microsoft AI Foundry to SQL MCP Server, the agent calls your MCP endpoint (for example, `https://<host>/mcp`). Authentication is configured on both sides:

- **Microsoft AI Foundry** decides *how it will authenticate to the MCP server*.
- **SQL MCP Server (Data API builder)** decides *how it validates (or doesn’t validate) incoming requests*, and which role those requests run as (`anonymous`, `authenticated`, or an application role).

This article maps each Foundry authentication option to the matching Data API builder configuration, including CLI commands and JSON snippets.

## Prerequisites

- SQL MCP Server running (Data API builder 1.7+)
- An existing `dab-config.json` with at least one entity
- A Microsoft AI Foundry project with an agent where you can add an MCP tool connection

## Authentication options (Foundry)

Foundry currently offers these authentication modes when adding an MCP tool:

- **Unauthenticated**
- **Key-based**
- **Microsoft Entra**
- **OAuth Identity Passthrough**

The following sections describe each option in the same order.

> [!TIP]
> In Data API builder, authentication and authorization are separate. Even when authentication is enabled, *authorization is still enforced* by entity permissions.

## Unauthenticated

Use **Unauthenticated** when you want Foundry to call SQL MCP Server without presenting any identity. On the Data API builder side, you must ensure those requests land in the `anonymous` role and that your entities grant only the permissions you intend to allow.

### What happens

- Foundry sends no access token.
- Data API builder evaluates the request as `anonymous`.

> [!IMPORTANT]
> In Data API builder, the strictest way to enforce anonymous-only access is to omit the `runtime.host.authentication` section entirely. However, this article assumes the SQL MCP Server is hosted behind an Azure App Service-style platform and uses `AppService` authentication, where requests without identity headers are treated as `anonymous`.

### Configure Foundry

1. Add an MCP tool connection.
2. Set **Authentication** to **Unauthenticated**.
3. Set the MCP endpoint URL to your SQL MCP Server endpoint.

> SCREENSHOT "Add Model Context Protocol tool dialog with Authentication set to Unauthenticated"

### Configure SQL MCP Server (DAB)

1. Configure DAB to use the `AppService` provider.
2. Ensure each entity includes `anonymous` permissions.

#### CLI

#### [Bash](#tab/bash)

```bash
# 1) Set host authentication provider
dab configure \
  --runtime.host.authentication.provider AppService

# 2) Grant anonymous permissions per entity (repeat per entity)
dab update \
  Products \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
REM 1) Set host authentication provider
dab configure ^
  --runtime.host.authentication.provider AppService

REM 2) Grant anonymous permissions per entity (repeat per entity)
dab update ^
  Products ^
  --permissions "anonymous:read"
```

---

#### Resulting config (snippet)

```json
{
	"runtime": {
		"host": {
			"authentication": {
				"provider": "AppService"
			}
		}
	},
	"entities": {
		"Products": {
			"permissions": [
				{
					"role": "anonymous",
					"actions": [
						{ "action": "read" }
					]
				}
			]
		}
	}
}
```

## Key-based (not supported)

Foundry’s **Key-based** authentication mode typically sends a static API key (for example, `x-api-key`). **SQL MCP Server doesn’t support key-based authentication**, so you can’t secure the MCP endpoint with a shared secret directly in Data API builder.

### What to do instead

- Use **Microsoft Entra** (recommended) or **OAuth Identity Passthrough** so SQL MCP Server can validate JWTs.
- If you must use a static key, front SQL MCP Server with a gateway that validates the key and then forwards an authenticated request (for example, by exchanging the key for a token). This gateway pattern is outside the scope of this article.

> SCREENSHOT "Add Model Context Protocol tool dialog with Authentication set to Key-based"

## Microsoft Entra

Use **Microsoft Entra** when you want Foundry to acquire a Microsoft Entra access token and send it to SQL MCP Server. On the Data API builder side, configure the `EntraId` provider so DAB validates the JWT’s issuer and audience.

### What happens

- Foundry acquires an access token from Microsoft Entra.
- Foundry calls the MCP endpoint with `Authorization: Bearer <token>`.
- Data API builder validates the token (issuer + audience) and assigns a role:
	- If no `X-MS-API-ROLE` header is sent, the request runs as the system role `authenticated`.
	- If a valid `X-MS-API-ROLE` header is sent and matches a role claim in the token, the request runs as that role.
	- If no token is sent, the request runs as `anonymous`.

> [!NOTE]
> Many MCP clients (including managed experiences) don’t let you set arbitrary headers like `X-MS-API-ROLE`. In that case, plan your permissions around the `authenticated` system role.

### Configure Foundry

1. Add an MCP tool connection.
2. Set **Authentication** to **Microsoft Entra**.
3. Select the Entra configuration appropriate for your tenant/app.

> SCREENSHOT "Foundry MCP tool configuration showing Microsoft Entra authentication"

### Configure SQL MCP Server (DAB)

Configure the `EntraId` provider and set the `jwt.audience` and `jwt.issuer` values.

#### CLI

#### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.host.authentication.provider EntraId

dab configure \
  --runtime.host.authentication.jwt.audience "api://<app-id-or-audience>"

dab configure \
  --runtime.host.authentication.jwt.issuer "https://login.microsoftonline.com/<tenant-id>/v2.0"

# Grant permissions for authenticated users (repeat per entity)
dab update \
  Products \
  --permissions "authenticated:read"
```

#### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.host.authentication.provider EntraId

dab configure ^
  --runtime.host.authentication.jwt.audience "api://<app-id-or-audience>"

dab configure ^
  --runtime.host.authentication.jwt.issuer "https://login.microsoftonline.com/<tenant-id>/v2.0"

REM Grant permissions for authenticated users (repeat per entity)
dab update ^
  Products ^
  --permissions "authenticated:read"
```

---

#### Resulting config (snippet)

```json
{
	"runtime": {
		"host": {
			"authentication": {
				"provider": "EntraId",
				"jwt": {
					"audience": "api://<app-id-or-audience>",
					"issuer": "https://login.microsoftonline.com/<tenant-id>/v2.0"
				}
			}
		}
	},
	"entities": {
		"Products": {
			"permissions": [
				{
					"role": "authenticated",
					"actions": [
						{ "action": "read" }
					]
				}
			]
		}
	}
}
```

### Entra configuration notes

Keep these points in mind when troubleshooting:

- **Audience**: Must match the token’s `aud` claim (often `api://<app-id>` or an App ID URI).
- **Issuer**: Must match the token’s `iss` claim. For tenant-specific tokens, use `https://login.microsoftonline.com/<tenant-id>/v2.0`.
- **Roles**: Data API builder expects role values in the token’s `roles` claim.

For the full list of required fields and supported provider values, see `runtime.host.authentication` in the runtime configuration reference: https://review.learn.microsoft.com/en-us/azure/data-api-builder/configuration/runtime?branch=main#provider-authentication-host-runtime.

## OAuth Identity Passthrough

Use **OAuth Identity Passthrough** when Foundry can obtain an OAuth access token from an identity provider and pass it through to the MCP server. Conceptually this is the same as the **Microsoft Entra** option, but it can work with non-Entra identity providers.

### What happens

- Foundry obtains an OAuth access token and calls the MCP endpoint with `Authorization: Bearer <token>`.
- SQL MCP Server validates the JWT using either:
	- `provider: EntraId` (Microsoft Entra), or
	- `provider: Custom` (non-Entra JWT issuer).

### Configure Foundry

1. Add an MCP tool connection.
2. Set **Authentication** to **OAuth Identity Passthrough**.
3. Configure the OAuth provider details as required by Foundry.

> SCREENSHOT "Foundry MCP tool configuration showing OAuth Identity Passthrough authentication"

### Configure SQL MCP Server (DAB)

Choose one of the following DAB configurations.

#### Option A: Microsoft Entra tokens (recommended)

Use the same steps as [Microsoft Entra](#microsoft-entra).

#### Option B: Non-Entra OAuth provider

Configure Data API builder to use `Custom` JWT validation.

##### CLI

##### [Bash](#tab/bash)

```bash
dab configure \
  --runtime.host.authentication.provider Custom

dab configure \
  --runtime.host.authentication.jwt.audience "<your-api-audience>"

dab configure \
  --runtime.host.authentication.jwt.issuer "https://<your-issuer>/"
```

##### [Command Prompt](#tab/cmd)

```cmd
dab configure ^
  --runtime.host.authentication.provider Custom

dab configure ^
  --runtime.host.authentication.jwt.audience "<your-api-audience>"

dab configure ^
  --runtime.host.authentication.jwt.issuer "https://<your-issuer>/"
```

---

##### Resulting config (snippet)

```json
{
	"runtime": {
		"host": {
			"authentication": {
				"provider": "Custom",
				"jwt": {
					"audience": "<your-api-audience>",
					"issuer": "https://<your-issuer>/"
				}
			}
		}
	}
}
```

## Related content

- [Runtime configuration: authentication provider](../configuration/runtime.md)
- [Local authentication (Simulator/AppService)](../concept/security/authentication-local.md)
- [Azure authentication (JWT/roles)](../concept/security/authentication-azure.md)
- Foundry MCP authentication guidance: https://learn.microsoft.com/en-us/azure/ai-foundry/agents/how-to/mcp-authentication?view=foundry&branch=release-ignite-foundry-nextgen
