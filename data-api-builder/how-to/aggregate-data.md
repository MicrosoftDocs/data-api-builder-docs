---
title: Aggregate data with GraphQL
description: Use Data API builder GraphQL aggregation and groupBy to summarize data without extra back-end code.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 01/27/2026
# Customer Intent: As a developer, I want to run GraphQL aggregations (sum, average, min, max) so I can summarize data without custom APIs.
---

# Aggregate data with GraphQL in Data API builder

Data API builder (DAB) supports GraphQL aggregation and grouping for SQL family databases and Azure Synapse Analytics (Dedicated SQL pool). Aggregations let you summarize numeric fields and group results without writing custom API code. Aggregation and `groupBy` aren't available for Azure Cosmos DB for NoSQL, PostgreSQL, or MySQL.

## Prerequisites

- Supported database:
  - SQL Server 2016 or later
  - Azure SQL Database
  - Azure SQL Managed Instance
  - Microsoft Fabric SQL
  - Azure Synapse Analytics (Dedicated SQL pool only)
- Data API builder CLI. [Install the CLI](../command-line/install.md)
- A DAB configuration file with your entity exposed through GraphQL.
- A GraphQL client (for example, Banana Cake Pop or GraphQL Playground) to run queries.

## Supported databases

| Database | Aggregation support |
| --- | --- |
| SQL Server / Azure SQL / Microsoft Fabric SQL | ✅ Yes |
| Azure Synapse (Dedicated SQL pool) | ✅ Yes |
| Azure Synapse (Serverless SQL pool) | ❌ No |
| PostgreSQL | ❌ No |
| MySQL | ❌ No |
| Azure Cosmos DB for NoSQL | ❌ No |

## Aggregate functions

DAB supports the following aggregate functions:

| Function | Applies to | Description |
| --- | --- | --- |
| `sum` | Numeric fields only | Total of all values |
| `average` | Numeric fields only | Mean of all values |
| `min` | Numeric fields only | Minimum value |
| `max` | Numeric fields only | Maximum value |
| `count` | Any field | Count of non-null values |

### Constraints

- `sum`, `average`, `min`, and `max` only work on numeric data types (int, decimal, float, etc.).
- `count` works on any data type, including strings and dates.
- If a table has no numeric columns, DAB doesn't generate aggregation nodes for that entity. You can still use `count` on non-numeric fields.

### Optional modifiers

| Modifier | Purpose | Example |
| --- | --- | --- |
| `distinct: true` | Count unique values only | Count distinct customers |
| `having: { ... }` | Filter groups after aggregation | Show groups with sum > 1000 |

## Run the DAB runtime

Start DAB with your configuration file so the GraphQL endpoint is available.

```dotnetcli
dab start
```

## Query aggregated results

This section walks through a complete example showing the table schema, GraphQL query, generated SQL, and JSON response.

### Table schema

```sql
CREATE TABLE books (
    id INT PRIMARY KEY,
    title NVARCHAR(200),
    year INT,
    pages INT
);
```

### GraphQL query

Use GraphQL to group rows and return aggregate values for numeric fields.

```graphql
{
  books(
    groupBy: { fields: ["year"] }
  ) {
    items {
      year
    }
    aggregates {
      pages {
        sum
        average
        min
        max
      }
    }
  }
}
```

- `groupBy.fields` groups rows by the specified columns.
- `aggregates` exposes aggregate functions for numeric fields (for example, `pages`).
- The GraphQL schema only exposes aggregates for fields that support them; use schema introspection in your client to confirm available aggregate fields and functions.

### Generated SQL

DAB translates the GraphQL query into T-SQL:

```sql
SELECT 
    [year],
    SUM([pages]) AS [sum],
    AVG([pages]) AS [average],
    MIN([pages]) AS [min],
    MAX([pages]) AS [max]
FROM [dbo].[books]
GROUP BY [year]
FOR JSON PATH, INCLUDE_NULL_VALUES
```

### JSON response

```json
{
  "data": {
    "books": {
      "items": [
        { "year": 2023 },
        { "year": 2024 }
      ],
      "aggregates": {
        "pages": [
          { "sum": 3200, "average": 320, "min": 120, "max": 450 },
          { "sum": 4500, "average": 300, "min": 140, "max": 510 }
        ]
      }
    }
  }
}
```

The `items` and `aggregates` arrays align by index—the first element in `aggregates.pages` corresponds to the first group in `items`.

