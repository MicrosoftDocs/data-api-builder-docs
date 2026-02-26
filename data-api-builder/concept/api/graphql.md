---
title: How to call GraphQL endpoints
description: Learn how to call and use GraphQL endpoints in Data API builder, including how to query, filter, sort, and page results.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 2/25/2026
# Customer Intent: As a developer, I want to call GraphQL endpoints in Data API builder to query, filter, and modify data safely and efficiently.
---

# How to call GraphQL endpoints

GraphQL endpoints in Data API builder (DAB) let you query and modify data with precision.
Each query declares exactly what fields you need and supports arguments for filtering, ordering, and paging results.

By default, DAB hosts its GraphQL endpoint at:

```
https://{base_url}/graphql
```

Entities exposed through configuration are automatically included in the GraphQL schema.
For example, if you have `books` and `authors` entities, both appear as root fields in the schema.

> [!NOTE]
> To explore the schema and autocomplete fields, use any modern GraphQL client or IDE (like Apollo, Insomnia, or the Visual Studio Code GraphQL extension).

#### Keywords supported in Data API builder

| Concept | GraphQL | Purpose |
|----------|------------------|----------|
| Projection |  [items](../../keywords/select-graphql.md) | Choose which fields to return |
| Filtering | [filter](../../keywords/filter-graphql.md) | Restrict rows by condition |
| Sorting | [orderBy](../../keywords/orderby-graphql.md) | Define the sort order |
| Page size | [first](../../keywords/first-graphql.md) | Limit the items per page |
| Continuation | [after](../../keywords/after-graphql.md) | Continue from the last page |

## Basic structure

Every GraphQL query starts with a root field that represents an entity.
All GraphQL requests use `POST` to the `/graphql` endpoint with a JSON body containing the query.

```graphql
{
  books {
    items {
      id
      title
      year
      pages
    }
  }
}
```

The response is a JSON object with the same shape as your selection set.
Pagination and error details appear only when applicable.

> [!NOTE]
> By default, DAB returns up to 100 items per query unless configured otherwise (`runtime.pagination.default-page-size`).

### [HTTP](#tab/http)

```http
POST https://localhost:5001/graphql
Content-Type: application/json

{
  "query": "{ books { items { id title year pages } } }"
}
```

**Success:**

```json
{
  "data": {
    "books": {
      "items": [
        { "id": 1, "title": "Dune", "year": 1965, "pages": 412 },
        { "id": 2, "title": "Foundation", "year": 1951, "pages": 255 }
      ]
    }
  }
}
```

**Success with pagination:**

```json
{
  "data": {
    "books": {
      "items": [
        { "id": 1, "title": "Dune", "year": 1965, "pages": 412 },
        { "id": 2, "title": "Foundation", "year": 1951, "pages": 255 }
      ],
      "hasNextPage": true,
      "endCursor": "eyJpZCI6Mn0="
    }
  }
}
```

**Error:**

```json
{
  "errors": [
    {
      "message": "Could not find item with the given key.",
      "locations": [{ "line": 1, "column": 3 }],
      "path": ["book_by_pk"]
    }
  ]
}
```

### [cURL](#tab/curl)

```bash
curl -X POST "https://localhost:5001/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ books { items { id title year pages } } }"}'
```

### [C#](#tab/csharp)

The following model classes deserialize DAB GraphQL responses:

