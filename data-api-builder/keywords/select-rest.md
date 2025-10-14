---
title: Field selection (Projection) in REST
description: Learn how to shape REST responses with $select, how internal columns are handled, and how projection interacts with ordering, pagination, security and configuration in Data API builder.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/08/2025
# Customer Intent: As a developer, I want to request only the fields I need from REST endpoints.
---

# Field selection (Projection) in REST

Projection helps you return only what your client actually needs. Smaller payloads improve performance, reduce network costs, and reduce client-side parsing overhead. Data API builder (DAB) implements projection for REST through the `$select` query parameter.

> [!NOTE]
> REST query parameter names (including `$select`) are case sensitive. Field names are also case sensitive based on what you configured or exposed.

Go to the [GraphQL version of this document](./select-graphql.md).

## Basic selection

#### Pattern

```http
GET /api/{entity}?$select=FieldA,FieldB,FieldC
```

If `$select` is omitted, DAB returns all fields the caller’s role is authorized to read (subject to `include` and `exclude` configuration and field-level permissions). There's no wildcard token like `*`; omitting `$select` is how you request the full allowed shape.

#### Examples

```http
# Return all accessible fields
GET /api/author

# Return only first_name
GET /api/author?$select=first_name

# Return only first_name and last_name
GET /api/author?$select=first_name,last_name
```

## Internal vs response columns

You aren't required to project primary key or ordering fields. If omitted, they don't appear in the JSON response. However, DAB may internally fetch extra columns needed to enforce security policies (row-level filters, field masks) and handle pagination cursors (`$after` / `nextLink`).

> [!NOTE]
> These internally fetched columns are removed before the response unless you explicitly request them.

#### Example

```http
GET /api/book?$select=id,title&$orderby=publisher_id desc&$first=5
```

#### Conceptual SQL

```sql
SELECT TOP (6) -- first (5) + 1 probe row for paging
  [b].[id],
  [b].[sku_title] AS title
FROM dbo.books AS [b]
ORDER BY [b].[publisher_id] DESC, [b].[id] ASC;
```

#### Response

```json
{
  "value": [
    { "id": 101, "title": "Example 1" },
    { "id": 77,  "title": "Example 2" },
    { "id": 42,  "title": "Example 3" },
    { "id": 33,  "title": "Example 4" },
    { "id": 5,   "title": "Example 5" }
  ],
  "nextLink": "..."
}
```

Learn more about [pagination and the after keyword](./after-graphql.md).

> The extra internal columns and the sixth probe row aren't visible in the payload.

## Stored procedures

For stored procedure–backed entities, `$select` isn't interpreted as a projection clause. Instead, query string key/value pairs (except recognized system parameters like `$filter`, `$orderby`, etc.) are treated as stored procedure parameters. `$select` has no effect; the procedure’s result set defines the shape.

[!INCLUDE[Sample Configuration](./includes/sample-config.md)]
[!INCLUDE[See Also](./includes/see-also.md)]
