---
title: Data API builder CLI
description: This document defines the dab CLI.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: cab-cli
ms.date: 04/06/2023
---

# About `dab` CLI

The Data API builder CLI (**dab CLI** or `dab`) is a command line tool that streamlines the local development experience for applications using Data API builder.

## Key Features of `dab` CLI

- Initialize the configuration file for REST and GraphQL endpoints
- Add new entities
- Update entity details
- Add/update entity relationships
- Configure roles and their permissions
- Configure cross-origin requests (CORS)
- Run the Data API builder engine

## CLI command line

DAB CLI comes with an integrated help system. To get a list of what commands are available, use the `--help` option on the `dab` command.

```shell
dab --help
```

To get help on a specific command, use the `--help` option. For example, to learn more about the `init` command:

```shell
dab init --help
```

## CLI command line verbs and options

### **`init`**

Initializes the runtime configuration for the Data API builder runtime engine. It creates a new JSON file with the properties provided as options.

**Syntax:** `dab init [options]`

**Example:** `dab init --config "dab-config.MsSql.json" --database-type mssql --connection-string "Server=tcp:127.0.0.1,1433;User ID=sa;Password=REPLACEME;Connection Timeout=5;"`

| Options | Option Required | Default Value | Value Required | Value Type | Description | 
| :--- | :--- | :--- | :--- | :--- | :--- | 
| **--database-type** | true | - | true | String | Type of database to connect. Supported values: mssql, cosmosdb_nosql, cosmosdb_postgresql, mysql, postgresql | 
| **--connection-string** | false | "" | true | String | Connection details to connect to the database. | 
| **--cosmosdb_nosql-database** | true when databaseType=cosmosdb_nosql | - | true | String | Database name for Cosmos DB for NoSql. | 
| **--cosmosdb_nosql-container** | false | - | true | String | Container name for Cosmos DB for NoSql. | 
| **--graphql-schema** | true when databaseType=cosmosdb_nosql | - | true | String | GraphQL schema Path | 
| **--set-session-context** | false | false | false | - | Enable sending data to MsSql using session context. | 
| **--host-mode** | false | production | true | String | Specify the Host mode - development or production | 
| **--cors-origin** | false | "" | true | String | Specify the list of allowed origins. | 
| **--auth.provider** | false | StaticWebApps | true | String | Specify the Identity Provider. | 
| **--rest.path** | false | /api | true | String | Specify the REST endpoint's prefix. | 
| **--rest.disabled** | false | false | false | - | Disables REST endpoint for all entities. | 
| **--rest.enabled** | false | true | true | - | Enables REST endpoint for all entities. |
| **--rest.request-body-strict** | false | true | true | - | Does not allow extraneous fields in request body. |
| **--graphql.path** | false | /graphql | true | String | Specify the GraphQL endpoint's prefix. | 
| **--graphql.disabled** | false | false | false | - | Disables GraphQL endpoint for all entities. | 
| **--graphql.enabled** | false | true | true | - | Enables GraphQL endpoint for all entities. |
| **--auth.audience** | false | - | true | String | Identifies the recipients that the JWT is intended for. | 
| **--auth.issuer** | false | - | true | String | Specify the party that issued the JWT token. | 
| **-c,--config** | false | dab-config.json | true | String | Path to config file. |

### **`add`**

Add new database entity to the configuration file. Make sure you already have a configuration file before executing this command, otherwise it returns an error.

**Syntax**: `dab add [entity-name] [options]`

**Example:**: `dab add Book -c "dab-config.MsSql.json" --source dbo.books --permissions "anonymous:*"`

| Options | Option Required | Default Value | Value Required | Value Type | Description | 
| :--- | :--- | :--- | :--- | :--- | :--- | 
| **-s,--source** | true | - | true | String | Name of the source table or container. | 
| **--permissions** | true | - | true | String | Permissions required to access the source table or container. Format "[role]:[actions]". | 
| **--source.type** | false | table | true | String | Type of the database object. Must be one of: [table, view, stored-procedure]. | 
| **--source.params** | false | - | true | String | Dictionary of parameters and their values for Source object."param1:val1,param2:value2,..." for Stored-Procedures. | 
| **--source.key-fields** | true when  `--source.type`  is view | - | true | String | The field(s) to be used as primary keys for tables and views only. Comma separated values. Example `--source.key-fields "id,name,type"`. | 
| **--rest** | false | case sensitive entity name. | true | String | Route for REST API. Example: <br>`--rest: false` -> Disables REST API  calls for this entity.<br>`--rest: true` -> Entity name becomes the rest path. <br>`--rest: "customPathName"` -> Provided customPathName becomes the REST path.| 
| **--rest.methods** | false | post | true | String | HTTP actions to be supported for stored procedure. Specify the actions as a comma separated list. Valid HTTP actions are:[get, post, put, patch, delete]. | 
| **--graphql** | false | case sensitive entity name | true | Bool/String | Entity type exposed for GraphQL. Example: <br>`--graphql: false` -> disables graphql calls for this entity. <br>`--graphql: true` -> Exposes the entity for GraphQL with default names. The singular form of the entity name is considered for the query and mutation names. <br>`--graphql: "customQueryName"` -> Lets the user customize the singular and plural name for queries and mutations. | 
| **--graphql.operation** | false | mutation | true | String | GraphQL operation to be supported for stored procedure. Valid operations are: [query, mutation]. | 
| **--fields.include** | false | - | true | String | Fields with permission to access. | 
| **--fields.exclude** | false | - | true | String | Fields excluded from the action lists. | 
| **--policy-database** | false | - | true | String | Specify an OData style filter rule that is injected in the query sent to the database. | 
| **-c,--config** | false | dab-config.json | true | String | Path to config file. |

