---
title: Database views in the GraphQL API
description: Learn how to expose database views as GraphQL types in Data API builder for queries and mutations.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 03/28/2026
# Customer Intent: As a developer, I want to expose views as GraphQL types so I can query read-only or updatable data models through GraphQL.
---

# Database views in the GraphQL API

Views are supported as alternatives to tables in Data API builder (DAB). A view can be exposed through GraphQL endpoints with minimal configuration.

## Configuration

To expose a view:

* Set `source.type` to `"view"`
* Set `source.object` to the fully qualified view name
* To identify a row uniquely, define `key-fields`
* Grant permission using the `"read"` action (and optionally `"create"`, `"update"`, `"delete"` if the view is updatable)

### CLI example

```sh
dab add BookDetail \
  --source dbo.vw_books_details \
  --source.type "view" \
  --fields.name "id" \
  --fields.primary-key "true" \
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

## GraphQL behavior

* View appears as a GraphQL type
* Queries are always supported
* Mutations are supported only if the view is updatable
* Follows standard DAB GraphQL schema structure

### Example query

```graphql
{
  bookDetails {
    items {
      id
      title
      authorName
    }
  }
}
```

## Permissions

* Use the `read` action for readonly views
* Use `create`, `update`, and `delete` only if the view is updatable

## Limitations

* `key-fields` are required
* Views don't support relationships
* Pagination, filtering, and sorting are supported if the view behaves like a table

## Related content

* [Database views in the REST API](../rest/views.md)
* [Source configuration](../../configuration/entities.md#source-entity-name-entities)
