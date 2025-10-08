---
title: Use $select to shape REST payloads
description: Learn how to use $select to project specific fields in REST queries and how selection works in GraphQL.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/07/2025
# Customer Intent: As a developer, I want to reduce payload size and surface only allowed columns.
---

# Select projection in REST and GraphQL

Projection helps you return only what your client actually needs. Smaller payloads improve performance, reduce network costs, and can accelerate client-side processing. Data API builder (DAB) implements projection for:

* REST: via the `$select` query parameter.
* GraphQL: through the natural GraphQL field selection set.

> [!NOTE]
> All REST query parameter names (including `$select`) are case sensitive.

## REST: `$select`

Pattern:

```
GET /api/{entity}?$select=FieldA,FieldB,FieldC
```

Examples:

```http
### Return all accessible fields
GET /api/author

### Return only first_name
GET /api/author?$select=first_name

### Return only first_name and last_name
GET /api/author?$select=first_name,last_name
```

### Validation & errors

| Scenario | Behavior |
| --- | --- |
| Field does not exist | `400 Bad Request` (example message: `Invalid field to be returned requested: content`) |
| Field exists but caller lacks permission (excluded or not granted) | `403 Forbidden` |
| Mixed valid + invalid fields | Entire request fails (atomic validation) |
| Duplicate field names | Deduplicated logically (harmless) |
| Empty `$select=` (no value) | Treated as invalid → `400 Bad Request` |

> [!NOTE]
> The engine validates against the entity’s effective field list (includes `include`/`exclude` and role-based field permissions).

### Interaction with composite primary keys

You are not required to project primary key fields. If you omit some or all primary key columns, they are omitted from the response (tests confirm behavior for composite keys). Internally, DAB may still fetch those columns to:
* Enforce security policies
* Build pagination cursors (`$after` / `nextLink`)
* Tie-break ordered sets

Those internally fetched columns are stripped before the final response unless you explicitly requested them.

### Interaction with `$orderby` and pagination

When you combine `$select` with `$orderby` or pagination (`$first` / `$after`):

1. DAB may add order-by columns and primary key columns to the underlying SQL query even if not in `$select`.
2. It calculates the pagination cursor (`$after`) using those values.
3. It removes the unrequested extra fields before forming the `value` array.

This is why you can safely write:

```http
GET /api/book?$select=id,title&$orderby=publisher_id
```

…and receive only `id` and `title` even though `publisher_id` was needed internally.

### Stored procedures

For stored procedure–backed entities, `$select` is not interpreted as a projection clause. Arbitrary query string keys are passed as parameters (and unsupported names may fail validation depending on the procedure definition).

### Security considerations

Projection helps avoid accidental data exposure, but it **does not** override your role/field permissions. If a client attempts to project a disallowed field, the request fails (403) rather than silently dropping that field—making misconfiguration visible early.

### Performance characteristics

* Database query only retrieves projected (and minimal supporting) columns.
* Reduced network transfer and serialization overhead.
* Columns required for cursor construction are still fetched—but trimmed post-processing.

---

## GraphQL projection

GraphQL always uses *explicit selection sets*:

```graphql
query {
  books(first: 5) {
    items {
      id
      title
    }
  }
}
```

Differences vs REST `$select`:

| Aspect | REST `$select` | GraphQL |
| --- | --- | --- |
| Syntax | Comma-delimited query parameter | Field selection set |
| Validation | Fails if any field invalid | GraphQL validation phase rejects unknown fields |
| Unauthorized field | 403 (REST pipeline) | Authorization error surfaced in GraphQL errors |
| Extra internal fields for pagination | Removed before response | Added implicitly to build `endCursor`, not exposed |

> [!NOTE]
> In GraphQL, requesting nothing (empty selection) is invalid. You must specify at least one field under each object type.

### Nested relationships

GraphQL lets you project nested relationships selectively without additional parameters:

```graphql
{
  authors(
    filter: { or: [{ first_name: { eq: "Isaac" } } { last_name: { eq: "Asimov" } }] }
    orderBy: { last_name: ASC }
    first: 10
  ) {
    items {
      first_name
      last_name
      books(orderBy: { year: ASC }) {
        items {
          title
          year
        }
      }
    }
  }
}
```

Only the listed fields per object materialize.

## Best practices

| Goal | Recommendation |
| --- | --- |
| Minimize over-fetching REST data | Always supply `$select` for mobile or latency-sensitive scenarios |
| Consistent pagination | Include stable ordering (`$orderby` or GraphQL `orderBy`) when you paginate |
| Security hardening | Combine projection with least-privilege field permissions |
| Backward compatibility | Add new nullable columns—clients using `$select` are unaffected until they opt-in |
| Large pages | Use `$first` or `first` plus projection to keep row count and column count aligned with UX needs |

## Common pitfalls

| Pitfall | How to avoid |
| --- | --- |
| 400 due to a typo | Double‑check case (case sensitive) |
| 403 unexpected | Verify role’s field permissions and recent hot-reload changes |
| Cursor mismatch after schema changes | Regenerate clients or refresh pagination flows when key/order fields change |
| Assuming `$select=*` works | Not supported—omit `$select` to get full allowed shape |

## Troubleshooting checklist

1. Remove `$select` — does the query work? If yes, a listed field is invalid or unauthorized.
2. Try projecting a single field at a time to isolate the problematic one.
3. Verify the entity’s configuration (`include` / `exclude` / mappings).
4. Confirm no recent permission hot reload removed access.
5. If paginating, ensure `$orderby` columns still exist and are not excluded.

## Summary

Projection in DAB is:

* Explicit (`$select` for REST, field sets for GraphQL)
* Secure (fails fast on invalid or unauthorized fields)
* Pagination-aware (internal augmentation stripped before return)
* Performance-focused (fetches only what’s required)

Use it early in API design to keep responses lean, intentional, and stable.

[!INCLUDE[See also](includes/see-also.md)]

