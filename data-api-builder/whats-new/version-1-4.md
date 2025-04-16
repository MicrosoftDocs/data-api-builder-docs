---
title: What's new for version 1.4
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 1.4.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 02/16/2025
---

# What's new in Data API builder version 1.4 (February 2025)

> Our release strategy alternates between feature-focused and stability-focused updates. Odd-numbered releases (like 1.3) introduce new features and enhancements. Even-numbered releases (like 1.4) prioritize bug fixes, polish, and stability. When reading these release notes, remember: odd releases are more expansive, even releases are more incremental.

Release notes and information about the updates and enhancements in Data API builder (DAB) version 1.4.  
[Release 1.4: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v1.4.26)

## Introducing: OpenTelemetry

Data API builder now includes initial support for OpenTelemetry, marking the beginning of our investment in deep, custom observability. Tracing gives developers visibility into request flow, helping detect bottlenecks, diagnose errors, and understand performance.

This release emits spans for key operations such as request handling and query execution. These spans follow OpenTelemetry conventions and can be exported to Azure Monitor, Jaeger, Zipkin, or any compatible backend.

Future releases add richer metadata, broader coverage, and customizable instrumentation to give you insight into your API’s behavior, latency, and usage patterns.  
[More.](https://github.com/Azure/data-api-builder/pull/2449)

## Enhancement: Cosmos Schema Generation with Multi-Container Support

This release improves schema generation for Cosmos DB. Data API builder now automatically scans all configured containers and uses defined entities to generate schemas, simplifying onboarding and setup.

It also resolves key bugs: generation no longer fails with empty arrays or PascalCase singular/plural naming. Logging now confirms success only when a meaningful, nonempty schema is created.

These changes make schema generation more reliable, more automatic, and more developer-friendly.  
[More.](https://github.com/Azure/data-api-builder/pull/2479)

## Command Line Everything

We continue expanding CLI support to cover more configuration properties. This release brings us closer to full coverage.  
[More.](https://github.com/Azure/data-api-builder/pull/2455)

**Runtime.Host**

```sh
dab configure --runtime.host.mode development

dab configure --runtime.host.cors.origins "http://localhost1,http://localhost2"

dab configure --runtime.host.authentication.provider MyProvider

dab configure --runtime.host.authentication.jwt.audience MyAudience

dab configure --runtime.host.authentication.jwt.issuer MyIssuer
```

**Note:** The `authentication.jwt.audience` and `authentication.jwt.issuer` properties can only be set if `authentication.provider` is `Jwt`. The CLI checks for this nuance before applying the update.