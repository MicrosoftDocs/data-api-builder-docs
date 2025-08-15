---
title: What's new for version 1.5
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 1.5.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 05/16/2025
---

# What's new in Data API builder version 1.5 (April 2025)

Release notes and updates for Data API builder (DAB) version 1.5  
[Release 1.5: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v1.5.50)

## Introducing: Health Endpoint

This release improves how DAB communicates its runtime state. Previously, the root URL returned a simple health result:

```json
{
  "status": "Healthy",
  "version": "1.5.50",
  "app-name": "dab_oss_1.5.50"
}
```

That response shows that validation (similar to `dab validate`) runs and the engine is active—but it doesn't reflect the actual health of data sources or endpoints.

Now, the `/health` endpoint includes basic config details and health checks:

```json
{
  "status": "Unhealthy",
  "version": "1.5.50",
  "app-name": "dab_oss_1.5.50",
  "configuration": {
    "rest": true,
    "graphql": true,
    "caching": false,
    "telemetry": false,
    "mode": "Development"
  },
  "checks": []
}
```

Checks validate the availability and responsiveness of each data source and endpoint—REST and GraphQL—using thresholds you define.


### Endpoint Safety

Health endpoints follow DAB’s role-based access model. Checks run in parallel or sequentially depending on settings, and responses are cached to reduce load from polling.

## Introducing: Schema Inference for Azure Cosmos DB for NOSQL

This enhancement to Azure Data API Builder (DAB) enables automated schema creation directly from Azure CosmosDB NOSQL API collections. earlier, users had to manually define the schema using a schema.gql file. With the new capability, schema generation can be handled through cli, streamlining configuration and reducing the need for upfront knowledge of the database structure.[Read more](../schema-inference-nosql.md)

## Introducing: Custom Log-Level

DAB now supports configurable logging levels. You can set a global default and override it per namespace:

```json
{
  "runtime": {
    "telemetry": {
      "log-level": {
        "default": "trace | debug | information | warning | error | critical | none"
      }
    }
  }
}
```

With per-namespace overrides:

```json
{
  "runtime": {
    "telemetry": {
      "log-level": {
        "default": "warning",
        "Azure.DataApiBuilder.Service": "information",
        "Azure.DataApiBuilder.Engine.Authorization": "error",
        "Microsoft.AspNetCore": "none"
      }
    }
  }
}
```

In `production`, the Hot Reloads feature supports dynamic updates to `log-level`. Other config changes are ignored, but log-level changes apply immediately—ideal for diagnosing issues live.  
[More.](https://github.com/Azure/data-api-builder/pull/2620)

## Introducing: Aggregation in GraphQL

DAB now supports grouping and aggregation operations in GraphQL queries for Microsoft SQL Server (MSSQL). You can generate summaries and insights without more backend logic.

### Features:

- **Aggregation Types**: `SUM`, `AVG`, `MIN`, `MAX`
- **GroupBy Support**: Group results by fields
- **Optimized for MSSQL**: Efficient and reliable query execution
- **Improved Logs**: Clearer schema generation and execution output

Implemented across:

- [Add types for numeric aggregation](https://github.com/Azure/data-api-builder/pull/2521)
- [Add groupBy support and connection updates](https://github.com/Azure/data-api-builder/pull/2541)
- [Enable groupBy and aggregation in MSSQL](https://github.com/Azure/data-api-builder/pull/2550)
- [More improvements and fixes](https://github.com/Azure/data-api-builder/pull/2562)

<!--

## Introducing: Cache Level 2—Redis Support

Before this release, DAB supported only Level 1 in-memory caching—scoped to a single instance. Now, with Level 2 Redis caching, you get shared caching across all instances.

- **Scalable**: Shared by all containers
- **Fast**: Reduces database round-trips
- **Reliable**: Persists through restarts and deployments

-->

### HTTP Cache Headers

DAB now supports:

| Directive         | Meaning |
|------------------|---------|
| `no-cache`        | Use cached data only after revalidating with the server |
| `no-store`        | Don’t cache the response at all |
| `only-if-cached`  | Use cached data only; fail if unavailable |

[More.](https://github.com/Azure/data-api-builder/pull/2650)

## Enhanced: OpenTelemetry

Previously, DAB supported only default ASP.NET Core spans. This release adds custom spans and metrics for REST and GraphQL.

### Metrics:

- **Active Requests**: Real-time count of running requests  
- **Total Requests**: Cumulative count since startup  
- **Total Errors**: Cumulative failures and exceptions  

These metrics improve visibility into runtime behavior and lay the foundation for deeper telemetry.

## Enhanced: Entra ID Auth Provider

DAB originally used the `AzureAd` enum to configure Azure Active Directory. Microsoft has since renamed it to Entra ID.

This release introduces `EntraId` as the preferred value. The old enum (`AzureAd`) still works for backward compatibility, but `EntraId` aligns with current branding.