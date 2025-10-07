---
title: Use $after (REST) and after (GraphQL)
description: Learn how cursor-based pagination works, how continuation tokens are formed, and how to safely request subsequent pages.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/07/2025
# Customer Intent: As a developer, I want to reliably fetch subsequent pages without duplicates or gaps.
---

# Continuation tokens with `$after` / `after`

The `$after` (REST) and `after` (GraphQL) parameters carry an *opaque cursor* that tells the server where the previous page ended. Data API builder (DAB) uses **keyset pagination**, avoiding the pitfalls of numeric offsets (skipped or duplicated rows under concurrent data changes).

## Lifecycle

1. Client requests first page (with or without size limit).
2. DAB returns:
   * Page of results
   * Continuation pointer:
     * REST: `nextLink` URL containing `$after={token}`
     * GraphQL: `endCursor` string (plus `hasNextPage`)
3. Client copies the token into the next request’s `$after` / `after`.
4. Repeat until:
   * `nextLink` absent (REST) or `hasNextPage=false` (GraphQL).

> [!NOTE]
> Tokens are *opaque*. Do not construct or edit them manually.

---

## REST example

Initial page:

```http
GET /api/products?$first=3
```

Sample response:

```json
{
  "value": [
    { "id": 1, "name": "Item A" },
    { "id": 2, "name": "Item B" },
    { "id": 3, "name": "Item C" }
  ],
  "nextLink": "/api/products?$first=3&$after=eyJpZCI6MywidHMiOjE3MDA4MDg1NTU1fQ=="
}
```

Next page:

```http
GET /api/products?$first=3&$after=eyJpZCI6MywidHMiOjE3MDA4MDg1NTU1fQ==
```

If the server is configured with `next-link-relative=true`, the `nextLink` value is a relative path; otherwise it is an absolute URL.

---

## GraphQL example

First page:

```graphql
query {
  products(first: 3) {
    items { id name }
    hasNextPage
    endCursor
  }
}
```

Next page:

```graphql
query {
  products(first: 3, after: "eyJpZCI6MywidHMiOjE3MDA4MDg1NTU1fQ==") {
    items { id name }
    hasNextPage
    endCursor
  }
}
```

---

## Cursor construction (internal)

Internally, a cursor is:

1. A JSON array of “pagination columns” in priority order:
   * All user-specified ordering fields (with direction)
   * Remaining primary key columns (tie-break)
2. Each element describes:
   ```json
   {
     "EntityName": "Book",
     "FieldName": "id",
     "FieldValue": 42,
     "Direction": 0
   }
   ```
   `Direction`: `0` = ASC, `1` = DESC.
3. The array is serialized and base64 encoded.

Example decoded (illustrative):

```json
[
  { "EntityName":"Book","FieldName":"year","FieldValue":1999,"Direction":0 },
  { "EntityName":"Book","FieldName":"id","FieldValue":42,"Direction":0 }
]
```

> [!WARNING]
> Any change to ordering rules, primary key definition, or field mappings invalidates previously issued cursors.

---

## Validation on input

When a request supplies `$after` / `after`:

* The base64 payload is decoded.
* JSON deserialized into expected structure.
* Fields checked against entity metadata (exposed → backing columns).
* Types validated and converted.
* A keyset predicate is generated:
  * Accounts for ordering direction
  * Expands composite comparisons lexicographically

Invalid tokens yield `400 Bad Request` (REST) or GraphQL error responses (BadRequest substatus).

---

## Handling “end of data”

| Indicator | REST | GraphQL |
| --- | --- | --- |
| More pages exist | `nextLink` present | `hasNextPage = true` |
| No more pages | `nextLink` absent | `hasNextPage = false` (cursor may be null) |

---

## Differences vs offset pagination

| Dimension | Keyset (DAB) | Offset (not used) |
| --- | --- | --- |
| Concurrent inserts/deletes | Stable (no gaps/dupes) | Gaps and duplicates possible |
| Large offsets performance | Efficient (index seek) | Degrades (skips many rows) |
| Token size | Cursor + PK values | Single integer |
| Replaying with changed ordering | Unsafe (invalidate token) | Recomputes but may shift rows |

---

## Common scenarios

| Scenario | Approach |
| --- | --- |
| Infinite scroll | Keep requesting `nextLink` / `endCursor` until exhaustion |
| Resume after interruption | Persist the last token client-side, resume later |
| Backward navigation | Not supported directly—store prior cursors if needed |
| Changing sort mid-stream | Restart at page 1 (discard old tokens) |
| Real-time feeds | Use stable ordering (e.g., created timestamp, then PK) |

---

## Error conditions

| Cause | Symptom | Resolution |
| --- | --- | --- |
| Malformed base64 | 400 / GraphQL error | Discard token, restart |
| Missing required ordering field (schema change) | 400 | Issue fresh initial page request |
| Field type mismatch | 400 | Ensure tokens from same version of schema |
| Tampered token | 400 | Treat tokens as opaque |

---

## Best practices

| Goal | Practice |
| --- | --- |
| Minimal token churn | Avoid re-sorting between pages |
| Multi-user consistency | Base ordering on immutable columns (e.g., PK, created date) |
| Large datasets | Use narrow projections + selective ordering columns |
| Caching integration | Include hash of ordering in client cache key, not the raw cursor |
| Debugging | Base64 decode only in secure tooling—never in production clients |

---

## Use with `$first` / `first`

The combination defines a *window*: first N rows strictly greater (or less, for DESC) than the last cursor row in lexical ordering. If a record is updated so its ordering columns move before the cursor, it will *not* appear in subsequent pages (expected for keyset semantics).

---

## Security considerations

* Token contains only exposed column values (filtered to safe fields).
* Parameterization prevents injection (values not executed as code).
* Relative `nextLink` toggled by configuration—supports reverse proxies.

---

## Troubleshooting decision tree

1. **No `nextLink` / `hasNextPage=false` sooner than expected?**  
   *Was `first` smaller than intended?* Increase page size (within limits).
2. **400 after upgrade?**  
   *Schema or mapping changed.* Start a fresh pagination cycle.
3. **Duplicate first item of next page?**  
   Check for unstable ordering (missing secondary order or non-deterministic computed column).
4. **Records “skipped”?**  
   Were rows inserted *before* the cursor boundary? Keyset pagination doesn’t retroactively include them—design for append-only readers if necessary.

---

## Summary

`$after` / `after` delivers:

* Stable, race-resistant pagination
* Opaque, self-contained continuation state
* Deterministic ordering with automatic PK tie-break
* Efficient index-driven traversal

Adopt it for scalable data browsing patterns.

---

## See also

* [$first](./first.md)
* [$orderby](./orderby.md)
* [$filter](./filter.md)
* [$select](./select.md)