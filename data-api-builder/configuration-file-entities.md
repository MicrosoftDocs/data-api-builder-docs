---
title: Entities Basic Configuration
description: Part of the configuration documentation for Data API builder, focusing on Entities Basic Configuration.
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
1. [Entities.{entity}.rest](./configuration-file-entities-graphql.md)
1. [Entities.{entity}.graphql](./configuration-file-entities-rest.md)
1. [Entities.{entity}.relationships](./configuration-file-entity-relationships.md)
1. [Entities.{entity}.permissions](./configuration-file-entity-permissions.md)
1. [Entities.{entity}.policy](./configuration-file-entity-policy.md)
1. [Sample](./configuration-file-sample.md)

# Entities

## `entities` property

The `entities` section serves as the core of the configuration file, establishing a bridge between database objects and their corresponding API endpoints. It defines how each entity in the database is represented in the API, including property mappings and permissions. Each entity is encapsulated within its own subsection, with the entity's name acting as a key for reference throughout the configuration.

```json
{
  "entities" {
    "<entity-name>": { ... }
  }
}
```

**Example**

This example declare the `User` entity. This name `User` is used anywhere in the configuration file where entities are referenced. Otherwise the entity name is not relevant to the endpoints.

```json
{
  "entities" {
    "User": {
      ...
    }
  }
}
```

## `{entity}.source` property

The {entity}.source configuration is pivotal in defining the connection between the API-exposed entity and its underlying database object. This property specifies the database table, view, or stored procedure that the entity represents, establishing a direct link for data retrieval and manipulation.

**Simple Source Definition**

For straightforward scenarios, where the entity maps directly to a single database table or collection, the source property needs only the name of that database object. This simplicity facilitates quick setup for common use cases.

```json
{
  "entities" {
    "<entity-name>": {
      "source": "<database-object>",
      ...
    }
  }
}
```

When specifying a value for `source`, include the schema, for example "dbo.Users".

## `{entity}.type` property

The `type` property identifies the type of database object behind the entity, these include `view`, `table`, and `stored-procedure`. Some types require additional properties. The `type` property is required and there is not default value. 

**View**

Views require the `key-fields` property to be provided, so that Data API builder knows how it can identify and return a single item, if needed. If `type` is set to `view` without `key-fields`, the Data API builder engine will refuse to start.

## `{entity}.key-fields` property

The `{entity}.key-fields` setting is necessary for entities backed by views, so Data API builder knows how it can identify and return a single item, if needed. If `type` is set to `view` without `key-fields`, the Data API builder engine will refuse to start.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "type": "view",
      "key-fields": [ "<field-name>" ]
    }
  }
}
```

## `{entity}.parameters` property

The `{entity}.parameters` setting is important for entities backed by stored procedures, enabling developers to specify parameters and their default values. This ensures that if certain parameters are not provided within an HTTP request, the system can fall back to these predefined values.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "type": "stored-procedure",
      "parameters": {
        "<parameter-name-1>" : "<default-value>",
        "<parameter-name-2>" : "<default-value>",
        "<parameter-name-3>" : "<default-value>"
      }
    }
  }
}
```

## `{entity}.mappings` property

The `mappings` section enables configuring aliases, or exposed names, for database object fields. The configured exposed names apply to both the GraphQL and REST endpoints. For entities with GraphQL enabled, the configured exposed name must meet GraphQL naming requirements. [GraphQL - October 2021 - Names](https://spec.graphql.org/October2021/#sec-Names)

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "mappings": [
        "<field-1-alias>" : "<field-1-name>",
        "<field-2-alias>" : "<field-2-name>",
        "<field-3-alias>" : "<field-3-name>"
      ]
    }
  }
}
```

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

## `{entity}.rest` property

The `rest` section of the configuration file is dedicated to fine-tuning the RESTful endpoints for each database entity. This customization capability ensures that the exposed REST API matches specific requirements, improving both its utility and integration capabilities. It addresses potential mismatches between default inferred settings and desired endpoint behaviors.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "rest": {
        ...
      }
    }
  }
}
```

### `{entity}.rest.enabled` property

This property acts as a toggle for the visibility of entities within the REST API. By setting the `enabled` property to `true` or `false`, developers can control access to specific entities, enabling a tailored API surface that aligns with application security and functionality requirements.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "rest": {
        "enabled": true | false
      }
    }
  }
}
```

If omitted or missing, the default value of `enabled` is `true`. 

### `{entity}.rest.path` property

The `path` property specifies the URI segment used to access an entity via the REST API. This customization allows for more descriptive or simplified endpoint paths beyond the default entity name, enhancing API navigability and client-side integration.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "rest": {
        ...
        "path": "/entity-path"
      }
    }
  }
}
```

### `{entity}.rest.methods` property

Applicable specifically to stored procedures, the `methods` property defines which HTTP verbs (e.g., GET, POST) the procedure can respond to. This enables precise control over how stored procedures are exposed through the REST API, ensuring compatibility with RESTful standards and client expectations. This section underlines the platform's commitment to flexibility and developer control, allowing for precise and intuitive API design tailored to the specific needs of each application.

If omitted or missing, the `methods` default is `POST`. 

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "rest": {
        ...
        "methods": [ "GET", "POST" ]
      }
    }
  }
}
```