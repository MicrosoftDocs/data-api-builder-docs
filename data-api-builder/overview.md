---
title: What is Data API builder?
titleSuffix: Azure Databases
description: Learn about the Data API builder (DAB) tool to generate APIs using REST and GraphQL for Azure Databases.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: overview
ms.date: 03/20/2024
#Customer Intent: As a developer, I want to learn more about DAB, so that I can determine if it's the right tool for my scenario.
---

# What is Data API builder for Azure Databases?

Data API builder generates modern REST and GraphQL endpoints for your Azure Databases. Use Data API builder to securely expose API endpoints so that your data can be accessed using modern techniques from any platform, developer language, or device. Data API builder includes a flexible deeply integrated policy engine, granular security controls, and integration with popular Azure databases. Data API builder is open-source and it can be ran both for development workloads on your machines or production workloads in any cloud.

Use Data API builder with:

- Azure SQL
- SQL Server
- Azure Database for PostgreSQL
- Azure Database for MySQL
- Azure Cosmos DB for NoSQL

## Architecture

This diagram breaks down the relationship between all of the components of the Data API builder.

![Diagram that shows an overview of the Data API Builder architecture. The diagram includes schema files, abstractions, configuration files, and resulting GraphQL+REST endpoints.](./media/overview/architecture.png)

## Features

Here's a list of features that Data API builder supports for your workloads.

- Support for collections, tables, views, and stored procedures to be accessed via REST and GraphQL
- Support for authentication via OAuth2/JWT
- Support for EasyAuth when running in Azure
- Role-based authorization using received claims
- Item-level security via policy expressions
- REST
  - CRUD operations via POST, GET, PUT, PATCH, DELETE
  - Filtering, sorting, and pagination
  - Support for OpenAPI
- GraphQL
  - Queries and mutations
  - Filtering, sorting and pagination
  - Relationship navigation
- Easy development via dedicated CLI
- Fully integrated with Static Web Apps via Database Connection feature when running in Azure
- Open Source

## Open source

Data API builder is open source and released under the MIT license. The repository is available on GitHub at [azure/data-api-builder](https://github.com/Azure/data-api-builder).

## Related content

- [Install the Data API builder CLI](how-to-install-cli.md)
- [Todo app sample with Data API builder, Azure Static Web Apps, and Azure SQL](https://github.com/azure-samples/dab-swa-todo)
- [Library app sample with Data API builder, Azure Static Web Apps, and Azure SQL](https://github.com/azure-samples/dab-swa-library-demo)
