---
title: What's new for version 0.11 and earlier
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 0.11 and earlier.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 05/15/2024
---

# What's new in version 0.11 and earlier

Release notes and information about all updates and enhancements in Data API builder version 0.11 and earlier.

## What's new in version 0.11

Release notes and information about the updates and enhancements in Data API builder version 0.10.

### GraphQL support for SQL Data Warehouse

SQL Data Warehouse now supports GraphQL endpoints.

### Enhanced Azure Cosmos DB for NoSQL filtering

Azure Cosmos DB for NoSQL now has support for nested filters, ID variables, and string array searches with the `contains` operator.

### Enable application data collection with command-line interface

You can now use the DAB command-line interface (CLI) to enable data collection with Application Insights.

## What's new in version 0.10

Release notes and information about the updates and enhancements in Data API builder version 0.10.

Our focus shifts to stability as we approach General Availability. While not all efforts in code quality and engine stability are detailed in this article, this list highlights significant updates.

### GitHub release notes

Review these release pages for a comprehensive list of all the changes and improvements:

- 2024-02-06 - Version 0.10.23
  - [0.10.23: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v0.10.23)
- 2024-01-31 - Version 0.10.21
  - [0.10.21: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v0.10.21)
- 2023-12-07 - Version 0.10.11
  - [0.10.11-rc: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v0.10.11-rc)

### In-memory caching

Version 0.10 introduces in-memory caching for REST and GraphQL endpoints. This feature, designed for internal caching, lays the groundwork for future distributed caching. In-memory caching reduces database load from repetitive queries.

#### Caching Scenarios

- **Reducing database load**: Cache stores results of expensive queries, eliminating the need for repeated database calls.
- **Improving API scalability**: Caching supports more frequent API calls without increasing database requests, significantly scaling your API's capabilities.

#### Configuration Changes

Caching settings are available in the `runtime` section and for each entity, offering granular control.

**Runtime settings**:

```json
{
  "runtime": {
    "cache": {
      "enabled": true,
      "ttl-seconds": 6
    }
  }
}
```

- Caching is disabled by default.
- The default time-to-live (TTL) is 5 seconds.

**Entity settings**:

```json
{
  "Book": {
    "source": {
      "object": "books",
      "type": "table"
    },
    "graphql": {
      "enabled": true,
      "type": {
        "singular": "book",
        "plural": "books"
      }
    },
    "rest": {
      "enabled": true
    },
    "permissions": [
      {
        "role": "anonymous",
        "actions": [
          {
            "action": "*"
          }
        ]
      }
    ],
    "cache": {
      "enabled": true,
      "ttl-seconds": 6
    }
  }
}
```

### Configuration Validation in CLI

The CLI now supports `dab validate` for checking configuration files for errors or inconsistencies, enhancing the development workflow.

#### Validation Steps

1. **Schema validation**
2. **Config properties validation**
3. **Config permission validation**
4. **Database connection validation**
5. **Entities Metadata validation**

### Preview Features

