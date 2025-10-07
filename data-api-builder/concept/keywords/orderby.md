---
title: Use $orderby (REST) and orderBy (GraphQL)
description: Learn how to sort results, tie-break with primary keys, and understand pagination implications in Data API builder.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/07/2025
# Customer Intent: As a developer, I want predictable sorted pages and stable cursors.
---

# Ordering (sorting) results

Ordering defines the sequence of returned records and underpins *stable pagination*. Data API builder (DAB) supports sorting via:

* REST: `$orderby`
* GraphQL: `orderBy`

> [!NOTE]
> If you do not specify ordering, DAB defaults to primary key order (ascending). For composite primary keys, component order follows the database definition.

## REST: `$orderby`

Pattern:

```
GET /api/{entity}?$orderby=FieldA [asc|desc], FieldB desc, FieldC
```

Examples:

```http
### Ascending (implicit)
GET /api/book?$orderby=title

### Explicit ascending
GET /api/book?$orderby=title asc

### Descending
GET /api/book?$orderby=title desc

### Multi-field
GET /api/book?$orderby=year desc, title asc

### Tie-breaking with different directions
GET /api/book?$orderby=pages asc, title desc
```

Rules:

| Rule | Detail |
| --- | --- |
| Delimiter | Comma + optional whitespace |
| Direction keywords | `asc` (default), `desc` |
| Case sensitivity | Field names are case sensitive; direction tokens are case insensitive in practice but use lowercase for clarity |
| Unknown field | Returns `400 Invalid orderby column requested` |
| Unsupported syntax (functions, expressions) | Returns `400 OrderBy property is not supported.` |

### Interaction with `$select`

If you sort by a field not in `$select`, the engine still fetches it internally (to compute order and cursor) but strips it from the final `value` array. You only see what you projected.

### Primary key augmentation

For consistent pagination, DAB ensures that all primary key columns are ultimately part of the ordering sequence (even if you do not list them):

1. User-specified order columns (in declared order).
2. Remaining primary key columns appended (ascending) as deterministic tie-breakers.

This guarantees uniqueness of ordering slots and stable cursor formation.

### Pagination effect

When `$first` + `$orderby` are combined, DAB requests one extra row (N+1) to detect `hasNextPage`. The cursor (`$after` token) is built from:

* Ordered fields (including direction)
* Any remaining primary key fields

These values are serialized to a base64 representation (opaque to clients).

---

## GraphQL: `orderBy`

Pattern:

```graphql
{
  books(orderBy: { year: DESC, title: ASC }, first: 10) {
    items { id title year }
    endCursor
    hasNextPage
  }
}
```

Key behaviors:

| Aspect | Behavior |
| --- | --- |
| Input type | Generated `*OrderByInput` enumerating built-in scalar fields |
| Direction enum | `ASC`, `DESC` (null means “ignore field”) |
| Composite ordering | Order of object fields defines precedence |
| Tie-breaking | Remaining primary key columns appended automatically |
| Null directive | Supplying a field with `null` direction effectively removes it (`title: null`) |

Example ignoring a field:

```graphql
{
  books(orderBy: { title: null, id: DESC }) {
    items { id title }
  }
}
```

### Invalid structures

GraphQL forbids including logical operators (`or`, `and`) inside `orderBy` for lists; providing them yields a validation or resolver error (tests confirm error paths such as `books(orderBy: { or: { id: ASC } })`).

### Variables example

```graphql
query ($dir: OrderBy) {
  books(first: 4, orderBy: { id: $dir }) {
    items { id title }
  }
}
```

Variables:

```json
{ "dir": "DESC" }
```

---

## Internal implementation details

| Step | REST | GraphQL |
| --- | --- | --- |
| Parse | OData `OrderByClause` | Input object traversal |
| Resolve names | Exposed → backing columns | Exposed → backing columns (supports mappings) |
| Validate | Unknown column → 400 | Unknown field → GraphQL validation error |
| Append PKs | Yes (if not already present) | Yes (remaining PKs appended) |
| Cursor composition | Uses ordering columns + PK | Same |

GraphQL’s resolver ensures the `orderBy` argument is processed *before* pagination limit adjustments (`first + 1` when `endCursor`/`hasNextPage` requested).

### Cosmos DB considerations

For Cosmos DB (NoSQL), ordering translation supports scalar paths. Null directions are skipped, and PK addition ensures stable continuation across physical partitions.

---

## Example: deterministic pagination

| Goal | REST | GraphQL |
| --- | --- | --- |
| Page by year then title | `/api/book?$orderby=year desc, title asc&$first=5` | `{ books(orderBy: { year: DESC, title: ASC }, first: 5) { ... } }` |
| Multi-key tie-break (composite pk) | Omit pk in `$orderby`; DAB appends automatically | Same; pk columns added implicitly |
| Remove unstable ordering artifact | Avoid computed / mapped expressions; rely on stored columns | Do not supply non-deterministic resolver fields in `orderBy` |

---

## Error handling quick reference

| Condition | REST Response | GraphQL Response |
| --- | --- | --- |
| Invalid column | 400 | Validation error |
| Unsupported token (function) | 400 | Validation error |
| Mixed valid / invalid columns | 400 | Entire argument rejected |
| Null direction text (e.g., `title foo`) | 400 | Validation error |

---

## Best practices

| Scenario | Recommendation |
| --- | --- |
| Infinite scroll | Always define explicit multi-field ordering including a stable, unique final key (pk) |
| Large “top N” dashboards | Use descending ordering on indexed/date columns + projection |
| Reordering risk | Avoid changing column semantics or pk shape without versioning the client |
| Reducing cursor size | Order by minimal number of necessary columns (pk appended anyway) |

---

## Inspecting / debugging a cursor

While cursors are opaque, for troubleshooting you can base64-decode them locally. Structure is an array of JSON objects:

```json
[
  { "EntityName":"Book","FieldName":"year","FieldValue":1999,"Direction":0 },
  { "EntityName":"Book","FieldName":"id","FieldValue":42,"Direction":0 }
]
```

`Direction`: `0` = ASC, `1` = DESC.

> [!CAUTION]
> Clients must treat tokens as opaque—never construct or modify them manually.

---

## Summary

Stable ordering is foundational for:

* Correct, gapless pagination
* Predictable UI sorting
* Cache friendliness
* Consistent “resume where you left off” flows

Specify order intentionally; rely on automatic primary key augmentation to finalize determinism.

---

## See also

* [$first](./first.md)
* [$after](./after.md)
* [$filter](./filter.md)
* [$select](./select.md)