## Aggregate without grouping

Calculate aggregates across all rows when you omit `groupBy`.

### GraphQL query

```graphql
{
  books {
    aggregates {
      pages {
        sum
        average
        min
        max
        count
      }
      id {
        count
      }
    }
  }
}
```

### Generated SQL

```sql
SELECT
    SUM([pages]) AS [sum],
    AVG([pages]) AS [average],
    MIN([pages]) AS [min],
    MAX([pages]) AS [max],
    COUNT([pages]) AS [count],
    COUNT([id]) AS [count]
FROM [dbo].[books]
FOR JSON PATH, INCLUDE_NULL_VALUES
```

### JSON response

```json
{
  "data": {
    "books": {
      "aggregates": {
        "pages": {
          "sum": 15420,
          "average": 308,
          "min": 120,
          "max": 850,
          "count": 50
        },
        "id": {
          "count": 50
        }
      }
    }
  }
}
```

Without `groupBy`, the response returns a single object (not an array) because all rows collapse into one result.

## Group by one or more fields

Group rows by one or more columns and return aggregates per group.

### Table schema

```sql
CREATE TABLE sales (
    id INT PRIMARY KEY,
    year INT,
    category NVARCHAR(50),
    revenue DECIMAL(10,2),
    quantity INT
);
```

### GraphQL query

```graphql
{
  sales(
    groupBy: { fields: ["year", "category"] }
  ) {
    items {
      year
      category
    }
    aggregates {
      revenue {
        sum
        average
      }
      quantity {
        sum
      }
    }
  }
}
```

### Generated SQL

```sql
SELECT
    [year],
    [category],
    SUM([revenue]) AS [sum],
    AVG([revenue]) AS [average],
    SUM([quantity]) AS [sum]
FROM [dbo].[sales]
GROUP BY [year], [category]
FOR JSON PATH, INCLUDE_NULL_VALUES
```

### JSON response

```json
{
  "data": {
    "sales": {
      "items": [
        { "year": 2023, "category": "Books" },
        { "year": 2023, "category": "Electronics" },
        { "year": 2024, "category": "Books" }
      ],
      "aggregates": {
        "revenue": [
          { "sum": 45000.00, "average": 150.00 },
          { "sum": 120000.00, "average": 600.00 },
          { "sum": 52000.00, "average": 173.33 }
        ],
        "quantity": [
          { "sum": 300 },
          { "sum": 200 },
          { "sum": 300 }
        ]
      }
    }
  }
}
```

The response returns arrays for `items` and aggregates in the same order so you can align groups with their aggregated values.

## HAVING to filter aggregated results

Use `having` to filter groups after aggregation. This is equivalent to SQL's `HAVING` clause.

### Table schema

```sql
CREATE TABLE products (
    id INT PRIMARY KEY,
    category NVARCHAR(50),
    price DECIMAL(10,2)
);
```

### GraphQL query

```graphql
{
  products(
    groupBy: { fields: ["category"] }
  ) {
    items { category }
    aggregates {
      price {
        sum(having: { gt: 10000 })
        average
      }
    }
  }
}
```

### Generated SQL

```sql
SELECT
    [category],
    SUM([price]) AS [sum],
    AVG([price]) AS [average]
FROM [dbo].[products]
GROUP BY [category]
HAVING SUM([price]) > 10000
FOR JSON PATH, INCLUDE_NULL_VALUES
```

### JSON response

Only categories where the sum exceeds 10000 are returned:

```json
{
  "data": {
    "products": {
      "items": [
        { "category": "Electronics" },
        { "category": "Furniture" }
      ],
      "aggregates": {
        "price": [
          { "sum": 15000.00, "average": 300.00 },
          { "sum": 12000.00, "average": 400.00 }
        ]
      }
    }
  }
}
```

### HAVING operators

| Operator | SQL equivalent | Example |
| --- | --- | --- |
| `eq` | `=` | `having: { eq: 100 }` |
| `neq` | `<>` | `having: { neq: 0 }` |
| `gt` | `>` | `having: { gt: 1000 }` |
| `gte` | `>=` | `having: { gte: 500 }` |
| `lt` | `<` | `having: { lt: 100 }` |
| `lte` | `<=` | `having: { lte: 50 }` |

> [!NOTE]
> Each `having` filter applies independently to its aggregate function. You can't create cross-aggregate conditions like "sum > 1000 OR count < 10" in a single GraphQL query.

