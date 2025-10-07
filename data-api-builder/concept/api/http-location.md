---
title: The Location Response Header in REST Create Operation
description: Learn how Data API builder (DAB) uses the Location header to indicate where newly created resources can be retrieved after POST or PUT inserts.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 09/26/2025
# Customer Intent: As a developer, I want to understand how the Location header works in DAB REST endpoints so I can reliably find the path of newly created resources.
---

# The Location Response Header in REST Create Operation

For REST endpoints, the `Location` response header tells clients where to retrieve a newly created resource. Data API builder (DAB) returns `Location` for `POST` inserts. For `PUT` or `PATCH` upserts that create new rows, the header may be omitted.

## When DAB sets the Location header

| Scenario                                            | Status Code   | Location Header (current behavior)                                                    |
| --------------------------------------------------- | ------------- | ------------------------------------------------------------------------------------- |
| `POST` creates a new row (table)                    | 201 Created   | Present: primary key path segments, for example `id/123` or `categoryid/3/pieceid/1`. |
| `POST` executes stored procedure returning new rows | 201 Created   | Present if PK can be derived; may be empty when it can't.                             |
| `PUT` upsert updates existing row                   | 200 OK        | Not present                                                                           |
| `PUT` upsert inserts new row (no If-Match)          | 201 Created   | May be omitted; don't rely on `Location`                                              |
| `PATCH` upsert updates existing row                 | 200 OK        | Not present                                                                           |
| `PATCH` upsert inserts new row (no If-Match)        | 201 Created   | May be omitted; don't rely on `Location`                                              |
| `PUT`/`PATCH` with `If-Match: *` and row missing    | 404 Not Found | Not present                                                                           |
| Any update (row existed)                            | 200 OK        | Not present                                                                           |

### Behavior

* Composite primary keys appear as ordered segments, for example `book_id/1/id/5001` or `categoryid/3/pieceid/1`.
* Column name mappings (aliases) use the REST-exposed field names in the path.

## Example: POST creating a new item

Request

```http
POST /api/Books
Content-Type: application/json

{
  "title": "New Book",
  "publisher_id": 42
}
```

Response

```http
HTTP/1.1 201 Created
Location: http://localhost:50246/api/Books/id/123
Content-Type: application/json

{
  "id": 123,
  "title": "New Book",
  "publisher_id": 42
}
```

Client can now `GET http://localhost:50246/api/Books/id/123`.

## Example: POST inserting into composite key table

Request

```http
POST /api/Inventory
Content-Type: application/json

{
  "categoryid": 3,
  "pieceid": 1,
  "categoryName": "SciFi"
}
```

Response

```http
HTTP/1.1 201 Created
Location: http://localhost:50246/api/Inventory/categoryid/3/pieceid/1
Content-Type: application/json

{
  "categoryid": 3,
  "pieceid": 1,
  "categoryName": "SciFi"
}
```

## Example: PUT updating existing row (no Location)

Request

```http
PUT http://localhost:50246/api/Books/id/1
Content-Type: application/json

{
  "title": "Updated Title"
}
```

Response

```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 1,
  "title": "Updated Title"
}
```

(No `Location` header.)

## Example: PUT inserting new row

Request

```http
PUT http://localhost:50246/api/Books/id/500
Content-Type: application/json

{
  "title": "Inserted via PUT",
  "publisher_id": 7
}
```

Response

```http
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": 500,
  "title": "Inserted via PUT",
  "publisher_id": 7
}
```

(`Location` header may be omitted here.)

## Example: PUT with If-Match and row missing

Request

```http
PUT http://localhost:50246/api/Books/id/500
If-Match: *
Content-Type: application/json

{
  "title": "Attempted Update"
}
```

Response

```http
HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "error": "No Update could be performed, record not found"
}
```

(No `Location` header.)

## Review

* **POST with creation**: `Location` is present with the primary key path.
* **PUT or PATCH with update**: No `Location`.
* **PUT or PATCH with insert**: Returns `201 Created`; `Location` may be omitted (don't depend on it).
* When you include [`If-Match: *`](./http-if-match.md), DAB only performs an update if the row already exists. If the row is missing, the request fails with `404 Not Found` and no insert is performed, so no `Location` header is returned.
