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

Data API builder provides a `/health` endpoint to monitor the responsiveness and health of your API’s data sources and entities. This endpoint runs checks against all configured data sources, REST endpoints, and GraphQL entities, validating that they respond within thresholds you set.

## How health checks work

* For each **data source**, a simple database-specific query verifies connectivity and measures response time.
* For each **entity** (REST or GraphQL), a query without predicates runs, returning the first N rows to confirm responsiveness.
* The `/health` endpoint aggregates these results into a comprehensive report indicating overall health.

## Runtime health configuration

Health checks are controlled in the [`runtime.health` section](../../configuration/runtime.md#health-runtime), which configures the global health endpoint:

### Example runtime health configuration

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

### Roles behavior

* When `host.mode` is **development**, the health endpoint is accessible to everyone without requiring roles; all calls are treated as anonymous.
* When `host.mode` is **production**, roles **must** be explicitly defined to access the comprehensive health endpoint. Omitting roles disables access except for anonymous if specified.
* Multiple roles can be included in the `roles` array.
* The roles here **do not override** the roles' permissions for API or GraphQL access. If a role lacks permission to execute an endpoint or query, the health check will reflect a failure.
* At the root path `/`, a basic health endpoint is always available to everyone with limited information and no health checks.

## Data source health configuration

Each data source can be configured for health checks individually in `data-source.health`:

| Property       | Description                                               | Default             |
| -------------- | --------------------------------------------------------- | ------------------- |
| `enabled`      | Enable health checks for this data source                 | true                |
| `name`         | Unique label shown in the health report                   | database-type value |
| `threshold-ms` | Maximum allowed time in milliseconds for the health query | 1000                |

Example:

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

## Entity health configuration

Health checks can also be enabled per entity in `entities.{entity-name}.health`:

| Property       | Description                                        | Default |
| -------------- | -------------------------------------------------- | ------- |
| `enabled`      | Enable health check for the entity                 | true    |
| `first`        | Number of rows returned by the health query        | 100     |
| `threshold-ms` | Maximum allowed time in milliseconds for the query | 1000    |

> [!NOTE]
> The value of `first` must be less than or equal to the runtime configuration for `max-page-size`. Having said that, remember that a smaller `first` value helps health checks complete faster. When there are many entities, higher `first` values can negatively delay health reports. 

Example:

```json
{
  "entities": {
    "Book": {
      "health": {
        "enabled": true,
        "first": 3,
        "threshold-ms": 500
      }
    }
  }
}
```

## Additional considerations

* The **health check cache** prevents repeated rapid requests from overwhelming the system by caching the health report for the configured TTL.
* **Max query parallelism** controls concurrency of checks to speed execution without overloading resources; use this value with care.
* The **root `/` health endpoint** provides minimal info with no checks and is always publicly accessible.
* Health check failures respect entity and endpoint authorization — lack of permission results in failure reports, consistent with DAB’s security model.

