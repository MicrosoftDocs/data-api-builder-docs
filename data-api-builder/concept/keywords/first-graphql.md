---
title: Use first (GraphQL) and $first (REST)
description: Learn how to control page size limits, leverage -1 for maximum pages, and understand validation for pagination size in Data API builder.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/07/2025
# Customer Intent: As a developer, I want to page efficiently and respect server limits.
---

# Limiting page size with `first` in GraphQL

Limiting page size prevents overwhelming clients or servers when querying large datasets. In GraphQL, Data API builder (DAB) uses the `first` argument to control how many records are returned in a single response. DAB applies cursor-based pagination internally, but `first` can be used independently to simply cap result size.

> [!NOTE]
> `first` limits the number of returned records but does not itself handle continuation. For multiple pages, use `after`.

Go to the [REST version of this document](./first-rest.md).

## Overview

| Concept           | Description                                              |
| ----------------- | -------------------------------------------------------- |
| Default page size | `runtime.pagination.default-page-size` (defaults to 100) |
| Max page size     | `runtime.pagination.max-page-size` (defaults to 100000)  |
| Client override   | `first`                                                  |
| Requesting max    | Pass `-1` to request the configured max page size        |

If `first` is omitted, the default page size applies automatically.

## Usage pattern

```graphql
query {
  books(first: N) {
    items { id title }
  }
}
```

#### Example

Limit the results to 5 books.

```graphql
query {
  books(first: 5) {
    items {
      id
      title
    }
  }
}
```

#### Conceptual SQL

```sql
SELECT TOP (5)
  id,
  sku_title AS title
FROM dbo.books
ORDER BY id ASC;
```

#### Sample response

```json
{
  "data": {
    "books": {
      "items": [
        { "id": 1, "title": "Dune" },
        { "id": 2, "title": "Foundation" },
        { "id": 3, "title": "Hyperion" },
        { "id": 4, "title": "I, Robot" },
        { "id": 5, "title": "The Martian" }
      ]
    }
  }
}
```

## Validation rules

| Input                  | Result                      |
| ---------------------- | --------------------------- |
| Omitted                | Uses `default-page-size`    |
| Positive integer ≤ max | Accepted                    |
| `-1`                   | Expanded to `max-page-size` |
| `0`                    | Error (invalid)             |
| `< -1`                 | Error                       |
| `> max-page-size`      | Error                       |

#### Example error message

```
Invalid number of items requested, first argument must be either -1 or a positive number within the max page size limit of 100000. Actual value: 0
```

## Relevant configuration

```jsonc
{
  "runtime": {
    "pagination": {
      "default-page-size": 100,
      "max-page-size": 100000
    }
  },
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

[!INCLUDE[Install CLI](./includes/see-also.md)]