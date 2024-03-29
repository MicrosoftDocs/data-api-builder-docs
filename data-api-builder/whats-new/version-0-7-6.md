---
title: What's new for version 0.7.6
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 0.7.6.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 03/28/2024
---

# What's new in Data API builder version 0.7.6

This article describes the release notes for the 0.7.6 release.

## Initial Support for OpenAPI v3-0-1 description document creation

Data API builder supports the OpenAPI standard for generating and exposing description docs that contain useful information about the service. These docs are created from the runtime configuration file and the metadata for each database object. These objects are associated with a REST enabled entity defined in that same configuration file. They're then exposed through a UI and made available as a serialized file.

For more information about the specifics of OpenAPI and Data API builder, see [OpenAPI](../openapi.md).

## Allowing merger of configuration files

Adds the ability to automatically merge two configuration files.

It's possible to maintain multiple pairs of baseline and environment specific configuration files to simplify management of the environment specific settings. For example, it's possible to maintain separate configurations for **Development** and **Production**. This step involves having a base configuration file that has all of the common settings between the different environments. Then by setting the `DAB_ENVIRONMENT` variable it's possible to control which configuration files to merge for consumption by Data API builder.

For more information, see [CLI reference](../reference-cli.md).

## Executing GraphQL and REST Mutations in a transaction

Data API builder creates database transactions to execute certain types of GraphQL and REST requests.

There are many requests, which involve making more than one database query to accomplish. For example to return the results from an update, first a query for the update must be made, then the new values must be read before being returned. When a request requires multiple database queries to execute, Data API builder now executes these database queries within a single transaction.

You can read more about this capability within the context of REST [in the REST documentation](../rest.md#database-transactions-for-rest-api-requests) and of GraphQL [in the GraphQL documentation](../graphql.md#database-transactions-for-a-mutation).

## Bug Fixes

- [Address filter access deny issue for Cosmos](https://github.com/Azure/data-api-builder/pull/1436)
- [Bug fix for Azure Cosmos DB field auth when graphql is "true," include is "*"](https://github.com/Azure/data-api-builder/pull/1516)
