---
title: Use the If-Match HTTP Header in PUT and PATCH Operations
description: Use http headers to control upsert operations
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 09/26/2025
# Customer Intent: As a developer, I want to add use http headers to control PUT and PATCH operations.
---

# Use the If-Match HTTP Header in PUT and PATCH Operations

For REST endpoints, developers often want control over whether updates create new records or only modify existing ones. The `If-Match` HTTP header provides that control in Data API builder (DAB).

By default, DAB treats `PUT` and `PATCH` as *upsert* operations:

* If the resource exists: it's updated.
* If it doesn't exist: it's inserted.

  * `PUT` → full upsert (replaces resource).
  * `PATCH` → incremental upsert (applies partial update).

Adding `If-Match: *` changes this behavior to update-only semantics.

## What If-Match does in DAB

`If-Match` is supported only with the wildcard value `*`.

| Header Value            | Behavior                                                                |
| ----------------------- | ----------------------------------------------------------------------- |
| `If-Match: *`           | Perform update only if the resource exists; if missing → 404 Not Found. |
| `If-Match: <any other>` | Rejected; 400 Bad Request (`Etags not supported, use '*'`).             |
| (absent)                | Upsert behavior (insert if not found, otherwise update).                |

### Behavior overview

* DAB doesn't implement per-record ETag or version matching.
* No concurrency token is evaluated. `*` only asserts "must exist."
* Applies only to REST, not GraphQL.
* Not currently meaningful for DELETE operations.

## Using If-Match with PUT

Without `If-Match`, PUT inserts when the resource doesn't exist (returns `201 Created`).

### Update-only example

Request

```sh
PUT /api/Books/id/1
If-Match: *
Content-Type: application/json

{
  "title": "The Return of the King"
}
```

Success (record existed)

```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 1,
  "title": "The Return of the King"
}
```

Failure (record missing)

```
HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "error": "No Update could be performed, record not found"
}
```

### Upsert insert example (no If-Match and record didn't exist)

Request 

```
PUT /api/Books/id/500
Content-Type: application/json

{
  "title": "Inserted via PUT",
  "publisher_id": 7
}
```

Response

```
HTTP/1.1 201 Created
Location: id/500
Content-Type: application/json

{
  "id": 500,
  "title": "Inserted via PUT",
  "publisher_id": 7
}
```

## Using If-Match with PATCH

`PATCH` behaves similarly. Without `If-Match`, it performs an incremental upsert. With `If-Match: *`, it only updates existing rows.

Request

```
PATCH /api/Books/id/1
If-Match: *
Content-Type: application/json

{
  "title": "The Two Towers"
}
```

Response when Success

```
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 1,
  "title": "The Two Towers"
}
```

Response when Not found

```
HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "error": "No Update could be performed, record not found"
}
```

## Invalid If-Match Usage

Any value other than `*` (including quoted strings) is rejected.

Request

```
PUT /api/Books/id/1
If-Match: "abc123"
Content-Type: application/json

{
  "title": "To Kill a Mockingbird"
}
```

Response

```
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "Etags not supported, use '*'"
}
```

## Review

* Omit `If-Match` for upsert (insert-or-update) semantics.
* Use `If-Match: *` for strict update-only semantics (404 if the item is missing).
* Don't use any other value. Real ETag matching isn't implemented.
