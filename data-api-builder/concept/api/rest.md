---
title: How to call REST endpoints
description: Learn how to call and use REST endpoints in Data API builder, including how to query, filter, sort, and page results.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 10/09/2025
# Customer Intent: As a developer, I want to call REST endpoints in Data API builder to query, filter, and modify data safely and efficiently.
---

# How to call REST endpoints

Data API builder (DAB) provides a RESTful web API that lets you access tables, views, and stored procedures from a connected database.
Each exposed database object is defined as an *entity* in the runtime configuration.

By default, DAB hosts REST endpoints at:

```
https://{base_url}/api/{entity}
```

> [!NOTE]
> All path components and query parameters are case sensitive.

#### Keywords supported in Data API builder

| Concept      | REST                                       | Purpose                       |
| ------------ | ------------------------------------------ | ----------------------------- |
| Projection   | [$select](../../keywords/select-rest.md)   | Choose which fields to return |
| Filtering    | [$filter](../../keywords/filter-rest.md)   | Restrict rows by condition    |
| Sorting      | [$orderby](../../keywords/orderby-rest.md) | Define the sort order         |
| Page size    | [$first](../../keywords/first-rest.md)     | Limit the items per page      |
| Continuation | [$after](../../keywords/after-rest.md)     | Continue from the last page   |

## Basic structure

To call a REST API, construct a request using this pattern:

```http
{HTTP method} https://{base_url}/{rest-path}/{entity}
```

Example reading all records from the `book` entity:

```http
GET https://localhost:5001/api/book
```

The response is a JSON object:

```json
{
  "value": [
    { "id": 1, "title": "Dune" },
    { "id": 2, "title": "Foundation" }
  ]
}
```

> [!NOTE]
> By default, DAB returns up to 100 items per query unless configured otherwise (`runtime.pagination.default-page-size`).

## Query types

Each REST entity supports both collection and single-record reads.

| Operation                                                    | Description                       |
| ------------------------------------------------------------ | --------------------------------- |
| `GET /api/{entity}`                                          | Returns a list of records         |
| `GET /api/{entity}/{primary-key-column}/{primary-key-value}` | Returns one record by primary key |

Example returning one record:

```http
GET /api/book/id/1010
```

Example returning many:

```http
GET /api/book
```

## Filtering results

Use the `$filter` query parameter to restrict which records are returned.

```http
GET /api/book?$filter=title eq 'Foundation'
```

This query returns all books whose title equals "Foundation."

Filters can include logical operators for more complex queries:

```http
GET /api/book?$filter=year ge 1970 or title eq 'Dune'
```

See the [$filter argument reference](../../keywords/filter-rest.md) for supported operators like `eq`, `ne`, `lt`, `le`, `and`, and `or`.

## Sorting results

The `$orderby` parameter defines how records are sorted.

```http
GET /api/book?$orderby=year desc, title asc
```

This returns books ordered by `year` descending, then by `title`.

See the [$orderby argument reference](../../keywords/orderby-rest.md) for more details.

## Limiting results

The `$first` parameter limits how many records are returned in one request.

```http
GET /api/book?$first=5
```

This returns the first five books, ordered by primary key by default.
You can also use `$first=-1` to request the configured maximum page size.

Learn more in the [$first argument reference](../../keywords/first-rest.md).

## Continuing results

To fetch the next page, use `$after` with the continuation token from the previous response.

```http
GET /api/book?$first=5&$after={continuation-token}
```

The `$after` token identifies where the last query ended.
See [$after argument reference](../../keywords/after-rest.md) for details.

## Field selection (projection)

Use `$select` to control which fields are included in the response.

```http
GET /api/book?$select=id,title,price
```

This returns only the specified columns.
If a field is missing or not accessible, DAB returns `400 Bad Request`.

See [$select argument reference](../../keywords/select-rest.md) for details.

## Modifying data

The REST API also supports create, update, and delete operations depending on entity permissions.

| Method   | Action                                          |
| -------- | ----------------------------------------------- |
| `POST`   | Create a new item                               |
| `PUT`    | Replace an existing item (or create if missing) |
| `PATCH`  | Update an existing item (or create if missing)  |
| `DELETE` | Remove an item by primary key                   |

Example creating a new record:

```http
POST /api/book
Content-type: application/json

{
  "id": 2000,
  "title": "Leviathan Wakes"
}
```

Example updating an existing record:

```http
PATCH /api/book/id/2000
Content-type: application/json

{
  "year": 2011,
  "pages": 577
}
```

Example deleting a record:

```http
DELETE /api/book/id/2000
```

