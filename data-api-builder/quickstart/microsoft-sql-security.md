---
title: 'Quickstart: Choose a Microsoft SQL security sample'
description: Compare Microsoft SQL security quickstarts for Data API builder and choose the right sample for credentials, managed identity, Microsoft Entra, policies, row-level security, or on-behalf-of access.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 05/29/2026
# Customer Intent: As a developer, I want to compare Microsoft SQL security quickstarts so that I can choose the right authentication or authorization pattern for my app.
---

# Quickstart: Choose a Microsoft SQL security sample

Use these Microsoft SQL security samples to compare how Data API builder (DAB) authenticates to SQL, validates users, and enforces per-user access. Each sample is self-contained, but the series moves from basic credentials to user-delegated Azure SQL access.

## Choose a quickstart

Start with the question that matches your goal.

| If you want to... | Use this quickstart |
| --- | --- |
| Learn the simplest DAB-to-SQL connection pattern | [Username/password](authentication-sql-credentials.md) |
| Remove SQL passwords from Azure configuration | [Managed identity](authentication-managed-identity.md) |
| Add Microsoft Entra token validation before requiring sign-in | [Microsoft Entra](authentication-microsoft-entra-provider.md) |
| Filter rows in DAB by using token claims | [DAB policies](authorization-database-policies.md) |
| Filter rows in SQL by using database-enforced row-level security | [SQL row-level security](authorization-sql-row-level-security.md) |
| Let Azure SQL authenticate the signed-in user directly | [On-behalf-of to Azure SQL](authentication-on-behalf-of.md) |

## Decision tree

- Do you only need a basic working sample?
  - Use [Username/password](authentication-sql-credentials.md).
- Do you want passwordless DAB-to-Azure SQL access?
  - Use [Managed identity](authentication-managed-identity.md).
- Do you need DAB to validate Microsoft Entra tokens?
  - Use [Microsoft Entra](authentication-microsoft-entra-provider.md).
- Do signed-in users need to see only their own rows?
  - If DAB should enforce the filter, use [DAB policies](authorization-database-policies.md).
  - If SQL should enforce the filter, use [SQL row-level security](authorization-sql-row-level-security.md).
- Do audit logs or database policies need the actual signed-in user as the SQL identity?
  - Use [On-behalf-of to Azure SQL](authentication-on-behalf-of.md).

## Compare the security model

The **DAB authentication provider** column shows the effective value for `runtime.host.authentication.provider`. If the configuration omits this setting, DAB uses `Unauthenticated`. Except for the username/password and on-behalf-of samples, local runs use SQL credentials and Azure deployments use managed identity. The on-behalf-of sample also sets `data-source.user-delegated-auth.provider` to `EntraId`.

| Quickstart | User to web app | Web app to DAB | DAB authentication provider | DAB to SQL |
| --- | --- | --- | --- | --- |
| [Username/password](authentication-sql-credentials.md) | Anonymous | Anonymous | `Unauthenticated` | SQL credentials |
| [Managed identity](authentication-managed-identity.md) | Anonymous | Anonymous | `Unauthenticated` | Managed identity in Azure |
| [Microsoft Entra](authentication-microsoft-entra-provider.md) | Anonymous | Anonymous | `EntraId` | Managed identity in Azure |
| [DAB policies](authorization-database-policies.md) | Microsoft Entra sign-in | Bearer token | `EntraId` | Managed identity in Azure |
| [SQL row-level security](authorization-sql-row-level-security.md) | Microsoft Entra sign-in | Bearer token | `EntraId` | Managed identity in Azure |
| [On-behalf-of to Azure SQL](authentication-on-behalf-of.md) | Microsoft Entra sign-in | Bearer token | `EntraId` | User-delegated token to Azure SQL |

## Related content

- [Quickstart: Use Data API builder with SQL](basic-sql.md)
- [Microsoft Entra ID authentication in Data API builder](../concept/security/authenticate-entra.md)
- [Authorization overview](../concept/security/authorization-overview.md)
- [Configure on-behalf-of authentication](../concept/security/authenticate-on-behalf-of.md)