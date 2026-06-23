---
title: Aggregate data with GraphQL
description: Learn how Data API builder translates GraphQL aggregate queries into SQL queries for counts, sums, averages, grouped values, filters, and views.
author: JerryNixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 06/23/2026
# Customer Intent: As a developer, I want to aggregate data with GraphQL so that I can query summary values without writing custom SQL endpoints.
---

# Aggregate data with GraphQL

Data API builder supports GraphQL aggregation for SQL Server family and Azure Synapse Analytics Dedicated SQL pool entities. Use the `groupBy` field on a collection query to calculate `sum`, `avg`, `min`, `max`, and `count` values.

The examples in this article use SQL Server and GraphQL entities with read permission. Data API builder generates SQL like the statements shown in each scenario. Parameter values appear as query parameters at runtime. The `sum`, `avg`, `min`, and `max` functions apply to numeric fields. The `count` function works on any field.

> [!IMPORTANT]
> Aggregation isn't available for Azure Cosmos DB for NoSQL, PostgreSQL, or MySQL.

Aggregation is enabled by default. To turn it off, set `enable-aggregation` to `false` under `runtime.graphql` in your configuration file. Aggregation queries return one page of groups, 100 by default. Use the `first` argument on the collection query to change the maximum, for example `books(first: 500)`. Set the default with `runtime.pagination.default-page-size`.

## GraphQL schema additions

When you enable aggregation, Data API builder adds aggregation fields and generated types to each supported GraphQL collection. The exact generated type names are entity-specific and visible through GraphQL introspection, but the query syntax is consistent across entities.

The following snippets show syntax formats, not complete GraphQL queries.

### `groupBy`

Returns grouped rows for the collection. Select this member instead of `items` in an aggregation query.

```text
<collection> { groupBy { ... } }
```

### `groupBy(fields: [...])`

Lists the entity fields to group by. Omit `fields` to aggregate all rows into one group.

```text
<collection> { groupBy(fields: [<field>, ...]) { ... } }
```

### `fields`

Returns the grouped field values for each row in the aggregation result.

```text
groupBy(fields: [<field>]) { fields { <field> } }
```

### `aggregations`

Contains the aggregate function selections for each group.

```text
groupBy { aggregations { <alias>: <function>(field: <field>) } }
```

### `sum`, `avg`, `min`, and `max`

Aggregate numeric fields.

```text
aggregations { <alias>: sum(field: <numeric-field>) }
aggregations { <alias>: avg(field: <numeric-field>) }
aggregations { <alias>: min(field: <numeric-field>) }
aggregations { <alias>: max(field: <numeric-field>) }
```

### `count`

Counts values for a field.

```text
aggregations { <alias>: count(field: <field>) }
```

### `field`

Identifies the entity field to aggregate. Field names are enum values, not strings.

```text
<function>(field: <field>)
```

### `having`

Filters groups after Data API builder calculates the aggregate value.

```text
aggregations { <alias>: <function>(field: <field>, having: { <operator>: <value> }) }
```

### `distinct`

Counts unique values when used with `count`.

```text
aggregations { <alias>: count(field: <field>, distinct: true) }
```

Data API builder generates entity-specific GraphQL types behind these members, including group row types, grouped field types, aggregate selection types, field enums, and `having` input types. You don't need to name those generated types in a query.

## Samples

The following samples show the SQL table, GraphQL query, resulting SQL, and resulting output for common aggregation patterns.

### Aggregate all rows in a table

Use this pattern when you want one summary row for the whole entity.

#### SQL table

```sql
CREATE TABLE dbo.Books (
    id INT NOT NULL PRIMARY KEY,
    title NVARCHAR(200) NOT NULL,
    [year] INT NOT NULL,
    pages INT NOT NULL
);

INSERT INTO dbo.Books (id, title, [year], pages) VALUES
    (1, N'GraphQL Basics', 2023, 120),
    (2, N'Advanced APIs', 2023, 450),
    (3, N'Data Patterns', 2023, 390),
    (4, N'Cloud APIs', 2024, 140),
    (5, N'Runtime Internals', 2024, 510),
    (6, N'Query Tuning', 2024, 250);
```

