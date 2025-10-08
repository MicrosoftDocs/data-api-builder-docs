---
title: Use $filter (REST) and filter (GraphQL)
description: Learn how to express predicates, supported operators, validation rules, and see example translations to parameterized SQL (SQL Server) for filtering in Data API builder.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 10/08/2025
# Customer Intent: As a developer, I want to filter datasets efficiently and safely and understand the SQL produced.
---

# Filtering data in REST and GraphQL

Filtering narrows large data sets to only the records you need. Data API builder (DAB) supports two filter syntaxes: `$filter` in REST and `filter` in GraphQL. Both compile to parameterized SQL for safety and consistency.

> [!NOTE]
> REST filtering supports comparison and logical operators. GraphQL filtering adds pattern and membership operators.

## Common concepts

Filtering expressions are built from predicates joined by logical operators. Each predicate compares a field to a literal or null. Parentheses group expressions. Literal values are always parameterized.

Example goal: Return books published in or after 2020 and priced under 25.

---

## Supported operators

| Operator    | Meaning               | REST | GraphQL |
| ----------- | --------------------- | ---- | ------- |
| eq          | equal                 | Yes  | Yes     |
| ne          | not equal             | Yes  | No      |
| neq         | not equal             | No   | Yes     |
| gt          | greater than          | Yes  | Yes     |
| ge          | greater than or equal | Yes  | No      |
| gte         | greater than or equal | No   | Yes     |
| lt          | less than             | Yes  | Yes     |
| le          | less than or equal    | Yes  | No      |
| lte         | less than or equal    | No   | Yes     |
| and         | logical AND           | Yes  | Yes     |
| or          | logical OR            | Yes  | Yes     |
| not         | logical NOT           | Yes  | No      |
| contains    | substring match       | No   | Yes     |
| notContains | not substring match   | No   | Yes     |
| startsWith  | prefix match          | No   | Yes     |
| endsWith    | suffix match          | No   | Yes     |
| in          | membership            | No   | Yes     |
| isNull      | null check            | No   | Yes     |
| ( )         | grouping              | Yes  | No      |

> [!NOTE]
> REST uses single quotes for strings and ISO 8601 UTC format for dates. GraphQL uses double quotes inside JSON-style literals.

---

# [REST](#tab/rest)

Pattern
`GET /api/{entity}?$filter=<predicate>`

Example
`GET /api/books?$filter=year ge 2020 and price lt 25`

SQL

```sql
SELECT * FROM Books
WHERE year >= 2020 AND price < 25;
```

Books titled “Foundation” or “Dune”

```
$filter=title eq 'Foundation' or title eq 'Dune'
```

```sql
SELECT * FROM Books
WHERE title = 'Foundation' OR title = 'Dune';
```

Books with a rating

```
$filter=rating ne null
```

```sql
SELECT * FROM Books
WHERE rating IS NOT NULL;
```

Books published in 2025 and priced under 25

```
$filter=published_on ge 2025-01-01T00:00:00Z and published_on lt 2026-01-01T00:00:00Z and price lt 25
```

```sql
SELECT * FROM Books
WHERE published_on >= '2025-01-01'
  AND published_on < '2026-01-01'
  AND price < 25;
```

# [GraphQL](#tab/graphql)

Pattern

```graphql
query {
  books(filter: { year: { gte: 2020 }, price: { lt: 25 } }) {
    items { id title year price }
  }
}
```

SQL

```sql
SELECT id, title, year, price
FROM Books
WHERE year >= 2020 AND price < 25;
```

Books containing “Guide” in the title

```graphql
books(filter: { title: { contains: "Guide" } }) {
  items { id title }
}
```

```sql
SELECT id, title FROM Books
WHERE title LIKE '%Guide%';
```

Books not discontinued

```graphql
books(filter: { discontinuedOn: { isNull: true } }) {
  items { id title }
}
```

```sql
SELECT id, title FROM Books
WHERE discontinuedOn IS NULL;
```

---

## Null handling

| REST            | SQL           | GraphQL                        |
| --------------- | ------------- | ------------------------------ |
| `field eq null` | `IS NULL`     | `{ field: { isNull: true } }`  |
| `field ne null` | `IS NOT NULL` | `{ field: { isNull: false } }` |
