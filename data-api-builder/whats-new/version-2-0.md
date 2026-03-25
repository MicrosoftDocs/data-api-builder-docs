---
title: What's new for version 2.0
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 2.0.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: whats-new
ms.date: 03/24/2026
---

# What’s new in Data API builder version 2.0 (March 2026)

Data API builder 2.0 focuses on Model Context Protocol (MCP) and AI integration, simpler authentication defaults, and better configuration automation. This release also brings stronger observability and more flexible REST and OpenAPI behavior.

## Authentication and authorization

### `Unauthenticated` is now the default authentication provider

DAB 2.0 introduces `Unauthenticated` as a new authentication provider and makes it the default for new configurations. When this provider is active, all requests run as `anonymous`. DAB doesn't inspect or validate any JSON Web Token (JWT). The upstream service handles authentication—for example, Azure API Management or an application gateway.

#### Why?

Now, when DAB sits behind a trusted front end that handles identity, you don't need to configure a JWT provider just to get started. Running `dab init` produces a working config without any extra auth options.

```bash
dab init --database-type mssql --connection-string "Server=localhost;Database=mydb;"
```

#### Generated configuration

```json
{
	"runtime": {
		"host": {
			"authentication": {
				"provider": "Unauthenticated"
			}
		}
	}
}
```

To use a different provider, set it explicitly:

```bash
dab init --database-type mssql --connection-string "..." --auth.provider AppService
```

> [!IMPORTANT]
> When `Unauthenticated` is active, `authenticated` and custom roles defined in entity permissions are never activated. If your config contains those roles, DAB emits a warning at startup.

---

### Role inheritance for entity permissions

DAB 2.0 adds role inheritance so you don't need to repeat the same permission block across every role. The inheritance chain is:

```
named-role → authenticated → anonymous
```

If `authenticated` isn't explicitly configured for an entity, it inherits from `anonymous`. If a named role isn't configured, it inherits from `authenticated`, or from `anonymous` if `authenticated` is also absent.

#### Why?

With role inheritance, you can define permissions once on `anonymous` and every broader role gets the same access automatically, no duplication required.

```json
{
	"entities": {
		"Book": {
			"source": "dbo.books",
			"permissions": [
				{ "role": "anonymous", "actions": [ "read" ] }
			]
		}
	}
}
```

With this configuration, `anonymous`, `authenticated`, and any unconfigured named role can all read `Book`.

---

### Show effective permissions with the CLI

A new `--show-effective-permissions` option on `dab configure` displays the resolved permissions for every entity after inheritance is applied.

#### Why?

If you're unsure what a role can do after inheritance rules take effect, run this command to get the answer instead of reasoning through the config manually.

```bash
dab configure --show-effective-permissions
dab configure --show-effective-permissions --config my-config.json
```

#### Example output

```text
Entity: Book
	Role: anonymous        | Actions: Read
	Role: authenticated    | Actions: Read (inherited from: anonymous)
	Unconfigured roles inherit from: anonymous

Entity: Order
	Role: admin            | Actions: Create, Read, Update, Delete
	Role: anonymous        | Actions: Read
	Role: authenticated    | Actions: Read (inherited from: anonymous)
	Unconfigured roles inherit from: authenticated
```

---

### On-Behalf-Of (OBO) user-delegated authentication for SQL

DAB 2.0 adds On-Behalf-Of (OBO) authentication for SQL Server and Azure SQL. When enabled, DAB exchanges the incoming user token for a downstream SQL token so the database authenticates as the actual calling user.

#### Why?

With OBO authentication, you can build APIs where the SQL database sees and enforces the real user identity, which is required for row-level security policies and compliance auditing. This feature is available only for `mssql` data sources and requires Entra ID authentication upstream.

```json
{
	"data-source": {
		"database-type": "mssql",
		"connection-string": "@env('SQL_CONNECTION_STRING')",
		"user-delegated-auth": {
			"enabled": true,
			"provider": "EntraId",
			"database-audience": "https://database.windows.net"
		}
	}
}
```

#### Required environment variables

```text
DAB_OBO_CLIENTID
DAB_OBO_CLIENTSECRET
DAB_OBO_TENANTID
```

#### CLI example

```bash
dab configure --data-source.user-delegated-auth.enabled true
dab configure --data-source.user-delegated-auth.database-audience "https://database.windows.net"
```

> [!IMPORTANT]
> OBO is supported only for `mssql`. `database-audience` is required when OBO is enabled. Running this configuration against a non-MSSQL data source fails validation.

---

### Per-user connection pooling (OBO)

When OBO is enabled, DAB maintains separate SQL connection pools per user so that one user's access token is never reused for another user's request.

#### Why?

Now, when row-level security depends on who is connected, you can be confident that connection reuse across users doesn't silently grant the wrong access.

> [!NOTE]
> This behavior applies only when OBO authentication is active. Standard deployments are unaffected.

---

## Configuration and CLI

### Introducing: `dab auto-config`

