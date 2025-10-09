---
title: Use $orderby (REST) and orderBy (GraphQL)
description: Learn how to sort data, apply multi-field ordering, and understand how Data API builder enforces stable ordering for pagination and consistency.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/09/2025
# Customer Intent: As a developer, I want to order records predictably and ensure stable pagination.
---

# Ordering results in REST (`$orderby`)

Ordering defines the sequence of returned records and underpins stable pagination. In REST, Data API builder (DAB) uses the `$orderby` query parameter to sort results before applying `$first` or `$after`. If you omit `$orderby`, DAB defaults to sorting by the primary key (ascending).

> [!NOTE]
> For composite primary keys, DAB orders by the database column sequence.

Go to the [GraphQL version of this document](./orderby-graphql.md).

## Overview

| Concept           | Description                                         |
| ----------------- | --------------------------------------------------- |
| Query parameter   | `$orderby`                                          |
| Direction tokens  | `asc`, `desc`                                       |
| Default order     | Primary key ascending                               |
| Multi-field order | Comma-separated field list                          |
| Tie-break         | Remaining primary key fields appended automatically |

## Usage pattern

```
GET /api/{entity}?$orderby=FieldA [asc|desc], FieldB desc
```

#### Example

Order books by year descending, then title ascending.

```http
GET /api/books?$orderby=year desc, title asc&$first=5
```

#### Conceptual SQL

```sql
SELECT TOP (5)
  id,
  sku_title AS title,
  year
FROM dbo.books
ORDER BY year DESC, sku_title ASC, id ASC;
```

#### Sample response

```json
{
  "value": [
    { "id": 7, "title": "Dune Messiah", "year": 1969 },
    { "id": 6, "title": "Dune", "year": 1965 },
    { "id": 3, "title": "Foundation", "year": 1951 },
    { "id": 1, "title": "I, Robot", "year": 1950 },
    { "id": 8, "title": "The Martian Chronicles", "year": 1950 }
  ]
}
```

## Rules

| Rule               | Detail                                           |
| ------------------ | ------------------------------------------------ |
| Delimiter          | Comma + optional whitespace                      |
| Direction keywords | `asc` (default), `desc`                          |
| Case sensitivity   | Field names are case-sensitive                   |
| Unknown field      | Returns `400 Invalid orderby column requested`   |
| Unsupported syntax | Returns `400 OrderBy property is not supported.` |

#### Example errors

Invalid field name:

```
400 Invalid orderby column requested: publishedYear
```

Unsupported token:

```
400 OrderBy property is not supported.
```

## Interaction with `$select`

When you sort by a field not present in `$select`, DAB fetches it internally for ordering or cursor creation but omits it from the final payload.

## Relevant configuration

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

[!INCLUDE[Install CLI](./includes/see-also.md)]