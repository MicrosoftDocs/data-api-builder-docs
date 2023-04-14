---
title: REST in Data API builder
description: This document contains details about REST in Data API builder.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: rest-in-data-api-builder
ms.date: 04/06/2023
---

# REST in Data API builder

Entities configured to be available via REST are available at the path

```bash
http://<dab-server>/api/<entity>
```

Using the [Getting Started](./getting-started/getting-started.md) example, with `books` and the `authors` entity configured for REST access, the path would be, for example:

```bash
http://localhost:5000/api/book
```

Depending on the permission defined on the entity in the configuration file, the following HTTP verbs are available:

- [GET](#get): Get zero, one or more items
- [POST](#post): Create a new item
- [PUT](#put): Create or replace an item
- [PATCH](#patch): Update an item
- [DELETE](#delete): Delete an item

> **Attention!**: the URL path (entities and query parameters) is case sensitive

## Result set format

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

```bash
http://<dab-server>/api/<entity>/<primary-key-column>/<primary-key-value>
```

for example:

```bash
http://localhost:5000/api/book/id/1001
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

```bash
http://localhost:5000/api/author?$select=first_name,last_name
```

returns only `first_name` and `last_name` fields.

If any of the requested fields don't exist or isn't accessible due to configured permissions, a `400 - Bad Request` is returned.

#### `$filter`

The value of the `$filter` option is predicate expression (an expression that returns a boolean value) using entity's fields. Only items where the expression evaluates to True are included in the response. For example:

```bash
http://localhost:5000/api/author?$filter=last_name eq 'Asimov'
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

**NOTE: `$filter` is a case sensitive argument.**

#### `$orderby`

The value of the `orderby` parameter is a comma-separated list of expressions used to sort the items. 

Each expression in the `orderby` parameter value may include the suffix `desc` to ask for a descending order, separated from the expression by one or more spaces.

For example:

```bash
http://localhost:5000/api/author?$orderby=first_name desc, last_name
```

returns the list of authors sorted by `first_name` descending and then by `last_name` ascending.

**NOTE: `$orderBy` is a case sensitive argument.**

#### `$first` and `$after`

The query parameter `$first` allows to limit the number of items returned. For example:

```bash
http://localhost:5000/api/book?$first=5
```

returns only the first `n` books. In case ordering isn't specified, items are ordered by the underlying primary key. `n` must be a positive integer value.

If the number of items available to the entity is bigger than the number specified in the `$first` parameter, the returned result contains a `nextLink` item:

```json
{
    "value": [],
    "nextLink": ""
}
```

`nextLink` can be used to get the next set of items via the `$after` query parameter using the following format:

```bash
http://<dab-server>/api/book?$first=<n>&$after=<continuation-data>
```

## POST

Create a new item for the specified entity. For example:

```bash
POST http://localhost:5000/api/book

{
  "id": 2000,
  "title": "Do Androids Dream of Electric Sheep?"
}
```

creates a new book. All the fields that can't be nullable must be supplied. If successful the full entity object, including any null fields, is returned:

```JSON
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

```bash
http://<dab-server>/api/<entity>/<primary-key-column>/<primary-key-value>
```

for example:

```bash
PUT /api/book/id/2001

{  
  "title": "Stranger in a Strange Land",
  "pages": 525
}
```

If there's an item with the specified primary key `2001` that item is *completely replaced* by the provided data. If instead an item with that primary key doesn't exist, a new item is created.

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

PATCH creates or updates the item of the specified entity. Only the specified fields are affected. All fields not specified in the request body are not affected. If an item with the specified primary key doesn't exist, a new item is created.

The query pattern is:

```bash
http://<dab-server>/api/<entity>/<primary-key-column>/<primary-key-value>
```

for example:

```bash
PATCH /api/book/id/2001

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

```bash
http://<dab-server>/api/<entity>/<primary-key-column>/<primary-key-value>
```

for example:

```bash
DELETE /api/book/id/2001
```

If successful, the result is an empty response with status code 204.
