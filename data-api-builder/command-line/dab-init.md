# `init` command

Initialize a new Data API builder configuration file. The resulting JSON captures data source details, enabled endpoints (REST, GraphQL, MCP), authentication, and runtime behaviors.

## Syntax

```bash
dab init [options]
```

If the target config file already exists, the command overwrites it. There is no merge. Use version control or backups if you need to preserve the previous file.

### Quick glance

| Option                                                                  | Summary                                                                                          |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| [`--database-type`](#--database-type)                                   | Required. Database type: `mssql`, `mysql`, `postgresql`, `cosmosdb_postgresql`, `cosmosdb_nosql` |
| [`--connection-string`](#--connection-string)                           | Database connection string (supports `@env()`)                                                   |
| [`--cosmosdb_nosql-database`](#--cosmosdb_nosql-database)               | Cosmos DB NoSQL database name (required for cosmosdb_nosql)                                      |
| [`--cosmosdb_nosql-container`](#--cosmosdb_nosql-container)             | Cosmos DB NoSQL container name (optional)                                                        |
| [`--graphql-schema`](#--graphql-schema)                                 | Path to GraphQL schema (required for cosmosdb_nosql)                                             |
| [`--set-session-context`](#--set-session-context)                       | Enable SQL Server session context (mssql only)                                                   |
| [`--host-mode`](#--host-mode)                                           | Host mode: Development or Production (default Production)                                        |
| [`--cors-origin`](#--cors-origin)                                       | Allowed origins list (comma-separated)                                                           |
| [`--auth.provider`](#--authprovider)                                    | Identity provider (default StaticWebApps)                                                        |
| [`--auth.audience`](#--authaudience)                                    | JWT audience claim                                                                               |
| [`--auth.issuer`](#--authissuer)                                        | JWT issuer claim                                                                                 |
| [`--rest.path`](#--restpath)                                            | REST endpoint prefix (default /api, ignored for cosmosdb_nosql)                                  |
| [`--rest.enabled`](#--restenabled)                                      | Enable REST (default true, prefer over `--rest.disabled`)                                        |
| [`--rest.disabled`](#--restdisabled)                                    | Deprecated. Disables REST (use `--rest.enabled false`)                                           |
| [`--rest.request-body-strict`](#--restrequest-body-strict)              | Enforce strict request body validation (default true, ignored for cosmosdb_nosql)                |
| [`--graphql.path`](#--graphqlpath)                                      | GraphQL endpoint prefix (default /graphql)                                                       |
| [`--graphql.enabled`](#--graphqlenabled)                                | Enable GraphQL (default true)                                                                    |
| [`--graphql.disabled`](#--graphqldisabled)                              | Deprecated. Disables GraphQL (use `--graphql.enabled false`)                                     |
| [`--graphql.multiple-create.enabled`](#--graphqlmultiple-createenabled) | Allow multiple create mutations (default false)                                                  |
| [`--mcp.path`](#--mcppath)                                              | MCP endpoint prefix (default /mcp)                                                               |
| [`--mcp.enabled`](#--mcpenabled)                                        | Enable MCP (default true)                                                                        |
| [`--mcp.disabled`](#--mcpdisabled)                                      | Deprecated. Disables MCP (use `--mcp.enabled false`)                                             |
| [`--runtime.base-route`](#--runtimebase-route)                          | Global prefix for all endpoints                                                                  |
| [`-c, --config`](#-c---config)                                          | Output config file name (default dab-config.json)                                                |

> [!IMPORTANT]
> Do not mix the new `--*.enabled` flags and the legacy `--*.disabled` flags for the same subsystem in the same command. Prefer the `--*.enabled` pattern; the `--rest.disabled`, `--graphql.disabled`, and `--mcp.disabled` options log warnings and will be removed in future versions.

## `--database-type`

Specifies the target database engine.
Supported: `mssql`, `mysql`, `postgresql`, `cosmosdb_postgresql`, `cosmosdb_nosql`.

**Example**

```sh
dab init --database-type mssql
```

## `--connection-string`

Supply a direct connection string or reference environment variables with `@env()`.

**Example**

```sh
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')"
```

If omitted at init, you must add it later before `dab start` can connect.

## `--cosmosdb_nosql-database`

Cosmos DB NoSQL database name.

> [!Note]
> Required only when `--database-type` is `cosmosdb_nosql`.

**Example**

```sh
dab init --database-type cosmosdb_nosql --cosmosdb_nosql-database MyDb
```

## `--cosmosdb_nosql-container`

Cosmos DB NoSQL container name. Optional.

**Example**

```sh
dab init --database-type cosmosdb_nosql --cosmosdb_nosql-container MyContainer
```

## `--graphql-schema`

Path to a GraphQL schema file.

> [!Note]
> Required only when `--database-type` is `cosmosdb_nosql`.

**Example**

```sh
dab init --database-type cosmosdb_nosql --graphql-schema ./schema.gql
```

## `--set-session-context`

Enable sending data to SQL Server using session context. Only meaningful for `mssql`. Default is `false`.

**Example**

```sh
dab init --database-type mssql --set-session-context true
```

## `--host-mode`

Specify host mode. Default is `Production`.

Valid values: `Development`, `Production`.

**Example**

```sh
dab init --database-type mssql --host-mode development
```

## `--cors-origin`

Comma-separated list of allowed origins.

**Example**

```sh
dab init --database-type mssql --cors-origin "https://app.example.com,https://admin.example.com"
```

## `--auth.provider`

Identity provider. Default is `StaticWebApps`.

**Example**

```sh
dab init --database-type mssql --auth.provider AzureAD
```

## `--auth.audience`

JWT audience claim.

**Example**

```sh
dab init --database-type mssql --auth.audience "https://example.com/api"
```

## `--auth.issuer`

JWT issuer claim.

**Example**

```sh
dab init --database-type mssql --auth.issuer "https://login.microsoftonline.com/{tenant-id}/v2.0"
```

## `--rest.path`

REST endpoint prefix. Default is `/api`. Must start with `/`.

> [!Note]
> Ignored with a warning when using `cosmosdb_nosql`.

**Example**

```sh
dab init --database-type mssql --rest.path /rest
```

## `--rest.enabled`

Enable REST endpoint for all entities. Default is `true`.

**Example**

```sh
dab init --database-type mssql --rest.enabled false
```

## `--rest.disabled`

Deprecated. Disables REST endpoint. Prefer `--rest.enabled false`.

## `--rest.request-body-strict`

Controls handling of extra fields in request bodies. Default is `true`.

* `true`: Rejects extraneous fields (HTTP 400).
* `false`: Ignores extra fields.

> [!Note]
> Ignored with a warning when using `cosmosdb_nosql`.

**Example**

```sh
dab init --database-type mssql --rest.request-body-strict false
```

## `--graphql.path`

GraphQL endpoint prefix. Default is `/graphql`.

**Example**

```sh
dab init --database-type mssql --graphql.path /gql
```

## `--graphql.enabled`

Enable GraphQL endpoint. Default is `true`.

**Example**

```sh
dab init --database-type mssql --graphql.enabled false
```

## `--graphql.disabled`

Deprecated. Disables GraphQL endpoint. Prefer `--graphql.enabled false`.

## `--graphql.multiple-create.enabled`

Default is `false`. Allows bulk create mutations in GraphQL.

**Example**

```sh
dab init --database-type mssql --graphql.multiple-create.enabled true
```

## `--mcp.path`

MCP endpoint prefix. Default is `/mcp`.

**Example**

```sh
dab init --database-type mssql --mcp.path /model
```

## `--mcp.enabled`

Enable MCP endpoint. Default is `true`.

**Example**

```sh
dab init --database-type mssql --mcp.enabled false
```

## `--mcp.disabled`

Deprecated. Disables MCP endpoint. Prefer `--mcp.enabled false`.

## `--runtime.base-route`

Global prefix prepended to all endpoints. Must begin with `/`.

**Example**

```sh
dab init --database-type mssql --runtime.base-route /v1
```

Final routes with defaults:

* REST: `/v1/api`
* GraphQL: `/v1/graphql`
* MCP: `/v1/mcp`

## `-c, --config`

Path to the output configuration file. Default is `dab-config.json`.

**Example**

```sh
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --config dab-config.local.json
```
