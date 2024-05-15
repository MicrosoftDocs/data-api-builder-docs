---
title: Feature availability
description: Review available features in Data API builder for Azure Databases. This matrix includes features across multiple databases and API platforms.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 05/15/2024
---

# Feature availability for Data API builder

TODO

## Database version

| Database | Minimum Supported Version |
| --- | --- |
| SQL Server | v2016 |
| Azure SQL | N/A |
| Azure Cosmos DB for NoSQL | N/A |
| PostgreSQL | v11 |
| MySQL | v8 |

## GraphQL

| Feature | SQL Server | Azure SQL | Azure Cosmos DB for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| Pagination | Yes | Yes | Yes | Yes | Yes | - |
| Filtering | Yes | Yes | Yes | Yes | Yes | - |
| Sorting | Yes | Yes | - | Yes | Yes | Yes |
| Selection | Yes | Yes | Yes | Yes | Yes | - |
| Schema Gen | Yes | Yes | - | Yes | Yes | - |
| Schema Attribute Placement (`@model`, `@authorize`) | Yes | Yes | - | Yes | Yes | - |
| User Provided Schema | - | - | Yes | - | - | - |
| Subscription | - | - | - | - | - | - |
| Banana Cake Pop UI `*` | Yes | Yes | Yes | Yes | Yes | - |
| In-Memory Cache  `**` | Yes | Yes | - | Yes | Yes | - |

## GraphQL Relationship Navigation

| Feature | SQL Server | Azure SQL | Azure Cosmos DB for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| One-To-Many / Query | Yes | Yes | - | Yes | Yes | - |
| One-To-Many / Mutation | `v0.11` | `v0.11` | - | - | - | - |
| Many-To-Many / Query | Yes | Yes | - | Yes | Yes | - |
| Many-To-Many / Mutation | `v0.11` | `v0.11` | - | - | - | - |
| Cross-Source Relationships | - | - | - | - | - | - |
| Cross-Source Joins | - | - | - | - | - | - |

## REST

| Feature | SQL Server | Azure SQL | Azure Cosmos DB for NoSQL* | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| PUT | Yes | Yes | - | Yes | Yes | - |
| POST | Yes | Yes | - | Yes | Yes | - |
| PATCH | Yes | Yes | - | Yes | Yes | - |
| DELETE | Yes | Yes | - | Yes | Yes | - |
| GET | Yes | Yes | - | Yes | Yes | Yes |
| Pagination | Yes | Yes | - | Yes | Yes | - |
| $Filter | Yes | Yes | - | Yes | Yes | - |
| $Count | - | - | - | - | - | - |
| $OrderBy | Yes | Yes | - | Yes | - | - |
| $First | Yes | Yes | - | Yes | - | - |
| $After | Yes | Yes | - | Yes | - | - |
| $Select | Yes | - | - | Yes | Yes | - |
| OpenAPI Document | Yes | Yes | - | Yes | Yes | - |
| Swagger UI  `*` | Yes | Yes | - | Yes | Yes | - |
| In-Memory Cache  `**` | Yes | Yes | - | Yes | Yes | - |
| Not/Strict Payload | Yes | Yes | - | Yes | Yes | - |
| OpenAPIReference | - | - | - | - | - | - |

> * Data API builder does not generate a REST API for Azure Cosmos DB for NoSQL as Azure Cosmos DB for NoSQL provides a native REST API. More information can be found here: [Azure Cosmos DB: REST API Reference](https://learn.microsoft.com/rest/api/cosmos-db/).

## Supported Database Objects

| Feature | SQL Server | Azure SQL | Azure Cosmos DB for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| Stored Procedures | Yes | Yes | - | - | - | - |
| Tables | Yes | Yes | - | Yes | Yes | Yes |
| Views | Yes | Yes | - | Yes | - | - |
| Functions | - | - | - | - | - | - |
| Collections | - | - | Yes | - | - | - |

## Entity Security

| Feature | SQL Server | Azure SQL | Azure Cosmos DB for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| **C**reate | Yes | Yes | Yes | Yes | Yes | - |
| **R**ead | Yes | Yes | Yes | Yes | Yes | - |
| **U**pdate | Yes | Yes | Yes | Yes | Yes | - |
| **D**elete | Yes | Yes | Yes | Yes | Yes | - |

## Database Policy

| Feature | SQL Server | Azure SQL | Azure Cosmos DB for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| Create | Yes | Yes | - | - | - | - |
| Read | Yes | Yes | - | Yes | Yes | - |
| Update | Yes | Yes | - | Yes | Yes | - |
| Delete | Yes | Yes | - | Yes | Yes | - |
| Single-Table Policies | Yes | Yes | - | - | - | - |
| Multi-Table Policies | - | - | - | - | - | - |
| Request Policy | - | - | - | - | - | - |
| Create via PUT | Yes | Yes | - | - | - | - |
| Create via PATCH | Yes | Yes | - | - | - | - |
| Update via PUT | Yes | Yes | - | - | - | - |
| Update via PATCH | Yes | Yes | - | - | - | - |

## Other Features

| Feature | SQL Server | Azure SQL | Azure Cosmos DB for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| User-assigned managed identity (Microsoft Entra ID) | - | - | - | - | - | - |
| System-assigned managed identity (Microsoft Entra ID) | Yes | Yes | Yes | Yes | Yes | - |
| Column/Property Mapping/Rename | Yes | Yes | - | Yes | Yes | - |
| Native JSON Support | Yes | Yes | Yes | - | - | - |
| Native XML Support | - | - | - | - | - | - |
| Native Vector Support | - | - | - | - | - | - |
| application_name | Yes | Yes | Yes | - | - | - |
| Application Insights `*` | Yes | Yes | Yes | Yes | Yes | Yes |
| Session Context | Yes | Yes | - | - | - | - |
| Multiple Data Sources `*` | Yes | Yes | Yes | Yes | Yes | - |
| Cross-data source join | - | - | - | - | - | - |

## Static Web Apps

* `*` Not supported in Azure Static Web Apps (SWA)
* `**` Not supported in SWA yet
* User-assigned managed identity is supported in SWA only when configured from the Azure portal.
* `StaticWebApps` is required when using SWA authentication (EasyAuth).
