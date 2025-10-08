---
title: Use $filter (REST)
description: Learn how to use the $filter query parameter in Data API builder (DAB) REST endpoints to express predicates, supported operators, and example translations to parameterized SQL.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/08/2025
# Customer Intent: As a developer, I want to filter datasets efficiently and safely using REST and understand the SQL produced by Data API builder.
---

# Filtering data in REST ($filter)

Filtering narrows large data sets to only the records you need. In REST, Data API builder (DAB) supports an OData-inspired `$filter` query parameter. Each filter compiles to parameterized SQL for safety and consistency.

## Quick glance

| Operator           | Meaning               |
| ------------------ | --------------------- |
| [`eq`](#eq)        | equal                 |
| [`ne`](#ne)        | not equal             |
| [`gt`](#gt)        | greater than          |
| [`ge`](#ge)        | greater than or equal |
| [`lt`](#lt)        | less than             |
| [`le`](#le)        | less than or equal    |
| [`and`](#and)      | logical AND           |
| [`or`](#or)        | logical OR            |
| [`not`](#not)      | logical NOT           |
| [`( )`](#grouping) | grouping              |

## `eq`

Equal to. Returns records where a field’s value exactly matches the provided literal or `null`.

In this example we are getting books where the title is equal to `'Dune'`, the available flag is true, the price is 20, the published date is January 1, 2024, and the rating is null.

```
GET /api/books?$filter=
  title eq 'Dune' and
  available eq true and
  price eq 20 and
  published_on eq 2024-01-01T00:00:00Z and
  rating eq null
```

> [!NOTE]
> `$filter` supports `eq null` and `ne null` directly for null comparisons.

### Resulting SQL

```sql
SELECT * FROM Books
WHERE title = 'Dune'
  AND available = 1
  AND price = 20
  AND published_on = '2024-01-01T00:00:00Z'
  AND rating IS NULL;
```

## `ne`

Not equal to. Returns records where a field’s value does not match the given literal or is not null.

In this example we are getting books where the title is not `'Foundation'`, the available flag is not false, the price is not zero, the published date is not December 31, 2023, and the rating is not null.

```
GET /api/books?$filter=
  title ne 'Foundation' and
  available ne false and
  price ne 0 and
  published_on ne 2023-12-31T00:00:00Z and
  rating ne null
```

> [!NOTE]
> When filtering on date or datetime fields in REST, use **unquoted** ISO 8601 UTC format (`yyyy-MM-ddTHH:mm:ssZ`).
> Quoted or OData-style formats are invalid.
>
> * Wrong: `$filter=Date ge '2025-01-01'`
> * Wrong: `$filter=Date ge datetime'2025-01-01'`
> * Correct: `$filter=Date ge 2025-01-01T00:00:00Z`

### Resulting SQL

```sql
SELECT * FROM Books
WHERE title <> 'Foundation'
  AND available <> 0
  AND price <> 0
  AND published_on <> '2023-12-31T00:00:00Z'
  AND rating IS NOT NULL;
```

## `gt`

Greater than. Returns records where a field’s value is strictly higher than the given literal.

In this example we are getting books whose title sorts alphabetically after `'A'`, the available flag is true, the price is greater than 10, and the published date is after January 1, 2020.

```
GET /api/books?$filter=
  title gt 'A' and
  available gt false and
  price gt 10 and
  published_on gt 2020-01-01T00:00:00Z
```

> [!NOTE]
> Always use the ISO 8601 UTC format (`yyyy-MM-ddTHH:mm:ssZ`) for date filters.

### Resulting SQL

```sql
SELECT * FROM Books
WHERE title > 'A'
  AND available > 0
  AND price > 10
  AND published_on > '2020-01-01T00:00:00Z';
```

## `ge`

Greater than or equal. Returns records where a field’s value is higher than or equal to the given literal.

In this example we are getting books whose title is `'A'` or later, the available flag is true, the price is at least 10, and the published date is on or after January 1, 2020.

```
GET /api/books?$filter=
  title ge 'A' and
  available ge false and
  price ge 10 and
  published_on ge 2020-01-01T00:00:00Z
```

### Resulting SQL

```sql
SELECT * FROM Books
WHERE title >= 'A'
  AND available >= 0
  AND price >= 10
  AND published_on >= '2020-01-01T00:00:00Z';
```

## `lt`

Less than. Returns records where a field’s value is strictly lower than the given literal.

In this example we are getting books whose title sorts before `'Z'`, the available flag is false, the price is less than 50, and the published date is before January 1, 2030.

```
GET /api/books?$filter=
  title lt 'Z' and
  available lt true and
  price lt 50 and
  published_on lt 2030-01-01T00:00:00Z
```

### Resulting SQL

```sql
SELECT * FROM Books
WHERE title < 'Z'
  AND available < 1
  AND price < 50
  AND published_on < '2030-01-01T00:00:00Z';
```

## `le`

Less than or equal. Returns records where a field’s value is lower than or equal to the given literal.

In this example we are getting books whose title sorts before or equal to `'Z'`, the available flag is true, the price is 100 or less, and the published date is on or before January 1, 2030.

```
GET /api/books?$filter=
  title le 'Z' and
  available le true and
  price le 100 and
  published_on le 2030-01-01T00:00:00Z
```

### Resulting SQL

```sql
SELECT * FROM Books
WHERE title <= 'Z'
  AND available <= 1
  AND price <= 100
  AND published_on <= '2030-01-01T00:00:00Z';
```

## `and`

Logical AND. Combines multiple conditions that must all be true for a record to match.

In this example we are getting books where the title is `'Dune'`, the available flag is true, the price is less than 50, the published date is after January 1, 2020, and the rating is null.

```
GET /api/books?$filter=
  title eq 'Dune' and
  available eq true and
  price lt 50 and
  published_on ge 2020-01-01T00:00:00Z and
  rating eq null
```

### Resulting SQL

```sql
SELECT * FROM Books
WHERE title = 'Dune'
  AND available = 1
  AND price < 50
  AND published_on >= '2020-01-01T00:00:00Z'
  AND rating IS NULL;
```

## `or`

Logical OR. Combines conditions where at least one must be true for a record to match.

In this example we are getting books where the title is `'Dune'` or the available flag is true or the price is greater than 20 or the published date is before January 1, 2025, or the rating is null.

```
GET /api/books?$filter=
  title eq 'Dune' or
  available eq true or
  price gt 20 or
  published_on lt 2025-01-01T00:00:00Z or
  rating eq null
```

### Resulting SQL

```sql
SELECT * FROM Books
WHERE title = 'Dune'
  OR available = 1
  OR price > 20
  OR published_on < '2025-01-01T00:00:00Z'
  OR rating IS NULL;
```

## `not`

Logical NOT. Negates a condition so records are returned only if the condition is false.

In this example we are getting all books that do **not** have the title `'Romance'`, are not unavailable, do not cost less than $10, were not published before January 1, 2020, and do not have a null rating.

```
GET /api/books?$filter=
  not (
    title eq 'Romance' and
    available eq false and
    price lt 10 and
    published_on lt 2020-01-01T00:00:00Z and
    rating eq null
  )
```

### Resulting SQL

```sql
SELECT * FROM Books
WHERE NOT (
  title = 'Romance'
  AND available = 0
  AND price < 10
  AND published_on < '2020-01-01T00:00:00Z'
  AND rating IS NULL
);
```

## `( )` grouping

Groups sub-expressions so you can control evaluation order in complex filters.

In this example we are getting books where the title is either `'Fiction'` or `'SciFi'`, and the book is either available or priced below $25, and the published date is after January 1, 2020, and the rating is null.

```
GET /api/books?$filter=
  (title eq 'Fiction' or title eq 'SciFi') and
  (available eq true or price lt 25) and
  published_on ge 2020-01-01T00:00:00Z and
  rating eq null
```

### Resulting SQL

```sql
SELECT * FROM Books
WHERE (title = 'Fiction' OR title = 'SciFi')
  AND (available = 1 OR price < 25)
  AND published_on >= '2020-01-01T00:00:00Z'
  AND rating IS NULL;
```
