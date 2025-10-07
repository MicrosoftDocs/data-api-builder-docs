---
title: Use $filter (REST) and filter (GraphQL)
description: Learn how to express predicates, supported operators, validation rules, and implementation details for filtering in Data API builder.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/07/2025
# Customer Intent: As a developer, I want to filter datasets efficiently and safely.
---

# Filtering data in REST and GraphQL

Filtering narrows large sets to just the records you need. Data API builder supports expressive, parameterized predicates with *OData-inspired* syntax for REST and a structured input object model for GraphQL.

> [!NOTE]
> Filter logic is case sensitive. Field names and operators must match expected casing.

## REST: `$filter`

Pattern:

```
GET /api/{entity}?$filter=<predicate>
```

Examples (books):

```http
### Equality
GET /api/book?$filter=title eq 'Hyperion'

### Not equal
GET /api/book?$filter=title ne 'Hyperion'

### Numeric comparisons
GET /api/book?$filter=year gt 1990
GET /api/book?$filter=year ge 1990
GET /api/book?$filter=year lt 1991
GET /api/book?$filter=year le 1990

### Logical grouping
GET /api/book?$filter=year ge 1980 and year le 1990
GET /api/book?$filter=year le 1960 or title eq 'Hyperion'
GET /api/book?$filter=not (year le 1960)
GET /api/book?$filter=(year ge 1970 or title eq 'Foundation') and pages gt 400
```

### Supported operators (REST)

| Category | Operators | Example |
| --- | --- | --- |
| Comparison | `eq`, `ne`, `gt`, `ge`, `lt`, `le` | `year gt 1990` |
| Logical | `and`, `or`, `not` | `a eq 1 and b lt 5` |
| Grouping | `( )` | `(a eq 1 or b eq 2) and c ne 3` |

### Dates and datetimes

Use *unquoted* ISO 8601 UTC:

```
$filter=Date ge 2025-01-01T00:00:00Z and Date le 2025-01-05T00:00:00Z
```

Invalid forms:

```
$filter=Date ge '2025-01-01'          # ❌ quotes not allowed
$filter=Date ge datetime'2025-01-01'  # ❌ OData literal form not supported
```

If range logic causes complexity, match discrete points:

```
$filter=ClassId eq 2 and (
  Date eq 2025-01-01T00:00:00Z or
  Date eq 2025-01-02T00:00:00Z or
  Date eq 2025-01-03T00:00:00Z
)
```

### Implementation (REST)

Under the hood:

1. `$filter` text is prefixed (`?$filter=...`) and parsed by an OData URI Parser.
2. An abstract syntax tree (AST) is visited to:
   * Resolve exposed field names to backing columns.
   * Parameterize literal values (protects against injection).
   * Infer database types for parameters.
3. The resulting predicate composes with:
   * Authorization / database policy filters.
   * Pagination tie-break logic (keyset pagination).
   * Any GraphQL-like sorting expansions (for cross-endpoint consistency).

Malformed expressions trigger a `400 Bad Request` with a generic message (`$filter query parameter is not well formed.`) to avoid leaking parser internals.

> [!TIP]
> When combining filters with pagination, ensure an accompanying `$orderby` (or rely on implicit primary key ordering) for deterministic page boundaries.

### Stored procedures

For stored procedure entities, `$filter` is treated as a plain parameter key (not parsed into an AST). Unsupported usage results in a Bad Request.

---

## GraphQL: `filter` argument

Pattern (collection query):

```graphql
{
  books(
    filter: {
      or: [
        { title: { contains: "Foundation" } }
        { year: { gt: 1975 } }
      ]
    }
    orderBy: { year: ASC }
    first: 5
  ) {
    items { id title year }
    hasNextPage
    endCursor
  }
}
```

### Operator mapping

| Type | Operators |
| --- | --- |
| Scalar comparisons | `eq`, `neq`, `gt`, `gte`, `lt`, `lte`, `isNull` |
| String-specific | `contains`, `notContains`, `startsWith`, `endsWith` |
| Logical grouping | `and`, `or` (each takes arrays of sub-expressions) |

Example combining conditions:

