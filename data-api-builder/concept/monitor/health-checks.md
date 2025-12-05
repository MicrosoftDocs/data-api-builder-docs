---
title: Use Health Checks and the Health Endpoint
description: Overview of health checks in Data API builder, including configuration and usage of the /health endpoint.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 07/21/2025
# Customer Intent: As a developer, I want to configure health checks to monitor data sources and endpoints via the /health endpoint.
---

# Use Health Checks and the Health Endpoint

Data API builder provides a `/health` endpoint to monitor the responsiveness and health of your API's data sources and entities. This endpoint runs checks against configured data sources and entities, validating that they respond within thresholds you set.

## How health checks work

* For each data source, a simple database-specific query verifies connectivity and measures response time.
* For each entity with REST or GraphQL enabled, a query returns the first N rows to confirm responsiveness.
* Stored procedures are automatically excluded from health checks because they require parameters and may not be deterministic.
* The `/health` endpoint aggregates these results into a comprehensive report indicating overall health.

## Runtime health configuration

Health checks are controlled in the `runtime.health` section:

```json
{
  "runtime": {
    "health": {
      "enabled": true,
      "roles": ["admin", "monitoring"],
      "cache-ttl-seconds": 10,
      "max-query-parallelism": 4
    }
  }
}
```

| Property              | Type     | Default | Description                                                  |
| --------------------- | -------- | ------- | ------------------------------------------------------------ |
| enabled               | boolean  | true    | Enable or disable the comprehensive health endpoint globally |
| roles                 | string[] | null    | Roles allowed to access the `/health` endpoint               |
| cache-ttl-seconds     | integer  | 5       | Time to live in seconds for cached health reports            |
| max-query-parallelism | integer  | 4       | Maximum concurrent health check queries (range: 1-8)         |

### Role-based access behavior

* Development mode (`host.mode: development`):

  * When `roles` is not configured: health endpoint accessible to all users (treated as anonymous)
  * When `roles` is configured: only specified roles can access the endpoint

* Production mode (`host.mode: production`):

  * `roles` must be explicitly defined
  * Omitting `roles` returns 403 Forbidden for all requests
  * To allow public access, set `"roles": ["anonymous"]`

> [!IMPORTANT]
> Roles configured here control access to the health endpoint, not permissions for individual entity operations. If a role lacks permission to query an entity, the health check for that entity will reflect a failure, which is expected behavior.

### Basic health endpoint at the root path

A simplified health endpoint at `/` is always publicly accessible without authentication. It returns basic service information (version, status) without running any health checks.

## Data source health configuration

Each data source can be configured for health checks in `data-source.health`:

```json
{
  "data-source": {
    "health": {
      "enabled": true,
      "name": "primary-sql-db",
      "threshold-ms": 1500
    }
  }
}
```

| Property     | Type    | Default             | Description                                          |
| ------------ | ------- | ------------------- | ---------------------------------------------------- |
| enabled      | boolean | true                | Enable health checks for this data source            |
| name         | string  | database-type value | Unique identifier shown in the health report         |
| threshold-ms | integer | 1000                | Maximum allowed query execution time in milliseconds |

## Entity health configuration

Entity checks can be enabled per entity in `entities.{entity-name}.health`:

```json
{
  "entities": {
    "Book": {
      "health": {
        "enabled": true,
        "first": 50,
        "threshold-ms": 500
      }
    }
  }
}
```

| Property     | Type    | Default | Description                                                |
| ------------ | ------- | ------- | ---------------------------------------------------------- |
| enabled      | boolean | true    | Enable health checks for the entity                        |
| first        | integer | 100     | Number of rows returned by the health query (range: 1-500) |
| threshold-ms | integer | 1000    | Maximum allowed query execution time in milliseconds       |

> [!NOTE]
> The value of `first` must be less than or equal to the runtime configuration for `max-page-size`. A smaller `first` value improves performance. When monitoring many entities, higher `first` values can slow down reports.

Entity health checks run for both REST and GraphQL if enabled. Each appears as a separate entry in the report with tags (`rest` or `graphql`).

## Performance and caching considerations

**Health check cache** (`cache-ttl-seconds`):

* Prevents rapid requests from overwhelming the system
* Caches the complete health report for the configured TTL
* Set to `0` to disable caching
* Default: 5 seconds

**Query parallelism** (`max-query-parallelism`):

* Controls how many health check queries run concurrently
* Higher values speed up checks but increase database load
* Range: 1-8
* Default: 4
* Use lower values if you have many entities or tight resource limits

## Sample health check response

```json
{
  "status": "Healthy",
  "version": "1.2.3",
  "app-name": "dab_oss_1.2.3",
  "timestamp": "2025-01-15T10:30:00Z",
  "configuration": {
    "rest": true,
    "graphql": true,
    "mcp": true,
    "caching": false,
    "telemetry": true,
    "mode": "Production"
  },
  "checks": [
    {
      "status": "Healthy",
      "name": "primary-sql-db",
      "tags": ["data-source"],
      "data": {
        "response-ms": 12,
        "threshold-ms": 1500
      }
    },
    {
      "status": "Healthy",
      "name": "Book",
      "tags": ["rest", "endpoint"],
      "data": {
        "response-ms": 45,
        "threshold-ms": 500
      }
    },
    {
      "status": "Healthy",
      "name": "Book",
      "tags": ["graphql", "endpoint"],
      "data": {
        "response-ms": 38,
        "threshold-ms": 500
      }
    }
  ]
}
```

## Additional considerations

* Health checks respect entity and endpoint authorization. If a role lacks permission to access an entity, the health check reports it.
* Stored procedures are excluded because they require parameters and may have side effects.
* Entities with `rest.enabled: false` or `graphql.enabled: false` are excluded from those checks.
* When `data-source.health.enabled: false`, data source checks are skipped.
