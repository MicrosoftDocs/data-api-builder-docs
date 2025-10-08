---
title: Use $select to shape REST payloads
description: Learn how to use $select to project specific fields in REST queries and how selection works in GraphQL.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/07/2025
# Customer Intent: As a developer, I want to reduce payload size and surface only allowed columns.
---

# Field Selection (Projection) in GraphQL 

In GraphQL, the selection set determines which fields appear in the response—no more, no less. Data API builder (DAB) compiles your GraphQL field selections into parameterized SQL (or provider‐specific queries) that retrieves only the referenced columns plus any required key/foreign key columns for relationship resolution.

> [!NOTE]
> GraphQL has no wildcard equivalent to `SELECT *`. Always request only what you need for performance, network efficiency, and clarity.

## Quick glance

| Concept                  | Description                                                                 |
| ------------------------ | --------------------------------------------------------------------------- |
| Field selection          | Controls which scalar/object fields are returned                            |
| Nested fields            | Parent and related entities resolved with batched queries                   |
| Aliases                  | Rename fields in the GraphQL response (does not expose hidden fields)       |
| Pagination compatibility | Works seamlessly with `first`, `after`, and `orderBy`                       |
| Safety                   | Only fields exposed in the DAB configuration are selectable                 |

## Basic selection

Selecting only `id`, `title`, and `price`:

```graphql
query {
  books {
    items { id title price }
  }
}
```

### Conceptual SQL (may vary by database)

```sql
SELECT id, title, price
FROM Books;
```

### Sample response

```json
{
  "data": {
    "books": {
      "items": [
        { "id": 1, "title": "Dune", "price": 20 },
        { "id": 2, "title": "Foundation", "price": 18 },
        { "id": 3, "title": "Hyperion", "price": 22 }
      ]
    }
  }
}
```

## Aliases

GraphQL aliases change the field name in the response, not the underlying column name.

```graphql
query {
  books {
    items {
      bookTitle: title
      cost: price
    }
  }
}
```

### Conceptual SQL

```sql
SELECT title, price
FROM Books;
```

> The alias mapping (`bookTitle`, `cost`) is handled in the GraphQL layer; the physical SQL may not use `AS`.

### Sample response

```json
{
  "data": {
    "books": {
      "items": [
        { "bookTitle": "Dune", "cost": 20 },
        { "bookTitle": "Foundation", "cost": 18 }
      ]
    }
  }
}
```

## Nested list with sort

Sorting can be applied at any list level independently.

```graphql
query {
  authors {
    items {
      id
      name
      books(orderBy: { year: ASC }) {
        items { title year }
      }
    }
  }
}
```

### Conceptual SQL

```sql
-- Parents
SELECT id, name
FROM Authors;

-- Child list (batched by author IDs)
SELECT author_id, title, year
FROM Books
WHERE author_id IN (@a1, @a2, @a3)
ORDER BY year ASC;
```

### Sample response

```json
{
  "data": {
    "authors": {
      "items": [
        {
          "id": 11,
          "name": "Frank Herbert",
          "books": {
            "items": [
              { "title": "Dune", "year": 1965 },
              { "title": "Dune Messiah", "year": 1969 }
            ]
          }
        },
        {
          "id": 12,
          "name": "Isaac Asimov",
          "books": {
            "items": [
              { "title": "Foundation", "year": 1951 },
              { "title": "Foundation and Empire", "year": 1952 }
            ]
          }
        }
      ]
    }
  }
}
```

## Projection with pagination

Projection behaves the same with pagination arguments. The pagination metadata fields `hasNextPage` and `endCursor` appear directly alongside `items`—there is no `pageInfo` wrapper object.

```graphql
query {
  books(first: 5) {
    items { id title }
    hasNextPage
    endCursor
  }
}
```

### Conceptual SQL (SQL Server variant)

```sql
SELECT TOP (5) id, title
FROM Books
ORDER BY id ASC;
```

### Conceptual SQL (PostgreSQL/MySQL variant)

```sql
SELECT id, title
FROM Books
ORDER BY id ASC
LIMIT 5;
```

### Sample response

```json
{
  "data": {
    "books": {
      "items": [
        { "id": 1, "title": "Dune" },
        { "id": 2, "title": "Foundation" },
        { "id": 3, "title": "Hyperion" },
        { "id": 4, "title": "I, Robot" },
        { "id": 5, "title": "Neuromancer" }
      ],
      "hasNextPage": true,
      "endCursor": "eyJpZCI6NX0="
    }
  }
}
```

> [!NOTE]
> This differs from the Relay Cursor Connections Specification, which uses a `pageInfo` object. DAB exposes the pagination token (`endCursor`) and `hasNextPage` directly. A stable ordering (often by primary key) underpins deterministic cursor generation.

## Computed or mapped fields

Computed (or mapped) fields are defined in the DAB configuration and expanded during query compilation. Clients cannot inject arbitrary SQL expressions.

```jsonc
{
  "entities": {
    "Books": {
      "source": { "type": "table", "name": "Books" },
      "mappings": {
        "displayPrice": { "source": "price * 1.08" } // e.g., tax-inclusive
      }
    }
  }
}
```

GraphQL query:

```graphql
query {
  books {
    items { title displayPrice }
  }
}
```

Conceptual SQL (simplified):

```sql
SELECT title, (price * 1.08) AS displayPrice
FROM Books;
```

> [!NOTE]
> Exact computed field configuration syntax may differ—refer to the official DAB configuration reference.