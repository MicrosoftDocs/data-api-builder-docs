---
title: What's new for version 1.6
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 1.5.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 09/24/2025
---

# What’s new in Data API builder 1.6

This incremental release focuses on multi-tier caching, expanded logging and observability, secret management, and query/pagination improvements.

## Introducing: Level 2 (Distributed) Caching

Data API builder has long supported Level 1 (L1) in-memory cache and cache-related HTTP request headers like `no-store`, `no-cache`, and `only-if-cached` to influence cache behavior.

In this release, we added Level 2 (L2) distributed cache.

**Global runtime configuration:**

```json
{
  "runtime": {
    "cache": {
      "enabled": true,
      "ttl-seconds": 30,
      "level-2": {
        "enabled": true,
        "provider": "redis",
        "connection-string": "localhost:6379",
        "partition": "prod-api"
      }
    }
  }
}
```

**Entity-specific overrides:**

```json
{
  "entities": {
    "Products": {
      "source": "dbo.Products",
      "cache": { "enabled": true, "ttl-seconds": 120, "level": "L1L2" }
    },
    "Orders": {
      "source": "dbo.Orders",
      "cache": { "enabled": true, "level": "L1" }
    }
  }
}
```

### Cache level `L1L2`

> **TL;DR** `L1L2` = Request → L1 → L2 → DB → L2 → L1 → Response

By default, an entity with caching enabled uses level `L1L2`. `L1` is the per-process in-memory cache. `L2` is the distributed cache layer (currently Redis) plus a backplane for cross-instance coherence. With `L1L2`, a cache lookup first checks `L1`. On an `L1` miss, it checks `L2` if level-2 caching is globally enabled and configured. If the entry isn't in either layer, DAB executes the database query. The result is stored in both `L1` and `L2` (dual write). Future requests on the same instance are served from local `L1`.

Requests on other instances can pull from `L2` and promote the entry into their own `L1`. If the local container is recycled, an `L1` miss followed by an `L2` hit still avoids a database round trip, giving you a warm distributed cache. If `L2` isn't enabled globally, an entity set to `L1L2` behaves as `L1`. An optional partition setting namespaces Redis keys and the backplane channel so only containers sharing that partition participate in the same distributed cache space.

## Introducing: Flexible logging

Before release 1.5, developers were subject to the default log levels and filters hardcoded into DAB. We now support configurable filters and levels for logs emitted by the engine.

Now, in release 1.6, we add to our list of sinks. In addition to Application Insights and OpenTelemetry publishing, Data API builder now supports both **file** and **Azure Log Analytics** as targets. Rich, configurable logging wherever you need it.

```json
{
  "telemetry": {
      "log-level": { },
      "open-telemetry": { },
      "application-insights": { },
      "azure-log-analytics": { }, // new!
      "file": { } // new!
    }
  }
}
```

### File sink

Previously, DAB developers were mostly limited to console logs in the container. With release 1.6, you can now sink logs to local files in a container folder to systematically debug and observe DAB behavior in your preferred monitoring solution. Mounting a container volume as the target folder is an easy way to preserve logs across container lifecycles.

**Example file sink configuration:**

```json
{
  "telemetry": {
      "file": {
        "enabled": ...,               // Turn file logging on or off
        "path": ...,                  // Folder path for log files
        "rolling-interval": ...,      // How often a new log file is created
        "retained-file-count-limit": ..., // Max number of log files to keep
        "file-size-limit-bytes": ..., // Max size of a log file before rolling
      }
    }
  }
}
```

### Azure Log Analytics Sink

Enterprise developers often face stricter requirements than local debugging can meet. Many organizations mandate centralized logging, compliance auditing, and integration with corporate monitoring solutions. To support these scenarios, Data API builder integrates with Azure Log Analytics, allowing logs to flow into a secure, centralized platform that aligns with enterprise policies for retention, governance, and observability.

**Example Azure Log Analytics sink configuration:**

```json
{
  "telemetry": {
      "azure-log-analytics": {
        "enabled": ...,                 // Turn logging on or off
        "auth.workspace-id": ...,       // Workspace ID 
        "auth.dcr-immutable-id": ...,   // Data Collection Rule
        "auth.dce-endpoint": ...,       // Data Collection Endpoint
        "dab-identifier": ...,          // Unique string to identify log source
        "flush-interval-seconds": ...,  // How often logs are flushed
       }
    }
  }
}
```

