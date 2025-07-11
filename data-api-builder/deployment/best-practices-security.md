---
title: Security best practices
description: Review a list of current best practices and recommendations for security and connectivity in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: best-practice
ms.date: 06/11/2025
# Customer Intent: As a developer, I want to review best practices, so that I can configure my API using current best practices.
---

# Security best practices in Data API builder

:::image type="complex" source="media/best-practices-security/map.svg" border="false" alt-text="Diagram of the current location ('Optimize') in the sequence of the deployment guide.":::
Diagram of the sequence of the deployment guide including these locations, in order: Overview, Plan, Prepare, Publish, Monitor, and Optimization. The 'Optimize' location is currently highlighted.
:::image-end:::

This article includes the current recommended best practices for security in the Data API builder. This article doesn't include an exhaustive list of every security consideration for your Data API builder solution.

## Disable Legacy Versions of TLS at the Server Level

Data sent between a client and Data API builder should occur over a secure connection to protect sensitive or valuable information. A secure connection is typically established using Transport Layer Security (TLS) protocols.

As detailed in [OWASP's Transport Layer Protection](https://cheatsheetseries.owasp.org/cheatsheets/Transport_Layer_Protection_Cheat_Sheet.html) guidance, TLS provides numerous security benefits when implemented correctly:

- **Confidentiality** - protection against an attacker from reading the contents of traffic.
- **Integrity** - protection against an attacker modifying traffic.
- **Replay prevention** - protection against an attacker replaying requests against the server.
- **Authentication** - allowing the client to verify that they're connected to the real server (note that the identity of the client isn't verified unless client certificates are used).

## Recommendations

One way to help configure TLS securely is **to disable usage of legacy versions of TLS at the server level**. Data API builder is built on Kestrel, a [cross-platform web server for ASP.NET Core](/aspnet/core/fundamentals/servers/kestrel?view=aspnetcore-6.0&preserve-view=true) and is configured by default to defer to the operating system's TLS version configuration. Microsoft's [TLS best practices for .NET guidance](/dotnet/framework/network-programming/tls) describe the motivation behind such behavior:

> [!NOTE]
> TLS 1.2 is a standard that provides security improvements over previous versions. TLS 1.2 will eventually be replaced by the newest released standard TLS 1.3 which is faster and has improved security.
>
> To ensure .NET Framework applications remain secure, the TLS version should not be hardcoded. .NET Framework applications should use the TLS version the operating system (OS) supports.

While explicitly defining supported TLS protocol versions for Kestrel is supported, doing so isn't recommended. These definitions translate to an allowlist, which prevents support for future TLS versions as they become available. More information about Kestrel's default TLS protocol version behavior can be found [here](/dotnet/core/compatibility/aspnet-core/5.0/kestrel-default-supported-tls-protocol-versions-changed).

## TLS support

TLS 1.2 is enabled by default on the latest versions of .NET and many of the latest operating system versions.

### [Windows](#tab/windows)

- Install .NET on Windows - [Microsoft Learn](/dotnet/core/install/windows?tabs=net60)
- Enable support for TLS 1.2 in your environment - [Microsoft Entra ID Guidance](/troubleshoot/azure/active-directory/enable-support-tls-environment?tabs=azure-monitor#enable-support-for-tls-12-in-your-environment)
- TLS 1.2 support at Microsoft - [Microsoft Security Blog](https://www.microsoft.com/security/blog/2017/06/20/tls-1-2-support-at-microsoft/)

### [macOS](#tab/macos)

- Install .NET on macOS - [Microsoft Learn](/dotnet/core/install/macos)
- TLS Security - [Apple Platform Security](https://support.apple.com/guide/security/tls-security-sec100a75d12/web)
- TLS 1.2 is enabled starting with OS X Mavericks(10.9) - [About the security content of OS X Mavericks v10.9](https://support.apple.com/HT202854)

### [Linux](#tab/linux)

- Install .NET on Linux - [Microsoft Learn](/dotnet/core/install/linux)
- Linux .NET Dependencies - [GitHub](https://github.com/dotnet/core/blob/main/release-notes/6.0/linux-packages.md)
  - Includes [OpenSSL](https://www.openssl.org/) where the latest versions support TLS protocol versions up through TLS 1.3. [OpenSSL Wiki](https://wiki.openssl.org/index.php/TLS1.3)

---
