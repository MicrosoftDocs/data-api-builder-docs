---
title: Use after (GraphQL)
description: Learn how cursor-based pagination works in GraphQL for Data API builder, how continuation tokens are generated, and how to request subsequent pages safely and efficiently.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/08/2025
# Customer Intent: As a developer, I want to understand how to page through large GraphQL datasets safely, efficiently, and without duplicates or missing data.
---

# Pagination with `$after` in REST

Pagination narrows large datasets to smaller, manageable pages. In REST, Data API builder (DAB) uses the `$after` query parameter for **keyset pagination**, providing stable and efficient traversal through ordered results.

Each token represents the position of the last record from the previous page, allowing the next request to continue from that point. Unlike offset pagination, keyset pagination avoids missing or duplicated rows when data changes between requests.

> [!Note]
> `$after` carries an opaque token that identifies where the last page ended. Treat tokens as immutable and never attempt to construct or modify them.

### Quick glance

| Concept    | Description                                                   |
| ---------- | ------------------------------------------------------------- |
| `$after`   | The opaque continuation token returned from the prior request |
| `$first`   | The maximum number of records to fetch per page               |
| `nextLink` | URL for the next page, includes `$after`                      |
| `value`    | The array of returned items for the current page              |

### How pagination works

1. The client requests the first page using `$first` to set page size.
2. DAB returns a list of items and a `nextLink` that includes `$after`.
3. The client uses the `nextLink` or copies the `$after` value into the next request.
4. The process repeats until `nextLink` is no longer present.

### `$after`

Specifies the continuation token for the next page. The value is a base64-encoded string that represents the last record of the previous result set.

In this example we are getting the next three products after the last page’s token.

```http
GET /api/products?$first=3&$after=eyJpZCI6MywidHMiOjE3MDA4MDg1NTU1fQ==
```

#### Resulting SQL from the above example

```sql
SELECT TOP (3) id, name
FROM Products
WHERE (id > 3)
ORDER BY id ASC;
```

### `$first`

Defines how many records to return per request. Used with `$after`, it determines a precise window over the ordered dataset.

In this example we are getting the first three products.

```http
GET /api/products?$first=3
```

Sample response:

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

If `next-link-relative=true` in configuration, `nextLink` will contain a relative path; otherwise, it will be an absolute URL.

### How tokens are formed

Internally, DAB encodes the last record of each page as a token:

1. DAB collects pagination columns from the current order (including direction).
2. It includes any remaining primary key columns as tie-breakers.
3. Each field is serialized into JSON and base64-encoded.

Decoded example:

```json
[
  { "EntityName": "Product", "FieldName": "createdOn", "FieldValue": "2024-11-05T12:34:56Z", "Direction": 0 },
  { "EntityName": "Product", "FieldName": "id", "FieldValue": 42, "Direction": 0 }
]
```

> [!Note]
> Any schema or ordering change invalidates previously issued tokens. Clients must restart pagination from the first page.

### End of data

When `nextLink` is absent, there are no additional records to fetch.

The final page response includes only a `value` array without a `nextLink`.