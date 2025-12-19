---
title: Feature availability
description: Review available features in Data API builder for Azure Databases. This article includes features across multiple databases and API platforms.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 06/11/2025
---

# Feature availability for Data API builder

These tables list the features available in Data API builder (DAB). 

## Database version

| Database | Minimum Supported Version |
| --- | --- |
| SQL Server | v2016 |
| Azure SQL | N/A (PaaS) |
| Azure Cosmos DB (for NoSQL) | N/A (PaaS) |
| PostgreSQL | v11 |
| MySQL | v8 |

## GraphQL

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | SQLDW |
| --- | --- | --- | --- | --- | --- | --- |
| Pagination | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Throttling | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Filtering | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Aggregation | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Sorting | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| Selection | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Query-type | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Mutation-type| ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Multi-Mutation | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Advanced GroupBy | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Advanced Having | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Aggregations | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Schema Generation | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Schema Attribute Placement (`@model`, `@authorize`) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| User Provided Schema | ✖️ No | ✖️ No | ✅ Yes | ✖️ No | ✖️ No | ✖️ No |
| Subscription | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Nitro/Banana Cake Pop UI | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Cache Headers | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Level 1 Cache: Memory | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Level 2 Cache: Redis | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## GraphQL Relationship Navigation

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | SQLDW |
| --- | --- | --- | --- | --- | --- | --- |
| One-To-Many / Query | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| One-To-Many / Mutation | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Many-To-Many / Query | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Many-To-Many / Mutation | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Cross-Source Relationships | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Cross-Source Joins | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## REST

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL* | PostgreSQL | MySQL | SQLDW |
| --- | --- | --- | --- | --- | --- | --- |
| PUT | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| POST | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| PATCH | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| DELETE | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| GET | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| Pagination | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| OData-like $Select | ✅ Yes | ✖️ No | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| OData-like $Filter | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| OData-like $Count | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| OData-like $OrderBy | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✖️ No | ✖️ No |
| OData-like $First | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✖️ No | ✖️ No |
| $After (Cursor paging) | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✖️ No | ✖️ No |
| OpenAPI Document | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Swagger UI | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Cache Headers | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Level 1 Cache: Memory | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Level 2 Cache: Redis | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| POCO-ready Payload | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| OpenAPIReference | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

> `*` Data API builder does not generate a REST API for Azure Cosmos DB for NoSQL as the API for NoSQL provides a native REST API. More information can be found here: [Azure Cosmos DB: REST API Reference](/rest/api/cosmos-db/).

## Supported Database Objects

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | SQLDW |
| --- | --- | --- | --- | --- | --- | --- |
| Tables | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| Views | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✖️ No | ✖️ No |
| Stored Procedures | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Proc Parameters | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Functions | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Collections | ✖️ No | ✖️ No | ✅ Yes | ✖️ No | ✖️ No | ✖️ No |
| Field Mapping | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

## Entity Permissions

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | SQLDW |
| --- | --- | --- | --- | --- | --- | --- |
| **C**reate | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| **R**ead | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **U**pdate | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| **D**elete | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| **E**xecute | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Include Fields | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Exclude Fields | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

## Database Policy

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | SQLDW |
| --- | --- | --- | --- | --- | --- | --- |
| Create | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Read | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Update | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Delete | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Single-Table Policies | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Multi-Table Policies | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Request Policy | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## Authentication Features

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | SQLDW |
| --- | --- | --- | --- | --- | --- | --- |
| UAMI (Entra ID) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| SAMI (Entra ID) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Azure EasyAuth | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Pass-through security | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| API-key security | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## Other Features

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | SQLDW |
| --- | --- | --- | --- | --- | --- | --- |
| Native JSON Support | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Native XML Support | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Native Vector Support | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Application Insights | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Log Analytics | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Session Context | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Multiple Data Sources | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Cross-source join | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Open Telemetry | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Health Endpoints | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Custom Log Levels | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| .NET Aspire | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

## Azure Support (containers)

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | SQLDW |
| --- | --- | --- | --- | --- | --- | --- |
| Azure Container Apps | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Container Instances | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Kubernetes Services | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Web App for Containers | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Red Hat OpenShift | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Spring Apps | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Service Fabric | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Virtual Machine | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Batch | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |