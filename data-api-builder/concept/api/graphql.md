---
title: How to call GraphQL endpoints
description: Learn how to call and use GraphQL endpoints in Data API builder, including how to query, filter, sort, and page results.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 10/09/2025
# Customer Intent: As a developer, I want to call GraphQL endpoints in Data API builder to query, filter, and modify data safely and efficiently.
---

# How to call GraphQL endpoints

GraphQL endpoints in Data API builder (DAB) let you query and modify data with precision.
Each query declares exactly what fields you need and supports arguments for filtering, ordering, and paging results.

By default, DAB hosts its GraphQL endpoint at:

```
https://{base_url}/graphql
```

Entities exposed through configuration are automatically included in the GraphQL schema.
For example, if you have `books` and `authors` entities, both appear as root fields in the schema.

> [!NOTE]
> Use any modern GraphQL client or IDE (like Apollo, Insomnia, or VS Code GraphQL) to explore the schema and autocomplete fields.

#### Keywords supported in Data API builder

| Concept | GraphQL | Purpose |
|----------|------------------|----------|
| Projection |  [items](../../keywords/select-graphql.md) | Choose which fields to return |
| Filtering | [filter](../../keywords/filter-graphql.md) | Restrict rows by condition |
| Sorting | [orderBy](../../keywords/orderby-graphql.md) | Define the sort order |
| Page size | [first](../../keywords/first-graphql.md) | Limit the items per page |
| Continuation | [after](../../keywords/after-graphql.md) | Continue from the last page |

## Basic structure

Every GraphQL query starts with a root field that represents an entity.

```graphql
{
  books {
    items {
      id
      title
      price
    }
  }
}
```

The result is a JSON object with the same shape as your selection set:

```json
{
  "data": {
    "books": {
      "items": [
        { "id": 1, "title": "Dune", "price": 20 },
        { "id": 2, "title": "Foundation", "price": 18 }
      ]
    }
  }
}
```

> [!NOTE]
> By default, DAB returns up to 100 items per query unless configured otherwise (`runtime.pagination.default-page-size`).

## Query types

Each entity supports two standard root queries:

| Query          | Description                                  |
| -------------- | -------------------------------------------- |
| `entity_by_pk` | Returns one record by its primary key        |
| `entities`     | Returns a list of records that match filters |

Example returning one record:

```graphql
{
  book_by_pk(id: 1010) {
    title
    year
  }
}
```

Example returning many:

```graphql
{
  books {
    items {
      id
      title
    }
  }
}
```

## Filtering results

Use the `filter` argument to restrict which records are returned.

```graphql
{
  books(filter: { title: { contains: "Foundation" } }) {
    items { id title }
  }
}
```

This query returns all books whose title contains “Foundation.”

Filters can combine comparisons with logical operators:

```graphql
{
  authors(filter: {
    or: [
      { first_name: { eq: "Isaac" } }
      { last_name: { eq: "Asimov" } }
    ]
  }) {
    items { first_name last_name }
  }
}
```

See the [filter argument reference](../../keywords/filter-graphql.md) for supported operators like `eq`, `neq`, `lt`, `lte`, and `isNull`.

## Sorting results

The `orderBy` argument defines how records are sorted.

```graphql
{
  books(orderBy: { year: DESC, title: ASC }) {
    items { id title year }
  }
}
```

This returns books ordered by `year` descending, then by `title`.

See the [orderBy argument reference](../../keywords/orderby-graphql.md) for more details.

## Limiting results

The `first` argument limits how many records are returned in a single request.

```graphql
{
  books(first: 5) {
    items { id title }
  }
}
```

This returns the first five books, ordered by primary key by default.
You can also use `first: -1` to request the configured maximum page size.

Learn more in the [first argument reference](../../keywords/first-graphql.md).

## Continuing results

To fetch the next page, use the `after` argument with the cursor from the previous query.

```graphql
{
  books(first: 5, after: "eyJpZCI6NX0=") {
    items { id title }
  }
}
```

The `after` token marks where the prior page ended.
See [after argument reference](../../keywords/after-graphql.md) for more details.

## Field selection (projection)

In GraphQL, you choose exactly which fields appear in the response.
There is no wildcard like `SELECT *`. Request only what you need.

```graphql
{
  books {
    items { id title price }
  }
}
```

You can also use aliases to rename fields in the response:

```graphql
{
  books {
    items {
      bookTitle: title
      cost: price
    }
  }
}
```

See [field projection reference](../../keywords/select-graphql.md) for details.