`dab auto-config` is a new command for creating or updating `autoentities` definitions from the CLI. Autoentities let you define a pattern-based rule that automatically exposes matching database objects as DAB entities.

#### Why?

With `auto-config`, you can wire up an entire database schema as a DAB API without writing a single entity block by hand. Define your patterns once and DAB does the rest.

```bash
dab auto-config my-def \
	--patterns.include "dbo.%" \
	--patterns.exclude "dbo.internal%" \
	--patterns.name "{schema}_{table}" \
	--permissions "anonymous:read"
```

#### Template example

```bash
dab auto-config my-def \
	--template.rest.enabled true \
	--template.graphql.enabled true \
	--template.cache.enabled true \
	--template.cache.ttl-seconds 30 \
	--template.cache.level L1L2
```

#### Resulting configuration

```json
{
	"autoentities": {
		"my-def": {
			"patterns": {
				"include": [ "dbo.%" ],
				"exclude": [ "dbo.internal%" ],
				"name": "{schema}_{table}"
			},
			"template": {
				"rest": { "enabled": true },
				"graphql": { "enabled": true },
				"cache": { "enabled": true, "ttl-seconds": 30, "level": "l1l2" }
			},
			"permissions": [
				{ "role": "anonymous", "actions": [ { "action": "read" } ] }
			]
		}
	}
}
```

---

### Introducing: `dab auto-config-simulate`

`dab auto-config-simulate` previews which database objects match your autoentities patterns before you commit any changes. It connects to the database, resolves each pattern, and prints the matched objects.

#### Why?

Now, you can verify your include and exclude patterns produce exactly the entities you expect before touching the live config.

#### [Console](#tab/console)

```bash
dab auto-config-simulate
```

```text
AutoEntities Simulation Results

Filter: my-def
Matches: 3
	dbo_Products  →  dbo.Products
	dbo_Inventory →  dbo.Inventory
	dbo_Pricing   →  dbo.Pricing
```

#### [CSV](#tab/csv)

```bash
dab auto-config-simulate --output results.csv
```

```csv
filter_name,entity_name,database_object
my-def,dbo_Products,dbo.Products
my-def,dbo_Inventory,dbo.Inventory
my-def,dbo_Pricing,dbo.Pricing
```

---

> [!NOTE]
> `dab auto-config-simulate` currently executes against MSSQL autoentity filters.

---

### Default OpenTelemetry settings in `dab init`

New configurations generated by `dab init` now include a default OpenTelemetry section prewired to standard OpenTelemetry (OTEL) environment variables.

#### Why?

Now, when you deploy DAB in a container or an Aspire app, the observability plumbing is already there. You just set the environment variables—no manual config edits needed.

```json
{
	"telemetry": {
		"open-telemetry": {
			"enabled": true,
			"endpoint": "@env('OTEL_EXPORTER_OTLP_ENDPOINT')",
			"headers": "@env('OTEL_EXPORTER_OTLP_HEADERS')",
			"service-name": "@env('OTEL_SERVICE_NAME')"
		}
	}
}
```

If the environment variables aren't set, DAB starts normally and skips OpenTelemetry Protocol (OTLP) exporter setup. Unresolved `@env(...)` values are tolerated at startup.

---

## MCP and AI integration

### Entity-level MCP configuration

DAB 2.0 adds an `mcp` property at the entity level to control MCP participation per entity. It accepts a boolean shorthand or a full object.

#### Why?

With entity-level MCP configuration, you can expose only the entities that make sense for AI tools, disable MCP on sensitive tables, and enable custom tool generation for stored procedures—all without changing your REST or GraphQL configuration.

#### [Boolean shorthand](#tab/bool)

```json
{
	"entities": {
		"Book": {
			"source": "books",
			"mcp": true
		}
	}
}
```

`true` enables data manipulation language (DML) tools. `false` disables MCP for this entity entirely.

#### [Object format](#tab/object)

```json
{
	"entities": {
		"GetBookById": {
			"source": {
				"object": "dbo.get_book_by_id",
				"type": "stored-procedure"
			},
			"mcp": {
				"dml-tools": false,
				"custom-tool": true
			}
		}
	}
}
```

---

`dml-tools` and `custom-tool` are independent. `custom-tool` is valid only for stored-procedure entities. If `mcp` is omitted from an entity, DML tools remain enabled by default.

CLI equivalents:

```bash
dab add Book --source books --permissions "anonymous:*" --mcp.dml-tools true
dab add GetBookById --source dbo.get_book_by_id --source.type stored-procedure \
	--permissions "anonymous:execute" --mcp.custom-tool true
```

---

### Custom MCP tools from stored procedures

When `custom-tool: true` is set on a stored-procedure entity, DAB dynamically registers that procedure as a named MCP tool exposed through the standard `tools/list` and `tools/call` methods.

#### Why?

Now, you can give AI agents purpose-built tools backed by your existing stored procedures—without writing any glue code. The tool appears in the MCP tool list and accepts the same parameters as the procedure.

