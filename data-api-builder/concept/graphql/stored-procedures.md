---
title: Stored procedures in the GraphQL API
description: Learn how to expose stored procedures as GraphQL operations in Data API builder with the execute prefix.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 03/28/2026
# Customer Intent: As a developer, I want to call stored procedures through GraphQL so I can reuse existing database logic from GraphQL clients.
---

# Stored procedures in the GraphQL API

Stored procedures can be exposed as GraphQL operations in Data API builder (DAB). This approach is useful for scenarios that involve custom logic, filtering, validation, or computed results not handled by simple tables or views.

## Configuration

To expose a stored procedure:

* Set `source.type` to `"stored-procedure"`
* Set `source.object` to the fully qualified procedure name
* Define optional `parameters` with their defaults, if necessary
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

## GraphQL behavior

* Requires `graphql.operation` to be `"query"` or `"mutation"`
* Fields are autoprefixed with `execute`, for example, `executeGetCowrittenBooksByAuthor`
* Parameters are passed as GraphQL arguments

### Example query

```graphql
query {
  executeGetCowrittenBooksByAuthor(author: "asimov") {
    id
    title
  }
}
```

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

[!INCLUDE[Note - SQL MCP Server 2.0 preview](../../mcp/includes/note-sql-mcp-server-2-preview.md)]

## Limitations

* Only the **first result set** is returned
* Pagination, filtering, and ordering aren't supported
* Relationships aren't supported
* Requires metadata from `sys.dm_exec_describe_first_result_set`
* Can't return a single item by key
* No parameter-level authorization

## Related content

* [Stored procedures in the REST API](../rest/stored-procedures.md)
* [Source configuration](../../configuration/entities.md#source-entity-name-entities)