| id | title | year | pages |
| --- | --- | --- | --- |
| 1 | GraphQL Basics | 2023 | 120 |
| 2 | Advanced APIs | 2023 | 450 |
| 3 | Data Patterns | 2023 | 390 |
| 4 | Cloud APIs | 2024 | 140 |
| 5 | Runtime Internals | 2024 | 510 |
| 6 | Query Tuning | 2024 | 250 |

#### GraphQL query

```graphql
{
  books {
    groupBy {
      aggregations {
        totalPages: sum(field: pages)
        averagePages: avg(field: pages)
        shortestBook: min(field: pages)
        longestBook: max(field: pages)
        bookCount: count(field: id)
      }
    }
  }
}
```

#### Resulting SQL

```sql
SELECT TOP 100
    SUM([table0].[pages]) AS [totalPages],
    AVG([table0].[pages]) AS [averagePages],
    MIN([table0].[pages]) AS [shortestBook],
    MAX([table0].[pages]) AS [longestBook],
    COUNT([table0].[id]) AS [bookCount]
FROM [dbo].[Books] AS [table0]
WHERE 1 = 1
FOR JSON PATH, INCLUDE_NULL_VALUES;
```

#### Resulting output

```json
{
  "data": {
    "books": {
      "groupBy": [
        {
          "aggregations": {
            "totalPages": 1860,
            "averagePages": 310,
            "shortestBook": 120,
            "longestBook": 510,
            "bookCount": 6
          }
        }
      ]
    }
  }
}
```

| totalPages | averagePages | shortestBook | longestBook | bookCount |
| --- | --- | --- | --- | --- |
| 1860 | 310 | 120 | 510 | 6 |

### Group rows by one field

Use `groupBy(fields: [...])` to return one aggregate row per field value. Field names are GraphQL enum values, not strings.

#### SQL table

```sql
CREATE TABLE dbo.Books (
  id INT NOT NULL PRIMARY KEY,
  title NVARCHAR(200) NOT NULL,
  [year] INT NOT NULL,
  pages INT NOT NULL
);

INSERT INTO dbo.Books (id, title, [year], pages) VALUES
  (1, N'GraphQL Basics', 2023, 120),
  (2, N'Advanced APIs', 2023, 450),
  (3, N'Data Patterns', 2023, 390),
  (4, N'Cloud APIs', 2024, 140),
  (5, N'Runtime Internals', 2024, 510),
  (6, N'Query Tuning', 2024, 250);
```

| id | title | year | pages |
| --- | --- | --- | --- |
| 1 | GraphQL Basics | 2023 | 120 |
| 2 | Advanced APIs | 2023 | 450 |
| 3 | Data Patterns | 2023 | 390 |
| 4 | Cloud APIs | 2024 | 140 |
| 5 | Runtime Internals | 2024 | 510 |
| 6 | Query Tuning | 2024 | 250 |

#### GraphQL query

```graphql
{
  books(orderBy: { year: ASC }) {
    groupBy(fields: [year]) {
      fields { year }
      aggregations {
        totalPages: sum(field: pages)
        averagePages: avg(field: pages)
      }
    }
  }
}
```

#### Resulting SQL

```sql
SELECT TOP 100
    [table0].[year] AS [year],
    SUM([table0].[pages]) AS [totalPages],
    AVG([table0].[pages]) AS [averagePages]
FROM [dbo].[Books] AS [table0]
WHERE 1 = 1
GROUP BY [table0].[year]
ORDER BY [table0].[year] ASC
FOR JSON PATH, INCLUDE_NULL_VALUES;
```

#### Resulting output

```json
{
  "data": {
    "books": {
      "groupBy": [
        {
          "fields": {
            "year": 2023
          },
          "aggregations": {
            "totalPages": 960,
            "averagePages": 320
          }
        },
        {
          "fields": {
            "year": 2024
          },
          "aggregations": {
            "totalPages": 900,
            "averagePages": 300
          }
        }
      ]
    }
  }
}
```

