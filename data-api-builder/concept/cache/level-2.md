---
title: Implement level 2 cache
description: Configure distributed level 2 cache in Data API builder with Redis and entity-level cache settings.
author: jerrynixon
ms.author: jnixon
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/24/2026
# Customer Intent: As a developer, I want to use level 2 cache to make stateless containers warm start. 
---

# Implement level 2 cache

Data API builder long supported Level 1 (`L1`) in-memory cache and cache-related HTTP request headers like `no-store`, `no-cache`, and `only-if-cached` to influence cache behavior.

Level 2 (`L2`) cache extends caching beyond the local process by adding a distributed cache layer. With `L2`, cached results can be reused across multiple DAB instances and can survive individual container restarts, which makes stateless deployments feel less stateless in all the right ways.

## Benefits of level 2 cache

Use level 2 cache when you want to:

* Share cached results across scaled-out DAB instances
* Reduce database round trips for repeated reads
* Keep stateless containers warm after recycle or redeploy
* Improve performance for read-heavy workloads
* Namespace cache participation with partitions

## Configure runtime cache settings

Level 2 cache is configured globally under `runtime.cache`. The runtime cache block enables caching, sets the default time to live (TTL), and configures the distributed cache provider.

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

### Runtime properties

| Property | Description |
|---|---|
| `enabled` | Enables cache support globally. |
| `ttl-seconds` | Sets the default cache time-to-live in seconds. |
| `level-2.enabled` | Turns on the distributed cache tier. |
| `level-2.provider` | Selects the distributed cache provider. Currently `redis` is supported. |
| `level-2.connection-string` | Connection string for the Redis instance. |
| `level-2.partition` | Optional namespace for Redis keys and the backplane channel. Only containers using the same partition share the same distributed cache space. |

## Configure entity-specific cache behavior

Entities can override the global cache behavior. Use the entity `cache` block to enable caching, set a custom TTL, and choose the cache level.

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

### The `cache.level` property

Use `cache.level` to control which cache tiers an entity uses.

| Value | Description |
|---|---|
| `L1` | In-memory cache only. Fast and local to the current DAB process. |
| `L1L2` | In-memory plus distributed cache. This level is the default for cached entities. |

If `L2` isn't enabled globally, an entity configured with `L1L2` behaves as `L1`.

## How `L1L2` works

> [!TIP]
> **TL;DR** `L1L2` = Request → L1 → L2 → database → L2 → L1 → Response

By default, an entity with caching enabled uses level `L1L2`.

* `L1` is the per-process in-memory cache.
* `L2` is the distributed cache layer, currently Redis, plus a backplane for cross-instance coherence.

With `L1L2`, a cache lookup first checks `L1`. On an `L1` miss, it checks `L2` if level 2 caching is globally enabled and configured. If the entry isn't found in either layer, DAB executes the database query. The result is then stored in both `L1` and `L2`.

That means:

* Future requests on the same instance are served from local `L1`
* Requests on other instances can read from `L2` and promote the entry into their own `L1`
* If a container restarts, an `L1` miss followed by an `L2` hit can still avoid a database round trip

This combination gives you a warm distributed cache across scaled-out or recycled instances.

## Redis support

Redis is the current provider for level 2 cache. It's well-suited for this scenario because it supports:

* Shared access across multiple DAB instances
* Key expiration for TTL-based caching
* Fast reads and writes for high-throughput workloads
* Backplane coordination across instances

## Partitioned cache spaces

Use the optional `partition` setting to isolate distributed cache activity. DAB uses the partition value to namespace Redis keys and the backplane channel. Only containers sharing the same partition participate in the same distributed cache space.

This setting is useful when you want to:

* Separate production and nonproduction traffic
* Isolate tenants or environments
* Prevent unrelated services from sharing cached entries

## See also

* [Use level 1 cache](level-1.md)
* [Use Cache-Control header](http-headers.md)
* [What's new for version 1.6](../../whats-new/version-1-6.md)
