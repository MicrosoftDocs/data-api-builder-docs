---
title: What is Data API builder?
titleSuffix: Azure Databases
description: Learn about the Data API builder (DAB) tool to generate APIs using REST and GraphQL for Azure Databases.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: overview
ms.date: 06/11/2025
#Customer Intent: As a developer, I want to learn more about DAB, so that I can determine if it's the right tool for my scenario.
---

# What is Data API builder for Azure Databases?

:::row:::
  :::column span="3":::
    Data API builder (DAB) provides a REST API over a database. It also provides a GraphQL API. It supports not just SQL Server, but Azure SQL Database, Azure Cosmos DB, PostgreSQL, MySQL, and SQL Data Warehouse. DAB runs in any cloud or on-prem, and it is open source and free to use. It's secure, feature-rich, and a foundational component of Microsoft Fabric—which is another way of saying it’s high-performance and capable of handling massive data operations.

    Data API builder replaces most custom data APIs that perform generic CRUD (Create, Read, Update, Delete) operations against a database. DAB is independent of language, technology, and framework. It requires zero code and a single configuration file. Best of all, it’s truly free, with no premium tier, and runs statelessly anywhere.
  :::column-end:::
  :::column span="1":::
    :::image type="content" source="media/overview/mascot.png" alt-text="Illustration of the Data API builder mascot, which is a database with a construction hat featuring a cloud logo." border="false":::
  :::column-end:::
:::row-end:::

Data API builder is designed for developers. Data API builder features a cross-platform CLI, native OpenAPI, Swagger for REST endpoints, and Banana Cake Pop for GraphQL endpoints. Its stateless, Docker-friendly container can be secured with EasyAuth, Microsoft Entra ID, or any JSON Web Token (JWT) server an enterprise chooses. It has a flexible policy engine, granular security controls, and automatically passes claims data to the SQL session context.


Data API builder (DAB) supports multiple backend data sources simultaneously, including relational and NoSQL sources. DAB also integrates seamlessly with Application Insights. The configuration file can reflect relationships in the database or define new, virtual ones with support for hot reloading. GraphQL endpoints allow multiple nested Create statements within a single transaction, while REST endpoints feature in-memory caching and rich support for OData-like query string keywords.

DAB natively integrates with Azure Static Web Apps. It also works great with Azure Container Apps, Azure Container Instances, Azure Kubernetes Services, and Azure Web Apps for Containers. DAB works with these services while fully supporting custom, on-premises deployments.

DAB supports:

- SQL Server
- Azure SQL
- Azure Cosmos DB for NoSQL
- PostgreSQL
- Azure Database for PostgreSQL
- Azure Cosmos DB for PostgreSQL
- MySQL
- Azure Database for MySQL
- Azure SQL Data Warehouse

DAB can reduce a typical codebase by a third, eliminate suites of unit tests, shorten CI/CD pipelines, and introduce standards and advanced capabilities typically reserved for the largest development teams. It’s secure and feature-rich while remaining incredibly simple, scalable, and observable.

## Architecture

This diagram breaks down the relationship between all of the components of the Data API builder.

![Diagram that shows an overview of the Data API Builder architecture. The diagram includes schema files, abstractions, configuration files, and resulting GraphQL+REST endpoints.](media/overview/architecture.png)

## Key Features

- Support for NoSQL collections
- Support for relational tables, views, and stored procedures
- Support multiple, simultaneous data sources
- Support for authentication via OAuth2/JWT
- Support for EasyAuth and Microsoft Entra ID
- Role-based authorization using received claims
- Item-level security via policy expressions
- REST endpoints
  - POST, GET, PUT, PATCH, DELETE
  - Filtering, sorting, and pagination
  - In-memory cache
  - Support for OpenAPI
- GraphQL endpoints
  - Queries and mutations
  - Filtering, sorting and pagination
  - Relationship navigation
  - Dynamic schemas
- Easy development via dedicated CLI
- Integration for Static Web Apps via Database Connection
- Open Source & free

## Open source

Data API builder is open source and released under the MIT license. The repository is available on GitHub at [azure/data-api-builder](https://github.com/Azure/data-api-builder).

## Related content

- [Install the Data API builder CLI](how-to-install-cli.md)
- [Todo app sample with Data API builder, Azure Static Web Apps, and Azure SQL](https://github.com/azure-samples/dab-swa-todo)
- [Library app sample with Data API builder, Azure Static Web Apps, and Azure SQL](https://github.com/azure-samples/dab-swa-library-demo)
