---
title: Secure your solution
description: Review the fundamentals of securing Data API builder from the perspective of authentication, authorization, transport, and configuration security.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: best-practice
ms.date: 03/24/2026
ms.custom: [security-horizontal-2025, horz-security]
---

# Secure your Data API builder solution

Data API builder exposes your data through REST and GraphQL endpoints. Securing your API requires attention to three core areas: **authentication** (who is calling?), **authorization** (what can they do?), and **transport security** (is the connection protected?).

![Illustration of the end-to-end request flow showing authentication, authorization, and database access.](media/index/security-overview-flow.svg)

## Three pillars of security

| Pillar | Question it answers | Key concept |
|--------|---------------------|-------------|
| **Authentication** | Who is the caller? | Validate tokens from an identity provider |
| **Authorization** | What can they do? | Role-based permissions on entities |
| **Transport** | Is the connection secure? | Transport Layer Security (TLS) encryption for all traffic |

## Choose your authentication provider

Data API builder supports multiple authentication providers. Choose the one that matches your deployment scenario:

| Provider | Use case | Guide |
|----------|----------|-------|
| **Unauthenticated** | DAB sits behind a trusted front end that handles identity (default) | [Configure the Unauthenticated provider](authenticate-unauthenticated.md) |
| **Microsoft Entra ID** (`EntraID`/`AzureAD`) | Production apps using Microsoft identity | [Configure Microsoft Entra authentication](authenticate-entra.md) |
| **Custom JSON Web Token (JWT)** | Third-party IdPs (Okta, Auth0, Keycloak) | [Configure custom JWT authentication](authenticate-custom.md) |
| **App Service** | Apps running behind Azure App Service EasyAuth (platform headers) | [Configure App Service authentication](authenticate-easy-auth.md) |
| **Simulator** | Local development and testing | [Configure Simulator authentication](authenticate-simulator.md) |
| **OBO (user-delegated)** | SQL databases that require the real user identity (row-level security, auditing) | [Configure OBO authentication](authenticate-on-behalf-of.md) |
| **Static Web Apps** | Apps fronted by Static Web Apps (SWA) auth headers | [Configure App Service authentication](authenticate-easy-auth.md)

[!INCLUDE[Note - DAB 2.0 preview](../../includes/note-dab-2-preview.md)]

## Authentication

Authentication verifies the caller's identity. Data API builder authenticates requests by either validating JWT bearer tokens (`EntraID`/`AzureAD`, `Custom`) or trusting platform-provided identity headers (`AppService`, `StaticWebApps`). `Simulator` skips external validation for development.

![Illustration of how clients authenticate to Data API builder using JWT tokens.](media/index/authentication-inbound-flow.svg)

### How it works

1. For JWT providers, the client acquires a token from the identity provider
1. The client sends the token in the `Authorization: Bearer <token>` header (JWT providers) or platform injects identity headers (EasyAuth/SWA)
1. Data API builder validates the token or platform header (issuer, audience, signature for JWT providers)
1. DAB extracts the user's roles from the token or identity header

### Quick reference

| Setting | Description |
|---------|-------------|
| `runtime.host.authentication.provider` | The authentication provider (`Unauthenticated`, `EntraID`/`AzureAD`, `Custom`, `AppService`, `StaticWebApps`, `Simulator`) |
| `runtime.host.authentication.jwt.audience` | Expected audience claim for JWT providers (not used by AppService/StaticWebApps/Simulator/Unauthenticated) |
| `runtime.host.authentication.jwt.issuer` | Expected issuer/authority for JWT providers (not used by AppService/StaticWebApps/Simulator/Unauthenticated) |

For provider-specific configuration, see the authentication guides in this section.

## Authorization

Authorization determines what an authenticated (or anonymous) user can do. Data API builder uses role-based access control (RBAC) to restrict access to entities and actions.

![Illustration of how Data API builder selects a role and evaluates permissions for a request.](media/index/authorization-role-evaluation.svg)

