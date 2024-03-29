---
title: Database connections in Data API builder
description: This document helps with database connections in Data API builder.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: database-connections
ms.date: 04/06/2023
---

# Database connections in Data API builder

Data API builder operates by connecting to a target database. You set the target database by setting a connection string in the [configuration file](./configuration-file.md).

## Connection resiliency

Data API builder automatically retries database requests after detecting transient errors. The retry logic follows an Exponential Backoff strategy where the maximum number of retries is 5. The retry backoff duration after subsequent requests is `power(2, retryAttempt)`. The first retry is attempted after 2 seconds. The second through fifth retries are attempted after 4, 8, 16, and 32 seconds, respectively.

## Database specific details

### Azure SQL and SQL Server

Data API builder uses the SqlClient library to connect to Azure SQL or SQL Server using the connection string you provide in the configuration file. A list of all the supported connection string options is available here: [SqlConnection.ConnectionString Property](/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring).

Data API builder can also connect to the target database using Managed Service Identities (MSI). The DefaultAzureCredential defined in [Azure Identity client library for .NET](/dotnet/api/overview/azure/Identity-readme#defaultazurecredential) will be used when you don't specify a username or password in your connection string.