**Versus Application Insights**

Where Application Insights focuses on app performance monitoring (APM), Azure Log Analytics provides broader coverage, aggregating logs from apps, Azure resources, VMs, containers, networks, and security tools into a centralized workspace for Kusto (KQL) queries, correlation, and compliance.

## Introducing: Azure Key Vault support

Since the beginning, Data API builder configuration files have supported the `@env()` function to replace values in the configuration file with environment variables. This ensures secrets are never checked in with the configuration file. DAB also supports `.env` files in local development so developers can simulate and test configurations.

With release 1.6, we now support Azure Key Vault the same way. The new `@akv()` function replaces values in the configuration file with values from Azure Key Vault. This lets developers who rely on centralized secret storage use Data API builder in lockstep with enterprise standards.

> [!Note]
> Just as Data API builder supports `.env` files for local developers simulating environment variables, DAB now supports `.akv` files. These files let developers without an Azure Key Vault simulate the service locally. They use the same simple `name=value` format and should always be added to your `.gitignore`.

**Example (function syntax):**

Using the `@env()` function:

```bash
{
  "data-source": {
    "connection-string": "@env('my-environment-variable-name')"
  }
}
```

Using the `@akv()` function:

```bash
{
  "data-source": {
    "connection-string": "@akv('my-akv-secret-name')"
  }
}
```

**Example Azure Key Vault configuration:**

```json
{
  "azure-key-vault": {
    "endpoint": "...",                          // Key Vault endpoint URL
    "retry-policy.mode": "...",                 // Retry mode (fixed or exponential)
    "retry-policy.max-count": ...,              // Maximum retry attempts
    "retry-policy.delay-seconds": ...,          // Initial delay between retries
    "retry-policy.max-delay-seconds": ...,      // Maximum delay for exponential backoff
    "retry-policy.network-timeout-seconds": ... // Network timeout duration
  }
}
```

## Query and Pagination Enhancements

### Introducing: IN Operator (SQL backends, GraphQL)

DAB's new `IN` operator helps simplify multi-value filtering in GraphQL queries. It reduces chained `OR` filters, generating cleaner SQL. Note that this feature is part of DAB's GraphQL syntax and is not yet in DAB's REST `$filter` syntax.

```graphql
query {
  products(filter: { status: { in: ["ACTIVE", "PENDING"] } }) {
    items { id name status }
  }
}
```

### Introducing: Relative nextLink

DAB's new relative `nextLink` option lets developers configure the engine to emit relative links instead of absolute links. This feature, a frequent community request, is especially useful in reverse proxy and domain rewriting scenarios where relative links prevent mismatched hostnames.

```json
{
  "runtime": {
    "rest": {
      "next-link-relative": true // default is false
    }
  }
}
```

## Health checks

To deliver a faster composite status, Data API builder health checks can now run in parallel. This reduces latency in multi-source deployments, especially when several endpoints are involved and health checks are used to determine the deployment status of the DAB container, such as in the .NET Aspire application host.

**Example Health DOP configuration:**

```json
{
  "runtime": {
    "health": {
      "max-query-parallelism": 8 
    }
  }
}
```

| `max-query-parallelism` | DOP |
| ----------------------- | :-: |
| Minimum                 |  1  |
| Default                 |  4  |
| Maximum                 |  8  |

## DWSQL policies

Data API builder has always allowed developers to configure API-level policies. These policies append as additional predicates to the query’s WHERE clause and support `@item` and `@claim` interrogation, providing advanced row-level security without requiring database changes.

With release 1.6, Data API builder extends this capability to Azure SQL Data Warehouse (`dwsql`), a data source already supported but without policy integration until now. Developers can now define policies that bring DWSQL in line with other SQL database types.

**Example entity with policy configuration:**

```json
{
  "entities": {
    "Orders": {
      "source": "dbo.Orders",
      "permissions": [
        {
          "role": "authenticated",
          "actions": [ "read" ],
          "policy": "@item.Region = @claim.region"
        }
      ]
    }
  }
}
```

In this example, when an `authenticated` user queries `Orders`, the engine appends `WHERE Region = <user's claim:region>` automatically.

