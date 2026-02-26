---
title: How to call REST endpoints
description: Learn how to call and use REST endpoints in Data API builder, including how to query, filter, sort, and page results.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 2/25/2026
# Customer Intent: As a developer, I want to call REST endpoints in Data API builder to query, filter, and modify data safely and efficiently.
---

# How to call REST endpoints

Data API builder (DAB) provides a RESTful web API that lets you access tables, views, and stored procedures from a connected database.
Each exposed database object is defined as an *entity* in the runtime configuration.

By default, DAB hosts REST endpoints at:

```
https://{base_url}/api/{entity}
```

> [!NOTE]
> All path components and query parameters are case sensitive.

#### Keywords supported in Data API builder

| Concept      | REST                                       | Purpose                       |
| ------------ | ------------------------------------------ | ----------------------------- |
| Projection   | [$select](../../keywords/select-rest.md)   | Choose which fields to return |
| Filtering    | [$filter](../../keywords/filter-rest.md)   | Restrict rows by condition    |
| Sorting      | [$orderby](../../keywords/orderby-rest.md) | Define the sort order         |
| Page size    | [$first](../../keywords/first-rest.md)     | Limit the items per page      |
| Continuation | [$after](../../keywords/after-rest.md)     | Continue from the last page   |

## Basic structure

To call a REST API, construct a request using this pattern:

```http
{HTTP method} https://{base_url}/{rest-path}/{entity}
```

Example reading all records from the `book` entity:

```http
GET https://localhost:5001/api/book
```

The response is a JSON object with a `value` array. Pagination and error information appear only when applicable.

> [!NOTE]
> By default, DAB returns up to 100 items per query unless configured otherwise (`runtime.pagination.default-page-size`).

### [HTTP](#tab/http)

```http
GET https://localhost:5001/api/book
```

**Success:**

```json
{
  "value": [
    { "id": 1, "title": "Dune", "year": 1965, "pages": 412 },
    { "id": 2, "title": "Foundation", "year": 1951, "pages": 255 }
  ]
}
```

**Success with pagination:**

```json
{
  "value": [
    { "id": 1, "title": "Dune", "year": 1965, "pages": 412 },
    { "id": 2, "title": "Foundation", "year": 1951, "pages": 255 }
  ],
  "nextLink": "https://localhost:5001/api/book?$after=WyJCb29rMiJd"
}
```

**Error:**

```json
{
  "error": {
    "code": "NotFound",
    "message": "Could not find item with the given key.",
    "status": 404
  }
}
```

### [cURL](#tab/curl)

```bash
curl -X GET "https://localhost:5001/api/book"
```

### [C#](#tab/csharp)

The following model classes deserialize DAB responses:

```csharp
using System.Text.Json.Serialization;

public class DabResponse<T>
{
    [JsonPropertyName("value")]
    public List<T>? Value { get; set; }

    [JsonPropertyName("nextLink")]
    public string? NextLink { get; set; }

    [JsonPropertyName("error")]
    public DabError? Error { get; set; }

    [JsonIgnore]
    public bool IsSuccess => Error is null;

    [JsonIgnore]
    public bool HasNextPage => NextLink is not null;
}

public class DabError
{
    [JsonPropertyName("code")]
    public string Code { get; set; } = string.Empty;

    [JsonPropertyName("message")]
    public string Message { get; set; } = string.Empty;

    [JsonPropertyName("status")]
    public int Status { get; set; }
}

public class Book
{
    [JsonPropertyName("id")]
    public int Id { get; set; }

    [JsonPropertyName("title")]
    public string Title { get; set; } = string.Empty;

    [JsonPropertyName("year")]
    public int? Year { get; set; }

    [JsonPropertyName("pages")]
    public int? Pages { get; set; }
}
```

Call the API and deserialize the response:

```csharp
public async Task<List<Book>> GetBooksAsync()
{
    var response = await httpClient.GetAsync("api/book");
    response.EnsureSuccessStatusCode();
    var result = await response.Content.ReadFromJsonAsync<DabResponse<Book>>();

    if (result?.Error is not null)
    {
        throw new Exception($"{result.Error.Code}: {result.Error.Message}");
    }

    return result?.Value ?? [];
}
```

### [Python](#tab/python)

The following data classes model DAB responses:

