---
title: Overview Configuration Entities
description: Overviews the entites property in Configuration
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/27/2024
---

# Entities

The `entities` section serves as the core of the configuration file, establishing a bridge between database objects and their corresponding API endpoints. It defines how each entity in the database is represented in the API, including property mappings and permissions. Each entity is encapsulated within its own subsection, with the entity's name acting as a key for reference throughout the configuration.

## Syntax overview

```json
{
  "entities": {
    "entity-name": {
      "rest": {
        "enabled": true (default) | false,
        "path": "/entity-path",
        "methods": ["GET", "POST"]
      },
      "graphql": {
        "enabled": true (default) | false,
        "type": {
          "singular": "myEntity",
          "plural": "myEntities"
        },
        "operation": "query" | "mutation"
      },
      "source": {
        "object": "database-object-name",
        "type": "view" | "stored-procedure" | "table",
        "key-fields": ["field-name"],
        "parameters": {
          "parameter-name": "parameter-value"
        }
      },
      "mappings": {
        "field-alias": "database-field-name"
      },
      "relationships": {
        "relationship-name": {
          "cardinality": "one" | "many",
          "target.entity": "target-entity-name",
          "source.fields": ["source-field-name"],
          "target.fields": ["target-field-name"],
          "linking.object": "linking-object-name",
          "linking.source.fields": ["linking-source-field-name"],
          "linking.target.fields": ["linking-target-field-name"]
        }
      },
      "permissions": [
        {
          "role": "anonymous | authenticated | custom-role-name",
          "actions": ["create" | "read" | "update" | "delete" | "*"],
          "fields": {
            "include": ["field-name"],
            "exclude": ["field-name"]
          },
          "policy": {
            "database": "<Expression>"
          }
        }
      ]
    }
  }
}
```

## Example

The example declares the `User` entity. This name `User` is used anywhere in the configuration file where entities are referenced. Otherwise the entity name isn't relevant to the endpoints.

```json
{
  "entities": {
    "Book": {
      "rest": {
        "enabled": true,
        "path": "/books",
        "methods": ["GET", "POST", "PUT"]
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "Book",
          "plural": "Books"
        },
        "operation": "query"
      },
      "source": {
        "object": "BooksTable",
        "type": "table",
        "key-fields": ["Id"],
        "parameters": {}
      },
      "mappings": {
        "id": "Id",
        "title": "Title",
        "authorId": "AuthorId"
      },
      "permissions": [
        {
          "role": "authenticated",
          "actions": ["read"],
          "fields": {
            "include": ["id", "title"],
            "exclude": []
          },
          "policy": {
            "database": "@claims.userId eq @item.authorId"
          }
        },
        {
          "role": "admin",
          "actions": ["create", "read", "update", "delete"],
          "fields": {
            "include": ["*"],
            "exclude": []
          },
          "policy": {
            "database": "@claims.userRoles has 'BookAdmin'"
          }
        }
      ]
    }
  }
}
```

### Walkthrough

**[REST](entity-rest.md) & [GraphQL](entity-graphql.md) Configurations**: Define how the `Book` entity is exposed through RESTful endpoints and GraphQL queries, specifying paths, enabled methods, and operations.

**[Source](entity-source.md)**: Identifies the database table (`BooksTable`) associated with the `Book` entity, including the primary key and any parameters for querying the database.

**[Mappings](entity-mappings.md)**: Links entity fields (`id`, `title`, `authorId`) to their corresponding database column names, ensuring correct data translation between the API and the database.

**[Permissions](entity-permissions.md)**: Outlines role-based access control, detailing which roles can perform specified actions (`read`, `create`, `update`, `delete`) on the entity's fields. Includes field-level access control through `include` and `exclude` lists.

**[Policy](entity-policy.md)**: Specifies item-level security rules using database policy expressions. These expressions determine access to entity records based on conditions involving user claims and entity fields, enforcing row-level security.