```json
{
	"jsonrpc": "2.0",
	"method": "tools/call",
	"params": {
		"name": "get_book_by_id",
		"arguments": { "id": 1 }
	},
	"id": 1
}
```

---

## REST and OpenAPI

### OpenAPI now reflects actual permissions

The OpenAPI document now shows only the HTTP methods and fields that are accessible based on permissions. A new role-specific path `/openapi/{role}` lets you see exactly what a given role can do.

#### Why?

With permission-aware OpenAPI, your document is a reliable contract. Clients and API consumers see only what they're allowed to call, not the full internal surface.

#### Available paths

```text
/openapi
/openapi/anonymous
/openapi/authenticated
/openapi/admin
```

#### Permission-to-method mapping

| Permission | HTTP methods |
|---|---|
| `read` | `GET` |
| `create` | `POST` |
| `create` + `update` | `PUT`, `PATCH` |
| `delete` | `DELETE` |

> [!IMPORTANT]
> `/openapi/{role}` is available in **Development** mode only to prevent role enumeration in production.

---

### Advanced REST paths with subdirectories

Entity REST paths can now include forward slashes, allowing subdirectory-style URL segments.

#### Why?

Now, you can group related entities under a shared path prefix, making your REST API feel more naturally organized without any router configuration.

```json
{
	"entities": {
		"ShoppingCartItem": {
			"source": "dbo.ShoppingCartItem",
			"rest": { "path": "shopping-cart/item" }
		},
		"InvoiceItem": {
			"source": "dbo.InvoiceItem",
			"rest": { "path": "invoice/item" }
		}
	}
}
```

#### Resulting paths

```text
/api/shopping-cart/item
/api/invoice/item
```

DAB uses longest-prefix matching for routing. Validation blocks path traversal patterns, backslashes, and percent-encoded path separators in config values.

---

### Keyless `PUT` and `PATCH` for autogenerated primary keys

DAB 2.0 allows `PUT` and `PATCH` requests without a primary key in the URL when the database autogenerates all omitted key columns.

#### Why?

With keyless upserts, you can insert a new row with a server-generated key using the same upsert semantics you're used to—no need to pregenerate or supply the key yourself.

#### [PUT](#tab/put)

```http
PUT /api/Book
Content-Type: application/json

{
	"title": "My New Book",
	"publisher_id": 1234
}
```

#### [PATCH](#tab/patch)

```http
PATCH /api/Book
Content-Type: application/json

{
	"title": "Another New Book",
	"publisher_id": 5678
}
```

---

For composite keys, any non-autogenerated portions must still be supplied. Stored procedures are unaffected. OpenAPI documents these keyless operations on the base entity path automatically.

---

### HTTP response compression

DAB 2.0 adds HTTP response compression for REST and GraphQL responses.

#### Why?

Now, you can reduce payload sizes over the wire with a single config setting, which is especially useful for large result sets or low-bandwidth environments.

```json
{
	"runtime": {
		"compression": {
			"level": "optimal"
		}
	}
}
```

#### Supported levels and CLI

Supported levels: `optimal`, `fastest`, `none`.

```bash
dab configure --runtime.compression.level optimal
```

---

## Observability and health

### `currentRole` in the `/health` response

The `/health` endpoint now includes a `currentRole` field indicating the effective role of the caller.

#### Why?

With this field, you can confirm at a glance what role DAB is using to evaluate a request, which is especially handy when debugging auth configuration or upstream header forwarding.

#### Role resolution order

An explicit `X-MS-API-ROLE` header wins; otherwise `authenticated` if a client principal token is present; otherwise `anonymous`.

#### [Anonymous request](#tab/anon)

```http
GET /health
```

```json
{
	"status": "Healthy",
	"version": "2.0.0",
	"currentRole": "anonymous"
}
```

#### [Authenticated request](#tab/auth)

```http
GET /health
X-MS-CLIENT-PRINCIPAL: <base64-token>
```

```json
{
	"status": "Healthy",
	"version": "2.0.0",
	"currentRole": "authenticated"
}
```

#### [Explicit role header](#tab/role)

```http
GET /health
X-MS-API-ROLE: myrole
```

```json
{
	"status": "Healthy",
	"version": "2.0.0",
	"currentRole": "myrole"
}
```

---

### OpenTelemetry tracing for MCP execution

MCP tool execution is now included in OpenTelemetry traces alongside REST and GraphQL traffic.

#### Why?

Now, you can monitor and correlate AI agent tool calls the same way you monitor API requests—using the same dashboards, the same trace IDs, and the same tooling.

This works automatically when OpenTelemetry is configured. Because `dab init` now generates a default telemetry section, new apps have out-of-the-box observability for all three endpoint types.

---

## Deployment

### .NET Aspire sample

DAB 2.0 includes a new sample under `samples/` demonstrating how to compose DAB within a .NET Aspire application host. The sample shows DAB alongside other Aspire services and uses the default OTEL configuration now generated by `dab init`.

#### Why?

With this sample, you have a working starting point for Aspire-based architectures where DAB is one component in a larger orchestrated system.
