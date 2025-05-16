---
title: Command-line interface
description: Lists all of the commands and subcommands (verbs) for the Data API builder command-line interface (CLI).
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 06/06/2024
---

# Data API builder command-line interface reference

The Data API builder command-line interface (CLI) (**dab CLI** or `dab`) is a command line tool that streamlines the local development experience for applications using Data API builder.

> [!TIP]
> The Data API builder CLI comes with an integrated help system. To get a list of what commands are available, use the `--help` option on the `dab` command.
>
> ```dotnetcli
> dab --help
> ```
>
> To get help on a specific command, use the `--help` option. For example, to learn more about the `init` command:
>
> ```dotnetcli
> dab init --help
> ```
>

## Command-line verbs and options

### `init`

Initializes the runtime configuration for the Data API builder runtime engine. It creates a new JSON file with the properties provided as options.

#### Syntax

```dotnetcli
dab init [options]
```

#### Examples

```dotnetcli
dab init --config "dab-config.mssql.json" --database-type mssql --connection-string "@env('SQL_CONNECTION_STRING')"
```

```dotnetcli
dab init --database-type mysql --connection-string "@env('MYSQL_CONNECTION_STRING')" --graphql.multiple-create.enabled true
```

#### Options

| Options | Option Required | Default Value | Value Required | Value Type | Description |
| --- | --- | --- | --- | --- | --- |
| **--database-type** | ✔️ Yes | | ✔️ Yes | string | Type of database to connect. Supported values: `mssql`, `cosmosdb_nosql`, `cosmosdb_postgresql`, `mysql`, `postgresql`. |
| **--connection-string** | ❌ No | `""` | ✔️ Yes | string | Connection details to connect to the database. |
| **--cosmosdb_nosql-database** | ✔️ Yes ¹ | | ✔️ Yes | string | Database name for Cosmos DB for NoSql. |
| **--cosmosdb_nosql-container** | ❌ No | | ✔️ Yes | string | Container name for Cosmos DB for NoSql. |
| **--graphql-schema** | ✔️ Yes ¹ | | ✔️ Yes | string | GraphQL schema Path |
| **--set-session-context** | ❌ No | `false` | ❌ No | | Enable sending data to MsSql using session context. |
| **--host-mode** | ❌ No | `production` | ✔️ Yes | string | Specify the Host mode - development or production |
| **--cors-origin** | ❌ No | `""` | ✔️ Yes | string | Specify the list of allowed origins. |
| **--auth.provider** | ❌ No | `StaticWebApps` | ✔️ Yes | string | Specify the Identity Provider. |
| **--rest.path** | ❌ No | `/api` | ✔️ Yes | string | Specify the REST endpoint's prefix. |
| **--rest.enabled** | ❌ No | `true` | ✔️ Yes | boolean | Enables REST endpoint for all entities. |
| **--rest.request-body-strict** | ❌ No | `true` | ✔️ Yes | | Doesn't allow extraneous fields in request body. |
| **--graphql.path** | ❌ No | `/graphql` | ✔️ Yes | string | Specify the GraphQL endpoint's prefix. |
| **--graphql.enabled** | ❌ No | `true` | ✔️ Yes | boolean | Enables GraphQL endpoint for all entities. |
| **--graphql.multiple-create.enabled** | ❌ No | `false` | ✔️ Yes | | Enables multiple create functionality in GraphQL. |
| **--auth.audience** | ❌ No | | ✔️ Yes | string | Identifies the recipients that the Json Web Token (JWT) is intended for. |
| **--auth.issuer** | ❌ No | | ✔️ Yes | string | Specify the party that issued the JWT token. |
| **-c,--config** | ❌ No | `dab-config.json` | ✔️ Yes | string | Path to config file. |

¹ This option is only required when `--database-type` is set to `cosmosdb_nosql`.

### `add`

Add new database entity to the configuration file. Make sure you already have a configuration file before executing this command, otherwise it returns an error.

#### Syntax

```dotnetcli
dab add [entity-name] [options]
```

#### Examples

```dotnetcli
dab add Book -c "dab-config.MsSql.json" --source dbo.books --permissions "anonymous:*"
```

#### Options

