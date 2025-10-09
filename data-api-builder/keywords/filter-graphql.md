---
title: Use filter (GraphQL)
description: Learn how to use the filter argument in Data API builder (DAB) GraphQL queries to express predicates, supported operators, and example translations to parameterized SQL.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/08/2025
# Customer Intent: As a developer, I want to filter datasets efficiently and safely using GraphQL and understand the SQL produced by Data API builder.
---

# Filtering data in GraphQL (`filter`)

Filtering narrows large datasets to only the records you need. In GraphQL, Data API builder (DAB) supports a structured `filter` argument on entity queries. Each filter compiles to parameterized SQL for safety and consistency.

> [!NOTE]
> GraphQL filtering supports comparison, logical, string pattern, membership, and null operators.
> GraphQL filters use structured input objects: `{ fieldName: { operator: value } }`.
> Dates must be valid ISO 8601 UTC strings.
> Null checks use `isNull` instead of `eq null`.

## Quick glance

| Operator                              | Meaning               |
| ------------------------------------- | --------------------- |
| [`eq`](#eq-graphql)                   | equal                 |
| [`neq`](#neq-graphql)                 | not equal             |
| [`gt`](#gt-graphql)                   | greater than          |
| [`gte`](#gte-graphql)                 | greater than or equal |
| [`lt`](#lt-graphql)                   | less than             |
| [`lte`](#lte-graphql)                 | less than or equal    |
| [`and`](#and-graphql)                 | logical AND           |
| [`or`](#or-graphql)                   | logical OR            |
| [`contains`](#contains-graphql)       | substring match       |
| [`notContains`](#notcontains-graphql) | not substring match   |
| [`startsWith`](#startswith-graphql)   | prefix match          |
| [`endsWith`](#endswith-graphql)       | suffix match          |
| [`in`](#in-graphql)                   | membership            |
| [`isNull`](#isnull-graphql)           | null check            |

## `eq` {#eq-graphql}

Equal to. Returns records where a field’s value exactly matches the provided literal or is null if using `isNull`.

> [!NOTE]
> When filtering on date or datetime fields, use **unquoted** ISO 8601 UTC format (`yyyy-MM-ddTHH:mm:ssZ`).
> Quoted or OData-style formats are invalid.
>
> * Wrong: `$filter=Date ge '2025-01-01'`
> * Wrong: `$filter=Date ge datetime'2025-01-01'`
> * Correct: `$filter=Date ge 2025-01-01T00:00:00Z`

In this example, we're getting books where the title is `'Dune'`, the available flag is true, the price is 20, the published date is January 1, 2024, and the rating is null.

```graphql
query {
  books(filter: {
    and: [
      { title: { eq: "Dune" } }
      { available: { eq: true } }
      { price: { eq: 20 } }
      { publishedOn: { eq: "2024-01-01T00:00:00Z" } }
      { rating: { isNull: true } }
    ]
  }) {
    items { id title available price publishedOn rating }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, available, price, publishedOn, rating
FROM Books
WHERE title = 'Dune'
  AND available = 1
  AND price = 20
  AND publishedOn = '2024-01-01T00:00:00Z'
  AND rating IS NULL;
```

## `neq` {#neq-graphql}

Not equal to. Returns records where a field’s value doesn’t match the literal or isn’t null when combined with `isNull: false`.

In this example, we're getting books where the title isn't `'Foundation'`, the available flag isn't false, the price isn't zero, the published date isn't December 31, 2023, and the rating isn't null.

```graphql
query {
  books(filter: {
    and: [
      { title: { neq: "Foundation" } }
      { available: { neq: false } }
      { price: { neq: 0 } }
      { publishedOn: { neq: "2023-12-31T00:00:00Z" } }
      { rating: { isNull: false } }
    ]
  }) {
    items { id title available price publishedOn rating }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, available, price, publishedOn, rating
FROM Books
WHERE title <> 'Foundation'
  AND available <> 0
  AND price <> 0
  AND publishedOn <> '2023-12-31T00:00:00Z'
  AND rating IS NOT NULL;
```

## `gt` {#gt-graphql}

Greater than. Returns records where a field’s value is strictly higher than the provided literal.

In this example, we're getting books whose title sorts alphabetically after `'A'`, the available flag is true, the price is greater than 10, and the published date is after January 1, 2020.

```graphql
query {
  books(filter: {
    and: [
      { title: { gt: "A" } }
      { available: { gt: false } }
      { price: { gt: 10 } }
      { publishedOn: { gt: "2020-01-01T00:00:00Z" } }
    ]
  }) {
    items { id title available price publishedOn }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, available, price, publishedOn
FROM Books
WHERE title > 'A'
  AND available > 0
  AND price > 10
  AND publishedOn > '2020-01-01T00:00:00Z';
```

## `gte` {#gte-graphql}

Greater than or equal to. Returns records where a field’s value is higher than or equal to the given literal.

In this example, we're getting books whose title is `'A'` or later, the available flag is true, the price is at least 10, and the published date is on or after January 1, 2020.

```graphql
query {
  books(filter: {
    and: [
      { title: { gte: "A" } }
      { available: { gte: false } }
      { price: { gte: 10 } }
      { publishedOn: { gte: "2020-01-01T00:00:00Z" } }
    ]
  }) {
    items { id title available price publishedOn }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, available, price, publishedOn
FROM Books
WHERE title >= 'A'
  AND available >= 0
  AND price >= 10
  AND publishedOn >= '2020-01-01T00:00:00Z';
```

## `lt` {#lt-graphql}

Less than. Returns records where a field’s value is strictly lower than the given literal.

In this example, we're getting books whose title sorts before `'Z'`, the available flag is false, the price is less than 50, and the published date is before January 1, 2030.

```graphql
query {
  books(filter: {
    and: [
      { title: { lt: "Z" } }
      { available: { lt: true } }
      { price: { lt: 50 } }
      { publishedOn: { lt: "2030-01-01T00:00:00Z" } }
    ]
  }) {
    items { id title available price publishedOn }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, available, price, publishedOn
FROM Books
WHERE title < 'Z'
  AND available < 1
  AND price < 50
  AND publishedOn < '2030-01-01T00:00:00Z';
```

## `lte` {#lte-graphql}

Less than or equal to. Returns records where a field’s value is lower than or equal to the given literal.

In this example, we're getting books whose title sorts before or equal to `'Z'`, the available flag is true, the price is 100 or less, and the published date is on or before January 1, 2030.

```graphql
query {
  books(filter: {
    and: [
      { title: { lte: "Z" } }
      { available: { lte: true } }
      { price: { lte: 100 } }
      { publishedOn: { lte: "2030-01-01T00:00:00Z" } }
    ]
  }) {
    items { id title available price publishedOn }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, available, price, publishedOn
FROM Books
WHERE title <= 'Z'
  AND available <= 1
  AND price <= 100
  AND publishedOn <= '2030-01-01T00:00:00Z';
```

## `and` {#and-graphql}

Logical AND. Combines multiple predicates that must all be true for a record to match.

In this example, we’re getting books that are available, cost less than 30, and were published after January 1, 2022.

```graphql
query {
  books(filter: {
    and: [
      { available: { eq: true } }
      { price: { lt: 30 } }
      { publishedOn: { gt: "2022-01-01T00:00:00Z" } }
    ]
  }) {
    items { id title available price publishedOn }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, available, price, publishedOn
FROM Books
WHERE available = 1
  AND price < 30
  AND publishedOn > '2022-01-01T00:00:00Z';
```

## `or` {#or-graphql}

Logical OR. Returns records where at least one predicate in the array evaluates to true.

In this example, we’re getting books that are either out of stock or priced above 50.

```graphql
query {
  books(filter: {
    or: [
      { available: { eq: false } }
      { price: { gt: 50 } }
    ]
  }) {
    items { id title available price }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, available, price
FROM Books
WHERE available = 0
   OR price > 50;
```

## `contains` {#contains-graphql}

Substring match. Returns records where the field contains the provided substring (case sensitivity depends on the database collation).

In this example, we’re getting books whose title includes the word “Dune.”

```graphql
query {
  books(filter: { title: { contains: "Dune" } }) {
    items { id title }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title
FROM Books
WHERE title LIKE '%Dune%';
```

## `notContains` {#notcontains-graphql}

Negative substring match. Returns records where the field does **not** contain the provided substring.

In this example, we’re getting books whose title doesn’t include “Guide.”

```graphql
query {
  books(filter: { title: { notContains: "Guide" } }) {
    items { id title }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title
FROM Books
WHERE title NOT LIKE '%Guide%';
```

## `startsWith` {#startswith-graphql}

Prefix match. Returns records where the field begins with the provided string.

In this example, we’re getting books whose title starts with “The.”

```graphql
query {
  books(filter: { title: { startsWith: "The" } }) {
    items { id title }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title
FROM Books
WHERE title LIKE 'The%';
```

## `endsWith` {#endswith-graphql}

Suffix match. Returns records where the field ends with the provided string.

In this example, we’re getting books whose title ends with “Chronicles.”

```graphql
query {
  books(filter: { title: { endsWith: "Chronicles" } }) {
    items { id title }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title
FROM Books
WHERE title LIKE '%Chronicles';
```

## `in` {#in-graphql}

Membership match. Returns records where the field’s value exists in the provided list.

In this example, we’re getting books whose genre is either “SciFi” or “Fantasy.”

```graphql
query {
  books(filter: { genre: { in: ["SciFi", "Fantasy"] } }) {
    items { id title genre }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, genre
FROM Books
WHERE genre IN ('SciFi', 'Fantasy');
```

## `isNull` {#isnull-graphql}

Null check. Returns records where a field’s value is either null or not null depending on the boolean literal.

In this example, we're getting books where the rating is null.

```graphql
query {
  books(filter: { rating: { isNull: true } }) {
    items { id title rating }
  }
}
```

#### Conceptual SQL

```sql
SELECT id, title, rating
FROM Books
WHERE rating IS NULL;
```

[!INCLUDE[Sample Configuration](./includes/sample-config.md)]
[!INCLUDE[See Also](./includes/see-also.md)]
