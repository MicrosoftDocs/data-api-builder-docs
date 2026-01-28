---
title: What is Data API builder?
titleSuffix: Azure Databases
description: Learn about the Data API builder (DAB) tool to generate APIs using REST and GraphQL for Azure Databases.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: overview
ms.date: 01/08/2026
#Customer Intent: As a developer, I want to learn more about DAB, so that I can determine if it's the right tool for my scenario.
---

# What is Data API builder for Azure Databases?

:::row:::
  :::column span="3":::
    Data API builder (DAB) is an open source, configuration-based engine that creates REST and GraphQL APIs for supported databases such as SQL Server, Azure Cosmos DB, PostgreSQL, and MySQL. DAB runs in any cloud or on-premises, and it's free to use. You configure it using a single JSON file, so you can expose database objects without writing a custom API.
  :::column-end:::
  :::column span="1":::
    :::image type="content" source="media/overview/mascot.png" alt-text="Illustration of the Data API builder mascot wearing a construction hat." border="false":::
  :::column-end:::
:::row-end:::

Data API builder replaces most custom data APIs that perform generic CRUD (Create, Read, Update, Delete) operations against a database. DAB is independent of language, technology, and framework. It requires no application code and a single configuration file. Best of all, it’s truly free, with no premium tier, and runs statelessly anywhere.

## Endpoint support

Data API builder supports both REST and GraphQL endpoints out of the box and simultaneously. With version 1.7 and later, DAB also supports [Model Context Protocol (MCP) for agent apps](mcp/overview.md) with the same rich functionality.

![Diagram of endpoint support in Data API builder.](media/overview/endpoint-support.svg)

DAB includes a cross-platform CLI, OpenTelemetry, and health checks. It also supports OpenAPI and Swagger for REST endpoints and Nitro (previously called Banana Cake Pop) for GraphQL endpoints.

> [!TIP]
> Out-of-the-box endpoint features:
>
> - Data Pagination
> - Data Filtering
> - Data Sorting
> - Column Selection
> - Stored Procedures
> - Relationship navigation
> - Aggregation for SQL family databases

## Database support

Data API builder (DAB) supports multiple backend data sources simultaneously, including relational and NoSQL sources. Supported databases include SQL Server and Azure SQL, Azure Cosmos DB, PostgreSQL, and MySQL. For details and limitations by database, see [Feature availability](feature-availability.md).

![Diagram of supported databases for Data API builder.](media/overview/supported-databases.svg)

Data API builder can connect to multiple data sources at the same time. You can combine relational sources with JSON or document databases and mix cloud and on-premises databases. This flexibility lets DAB support everything from simple setups to complex deployment topologies.

## Security

Data API builder's stateless, Docker-friendly container can be secured with Azure App Service EasyAuth, Microsoft Entra ID, or any JSON Web Token (JWT) server. It has a flexible policy engine, granular security controls, and automatically passes claims data to the SQL session context.

![Diagram of authentication options for Data API builder.](media/overview/authentication-options.svg)

Data API builder supports multiple authentication providers:

| Provider | Use case |
|----------|----------|
| **Microsoft Entra ID** | Production apps using Microsoft identity |
| **Custom JWT** | Third-party identity providers (Okta, Auth0, Keycloak) |
| **App Service** | Apps running behind Azure App Service EasyAuth |
| **Simulator** | Local development and testing |

For step-by-step configuration guides, see [Security overview](concept/security/index.md).

## Architecture

This diagram breaks down the relationship between all of the components of the Data API builder. It starts with the database schema, which defines tables, views, and stored procedures. The DAB configuration file projects these objects into an abstraction layer. In that layer, you name entities, select or alias fields, define relationships, and apply permissions. At runtime, Data API builder reads this configuration to generate a consistent API surface, exposing the same entity model through REST and GraphQL endpoints. This separation lets you evolve the database independently while keeping a stable, secure contract for applications and clients.

![Diagram of the Data API builder architecture.](media/overview/architecture.svg)

You configure Data API builder with a single JSON file. In the file, you define:

- How the server connects to data sources
- Which tables, views, and stored procedures are exposed
- How entities are shaped, named, and related
- Which roles are allowed to access each operation

## Deployment options

![Diagram of container hosting options for Data API builder.](media/overview/container-service.svg)

DAB works great with Azure Container Apps, Azure Container Instances, Azure Kubernetes Service, and Azure Web Apps for Containers. DAB works with these services while fully supporting custom, on-premises deployments.

## Integrations and capabilities

DAB also integrates seamlessly with Application Insights. The configuration file can reflect relationships in the database or define new, virtual ones with support for hot reloading. GraphQL endpoints allow multiple nested Create statements within a single transaction, while REST endpoints feature in-memory caching and rich support for OData-like query string keywords.

## Less code, more features

DAB can help reduce custom API code, shorten CI/CD pipelines, and introduce standards and advanced capabilities typically reserved for the largest development teams. It’s secure and feature-rich while remaining incredibly simple, scalable, and observable.

## Open source

Data API builder is open source and released under the MIT license. The repository is available on GitHub at [azure/data-api-builder](https://github.com/Azure/data-api-builder).

