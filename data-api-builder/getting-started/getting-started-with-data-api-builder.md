---
title: Quickstart to Azure data API builder
description: In this quickstart, we help you get started with Data API builder (DAB) for Azure Databases
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 02/22/2023
---

# Quickstart: Build modern end point support with Data API builder for Azure Databases

Welcome! This guide helps you get started with Data API builder (DAB) for Azure Databases. First you're going to get DAB running locally on your machine. It then uses DAB to create an API for your application using the Azure Database of your choice.

## Use case scenario

In this tutorial we're creating the backend API for a small solution that allows end-users to keep track of books in their bookshelf. Therefore, the business entities we're dealing with are:

- Books
- Authors

Both the business entities need a modern endpoint, REST and/or GraphQL, to allow third party developers to build mobile and desktop applications to manage the library catalog. Data API builder is perfect for enabling that modern endpoint support.

## Prerequisites

### .NET 6 SDK

Make sure you have .NET 6.0 SDK installed on your machine (https://dotnet.microsoft.com/en-us/download/dotnet/6.0.)

You can list the SDKs installed on your machine by using the following command:

```bash
dotnet --list-sdks
```

## Installing DAB CLI

Data API Builder provides a CLI tool to simplify configuration and execution of the engine. You can install the DAB CLI using [.NET tools](/dotnet/core/tools/global-tools):

```shell
dotnet tool install --global Microsoft.DataApiBuilder 
```

or, if you've already installed a previous version, you can update DAB CLI to the latest version via the following:

```shell
dotnet tool update --global Microsoft.DataApiBuilder
```

> [!IMPORTANT]: if you are running on Linux or MacOS, you may need to add .NET global tools to your PATH to call `dab` directly. Take a look at the troubleshooting guide for more information: [Troubleshoot Data API builder installation](../troubleshooting-installation.md)

## Verifying the installation

Installing the package makes the `dab` command available on your development machine. To validate your installation, you can run the following sample command:

```shell
dab --version
```

which should output

```shell
Microsoft.DataApiBuilder x.y.z
```

Where `x.y.z` is your version of DAB CLI.

## Next Steps

As the Data API builder for Azure Databases generates REST and GraphQL endpoints for database objects, you need to have a database ready for the tutorial. You can choose either a relational or non-relational database.

It's time for you to choose which database you want to use, so you can continue the getting started guide from there:

- [Getting Started with Data API builder for Azure SQL](./getting-started-azure-sql.md)
- [Getting Started with Data API builder for with Azure Cosmos DB](./getting-started-azure-cosmos-db.md)
- [Getting Started with Data API builder for with Azure Database PostgreSQL](./getting-started-azure-postgresql.md)
- [Getting Started with Data API builder for with Azure MySQL Database](./getting-started-mysql-db.md)
