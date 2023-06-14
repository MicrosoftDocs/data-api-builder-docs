---
title: Release notes for Data API builder 0.7.6
description: Release notes for Data API builder 0.7.6 are available here.
author: aaronburtle 
ms.author: aaronburtle
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 06/12/2023
---
# What's New in Data API builder 0.7.6

- [Adding Merge config capabilities](#adding-merge-config-capabilities)
- [Executing GraphQL and REST Mutations in a transaction](#executing-graphql-and-rest-mutations-in-a-transaction)
- [Initial Support for OpenAPI v3.0.1 description document creation](#initial-support-for-openapi-v3-0-1-description-document-creation)
- [Allow passing a config override file through the configuration endpoint](#allow-passing-a-config-override-file-through-the-configuration-endpoint)
- [Adding useragent to Cosmos](#adding-useragent-to-cosmos)
- [Bug Fixes](#bug-fixes)
- [Doc Updates](#doc-updates)

## Adding Merge config capabilities
Adds the ability to automatically merge two configuration files, additional information can be found [in this document.](./data-api-builder-cli.md#using-data-api-builder-with-two-configuration-files)

You can maintain multiple pairs of baseline and environment specific configuration files to simplify management of your environment specific settings. The following steps demonstrate how to set up a base configuration file with two environment specific configuration files (**development** and **production**):

1. Create a base configuration file `dab-config.json` with all of your settings common across each of your environments.
2. Create two environemnt specific configuration files: `dab-config.development.json` and `dab-config.production.json`. These two configuration files should only include settings which differ from the base configuration file such as connection strings.
3. Next, set the `DAB_ENVIRONMENT` variable based on the environment configuration you want Data API builder to consume. For this example, set `DAB_ENVIRONMENT=development` so the `development` environment configuration file selected.
4. Start Data API builder with the command `dab start`. The engine checks the value of `DAB_ENVIRONMENT` and uses the base file `dab-config.json` and the environment specific file `dab-config.development.json`. When the engine detects the presence of both files, it merges the files into a third file: `dab-config.development.merged.json`.
5. (Optional) Set the `DAB_ENVIRONMENT` environment variable value to `production` when you want the production environment specific settings to be merged with your base configuration file.

> [!NOTE]
> 1. By default, **dab-config.json** is used to start the engine when the `DAB_ENVIRONMENT` environment variable isn't set.
> 2. A user provided config file is used regardless of the `DAB_ENVIRONMENT` environment variable's value. For example, the file `my-config.json` is used when Data API builder is started using `dab start -c my-config.json`

## Executing GraphQL and REST Mutations in a transaction
Data API builder creates database transactions to execute certain types of GraphQL and REST requests.

### GraphQL Mutations in Data Api builder
Consider a typical GraphQL mutation

```graphql
mutation updateNotebook($id: Int!, $item: UpdateNotebookInput!) {
        updateNotebook(id: $id, item: $item) {
          id
          color
        }
      }
``` 

To process such a GraphQL request, Data API builder constructs two database queries. The first database query is for performing the update action that is associated with the mutation.

The second database query is for fetching the data requested in the selection set. 

Data API builder executes both these database queries in a transaction.

### Transaction Isolation level for each database type

The below table lists the isolation levels with which the transactions are created for each database type.

|**Database Type**|**Isolation Level**
:-----:|:-----:
Azure SQL (or) SQL Server|Read Committed
MySQL|Repeatable Read
PostgreSQL|Read Committed

### Behavior exhibited by concurrent transactions

This section details the behavior expected when there are two concurrent running transactions operating on the same item. The nature of concurrent transactions is as follows.

a) Long running write transaction and a read transaction

b) Long running read transaction and a write transaction

Here, a read transaction implies that the transaction performs only read operations. A write transaction implies that the transaction performs both read and write operations.

### Long running write transaction and a read transaction

A read transaction arrives when a long running write transaction is in flight.

|**Database Type**|**Does the read transaction block?**
:-----:|:-----:
Azure SQL (or) SQL Server| Yes
MySQL| No
PostgreSQL| No

For Azure SQL or SQL Server, the read transaction waits for the write transaction to complete. For MySQL and PostgreSQL database types, the read transaction doesn't wait until the completion of the write transaction

## Initial Support for OpenAPI v3-0-1 description document creation
The OpenAPI specification is a programming language-agnostic standard for documenting HTTP APIs. Data API builder supports the OpenAPI standard with its ability to:

- Generate information about all runtime config defined entities that are REST enabled.
- Compile the information into a format that matches the OpenAPI schema.
- Exposes the generated OpenAPI schema via a visual UI (Swagger) or a serialized file.

### OpenAPI Description Document

Data API builder generates an OpenAPI description document (also referred to as a schema file) using the developer provided runtime config file and the database object metadata for each REST enabled entity defined in the runtime config file.
The schema file is generated using functionality provided by the [OpenAPI.NET SDK](https://github.com/microsoft/OpenAPI.NET). Currently, the schema file is  generated in adherence to [OpenAPI Specification v3.0.1](https://spec.openapis.org/oas/v3.0.1.html) formatted as JSON.

The OpenAPI description document can be fetched from Data API builder from the path:

```https
GET /{rest-path}/openapi 
```

> [!NOTE]
> By default, the `rest-path` value is `api` and is configurable. For more details, see [Configuration file - REST Settings](./configuration-file.md#rest)
### SwaggerUI

[Swagger UI](https://swagger.io/swagger-ui/) offers a web-based UI that provides information about the service, using the generated OpenAPI specification.

In `Development` mode, Data API builder enables viewing the generated OpenAPI description document from a dedicated endpoint:

```https
GET /swagger
```

The "Swagger" endpoint is not nested under the `rest-path` in order to avoid naming conflicts with runtime configured entities.

## Allow passing a config override file through the configuration endpoint
It is now possible to provide the configuration file and a set of overrides when configuring the engine at runtime. This will override any existing or new setting without requiring any other update to the configuration endpoint.

This adds a second configuration endpoint at `/configuration/v2`. This endpoint expects a "Configuration Overrides" which matches the schema of the configuration file.


## Adding useragent to Cosmos 
Adds `user agent` to Cosmos client.
>A string that specifies the client user agent performing the request. The recommended format is {user agent name}/{version}. For example, the official SQL API .NET SDK sets the User-Agent string to Microsoft.Document.Client/1.0.0.0. A custom user-agent could be something like ContosoMarketingApp/1.0.0.

[Read more about Cosmos DB REST request headers here.](https://learn.microsoft.com/rest/api/cosmos-db/common-cosmosdb-rest-request-headers)
## Bug Fixes
- [Address filter access deny issue for Cosmos](https://github.com/Azure/data-api-builder/pull/1436)
- [Fix CLI test warnings](https://github.com/Azure/data-api-builder/pull/1450)
- [Bug fix for CosmosDB field auth when graphql is "true", include is "*"](https://github.com/Azure/data-api-builder/pull/1516)

## Doc Updates
- [clarified upsert behavior for PATCH](https://github.com/Azure/data-api-builder/pull/1410)
- [docs and samples : running-in-azure](https://github.com/Azure/data-api-builder/pull/1457)
- [move documentation to learn.microsoft.com](https://github.com/Azure/data-api-builder/pull/1458)
- [Move recently updated docs](https://github.com/Azure/data-api-builder/pull/1470)