| Options | Option Required | Default Value | Value Required | Value Type | Description |
| --- | --- | --- | --- | --- | --- |
| **-s,--source** | ✔️ Yes | | ✔️ Yes | string | Name of the source table or container. |
| **--permissions** | ✔️ Yes | | ✔️ Yes | string | Permissions required to access the source table or container. Format: `[role]:[actions]`. |
| **--source.type** | ❌ No | `table` | ✔️ Yes | string | Type of the database object. Supported values: `table`, `view`, `stored-procedure`. |
| **--source.params** | ❌ No | | ✔️ Yes, if proc has params | string | A dictionary of stored procedure parameters and their data types. Supported data types are `string`, `number`, and `boolean`. Parameters are specified in the format: `paramName:type`. For example: `--source.params "id:number,isActive:boolean,name:string"`. |
| **--source.key-fields** | ✔️ Yes ¹ | | ✔️ Yes | string | One or more fields to be used as primary keys for tables and views only. Comma separated values. Example `--source.key-fields "id,name,type"`. |
| **--rest** | ❌ No | *case-sensitive entity name* | ✔️ Yes | string | Route for REST API. Examples: `--rest: false` -> Disables REST API  calls for this entity. `--rest: true` -> Entity name becomes the rest path. `--rest: "customPathName"` -> Provided customPathName becomes the REST path.|
| **--rest.methods** | ❌ No | `post` | ✔️ Yes | string | HTTP actions to be supported for stored procedure. Specify the actions as a comma separated list. Valid HTTP actions are:[get, post, put, patch, delete]. |
| **--graphql** | ❌ No | *case-sensitive entity name* | ✔️ Yes | Bool/String | Entity type exposed for GraphQL. Examples: `--graphql: false` -> disables graphql calls for this entity. `--graphql: true` -> Exposes the entity for GraphQL with default names. The singular form of the entity name is considered for the query and mutation names. `--graphql: "customQueryName"` -> Explicitly sets the singular value while DAB pluralizes the provided value for queries and mutations. `--graphql: "singularName:pluralName"` -> Sets both the singular and plural values (delimited by a colon `:`) used for queries and mutations. |
| **--graphql.operation** | ❌ No | `mutation` | ✔️ Yes | string | GraphQL operation to be supported for stored procedure. Supported values: `query`, `mutation`. |
| **--fields.include** | ❌ No | | ✔️ Yes | string | Fields with permission to access. |
| **--fields.exclude** | ❌ No | | ✔️ Yes | string | Fields excluded from the action lists. |
| **--policy-database** | ❌ No | | ✔️ Yes | string | Specify an OData style filter rule that is injected in the query sent to the database. |
| **-c,--config** | ❌ No | `dab-config.json` | ✔️ Yes | string | Path to config file. |

¹ This option is only required when `--source.type` is set to `view`.

### `update`

Update the properties of any database entity in the configuration file.

> [!NOTE]
> `dab update` supports all the options that are supported by `dab add`. Additionally, it also supports the listed options.

#### Syntax

```dotnetcli
dab update [entity-name] [options]
```

#### Examples

```dotnetcli
dab update Publisher --permissions "authenticated:*"
```

#### Options

| Options | Option Required | Default Value | Value Required | Value Type | Description |
| --- | --- | --- | --- | --- | --- |
| **--relationship** | ❌ No | | ✔️ Yes | string | Specify relationship between two entities. Provide the name of the relationship. |
| **--cardinality** | ✔️ Yes ¹ | | ✔️ Yes | string | Specify cardinality between two entities. Could be one or many. |
| **--target.entity** | ✔️ Yes ¹ | | ✔️ Yes | string | Another exposed entity that the source entity relates to. |
| **--linking.object** | ❌ No | | ✔️ Yes | string | Database object that is used to support an M:N relationship. |
| **--linking.source.fields** | ❌ No | | ✔️ Yes | string | Database fields in the linking object to connect to the related item in the source entity. Comma separated fields. |
| **--linking.target.fields** | ❌ No | | ✔️ Yes | string | Database fields in the linking object to connect to the related item in the target entity. Comma separated fields. |
| **--relationship.fields** | ❌ No | | ✔️ Yes | string | Specify fields to be used for mapping the entities. Example: `--relationship.fields "id:book_id"`. Here, `id` represents column from sourceEntity, while `book_id` from targetEntity. Foreign keys are required between the underlying sources if not specified. |
| **-m,--map** | ❌ No | | ✔️ Yes | string | Specify mappings between database fields and GraphQL and REST fields. Format: `--map "backendName1:exposedName1, backendName2:exposedName2,..."`. |

