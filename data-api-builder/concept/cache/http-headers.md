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

For REST endpoints, you can influence how Data API builder (DAB) uses its internal query result cache using the `Cache-Control` request header.

When enabled in configuration, DAB query result caching uses:

* Level 1: In-memory cache
* Level 2: (Optional) distributed cache

These directives affect only DAB’s server-side query cache, not browser or CDN caching.

If caching is disabled in the runtime configuration, these directives are ignored and queries execute normally.

## Supported request directives

| Header Value                    | Behavior (per implementation)                                                                                                 |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `Cache-Control: no-cache`       | Always executes the query against the database, then refreshes (overwrites) the cache with the fresh result.                  |
| `Cache-Control: no-store`       | Returns a cached result if already present; if not cached, queries the database but does not store the new result.            |
| `Cache-Control: only-if-cached` | Returns the cached result only. If not cached, responds with `504 Gateway Timeout` and an error message.                      |
| (Absent or unsupported value)   | Default caching: returns cached result if present; otherwise queries the database and stores the result using configured TTL. |

Notes:

* Directive matching is case-insensitive.
* No other standard Cache-Control directives (such as max-age or max-stale) are interpreted by DAB.
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

Uses an existing cached value if present; otherwise queries the database but does not populate (or refresh) the cache with the new result.

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

Effect: If this result was not already cached, it will not be stored. A subsequent `only-if-cached` request could fail if no earlier request populated the cache.

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

1. Checks cache (L1/L2 depending on configuration).
2. Returns cached result if present.
3. Otherwise queries the database and stores the result (respecting configured TTLs).
4. Returns `200 OK`.

## Summary

* Use `no-cache` when you must force a refresh from the database and also update the cache.
* Use `no-store` when you want the data but do not want this response to change the cache (though it may read an existing cached value).
* Use `only-if-cached` when you want a fast cached response only and prefer a controlled failure (`504`) over a DB round trip.
* Omit the header for normal caching behavior.

These directives give you explicit, per-request control over how DAB leverages its query result caching layers.
