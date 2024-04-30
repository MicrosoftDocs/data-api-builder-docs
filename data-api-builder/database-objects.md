---
title: Expanded database objects
description: Map Data API builder endpoints to data other than traditional database tables by using database objects in the configuration.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 04/01/2024
# Customer Intent: As a developer, I want to configure database objects, so that I can map my endpoints to objects other than tables.
---

# Expanded database objects in Data API builder

Data API builder includes support for views and stored procedures as alternatives to mapping to database tables or containers. These distinct database objects require custom configuration to map seamlessly to REST or GraphQL endpoints. Some custom configuration is required to use Data API builder with views and stored procedures.

This article includes a breakdown of how to use both views and stored procedures with Data API builder.

## Views

Views can be used similar to how a table can be used in Data API builder. View usage must be defined by specifying the source type for the entity as `view`. Along with that the `key-fields` property must be provided, so that Data API builder knows how it can identify and return a single item, if needed.

If you have a view, for example [`dbo.vw_books_details`](https://github.com/Azure/data-api-builder/blob/main/samples/getting-started/azure-sql-db/library.azure-sql.sql#L112) it can be exposed using the following `dab` command:

```bash
dab add BookDetail --source dbo.vw_books_details --source.type View --source.key-fields "id" --permissions "anonymous:read"
```

> [!NOTE]
> `--source.key-fields` is mandatory for views when generating config through the CLI.

The `dab-config.json` file would be like the following example:

```json
"BookDetail": {
  "source": {
    "type": "view",
    "object": "dbo.vw_books_details",
    "key-fields": [ "id" ]
  },
  "permissions": [{
    "role": "anonymous",
    "actions": [ "read" ]
  }]
}
```

> [!NOTE]
> Note that **you should configure the permission accordingly with the ability of the view to be updatable or not**. If a view isn't updatable, you should only allow a read access to the entity based on that view.

### REST support for views

A view, from a REST perspective, behaves like a table. All REST operations are supported.

### GraphQL support for views

A view, from a GraphQL perspective, behaves like a table. All GraphQL operations are supported.

## Stored procedures

Stored procedures can be used as objects related to entities exposed by Data API builder. Stored Procedure usage must be defined specifying that the source type for the entity is `stored-procedure`.

If you have a stored procedure, for example [`dbo.stp_get_all_cowritten_books_by_author`](https://github.com/Azure/data-api-builder/blob/main/samples/getting-started/azure-sql-db/library.azure-sql.sql#L138) it can be exposed using the following `dab` command:

```bash
dab add GetCowrittenBooksByAuthor --source dbo.stp_get_all_cowritten_books_by_author --source.type "stored-procedure" source.params "searchType:s" --permissions "anonymous:execute" --rest.methods "get" --graphql.operation "query"
```

The `dab-config.json` file would be like the following example:

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
  "permissions": [{
   "role": "anonymous",
    "actions": [ "execute" ]
  }]
}
```

The `parameters` defines which parameters should be exposed and also provides default values to be passed to the stored procedure parameters, if those parameters aren't provided in the HTTP request.

### Limitations

- Only the first result set returned by the stored procedure is used by Data API builder.
- Only those stored procedures whose metadata for the first result set described by [`sys.dm_exec_describe_first_result_set`](/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-describe-first-result-set-transact-sql) are supported.
- For both REST and GraphQL endpoints: when a stored procedure parameter is specified both in the configuration file and in the URL query string, the parameter in the URL query string takes precedence.
- Entities backed by a stored procedure don't have all the capabilities automatically provided for entities backed by tables, collections, or views.
  - Stored procedure backed entities don't support pagination, ordering, or filtering. Nor do such entities support returning items specified by primary key values.
  - Field/parameter level authorization rules aren't supported.

### REST support for stored procedures

The REST endpoint behavior, for stored procedure backed entity, can be configured to support one or multiple HTTP verbs (GET, POST, PUT, PATCH, DELETE). The REST section of the entity would be like the following example:

```json
"rest": {
  "methods": [ "GET", "POST" ]
}
```

Any REST requests for the entity fail with **HTTP 405 Method Not Allowed** when an HTTP method not listed in the configuration is used. For example, executing a PUT request fails with error code 405.
If the `methods` section is excluded from the entity's REST configuration, the default method **POST** is inferred. To disable the REST endpoint for this entity, configure `"rest": false` and any REST requests on the stored procedure entity fails with **HTTP 404 Not Found**.

If the stored procedure accepts parameters, the parameters can be passed in the URL query string when calling the REST endpoint with the `GET` HTTP verb. For example:

```http
GET http://<dab-server>/api/GetCowrittenBooksByAuthor?author=isaac%20asimov
```

Stored procedures that are executed using other HTTP verbs such as POST, PUT, PATCH, DELETE require parameters to be passed as JSON in the request body. For example:

```http
POST http://<dab-server>/api/GetCowrittenBooksByAuthor
```

```json
{
  "author": "isaac asimov"
}
```

### GraphQL support for stored procedures

Stored procedure execution in GraphQL can be configured using the `graphql` option of a stored procedure backed entity. Explicitly setting the operation of the entity allows you to represent a stored procedure in the GraphQL schema in a way that aligns with the behavior of the stored procedure.

> [!NOTE]
> GraphQL *requires* a Query element to be present in the schema. If you are exposing only stored procedures, make sure to have at least one of them supporting the `query` operation, otherwise you'll get a GraphQL error like ```The object type Query has to at least define one field in order to be valid.```

Not setting any value for the operation results in the creation of a `mutation` operation.

For example, using the value `query` for the `operation` option results in the stored procedure resolving as a query field in the GraphQL schema.

CLI Usage:

```sh
dab add GetCowrittenBooksByAuthor --source dbo.stp_get_all_cowritten_books_by_author --source.type "stored-procedure" --source.params "searchType:s" --permissions "anonymous:execute" --rest.methods "GET" --graphql.operation "query"
```

Runtime Configuration:

```json
"graphql": {
  "operation": "query"
}
```

GraphQL Schema Components: type and query field:

```graphql
type GetCowrittenBooksByAuthor {
  id: Int!
  title: String
}
```

In the schema, both query and mutation operations for stored procedures have `execute` as a prefix. For the previous stored procedure, the exact query name field generated would be `executeGetCowrittenBooksByAuthor`. The GraphQL type that is generated is:

```graphql
type Query {
  executeGetCowrittenBooksByAuthor(
    searchType: String = "S"
  ): [GetCowrittenBooksByAuthor!]!
}
```

Alternatively, `operation` can be set to `mutation` so that a mutation field represents the stored procedure in the GraphQL schema. The `dab update` command can be used to change the `operation`:

```sh
dab update GetCowrittenBooksByAuthor --graphql.operation "mutation"
```

Runtime configuration:

```json
"graphql": {
  "operation": "mutation"
}
```

The GraphQL schema that is generated is:

```graphql
type Mutation {
  executeGetCowrittenBooksByAuthor(
    searchType: String = "S"
  ): [GetCowrittenBooksByAuthor!]!
}
```

If the stored procedure accepts parameters, those parameters can be passed as parameter of the query or mutation. For example:

```graphql
query {
  executeGetCowrittenBooksByAuthor(author:"asimov")
   {
    id
    title
    pages
    year
  }
}
```

## Related content

- [Configuration reference](reference-configuration.md)
- [Install the CLI](how-to-install-cli.md)
