---
title: Feature availability
description: Review available features in Data API builder for Azure Databases. This article includes features across multiple databases and API platforms.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 05/15/2024
---

# Feature availability for Data API builder

These tables list the features available in Data API builder (DAB) for Azure databases. These tables include features across multiple databases and API platforms.

## Database version

| Database | Minimum Supported Version |
| --- | --- |
| SQL Server | v2016 |
| Azure SQL | N/A |
| Azure Cosmos DB for NoSQL | N/A |
| PostgreSQL | v11 |
| MySQL | v8 |

## GraphQL

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| Pagination | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Filtering | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Sorting | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| Selection | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Schema Gen | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Schema Attribute Placement (`@model`, `@authorize`) | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| User Provided Schema | ✖️ No | ✖️ No | ✅ Yes | ✖️ No | ✖️ No | ✖️ No |
| Subscription | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Banana Cake Pop UI ¹ | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| In-Memory Cache  ² | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |

## GraphQL Relationship Navigation

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| One-To-Many / Query | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| One-To-Many / Mutation | ✅ Yes (as of version `0.11`) | ✅ Yes (as of version `0.11`) | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Many-To-Many / Query | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Many-To-Many / Mutation | ✅ Yes (as of version `0.11`) | ✅ Yes (as of version `0.11`) | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Cross-Source Relationships | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Cross-Source Joins | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## REST

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL* | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| PUT | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| POST | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| PATCH | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| DELETE | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| GET | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| Pagination | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| $Filter | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| $Count | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| $OrderBy | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✖️ No | ✖️ No |
| $First | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✖️ No | ✖️ No |
| $After | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✖️ No | ✖️ No |
| $Select | ✅ Yes | ✖️ No | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| OpenAPI Document | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Swagger UI  ¹ | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| In-Memory Cache  ² | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Not/Strict Payload | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| OpenAPIReference | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

> `*` Data API builder does not generate a REST API for Azure Cosmos DB for NoSQL as the API for NoSQL provides a native REST API. More information can be found here: [Azure Cosmos DB: REST API Reference](/rest/api/cosmos-db/).

## Supported Database Objects

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| Stored Procedures | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Tables | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| Views | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✖️ No | ✖️ No |
| Functions | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Collections | ✖️ No | ✖️ No | ✅ Yes | ✖️ No | ✖️ No | ✖️ No |

## Entity Security

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| **C**reate | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| **R**ead | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **U**pdate | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| **D**elete | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |

## Database Policy

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| Create | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Read | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Update | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Delete | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Single-Table Policies | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Multi-Table Policies | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Request Policy | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Create via PUT | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Create via PATCH | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Update via PUT | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Update via PATCH | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## Authentication Features

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| User-assigned managed identity<br/>(Microsoft Entra ID) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| System-assigned managed identity<br/>(Microsoft Entra ID) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No |
| Static Web App EasyAuth | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Pass-through security | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| API-key security | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## Other Features

| Feature | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | DWSQL |
| --- | --- | --- | --- | --- | --- | --- |
| Column/Field Mapping | ✅ Yes | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✖️ No |
| Native JSON Support | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No |
| Native XML Support | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Native Vector Support | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| application_name | ✅ Yes | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No |
| Application Insights ¹ | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Session Context | ✅ Yes | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Multiple Data Sources ¹ | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Cross-data source join | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## Azure Support (containers)

| Feature                        | SQL Server | Azure SQL | Azure Cosmos DB<br/>for NoSQL | PostgreSQL | MySQL | DWSQL |
|--------------------------------|------------|-----------|---------------------------|------------|-------|-------|
| Azure Static Web Apps          | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |
| Azure Container Apps           | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |
| Azure Container Instances      | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |
| Azure Kubernetes Services      | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |
| Azure Web App for Containers   | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |
| Azure Red Hat OpenShift        | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |
| Azure Spring Apps        | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |
| Azure Service Fabric           | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |
| Azure Virtual Machine                    | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |
| Azure Batch                    | ✅ Yes     | ✅ Yes    | ✅ Yes                    | ✅ Yes     | ✅ Yes | ✅ Yes |

## Static Web Apps

* ¹ Not supported in Azure Static Web Apps (SWA)
* ² Not supported in Azure Static Web Apps (SWA) yet

* User-assigned managed identity is supported in SWA only when configured from the Azure portal.
* `StaticWebApps` is required when using SWA authentication (EasyAuth).