| year | totalPages | averagePages |
| --- | --- | --- |
| 2023 | 960 | 320 |
| 2024 | 900 | 300 |

### Group rows from a view

Aggregation also works for view-backed entities. Configure a key field for the view so Data API builder can expose it as an entity.

#### SQL view

```sql
CREATE TABLE dbo.Employees (
  id INT NOT NULL PRIMARY KEY,
  name NVARCHAR(100) NOT NULL,
  department NVARCHAR(50) NOT NULL,
  title NVARCHAR(100) NOT NULL,
  age INT NOT NULL
);

INSERT INTO dbo.Employees (id, name, department, title, age) VALUES
  (1, N'Ada', N'Engineering', N'Developer', 29),
  (2, N'Ben', N'Engineering', N'Architect', 41),
  (3, N'Cora', N'Sales', N'Account manager', 34),
  (4, N'Diego', N'Sales', N'Sales lead', 52),
  (5, N'Ema', N'Support', N'Support engineer', 25),
  (6, N'Finn', N'Support', N'Support lead', 38),
  (7, N'Gia', N'Engineering', N'Engineering manager', 45);

CREATE VIEW dbo.EmployeeAgeReport
AS
SELECT id, department, age
FROM dbo.Employees;
```

| id | department | age |
| --- | --- | --- |
| 1 | Engineering | 29 |
| 2 | Engineering | 41 |
| 3 | Sales | 34 |
| 4 | Sales | 52 |
| 5 | Support | 25 |
| 6 | Support | 38 |
| 7 | Engineering | 45 |

Configure the view with `id` as the key field:

```dotnetcli
dab add EmployeeAgeReport --source dbo.EmployeeAgeReport --source.type view --source.key-fields id --permissions "anonymous:read"
```

#### GraphQL query

```graphql
{
  employeeAgeReports(orderBy: { department: ASC }) {
    groupBy(fields: [department]) {
      fields { department }
      aggregations {
        youngest: min(field: age)
        oldest: max(field: age)
        employeeCount: count(field: id)
      }
    }
  }
}
```

#### Resulting SQL

```sql
SELECT TOP 100
  [table0].[department] AS [department],
  MIN([table0].[age]) AS [youngest],
  MAX([table0].[age]) AS [oldest],
  COUNT([table0].[id]) AS [employeeCount]
FROM [dbo].[EmployeeAgeReport] AS [table0]
WHERE 1 = 1
GROUP BY [table0].[department]
ORDER BY [table0].[department] ASC
FOR JSON PATH, INCLUDE_NULL_VALUES;
```

#### Resulting output

```json
{
  "data": {
    "employeeAgeReports": {
      "groupBy": [
        {
          "fields": {
            "department": "Engineering"
          },
          "aggregations": {
            "youngest": 29,
            "oldest": 45,
            "employeeCount": 3
          }
        },
        {
          "fields": {
            "department": "Sales"
          },
          "aggregations": {
            "youngest": 34,
            "oldest": 52,
            "employeeCount": 2
          }
        },
        {
          "fields": {
            "department": "Support"
          },
          "aggregations": {
            "youngest": 25,
            "oldest": 38,
            "employeeCount": 2
          }
        }
      ]
    }
  }
}
```

| department | youngest | oldest | employeeCount |
| --- | --- | --- | --- |
| Engineering | 29 | 45 | 3 |
| Sales | 34 | 52 | 2 |
| Support | 25 | 38 | 2 |

### Filter rows before aggregation

Use `filter` on the collection query to limit source rows before Data API builder groups and aggregates them.

#### SQL view

