---
title: Data API builder best practices
description: This doc lists the Data API builder best practices.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: best-practices
ms.date: 04/06/2023
---

# Data API builder best practices

Here are the recommended best practices for Data API Builder:

## Name entity using PascalCasing

When adding an entity to the configuration file, use PascalCasing, so that the generated GraphQL types are easier to read. For example, if you have an entity named `CompositeNameEntity` the generated GraphQL schema will have the following queries and mutations:

- Queries
  - `compositeNameEntities`
  - `compositeNameEntity_by_pk`
- Mutations
  - `createCompositeNameEntity`
  - `updateCompositeNameEntity`
  - `deleteCompositeNameEntity`

which are easier and nicer to read.

## Use singular form when naming entities

When adding an entity to the configuration file, make sure to use the singular form for the name. Data API builder will automatically generate the plural form whenever a collection of that entity is returned. You can also manually provide singular and plural forms, by manually adding them to the configuration file: [Configuration file - GraphQL type](./configuration-file.md#graphql-type)
