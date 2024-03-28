---
title: Configuration Entity Graphql
description: Details the graphql property in Entity
author: jerrynixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/27/2024
---

# GraphQL

This segment provides for integrating an entity into the GraphQL schema. It allows developers to specify or modify default values for the entity in GraphQL. This setup ensures the schema accurately reflects the intended structure and naming conventions.

## Syntax overview

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "graphql": {
        "enabled": true (default) | false,
        "type": {
          "singular": "my-alternative-name",
          "plural": "my-alternative-name-pluralized"
        },
        "operation": "query" | "mutation" (default)
      },
    }
  }
}
```

### Enabled property

Enabled controls whether an entity is available via GraphQL endpoints. Toggling the `enabled` property lets developers  selectively expose entities from the GraphQL schema.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "graphql": {
        ...
        "enabled": true | false
      }
    }
  }
}
```

### Type property

This property dictates the naming convention for an entity within the GraphQL schema. It supports both scalar string values and object types. The object value specifies the singular and plural forms. This property provides granular control over the schema's readability and user experience.

**Scalar string value**

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "graphql": {
        ...
        "type": "<custom-type-name>"
      }
    }
  }
}
```

**Object type value**

For even greater control over the GraphQL type, you can configure how the singular and plural name is represented independently. 

If `plural` is missing or omitted (like scalar value) Data API builder tries to pluralize the name automatically, following the English rules for pluralization (for example: https://engdic.org/singular-and-plural-noun-rules-definitions-examples)

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "graphql": {
        ...
        "type": {
          "singular": "User",
          "plural": "Users"
        }
      }
    }
  }
}
```

### Operation property

For entities mapped to stored procedures, the `operation` property designates the GraphQL operation type (query or mutation) where the stored procedure is accessible. This setting allows for logical organization of the schema and adherence to GraphQL best practices, without impacting functionality.

> [!NOTE]
> An entity is specified to be a stored procedure by setting the `{entity}.type` property value to `stored-procedure`. In the case of a stored procedure, a new GraphQL type executeXXX is automatically created. However, the `operation` property allows the developer to coerse the location of that type into either the `mutation` or `query` parts of the schema. This property allows for schema hygene and there is no functional impact regardless of `operation` value.  

If missing, the `operation` default is `mutation`.

**Mutation example**

When `operation` is `mutation`, the GraphQL schema would resemble:

```graphql
type Mutation {
  executeGetCowrittenBooksByAuthor(
    searchType: String = "S"
  ): [GetCowrittenBooksByAuthor!]!
}
```

**Query example**

When `operation` is `query`, the GraphQL schema would resemble:

The GraphQL schema would resemble:

```graphql
type Query {
  executeGetCowrittenBooksByAuthor(
    searchType: String = "S"
  ): [GetCowrittenBooksByAuthor!]!
}
```

> [!NOTE]
> The `operation` property is only about the placement of the operation in the GraphQL schema, it does not change the behavior of the operation. 

## Example

```json
{
  "entities": {
    "Book": {
      ...
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "Book",
          "plural": "Books"
        },
        "operation": "query"
      },
      ...
    }
  }
}
```

### Walkthrough:

In this example, the entity defined is `Book`, indicating we're dealing with a set of data related to books in the database. The configuration for the `Book` entity within the GraphQL segment offers a clear structure on how it should be represented and interacted with in a GraphQL schema.

**Enabled property**: The `Book` entity is made available through GraphQL (`"enabled": true`), meaning developers and users can query or mutate book data via GraphQL operations.

**Type property**: The entity is represented with the singular name `"Book"` and the plural name `"Books"` in the GraphQL schema. This distinction ensures that when querying a single book or multiple books, the schema offers intuitively named types (`Book` for a single entry, `Books` for a list), enhancing the API's usability.

**Operation property**: The operation is set to `"query"`, indicating that the primary interaction with the `Book` entity through GraphQL is intended to be querying (retrieving) data rather than mutating (creating, updating, or deleting) it. This setup aligns with typical usage patterns where book data is more frequently read than modified.