```sql
CREATE TABLE dbo.Employees (
  id INT NOT NULL PRIMARY KEY,
  name NVARCHAR(100) NOT NULL,
  department NVARCHAR(50) NOT NULL,
  title NVARCHAR(100) NOT NULL,
  age INT NOT NULL
);

INSERT INTO dbo.Employees (id, name, department, title, age) VALUES
  (1, N'Ada', N'Engineering', N'Developer', 29),
  (2, N'Ben', N'Engineering', N'Architect', 41),
  (3, N'Cora', N'Sales', N'Account manager', 34),
  (4, N'Diego', N'Sales', N'Sales lead', 52),
  (5, N'Ema', N'Support', N'Support engineer', 25),
  (6, N'Finn', N'Support', N'Support lead', 38),
  (7, N'Gia', N'Engineering', N'Engineering manager', 45);

CREATE VIEW dbo.EmployeeAgeReport
AS
SELECT id, department, age
FROM dbo.Employees;
```

| id | department | age |
| --- | --- | --- |
| 1 | Engineering | 29 |
| 2 | Engineering | 41 |
| 3 | Sales | 34 |
| 4 | Sales | 52 |
| 5 | Support | 25 |
| 6 | Support | 38 |
| 7 | Engineering | 45 |

#### GraphQL query

```graphql
{
  employeeAgeReports(filter: { age: { gt: 30 } }, orderBy: { department: ASC }) {
    groupBy(fields: [department]) {
      fields { department }
      aggregations {
        youngest: min(field: age)
        oldest: max(field: age)
        employeeCount: count(field: id)
      }
    }
  }
}
```

#### Resulting SQL

```sql
SELECT TOP 100
  [table0].[department] AS [department],
  MIN([table0].[age]) AS [youngest],
  MAX([table0].[age]) AS [oldest],
  COUNT([table0].[id]) AS [employeeCount]
FROM [dbo].[EmployeeAgeReport] AS [table0]
WHERE [table0].[age] > @param1
GROUP BY [table0].[department]
ORDER BY [table0].[department] ASC
FOR JSON PATH, INCLUDE_NULL_VALUES;
```

For this query, `@param1` is `30`.

#### Resulting output

```json
{
  "data": {
    "employeeAgeReports": {
      "groupBy": [
        {
          "fields": {
            "department": "Engineering"
          },
          "aggregations": {
            "youngest": 41,
            "oldest": 45,
            "employeeCount": 2
          }
        },
        {
          "fields": {
            "department": "Sales"
          },
          "aggregations": {
            "youngest": 34,
            "oldest": 52,
            "employeeCount": 2
          }
        },
        {
          "fields": {
            "department": "Support"
          },
          "aggregations": {
            "youngest": 38,
            "oldest": 38,
            "employeeCount": 1
          }
        }
      ]
    }
  }
}
```

| department | youngest | oldest | employeeCount |
| --- | --- | --- | --- |
| Engineering | 41 | 45 | 2 |
| Sales | 34 | 52 | 2 |
| Support | 38 | 38 | 1 |

### Filter groups by using `having`

Use `having` on an aggregate function to filter groups after aggregation. This pattern maps to a SQL `HAVING` clause.

#### SQL table

```sql
CREATE TABLE dbo.Products (
    id INT NOT NULL PRIMARY KEY,
    category NVARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

INSERT INTO dbo.Products (id, category, price) VALUES
    (1, N'Electronics', 5000.00),
    (2, N'Electronics', 10000.00),
    (3, N'Furniture', 4000.00),
    (4, N'Furniture', 8000.00),
    (5, N'Books', 100.00),
    (6, N'Books', 200.00);
```

| id | category | price |
| --- | --- | --- |
| 1 | Electronics | 5000.00 |
| 2 | Electronics | 10000.00 |
| 3 | Furniture | 4000.00 |
| 4 | Furniture | 8000.00 |
| 5 | Books | 100.00 |
| 6 | Books | 200.00 |

#### GraphQL query

```graphql
{
  products(orderBy: { category: ASC }) {
    groupBy(fields: [category]) {
      fields { category }
      aggregations {
        totalValue: sum(field: price, having: { gt: 10000 })
        averagePrice: avg(field: price)
      }
    }
  }
}
```

#### Resulting SQL

