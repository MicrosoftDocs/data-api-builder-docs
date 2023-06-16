---
title: Release notes for Data API builder 0.7.6
description: Release notes for Data API builder 0.7.6 are available here.
author: aaronburtle 
ms.author: aaronburtle
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 06/12/2023
---
# What's New in Data API builder 0.7.6

- [Adding Merge config capabilities](#allowing-merger-of-configuration-files)
- [Executing GraphQL and REST Mutations in a transaction](#executing-graphql-and-rest-mutations-in-a-transaction)
- [Initial Support for OpenAPI v3.0.1 description document creation](#initial-support-for-openapi-v3-0-1-description-document-creation)
- [Bug Fixes](#bug-fixes)

## Initial Support for OpenAPI v3-0-1 description document creation
Data API builder supports the OpenAPI standard for generating and exposing description docs that contain useful information about the service. These are created from the runtime configuration file and the metadata for each database object associated with a REST enabled entity defined in that same configuration file. They are then exposed through a UI and made available as a serialized file.

To read more about the specifics of OpenAPI and how it is used with Data Api builder please [see this document.](./openapi.md)


## Allowing merger of configuration files
Adds the ability to automatically merge two configuration files.

It is possible to maintain multiple pairs of baseline and environment specific configuration files to simplify management of the environment specific settings. For example, it is possible to maintain separate configurations for **Development** and **Production**. This involves having a base configuration file that has all of the common settings between the different environments. Then by setting the `DAB_ENVIRONMENT` variable it is possible to control which configuration files are merged for consumption by Data Api builder.

Additional information can be found [in this document.](./data-api-builder-cli.md#using-data-api-builder-with-two-configuration-files)

## Executing GraphQL and REST Mutations in a transaction
Data API builder creates database transactions to execute certain types of GraphQL and REST requests.

There are a number of requests which involve making more than one database query to accomplish. For example to return the results from an update, first a query for the update must be made, then the new values must be read before being returned. When a request requires multiple database queries to execute, Data Api builder now executes these database queries within a single transaction.

You can read more about this within the context of REST [in this document](./rest.md#database-transactions-for-rest-api-requests) and of GraphQL [in this document.](./graphql.md#database-transactions-for-a-mutation)


## Bug Fixes
- [Address filter access deny issue for Cosmos](https://github.com/Azure/data-api-builder/pull/1436)
- [Bug fix for CosmosDB field auth when graphql is "true", include is "*"](https://github.com/Azure/data-api-builder/pull/1516)





