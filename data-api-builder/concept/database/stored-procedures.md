---
title: Using Stored Procedures in DAB
description: Learn how to expose stored procedures as endpoints in Data API builder for both REST and GraphQL.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 03/24/2026
# Customer Intent: Customer Intent: As a developer, I want to expose stored procedures in DAB so I can reuse business logic or parameterized queries as endpoints.
---

# Using stored procedures in Data API builder

Stored procedures can be exposed as REST or GraphQL endpoints in DAB. This approach is useful for scenarios that involve custom logic, filtering, validation, or computed results not handled by simple tables or views.

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
  --parameters.name "searchType" \
  --parameters.required "false" \
  --parameters.default "default-value" \
  --parameters.description "The type of search to perform" \
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

> [!WARNING]
> The dictionary format for `parameters` (for example, `{ "searchType": "default-value" }`) is deprecated in DAB 2.0. Use the array format shown in the preceding example. The old format is still accepted for backward compatibility.

> [!TIP]
> For more information on the parameters array format, see [source configuration](../../configuration/entities.md#source-entity-name-entities).

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

## Custom MCP tools

Starting in DAB 2.0, stored procedures can be exposed as custom Model Context Protocol (MCP) tools. When you set `"custom-tool": true` on a stored-procedure entity, DAB dynamically registers the procedure as a named tool in the MCP `tools/list` and `tools/call` endpoints. AI agents can discover and invoke the tool directly by name, with parameters matching the procedure signature.

```json
"GetBookById": {
  "source": {
    "type": "stored-procedure",
    "object": "dbo.get_book_by_id"
  },
  "mcp": {
    "custom-tool": true
  },
  "permissions": [
    {
      "role": "anonymous",
      "actions": [ "execute" ]
    }
  ]
}
```

CLI equivalent:

```sh
dab add GetBookById \
  --source dbo.get_book_by_id \
  --source.type "stored-procedure" \
  --permissions "anonymous:execute" \
  --mcp.custom-tool true
```

> [!TIP]
> For more information about MCP custom tools, see [What's new in Data API builder version 2.0](../../whats-new/version-2-0.md#introducing-custom-mcp-tools) and [Data manipulation language (DML) tools](../../mcp/data-manipulation-language-tools.md#custom-tools-for-stored-procedures).

## MCP custom tools

In Data API builder 2.0, stored procedures can be registered as custom MCP tools. When you set `"custom-tool": true` in the entity's `mcp` configuration, DAB registers the stored procedure as a named tool via MCP `tools/list` and `tools/call`. This configuration lets AI agents discover and invoke the procedure directly by name.

### Configuration example

```json
"GetBookById": {
  "source": {
    "type": "stored-procedure",
    "object": "dbo.get_book_by_id"
  },
  "mcp": {
    "custom-tool": true
  },
  "permissions": [
    {
      "role": "anonymous",
      "actions": [ "execute" ]
    }
  ]
}
```

### CLI example

```bash
dab add GetBookById \
  --source dbo.get_book_by_id \
  --source.type stored-procedure \
  --permissions "anonymous:execute" \
  --mcp.custom-tool true
```

> [!TIP]
> For more information about MCP custom tools in DAB 2.0, see [What's new in version 2.0](../../whats-new/version-2-0.md).

