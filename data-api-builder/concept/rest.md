---
title: Host REST endpoints
description: Review REST endpoint hosting for Data API builder including, how to expose endpoints, endpoint configuration, and invocation.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 06/11/2025
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
GET https://localhost:5001/api/Book
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

The rest path designates the location of Data API builder's REST API. The path is configurable in the runtime configuration and defaults to */api*. For more information, see [REST path configuration](../reference-configuration.md#path-rest-entity).

### Entity

*Entity* is the terminology used to reference a REST API resource in  Data API builder. By default, the URL route value for an entity is the entity name defined in the runtime configuration. An entity's REST URL path value is configurable within the entity's REST settings. For more information, see [entity configuration](../reference-configuration.md#rest-entities).

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

### URL Parameters

REST endpoints allow you to retrieve an item by its primary key using URL parameters. For entities with a single primary key, the format is straightforward:

```http
GET /api/{entity}/{primary-key-column}/{primary-key-value}
```

To retrieve a book with an ID of `1001`, you would use:

```http
GET /api/book/id/1001
```

For entities with compound primary keys, where more than one column is used to uniquely identify a record, the URL format includes all key columns in sequence:

```http
GET /api/{entity}/{primary-key-column1}/{primary-key-value1}/{primary-key-column2}/{primary-key-value2}
```

If a `books` entity has a compound key consisting of `id1` and `id2`, you would retrieve a specific book like this:

```http
GET /api/books/id1/123/id2/abc
```

### For example:

Here’s how a call would look:

```http
### Retrieve a book by a single primary key
GET /api/book/id/1001

### Retrieve an author by a single primary key
GET /api/author/id/501

### Retrieve a book by compound primary keys (id1 and id2)
GET /api/books/id1/123/id2/abc

### Retrieve an order by compound primary keys (orderId and customerId)
GET /api/orders/orderId/789/customerId/456

### Retrieve a product by compound primary keys (categoryId and productId)
GET /api/products/categoryId/electronics/productId/987

### Retrieve a course by compound primary keys (departmentCode and courseNumber)
GET /api/courses/departmentCode/CS/courseNumber/101
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
### Get all fields
GET /api/author

### Get only first_name field
GET /api/author?$select=first_name

### Get only first_name and last_name fields
GET /api/author?$select=first_name,last_name
```

> [!NOTE]
> If any of the requested fields don't exist or isn't accessible due to configured permissions, a `400 - Bad Request` is returned.

The `$select` query parameter, also known as "projection," is used to control the size of the data returned in an API response. With only needed columns, `$select` reduces the payload size, which can improve performance by minimizing parsing time, reducing bandwidth usage, and speeding up data processing. This optimization extends to the database. There, only the requested columns are retrieved.  

#### `$filter`

The value of the `$filter` option is a predicate expression (an expression that returns a boolean result) using entity's fields. Only items where the expression evaluates to True are included in the response. For example:

```http
### Get books titled "Hyperion" (Equal to)
GET /api/book?$filter=title eq 'Hyperion'

### Get books not titled "Hyperion" (Not equal to)
GET /api/book?$filter=title ne 'Hyperion'

### Get books published after 1990 (Greater than)
GET /api/book?$filter=year gt 1990

### Get books published in or after 1990 (Greater than or equal to)
GET /api/book?$filter=year ge 1990

### Get books published before 1991 (Less than)
GET /api/book?$filter=year lt 1991

### Get books published in or before 1990 (Less than or equal to)
GET /api/book?$filter=year le 1990

### Get books published between 1980 and 1990 (Logical and)
GET /api/book?$filter=year ge 1980 and year le 1990

### Get books published before 1960 or titled "Hyperion" (Logical or)
GET /api/book?$filter=year le 1960 or title eq 'Hyperion'

### Get books not published before 1960 (Logical negation)
GET /api/book?$filter=not (year le 1960)

### Get books published in 1970 or later, and either titled "Foundation" or with more than 400 pages (Grouping)
GET /api/book?$filter=(year ge 1970 or title eq 'Foundation') and pages gt 400
```

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
> `$filter` is a case-sensitive argument.

The `$filter` query parameter in Azure Data API Builder might remind some users of OData, and that’s because it was directly inspired by OData’s filtering capabilities. The syntax is nearly identical, making it easy for developers who are already familiar with OData to pick up and use. This similarity was intentional, aimed at providing a familiar and powerful way to filter data across different APIs. 

### Filtering on Dates 

When filtering on `date` or `datetime` fields in Data API builder, use **unquoted ISO 8601 format** (`yyyy-MM-ddTHH:mm:ssZ`). This approach is required for operators like `ge`, `le`, `gt`, and `lt`.

#### Wrong format

```
$filter=Date ge '2025-01-01'         // quotes not allowed  
$filter=Date ge datetime'2025-01-01' // OData-style not supported  
```

#### Correct format

```
$filter=Date ge 2025-01-01T00:00:00Z and Date le 2025-01-05T00:00:00Z
```
#### Exact dates with `or`

If range filters cause issues, you can match exact dates:

```
$filter=ClassId eq 2 and (
  Date eq 2025-01-01T00:00:00Z or
  Date eq 2025-01-02T00:00:00Z or
  Date eq 2025-01-03T00:00:00Z
)
```

**Code Example**

Tip: Always `UrlEncode` the full `$filter` query before sending it.

### [HTTP](#tab/http)

```http
GET https://localhost:5001/api/Entity?$filter=Date ge 2025-01-01T00:00:00Z and Date le 2025-01-05T00:00:00Z
```

### [C#](#tab/csharp)

```csharp
using System;
using System.Net.Http;

var client = new HttpClient();
var baseUrl = "https://localhost:5001/api/Entity";

// Use DateTime objects
var start = new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc);
var end = new DateTime(2025, 1, 5, 0, 0, 0, DateTimeKind.Utc);

// Format to ISO 8601 with UTC indicator and full precision
var startDate = start.ToString("o"); // "2025-01-01T00:00:00.0000000Z"
var endDate = end.ToString("o");     // "2025-01-05T00:00:00.0000000Z"

var filterExpression = $"Date ge {startDate} and Date le {endDate}";
var encodedFilter = Uri.EscapeDataString(filterExpression);
var url = $"{baseUrl}?$filter={encodedFilter}";

var response = await client.GetAsync(url);
```

### [JavaScript/TypeScript](#tab/javascript-typescript)

```typescript
const baseUrl = "https://localhost:5001/api/Entity";

// Use real Date objects
const start = new Date(Date.UTC(2025, 0, 1)); // months are 0-based
const end = new Date(Date.UTC(2025, 0, 5));

// Format to ISO 8601 with 'Z' for UTC
const startDate = start.toISOString(); // "2025-01-01T00:00:00.000Z"
const endDate = end.toISOString();     // "2025-01-05T00:00:00.000Z"

const filterExpression = `Date ge ${startDate} and Date le ${endDate}`;
const encodedFilter = encodeURIComponent(filterExpression);
const url = `${baseUrl}?$filter=${encodedFilter}`;

const response = await fetch(url);
const data = await response.json();
```

### [Python](#tab/python)

```python
import requests
from urllib.parse import quote
from datetime import datetime, timezone

base_url = "https://localhost:5001/api/Entity"

# Use datetime objects with UTC timezone
start = datetime(2025, 1, 1, 0, 0, 0, tzinfo=timezone.utc)
end = datetime(2025, 1, 5, 0, 0, 0, tzinfo=timezone.utc)

# Format to ISO 8601 with 'Z'
start_date = start.isoformat().replace("+00:00", "Z")
end_date = end.isoformat().replace("+00:00", "Z")

filter_expression = f"Date ge {start_date} and Date le {end_date}"
encoded_filter = quote(filter_expression)

url = f"{base_url}?$filter={encoded_filter}"
response = requests.get(url)
print(response.json())
```

---

#### `$orderby`

The value of the `orderby` parameter is a comma-separated list of expressions used to sort the items.

Each expression in the `orderby` parameter value might include the suffix `desc` to ask for a descending order, separated from the expression by one or more spaces.

For example:

```http
### Order books by title in ascending order
GET /api/book?$orderby=title

### Order books by title in ascending order
GET /api/book?$orderby=title asc

### Order books by title in descending order
GET /api/book?$orderby=title desc

### Order books by year of publication in ascending order, then by title in ascending order
GET /api/book?$orderby=year asc, title asc

### Order books by year of publication in descending order, then by title in ascending order
GET /api/book?$orderby=year desc, title asc

### Order books by number of pages in ascending order, then by title in descending order
GET /api/book?$orderby=pages asc, title desc

### Order books by title in ascending order, then by year of publication in descending order
GET /api/book?$orderby=title asc, year desc
```

> [!NOTE]
> `$orderBy` is a case-sensitive argument.

The `$orderby` query parameter is valuable for sorting data directly on the server, easily handled on the client-side as well. However, it becomes useful when combined with other query parameters, such as `$filter` and `$first`. The parameter lets pagination maintain a stable and predictable dataset as you paginate through large collections.

#### `$first` and `$after`

The `$first` query parameter limits the number of items returned in a single request. For example:

```http
GET /api/book?$first=5
```

This request returns the first five books. The `$first` query parameter in Azure Data API Builder is similar to the `TOP` clause in SQL. Both are used to limit the number of records returned from a query. Just as `TOP` in SQL allows you to specify the quantity of rows to retrieve, `$first` lets you control the number of items returned by the API. `$first` is useful when you want to fetch a small subset of data, such as the first 10 results, without retrieving the entire dataset. The main advantage is efficiency, as it reduces the amount of data transmitted and processed.

> [!NOTE]
> In Azure Data API builder, the number of rows returned by default is limited by a setting in the configuration file. Users can override this limit using the `$first` parameter to request more rows, but there's still a configured maximum number of rows that can be returned overall. Additionally, there's a limit on the total megabytes that can be returned in a single response, which is also configurable. 

If more items are available beyond the specified limit, the response includes a `nextLink` property:

```json
{
    "value": [],
    "nextLink": "dab-will-generate-this-continuation-url"
}
```

The `nextLink` can be used with the `$after` query parameter to retrieve the next set of items:

```http
GET /api/book?$first={n}&$after={continuation-data}
```

This continuation approach uses cursor-based pagination. A unique cursor is a reference to a specific item in the dataset, determining where to continue retrieving data in the next set. Unlike index pagination that use offsets or indexes, cursor-based pagination doesn't rely on skipping records. Cursor continuation makes it more reliable with large datasets or frequently changing data. Instead, it ensures a smooth and consistent flow of data retrieval by starting exactly where the last query left off, based on the cursor provided.

For example:

```http
### Get the first 5 books explicitly
GET /api/book?$first=5

### Get the next set of 5 books using the continuation token
GET /api/book?$first=5&$after={continuation-token}

### Get the first 10 books, ordered by title
GET /api/book?$first=10&$orderby=title asc

### Get the next set of 10 books after the first set, ordered by title
GET /api/book?$first=10&$after={continuation-token}&$orderby=title asc

### Get books without specifying $first (automatic pagination limit)
GET /api/book

### Get the next set of books using the continuation token without specifying $first
GET /api/book?$after={continuation-token}
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

### The `If-Match: *` HTTP Request Header

The HTTP header `If-Match: *` ensures an **update operation** is performed **only if the resource exists**. If the resource does not exist, the operation will fail with HTTP Status Code: `404 Not Found`. If the `If-Match` header is **omitted**, the default behavior is to perform an **upsert**, which creates the resource if it does not already exist.

**Example:**
```http
PUT /api/Books/2001 HTTP/1.1
If-Match: *
Content-Type: application/json

{
  "title": "Stranger in a Strange Land",
  "pages": 525
}
```

> [!NOTE]
> If you specify a value other than `*` in the `If-Match` header, Data API builder will return a `400 Bad Request` error, as ETag-based matching is not supported.

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

### The `If-Match: *` HTTP Request Header

The HTTP header `If-Match: *` ensures an **update operation** is performed **only if the resource exists**. If the resource does not exist, the operation will fail with HTTP Status Code: `404 Not Found`. If the `If-Match` header is **omitted**, the default behavior is to perform an **upsert**, which creates the resource if it does not already exist.

**Example:**
```http
PATCH /api/Books/2001 HTTP/1.1
If-Match: *
Content-Type: application/json

{
    "year": 1991
}
```

> [!NOTE]
> If you specify a value other than `*` in the `If-Match` header, Data API builder will return a `400 Bad Request` error, as ETag-based matching is not supported.

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

[!INCLUDE[Database isolation levels](../includes/database-isolation-levels.md)]

## Related content

- [OpenAPI](openapi.md)
- [REST configuration reference](../reference-configuration.md#rest-entities)
