---
title: Secure your solution
description: Review the fundamentals of securing Data API builder from the perspective of authentication, authorization, transport, and configuration security.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: best-practice
ms.date: 07/01/2025
ms.custom: security-horizontal-2025
ai-usage: ai-generated
---

# Secure your Data API builder solution

Data API builder enables you to quickly expose your data through REST and GraphQL endpoints, making it easier to build modern applications. Because these endpoints can provide access to sensitive data, it's critical to implement robust security measures to protect your solution from unauthorized access and threats.

This article provides guidance on how to best secure your Data API builder solution.

## Authentication

- **Use strong authentication providers**: Always configure Data API builder to use a secure authentication provider such as Microsoft Entra ID or Azure Static Web Apps authentication. This configuration ensures only authorized users can access your APIs. For more information, see [authentication configuration](authentication-local.md).
- **Avoid hardcoding secrets**: Never store authentication secrets or credentials directly in your configuration files or source code. Use secure methods such as environment variables or Azure Key Vault. For more information, see [Azure authentication](authentication-azure.md).

## Authorization

- **Implement role-based access control (RBAC)**: Restrict access to entities and actions based on user roles by defining roles and permissions in your configuration. This limits exposure of sensitive data and operations. For more information, see [roles](authorization.md#roles).
- **Deny by default**: By default, entities have no permissions configured, so no one can access them. Explicitly define permissions for each role to ensure only intended users have access. For more information, see [authorization](authorization.md).
- **Use the X-MS-API-ROLE header for custom roles**: Require clients to specify the `X-MS-API-ROLE` header to access resources with custom roles, ensuring requests are evaluated in the correct security context. For more information, see [custom role header](authentication-azure.md#x-ms-api-role-request-header).

## Transport security

- **Enforce transport layer security for all connections**: Ensure all data exchanged between clients and Data API builder is encrypted using transport layer security. Transport layer security (TLS) protects data in transit from interception and tampering. For more information, see [TLS enforcement](deployment/best-practices-security.md#security-best-practices-in-data-api-builder).
- **Disable legacy TLS versions**: Configure your server to disable outdated TLS versions (such as TLS 1.0 and 1.1) and rely on the operating system's default TLS configuration to support the latest secure protocols. For more information, see [disabling legacy TLS versions](deployment/best-practices-security.md#disable-legacy-versions-of-tls-at-the-server-level).

## Configuration security

- **Restrict anonymous access**: Only allow anonymous access to entities when necessary. Otherwise, require authentication for all endpoints to reduce the risk of unauthorized data exposure. For more information, see [anonymous system role](authorization.md#anonymous-system-role).
- **Limit permissions to the minimum required**: Grant users and roles only the permissions they need to perform their tasks. Avoid using wildcard permissions unless necessary. For more information, see [permissions](reference-configuration.md#permissions).

## Monitoring and updates

- **Monitor and audit access**: Detect suspicious activity or unauthorized access attempts by regularly reviewing logs and monitoring access to your Data API builder endpoints. For more information, see [Monitor using application insights](deployment/how-to-use-application-insights.md).
- **Keep dependencies up to date**: Ensure you have the latest security patches and improvements by regularly updating Data API builder, its dependencies, and your underlying platform. For more information, see [DAB versions](whats-new/index.yml).

## Related

- [Azure authentication](authentication-azure.md)
- [Local authentication](authentication-local.md)
- [Authorization and roles](authorization.md)
- [Security best practices](deployment/best-practices-security.md)
