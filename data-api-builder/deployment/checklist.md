---
title: Deployment checklist
description: Review this checklist of items you should consider and collect before you start your Data API builder deployment.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: checklist
ms.date: 06/11/2025
---

# Deployment checklist for Data API builder

:::image type="complex" source="media/checklist/map.svg" border="false" alt-text="Diagram of the current location ('Plan') in the sequence of the deployment guide.":::
Diagram of the sequence of the deployment guide including these locations, in order: Overview, Plan, Prepare, Publish, Monitor, and Optimization. The 'Plan' location is currently highlighted.
:::image-end:::

Before deploying your Data API builder (DAB) solution, you should run through this quick checklist. This checklist includes section on gathering your connection information, deciding on which entities to expose, and deciding which features you wish to use in Data API builder.

## Gather database credentials

First, make sure that you have all of the details and credentials necessary to connect to your database from Data API builder across your environments. You could elect to connect to a separate development database while working on your solution, and then a production database once finalized.

| | Recommendation |
| --- | --- |
| **&#9744;** | **Determine if your preferred database platform and version are supported.** Review the [database version support](../reference-database-specific-features.md#database-version-support) table to identify the minimum supported version for each database. Consider this minimum version in both your local and deployed instances of the database. |
| **&#9744;** | **Obtain your database connection string.** Get the connection string for all instances of the database you plan to connect to. We recommend using the [environment variable function (`@env`)](../reference-functions.md#env) in the DAB configuration file and then setting your connection string using environment variables. In local development, you can optionally use an *.env* file. |
| **&#9744;** | **Configure your database for passwordless authentication.** We highly recommend not using plaintext username and password credentials whenever possible. For Azure-based deployments, use [managed identities](/entra/identity/managed-identities-azure-resources) to connect from the DAB host in development or production to your database. This configuration produces a connection string that only contains the endpoint of the database. Secure your solution further by storing the connection string in an [Azure Key Vault](/azure/key-vault) instance and referencing it using the `@env` function. |

## Plan the exposed entities

Next, determine which specific entities you wish to expose as APIs. Plan for any relationships between these entities. Ideally, you can produce an entity diagram to make it clear to consumers of your API which entities are related to each other and how they're related.

| | Recommendation |
| --- | --- |
| **&#9744;** | **Produce a list of entities to expose as API endpoints.** List out any database entities that you wish to explicitly expose as endpoints using DAB. DAB doesn't expose entities implicitly, so it's imperative that you determine ahead of time which entities to manually expose through the configuration file and the [`dab add`](../reference-command-line-interface.md#add) CLI command. Alternatively, you can write a custom database query to find all entities in your database and then generate the appropriate corresponding CLI commands. |
| **&#9744;** | **Document any relationships between entities.** Relationships between entities must be defined in the configuration file. For more information, see [relationships](../relationships.md). |

## Decide which features to use

Finally, decide if you want to use Data API builder with all default features enabled, or if you want to further customize the configuration of the engine.

| | Recommendation |
| --- | --- |
| **&#9744;** | **Decide if you want to use REST, GraphQL or both API types.** By default, DAB enables both REST and GraphQL endpoints. You can customize each endpoint by enabling or disabling either the [`runtime.graphql.enabled`](../reference-configuration.md#enabled-graphql-runtime) or the [`runtime.rest.enabled`](../reference-configuration.md#enabled-rest-runtime) configuration properties respectively. For more information on GraphQL, see [host GraphQL endpoints](../graphql.md). For more information on REST, see [host REST endpoints](../rest.md).  |
| **&#9744;** | **Select REST and GraphQL features that you wish to enable.** Each endpoint type "ships" with multiple features enabled out of the box and a default configuration. For example, the default REST endpoint URI is `/data`, but it can be customized using the [`runtime.rest.path`](../reference-configuration.md#path-rest-runtime) property. Similarly, the default GraphQL endpoint URI is `/query` and that's customizable using the [`runtime.graphql.path`](../reference-configuration.md#path-graphql-runtime) property. You can customize more aspects of each endpoint including, but not limited to; mutations, introspection, and request body. For more information on GraphQL endpoint customization, see [GraphQL configuration settings](../reference-configuration.md#graphql-runtime). For more information on REST endpoint customization, see [REST configuration settings](../reference-configuration.md#rest-runtime). |
| **&#9744;** | **Plan for Swagger UI and Banana Cake Pop.** When Data API builder is running in *Development* host mode, the engine exposes the [Swagger UI](https://swagger.io/swagger-ui) and [Banana Cake Pop](https://chillicream.com/products/bananacakepop) developer UI experiences. |

## Next step

> [!div class="nextstepaction"]
> [Hosting options](hosting-options.md)