```csharp
using System.Text.Json.Serialization;

public class GraphQLRequest
{
    [JsonPropertyName("query")]
    public string Query { get; set; } = string.Empty;

    [JsonPropertyName("variables")]
    public object? Variables { get; set; }
}

public class GraphQLResponse<T>
{
    [JsonPropertyName("data")]
    public T? Data { get; set; }

    [JsonPropertyName("errors")]
    public List<GraphQLError>? Errors { get; set; }

    [JsonIgnore]
    public bool IsSuccess => Errors is null || Errors.Count == 0;
}

public class GraphQLError
{
    [JsonPropertyName("message")]
    public string Message { get; set; } = string.Empty;

    [JsonPropertyName("path")]
    public List<string>? Path { get; set; }
}

public class BooksResponse
{
    [JsonPropertyName("books")]
    public BooksResult? Books { get; set; }
}

public class BooksResult
{
    [JsonPropertyName("items")]
    public List<Book>? Items { get; set; }

    [JsonPropertyName("hasNextPage")]
    public bool HasNextPage { get; set; }

    [JsonPropertyName("endCursor")]
    public string? EndCursor { get; set; }
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
    var request = new GraphQLRequest
    {
        Query = "{ books { items { id title year pages } } }"
    };

    var response = await httpClient.PostAsJsonAsync("graphql", request);
    response.EnsureSuccessStatusCode();
    var result = await response.Content.ReadFromJsonAsync<GraphQLResponse<BooksResponse>>();

    if (result?.Errors?.Count > 0)
    {
        throw new Exception(result.Errors[0].Message);
    }

    return result?.Data?.Books?.Items ?? [];
}
```

### [Python](#tab/python)

The following data classes model DAB GraphQL responses:

```python
from dataclasses import dataclass, field
import requests

@dataclass
class Book:
    id: int
    title: str
    year: int | None = None
    pages: int | None = None

@dataclass
class GraphQLError:
    message: str
    path: list[str] | None = None

@dataclass
class BooksResult:
    items: list[Book] = field(default_factory=list)
    has_next_page: bool = False
    end_cursor: str | None = None

@dataclass
class GraphQLResponse:
    data: dict | None = None
    errors: list[GraphQLError] | None = None

    @property
    def is_success(self) -> bool:
        return self.errors is None or len(self.errors) == 0
```

Call the API and parse the response:

```python
def get_books(base_url: str) -> list[Book]:
    query = "{ books { items { id title year pages } } }"
    response = requests.post(
        f"{base_url}/graphql",
        json={"query": query}
    )
    response.raise_for_status()
    data = response.json()

    if "errors" in data and data["errors"]:
        raise Exception(data["errors"][0]["message"])

    items = data.get("data", {}).get("books", {}).get("items", [])
    return [Book(**item) for item in items]
```

### [JavaScript](#tab/javascript)

The following function calls the GraphQL API:

```javascript
async function getBooks(baseUrl) {
  const query = "{ books { items { id title year pages } } }";

  const response = await fetch(`${baseUrl}/graphql`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ query }),
  });

  if (!response.ok) {
    throw new Error(`HTTP error: ${response.status}`);
  }

  const result = await response.json();

  if (result.errors?.length > 0) {
    throw new Error(result.errors[0].message);
  }

  return result.data?.books?.items ?? [];
}
```

Example usage:

```javascript
const books = await getBooks("https://localhost:5001");
console.log(`Fetched ${books.length} books from the API.`);
```

---

## Query types

Each entity supports two standard root queries:

| Query          | Description                                  |
| -------------- | -------------------------------------------- |
| `entity_by_pk` | Returns one record by its primary key        |
| `entities`     | Returns a list of records that match filters |

Example returning one record:

```graphql
{
  book_by_pk(id: 1010) {
    title
    year
  }
}
```

Example returning many:

```graphql
{
  books {
    items {
      id
      title
    }
  }
}
```

## Filtering results

Use the `filter` argument to restrict which records are returned.

```graphql
{
  books(filter: { title: { contains: "Foundation" } }) {
    items { id title }
  }
}
```

This query returns all books whose title contains “Foundation.”

Filters can combine comparisons with logical operators:

```graphql
{
  authors(filter: {
    or: [
      { first_name: { eq: "Isaac" } }
      { last_name: { eq: "Asimov" } }
    ]
  }) {
    items { first_name last_name }
  }
}
```

See the [filter argument reference](../../keywords/filter-graphql.md) for supported operators like `eq`, `neq`, `lt`, `lte`, and `isNull`.

## Sorting results

The `orderBy` argument defines how records are sorted.

```graphql
{
  books(orderBy: { year: DESC, title: ASC }) {
    items { id title year }
  }
}
```

This returns books ordered by `year` descending, then by `title`.

