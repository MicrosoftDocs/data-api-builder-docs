---
title: Overview to Azure data API builder
description: In this overview, we help you get started with Data API builder (DAB) for Azure Databases
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: overview
ms.date: 02/22/2023
---

# What is Data API builder?

**Data API builder for Azure Databases provides modern REST and GraphQL endpoints to your Azure Databases.**

With Data API builder, database objects can be securely exposed via REST or GraphQL endpoints so that your data can be accessed using modern techniques on any platform, any language, and any device. With an integrated and flexible policy engine, granular security is assured; integrated with Azure SQL, SQL Server, PostgreSQL, MySQL and Cosmos DB, gives developers an efficiency boost like never seen before.

Data API builder is Open Source and works on any platform. It can be executed on-premises, in container or as a Managed Service in Azure, via the new *Database Connection* feature available in Azure Static Web Apps.

![Data API Builder Architecture Overview Diagram](./media/data-api-builder-architecture-overview.png)

## Features

- Allow collections, tables, views and stored procedures to be accessed via REST and GraphQL
- Support authentication via OAuth2/JWT
- Support for EasyAuth when running in Azure
- Role-based authorization using received claims
- Item-level security via policy expressions
- REST
  - CRUD operations via POST, GET, PUT, PATCH, DELETE
  - filtering, sorting and pagination
- GraphQL
  - queries and mutations
  - filtering, sorting and pagination
  - relationship navigation
- Easy development via dedicated CLI
- Full integration with Static Web Apps via Database Connection feature when running in Azure
- Open Source

## Installation

Data API builder is built using .NET Core and is distributed as a NuGet package. It can be easily download and installed via `dotnet tool` install command:

```shell
dotnet tool install -g Microsoft.DataApiBuilder
```

if you've already installed the tool, you can update it to the latest version with the following command:

```shell
dotnet tool update -g Microsoft.DataApiBuilder
```

Data API builder requires .NET Core 6 to run. If you don't have it installed, you can download it from [here](https://dotnet.microsoft.com/download/dotnet/6.0). If you're using Ubuntu 22, take a look at the [Troubleshooting](./troubleshooting.md) page if you're having issues.

## Run Data API builder on-premises

Data API builder comes with a friendly CLI interface that allows the configuration of everything needed to securely create REST and GraphQL endpoints for your database.

```shell
dab init --database-type mssql --connection-string "Server=localhost;Database=Library;"
dab add Book --source dbo.Books --permissions "anonymous:*"
dab start
```

## Run Data API builder on Azure

Data API builder can be deployed in Azure using the new *Database Connection* feature offered by Azure Static Web Apps. With this feature you don't have to worry about running Data API builder in Azure at all: it's all taken care of for you. You can find more information about this feature [here](/azure/static-web-apps/database-overview).

Another option to run Data API builder on Azure is to deploy it in a container. Data API builder image is available on the Microsoft Registry: https://mcr.microsoft.com/product/azure-databases/data-api-builder/about

## Getting started

To get started quickly with Data API builder for Azure Databases, you can use the [Getting Started](./getting-started/getting-started-with-data-api-builder.md) tutorial. The tutorial helps to get familiar with some basic tools and concepts while giving you a good experience on how much Data API builder for Azure Databases can make you more efficient, removing the need to write plumbing code.

## Open source

Data API builder is open source and released under the MIT license. The reposiority is available [here](https://github.com/Azure/data-api-builder)

## Next steps

Once you're familiar with the basic features of Data API builder, you want to dive into the [Authentication](https://github.com/Azure/data-api-builder/blob/main/docs/authentication.md) and [Authorization](https://github.com/Azure/data-api-builder/blob/main/docs/authorization.md) process, the details of the [configuration file](https://github.com/Azure/data-api-builder/blob/main/docs/configuration-file.md) that is at the core of Data API builder engine. You can also check out the [Best Practices](https://github.com/Azure/data-api-builder/blob/main/docs/best-practices.md) also make sure to check out the end-to-end samples available here: 
- [Jamstack Todo-List Sample](https://github.com/Azure-Samples/dab-swa-todo).
- [Jamstack Library Management Sample](https://github.com/Azure-Samples/dab-swa-library-demo)
