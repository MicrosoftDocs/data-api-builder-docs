---
title: Feature availability
description: Review available features in Data API builder for Azure Databases. This article includes features across multiple databases and API platforms.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 01/27/2026
---

# Feature availability for Data API builder

These tables list the features available in Data API builder (DAB).

## Database version

| Database | Abbreviation | Min. Version |
| --- | --- | --- |
| SQL Server | SQL Family | Version 2016 |
| Azure SQL | SQL Family | N/A (PaaS) |
| Microsoft Fabric SQL | SQL Family | N/A (PaaS) |
| Azure Cosmos DB for NoSQL | Cosmos DB | N/A (PaaS) |
| PostgreSQL | PGSQL | Version 11 |
| MySQL | MySQL | Version 8 |
| Azure Synapse Analytics (Dedicated SQL pool) | SQLDW¹ | N/A (PaaS) |

## Cloud and hosting environments

The key to this table is that Data API builder can run in any environment with container support.

| Environment | Supported |
| --- | :---: |
| Microsoft Azure | ✅ Yes |
| Amazon Web Services (AWS) | ✅ Yes |
| Google Cloud Platform (GCP) | ✅ Yes |
| Oracle Cloud Infrastructure (OCI) | ✅ Yes |
| IBM Cloud | ✅ Yes |
| Alibaba Cloud | ✅ Yes |
| On-premises | ✅ Yes |

## GraphQL

