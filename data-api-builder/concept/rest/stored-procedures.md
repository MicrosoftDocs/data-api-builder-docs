---
title: Stored procedures in the REST API
description: Learn how to expose stored procedures as REST endpoints in Data API builder using GET and POST methods.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 03/28/2026
# Customer Intent: As a developer, I want to call stored procedures through REST endpoints so I can reuse existing database logic from HTTP clients.
---

# Stored procedures in the REST API

Stored procedures can be exposed as REST endpoints in Data API builder (DAB). This approach is useful for scenarios that involve custom logic, filtering, validation, or computed results not handled by simple tables or views.

## Configuration

To expose a stored procedure:

* Set `source.type` to `"stored-procedure"`
* Set `source.object` to the fully qualified procedure name
* Define optional `parameters` with their defaults, if necessary
* Set `rest.methods` (for example, `"GET"`, `"POST"`) or `rest: false`
* Grant permission using the `"execute"` action

### CLI example

```sh
dab add GetCowrittenBooksByAuthor \
  --source dbo.stp_get_all_cowritten_books_by_author \
  --source.type "stored-procedure" \
  --parameters.name "searchType" \
  --parameters.required "false" \
  --parameters.default "default-value" \
  --parameters.description "The type of search to perform" \
  --permissions "anonymous:execute" \
  --rest.methods "get"
```

### Configuration example

```json
"GetCowrittenBooksByAuthor": {
  "source": {
    "type": "stored-procedure",
    "object": "dbo.stp_get_all_cowritten_books_by_author",
    "parameters": [
      {
        "name": "searchType",
        "required": false,
        "default": "default-value",
        "description": "The type of search to perform"
      }
    ]
  },
  "rest": {
    "methods": [ "GET" ]
  },
  "permissions": [
    {
      "role": "anonymous",
      "actions": [ "execute" ]
    }
  ]
}
```

> [!WARNING]
> The dictionary format for `parameters` (for example, `{ "searchType": "default-value" }`) is deprecated in DAB 2.0. Use the array format shown in the preceding example. The old format is still accepted for backward compatibility.

> [!TIP]
> For more information on the parameters array format, see [source configuration](../../configuration/entities.md#source-entity-name-entities).

## REST behavior

* Supports only `GET` and `POST`
* Defaults to `POST` if `methods` is omitted
* Sends parameters via query string with `GET`
* Sends parameters via JSON body with `POST`
* Disables REST for a stored procedure if `"rest": false` is set

### Example requests

`GET /api/GetCowrittenBooksByAuthor?author=asimov`

`POST /api/GetCowrittenBooksByAuthor`

```json
{
  "author": "asimov"
}
```

## Limitations

* Only the **first result set** is returned
* Pagination, filtering, and ordering aren't supported
* Relationships aren't supported
* Requires metadata from `sys.dm_exec_describe_first_result_set`
* Can't return a single item by key
* No parameter-level authorization

## Related content

* [Stored procedures in the GraphQL API](../graphql/stored-procedures.md)
* [Source configuration](../../configuration/entities.md#source-entity-name-entities)
