---
title: Database connections
description: Use database connections to connect your API generated using the Data API builder with your target database.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 03/28/2024
show-latex: true
# Customer Intent: As a operations professional, I want to use the database connections feature, so I can ensure that my API connects to the right database using the credentials I prefer.
---

# Database connections in Data API builder

Data API builder operates by connecting to a target database. You set the target database by setting a connection string in the [configuration file](reference-configuration.md#connection-string).

## Connection resiliency

Data API builder automatically retries database requests after detecting transient errors. The retry logic follows an **Exponential Backoff** strategy where the maximum number of retries is **five**. The retry backoff duration after subsequent requests is calculated using this formula (assuming the current retry attempt is `r`): $2^r$. Using this formula, you can calculate the time for each retry attempt in seconds.

| | Seconds |
| :-- | :-- |
| **First** | `2` |
| **Second** | `4` |
| **Third** | `8` |
| **Fourth** | `16` |
| **Fifth** | `32` |

## Database specific details

Sometimes, individual databases have specific features for database connections that are unique to that database.

### Azure SQL and SQL Server

Data API builder uses the [`SqlClient`](https://www.nuget.org/packages/Microsoft.Data.SqlClient) library to connect to Azure SQL or SQL Server using the connection string you provide in the configuration file. A list of all the supported connection string options is available here: [SqlConnection.ConnectionString Property](/dotnet/api/system.data.sqlclient.sqlconnection.connectionstring).

Data API builder can also connect to the target database using Managed Service Identities (MSI). The `DefaultAzureCredential` defined in [`Azure.Identity`](https://www.nuget.org/packages/Azure.Identity) library is used when you don't specify a username or password in your connection string. For more information, see [`DefaultAzureCredential` examples](/dotnet/api/azure.identity.defaultazurecredential#examples).

## Related content

- [Configuration file](reference-configuration.md)
- [Best practices](best-practices.md)