- Initial DWSQL support. [#1864](https://github.com/Azure/data-api-builder/pull/1864)
- Support for multiple data sources. [#1709](https://github.com/Azure/data-api-builder/pull/1709)

## What's new in version 0.9

Here's the details on the most relevant changes and improvement in Data API builder 0.9.

### GitHub release notes

Review these release pages for a comprehensive list of all the changes and improvements:

- [0.9.7 GitHub release page](https://github.com/Azure/data-api-builder/releases/tag/v0.9.7)

### Enable Application Insights when self-hosting DAB

Logs can now be streamed to Application Insights for a better monitoring and debugging experience, especially when Data API builder is deployed in Azure. A new `telemetry` section can be added to the configuration file to enable and configure integration with Application Insights:

```json
"telemetry": {
    "application-insights": {
    "enabled": true,    // To enable/disable application insights telemetry
    "connection-string": "{APP_INSIGHTS_CONNECTION_STRING}" // Application Insights connection string to send telemetry
    }
}
```

Read all the details in the [Use Application Insights](../deployment/how-to-use-application-insights.yml) documentation page.

### Support for ignoring extraneous fields in REST request body

With the new `request-body-strict` option, you can now decide if having extra field in the REST payload generates an error (default behavior, backward compatible) or the extra fields is silently ignored.

```json
"runtime": {
    "rest": {
      "enabled": true,
      "path": "/api",
      "request-body-strict": true
    },
    ...
}
```

By setting the `request-body-strict` option to `false`, fields that don't have a mapping to the related database object are ignored without generating any error.

### Adding Application Name for `mssql` connections

Data API builder now injects in the connection string, for `mssql` database types only, the value `dab-<version>` as the `Application Name` property, making easier to identify the connections in the database server. If `Application Name` is already present in the connection string, Data API builder version is appended to it.

### Support `time` data type in `mssql`

`time` data type is now supported in `mssql` databases.

### Mutations on table with triggers for `mssql`

Mutations are now fully supported on tables with triggers for `mssql` databases.

#### Preventing update/insert of read-only fields in a table by user

Automatically detect read-only fields the database and prevent update/insert of those fields by user.  

## What's new in version 0.8

Here's the details on the most relevant changes and improvement in Data API builder 0.8.

### GitHub release notes

Review these release pages for a comprehensive list of all the changes and improvements:

- [0.8.52: GitHub release page](https://github.com/Azure/data-api-builder/releases/tag/v0.8.52)
- [0.8.51: GitHub release page](https://github.com/Azure/data-api-builder/releases/tag/v0.8.51)
- [0.8.50: GitHub release page](https://github.com/Azure/data-api-builder/releases/tag/v0.8.50)
- [0.8.49: GitHub release page](https://github.com/Azure/data-api-builder/releases/tag/v0.8.49)

### Added support for .env file

[Environment variables](/azure/data-api-builder/configuration-file#setting-environment-variables) shield secrets from plain text exposure and allow for value swapping in different settings. However, these variables must be set either in the user or computer scope, which can lead to cross-project variable "bleeding" if variable names are duplicated. The better alternative is environment files. For more information, see [environment files in Data API builder - blog](https://devblogs.microsoft.com/azure-sql/dab-envfiles).

## What's new in version 0.7.6

This article describes the release notes for the 0.7.6 release.

### GitHub pull requests

- [Address filter access deny issue for Cosmos](https://github.com/Azure/data-api-builder/pull/1436)
- [Bug fix for Azure Cosmos DB field auth when graphql is "true," include is "*"](https://github.com/Azure/data-api-builder/pull/1516)

### Initial Support for OpenAPI v3-0-1 description document creation

Data API builder supports the OpenAPI standard for generating and exposing description docs that contain useful information about the service. These docs are created from the runtime configuration file and the metadata for each database object. These objects are associated with a REST enabled entity defined in that same configuration file. They're then exposed through a UI and made available as a serialized file.

For more information about the specifics of OpenAPI and Data API builder, see [OpenAPI](../openapi.md).

### Allowing merger of configuration files

Adds the ability to automatically merge two configuration files.

It's possible to maintain multiple pairs of baseline and environment specific configuration files to simplify management of the environment specific settings. For example, it's possible to maintain separate configurations for **Development** and **Production**. This step involves having a base configuration file that has all of the common settings between the different environments. Then by setting the `DAB_ENVIRONMENT` variable it's possible to control which configuration files to merge for consumption by Data API builder.

For more information, see [CLI reference](../reference-command-line-interface.md).

### Executing GraphQL and REST Mutations in a transaction

Data API builder creates database transactions to execute certain types of GraphQL and REST requests.

There are many requests, which involve making more than one database query to accomplish. For example to return the results from an update, first a query for the update must be made, then the new values must be read before being returned. When a request requires multiple database queries to execute, Data API builder now executes these database queries within a single transaction.

You can read more about this capability within the context of REST [in the REST documentation](../rest.md#database-transactions-for-rest-api-requests) and of GraphQL [in the GraphQL documentation](../graphql.md#database-transactions-for-a-mutation).

## What's new in version 0.6.14

This article describes the patch for March 2023 release for Data API builder for Azure Databases.

### Bug Fixes

- Address query filter access denied issue for Cosmos.
- Cosmos DB currently doesn't support field level authorization, to avoid the situation when the users accidentally pass in the ```field``` permissions in the runtime config, we added a validation check.

## What's new in version 0.6.13

The full list of release notes for this version is available on GitHub: <https://github.com/Azure/data-api-builder/releases/tag/v0.6.13>.

### New CLI command to export GraphQL schema

A new option is added to export GraphQL schema. This starts up the DAB server and then query it to get the schema before writing it to the location that is provided.

```http
dab export --graphql -c dab-config.development.json -o ./schemas
```

This command generates the GraphQL schema file in the ./schemas directory. The path to configuration file is an optional parameter, which defaults to 'dab-config.json' unless 'dab-config.<DAB_ENVIRONMENT>.json' exists, where DAB_ENVIRONMENT is an environment variable.

### Database policy support for create action for MsSql

Database policies are now supported for all the CRUD (Create, Read, Update, Delete) operations for MsSql.
For example:

```json
"entities":{
  "Revenue":{
    "source": "revenues",
    "permissions":[
      "role": "authenticated",
          "actions": [
            {
              "action": "Create",
              "policy": {
                "database": "@item.revenue gt 0"
              }
            },
            "read",
            "update",
            "delete"
          ]
    ]
  }
}
```

The previous configuration for `Revenue` entity indicates that the user who is performing an insert operation with role `Authenticated` isn't allowed to create a record with revenue less than or equal to zero.

### Ability to configure GraphQL path and disable REST and GraphQL endpoints globally via CLI

We now support three more options for the `init` command:

- `graphql.path` : To provide custom GraphQL path
- `rest.disabled`: To disable REST endpoints globally
- `graphql.disabled`: To disable GraphQL endpoints globally

For example, an `init` command would generate a config file with a runtime section:

```http
dab init --database-type mssql --rest.disabled --graphql.disabled --graphql.path /gql
```

```json
"runtime": {
    "rest": {
      "enabled": false,
      "path": "/api"
    },
    "graphql": {
      "allow-introspection": true,
      "enabled": false,
      "path": "/gql"
    },
}
```

### Key fields mandatory for adding and updating views in CLI

It's now mandatory for the user to provide the key-fields (to be used as primary key) via the exposed option `source.key-fields` whenever adding a new database view (via `dab add`) to the config via CLI. Also, whenever updating anything in the view's configuration (via `dab update`) in the config file via CLI, if the update changes anything that relates to the definition of the view in the underlying database (for example, source type, key-fields), it's mandatory to specify the key-fields in the update command as well.

However, we still support views without having explicit primary keys specified in the config, but the configuration for such views has to be written directly in the config file.

For example, a `dab add` command is used to add a view:

```http
dab add books_view --source books_view --source.type "view" --source.key-fields "id" --permissions "anonymous:*" --rest true --graphql true
```

This command generates the configuration for `books_view` entity that is like this example:

```json
"books_view": {
      "source": {
        "type": "view",
        "object": "books_view",
        "key-fields":[
          "id"
        ]
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            "*"
          ]
        }
      ],
      "rest": true,
      "graphql": true
    }
```

### Replacing Azure storage link with GitHub links

Since DAB is now open-sourced, we don't need to download the artifacts from the storage account. Instead, we can directly download them from GitHub. Hence, the links are accordingly updated.

## What's new in version 0.5.34

The full list of release notes for this version is available on GitHub: <https://github.com/Azure/data-api-builder/releases/tag/v0.5.34>.

### Honor REST and GraphQL enabled flag at runtime level

A new option is added to allow enabling or disabling REST/GraphQL requests for all entities at the runtime level. If disabled globally, no entities would be accessible via REST or GraphQL requests irrespective of the individual entity settings. If enabled globally, individual entities are accessible by default unless disabled explicitly by the entity level settings.

```json
"runtime": {
    "rest": {
      "enabled": false,
      "path": "/api"
    },
    "graphql": {
      "allow-introspection": true,
      "enabled": false,
      "path": "/graphql"
    }
  }
```

### Correlation ID in request logs

To help debugging, we attach a correlation ID to any logs that are generated during a request. Since many requests might be made, having a way to identify the logs to a specific request is important to help the debugging process.

### Wildcard Operation Support for Stored Procedures in Engine and CLI

For stored procedures, roles can now be configured with the wildcard `*` action but it only expands to the `execute` action.

## What's new in version 0.5.32

The full list of release notes for this version is available on GitHub: <https://github.com/Azure/data-api-builder/releases/tag/v0.5.32-beta>.

### Ability to customize rest path via CLI

A new option `--rest.path` is introduced in the `init` command to customize the path for REST APIs.

```http
dab init --database-type mssql --connection-string "Connection-String" --rest.path "rest-api" 
```

This command configures the REST endpoints with a prefix of `rest-api`. The complete path for the REST endpoints is
`https://<dab-server>/rest-api/<entity-name>`

When `--rest.path` option isn't used, the REST endpoints are configured with the default prefix `api`. The complete path in this case is
`https://<dab-server>/api/<entity-name>`

### Data API builder container image in MAR

The official docker images for Data API builder for Azure Databases are now available in [Microsoft Artifact Registry](https://mcr.microsoft.com/product/azure-databases/data-api-builder/tags).

For instructions for using the published images, see [Microsoft container registry - Data API builder](https://mcr.microsoft.com/en-us/product/azure-databases/data-api-builder/about).

### Support for GraphQL fragments

Fragments are reusable part of a graphQL query. In scenarios where the same fields have to be queried in different queries, the repeated fields can be consolidated into a single reusable component called fragment.

For more information about fragments, see [GraphQL queries](https://graphql.org/learn/queries/).

A fragment called `description` on type `Character` is defined next:

```graphql
fragment description on Character {
  name
  homePlanet
  primaryFunction
}
```

A GraphQL query that makes use of the defined fragment can be constructed as illustrated here:

```graphql
{
  Player1: Player{
    id
    playerDescription{
        ...description
    }
  }
}
```

For the previous query, the result contains the following fields:

```graphql
{
 Player1: Player{
    id
    playerDescription{
        name
        homePlanet
        primaryFunction
    }
  }   
}
```

### Turn on BinSkim and fix Policheck alerts

BinSkim is a Portable Executable (PE) light-weight scanner that validates compiler/linker settings and other security-relevant binary characteristics. A pipeline task in `static-tools` pipeline is added to perform BinSkim scans with every pipeline run. The PoliCheck system is a set of tools and data that helps stay compliant with the Text and Code Review Requirement, as part of the overall Global Readiness policy. The alerts generated by Policheck scans are fixed to be compliant regarding sensitive terms.

## What's new in version 0.5.0

The full list of release notes for this version is available on GitHub: <https://github.com/Azure/data-api-builder/releases/tag/v0.5.0-beta>.

### Public JSON Schema

The public JSON schema gives you support for "intellisense," if you're using an IDE like Visual Studio Code that supports JSON Schemas. The `basic-empty-dab-config.json` file in the `samples` folder has an example starting point when manually creating the `dab-config.json` file.

### Public `Microsoft.DataApiBuilder` NuGet

`Microsoft.DataApiBuilder` is now available as a public NuGet package [here](https://www.nuget.org/packages/Microsoft.DataApiBuilder) for ease of installation using dotnet tool as follows:

```bash
dotnet tool install --global Microsoft.DataApiBuilder
```

### New `execute` action for stored procedures in Azure SQL

A new `execute` action is introduced as the only allowed action in the `permissions` section of the configuration file only when a source type backs an entity of `stored-procedure`. By default, only `POST` method is allowed for such entities and only the GraphQL `mutation` operation is configured with the prefix `execute` added to their name. Explicitly specifying the allowed `methods` in the `rest` section of the configuration file overrides this behavior. Similarly, for GraphQL, the `operation` in the `graphql` section, can be overridden to be `query` instead. For more information, see [views and stored procedures](../views-and-stored-procedures.md).

### New `mappings` section

In the `mappings` section under each `entity`, the mappings between database object field names and their corresponding exposed field names are defined for both GraphQL and REST endpoints.

The format is:

`<database_field>: <entity_field>`

For example:

```json
  "mappings":{
    "title": "descriptions",
    "completed": "done"
  }
```

The `title` field in the related database object is mapped to `description` field in the GraphQL type or in the REST request and response payload.

### Support for Session Context in Azure SQL

To enable an extra layer of Security (for example, Row Level Security (RLS)), DAB now supports sending data to the underlying Sql Server database via SESSION_CONTEXT. For more details, please refer to this detailed document on SESSION_CONTEXT: [Runtime to Database Authorization](https://github.com/Azure/data-api-builder/blob/cc7ec4f5a12c3e0fe87e1452f8989199d0aba8e6/docs/runtime-to-database-authorization.md).  

### Support for filter on nested objects within a document in PostgreSQL

With PostgreSQL, you can now use the object or array relationship defined in your schema, which enables to do filter operations on the nested objects just like Azure SQL.

```graphql
query {
  books(filter: { series: { name: { eq: "Foundation" } } }) {
    items {
      title
      year
      pages
    }
  }
}
```

### Support scalar list in Cosmos DB NoSQL

The ability to query `List` of Scalars is now added for Cosmos DB.

Consider this type definition.

```graphql
type Planet @model(name:"Planet") {
    id : ID,
    name : String,
    dimension : String,
    stars: [Star]
    tags: [String!]
}
```

It's now possible to run a query that fetches a List such as

```graphql
query ($id: ID, $partitionKeyValue: String) {
    planet_by_pk (id: $id, _partitionKeyValue: $partitionKeyValue) {
        tags
    }
}
```

### Enhanced logging support using log level

- The default log levels for the engine when `host.mode` is `Production` and `Development` are updated to `Error` and `Debug` respectively.
- During engine start-up, for every column of an entity, information such as exposed field names and the primary key is logged. This behavior happens even type when the field mapping is autogenerated.
- In the local execution scenario, all the queries that are generated and executed during engine start-up are logged at `Debug` level.
- For every entity, relationship fields such as `source.fields`, `target.fields`, and `cardinality` are logged. If there are many-many relationships, `linking.object`, `linking.source.fields`, and `linking.target.fields` inferred from the database (or from config file) are logged.
- For every incoming request, the role and the authentication status of the request are logged.
- In CLI, the `Microsoft.DataAPIBuilder` version is logged along with the logs associated with the respective command's execution.

### Updated CLI

- `--no-https-redirect` option is added to `start` command. With this option, the automatic redirection of requests from `http` to `https` can be prevented.

- In MsSql, session context can be enabled using `--set-session-context true` in the `init` command. A sample command is shown in this example:

  ```bash
  dab init --database-type mssql --connection-string "Connection String" --set-session-context true
  ```
  
- Authentication details such as the provider, audience, and issuer can be configured using the options `--auth.provider`, `--auth.audience`, and `--auth.issuer.` in the `init` command. A sample command is shown in this sample:

  ```bash
  dab init --database-type mssql --auth.provider AzureAD --auth.audience "audience" --auth.issuer "issuer"
  ```
  
- User friendly error messaging when the entity name isn't specified.

## What's new in version 0.4.11

The full list of release notes for this version is available on GitHub: <https://github.com/Azure/data-api-builder/releases/tag/v0.4.11-alpha>.

### Updated JSON schema for `data-source` section

The `data-source` section in the configuration file is updated to be consistent across all supported databases but still allow each database to have custom configurations. A new section `options` is introduced to group all the properties that are specific to a database. For example:

```json
{
  "$schema": "https://dataapibuilder.azureedge.net/schemas/v0.4.11-alpha/dab.draft.schema.json",
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "options": {
      "database": "PlaygroundDB",
      "graphql-schema": "schema.gql"
    },
    "connection-string": "AccountEndpoint=https://localhost:8081/;AccountKey=REPLACEME;"
  }
}
```

The elements available in the `options` section depend on the chosen `database-type`.

### Support for filter on nested objects within a document in Azure SQL and SQL Server

With Azure SQL and SQL Server, you can use the object or array relationship defined in your schema, which enables to do filter operations on the nested objects.

```graphql
query {
  books(filter: { series: { name: { eq: "Foundation" } } }) {
    items {
      title
      year
      pages
    }
  }
}
```

### Improved stored procedure support

Full support for stored procedure in REST and GraphQL. Stored procedure with parameters now 100% supported. Check out the [Stored Procedures](../views-and-stored-procedures.md#stored-procedures) documentation to learn how to use Data API builder with stored procedures.

### New `database-type` value renamed for Cosmos DB

We added support for PostgreSQL API with Cosmos DB. With a consolidated `data-source` section, the attribute `database-type` denotes the type of database. Since Cosmos DB supports multiple APIs, the currently supported database types are `cosmosdb_nosql` and `cosmosdb_postgresql`.

```json
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "options": {
      "database": "PlaygroundDB",
      "graphql-schema": "schema.gql"
    }
  }
```

### Renaming CLI properties for `cosmosdb_nosql`

Following the configuration changes described in previous sections, now CLI properties are renamed accordingly as `cosmosdb_nosql-database` and `cosmosdb_nosql-container` for Cosmos DB NoSQL API.

```bash
dab init --database-type "cosmosdb_nosql" --graphql-schema schema.gql --cosmosdb_nosql-database PlaygroundDB  --cosmosdb_nosql-container "books" --connection-string "AccountEndpoint=https://localhost:8081/;AccountKey=REPLACEME;" --host-mode "Development"
```

### Managed Identity now supported with Postgres

Now the user can alternatively specify the access token in the config to authenticate with a Managed Identity. Alternatively, now the user  just can't specify the password in the connection string and the runtime attempts to fetch the default managed identity token. If this fails, connection is attempted without a password in the connection string.

### Support Microsoft Entra ID user authentication for Azure MySQL

Added user token as password field to authenticate with MySQL with Microsoft Entra ID plugin.

## What's new in version 0.3.7

The full list of release notes for this version is available on GitHub: <https://github.com/Azure/data-api-builder/releases/tag/v0.3.7-alpha>.

### View support

Views are now supported both in REST and GraphQL. If you have a view, for example [`dbo.vw_books_details`](https://github.com/Azure/data-api-builder/blob/main/samples/getting-started/azure-sql-db/library.azure-sql.sql#L115) it can be exposed using the following `dab` command:

```sh
dab add BookDetail --source dbo.vw_books_details --source.type View --source.key-fields "id" --permissions "anonymous:read"
```

The `source.key-fields` option is used to specify which fields from the view are used to uniquely identify an item, so that navigation by primary key can be implemented also for views. It's the responsibility of the developer configuring DAB to enable or disable actions (for example, the `create` action) depending on if the view is updatable or not.

### Stored procedures support

Stored procedures are now supported for REST requests. If you have a stored procedure, for example [`dbo.stp_get_all_cowritten_books_by_author`](https://github.com/Azure/data-api-builder/blob/main/samples/getting-started/azure-sql-db/library.azure-sql.sql#L141) it can be exposed using the following `dab` command:

```sh
dab add GetCowrittenBooksByAuthor --source dbo.stp_get_all_cowritten_books_by_author --source.type "stored-procedure" --permissions "anonymous:read" --rest true
```

The parameter can be passed in the URL query string when calling the REST endpoint:

```http
http://<dab-server>/api/GetCowrittenBooksByAuthor?author=isaac%20asimov
```

It's the responsibility of the developer configuring DAB to enable or disable actions (for example, the `create` action) to allow or deny specific HTTP verbs to be used when calling the stored procedure. For example, for the stored procedure used in the example, given that its purpose is to return some data, it would make sense to only allow the `read` action.

### Microsoft Entra ID authentication

Microsoft Entra ID authentication is now fully working. For more information, see [authentication with Microsoft Entra ID](https://github.com/Azure/data-api-builder/blob/8c44bc882da718f86bbfba48756c0796ef24e058/docs/authentication-azure-ad.md).

### New simulator authentication provider for local authentication

To simplify testing of authenticated requests when developing locally, a new `simulator` authentication provider is available. The provider `simulator` is a configurable authentication provider, which instructs the Data API builder engine to treat all requests as authenticated. More details here: [Local Authentication](https://github.com/Azure/data-api-builder/blob/8c44bc882da718f86bbfba48756c0796ef24e058/docs/local-authentication.md)

### Support for filter on nested objects within a document in Azure Cosmos DB

With Azure Cosmos DB, You can use the object or array relationship defined in your schema, which enables to do filter operations on the nested objects.

```graphql
query {
  books(first: 1, filter : { author : { profile : { twitter : {eq : ""@founder""}}}})
    id
    name
  }
}
```
