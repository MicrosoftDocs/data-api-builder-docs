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

# Pagination with `after` in GraphQL

Pagination narrows large datasets to smaller, manageable pages. In GraphQL, Data API builder (DAB) uses the `after` argument for **keyset pagination**, providing stable and efficient traversal through ordered results. Each cursor encodes the position of the last record in the previous page, allowing the next query to continue from that point. Unlike offset pagination, keyset pagination avoids gaps or duplicates when data changes between requests.

Go to the [REST version of this document](./after-rest.md).

## Quick glance

| Concept       | Description                                      |
| ------------- | ------------------------------------------------ |
| `after`       | The continuation token from the prior request    |
| `first`       | The maximum number of records to fetch per page  |
| `hasNextPage` | Indicates whether more data exists               |
| `endCursor`   | The token to include in the next `after` request |

## Basic pagination

### GraphQL query

In this example we are getting the first three books.

```graphql
query {
  books(first: 3) {
    items {
      id
      title
    }
    hasNextPage
    endCursor
  }
}
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
  "data": {
    "books": {
      "items": [
        { "id": 1, "title": "Dune" },
        { "id": 2, "title": "Foundation" },
        { "id": 3, "title": "Hyperion" }
      ],
      "hasNextPage": true,
      "endCursor": "eyJpZCI6M30="
    }
  }
}
```

## Continuation with `after`

The `after` argument specifies the continuation token for the next page. The value is a base64-encoded cursor representing the last record from the previous page.

> [!WARNING]
> The `after` argument carries an opaque token that marks where the previous page ended. Treat tokens as immutable and never attempt to construct or edit them.

In this example we are getting the next three books after the last page’s cursor.

### GraphQL query

```graphql
query {
  books(first: 3, after: "eyJpZCI6M30=") {
    items {
      id
      title
    }
    hasNextPage
    endCursor
  }
}
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
  "data": {
    "books": {
      "items": [
        { "id": 4, "title": "I, Robot" },
        { "id": 5, "title": "The Left Hand of Darkness" },
        { "id": 6, "title": "The Martian" }
      ],
      "hasNextPage": true,
      "endCursor": "eyJpZCI6Nn0="
    }
  }
}
```

## Nested pagination

Pagination can be applied to related collections, such as retrieving authors with a paged list of books.

### GraphQL query

```graphql
query {
  authors {
    items {
      id
      name
      books(first: 2) {
        items {
          id
          title
        }
        hasNextPage
        endCursor
      }
    }
  }
}
```

### Conceptual SQL

```sql
-- parent
SELECT
  id,
  name
FROM dbo.authors;

-- child
SELECT TOP (2)
  author_id,
  id,
  sku_title AS title
FROM dbo.books
WHERE author_id IN (@a1, @a2)
ORDER BY id ASC;
```

> [!NOTE]
> Any schema or ordering change invalidates previously issued tokens. Clients must restart pagination from the first page.

[!INCLUDE[Sample Configuration](./includes/sample-config.md)]
[!INCLUDE[See Also](./includes/see-also.md)]