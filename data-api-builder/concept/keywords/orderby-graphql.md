---
title: Use orderBy (GraphQL) and $orderby (REST)
description: Learn how to sort data, apply multi-field ordering, and understand how Data API builder enforces stable ordering for pagination and consistency.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/09/2025
# Customer Intent: As a developer, I want to order records predictably and ensure stable pagination.
---

# Ordering results in GraphQL (`orderBy`)

Ordering defines the sequence of returned records and underpins stable pagination. In GraphQL, Data API builder (DAB) uses the `orderBy` argument to sort results before applying `first` or `after`. If you omit `orderBy`, DAB defaults to sorting by the primary key (ascending).

> [!NOTE]
> Composite primary keys are ordered by their database column sequence.

Go to the [REST version of this document](./orderby-rest.md).

## Overview

| Concept           | Description                                         |
| ----------------- | --------------------------------------------------- |
| Argument          | `orderBy`                                           |
| Direction values  | `ASC`, `DESC`                                       |
| Default order     | Primary key ascending                               |
| Multi-field order | Ordered by declared object property order           |
| Tie-break         | Remaining primary key fields appended automatically |

## Usage pattern

```graphql
query {
  books(orderBy: { year: DESC, title: ASC }, first: 5) {
    items {
      id
      title
      year
    }
  }
}
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
  "data": {
    "books": {
      "items": [
        { "id": 7, "title": "Dune Messiah", "year": 1969 },
        { "id": 6, "title": "Dune", "year": 1965 },
        { "id": 3, "title": "Foundation", "year": 1951 },
        { "id": 1, "title": "I, Robot", "year": 1950 },
        { "id": 8, "title": "The Martian Chronicles", "year": 1950 }
      ]
    }
  }
}
```

## Field behavior

| Aspect          | Behavior                                            |
| --------------- | --------------------------------------------------- |
| Input type      | Generated `*OrderByInput` enumerating scalar fields |
| Direction enum  | `ASC`, `DESC`                                       |
| Composite order | Precedence follows declaration order                |
| Null direction  | Excludes field from sorting (`title: null`)         |
| Unknown field   | Produces GraphQL validation error                   |

#### Example ignoring a field

```graphql
query {
  books(orderBy: { title: null, id: DESC }) {
    items { id title }
  }
}
```

## Invalid structures

GraphQL forbids logical operators (`and`, `or`) inside `orderBy`. For example, the following produces a validation error:

```graphql
books(orderBy: { or: { id: ASC } })
```

## Example using a variable

```graphql
query ($dir: OrderBy) {
  books(orderBy: { id: $dir }, first: 4) {
    items { id title }
  }
}
```

#### Variables

```json
{ "dir": "DESC" }
```

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

[!INCLUDE[Sample Configuration](./includes/sample-config.md)]
[!INCLUDE[See Also](./includes/see-also.md)]