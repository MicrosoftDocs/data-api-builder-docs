---
title: Host REST endpoints
description: Review REST endpoint hosting for Data API builder including, how to expose endpoints, endpoint configuration, and invocation.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 04/01/2024
# Customer Intent: As a developer, I want to use the Data API Builder, so that I can host REST endpoints.
---

# Host REST endpoints in Data API builder

Data API builder provides a RESTful web API that enables you to access tables, views, and stored procedures from a connected database. Entities represent a database object in Data API builder's runtime configuration. An entity must be set in the runtime configuration in order for it to be available on the REST API endpoint.

## Call a REST API method

To read from or write to a resource (or entity), you construct a request using the following pattern:

```http
{HTTP method} https://{base_url}/{rest-path}/{entity}
```

> [!NOTE]
> All components of the URL path, including entities and query parameters, are case sensitive.

The components of a request include:

| | Description |
| --- | --- |
| **[`{HTTP method}`](#http-methods)** | The HTTP method used on the request to Data API builder |
| **`{base_url}`** | The domain (or localhost server and port) which hosts an instance of Data API builder |
| **[`{rest-path}`](#rest-path)** | The base path of the REST API endpoint set in the runtime configuration |
| **[`{entity}`](#entity)** | The name of the database object as defined in the runtime configuration |

Here's an example GET request on the `book` entity residing under the REST endpoint base `/api` in a local development environment `localhost`:

```http
GET https:/localhost:5001/api/Book
```

### HTTP methods

Data API builder uses the HTTP method on your request to determine what action to take on the request designated entity. The following HTTP verbs are available, dependent upon the permissions set for a particular entity.

| Method | Description |
| --- | --- |
| [`GET`](#get) | Get zero, one or more items |
| [`POST`](#post) | Create a new item |
| [`PATCH`](#patch) | Update an item with new values if one exists. Otherwise, create a new item |
| [`PUT`](#put) | Replace an item with a new one if one exists. Otherwise, create a new item |
| [`DELETE`](#delete) | Delete an item |

### Rest path

The rest path designates the location of Data API builder's REST API. The path is configurable in the runtime configuration and defaults to */api*. For more information, see [REST path configuration](reference-configuration.md#path-rest-entity).

### Entity

*Entity* is the terminology used to reference a REST API resource in  Data API builder. By default, the URL route value for an entity is the entity name defined in the runtime configuration. An entity's REST URL path value is configurable within the entity's REST settings. For more information, see [entity configuration](reference-configuration.md#rest-entities).

### Result set format

The returned result is a JSON object with this format:

```json
{
    "value": []    
}
```

The items related to the requested entity are available in the `value` array. For example:

```json
{
  "value": [
    {
      "id": 1000,
      "title": "Foundation"
    },
    {
      "id": 1001,
      "title": "Foundation and Empire"
    }
  ]
}
```

> [!NOTE]
> Only the first 100 items are returned by default.

## GET

Using the GET method you can retrieve one or more items of the desired entity.

### URL parameters

REST endpoints support the ability to return an item via its primary key, using the URL parameter:

```http
GET /api/{entity}/{primary-key-column}/{primary-key-value}
```

For example:

```http
GET /api/book/id/1001
```

### Query parameters

REST endpoints support the following query parameters (case sensitive) to control the returned items:

- [`$select`](#select): returns only the selected columns
- [`$filter`](#filter): filters the returned items
- [`$orderby`](#orderby): defines how the returned data is sorted
- [`$first` and `$after`](#first-and-after): returns only the top `n` items

Query parameters can be used together.

#### `$select`

The query parameter `$select` allow to specify which fields must be returned. For example:

```http
GET /api/author?$select=first_name,last_name
```

This request returns only `first_name` and `last_name` fields.

If any of the requested fields don't exist or isn't accessible due to configured permissions, a `400 - Bad Request` is returned.

#### `$filter`

The value of the `$filter` option is predicate expression (an expression that returns a boolean value) using entity's fields. Only items where the expression evaluates to True are included in the response. For example:

```http
GET /api/author?$filter=last_name eq 'Asimov'
```

This request returns only those authors whose family name is `Asimov`

The operators supported by the `$filter` option are:

| Operator | Type | Description | Example |
| --- | --- | --- | --- |
| `eq` | Comparison | Equal | `title eq 'Hyperion'` |
| `ne` | Comparison | Not equal | `title ne 'Hyperion'` |
| `gt` | Comparison | Greater than | `year gt 1990` |
| `ge` | Comparison | Greater than or equal | `year ge 1990` |
| `lt` | Comparison | Less than | `year lt 1990` |
| `le` | Comparison | Less than or equal | `year le 1990` |
| `and` | Logical | Logical and | `year ge 1980 and year lt 1990` |
| `or` | Logical | Logical or | `year le 1960 or title eq 'Hyperion'` |
| `not` | Logical | Logical negation | `not (year le 1960)` |
| `( )` | Grouping | Precedence grouping | `(year ge 1970 or title eq 'Foundation') and pages gt 400` |

> [!NOTE]
> `$filter` is a case sensitive argument.

#### `$orderby`

The value of the `orderby` parameter is a comma-separated list of expressions used to sort the items.

Each expression in the `orderby` parameter value might include the suffix `desc` to ask for a descending order, separated from the expression by one or more spaces.

For example:

```http
GET /api/author?$orderby=first_name desc, last_name
```

This request returns the list of authors sorted by `first_name` descending and then by `last_name` ascending.

> [!NOTE]
> `$orderBy` is a case sensitive argument.

#### `$first` and `$after`

The query parameter `$first` allows the user to limit the number of items returned. For example:

```http
GET /api/book?$first=5
```

This request returns only the first `n` books. In case ordering isn't specified, items are ordered based on the underlying primary key. `n` must be a positive integer value.

If the number of items available to the entity is bigger than the number specified in the `$first` parameter, the returned result contains a `nextLink` item:

```json
{
    "value": [],
    "nextLink": ""
}
```

The `nextLink` property can be used to get the next set of items via the `$after` query parameter using the following format:

```http
GET /api/book?$first={n}&$after={continuation-data}
```

## POST

Create a new item for the specified entity. For example:

```http
POST /api/book
Content-type: application/json

{
  "id": 2000,
  "title": "Do Androids Dream of Electric Sheep?"
}
```

The POST request creates a new book. All the fields that can't be nullable must be supplied. If successful the full entity object, including any null fields, is returned:

```json
{
  "value": [
    {
      "id": 2000,
      "title": "Do Androids Dream of Electric Sheep?",
      "year": null,
      "pages": null
    }
  ]
}
```

## PUT

PUT creates or replaces an item of the specified entity. The query pattern is:

```http
PUT /api/{entity}/{primary-key-column}/{primary-key-value}
```

For example:

```http
PUT /api/book/id/2001
Content-type: application/json

{  
  "title": "Stranger in a Strange Land",
  "pages": 525
}
```

If there's an item with the specified primary key `2001`, the provided data *completely replaces* that item. If instead an item with that primary key doesn't exist, a new item is created.

In either case, the result is something like:

```json
{
  "value": [
    {
      "id": 2001,
      "title": "Stranger in a Strange Land",
      "year": null,
      "pages": 525
    }
  ]
}
```

## PATCH

PATCH creates or updates the item of the specified entity. Only the specified fields are affected. All fields not specified in the request body aren't affected. If an item with the specified primary key doesn't exist, a new item is created.

The query pattern is:

```http
PATCH /api/{entity}/{primary-key-column}/{primary-key-value}
```

For example:

```http
PATCH /api/book/id/2001
Content-type: application/json

{    
  "year": 1991
}
```

The result is something like:

```json
{
  "value": [
    {
      "id": 2001,
      "title": "Stranger in a Strange Land",
      "year": 1991,
      "pages": 525
    }
  ]
}
```

## DELETE

DELETE deletes the item of the specified entity.
The query pattern is:

```http
DELETE /api/{entity}/{primary-key-column}/{primary-key-value}
```

For example:

```http
DELETE /api/book/id/2001
```

If successful, the result is an empty response with status code 204.

### Database transactions for REST API requests

To process POST, PUT, PATCH, and DELETE API requests; Data API builder constructs and executes the database queries in a transaction.

[!INCLUDE[Database isolation levels](includes/database-isolation-levels.md)]

## Related content

- [OpenAPI](openapi.md)
- [REST configuration reference](reference-configuration.md#rest-entities)
