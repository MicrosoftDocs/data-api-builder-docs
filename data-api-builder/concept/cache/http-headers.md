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

When enabled in configuration, DAB query result caching uses:

* Level 1: In-memory cache
* Level 2: (Optional) distributed cache

These directives affect only DAB’s server-side query cache, not browser, or content delivery network (CDN) caching.

If caching is disabled in the runtime configuration, these directives are ignored and queries run normally.

## Supported request directives

| Header Value                    | Behavior                                                                                                                                     |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `Cache-Control: no-cache`       | Always executes the query against the database, then refreshes (overwrites) the cache with the fresh result.                                 |
| `Cache-Control: no-store`       | Returns a cached result if already present; if not cached, queries the database but doesn't store the new result.                            |
| `Cache-Control: only-if-cached` | Returns the cached result only. If not cached, responds with `504 Gateway Timeout` and an error message.                                     |
| (Absent or unsupported value)   | Default caching: returns cached result if present; otherwise queries the database and stores the result using configured time-to-live (TTL). |

Notes:

* Directive matching is case-insensitive.
* DAB doesn't interpret other standard `Cache-Control` directives such as max-age or max-stale.
* Applies only to REST query operations. Not used for GraphQL request-level cache directives.

## Directive: no-cache

Forces a fresh read and updates the cache layers.

Request:

```http
GET /api/Books
Cache-Control: no-cache
Accept: application/json
```

Response (example):

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

Request:

```http
GET /api/Books
Cache-Control: no-store
Accept: application/json
```

Response (example):

```http
HTTP/1.1 200 OK
Content-Type: application/json

[
  { "id": 1, "title": "The Hobbit" },
  { "id": 2, "title": "The Silmarillion" }
]
```

Effect: If this result wasn't already cached, it won't be stored. A later `only-if-cached` request could fail if no earlier request populated the cache.

## Directive: only-if-cached

Returns the cached result only. If no cached entry exists, DAB returns an error.

Cache hit example:

```http
GET /api/Books
Cache-Control: only-if-cached
Accept: application/json
```

```http
HTTP/1.1 200 OK
Content-Type: application/json

[ ...cached result... ]
```

Cache miss example:

```http
GET /api/Books
Cache-Control: only-if-cached
Accept: application/json
```

```http
HTTP/1.1 504 Gateway Timeout
Content-Type: application/json

{
  "error": "Header 'only-if-cached' was used but item was not found in cache."
}
```

## Default behavior (no directive)

If `Cache-Control` is absent (or contains an unrecognized directive), DAB:

1. Checks cache (L1 or L2 depending on configuration).
2. Returns cached result if present.
3. Otherwise queries the database and stores the result (respecting configured TTLs).
4. Returns `200 OK`.

## Review

* Use `no-cache` when you need to force a refresh from the database and also update the cache.
* Use `no-store` when you want the data but don't want this response to change the cache (though it may read an existing cached value).
* Use `only-if-cached` when you want a fast cached response only and prefer a controlled failure (`504`) over a database round trip.
* Omit the header for normal caching behavior.