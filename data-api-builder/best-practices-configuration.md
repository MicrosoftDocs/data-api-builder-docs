---
title: Configuration best practices
description: Review a list of current best practices and recommendations for the configuration metadata in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 04/01/2024
# Customer Intent: As a developer, I want to review best practices, so that I can configure my API using current best practices.
---

# Configuration best practices in Data API builder

This article includes the current recommended best practices for configuration in the Data API builder. This article doesn't include an exhaustive list of everything you must configure for your Data API builder solution.

## Name entities using Pascal casing

When adding an entity to the configuration file, use PascalCasing, so that the generated GraphQL types are easier to read. For example, if you have an entity named `CompositeNameEntity` the generated GraphQL schema has the following queries and mutations:

- Queries
  - `compositeNameEntities`
  - `compositeNameEntity_by_pk`
- Mutations
  - `createCompositeNameEntity`
  - `updateCompositeNameEntity`
  - `deleteCompositeNameEntity`

- If the entity maps to a stored procedure, the generated query or mutation would be named `executeCompositeNameEntity`, which is easier and nicer to read.

## Use singular form when naming entities

When adding an entity to the configuration file, make sure to use the singular form for the name. Data API builder automatically generates the plural form whenever a collection of that entity is returned. You can also manually provide singular and plural forms, by manually adding them to the configuration file: [Configuration file - GraphQL type](configuration-file.md#graphql-type)

## Related content

- [Configuration reference](reference-configuration.md)
- [Best practices security](best-practices-security.md)