For more information, see the [orderBy argument reference](../../keywords/orderby-graphql.md).

## Limiting results

The `first` argument limits how many records are returned in a single request.

```graphql
{
  books(first: 5) {
    items { id title }
  }
}
```

This returns the first five books, ordered by primary key by default.
You can also use `first: -1` to request the configured maximum page size.

Learn more in the [first argument reference](../../keywords/first-graphql.md).

## Continuing results

To fetch the next page, use the `after` argument with the cursor from the previous query.

```graphql
{
  books(first: 5, after: "eyJpZCI6NX0=") {
    items { id title }
  }
}
```

The `after` token marks where the prior page ended.
For more information, see the [after argument reference](../../keywords/after-graphql.md).

## Field selection (projection)

In GraphQL, you choose exactly which fields appear in the response.
There's no wildcard like `SELECT *`. Request only what you need.

```graphql
{
  books {
    items { id title price }
  }
}
```

You can also use aliases to rename fields in the response:

```graphql
{
  books {
    items {
      bookTitle: title
      cost: price
    }
  }
}
```

See [field projection reference](../../keywords/select-graphql.md) for details.

## Modifying data

GraphQL mutations allow you to create, update, and delete records depending on entity permissions.

| Mutation              | Action                   |
| --------------------- | ------------------------ |
| `createEntity`        | Create a new item        |
| `updateEntity_by_pk`  | Update an existing item  |
| `deleteEntity_by_pk`  | Remove an item           |

## Create a new record

Use a `create` mutation to add a new item.

### [HTTP](#tab/http)

```http
POST https://localhost:5001/graphql
Content-Type: application/json

{
  "query": "mutation { createBook(item: { id: 2000, title: \"Leviathan Wakes\", year: 2011, pages: 577 }) { id title year pages } }"
}
```

### [cURL](#tab/curl)

```bash
curl -X POST "https://localhost:5001/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { createBook(item: { id: 2000, title: \"Leviathan Wakes\", year: 2011, pages: 577 }) { id title year pages } }"}'
```

### [C#](#tab/csharp)

```csharp
var request = new GraphQLRequest
{
    Query = @"
        mutation CreateBook($item: CreateBookInput!) {
            createBook(item: $item) { id title year pages }
        }",
    Variables = new
    {
        item = new { id = 2000, title = "Leviathan Wakes", year = 2011, pages = 577 }
    }
};

var response = await httpClient.PostAsJsonAsync("graphql", request);
response.EnsureSuccessStatusCode();
var result = await response.Content.ReadFromJsonAsync<GraphQLResponse<CreateBookResponse>>();

if (result?.Errors?.Count > 0)
{
    throw new Exception(result.Errors[0].Message);
}
```

### [Python](#tab/python)

```python
query = """
    mutation CreateBook($item: CreateBookInput!) {
        createBook(item: $item) { id title year pages }
    }
"""
variables = {
    "item": {"id": 2000, "title": "Leviathan Wakes", "year": 2011, "pages": 577}
}
response = requests.post(
    f"{base_url}/graphql",
    json={"query": query, "variables": variables}
)
response.raise_for_status()
data = response.json()

if "errors" in data and data["errors"]:
    raise Exception(data["errors"][0]["message"])
```

### [JavaScript](#tab/javascript)

```javascript
const query = `
  mutation CreateBook($item: CreateBookInput!) {
    createBook(item: $item) { id title year pages }
  }
`;
const variables = {
  item: { id: 2000, title: "Leviathan Wakes", year: 2011, pages: 577 },
};

const response = await fetch(`${baseUrl}/graphql`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ query, variables }),
});
const result = await response.json();

if (result.errors?.length > 0) {
  throw new Error(result.errors[0].message);
}
```

---

## Update an existing record

Use an `update` mutation to modify specific fields on an existing item.

### [HTTP](#tab/http)

```http
POST https://localhost:5001/graphql
Content-Type: application/json

{
  "query": "mutation { updateBook_by_pk(id: 2000, item: { title: \"Leviathan Wakes\", year: 2011, pages: 577 }) { id title year pages } }"
}
```

