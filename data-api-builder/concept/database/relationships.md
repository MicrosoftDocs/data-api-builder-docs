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

# Entity Relationships

GraphQL queries can traverse related objects and their fields, so that with just one query you can write something like:

```graphql
{
  books
  {
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

To retrieve books and their authors.

To allow this ability to work, Data API builder needs to know how the two objects are related to each other. The `relationships` section in the configuration file provides the necessary metadata for making this ability work correctly and efficiently.

## Configuring a Relationship

No matter what database you're using with Data API builder, you have to explicitly tell Data API builder that an object is related to another one. There are three types of relationships that can be established between two entities:

- [Entity Relationships](#entity-relationships)
  - [Configuring a Relationship](#configuring-a-relationship)
    - [One-to-Many Relationship](#one-to-many-relationship)
    - [Many-to-One Relationship](#many-to-one-relationship)
    - [Many-To-Many Relationship](#many-to-many-relationship)
  - [Using a pair of One-to-Many/Many-to-One relationships](#using-a-pair-of-one-to-manymany-to-one-relationships)
  - [Using a linking object](#using-a-linking-object)

### One-to-Many Relationship

A one-to-many relationship allows an object to access a list of related objects. For example, a books series can allow access to all the books in that series:

```graphql
{
  series {
    items {
      name
      books {
        items {
          title
        }
      }
    }
  }
}
```

If there are Foreign Keys supporting the relationship between the two underlying database objects, you only need to tell Data API builder, that you want to expose such relationship. With DAB CLI:

```dotnetcli
dab update Series --relationship books --target.entity Book --cardinality many 
```

Which updates the `series` entity - used in the example:

```json
"Series": {
  "source": "dbo.series",
  ...
  "relationships": {
    "books": {
      "target.entity": "Book",
      "cardinality": "many"    
    }
  }
  ...
}
```

A new key is added under the `relationships` element: `books`. The element defines the name that is used for the GraphQL field to navigate from the `series` object to the object defined in the `target.entity`, `Book` in this case. This means that there must be an entity called `Book` in configuration file.

The `cardinality` property tells Data API builder that there can be many books in each series, so the created GraphQL field returns a list of items.

That property is all you need. At startup, Data API builder automatically detects the database fields that need to be used to sustain the defined relationship.

If you don't have a Foreign Key constraint sustaining the database relationship, Data API builder can't figure out automatically what fields are used. To tell Data API builder what fields relate the two entities, you must specify them manually. You can specify them with the CLI using [`dab update`](../../reference-command-line-interface.md#update):

```bash
dab update Series --relationship books --target.entity Book --cardinality many  --relationship.fields "id:series_id"
```

The option `relationship.fields` allows you to define which fields are used from the entity being updated (`Series`), and which fields are used from the target entity (`Book`), to connect the data from one entity to the other.

In the previous sample, the `id` database field of the `Series` entity is matched with the database field `series_id` of the `Book` entity.

The configuration also contains this information:

```json
"Series": {
  "source": "dbo.series",
  ...
  "relationships": {
    "books": {
      "cardinality": "many",
      "target.entity": "Book",
      "source.fields": ["id"],
      "target.fields": ["series_id"]
    }    
  }
  ...
}
```

### Many-to-One Relationship

A many-to-one relationship is similar to the One-To-Many relationship with two major differences:

- the `cardinality` is set to `one`
- the created GraphQL field returns a scalar not a list

Following the Book Series samples used before, a book can be in just one series, so the relationship is created using the following DAB CLI command:

```bash
dab update Book --relationship series --target.entity Series --cardinality one
```

Which generates this configuration:

```json
"Book": {
  "source": "dbo.books",
  ...
  "relationships": {       
    "series": {
      "target.entity": "Series",
      "cardinality": "one"
    }
  }
}
```

Which, in turn, allows a GraphQL query like this example:

```graphql
{
  books {
    items {
      id
      title    
      series {
        name
      }
    }
  }
}
```

Where each book returns also the series it belongs to.

### Many-To-Many Relationship

Many to many relationships can be seen as a pair of One-to-Many and Many-to-One relationships working together. An author can surely write more than one book (a One-to-Many relationship), but is also true that more than one author can work on the same book (a Many-to-One relationship).

Data API builder supports this type of relationship natively:

- Using a pair of One-to-Many/Many-to-One relationships.
- Using a *linking object*.

## Using a pair of One-to-Many/Many-to-One relationships

One business requirement that is likely to be there's to keep track of how royalties are split between the authors of a book. To implement such requirement a dedicated entity that links together an author, a book and the assigned royalties are needed. Three entities are therefore needed:

- `authors`, to represent biographical details of authors.
- `books`, to represent book data like title and International Standard Book Number (ISBN).
- `books_authors` to represent data that is related both to a book and to its author, for example, the percentage of royalties an author gets for a specific book.

The three entities can be visualized through the following diagram.

![Diagram showing many-to-many relationship between authors, books_authors and books.](../../media/relationship-many-to-many-01.png)

As visible, there are two bi-directional relationships:

- One-to-Many/Many-to-One relationship between `authors` and the `books_authors`
- One-to-Many/Many-to-One relationship between `books` and the `books_authors`

To handle such a scenario gracefully with DAB, all that is needed is to create the related entities and mappings in the configuration file. Assuming the `Book` and `Author` entity are already in the configuration file:

```dotnetcli
dab add BookAuthor --source dbo.books_authors --permissions "anonymous:*"
```

To add the new entity, run `dab update`:

```dotnetcli
dab update Book --relationship authors --target.entity BookAuthor --cardinality many --relationship.fields "id:book_id"
dab update Author --relationship books --target.entity BookAuthor --cardinality many --relationship.fields "id:author_id"
```

To add the relationships to the newly created `BookAuthor` entity, run `dab update` again:

```dotnetcli
dab update BookAuthor --relationship book --target.entity Book --cardinality one --relationship.fields "book_id:id"
dab update BookAuthor --relationship author --target.entity Author --cardinality one --relationship.fields "author_id:id"
```

To add the relationships from `BookAuthor` to `Book` and `Author` entities. With the provided configuration DAB is able to handle nested queries like this example:

```graphql
{
 authors {
    items {
      first_name
      last_name      
      books {
        items {
          book {
            id
            title
          }
          royalties_percentage
        }
      }      
    }
  }
}
```

Where you're asking to return all the authors, the book they wrote along with the related royalties.

## Using a linking object

The process described in the previous section works great if all the entities involved in the Many-to-Many relationships need to be accessed via GraphQL. This scenario isn't always the case. For example, if you don't need to keep track of royalties, the `BookAuthor` entity doesn't really bring any value to the end user. The entity was only used to associated books to their authors. In relational databases Many-to-Many relationships are created using such third table that *links* the tables participating in the Many-to-Many relationship together:

![Diagram showing another many-to-many relationship between authors, books_authors and books.](../../media/relationship-many-to-many-02.png)

In the diagram, you can see that there's a table named `books_authors` that is linking authors with their books and books with their authors. This linking table doesn't need to be exposed to the end user. The linking table is just an artifact to allow the Many-to-Many relationship to exist, but Data API builder needs to know its existence in order to properly use it.

DAB CLI can be used to create the Many-to-Many relationship and also configure the linking object (make sure to remove all the relationships created in the previous section and start only with the `Book` and `Author` entity with no configured relationship between them already):

```bash
dab update Book --relationship authors --target.entity Author --cardinality many --relationship.fields "id:id" --linking.object "dbo.books_authors" --linking.source.fields "book_id" --linking.target.fields "author_id" 
```

Which updates the JSON configuration file to be like this example:

```json
"Book": {
  "source": "dbo.books",
  ...
  "relationships": {       
    "authors": {
      "cardinality": "many",
      "target.entity": "author",
      "source.fields": [ "id" ],
      "target.fields": [ "id" ],
      "linking.object": "dbo.books_authors",
      "linking.source.fields": [ "book_id" ],
      "linking.target.fields": [ "author_id" ]
    }
  }
}
```

The configuration is telling DAB that you want to add a `authors` field in the `Book` entity that allows access to authors of the book. `authors` can be `many`, so a list of authors is returned when the GraphQL query accesses the `authors` field. This relationship defines how to navigate *from* books *to* authors:  the database fields used to navigate from books to their authors are defined in the `source.fields` for the book, and in the `target.fields` for the authors, similarly to the One-to-Many or Many-to-One relationship described previously in this article.

This relationship is a Many-to-Many relationship, so there's no direct connection between the two entities and so a `linking.object` needs to be used. In the sample, the database table `dbo.books_authors` is used as the linking object. How the linking object is able to connect books to their authors is defined in the `linking.source.fields` and `linking.target.fields` properties. The first one tells DAB how the source entity - the `Book` - is connected to the liking object, and the second one how the linking object is connected to the target entity, `Author` in the sample.

To understand how the provided information is used, you can use this example equivalent query:

```sql
select * 
from dbo.books as b
inner join dbo.books_authors as ba on b.id = ba.book_id 
inner join dbo.authors a on ba.author_id = a.id 
```

With the provided configuration DAB is able to understand GraphQL like this example:

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

Where you want to get books and their authors.

To allow navigation from `Author` to `Book`, the same principles can be applied, updating the configuration using the following command:

```bash
dab update Author --relationship books --target.entity Book --cardinality many --relationship.fields "id:id" --linking.object "dbo.books_authors" --linking.source.fields "author_id" --linking.target.fields "book_id" 
```

Which defines a Many-to-Many relationship between the `Author` entity and the `Book` entity, using the linking object `dbo.books_authors` behind the scenes.

## Related content

- [GraphQL](../graphql.md)
- [GraphQL - configuration schema](../../reference-configuration.md#graphql-entities)
