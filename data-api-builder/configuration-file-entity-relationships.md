---
title: Entity Relationship Configuration
description: Part of the configuration documentation for Data API builder, focusing on Entity Relationships.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

## Configuration File

1. [Overview](./configuration-file-overview.md)
1. [Runtime](./configuration-file-runtime.md)
1. [Entities.{entity}](./configuration-file-entities.md)
1. [Entities.{entity}.relationships](./configuration-file-entity-relationships.md)
1. [Entities.{entity}.permissions](./configuration-file-entity-permissions.md)
1. [Entities.{entity}.policy](./configuration-file-entity-policy.md)
1. [Sample](./configuration-file-sample.md)

# Relationships

This section outlines options that define relationships between entities. [more](https://devblogs.microsoft.com/azure-sql/data-api-builder-relationships/)

```json
{
  "entities": {
    "relationships": {
      "<relationship-name>": {
        "cardinality": "<one> | <many>",
      }
    }
  }
}
```

The `relationships` section outlines how entities interact within the Data API builder, detailing associations and potential database support for these relationships. The `name` property for each relationship is both required and must be unique across all relationships for a given entity. This ensures clear, identifiable connections and maintains the integrity of the GraphQL schema generated from these configurations.

| Relationship | Cardinality | Example
|-|-|-
| one-to-many | `many` | One category entity can relate to many totdo entities
| many-to-one | `one` | Many todo entities can relate to one category entity
| many-to-many| `many`  | One todo entity can relate to many user entities, and one user entity can relate to many todo entities

## One-To-Many relationship

A one-to-many relationship connects one entity to multiple entities in another table. This relationship allows you to model scenarios where a single entity can be associated with several instances of another entity. For instance, a single category can refence many todo tasks.

```json
{
  "entities": {
    "<entity-name>": {
      ...
      "relationships": {
        "<relationship-name>": {
          "cardinality": "many",
          "target.entity": "<entity-name>",
          "source.fields": ["<array-of-strings>"],
          "target.fields": ["<array-of-strings>"],
        }
      }
    }
  }
}
```

| Field           | Description
|-----------------|------------
| `source.fields` | Database fields in the *source* entity that are used to connect to the related item in the `target` entity. |
| `target.fields` | Database fields in the *target* entity that are used to connect to the related item in the `source` entity. |

These fields are optional and can be inferred automatically if there's a Foreign Key constraint between the two tables in the database.

### GraphQL Schema

The resulting GraphQL schema reflects this relationship by allowing queries on the `Category` entity to retrieve all related `Todo` items. This relationship enhances data retrieval efficiency and the relational context within your API.

```graphql
type Category
{
  id: Int!
  ...
  todos: [TodoConnection]!
}
```

### Example 

Consider a scenario where a `Category` entity is related to multiple `Todo` items. The configuration indicates that each category can be linked to many todos. The relationship is defined by matching the `Category` entity's ID (`source.fields`) with the `Todo` entity's category ID (`target.fields`).

```json
{
  "entities": {
    "<entity-name>": {
      ...
      "relationships": {
        "<relationship-name>": {
          "cardinality": "many",
          "target.entity": "Todo",
          "source.fields": ["id"],
          "target.fields": ["category_id"]
        }
      }
    }
  }
}
```

## Many-To-One Relationship

A Many-To-One relationship implies that multiple records in one entity are associated with a single record in another entity. This is commonly seen in scenarios where each child record (e.g., `Todo`) refers back to a parent record (`Category`).

```json
{
  "entities": {
    "<entity-name>": {
      ...
      "relationships": {
        "<relationship-name>": {
          "cardinality": "one",
          "target.entity": "<entity-name>",
          "source.fields": ["<array-of-strings>"],
          "target.fields": ["<array-of-strings>"],
        }
      }
    }
  }
}
```

| Field Type       | Description |
|------------------|-------------|
| `source.fields`  | Specifies the database fields in the source entity (`Todo`) used to link to the target entity (`Category`). Optional if a Foreign Key constraint exists. |
| `target.fields`  | Specifies the database fields in the target entity (`Category`) used for linking. Optional if a Foreign Key constraint exists. |

These fields are optional if there's an existing Foreign Key constraint that can automatically infer this information.

### GraphQL Schema

```graphql
type Todo {
  id: Int!
  ...
  category: Category
}
```

### Example

This configuration establishes a Many-To-One relationship between `Todo` and `Category` entities, allowing each `Todo` to be associated with a single `Category`.

```json
{
  "entities": {
    "<entity-name>": {
      ...
      "relationships": {
        "category": {
          "cardinality": "one",
          "target.entity": "Category",
          "source.fields": ["category_id"],
          "target.fields": ["id"]
        }
      }
    }
  }
}
```

## Many-To-Many Relationship

In a many-to-many relationship, two entities can have multiple connections between them. This relationship type is essential for scenarios where instances of one entity need to be linked with multiple instances of another entity, and vice versa. For example, a book can have multiple authors, and an author can write multiple books.

### Basic Syntax

```json
{
  "entities": {
    "<entity-name>": {
      ...
      "relationships": {
        "<relationship-name>": {
          "cardinality": "many",
          "target.entity": "<entity-name>",
          "source.fields": ["<array-of-strings>"],
          "target.fields": ["<array-of-strings>"],
          "linking.object": "<entity-or-db-object-name",
          "linking.source.fields": ["<array-of-strings>"],
          "linking.target.fields": ["<array-of-strings>"]
        }
      }
    }
  }
}
```

The `linking` prefix in elements identifies those elements used to provide association table or entity information.

| Field Type       | Description |
|------------------|-------------|
| `linking.object` |Specifies the intermediary table or entity used to maintain the many-to-many relationship between the two entities.
| `linking.source.fields` |Define the database columns used to establish the relationship to the source entity in the linking entity.
| `linking.target.fields` |Define the database columns used to establish the relationship in the target entity in the linking entity.

Both `source.fields` and `target.fields` are required in many-to-many relationship definitions. However, these fields are optional in configuration if they can be inferred automatically in the database.

### GraphQL Schema

The GraphQL schema generated from the configuration will allow for querying related entities through the intermediary, reflecting the many-to-many relationship.

```graphql
type Book {
  id: Int!
  ...
  authors: [Author]!
}

type Author {
  id: Int!
  ...
  books: [Book]!
}
```

### Example

Consider a scenario where books and authors are related through a many-to-many relationship. Each book can have multiple authors, and each author can write multiple books. The relationship is managed through an intermediary table, `BookAuthors`, which links books and authors based on their IDs.

```json
{
  "entities": {
    "Todo": {
      "relationships": {
        "assignees": {
          "cardinality": "many",
          "target.entity": "User",
          "source.fields": ["id"],
          "target.fields": ["id"],
          "linking.object": "users_todos",
          "linking.source.fields": ["todo_id"],
          "linking.target.fields": ["user_id"]
        }
      }
    }
  }
}
```

**Walkthrough**

+ `linking.object`: the database object (if not exposed via Hawaii) that is used in the backend database to support the M:N relationship
+ `linking.source.fields`: database fields, in the *linking* object (`users_todos` in the example), that is used to connect to the related item in the `source` entity (`Todo` in the sample)
+ `linking.target.fields`: database fields, in the *linking* object (`users_todos` in the example), that is used to connect to the related item in the `target` entity (`User` in the sample)