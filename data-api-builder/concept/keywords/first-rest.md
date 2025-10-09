---
title: Use $first (REST) and first (GraphQL)
description: Learn how to control page size limits, leverage -1 for maximum pages, and understand validation for pagination size in Data API builder.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/07/2025
# Customer Intent: As a developer, I want to page efficiently and respect server limits.
---

# Limiting page size with `$first` in REST

Limiting page size prevents overwhelming clients or servers when querying large datasets. In REST, Data API builder (DAB) uses the `$first` parameter to control how many records are returned in a single response. DAB applies cursor-based pagination internally, but `$first` can be used even when continuation is not required.

> [!NOTE]
> `$first` limits the number of rows returned but does not itself handle continuation. For multiple pages, use `$after`.

Go to the [GraphQL version of this document](./first-graphql.md).

## Overview

| Concept           | Description                                              |
| ----------------- | -------------------------------------------------------- |
| Default page size | `runtime.pagination.default-page-size` (defaults to 100) |
| Max page size     | `runtime.pagination.max-page-size` (defaults to 100000)  |
| Client override   | `$first`                                                 |
| Requesting max    | `$first=-1` requests the configured max page size        |

If `$first` is omitted, the default page size applies automatically.

## Usage pattern

```http
GET /api/{entity}?$first=N
```

#### Example

Limit the results to 5 books.

```http
GET /api/books?$first=5
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
  "value": [
    { "id": 1, "title": "Dune" },
    { "id": 2, "title": "Foundation" },
    { "id": 3, "title": "Hyperion" },
    { "id": 4, "title": "I, Robot" },
    { "id": 5, "title": "The Martian" }
  ]
}
```

## Validation rules

| Input                  | Result                      |
| ---------------------- | --------------------------- |
| Omitted                | Uses `default-page-size`    |
| Positive integer ≤ max | Accepted                    |
| `-1`                   | Expanded to `max-page-size` |
| `0`                    | 400 (invalid)               |
| `< -1`                 | 400                         |
| `> max-page-size`      | 400                         |

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