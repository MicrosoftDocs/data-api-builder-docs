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

# Pagination with `after` in GraphQL

Pagination narrows large datasets to smaller, manageable pages. In GraphQL, Data API builder (DAB) uses the `after` argument for **keyset pagination**, which provides stable and efficient traversal through ordered results.

Each cursor encodes the position of the last record in the previous page, allowing the next query to continue from that point. Unlike offset pagination, keyset pagination avoids gaps or duplicates when data changes between requests.

> [!Note]
> The `after` argument carries an opaque token that marks where the previous page ended. Treat tokens as immutable. Never attempt to construct or edit them.

### Quick glance

| Concept       | Description                                                   |
| ------------- | ------------------------------------------------------------- |
| `after`       | The opaque continuation token returned from the prior request |
| `first`       | The maximum number of records to fetch per page               |
| `hasNextPage` | Indicates whether more data exists                            |
| `endCursor`   | The token to include in the next `after` request              |

### How pagination works

1. The client requests a page using `first` to set page size.
2. DAB returns a list of items and a `pageInfo` object containing `hasNextPage` and `endCursor`.
3. The client passes that `endCursor` into the next query’s `after` argument.
4. The process repeats until `hasNextPage` is false.

### `after`

Specifies the continuation token for the next page. The value is a base64-encoded string that represents the last record of the previous result set.

In this example we are getting the next three products after the last page’s cursor.

```graphql
query {
  products(first: 3, after: "eyJpZCI6MywidHMiOjE3MDA4MDg1NTU1fQ==") {
    items { id name }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

#### Resulting SQL from the above example

```sql
SELECT TOP (3) id, name
FROM Products
WHERE (id > 3)
ORDER BY id ASC;
```

### `first`

Defines how many records to return per request. Used with `after`, it determines a precise window over the ordered dataset.

In this example we are getting the first three products.

```graphql
query {
  products(first: 3) {
    items { id name }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

#### Resulting SQL from the above example

```sql
SELECT TOP (3) id, name
FROM Products
ORDER BY id ASC;
```

### How cursors are formed

Internally, DAB encodes the last record of each page as a cursor:

1. DAB collects pagination columns from the current order (including direction).
2. It includes any remaining primary key columns as tie-breakers.
3. Each field is serialized into JSON and base64-encoded.

Decoded example:

```json
[
  { "EntityName": "Product", "FieldName": "createdOn", "FieldValue": "2024-11-05T12:34:56Z", "Direction": 0 },
  { "EntityName": "Product", "FieldName": "id", "FieldValue": 42, "Direction": 0 }
]
```

> [!Note]
> Any schema or ordering change invalidates prior cursors. Clients must start a new pagination cycle.

### End of data

When `hasNextPage` is false, there are no more records to fetch. The `endCursor` may be null on the final page.