| Feature | SQL Family | Cosmos DB | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| [Pagination](keywords/after-graphql.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Throttling | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Filtering](keywords/filter-graphql.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Aggregation](how-to/aggregate-data.md) | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| [Sorting](keywords/orderby-graphql.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [Selection](keywords/select-graphql.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Query-type](concept/api/graphql.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Mutation-type](concept/api/graphql.md) | ✅ Yes | ⚠️ Partial | ✅ Yes | ✅ Yes | ✅ Yes |
| Multi-Mutation | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Advanced GroupBy | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| Advanced Having | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| [Schema Generation](concept/api/graphql.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Schema Attribute (`@model`) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Schema Attribute (`@authorize`) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| User Provided Schema | ✖️ No | ✅ Yes | ✖️ No | ✖️ No | ✖️ No |
| Subscription | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| [Nitro](concept/api/graphql.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Cache Headers](concept/cache/http-headers.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [Level 1 Cache: Memory](concept/cache/level-1.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [Level 2 Cache: Redis](concept/cache/level-2.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |

## GraphQL Relationship Navigation

| Feature | SQL Family | Cosmos DB | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| [One-To-Many / Query](configuration/entities.md#relationships-entity-name-entities) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [One-To-Many / Mutation](configuration/entities.md#relationships-entity-name-entities) | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| [Many-To-Many / Query](configuration/entities.md#relationships-entity-name-entities) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [Many-To-Many / Mutation](configuration/entities.md#relationships-entity-name-entities) | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| [Cross-Source Relationships](configuration/entities.md#relationships-entity-name-entities) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| [Cross-Source Joins](configuration/entities.md#relationships-entity-name-entities) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## REST

| Feature | SQL Family | Cosmos DB² | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| [`PUT`](concept/api/rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [`POST`](concept/api/rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [`PATCH`](concept/api/rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [`DELETE`](concept/api/rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [`GET`](concept/api/rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [Pagination](keywords/after-rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [OData-like `$Select`](keywords/select-rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [OData-like `$Filter`](keywords/filter-rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| OData-like `$Count` | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| [OData-like `$OrderBy`](keywords/orderby-rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [OData-like `$First`](keywords/first-rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [`$After` (Cursor paging)](keywords/after-rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [OpenAPI Document](concept/api/openapi.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [Swagger UI](concept/api/openapi.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [Cache Headers](concept/cache/http-headers.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [Level 1 Cache: Memory](concept/cache/level-1.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [Level 2 Cache: Redis](concept/cache/level-2.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [POCO-ready Payload](concept/api/rest.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| OpenAPIReference | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## Supported Database Objects

| Feature | SQL Family | Cosmos DB | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| Tables | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| Views | ✅ Yes | ✖️ No | ✅ Yes | ✖️ No | ✅ Yes |
| Stored Procedures | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| Proc Parameters | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| Functions | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Collections | ✖️ No | ✅ Yes | ✖️ No | ✖️ No | ✖️ No |
| Field Mapping | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

## Entity Permissions

| Feature | SQL Family | Cosmos DB | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| [`C`reate](configuration/entities.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [`R`ead](configuration/entities.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [`U`pdate](configuration/entities.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [`D`elete](configuration/entities.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [`E`xecute](configuration/entities.md) | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| [Include Fields](configuration/entities.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Exclude Fields](configuration/entities.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

## Database Policy

| Feature | SQL Family | Cosmos DB | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| [`C`reate](concept/security/how-to-configure-database-policies.md) | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| [`R`ead](concept/security/how-to-configure-database-policies.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [`U`pdate](concept/security/how-to-configure-database-policies.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [`D`elete](concept/security/how-to-configure-database-policies.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [`E`xecute](concept/security/how-to-configure-database-policies.md) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| [Single-Table Policies](concept/security/how-to-configure-database-policies.md) | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| [Multi-Table Policies](concept/security/how-to-configure-database-policies.md) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| [Request Policy](concept/security/how-to-configure-database-policies.md) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## Authentication Features

| Feature | SQL Family | Cosmos DB | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| [UAMI (Entra ID)⁴](concept/security/how-to-authenticate-entra.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [SAMI (Entra ID)⁴](concept/security/how-to-authenticate-entra.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Azure EasyAuth](concept/security/how-to-authenticate-app-service.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Pass-through security | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| API-key security | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |

## Other Features

| Feature | SQL Family | Cosmos DB | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| Native JSON Support | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Native XML Support | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Native Vector Support | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| [Application Insights](concept/monitor/application-insights.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Log Analytics | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| File Logging | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Session Context](concept/security/row-level-security.md) | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| Multiple Data Sources | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Cross-Source Join | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| [OpenTelemetry](concept/monitor/open-telemetry.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Health Endpoints](concept/monitor/health-checks.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Custom Log Levels](concept/monitor/log-levels.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [.NET Aspire](mcp/quickstart-dotnet-aspire.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [MCP³](mcp/overview.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

## MCP Server

> [!NOTE]
> MCP Server features require Data API builder version 1.7 or later.

| Feature | SQL Family | Cosmos DB | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| [DML-tool: CREATE](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [DML-tool: READ](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [DML-tool: UPDATE](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [DML-tool: DELETE](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [DML-tool: EXECUTE](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [DML-tool: DESCRIBE](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Stored Procedure as Tool](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✖️ No | ✖️ No | ✖️ No | ✅ Yes |
| Server Instructions | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Object metadata](mcp/how-to-add-descriptions.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Field metadata](mcp/how-to-add-descriptions.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [Parameter metadata](mcp/how-to-add-descriptions.md) | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| [READ: Pagination](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [READ: `$Select`](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [READ: `$Filter`](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [READ: `$Count`](mcp/data-manipulation-language-tools.md) | ✖️ No | ✖️ No | ✖️ No | ✖️ No | ✖️ No |
| [READ: `$OrderBy`](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [READ: `$First`](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |
| [READ: `$After`](mcp/data-manipulation-language-tools.md) | ✅ Yes | ✖️ No | ✅ Yes | ✅ Yes | ✅ Yes |

## Azure Support (containers)

| Feature | SQL Family | Cosmos DB | PGSQL | MySQL | SQLDW¹ |
| --- | :---: | :---: | :---: | :---: | :---: |
| Azure Container Apps | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Container Instances | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Kubernetes Services | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Web App for Containers | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Red Hat OpenShift | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Spring Apps | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Service Fabric | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| Azure Virtual Machine | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

## Unsupported data types

Data API builder doesn't support some data types for each database platform. These limitations are typically due to serialization constraints or lack of native support in the underlying database driver.

### SQL Server and Azure SQL

| Data type | Description |
| --- | --- |
| `geography` | Geospatial data representing Earth's surface. |
| `geometry` | Planar spatial data using Cartesian coordinates. |
| `hierarchyid` | Hierarchical data management. |
| `json` | JSON formatted data (currently in preview). |
| `rowversion` | Row versioning for concurrency control. |
| `sql_variant` | Values of various SQL Server-supported data types. |
| `vector` | Vector data (currently in preview). |
| `xml` | XML formatted data. |

### PostgreSQL

| Data type | Description |
| --- | --- |
| `bytea` | Binary string storage. |
| `date` | Calendar dates (year, month, day). |
| `smalldatetime` | Less precise date and time storage. |
| `datetime2` | Not native; typically handled by `timestamp`. |
| `timestamptz` | Dates and times with time zone. |
| `time` | Time of day without date. |
| `localtime` | Current time based on system clock. |

### MySQL

| Data type | Description |
| --- | --- |
| `UUID` | Universally Unique Identifiers. |
| `DATE` | Calendar dates. |
| `SMALLDATETIME` | Less precise date and time storage. |
| `DATETIME2` | Not native; typically handled by `datetime`. |
| `DATETIMEOFFSET` | Dates and times with time zone. |
| `TIME` | Time of day without date. |
| `LOCALTIME` | Current time based on system clock. |

### Azure Cosmos DB for NoSQL

Azure Cosmos DB for NoSQL is schema-agnostic, so data type restrictions don't apply in the same way as relational databases.

## Footnotes

¹ SQLDW reflects support for Dedicated SQL pool only. Serverless SQL pool isn't supported.

² Cosmos DB is supported in DAB via GraphQL. DAB doesn't generate REST endpoints for Cosmos DB because the API for NoSQL provides a native REST API. For more information, see [Azure Cosmos DB: REST API Reference](/rest/api/cosmos-db/).

³ MCP (Model Context Protocol) is an endpoint-level capability, not database-specific.

⁴ Managed identity support uses Azure `DefaultAzureCredential`, which supports both System-Assigned (SAMI) and User-Assigned (UAMI) managed identities. UAMI requires setting the `AZURE_CLIENT_ID` environment variable.

⚠️ **Partial** for Cosmos DB mutations means basic create, update, and delete operations are supported, but not all mutation types (such as multi-mutation) are available.