```graphql
{
  authors(
    filter: {
      and: [
        { first_name: { eq: "Robert" } }
        { last_name: { eq: "Heinlein" } }
      ]
    }
    first: 1
  ) {
    items { first_name last_name }
  }
}
```

### Nested filtering

When filtering nested relationships (e.g., `authors { books(...) { ... }}`), each level’s filter executes in the context of its entity. DAB composes predicates and ensures the correct aliasing to avoid collisions.

### Implementation (GraphQL)

1. The GraphQL schema builder generates strongly-typed `*FilterInput` types.
2. Incoming filter arguments are parsed into a structured list of predicate objects.
3. Exposed names map to backing columns (supports mappings and case handling).
4. Database policy filters are appended.
5. Combined expression becomes a parameterized WHERE clause (or equivalent for the backing database, including Cosmos DB translation logic).

---

## Interaction with pagination and ordering

| Feature | REST | GraphQL |
| --- | --- | --- |
| Keyset pagination | Filter evaluated first, then cursor logic selects boundary row(s) | Filter shapes result set; `endCursor` built from last materialized row (including ordering fields + primary keys) |
| Need for deterministic ordering | Recommended to combine `$filter` + `$orderby` | Provide `orderBy` whenever returning more than a trivial subset |

Without explicit ordering, natural / primary key order is used, which is stable for many cases but less explicit.

---

## Performance guidance

| Approach | Impact |
| --- | --- |
| Narrow predicates with selective indexes (PK, unique, covering) | Reduces I/O and latency |
| Avoid leading wildcards in `contains`-like patterns (where supported) | Improves index utilization |
| Leverage projection (`$select` / GraphQL field sets) alongside filters | Shrinks row width, speeds serialization |
| Paginate early with `first` / `$first` | Prevents large intermediate result sets |

---

## Error handling matrix

| Cause | REST Response | GraphQL Response |
| --- | --- | --- |
| Unknown field | 400 (invalid field) | Validation error in `errors[]` |
| Unsupported operator | 400 | Validation / resolver error |
| Malformed syntax | 400 (`$filter query parameter is not well formed.`) | GraphQL error (BadRequest substatus) |
| Unauthorized field reference (policy) | 403 | Authorization error (may redact specifics) |

---

## Security model

* All literal values are parameterized.
* Field-level authorization applied *before* SQL emission.
* Database policy filters (claims-based, row-level style) are appended automatically.
* Attempts to smuggle operators via literals are blocked by strict parsing.

---

## Examples side-by-side

| Goal | REST | GraphQL |
| --- | --- | --- |
| Books with “Foundation” in title | `/api/book?$filter=title contains 'Foundation'` (string functions not yet in REST unless exposed via future extension—use equality/LIKE semantics where applicable) | `{ books(filter: { title: { contains: "Foundation" } }) { items { id title } } }` |
| Year between 1980–1990 | `/api/book?$filter=year ge 1980 and year le 1990` | `{ books(filter: { and: [ { year: { gte: 1980 } } { year: { lte: 1990 } } ] }) { items { id year } } }` |
| Null years only | `/api/book?$filter=year eq null` (use `isNull` style when added; current equality semantics vary by engine, prefer GraphQL) | `{ books(filter: { year: { isNull: true } }) { items { id } } }` |

> Implementation parity: The REST surface intentionally mirrors the OData comparison/logical set; GraphQL provides richer string predicates today.

---

## Tips

* URL-encode the entire `$filter` expression (`Uri.EscapeDataString` / `encodeURIComponent`).
* Keep filters deterministic; avoid relying on implicit casting.
* Use grouping parentheses to ensure intended precedence.

---

## Summary

Filtering in DAB is:

* Expressive (logical grouping, comparison operators, string predicates in GraphQL)
* Safe (parameterized, validated AST)
* Composable (works with projection, ordering, pagination, and policies)
* Consistent across database engines (translation layer abstracts differences)

Adopt filters early to reduce over-fetching and improve responsiveness.

---

## See also

* [$select](./select.md)
* [$orderby](./orderby.md)
* [$first](./first.md)
* [$after](./after.md)