### [cURL](#tab/curl)

```bash
curl -X POST "https://localhost:5001/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { updateBook_by_pk(id: 2000, item: { title: \"Leviathan Wakes\", year: 2011, pages: 577 }) { id title year pages } }"}'
```

### [C#](#tab/csharp)

```csharp
var request = new GraphQLRequest
{
    Query = @"
        mutation UpdateBook($id: Int!, $item: UpdateBookInput!) {
            updateBook_by_pk(id: $id, item: $item) { id title year pages }
        }",
    Variables = new
    {
        id = 2000,
        item = new { title = "Leviathan Wakes", year = 2011, pages = 577 }
    }
};

var response = await httpClient.PostAsJsonAsync("graphql", request);
response.EnsureSuccessStatusCode();
var result = await response.Content.ReadFromJsonAsync<GraphQLResponse<UpdateBookResponse>>();

if (result?.Errors?.Count > 0)
{
    throw new Exception(result.Errors[0].Message);
}
```

### [Python](#tab/python)

```python
query = """
    mutation UpdateBook($id: Int!, $item: UpdateBookInput!) {
        updateBook_by_pk(id: $id, item: $item) { id title year pages }
    }
"""
variables = {
    "id": 2000,
    "item": {"title": "Leviathan Wakes", "year": 2011, "pages": 577}
}
response = requests.post(
    f"{base_url}/graphql",
    json={"query": query, "variables": variables}
)
response.raise_for_status()
data = response.json()

if "errors" in data and data["errors"]:
    raise Exception(data["errors"][0]["message"])
```

### [JavaScript](#tab/javascript)

```javascript
const query = `
  mutation UpdateBook($id: Int!, $item: UpdateBookInput!) {
    updateBook_by_pk(id: $id, item: $item) { id title year pages }
  }
`;
const variables = {
  id: 2000,
  item: { title: "Leviathan Wakes", year: 2011, pages: 577 },
};

const response = await fetch(`${baseUrl}/graphql`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ query, variables }),
});
const result = await response.json();

if (result.errors?.length > 0) {
  throw new Error(result.errors[0].message);
}
```

---

## Delete a record

Use a `delete` mutation to remove an item by primary key.

### [HTTP](#tab/http)

```http
POST https://localhost:5001/graphql
Content-Type: application/json

{
  "query": "mutation { deleteBook_by_pk(id: 2000) { id title } }"
}
```

### [cURL](#tab/curl)

```bash
curl -X POST "https://localhost:5001/graphql" \
  -H "Content-Type: application/json" \
  -d '{"query": "mutation { deleteBook_by_pk(id: 2000) { id title } }"}'
```

### [C#](#tab/csharp)

```csharp
var request = new GraphQLRequest
{
    Query = @"
        mutation DeleteBook($id: Int!) {
            deleteBook_by_pk(id: $id) { id title }
        }",
    Variables = new { id = 2000 }
};

var response = await httpClient.PostAsJsonAsync("graphql", request);
response.EnsureSuccessStatusCode();
var result = await response.Content.ReadFromJsonAsync<GraphQLResponse<DeleteBookResponse>>();

if (result?.Errors?.Count > 0)
{
    throw new Exception(result.Errors[0].Message);
}
```

### [Python](#tab/python)

```python
query = """
    mutation DeleteBook($id: Int!) {
        deleteBook_by_pk(id: $id) { id title }
    }
"""
variables = {"id": 2000}
response = requests.post(
    f"{base_url}/graphql",
    json={"query": query, "variables": variables}
)
response.raise_for_status()
data = response.json()

if "errors" in data and data["errors"]:
    raise Exception(data["errors"][0]["message"])
```

### [JavaScript](#tab/javascript)

```javascript
const query = `
  mutation DeleteBook($id: Int!) {
    deleteBook_by_pk(id: $id) { id title }
  }
`;
const variables = { id: 2000 };

const response = await fetch(`${baseUrl}/graphql`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ query, variables }),
});
const result = await response.json();

if (result.errors?.length > 0) {
  throw new Error(result.errors[0].message);
}
```

---
