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

In GraphQL, the fields you request define exactly what Data API builder (DAB) returns, no more, no less. DAB compiles these selections into parameterized SQL, including only the mapped (exposed) columns you asked for plus any columns it must internally fetch to satisfy relationship joins (foreign key columns) and primary key / ordering columns needed for stable pagination and cursor construction.

> [!NOTE]
> GraphQL has no wildcard like `SELECT *`. Clients must specify each field explicitly.

Go to the [REST version of this document](./select-rest.md).

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

```jsonc
{
  "data": {
    "books": {
      "items": [
        {                 
          "id": 1,
          "title": "Dune",
          "price": 20
        }
      ]
    }    
  }
}
```

## Field aliases
Aliases rename fields in the response, not the database. The SQL layer does not need to alias to the GraphQL alias names; aliasing is applied after data retrieval.

```graphql
query {
  books {
    items {
      id
      bookTitle: title
      cost: price
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

With aliases
```jsonc
{
  "data": {
    "books": {
      "items": [
        {                 
          "id": 2,
          "bookTitle": "Foundation",
          "cost": 18
        }
      ]
    }
  }
}
```

## Nested selection

Relationships defined in the configuration allow nested queries. The conceptual SQL below shows a single JOIN; in practice DAB may execute one or more parameterized queries (e.g., a parent query plus a batched child fetch) rather than a single flattened join.

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

You can also traverse the inverse relationship. Again, SQL is conceptual; actual execution may de-duplicate parent rows and materialize child collections separately.

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

## Relevant configuration

To control selection, configure `mappings` and `relationships` under `entities`. Mapping keys are source columns; values are exposed GraphQL field names (so `sku_title` → `title`). Relationship syntax shown with dotted properties (illustrative—verify against your DAB version’s schema; some versions may nest these fields).

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
          "source.fields": [ "category_id" ],
          "target.fields": [ "id" ]
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

[!INCLUDE[Sample Configuration](./includes/sample-config.md)]
[!INCLUDE[See Also](./includes/see-also.md)]