¹ This option is only required when the `--relationship` option is used.

### `export`

Export the required schema as a file and save to disk based on the options.

#### Syntax

```dotnetcli
dab export [options]
```

#### Examples

```dotnetcli
dab export --graphql -o ./schemas
```

#### Options

| Options | Option Required | Default Value | Value Required | Value Type | Description |
| --- | --- | --- | --- | --- | --- |
| **--graphql** | ❌ No | `false` | ❌ No | | Export GraphQL schema. |
| **-o,--output** | ✔️ Yes | | ✔️ Yes | string | Specify the directory to save the schema file. |
| **-g,--graphql-schema-file** | ❌ No | `schema.graphql` | ✔️ Yes | string | Specify the name of the Graphql schema file. |
| **-c,--config** | ❌ No | `dab-config.json` | ✔️ Yes | string | Path to config file. |

### `start`

Start the runtime engine with the provided configuration file for serving REST and GraphQL requests.

#### Syntax

```dotnetcli
dab start [options]
```

#### Examples

```dotnetcli
dab start
```

#### Options

| Options | Option Required | Default Value | Value Required | Value Type | Description |
| --- | --- | --- | --- | --- | --- |
| **--verbose** | ❌ No | | ❌ No | | Specify logging level as informational. |
| **--LogLevel** | ❌ No | *`Debug` when `hostMode=development`, else `Error` when `HostMode=Production`* | ✔️ Yes | string | Specify logging level as provided value. example: debug, error, information, etc. |
| **--no-https-redirect** | ❌ No |  | ✔️ Yes | - | Disables automatic https redirects. |
| **-c,--config** | ❌ No | `dab-config.json` | ✔️ Yes | string | Path to config file. |

> [!NOTE]
> You can't use `--verbose` and `--LogLevel` at the same time. For more information about different logging levels, see [.NET log levels](/dotnet/api/microsoft.extensions.logging.loglevel).

### `validate`

Validates the runtime config file used by the Data API builder runtime engine. The validation process ensures that the config file is compliant with the schema and contains all the required information for the runtime engine to function correctly.

#### Syntax

```dotnetcli
dab validate [options]
```

#### Examples

```dotnetcli
dab validate
```

#### Options

| Options | Option Required | Default Value | Value Required | Value Type | Description |
| --- | --- | --- | --- | --- | --- |
| **-c,--config** | ❌ No | `dab-config.json` | ✔️ Yes | string | Path to the config file that is the target of validation. |

### `configure`

The `dab configure` command is designed to simplify updating config properties outside of the entities section. This document outlines the design, functionality, and implementation details of the dab configure command. It supports to edit the CLI for configuration properties in data-source and runtime sections of the runtime config.

> [!NOTE]
> `dab configure` is only for updating the data-source and runtime sections of the config. For the entities section, we already have the dab update command.

#### Syntax

```dotnetcli
dab configure [options] [value]
```

#### Examples

```dotnetcli
dab configure --runtime.rest.enabled true
```

#### Options

