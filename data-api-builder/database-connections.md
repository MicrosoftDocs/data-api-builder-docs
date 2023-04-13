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

In order to work properly, Data API builder needs to connect to a target database. To do that, a connection string must be supplied in the [configuration file](./configuration-file.md)

## Connection resiliency

Connections to databases are automatically retried, in case a transient error is trapped. Retry logic uses an Exponential Backoff strategy. Maximum number of retries set to 5. Between every subsequent retry backoff timespan is power(2, retryAttempt). For the first retry, it's performed after a gap of 2 seconds, second retry after a timespan of 4 seconds, third after 8,......, fifth after 32 seconds.

## Database specific details

### Azure SQL and SQL Server

Data API builder uses the SqlClient library to connect to Azure SQL or SQL Server. A list of all the supported connection string options is available here: [SqlConnection.ConnectionString Property](/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring).

Usage of Managed Service Identities (MSI) is also supported. Don't specify your username and password in the connection string, and the DefaultAzureCredential is used as documented here: [Azure Identity client library for .NET - DefaultAzureCredential](/dotnet/api/overview/azure/Identity-readme#defaultazurecredential)
