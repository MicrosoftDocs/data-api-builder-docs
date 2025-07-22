---
title: Entity relationships
description: Review GraphQL-specific relationships in Data API builder and how you can define, map, or manage them.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 06/11/2025
# Customer Intent: As a developer, I want to use relationships, so that I can better "shape" my GraphQL representation of my data.
---

# Entity relationships in Data API builder

Entity relationships allow GraphQL queries to traverse related entities, enabling complex data shapes with a single query. For example:

```graphql
{
  books {
    items {
      id
      title
      authors {
        items {
          first_name
          last_name
        }
      }
    }
  }
}
```

To achieve this, DAB must be told how entities are related via the [`relationships` section](../../configuration/entities.md#relationships) in the configuration file.

## Configuration

To define a relationship between entities:

* Use the `relationships` object inside the entity configuration.
* Provide the `target.entity` name.
* Set `cardinality` as `"one"` or `"many"`.
* Optionally specify `source.fields` and `target.fields`.
* Use `linking.object` when modeling many-to-many relationships without exposing the join table.

### CLI example

```sh
dab update Book \
  --relationship authors \
  --target.entity Author \
  --cardinality many \
  --relationship.fields "id:id" \
  --linking.object "dbo.books_authors" \
  --linking.source.fields "book_id" \
  --linking.target.fields "author_id"
```

### Configuration example

```json
"Book": {
  "source": "dbo.books",
  "relationships": {
    "authors": {
      "cardinality": "many",
      "target.entity": "Author",
      "source.fields": [ "id" ],
      "target.fields": [ "id" ],
      "linking.object": "dbo.books_authors",
      "linking.source.fields": [ "book_id" ],
      "linking.target.fields": [ "author_id" ]
    }
  }
}
```

## One-to-Many

* Use cardinality `"many"`.
* Example: A `Series` has many `Books`.
* DAB can infer fields if a foreign key exists.

```sh
dab update Series \
  --relationship books \
  --target.entity Book \
  --cardinality many
```

## Many-to-One

* Use cardinality `"one"`.
* Example: A `Book` belongs to one `Series`.

```sh
dab update Book \
  --relationship series \
  --target.entity Series \
  --cardinality one
```

## Many-to-Many (linking object)

* Use a join table that is not exposed in GraphQL.
* Define linking fields from source to target via the join table.

```sh
dab update Author \
  --relationship books \
  --target.entity Book \
  --cardinality many \
  --relationship.fields "id:id" \
  --linking.object "dbo.books_authors" \
  --linking.source.fields "author_id" \
  --linking.target.fields "book_id"
```

## Many-to-Many (explicit join entity)

* Expose the join table as a GraphQL object.
* Define relationships on all three entities.

```sh
dab add BookAuthor \
  --source dbo.books_authors \
  --permissions "anonymous:*"

dab update BookAuthor \
  --relationship book \
  --target.entity Book \
  --cardinality one \
  --relationship.fields "book_id:id"

dab update BookAuthor \
  --relationship author \
  --target.entity Author \
  --cardinality one \
  --relationship.fields "author_id:id"
```

## Reciprocal relationships

To allow navigation in both directions (for example, from `Book` to `Author` and from `Author` to `Book`), define a second relationship on the target entity that reverses the source and target fields.

### Example

```sh
dab update Author \
  --relationship books \
  --target.entity Book \
  --cardinality many \
  --relationship.fields "id:id" \
  --linking.object "dbo.books_authors" \
  --linking.source.fields "author_id" \
  --linking.target.fields "book_id"
```

This pairs with the `Book` to `Author` relationship and enables symmetric traversal in GraphQL:

```graphql
{
  authors {
    items {
      first_name
      books {
        items {
          title
        }
      }
    }
  }
}
```

## GraphQL support

* Related fields appear as nested objects.
* Cardinality determines whether a list or single object is returned.
* GraphQL type names and fields match configuration names.

## Limitations

* Relationships require entities to exist in the same config file.
* Only one-hop navigation is supported.
* Cycles and deep nesting aren't optimized.
* REST doesn't support relationships (GraphQL only).