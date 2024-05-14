---
title: Command-line interface
description: Lists all of the commands and subcommands (verbs) for the Data API builder command-line interface (CLI).
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 05/14/2024
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
| **--rest.disabled** | ❌ No | `false` | ❌ No | | Disables REST endpoint for all entities. |
| **--rest.enabled** | ❌ No | `true` | ✔️ Yes | | Enables REST endpoint for all entities. |
| **--rest.request-body-strict** | ❌ No | `true` | ✔️ Yes | | Doesn't allow extraneous fields in request body. |
| **--graphql.path** | ❌ No | `/graphql` | ✔️ Yes | string | Specify the GraphQL endpoint's prefix. |
| **--graphql.disabled** | ❌ No | `false` | ❌ No | | Disables GraphQL endpoint for all entities. |
| **--graphql.enabled** | ❌ No | `true` | ✔️ Yes | | Enables GraphQL endpoint for all entities. |
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
| **--source.params** | ❌ No | | ✔️ Yes | string | Dictionary of parameters and their values for Source object. `param1:val1,param2:value2,...` for Stored-Procedures. |
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
| **--no-https-redirect** | ❌ No | `false` | ✔️ Yes | string | Disables automatic https redirects. |
| **-c,--config** | ❌ No | `dab-config.json` | ✔️ Yes | string | Path to config file. |

> [!NOTE]
> You can't use `--verbose` and `--LogLevel` at the same time. For more information about different logging levels, see [.NET log levels](/dotnet/api/microsoft.extensions.logging.loglevel).

## Related content

- [Functions reference](reference-functions.md)
- [Configuration reference](reference-configuration.md)