| Configuration File Property | CLI Flag | Data Type | Nullable | Description |
|-----------------------|-------------------------------------------|-----------|----------|----------------------------------------------------|
| data-source.<br/>database-type                                          | <nobr>--data-source.database-type</nobr>                           | String: `MSSQL`, `PostgreSQL`, `CosmosDB_NoSQL`, `MySQL` | ❌ | This value indicates the Database type. |
| data-source.<br/>connection-string                                      | <nobr>--data-source.connection-string</nobr>                       | String    | ❌       | Refers to the connection string for the data source. |
| data-source.<br/>options.database                                       | <nobr>--data-source.options.database</nobr>                        | String    | ✅       | Refers to the database name for Cosmos DB for NoSql. |
| data-source.<br/>options.container                                      | <nobr>--data-source.options.container</nobr>                       | String    | ✅       | Refers to the Container name for Cosmos DB for NoSql. |
| data-source.<br/>options.schema                                         | <nobr>--data-source.options.schema</nobr>                          | String    | ✅       | Provides the Schema path for Cosmos DB for NoSql. |
| data-source.<br/>options.set-session-context                            | <nobr>--data-source.options.set-session-context</nobr>             | Boolean: `true`, `false` (default: `true`) | ✅ | Whether to Enable session context. |
| runtime.<br/>rest.enabled                                               | <nobr>--runtime.rest.enabled</nobr>                                | Boolean: `true`, `false` (default: `true`) | ❌ | Signifies whether to Enable DAB's REST endpoint. |
| runtime.<br/>rest.path                                                  | <nobr>--runtime.rest.path</nobr>                                   | String (default: `/api`) | ❌       | Customize DAB's REST endpoint path. Conditions: Prefix with '/', no spaces and no reserved characters. |
| runtime.<br/>rest.request-body-strict                                   | <nobr>--runtime.rest.request-body-strict</nobr>                    | Boolean: `true`, `false` (default: `true`) | ✅ | Allows/Prohibits extraneous REST request body fields. |
| runtime.<br/>graphql.enabled                                            | <nobr>--runtime.graphql.enabled</nobr>                             | Boolean: `true`, `false` (default: `true`) | ❌ | Enable/Disable DAB's GraphQL endpoint. 
| runtime.<br/>graphql.path                                               | <nobr>--runtime.graphql.path</nobr>                                | String (default: `/graphql`) | ❌       | Customize DAB's GraphQL endpoint path. Conditions: Prefix with '/', no spaces and no reserved characters. |
| runtime.<br/>graphql.depth-limit                                                       | <nobr>--runtime.graphql.depth-limit</nobr>                                   | Integer | ✅ | This refers to the Max allowed depth of the graphQL nested query. Allowed values: (0,2147483647] inclusive. Default is infinity. Use -1 to remove limit. |
| runtime.<br/>graphql.allow-introspection                                | <nobr>--runtime.graphql.allow-introspection</nobr>                 | Boolean: `true`, `false` (default: `true`) | ✅ | Allow/Deny GraphQL introspection requests in GraphQL Schema. |
| runtime.<br/>graphql.multiple-mutations.create.enabled                  | <nobr>--runtime.graphql.multiple-mutations.create.enabled</nobr>   | Boolean: `true`, `false` (default: `true`) | ✅ | Enable/Disable multiple-mutation create operations on DAB's generated GraphQL schema. |
| runtime.<br/>host.mode                                                  | <nobr>--runtime.host.mode</nobr>                                   | String: `Development`, `Production` Default: `Development` | ❌ | Set the host running mode of DAB in Development or Production. |
| runtime.<br/>host.cors.origins                                          | <nobr>--runtime.host.cors.origins</nobr>                           | Array of strings | ✅ | Use this to Overwrite Allowed Origins in CORS. Default: [] (Space separated array of strings). |
| runtime.<br/>host.cors.allow-credentials                                | <nobr>--runtime.host.cors.allow-credentials</nobr>                 | Boolean: `true`, `false` (default: `false`) | ✅ | Set value for Access-Control Allow-Credentials header in --host.cors.allow-credentials . |
| runtime.<br/>host.authentication.provider                               | <nobr>--runtime.host.authentication.provider</nobr>                | String: `StaticWebApps`, `AppService`, `EntraId`, `Jwt` | ✅ | Configure the name of authentication provider. Default: `StaticWebApps`. |
| runtime.<br/>host.authentication.jwt.audience                           | <nobr>--runtime.host.authentication.jwt.audience</nobr>            | Array of strings | ✅ | Use this to Configure the intended recipient(s) of the Jwt Token. |
| runtime.<br/>host.authentication.jwt.issuer                             | <nobr>--runtime.host.authentication.jwt.issuer</nobr>              | String    | ✅       | This refers to the entity that issued the Jwt Token. |
| runtime.<br/>cache.enabled                                              | <nobr>--runtime.cache.enabled</nobr>                               | Boolean: `true`, `false` (default: `false`) | ✅ | Enable/Disable DAB's cache globally. (You must also enable each entity's cache separately.). |
| runtime.<br/>cache.ttl-seconds                                          | <nobr>--runtime.cache.ttl-seconds</nobr>                           | Integer (default: `5`) | ✅       | Customize the DAB cache's global default time to live in seconds. |

## Related content

- [Functions reference](reference-functions.md)
- [Configuration reference](reference-configuration.md)
