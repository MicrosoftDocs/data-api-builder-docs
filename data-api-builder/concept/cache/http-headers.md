---
title: Use http headers to control caching from the request
description: Use http headers to control caching from the request
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 07/16/2025
# Customer Intent: As a developer, I want to add use http headers to control cache without changes to the Data API.
---

# Cache-Control in REST query caching

For REST endpoints, you can influence how Data API builder (DAB) uses its internal query result cache with the `Cache-Control` request header.

> [!INFORMATION]
> If caching is disabled in the runtime configuration, these directives are ignored and queries run normally.

## Supported Cache-Control values

| Value | Behavior
| - | - 
| `no-cache`       | Forces DAB to bypass both L1 and L2 caches, fetch fresh data from the database, and update the caches with the new result.
| `no-store`       | Tells DAB not to cache the response at all (does not store in L1 or L2, and does not attempt to fetch from cache).

### Behavior

* Directive matching is case-insensitive.
* DAB doesn't interpret other standard `Cache-Control` directives such as max-age or max-stale.
* Applies only to REST query operations. Not used for GraphQL request-level cache directives.
* The Cache-Control request HTTP header values control both L1 and L2 cache.

> [!Note]
> DAB does not set cache-control response headers for any cache operation.

## Directive: no-cache

Forces a fresh read and updates the cache layers.

### Request

```http
GET /api/Books
Cache-Control: no-cache
Accept: application/json
```

### Response (example)

```http
HTTP/1.1 200 OK
Content-Type: application/json

[
  { "id": 1, "title": "The Hobbit" },
  { "id": 2, "title": "The Silmarillion" }
]
```

Effect: Cache now holds this fresh result (subject to configured TTL).

## Directive: no-store

Uses an existing cached value if present; otherwise queries the database but doesn't populate (or refresh) the cache with the new result.

### Request

```http
GET /api/Books
Cache-Control: no-store
Accept: application/json
```

### Response (example)

```http
HTTP/1.1 200 OK
Content-Type: application/json

[
  { "id": 1, "title": "The Hobbit" },
  { "id": 2, "title": "The Silmarillion" }
]
```

Effect: If this result wasn't already cached, it won't be stored. A later `only-if-cached` request could fail if no earlier request populated the cache.

## Review

* Use `no-cache` when you need to force a refresh from the database and also update the cache.
* Use `no-store` when you want the data but don't want this response to change the cache (though it may read an existing cached value).
* Omit the header for normal caching behavior.