## DISTINCT in aggregations

Count unique values with `distinct: true`.

### Table schema

```sql
CREATE TABLE orders (
    id INT PRIMARY KEY,
    customer_id INT,
    product_id INT
);
```

### GraphQL query

```graphql
{
  orders(
    groupBy: { fields: ["customer_id"] }
  ) {
    items { customer_id }
    aggregates {
      product_id {
        count(distinct: true)
        count
      }
    }
  }
}
```

### Generated SQL

```sql
SELECT
    [customer_id],
    COUNT(DISTINCT [product_id]) AS [count],
    COUNT([product_id]) AS [count]
FROM [dbo].[orders]
GROUP BY [customer_id]
FOR JSON PATH, INCLUDE_NULL_VALUES
```

### JSON response

```json
{
  "data": {
    "orders": {
      "items": [
        { "customer_id": 101 },
        { "customer_id": 102 }
      ],
      "aggregates": {
        "product_id": [
          { "count": 5 },
          { "count": 3 }
        ]
      }
    }
  }
}
```

The first `count` (with `distinct: true`) returns unique products per customer. The second `count` returns total orders.

> [!NOTE]
> When requesting multiple aggregates on the same field, DAB returns them in the order requested. Use aliases (for example, `uniqueProducts: count(distinct: true)`) to make responses self-documenting.

## Combine filters with aggregation

Apply `filter` to rows before grouping, and `having` to groups after aggregation. Understanding the order of operations is critical:

1. **Filter** (SQL `WHERE`) removes rows before grouping
1. **Group by** collects remaining rows into groups
1. **Aggregate** calculates sum/avg/min/max/count per group
1. **Having** removes groups that don't match the condition

### GraphQL query

```graphql
{
  sales(
    filter: { year: { gte: 2023 } }
    groupBy: { fields: ["region"] }
  ) {
    items { region }
    aggregates {
      revenue { sum average }
    }
  }
}
```

### Generated SQL

```sql
SELECT
    [region],
    SUM([revenue]) AS [sum],
    AVG([revenue]) AS [average]
FROM [dbo].[sales]
WHERE [year] >= 2023
GROUP BY [region]
FOR JSON PATH, INCLUDE_NULL_VALUES
```

> [!TIP]
> Use `filter` to exclude rows before aggregation. Use `having` to filter groups after aggregation.

## Use aliases with aggregations

Create meaningful field names using GraphQL aliases.

```graphql
{
  products(
    groupBy: { fields: ["category"] }
  ) {
    items { category }
    aggregates {
      price {
        totalRevenue: sum
        avgPrice: average
        cheapest: min
        mostExpensive: max
        productCount: count
      }
    }
  }
}
```

## Schema introspection

Use introspection to see which aggregates are available for an entity.

```graphql
{
  __type(name: "BooksAggregates") {
    fields {
      name
      type { name }
    }
  }
}
```

Numeric fields expose `sum`, `average`, `min`, `max`, and `count`. Non-numeric fields expose `count`.

## Tips and limitations

- Aggregation and `groupBy` apply to SQL Server, Azure SQL, Microsoft Fabric SQL, and Azure Synapse Dedicated SQL pool only.
- Aggregates run on numeric fields; `count` works on any field. Tables without numeric columns only expose `count`.
- Grouping applies to fields on the same entity (no cross-entity groupBy).
- Large aggregations can be expensive; index your groupBy columns and filter rows before grouping when possible.
- Create indexes on frequently used `groupBy` columns to improve query performance.

## Troubleshooting

### Error: Field doesn't support aggregation

**Cause**: Using `sum`, `average`, `min`, or `max` on a non-numeric field.

**Solution**:

- Use schema introspection to verify field types.
- Use `count` for non-numeric fields.
- Check field mappings if using custom field names.

### Error: Aggregation nodes not found

**Cause**: Entity has no numeric columns.

**Solution**:

- Verify table schema has at least one numeric column.
- Use `count` aggregates on non-numeric fields if needed.

### Slow aggregation queries

**Cause**: Large tables without proper indexes.

**Solution**:

- Create indexes on `groupBy` columns.
- Use `filter` to limit rows before aggregation.
- Use `having` to reduce the number of groups returned.

## Related content

- [GraphQL in Data API builder](../concept/api/graphql.md)
- [Feature availability](../feature-availability.md)

## Next step

> [!div class="nextstepaction"]
> [Check feature availability](../feature-availability.md)
