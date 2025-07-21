---
title: Using Views in DAB
description: Learn how to expose database views as REST or GraphQL endpoints using Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 07/21/2025
# Customer Intent: As a developer, I want to expose views as endpoints in DAB, so I can query read-only data models easily.
---

# Using views in Data API builder

Views are supported as alternatives to tables in DAB. A view can be exposed through REST or GraphQL endpoints with minimal configuration.

## Configuration

To expose a view:

* Set `source.type` to `"view"`
* Set `source.object` to the fully qualified view name
* Define `key-fields` to identify a row uniquely
* Grant permission using the `"read"` action (and optionally `"create"`, `"update"`, `"delete"` if the view is updatable)

### CLI example

```sh
dab add BookDetail \
  --source dbo.vw_books_details \
  --source.type "view" \
  --source.key-fields "id" \
  --permissions "anonymous:read"
```

### Configuration example

```json
"BookDetail": {
  "source": {
    "type": "view",
    "object": "dbo.vw_books_details",
    "key-fields": [ "id" ]
  },
  "permissions": [
    {
      "role": "anonymous",
      "actions": [ "read" ]
    }
  ]
}
```

## REST support

* Supports all REST verbs: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`
* Default behavior is identical to table-backed entities
* Operations succeed only if the view is updatable and appropriate permissions are set

### Example request

```http
GET /api/BookDetail/42
```

Returns the row from `vw_books_details` with `id = 42`.

## GraphQL support

* View appears as a GraphQL type
* Queries are always supported
* Mutations are supported only if the view is updatable
* Follows standard DAB GraphQL schema structure

## Permissions

* Use the `read` action for readonly views
* Use `create`, `update`, and `delete` only if the view is updatable

## Limitations

* `key-fields` are required
* Views do not support relationships
* Pagination, filtering, and sorting are supported if the view behaves like a table

## Related content

* [Using stored procedures](stored-procedures.md)
* [Configuration reference](../../configuration/index.md)
* [Install the CLI](../../how-to/install-cli.md)