### How it works

1. DAB assigns a role to the request based on the token and headers
1. DAB looks up the entity's permissions for that role
1. If the role has permission for the requested action, DAB executes the query
1. If not, DAB returns a `403 Forbidden` response

### System roles vs. user roles

| Role type | Description |
|-----------|-------------|
| **`Anonymous`** | Assigned when no authenticated identity is present |
| **`Authenticated`** | Assigned when a request is authenticated (JWT accepted or trusted platform header) and no specific user role is selected |
| **User roles** | Custom roles from the token's `roles` claim (or platform roles), selected via `X-MS-API-ROLE` header |

### Secure by default

Entities have **no permissions by default**. You must explicitly grant access:

```json
{
  "entities": {
    "Book": {
      "permissions": [
        { "role": "authenticated", "actions": ["read"] }
      ]
    }
  }
}
```

For detailed configuration, see [Authorization and roles](authorization.md).

## Row-level and field-level security

Go beyond entity-level permissions with fine-grained access control:

| Feature | Description | Guide |
|---------|-------------|-------|
| **Database policies (row-level security)** | Translate policy expressions into query predicates that filter rows based on claims or session context | [Implement row-level security](row-level-security.md) |
| **Field-level security** | Include or exclude specific columns per role | [Field access](authorization.md#field-access) |
| **On-Behalf-Of (OBO)** | Exchange the incoming user token for a downstream SQL token so the database authenticates as the actual calling user (mssql only) | [User-delegated auth](../../configuration/data-source.md#user-delegated-auth) |

## Role inheritance

DAB 2.0 introduces role inheritance for entity permissions. The inheritance chain is `named-role → authenticated → anonymous`. If a role isn't explicitly configured for an entity, it inherits from the next broader role. Define permissions once on `anonymous` and every broader role gets the same access. For details, see [Role inheritance](role-inheritance.md).

## Transport and configuration security

### Transport security

- **Use TLS for all connections**: Encrypt traffic between clients and DAB
- **Disable legacy TLS versions**: Rely on TLS 1.2+ only
- **Use HTTPS endpoints**: Never expose DAB over unencrypted HTTP in production

For details, see [Security best practices](best-practices.md).

### Configuration security

- **Store secrets in environment variables**: Use `@env('SECRET_NAME')` in your config
- **Use Azure Key Vault**: Reference secrets with `@azure('key-vault-uri')`
- **Never commit secrets**: Keep `dab-config.json` free of passwords and connection strings

```json
{
  "data-source": {
    "connection-string": "@env('SQL_CONNECTION_STRING')"
  }
}
```

## Monitoring and updates

- **Monitor access**: Use [Application Insights](../monitor/application-insights.md) to track requests and detect anomalies
- **Review logs**: Check for failed authentication attempts and permission denials
- **Keep DAB updated**: Apply security patches by upgrading to the [latest version](../../whats-new/index.yml)

## Quick start guides

| Task | Guide |
|------|-------|
| Use a trusted front end without JWT validation in DAB | [Configure the Unauthenticated provider](authenticate-unauthenticated.md) |
| Set up Microsoft Entra ID authentication | [Configure Microsoft Entra authentication](authenticate-entra.md) |
| Use Okta or Auth0 | [Configure custom JWT authentication](authenticate-custom.md) |
| Run behind Azure App Service | [Configure App Service authentication](authenticate-easy-auth.md) |
| Test permissions locally | [Configure Simulator authentication](authenticate-simulator.md) |
| Restrict rows by user | [Implement row-level security](row-level-security.md) |
| Understand role assignment | [Authorization and roles](authorization.md) |

## Related content

- [Configure the Unauthenticated provider](authenticate-unauthenticated.md)
- [Configure Microsoft Entra ID authentication](authenticate-entra.md)
- [Authorization and roles](authorization.md)
- [Security best practices](best-practices.md)
- [Runtime configuration reference](../../configuration/runtime.md)
