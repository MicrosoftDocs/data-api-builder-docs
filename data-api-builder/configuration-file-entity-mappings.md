---
title: Entities Mapping Configuration
description: Part of the configuration documentation for Data API builder, focusing on Entities Basic Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

# `{entity}.mappings`

The `mappings` section enables configuring aliases, or exposed names, for database object fields. The configured exposed names apply to both the GraphQL and REST endpoints. For entities with GraphQL enabled, the configured exposed name must meet GraphQL naming requirements. [GraphQL - October 2021 - Names](https://spec.graphql.org/October2021/#sec-Names)

## Overview

```json
{
  ...
  "entities" {
    "<entity-name>": {
      "rest":{ ... },
      "graphql": { ... },
      "source": { ... },
      "mappings": {
        "<field-1-alias>" : "<field-1-name>",
        "<field-2-alias>" : "<field-2-name>",
        "<field-3-alias>" : "<field-3-name>"
      }
    }
  }
}
```

### Example

```json
{
  "entities": {
    "Book": {
      "mappings": {
        "id": "BookID",
        "title": "BookTitle",
        "author": "AuthorName"
      }
    }
  }
}
```

### Walkthrough:

In this refined example for the `Book` entity, the `mappings` section is utilized to define how fields in the database map to names exposed through the API, applicable for both GraphQL and REST interfaces.

**Mappings**: The `mappings` object links the database fields (`BookID`, `BookTitle`, `AuthorName`) to more intuitive or standardized names (`id`, `title`, `author`) that will be used externally. This aliasing serves several purposes:

  - **Clarity and Consistency**: It allows for the use of clear and consistent naming across the API, regardless of the underlying database schema. For instance, `BookID` in the database is simply represented as `id` in the API, making it more intuitive for developers interacting with the endpoint.
  
  - **GraphQL Compliance**: By providing a mechanism to alias field names, it ensures that the names exposed through the GraphQL interface comply with GraphQL naming requirements. This is critical because GraphQL has strict rules about names (e.g., no spaces, must start with a letter or underscore, etc.). For example, if a database field name does not meet these criteria, it can be aliased to a compliant name through mappings.
  
  - **Flexibility**: This aliasing adds a layer of abstraction between the database schema and the API, allowing for changes in one without necessitating changes in the other. For instance, a field name change in the database does not require an update to the API documentation or client-side code if the mapping remains consistent.

  - **Field Name Obfuscation**: Mapping allows for the obfuscation of field names, which can help prevent unauthorized users from inferring sensitive information about the database schema or the nature of the data stored.

  - **Protecting Proprietary Information**: By renaming fields, you can also protect proprietary names or business logic that may be hinted at through the database's original field names.