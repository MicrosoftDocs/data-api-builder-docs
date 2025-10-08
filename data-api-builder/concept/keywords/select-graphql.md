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

# Field selection (Projection) in GraphQL

In GraphQL, the fields you request define exactly what Data API builder (DAB) returns—no more, no less. DAB compiles these selections into parameterized SQL, including only the exposed columns and any foreign key fields required for relationships. Projection is governed by the entity configuration in `dab-config.json`.

> GraphQL has no wildcard like `SELECT *`. Clients must specify each field explicitly.

## Basic selection

Querying a few mapped fields.

#### GraphQL query

```graphql
query {
  books {
    items {
      id
      title
      price
    }
  }
}
```

#### Conceptual SQL

```sql
SELECT
  id,
  sku_title AS title,
  sku_price AS price
FROM dbo.books;
```

#### Sample response

```json
{
  "data": {
    "books": {
      "items": [
        {
          "id": 1,
          "title": "Dune",
          "price": 20
        },
        {
          "id": 2,
          "title": "Foundation",
          "price": 18
        }
      ]
    }
  }
}
```

## Field aliases

Aliases rename fields in the response, not the database.

#### GraphQL query

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

#### Conceptual SQL

```sql
SELECT
  sku_title AS title,
  sku_price AS price
FROM dbo.books;
```

#### Sample response

```json
{
  "data": {
    "books": {
      "items": [
        {
          "bookTitle": "Dune",
          "cost": 20
        },
        {
          "bookTitle": "Foundation",
          "cost": 18
        }
      ]
    }
  }
}
```

## Nested selection

Relationships defined in the configuration allow nested queries.

#### GraphQL query

```graphql
query {
  books {
    items {
      id
      title
      category {
        id
        name
      }
    }
  }
}
```

#### Conceptual SQL

```sql
SELECT
  b.id,
  b.sku_title AS title,
  c.id AS category_id,
  c.name AS category_name
FROM dbo.books AS b
JOIN dbo.categories AS c
  ON b.category_id = c.id;
```

#### Sample response

```json
{
  "data": {
    "books": {
      "items": [
        {
          "id": 1,
          "title": "Dune",
          "category": {
            "id": 10,
            "name": "Sci-Fi"
          }
        },
        {
          "id": 2,
          "title": "Foundation",
          "category": {
            "id": 10,
            "name": "Sci-Fi"
          }
        }
      ]
    }
  }
}
```

## One-to-many selection

You can also traverse the inverse relationship when defined on the other entity.

#### GraphQL query

```graphql
query {
  categories {
    items {
      id
      name
      books {
        items {
          id
          title
        }
      }
    }
  }
}
```

#### Conceptual SQL

```sql
SELECT
  c.id,
  c.name,
  b.id AS book_id,
  b.sku_title AS title
FROM dbo.categories AS c
JOIN dbo.books AS b
  ON c.id = b.category_id;
```

#### Sample response

```json
{
  "data": {
    "categories": {
      "items": [
        {
          "id": 10,
          "name": "Sci-Fi",
          "books": {
            "items": [
              { "id": 1, "title": "Dune" },
              { "id": 2, "title": "Foundation" }
            ]
          }
        }
      ]
    }
  }
}
```

## Pagination with projection

Projection and pagination combine seamlessly.

#### GraphQL query

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

#### Conceptual SQL

```sql
SELECT TOP (3)
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
        { "id": 3, "title": "Hyperion" }
      ],
      "hasNextPage": true,
      "endCursor": "eyJpZCI6M30="
    }
  }
}
```

## Relevant configuration

To control selection, configure `mappings` and `relationships` under `entities`.

```jsonc
{
  "entities": {
    "Book": {
      "source": {
        "object": "dbo.books",
        "type": "table"
      },
      "mappings": {
        "sku_title": "title",
        "sku_price": "price"
      },
      "relationships": {
        "book_category": {
          "cardinality": "one",
          "target.entity": "Category",
          "source.fields": [
            "category_id"
          ],
          "target.fields": [
            "id"
          ]
        }
      }
    },
    "Category": {
      "source": {
        "object": "dbo.categories",
        "type": "table"
      }
    }
  }
}
```