### **`update`**

Update the properties of any database entity in the configuration file.

**Syntax**: `dab update [entity-name] [options]`

**Example:** `dab update Publisher --permissions "authenticated:*"`

> [!NOTE]
> `dab update` supports all the options that are supported by `dab add`. Additionally, it also supports the below listed options.

| Options | Option Required | Default Value | Value Required | Value Type | Description |
| --- | --- | --- | --- | --- | --- |
| **--relationship** | false | - | true | String | Specify relationship between two entities. Provide the name of the relationship. |
| **--cardinality** | true when `--relationship` option is used | - | true | String | Specify cardinality between two entities. Could be one or many. |
| **--target.entity** | true when `--relationship` option is used | - | true | String | Another exposed entity that the source entity relates to. |
| **--linking.object** | false | - | true | String | Database object that is used to support an M:N relationship. |
| **--linking.source.fields** | false | - | true | String | Database fields in the linking object to connect to the related item in the source entity. Comma separated fields. |
| **--linking.target.fields** | false | - | true | String | Database fields in the linking object to connect to the related item in the target entity. Comma separated fields. |
| **--relationship.fields** | false | - | true | String | Specify fields to be used for mapping the entities. Example: `--relationship.fields "id:book_id"`. Here `id` represents column from sourceEntity, while `book_id` from targetEntity. Foreign keys are required between the underlying sources if not specified. |
| **-m,--map** | false | - | true | String | Specify mappings between database fields and GraphQL and REST fields. Format: --map "backendName1:exposedName1, backendName2:exposedName2,...". |

### **`export`**

Export the required schema as a file and save to disk based on the options.

**Syntax**: `dab export [options]`

**Example**: `dab export --graphql -o ./schemas`

| Options | Option Required | Default Value | Value Required | Value Type | Description |
| --- | --- | --- | --- | --- | --- |
| **--graphql** | false | false | false | - | Export GraphQL schema. |
| **-o,--output** | true | - | true | String | Specify the directory to save the schema file. |
| **-g,--graphql-schema-file** | false | schema.graphql | true | String | Specify the name of the Graphql schema file. |
| **-c,--config** | false | dab-config.json | true | String | Path to config file. |

### **`start`**

Start the runtime engine with the provided configuration file for serving REST and GraphQL requests.

**Syntax**: `dab start [options]`

**Example**: `dab start`

| Options | Option Required | Default Value | Value Required | Value Type | Description |
| --- | --- | --- | --- | --- | --- |
| **--verbose** | false | - | false | - | Specify logging level as informational. |
| **--LogLevel** | false | Debug when hostMode=development, else Error when HostMode=Production | true | String | Specify logging level as provided value. example: debug, error, information, etc. |
| **--no-https-redirect** | false | false | true | String | Disables automatic https redirects. |
| **-c,--config** | false | dab-config.json | true | String | Path to config file. |

> [!NOTE]
> You can't use `--verbose` and `--LogLevel` at the same time. Learn more about different logging levels [here](/dotnet/api/microsoft.extensions.logging.loglevel?view=dotnet-plat-ext-6.0&preserve-view=true).

### Using Data API builder with two configuration files

You can maintain multiple pairs of baseline and environment specific configuration files to simplify management of your environment specific settings. The following steps demonstrate how to set up a base configuration file with two environment specific configuration files (**development** and **production**):

1. Create a base configuration file `dab-config.json` with all of your settings common across each of your environments.
2. Create two environemnt specific configuration files: `dab-config.development.json` and `dab-config.production.json`. These two configuration files should only include settings which differ from the base configuration file such as connection strings.
3. Next, set the `DAB_ENVIRONMENT` variable based on the environment configuration you want Data API builder to consume. For this example, set `DAB_ENVIRONMENT=development` so the `development` environment configuration file selected.
4. Start Data API builder with the command `dab start`. The engine checks the value of `DAB_ENVIRONMENT` and uses the base file `dab-config.json` and the environment specific file `dab-config.development.json`. When the engine detects the presence of both files, it merges the files into a third file: `dab-config.development.merged.json`.
5. (Optional) Set the `DAB_ENVIRONMENT` environment variable value to `production` when you want the production environment specific settings to be merged with your base configuration file.

> [!NOTE]
> 1. By default, **dab-config.json** is used to start the engine when the `DAB_ENVIRONMENT` environment variable isn't set.
> 2. A user provided config file is used regardless of the `DAB_ENVIRONMENT` environment variable's value. For example, the file `my-config.json` is used when Data API builder is started using `dab start -c my-config.json`
