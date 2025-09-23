---
title: Using Stored Procedures in DAB
description: Learn how to expose stored procedures as endpoints in Data API builder for both REST and GraphQL.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 07/21/2025
# Customer Intent: Customer Intent: As a developer, I want to expose stored procedures in DAB so I can reuse business logic or parameterized queries as endpoints.
---

# Using stored procedures in Data API builder

Stored procedures can be exposed as REST or GraphQL endpoints in DAB. This is useful for scenarios that involve custom logic, filtering, validation, or computed results not handled by simple tables or views.

## Configuration

To expose a stored procedure:

* Set `source.type` to `"stored-procedure"`
* Set `source.object` to the fully qualified procedure name
* Define optional `parameters` with their defaults, if necessary
* Set `rest.methods` (for example, `"GET"`, `"POST"`) or `rest: false`
* Set `graphql.operation` to `"query"` or `"mutation"`, or omit to default to `"mutation"`
* Grant permission using the `"execute"` action

### CLI example

```sh
dab add GetCowrittenBooksByAuthor \
  --source dbo.stp_get_all_cowritten_books_by_author \
  --source.type "stored-procedure" \
  --source.params "searchType:default-value" \
  --permissions "anonymous:execute" \
  --rest.methods "get" \
  --graphql.operation "query"
```

### Configuration example

```json
"GetCowrittenBooksByAuthor": {
  "source": {
    "type": "stored-procedure",
    "object": "dbo.stp_get_all_cowritten_books_by_author",
    "parameters": {
      "searchType": "default-value"
    }
  },
  "rest": {
    "methods": [ "GET" ]
  },
  "graphql": {
    "operation": "query"
  },
  "permissions": [
    {
      "role": "anonymous",
      "actions": [ "execute" ]
    }
  ]
}
```

## REST support

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

## GraphQL support

* Requires `graphql.operation` to be `"query"` or `"mutation"`
* Fields are autoprefixed with `execute`, for example, `executeGetCowrittenBooksByAuthor`
* Parameters are passed as GraphQL arguments

### Example GraphQL

```graphql
query {
  executeGetCowrittenBooksByAuthor(author: "asimov") {
    id
    title
  }
}
```

## Limitations

* Only the **first result set** is returned
* Pagination, filtering, and ordering aren't supported
* Relationships aren't supported
* Requires metadata from `sys.dm_exec_describe_first_result_set`
* Can't return a single item by key
* No parameter-level authorization

