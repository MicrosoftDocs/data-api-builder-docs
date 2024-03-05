---
title: Entities Graphql Configuration
description: Part of the configuration documentation for Data API builder, focusing on Entities Graphql Configuration.
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

# Entity GraphQL

## `{entity}.graphql` property

This segment provides the necessary customization options for integrating an entity into the GraphQL schema. It allows developers to specify or modify default values for the entity's representation in GraphQL, ensuring that the schema accurately reflects the intended structure and naming conventions.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "graphql": {
        ...
      }
    }
  }
}
```

### `{entity}.graphql.enabled` property

This setting controls whether an entity is available via GraphQL endpoints. By toggling the `enabled` property, developers can selectively expose or hide entities from the GraphQL schema, offering flexibility in API design and access control.

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

### `{entity}.graphql.type` property

This property dictates the naming convention for an entity within the GraphQL schema. It supports both scalar string values for direct scalar naming and object types for specifying singular and plural forms, providing granular control over the schema's readability and user experience.

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

For even greater control over the GraphQL type, you can configure how the singular and plural name is represented independently. This is not required but can deliver a curated user experience. If `plural` is missing or omitted (like in the case of the scalar value) Data API builder tries to pluralize the name automatically, following the English rules for pluralization (for example: https://engdic.org/singular-and-plural-noun-rules-definitions-examples)

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

### `{entity}.graphql.operation` property

For entities mapped to stored procedures, the `operation` property designates the GraphQL operation type (query or mutation) where the stored procedure is accessible. This allows for logical organization of the schema and adherence to GraphQL best practices, without impacting functionality.

> An entity is specified to be a stored procedure by setting the `{entity}.type` property value to `stored-procedure`. In the case of a stored procedure, a new GraphQL type executeXXX is automatically created. However, the `operation` property allows the developer to coerse the location of that type into either the `mutation` or `query` parts of the schema. This property allows for schema hygene and there is no functional impact regardless of `operation` value.  

If ommitted or missing, the `operation` default is `mutation`.

**Mutation example**

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "graphql":{
        ...
        "operation": "mutation"
      }
    }
  }
}
```

The Graph QL schema would resemble:

```graphql
type Mutation {
  executeGetCowrittenBooksByAuthor(
    searchType: String = "S"
  ): [GetCowrittenBooksByAuthor!]!
}
```

**Query example**

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "graphql":{
        ...
        "operation": "query"
      }
    }
  }
}
```

The Graph QL schema would resemble:

```graphql
type Query {
  executeGetCowrittenBooksByAuthor(
    searchType: String = "S"
  ): [GetCowrittenBooksByAuthor!]!
}
```