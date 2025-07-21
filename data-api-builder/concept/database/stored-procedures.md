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

Stored procedures can be exposed as REST or GraphQL endpoints in DAB. This is useful for scenarios involving custom logic, filtering, validation, or computed results not handled by simple tables or views.

## Configuration

To expose a stored procedure:

* Set `source.type` to `"stored-procedure"`
* Set `source.object` to the fully qualified procedure name
* Define the `parameters` (with types) if required
* Set `rest.methods` (e.g., `"GET"`, `"POST"`) or `rest: false`
* Set `graphql.operation` to `"query"` or `"mutation"`, or omit to default to `"mutation"`
* Grant permission using the `"execute"` action

### CLI example

```sh
dab add GetCowrittenBooksByAuthor \
  --source dbo.stp_get_all_cowritten_books_by_author \
  --source.type "stored-procedure" \
  --source.params "searchType:s" \
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
      "searchType": "s"
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

### Parameter types (used in CLI and config)

| Code | Type              |
| ---- | ----------------- |
| s    | string            |
| i    | integer           |
| n    | numeric (decimal) |
| b    | boolean           |
| d    | datetime          |

These codes define the type only, not default values.

## REST support

* Supports only `GET` and `POST`
* If `methods` is omitted, defaults to `POST`
* `GET` sends parameters via query string
* `POST` sends parameters via JSON body
* To disable REST for a stored procedure, use `"rest": false`

### Example requests

`GET /api/GetCowrittenBooksByAuthor?author=asimov`

`POST /api/GetCowrittenBooksByAuthor`

```json
{
  "author": "asimov"
}
```

## GraphQL support

* `graphql.operation` must be `"query"` or `"mutation"`
* Field is auto-prefixed with `execute`, e.g., `executeGetCowrittenBooksByAuthor`
* Parameters are GraphQL arguments

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
* **Pagination**, **filtering**, and **ordering** are not supported
* **Relationships** are not supported
* Requires metadata from [`sys.dm_exec_describe_first_result_set`](https://learn.microsoft.com/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-describe-first-result-set-transact-sql)
* Cannot return a single item by key
* No parameter-level authorization

## Related content

* [Using views](views.md)
* [Configuration reference](../../configuration/index.md)
* [Install the CLI](../../how-to/install-cli.md)