```python
from dataclasses import dataclass
import requests

@dataclass
class Book:
    id: int
    title: str
    year: int | None = None
    pages: int | None = None

@dataclass
class DabError:
    code: str
    message: str
    status: int

@dataclass
class DabResponse:
    value: list[Book] | None = None
    next_link: str | None = None
    error: DabError | None = None

    @property
    def is_success(self) -> bool:
        return self.error is None

    @property
    def has_next_page(self) -> bool:
        return self.next_link is not None
```

Call the API and parse the response:

```python
def get_books(base_url: str) -> list[Book]:
    response = requests.get(f"{base_url}/api/book")
    response.raise_for_status()
    data = response.json()

    if "error" in data:
        err = data["error"]
        raise Exception(f"{err['code']}: {err['message']}")

    return [Book(**item) for item in data.get("value", [])]
```

### [JavaScript](#tab/javascript)

The following function calls the API:

```javascript
async function getBooks(baseUrl) {
  const response = await fetch(`${baseUrl}/api/book`);
  if (!response.ok) {
    throw new Error(`HTTP error: ${response.status}`);
  }
  const data = await response.json();

  if (data.error) {
    throw new Error(`${data.error.code}: ${data.error.message}`);
  }

  return data.value ?? [];
}
```

Example usage:

```javascript
const books = await getBooks("https://localhost:5001");
console.log(`Fetched ${books.length} books from the API.`);
```

---

## Query types

Each REST entity supports both collection and single-record reads.

| Operation                                                    | Description                       |
| ------------------------------------------------------------ | --------------------------------- |
| `GET /api/{entity}`                                          | Returns a list of records         |
| `GET /api/{entity}/{primary-key-column}/{primary-key-value}` | Returns one record by primary key |

Example returning one record:

```http
GET /api/book/id/1010
```

Example returning many:

```http
GET /api/book
```

## Filtering results

Use the `$filter` query parameter to restrict which records are returned.

```http
GET /api/book?$filter=title eq 'Foundation'
```

This query returns all books whose title equals "Foundation."

Filters can include logical operators for more complex queries:

```http
GET /api/book?$filter=year ge 1970 or title eq 'Dune'
```

For more information, see the [$filter argument reference](../../keywords/filter-rest.md).

## Sorting results

The `$orderby` parameter defines how records are sorted.

```http
GET /api/book?$orderby=year desc, title asc
```

This returns books ordered by `year` descending, then by `title`.

For more information, see the [$orderby argument reference](../../keywords/orderby-rest.md).

## Limiting results {#first-and-after}

The `$first` parameter limits how many records are returned in one request.

```http
GET /api/book?$first=5
```

This returns the first five books, ordered by primary key by default.
You can also use `$first=-1` to request the configured maximum page size.

For more information, see the [$first argument reference](../../keywords/first-rest.md).

## Continuing results

To fetch the next page, use `$after` with the continuation token from the previous response.

```http
GET /api/book?$first=5&$after={continuation-token}
```

The `$after` token identifies where the last query ended.
For more information, see the [$after argument reference](../../keywords/after-rest.md).

## Field selection (projection)

Use `$select` to control which fields are included in the response.

```http
GET /api/book?$select=id,title,price
```

This returns only the specified columns.
If a field is missing or not accessible, DAB returns `400 Bad Request`.

For more information, see the [$select argument reference](../../keywords/select-rest.md).

## Modifying data

The REST API also supports create, update, and delete operations depending on entity permissions.

| Method   | Action                                          |
| -------- | ----------------------------------------------- |
| `POST`   | Create a new item                               |
| `PUT`    | Replace an existing item (or create if missing) |
| `PATCH`  | Update an existing item (or create if missing)  |
| `DELETE` | Remove an item by primary key                   |

## Create a new record

Use `POST` to create a new item.

### [HTTP](#tab/http)

```http
POST https://localhost:5001/api/book
Content-Type: application/json

{
  "id": 2000,
  "title": "Leviathan Wakes",
  "year": 2011,
  "pages": 577
}
```

### [cURL](#tab/curl)

```bash
curl -X POST "https://localhost:5001/api/book" \
  -H "Content-Type: application/json" \
  -d '{"id": 2000, "title": "Leviathan Wakes", "year": 2011, "pages": 577}'
```

### [C#](#tab/csharp)

