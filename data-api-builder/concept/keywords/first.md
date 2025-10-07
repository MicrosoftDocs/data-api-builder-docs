---
title: Use $first (REST) and first (GraphQL)
description: Learn how to control page size limits, leverage -1 for maximum pages, and understand validation for pagination size in Data API builder.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/07/2025
# Customer Intent: As a developer, I want to page efficiently and respect server limits.
---

# Limiting page size with `$first` / `first`

Pagination prevents overwhelming clients or servers by slicing large result sets. Data API builder (DAB) uses a *cursor-based* model that requires a stable ordering and a request-specified (or default) page size.

## Overview

| Concept | Description |
| --- | --- |
| Default page size | `runtime.pagination.default-page-size` (defaults to 100) |
| Max page size | `runtime.pagination.max-page-size` (defaults to 100000) |
| Client override | `$first` (REST) / `first` (GraphQL) |
| Requesting max | Pass `-1` to request the configured max page size |
| Cursor token | `$after` / `after` (opaque base64) obtains next slice |
| Engine probe | DAB fetches `limit + 1` rows to detect `hasNextPage` |

> [!NOTE]
> If neither `$first` nor `first` is supplied, the default page size applies automatically.

---

## REST usage

Pattern:

```
GET /api/{entity}?$first=N
```

Examples:

```http
### First 5 books
GET /api/book?$first=5

### Request the configured maximum (max-page-size)
GET /api/book?$first=-1

### Combine with orderBy
GET /api/book?$first=10&$orderby=title asc

### Use continuation
GET /api/book?$first=10&$after={cursor}
```

Validation:

| Input | Result |
| --- | --- |
| Omitted | Uses default-page-size |
| Positive integer > 0 and ≤ max | Accepted |
| `-1` | Expanded to max-page-size |
| `0` | 400 (invalid) |
| `< -1` | 400 |
| `> max-page-size` | 400 |

Error message example (REST / GraphQL share logic):
```
Invalid number of items requested, first argument must be either -1 or a positive number within the max page size limit of {Max}. Actual value: {value}
```

### Response shape (paginated)

```json
{
  "value": [
    { "id": 1, "title": "A" },
    { "id": 2, "title": "B" }
  ],
  "nextLink": "https://host/api/book?$first=2&$after=eyJ...=="
}
```

If fewer than or equal to the requested number of rows remain (no extra probe row), `nextLink` is omitted.

---

## GraphQL usage

Pattern:

```graphql
{
  books(first: 5) {
    items { id title }
    endCursor
    hasNextPage
  }
}
```

Request maximum page:

```graphql
{
  books(first: -1) {
    items { id title }
    endCursor
    hasNextPage
  }
}
```

Fetch subsequent page:

```graphql
{
  books(first: 5, after: "eyJ...==") {
    items { id title }
    endCursor
    hasNextPage
  }
}
```

### Connection fields

| Field | Description |
| --- | --- |
| `items` | Page of results (trimmed to requested size) |
| `hasNextPage` | True if additional records exist |
| `endCursor` | Opaque cursor to resume after this page |

> If `hasNextPage` is `false`, `endCursor` may be `null` (or safely ignored).

---

## Cursor construction logic (summary)

Internally, pagination uses **keyset pagination**, not offset. The engine collects:

1. All explicit `orderBy` columns (with direction).
2. Remaining primary key columns (tie-breakers).
3. The last row’s values for those columns.
4. Serializes them into a JSON array:
   ```json
   [
     { "EntityName":"Book","FieldName":"year","FieldValue":1999,"Direction":0 },
     { "EntityName":"Book","FieldName":"id","FieldValue":42,"Direction":0 }
   ]
   ```
5. Base64 encodes the JSON to produce the cursor.

On the next request, that token is decoded, validated, and transformed into the WHERE predicate that advances the window.

> [!IMPORTANT]
> Treat the cursor as opaque. Changing it may result in 400 errors or inconsistent paging.

---

## Engine safeguards

| Safeguard | Purpose |
| --- | --- |
| Validation of `first` range | Prevent abuse / excessive load |
| Max response size enforcement (MB) | Protects memory and bandwidth (suggests using pagination) |
| Automatic tie-break injection (PK columns) | Ensures deterministic ordering |
| Fetch N+1 strategy | Reliable hasNext detection without counting entire set |

---

## Interactions with other parameters

| Feature | Interaction |
| --- | --- |
| `$orderby` / `orderBy` | Strongly recommended; else pk order is used |
| `$filter` / `filter` | Applied before pagination windowing |
| `$select` | Does not affect pagination logic; cursor fields may be fetched invisibly |
| Policies / auth filters | Included in predicate, limiting the visible dataset boundary |

---

## Frequently asked questions

| Question | Answer |
| --- | --- |
| Why not offset-based pagination? | Keyset (cursor) pagination avoids skipped/duplicated rows on concurrent inserts/deletes. |
| Can I jump to page 10? | Not directly; iterate using returned cursors (design aligns with large scale datasets). |
| Can I request all rows? | Use repeated pagination or an ETL path; large single responses risk hitting max response size. |
| Why does `first: -1` sometimes return fewer rows than I expect? | It’s capped by `max-page-size` and may also stop early if hitting response size limits (MB). |
| Will altering sort order break cursors? | Yes—cursors encode ordering context; change order → restart from beginning. |

---

## Troubleshooting

| Symptom | Possible Cause | Resolution |
| --- | --- | --- |
| 400 invalid number of items | Value was 0, < -1, or > max | Adjust within range or set `-1` |
| Missing `nextLink` / `hasNextPage=false` unexpectedly | Sort order changed mid-sequence | Restart pagination with new order |
| Duplicate rows across pages | Non-deterministic ordering (missing pk tie-break) | Add explicit order fields; engine appends PK automatically, ensure stable data |
| Large response truncated by error | Exceeded max response size | Use smaller `first` or narrower `$select` |

---

## Best practices

| Goal | Practice |
| --- | --- |
| Infinite scroll | Small `first` (e.g., 20–50) + explicit ordering |
| Admin exports | Batch through pages, store last cursor, resume on failure |
| Mobile optimization | Combine small `first` with projection `$select` / reduced selection sets |
| Consistency post-deploy | Avoid changing primary key or adding ambiguous ordering fields until clients discard old cursors |

---

## Summary

`$first` / `first` provides precise, predictable pagination:

* Validated sizes with `-1` shortcut
* Keyset-based stability
* Efficient detection of further pages
* Security and performance aware

Adopt cursors for scalable, race-condition-resistant traversal of large tables.

---

## See also

* [$after](./after.md)
* [$orderby](./orderby.md)
* [$filter](./filter.md)
* [$select](./select.md)