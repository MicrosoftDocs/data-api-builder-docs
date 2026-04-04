---
title: Authentication overview
description: Learn how authentication works in Data API builder and choose the right provider for your deployment scenario.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: conceptual
ms.date: 04/03/2026
---

# Authentication overview

Authentication determines who is calling your Data API builder (DAB) endpoints.

DAB supports multiple authentication providers so you can match local testing, production identity systems, and platform-hosted scenarios.

## Authentication providers at a glance

| Provider | Best for | Guide |
|---|---|---|
| `Unauthenticated` | Trusted front end or gateway handles identity before DAB | [Configure the Unauthenticated provider](authenticate-unauthenticated.md) |
| `EntraID` / `AzureAD` | Microsoft Entra ID-based production apps | [Configure Microsoft Entra ID authentication](authenticate-entra.md) |
| `Custom` | Third-party OpenID Connect or JWT providers | [Configure custom JWT authentication](authenticate-custom.md) |
| `AppService` | Azure App Service Easy Auth headers | [Configure App Service authentication](authenticate-easy-auth.md) |
| `Simulator` | Local development and role testing | [Configure Simulator authentication](authenticate-simulator.md) |
| `On-Behalf-Of (OBO)` | SQL scenarios requiring user-delegated downstream identity | [Configure OBO authentication](authenticate-on-behalf-of.md) |

## How authentication affects authorization

After DAB authenticates a request, DAB evaluates permissions by role.

- No authenticated identity maps to the `anonymous` system role.
- Authenticated identity maps to `authenticated`, or to a requested role from claims when `X-MS-API-ROLE` is used.

For role evaluation details, see [Authorization overview](authorization-overview.md).

## Configure authentication

Set the provider with:

```bash
dab configure --runtime.host.authentication.provider <ProviderName>
```

For schema details, see [Runtime configuration reference](../../configuration/runtime.md#provider-authentication-host-runtime).

## Related content

- [Secure your Data API builder solution](overview.md)
- [Authorization overview](authorization-overview.md)
- [Runtime configuration reference](../../configuration/runtime.md#provider-authentication-host-runtime)