```sql
SELECT TOP 100
    [table0].[category] AS [category],
    SUM([table0].[price]) AS [totalValue],
    AVG([table0].[price]) AS [averagePrice]
FROM [dbo].[Products] AS [table0]
WHERE 1 = 1
GROUP BY [table0].[category]
HAVING SUM([table0].[price]) > @param1
ORDER BY [table0].[category] ASC
FOR JSON PATH, INCLUDE_NULL_VALUES;
```

For this query, `@param1` is `10000`.

#### Resulting output

```json
{
  "data": {
    "products": {
      "groupBy": [
        {
          "fields": {
            "category": "Electronics"
          },
          "aggregations": {
            "totalValue": 15000,
            "averagePrice": 7500
          }
        },
        {
          "fields": {
            "category": "Furniture"
          },
          "aggregations": {
            "totalValue": 12000,
            "averagePrice": 6000
          }
        }
      ]
    }
  }
}
```

| category | totalValue | averagePrice |
| --- | --- | --- |
| Electronics | 15000 | 7500 |
| Furniture | 12000 | 6000 |

### Count distinct values

Use `distinct: true` with `count` to count unique values in each group.

#### SQL table

```sql
CREATE TABLE dbo.Orders (
    id INT NOT NULL PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL
);

INSERT INTO dbo.Orders (id, customer_id, product_id) VALUES
    (1, 101, 1),
    (2, 101, 2),
    (3, 101, 2),
    (4, 101, 3),
    (5, 101, 4),
    (6, 101, 5),
    (7, 102, 1),
    (8, 102, 1),
    (9, 102, 2),
    (10, 102, 3);
```

| id | customer_id | product_id |
| --- | --- | --- |
| 1 | 101 | 1 |
| 2 | 101 | 2 |
| 3 | 101 | 2 |
| 4 | 101 | 3 |
| 5 | 101 | 4 |
| 6 | 101 | 5 |
| 7 | 102 | 1 |
| 8 | 102 | 1 |
| 9 | 102 | 2 |
| 10 | 102 | 3 |

#### GraphQL query

```graphql
{
  orders(orderBy: { customer_id: ASC }) {
    groupBy(fields: [customer_id]) {
      fields { customer_id }
      aggregations {
        uniqueProducts: count(field: product_id, distinct: true)
        totalOrders: count(field: id)
      }
    }
  }
}
```

#### Resulting SQL

```sql
SELECT TOP 100
    [table0].[customer_id] AS [customer_id],
    COUNT(DISTINCT ([table0].[product_id])) AS [uniqueProducts],
    COUNT([table0].[id]) AS [totalOrders]
FROM [dbo].[Orders] AS [table0]
WHERE 1 = 1
GROUP BY [table0].[customer_id]
ORDER BY [table0].[customer_id] ASC
FOR JSON PATH, INCLUDE_NULL_VALUES;
```

#### Resulting output

```json
{
  "data": {
    "orders": {
      "groupBy": [
        {
          "fields": {
            "customer_id": 101
          },
          "aggregations": {
            "uniqueProducts": 5,
            "totalOrders": 6
          }
        },
        {
          "fields": {
            "customer_id": 102
          },
          "aggregations": {
            "uniqueProducts": 3,
            "totalOrders": 4
          }
        }
      ]
    }
  }
}
```

| customer_id | uniqueProducts | totalOrders |
| --- | --- | --- |
| 101 | 5 | 6 |
| 102 | 3 | 4 |

## Common mistakes

- Select `groupBy` inside the collection field. Don't pass `groupBy` as a collection argument.
- Use `aggregations`, not `aggregates`.
- Use `avg`, not `average`.
- Use field enum values, such as `fields: [year]`. Don't quote field names.
- Don't select `items` and `groupBy` in the same collection query.
- When you group by fields, select only the same fields inside the `fields` object.

## Related content

- [GraphQL in Data API builder](overview.md)
- [Database views in the GraphQL API](views.md)
- [Use filters with GraphQL](../../keywords/filter-graphql.md)
- [Order GraphQL query results](../../keywords/orderby-graphql.md)
- [Feature availability](../../feature-availability.md)
