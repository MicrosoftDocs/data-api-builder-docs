---
title: Implement pagination in REST or GraphQL
description: Implement pagination in REST or GraphQL
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 07/16/2025
# Customer Intent: As a developer, I want to page large returned payloads, so I can deal with large data.
---

# Pagination in REST or GraphQL

Payload pagination lets a Data API point to extremely large datasets without overwhelming the client or the API itself. Instead of returning all rows at once, Data API builder automatically breaks responses into pages, improving performance and protecting system resources.

This paging system works with both REST and GraphQL endpoints, and it includes built-in support for cursor-based navigation. Even when querying busy or fast-changing tables, cursor-based pagination helps deliver stable, consistent results across page loads.

## What is Cursor Navigation

Index navigation returns rows by position, like "rows 51 to 100." This works fine for static data but breaks if rows are added or removed between requests. The result is often skipped or duplicated rows.

Cursor navigation avoids this by using a stable reference, such as a unique ID or internal token, to remember where the previous page ended. This keeps pagination reliable even if the underlying data changes between calls.

For example, if a user loads 50 rows and new data is inserted before the next page request, cursor navigation still picks up exactly where the previous call left off. This behavior is built into Data API builder using `$first` and `$after` in REST, or `first` and `after` in GraphQL.

### Requesting Pages with `$after` (REST) or `after` (GraphQL)

Once the first page is retrieved, the response includes a continuation token. In REST, this comes as a `nextLink` URL. In GraphQL, it appears as an `endCursor` value inside a `pageInfo` object. You can use that token with `$after` or `after` to request the next page of results without skipping or repeating data.

#### REST Example with `$after`

```http
GET /api/products?$first=3&$after=eyJpZCI6MywidHMiOjE3MDA4MDg1NTU1fQ==
```

This call returns the next 3 items starting after the item represented by the token. Here’s what the REST payload might look like:

```json
{
  "value": [
    { "id": 1, "name": "Item A" },
    { "id": 2, "name": "Item B" },
    { "id": 3, "name": "Item C" }
  ],
  "nextLink": "/api/products?$first=3&$after=eyJpZCI6MywidHMiOjE3MDA4MDg1NTU1fQ=="
}
```

The `nextLink` field contains a ready-to-use continuation URL. The client can call this to get the next page.

#### GraphQL Example with `after`

In GraphQL, there is no `nextLink`. Instead, you must explicitly request `pageInfo` to receive the cursor and check if more pages are available.

```graphql
query {
  products(first: 3) {
    items {
      id
      name
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

Sample GraphQL response:

```json
{
  "data": {
    "products": {
      "items": [
        { "id": 1, "name": "Item A" },
        { "id": 2, "name": "Item B" },
        { "id": 3, "name": "Item C" }
      ],
      "pageInfo": {
        "hasNextPage": true,
        "endCursor": "eyJpZCI6MywidHMiOjE3MDA4MDg1NTU1fQ=="
      }
    }
  }
}
```

To get the next page, supply the `endCursor` value using the `after` parameter:

```graphql
query {
  products(first: 3, after: "eyJpZCI6MywidHMiOjE3MDA4MDg1NTU1fQ==") {
    items {
      id
      name
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

## Controlling the Payload

Data API builder gives developers flexible ways to control how much data is returned in a single request. This applies to both REST and GraphQL endpoints and helps avoid overloading the client or the API.

### Understanding runtime.pagination.default-page-size

The [`runtime.pagination.default-page-size`](../../configuration/runtime.md#pagination-runtime) setting defines how many rows are returned by default when no explicit limit is specified. This setting applies to both REST and GraphQL queries.

#### REST Example using `$first`

```http
GET /api/products?$first=10 HTTP/1.1
Host: myapi.com
```

#### GraphQL Example using `first`

```graphql
query {
  products(first: 10) {
    items {
      id
      name
    }
  }
}
```

In both cases, the response will return only 10 items, even if more exist. This allows UIs to stay responsive and helps manage bandwidth and processing.

### Understanding runtime.pagination.max-page-size

The [`runtime.pagination.max-page-size`](../../configuration/runtime.md#pagination-runtime) setting defines the upper limit for any request, even when a higher value is requested using `$first` or `first`. This prevents users from requesting excessively large payloads that could degrade performance.

> [!NOTE]
> Setting `$first=-1` (or `first: -1` in GraphQL) tells the API to return the maximum number of rows allowed by `max-page-size`. This gives consumers an easy way to request the full limit without knowing its exact value.

### Understanding runtime.host.max-response-size-md

The [`runtime.host.max-response-size-md`](../../configuration/runtime.md#maximum-response-size-host-runtime) setting controls the total response size in megabytes, regardless of row count. This is useful when rows include large fields such as `NVARCHAR(MAX)`, `JSON`, or binary data.

Even a small number of rows can create a large payload depending on the column types. This setting protects the API and clients from heavy responses that could exceed memory or network limits.

These settings work together to balance performance, safety, and flexibility across both REST and GraphQL.
