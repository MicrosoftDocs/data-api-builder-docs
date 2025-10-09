---
title: Use after (REST)
description: Learn how cursor-based pagination works in REST for Data API builder, how continuation tokens are generated, and how to request subsequent pages safely and efficiently.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/08/2025
# Customer Intent: As a developer, I want to understand how to page through large REST datasets safely, efficiently, and without duplicates or missing data.
---

# Pagination with `$after` in REST

Pagination narrows large datasets to smaller, manageable pages. In REST, Data API builder (DAB) uses the `$after` query parameter for **keyset pagination**, providing stable and efficient traversal through ordered results. Each token represents the position of the last record from the previous page, allowing the next request to continue from that point. Unlike offset pagination, keyset pagination avoids missing or duplicated rows when data changes between requests.

Go to the [GraphQL version of this document](./after-graphql.md).

## Quick glance

| Concept    | Description                                                   |
| ---------- | ------------------------------------------------------------- |
| `$after`   | The opaque continuation token returned from the prior request |
| `$first`   | The maximum number of records to fetch per page               |
| `nextLink` | URL for the next page, includes `$after`                      |

## Basic pagination

In this example we are getting the first three books.

### HTTP request

```http
GET /api/books?$first=3
```

### Conceptual SQL

```sql
SELECT TOP (3)
  id,
  sku_title AS title
FROM dbo.books
ORDER BY id ASC;
```

### Sample response

```jsonc
{
  "value": [
    { "id": 1, "title": "Dune" },
    { "id": 2, "title": "Foundation" },
    { "id": 3, "title": "Hyperion" }
  ],
  "nextLink": "/api/books?$first=3&$after=eyJpZCI6M30="
}
```

> [!NOTE]
> If `next-link-relative=true` in configuration, `nextLink` will contain a relative path; otherwise, it will be an absolute URL.

## Continuation with `$after`

The `$after` parameter specifies the continuation token for the next page. The value is a base64-encoded string representing the last record of the previous page.

> [!WARNING]
> `$after` carries an opaque token that identifies where the last page ended. Treat tokens as immutable and never attempt to construct or modify them.

In this example we are getting the next three books after the last page’s token.

### HTTP request

```http
GET /api/books?$first=3&$after=eyJpZCI6M30=
```

### Conceptual SQL

```sql
SELECT TOP (3)
  id,
  sku_title AS title
FROM dbo.books
WHERE id > 3
ORDER BY id ASC;
```

### Sample response

```jsonc
{
  "value": [
    { "id": 4, "title": "I, Robot" },
    { "id": 5, "title": "The Left Hand of Darkness" },
    { "id": 6, "title": "The Martian" }
  ],
  "nextLink": "/api/books?$first=3&$after=eyJpZCI6Nn0="
}
```

## End of data

When `nextLink` is absent, there are no additional records to fetch.
The final page response includes only a `value` array without a `nextLink`.

### Sample response

```jsonc
{
  "value": [
    { "id": 7, "title": "Rendezvous with Rama" },
    { "id": 8, "title": "The Dispossessed" }
  ]
}
```

> [!NOTE]
> Any schema or ordering change invalidates previously issued tokens. Clients must restart pagination from the first page.

## Relevant configuration

To enable paging in REST, define your entities in `dab-config.json`. Stable ordering columns (typically primary keys) ensure consistent pagination tokens.

```jsonc
{
  "entities": {
    "Book": {
      "source": {
        "object": "dbo.books",
        "type": "table"
      },
      "mappings": {
        "sku_title": "title"
      }
    }
  }
}
```
[!INCLUDE[Sample Configuration](./includes/sample-config.md)]
[!INCLUDE[See Also](./includes/see-also.md)]