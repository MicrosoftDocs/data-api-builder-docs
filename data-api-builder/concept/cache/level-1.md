---
title: Implement internal, level 1 cache
description: Implement internal, level 1 cache
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 07/16/2025
# Customer Intent: As a developer, I want to use level 1 cache to ease queries against my database
---

# Implement level 1 cache

Level 1 cache in Data API builder reduces redundant requests to the database by temporarily caching entity results in memory. This improves performance for frequent queries and avoids hitting the database unnecessarily.

## Enable cache globally

To enable caching, set the global runtime configuration:

```json
"runtime": {
  "cache": {
    "enabled": true,
    "ttl-seconds": 60
  }
}
```

* `enabled`: Required. Turns on caching globally.
* `ttl-seconds`: Optional. Defines the default time-to-live (in seconds) for cached items.

See [runtime cache settings](../../configuration/runtime.md#cache-runtime).

## Enable cache per entity

Each entity must also opt in to use cache:

```json
"MyEntity": {
  "cache": {
    "enabled": true,
    "ttl-seconds": 30
  }
}
```

* `enabled`: Required. Enables caching for this specific entity.
* `ttl-seconds`: Optional. If not specified, inherits from the global TTL.

See [entity cache settings](../../configuration/entities.md#cache-entity-name-entities).

## Behavior

* Applies only to REST endpoints.
* Works on a per-route, per-parameter basis.
* Cache is invalidated when data is modified (create, update, delete).
* Entity `ttl-seconds` overrides global `ttl-seconds`.

## Notes

* Level 1 cache is in-memory only.
* Best suited for read-heavy scenarios with low data volatility.

## Related content

* [Configuration reference](../../configuration/index.md)
* [Install the CLI](../../how-to/install-cli.md)
