# Relationships (GraphQL) — agent guide

Goal: reliably configure GraphQL navigation between entities using DAB’s `relationships` config and `dab update`.

Core facts (don’t guess):

- Relationships are configured under an entity’s `relationships` object.
- Required inputs:
  - `target.entity`
  - `cardinality`: `one` or `many`
- Optional but common:
  - `source.fields` / `target.fields` (direct mapping)
  - Many-to-many via a join table using `linking.object` and linking fields.
- REST does **not** support relationships (GraphQL-only).

## Decide the relationship shape

| Shape | Cardinality | Notes |
| --- | --- | --- |
| One-to-many | `many` | Parent → children |
| Many-to-one | `one` | Child → parent |
| Many-to-many (hidden join table) | `many` | Use `linking.*` to avoid exposing join table |
| Many-to-many (explicit join entity) | mix | Expose join table as entity; define two `one` relationships |

## CLI: direct relationship (no linking object)

Use when there’s an FK, or when mapping fields directly.

Command Prompt:

```cmd
dab update Book ^
  --relationship series ^
  --target.entity Series ^
  --cardinality one ^
  --relationship.fields "series_id:id"
```

Notes:

- `--relationship.fields` is a comma-separated list of `sourceField:targetField` pairs.

## CLI: many-to-many via linking object (join table not exposed)

Command Prompt:

```cmd
dab update Book ^
  --relationship authors ^
  --target.entity Author ^
  --cardinality many ^
  --relationship.fields "id:id" ^
  --linking.object "dbo.books_authors" ^
  --linking.source.fields "book_id" ^
  --linking.target.fields "author_id"
```

Interpretation:

- `relationship.fields` maps source↔target identity fields (often `id:id`).
- Linking fields map source→join and join→target.

## Reciprocal relationships (bi-directional traversal)

If you need navigation both directions, define a second relationship on the target entity that mirrors the join mapping.

Command Prompt:

```cmd
dab update Author ^
  --relationship books ^
  --target.entity Book ^
  --cardinality many ^
  --relationship.fields "id:id" ^
  --linking.object "dbo.books_authors" ^
  --linking.source.fields "author_id" ^
  --linking.target.fields "book_id"
```

## Validation and testing checklist

- Confirm both entities exist in `dab-config.json`.
- Confirm both entities have appropriate permissions for the role you’re testing.
- `dab validate -c dab-config.json`
- Run `dab start` and execute a nested GraphQL query.

## Common failure modes

- Missing entity: relationship points to an entity not present in config.
- Wrong cardinality: causes GraphQL shape mismatch.
- Field mismatch: `relationship.fields` uses wrong column names.
- Join mapping wrong: linking fields reversed.
- Permissions: relationship exists but role can’t read the target entity.
