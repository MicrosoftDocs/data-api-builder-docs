---
title: REST in Data API builder
description: This document contains details about REST in Data API builder.
author: seantleonard
ms.author: seleonar
ms.service: data-api-builder
ms.topic: rest-in-data-api-builder
ms.date: 06/14/2023
---

# REST in Data API builder

Data API builder provides a RESTful web API that enables you to access tables, views, and stored procedures from a connected database. An entity represents a database object in Data API builder's runtime config. An entity must be set in the runtime config in order to be available on the REST API endpoint.

## Call a REST API method

To read from or write to a resource (or entity), you construct a request that looks like the following pattern:

```http
{HTTP method} https://{base_url}/{rest-path}/{entity}
```

> [!NOTE]
> The URL path (entities and query parameters) is case sensitive.

The components of a request include:

- [{HTTP method}](#http-methods) - The HTTP method used on the request to Data API builder.
- {base_url} - The domain (or localhost server and port) which hosts an instance of Data API builder.
- [{rest-path}](#rest-path) - The base path of the REST API endpoint set in the runtime config.
- [{entity}](#entity) - The name of the database object as defined in the runtime config.

An example GET request on the `book` entity residing under the REST endpoint base `/api` in a local development environment `localhost`:

```http
GET https:/localhost:5001/api/Book
```

### HTTP methods

Data API builder uses the HTTP method on your request to determine what action to take on the request designated entity. The following HTTP verbs are available, dependent upon the permissions set for a particular entity.

| **Method**        | **Description**                                                             |
|:------------------|:----------------------------------------------------------------------------|
| [GET](#get)       | Get zero, one or more items.                                                |
| [POST](#post)     | Create a new item.                                                          |
| [PATCH](#patch)   | Update an item with new values if one exists. Otherwise, create a new item. |
| [PUT](#put)       | Replace an item with a new one if one exists. Otherwise, create a new item. |
| [DELETE](#delete) | Delete an item.                                                             |

### Rest path

The rest path designates the location of Data API builder's REST API. The path is configurable in the runtime config and defaults to */api*. For more information, see the [configuration file article](./configuration-file/overview.md).

### Entity

*Entity* is the terminology used to reference a REST API resource in  Data API builder. By default, the URL route value for an entity is the entity name defined in the runtime config. An entity's REST URL path value is configurable within the entity's REST settings. For more information, see the [configuration file article](./configuration-file/overview.md).

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

Using the GET method you can retrieve one or more items of the desired entity

### URL parameters

REST endpoints support the ability to return an item via its primary key, using URL parameter:

```http
GET /api/{entity}/{primary-key-column}/{primary-key-value}
```

for example:

```http
GET /api/book/id/1001
```

### Query parameters

REST endpoints support the following query parameters (case sensitive) to control the returned items:

- [`$select`](#select): returns only the selected columns
- [`$filter`](#filter): filters the returned items
- [`$orderby`](#orderby): defines how the returned data is sorted
- [`$first` and `$after`](#first-and-after): returns only the top `n` items

Query parameters can be used together

#### `$select`

The query parameter `$select` allow to specify which fields must be returned. For example:

```http
GET /api/author?$select=first_name,last_name
```

returns only `first_name` and `last_name` fields.

If any of the requested fields don't exist or isn't accessible due to configured permissions, a `400 - Bad Request` is returned.

#### `$filter`

The value of the `$filter` option is predicate expression (an expression that returns a boolean value) using entity's fields. Only items where the expression evaluates to True are included in the response. For example:

```http
GET /api/author?$filter=last_name eq 'Asimov'
```

returns only those authors whose last name is `Asimov`

The operators supported by the `$filter` option are:

Operator                 | Description           | Example
--------------------     | --------------------- | -----------------------------------------------------
**Comparison Operators** |                       |
eq                       | Equal                 | title eq 'Hyperion'
ne                       | Not equal             | title ne 'Hyperion'
gt                       | Greater than          | year gt 1990
ge                       | Greater than or equal | year ge 1990
lt                       | Less than             | year lt 1990
le                       | Less than or equal    | year le 1990
**Logical Operators**    |                       |
and                      | Logical and           | year ge 1980 and year lt 1990
or                       | Logical or            | year le 1960 or title eq 'Hyperion'
not                      | Logical negation      | not (year le 1960)
**Grouping Operators**   |                       |
( )                      | Precedence grouping   | (year ge 1970 or title eq 'Foundation') and pages gt 400

> [!NOTE]
> `$filter` is a case sensitive argument.

#### `$orderby`

The value of the `orderby` parameter is a comma-separated list of expressions used to sort the items.

Each expression in the `orderby` parameter value may include the suffix `desc` to ask for a descending order, separated from the expression by one or more spaces.

For example:

```http
GET /api/author?$orderby=first_name desc, last_name
```

returns the list of authors sorted by `first_name` descending and then by `last_name` ascending.

> [!NOTE]
> `$orderBy` is a case sensitive argument.

#### `$first` and `$after`

The query parameter `$first` allows the user to limit the number of items returned. For example:

```http
GET /api/book?$first=5
```

returns only the first `n` books. In case ordering isn't specified, items are ordered based on the underlying primary key. `n` must be a positive integer value.

If the number of items available to the entity is bigger than the number specified in the `$first` parameter, the returned result contains a `nextLink` item:

```json
{
    "value": [],
    "nextLink": ""
}
```

`nextLink` can be used to get the next set of items via the `$after` query parameter using the following format:

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

creates a new book. All the fields that can't be nullable must be supplied. If successful the full entity object, including any null fields, is returned:

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

for example:

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

for example:

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

for example:

```http
DELETE /api/book/id/2001
```

If successful, the result is an empty response with status code 204.

### Database transactions for REST API requests

To process POST, PUT, PATCH and DELETE API requests, Data API builder constructs and executes the database queries in a transaction.

The following table lists the isolation levels with which the transactions are created for each database type.

|**Database Type**|**Isolation Level**|**Isolation Level Docs**
:-----:|:-----:|:-----|
Azure SQL (or) SQL Server|Read Committed|[Azure SQL docs](https://www.learn.microsoft.com/sql/t-sql/language-elements/transaction-isolation-levels)
MySQL|Repeatable Read|[MySQL docs](https://dev.mysql.com/doc/refman/8.0/en/innodb-transaction-isolation-levels.html#isolevel_repeatable-read)
PostgreSQL|Read Committed|[PostgreSQL docs](https://www.postgresql.org/docs/current/transaction-iso.html#XACT-READ-COMMITTED)