```csharp
var book = new Book
{
    Id = 2000,
    Title = "Leviathan Wakes",
    Year = 2011,
    Pages = 577
};
var response = await httpClient.PostAsJsonAsync("api/book", book);
response.EnsureSuccessStatusCode();
var result = await response.Content.ReadFromJsonAsync<DabResponse<Book>>();

if (result?.Error is not null)
{
    throw new Exception($"{result.Error.Code}: {result.Error.Message}");
}
```

### [Python](#tab/python)

```python
book = {"id": 2000, "title": "Leviathan Wakes", "year": 2011, "pages": 577}
response = requests.post(f"{base_url}/api/book", json=book)
response.raise_for_status()
data = response.json()

if "error" in data:
    err = data["error"]
    raise Exception(f"{err['code']}: {err['message']}")
```

### [JavaScript](#tab/javascript)

```javascript
const book = { id: 2000, title: "Leviathan Wakes", year: 2011, pages: 577 };
const response = await fetch(`${baseUrl}/api/book`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify(book),
});
const data = await response.json();

if (data.error) {
  throw new Error(`${data.error.code}: ${data.error.message}`);
}
```

---

## Update an existing record

Use `PATCH` to update specific fields on an existing item.

### [HTTP](#tab/http)

```http
PATCH https://localhost:5001/api/book/id/2000
Content-Type: application/json

{
  "id": 2000,
  "title": "Leviathan Wakes",
  "year": 2011,
  "pages": 577
}
```

### [cURL](#tab/curl)

```bash
curl -X PATCH "https://localhost:5001/api/book/id/2000" \
  -H "Content-Type: application/json" \
  -d '{"id": 2000, "title": "Leviathan Wakes", "year": 2011, "pages": 577}'
```

### [C#](#tab/csharp)

> [!TIP]
> By default, DAB rejects fields in your request body that don't exist in the database or that belong in the URL (like primary key fields for PATCH and DELETE). This behavior requires separate C# types: one with keys for POST and one without for updates. To reuse a single type like `Book` for all operations, set `runtime.rest.request-body-strict` to `false` in your configuration.

```csharp
var book = new Book
{
    Id = 2000,
    Title = "Leviathan Wakes",
    Year = 2011,
    Pages = 577
};
var response = await httpClient.PatchAsJsonAsync("api/book/id/2000", book);
response.EnsureSuccessStatusCode();
var result = await response.Content.ReadFromJsonAsync<DabResponse<Book>>();

if (result?.Error is not null)
{
    throw new Exception($"{result.Error.Code}: {result.Error.Message}");
}
```

### [Python](#tab/python)

```python
book = {"id": 2000, "title": "Leviathan Wakes", "year": 2011, "pages": 577}
response = requests.patch(f"{base_url}/api/book/id/2000", json=book)
response.raise_for_status()
data = response.json()

if "error" in data:
    err = data["error"]
    raise Exception(f"{err['code']}: {err['message']}")
```

### [JavaScript](#tab/javascript)

```javascript
const book = { id: 2000, title: "Leviathan Wakes", year: 2011, pages: 577 };
const response = await fetch(`${baseUrl}/api/book/id/2000`, {
  method: "PATCH",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify(book),
});
const data = await response.json();

if (data.error) {
  throw new Error(`${data.error.code}: ${data.error.message}`);
}
```

---

## Delete a record

Use `DELETE` to remove an item by primary key.

### [HTTP](#tab/http)

```http
DELETE https://localhost:5001/api/book/id/2000
```

### [cURL](#tab/curl)

```bash
curl -X DELETE "https://localhost:5001/api/book/id/2000"
```

### [C#](#tab/csharp)

```csharp
var response = await httpClient.DeleteAsync("api/book/id/2000");
response.EnsureSuccessStatusCode();
var result = await response.Content.ReadFromJsonAsync<DabResponse<Book>>();

if (result?.Error is not null)
{
    throw new Exception($"{result.Error.Code}: {result.Error.Message}");
}
```

### [Python](#tab/python)

```python
response = requests.delete(f"{base_url}/api/book/id/2000")
response.raise_for_status()
data = response.json()

if "error" in data:
    err = data["error"]
    raise Exception(f"{err['code']}: {err['message']}")
```

### [JavaScript](#tab/javascript)

```javascript
const response = await fetch(`${baseUrl}/api/book/id/2000`, {
  method: "DELETE",
});
const data = await response.json();

if (data.error) {
  throw new Error(`${data.error.code}: ${data.error.message}`);
}
```

---

