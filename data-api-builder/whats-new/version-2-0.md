---
title: What's new for version 2.0 - Preview
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 2.0.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: whats-new
ms.date: 03/24/2026
---

# What's new in Data API builder version 2.0 (March 2026)

> [!NOTE]
> Version 2.0 is in public preview. Some features may not yet be recommended for production use. Refer to the documentation for details on feature availability and stability.

Data API builder 2.0 focuses on Model Context Protocol (MCP) and AI integration, simpler authentication defaults, and better configuration automation. This release also brings stronger observability and more flexible REST and OpenAPI behavior.

## Introducing: the new `Unauthenticated` provider

DAB 2.0 introduces `Unauthenticated` as a new authentication provider and makes it the default for new configurations. When this provider is active, all requests run as `anonymous`. DAB doesn't inspect or validate any JSON Web Token (JWT). The upstream service handles authentication—for example, Azure API Management or an application gateway.

### Why?

Now, when DAB sits behind a trusted front end that handles identity, you don't need to configure a JWT provider just to get started. Running `dab init` produces a working config without any extra auth options.

### Command line

```bash
dab init --database-type mssql --connection-string "Server=localhost;Database=mydb;"
```

#### Resulting configuration

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

> [!IMPORTANT]
> When `Unauthenticated` is active, `authenticated` and custom roles defined in entity permissions are never activated. If your config contains those roles, DAB emits a warning at startup.

### Read the docs

- [Choose your authentication provider](../concept/security/index.md#choose-your-authentication-provider)
- [`dab init --auth.provider`](../command-line/dab-init.md#--authprovider)

## Introducing: Role inheritance

DAB 2.0 adds role inheritance so you don't need to repeat the same permission block across every role. The inheritance chain is:

```
named-role → authenticated → anonymous
```

If `authenticated` isn't explicitly configured for an entity, it inherits from `anonymous`. If a named role isn't configured, it inherits from `authenticated`, or from `anonymous` if `authenticated` is also absent.

### Why?

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


### Show effective permissions with the CLI

As a result of role inheritance, a new `--show-effective-permissions` option on `dab configure` displays the resolved permissions for every entity after inheritance is applied. If you're unsure what a role can do after inheritance rules take effect, run this command to get the answer instead of reasoning through the config manually.

### Command line

```bash
dab configure --show-effective-permissions
dab configure --show-effective-permissions --config my-config.json
```

#### Resulting output

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

### Read the docs

- [Role inheritance](../concept/security/authorization.md#role-inheritance)
- [Entity permissions](../configuration/entities.md#role-inheritance)
- [`--show-effective-permissions`](../command-line/dab-configure.md#--show-effective-permissions)

## Introducing: On-Behalf-Of (OBO) user-delegation

DAB 2.0 adds On-Behalf-Of (OBO) authentication, sometimes referred to as pass-through authentication, for Microsoft SQL databases using Microsoft Entra ID. When enabled, DAB exchanges the incoming user token for a downstream SQL token so the database authenticates as the actual calling user.

### Why?

With OBO authentication, you can build APIs where the SQL database sees and enforces the real user identity, which can be helpful for some row-level security scenarios and compliance auditing. This is especially valuable in MCP scenarios where it can become unclear who is acting; OBO allows for transparent user identification.

### Prerequisites for OBO

1. An Entra ID app registration with the appropriate API permissions to request tokens for the database
2. An upstream identity provider that issues JWTs accepted by DAB (Entra ID or a custom provider you configure)
3. MSSQL database configured to accept Azure AD tokens

### Configuration requirements

 - requires `data-source.database-type: "mssql"`
 - requires `data-source.user-delegated-auth.database-audience`
 - requires `runtime.cache` to be disabled when OBO is configured.
 - requires env var `DAB_OBO_CLIENT_ID` with the client ID of the OBO app registration
 - requires env var `DAB_OBO_TENANT_ID` with the tenant ID of the OBO app registration
 - requires env var `DAB_OBO_CLIENT_SECRET` with the client secret of the OBO app registration

### Command line

```sh
set DAB_OBO_CLIENT_ID=1234-abcd-5678-efgh
set DAB_OBO_TENANT_ID=abcd-1234-efgh-567
set DAB_OBO_CLIENT_SECRET=supersecretvalue

dab configure --data-source.database-type mssql
dab configure --runtime.cache.enabled false

dab configure --data-source.user-delegated-auth.enabled true
dab configure --data-source.user-delegated-auth.provider EntraId
dab configure --data-source.user-delegated-auth.database-audience "https://database.windows.net"
```

#### Resulting configuration

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
	},
	"runtime": {
		"cache": {
			"enabled": false
		}
	}
}
```

> [!NOTE]
> When OBO is enabled, DAB maintains separate SQL connection pools per user so that one user's access token is never reused for another user's request. Now, when row-level security depends on who is connected, you can be confident that connection reuse across users doesn't silently grant the wrong access.

### Read the docs

- [Configure OBO authentication](../concept/security/how-to-authenticate-on-behalf-of.md)
- [User-delegated auth configuration](../configuration/data-source.md#user-delegated-auth)
- [Security best practices](../deployment/best-practices-security.md)

## Introducing: Auto configuration

Auto configuration is a powerful feature that allows you to define patterns that automatically find and expose database objects in your configuration. This can dramatically shrink a configuration file, especially when objects and permissions are predictable. In addition, `autoentities` reevaluate and apply the patterns each time DAB starts, so new tables that match the pattern are automatically added as entities without manual config changes.

> [!NOTE]
> In version 2.0, `dab auto-config` supports only tables in one or more Microsoft SQL databases. If you need another data source or database type, you can still [define your entities manually](../command-line/dab-add.md).

### Why?

With `auto-config`, you can wire up an entire database schema as a DAB API without writing a single entity block by hand. Define your patterns once and DAB does the rest.

It's worth noting that `autoentities` are not a shift in DAB to a schema-driven API. The problem with schema-driven APIs is that they leak the schema and place a burden on the database to conform to the API instead of a well-designed store. `Autoentities` solve this by letting you define patterns that match your database schema and automatically generate a subset of entities from those patterns. In addition, you can define multiple `autoentities` with unique patterns and permissions, participate in MCP, and more, all without manual config updates as your database evolves.

### Command line

```bash
dab auto-config my-def \
	--patterns.include "dbo.%" \
	--patterns.exclude "dbo.internal%" \
	--patterns.name "{schema}_{table}" \
	--permissions "anonymous:read"

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

### Testing your configuration

`dab auto-config-simulate` previews which database objects match your `autoentities` patterns before you commit any changes. It connects to the database, resolves each pattern, and prints the matched objects. Now, you can verify your include and exclude patterns produce exactly the entities you expect before touching the live config.

#### [Console](#tab/console)

```bash
dab auto-config-simulate
```
##### Resulting output

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

##### Resulting output

```csv
filter_name,entity_name,database_object
my-def,dbo_Products,dbo.Products
my-def,dbo_Inventory,dbo.Inventory
my-def,dbo_Pricing,dbo.Pricing
```

---

### Read the docs

- [`Autoentities` configuration](../configuration/autoentities.md)
- [`dab auto-config` command reference](../command-line/dab-auto-config.md)
- [`dab auto-config-simulate` command reference](../command-line/dab-auto-config-simulate.md)

## Default OpenTelemetry settings in `dab init`

New configurations generated by `dab init` now include a default OpenTelemetry section prewired to standard OpenTelemetry (OTEL) environment variables.

### Why?

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

### Read the docs

- [OpenTelemetry configuration](../configuration/runtime.md#opentelemetry-telemetry)
- [Use OpenTelemetry and activity traces](../concept/monitor/open-telemetry.md)

## Introducing: Custom MCP tools 

When `custom-tool: true` is set on a stored-procedure entity, DAB dynamically registers that procedure as a named MCP tool exposed through the standard `tools/list` and `tools/call` methods.

### Why?

Now, you can give AI agents purpose-built tools backed by your existing stored procedures—without writing any glue code. The tool appears in the MCP tool list and accepts the same parameters as the procedure.

### Command line

```bash
dab add GetBookById \
  --source dbo.get_book_by_id \
  --source.type "stored-procedure" \
  --permissions "anonymous:execute" \
  --mcp.custom-tool true
```

#### Resulting configuration

```json
{
	"entities": {
		"GetBookById": {
			"source": {
				"type": "stored-procedure",
				"object": "dbo.get_book_by_id"
			},
			"mcp": {
				"custom-tool": true
			},
			"permissions": [
				{
					"role": "anonymous",
					"actions": [ "execute" ]
				}
			]
		}
	}
}
```

### Read the docs

- [Custom tools for stored procedures](../mcp/data-manipulation-language-tools.md#custom-tools-for-stored-procedures)
- [MCP entity configuration](../configuration/entities.md#mcp)

## Introducing: permission-aware OpenAPI

The OpenAPI document now shows only the HTTP methods and fields that are accessible based on permissions. A new role-specific path `/openapi/{role}` lets you see exactly what a given role can do.

### Why?

With permission-aware OpenAPI, your document is a reliable contract. Clients and API consumers see only what they're allowed to call, not the full internal surface.

### Available paths

```text
/openapi
/openapi/anonymous
/openapi/authenticated
/openapi/{custom-role}
```

> [!IMPORTANT]
> `/openapi/{role}` is available in **Development** mode only to prevent role enumeration in production.

### Read the docs

- [Permission-aware OpenAPI](../concept/api/openapi.md#permission-aware-openapi)
- [Role-specific OpenAPI paths](../concept/api/openapi.md#role-specific-openapi-paths)

## Introducing: advanced REST paths

Entity REST paths can now include forward slashes, allowing subdirectory-style URL segments.

### Why?

Now, you can group related entities under a shared path prefix, making your REST API feel more naturally organized without any router configuration. This can be particularly helpful for multi-tenant scenarios where a tenant ID segment can segment endpoints with the same name, like `/api/shopping-cart/item` and `/api/invoice/items`, which would previously have required unique entity names.

### Command line

```bash
dab add ShoppingCartItem \
  --source dbo.ShoppingCartItem \
  --rest.path "shopping-cart/item"

dab add InvoiceItem \
  --source dbo.InvoiceItem \
  --rest.path "invoice/item"
```

#### Resulting configuration

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
https://{server-name}/api/shopping-cart/item
https://{server-name}/api/invoice/item
```

### Read the docs

- [Advanced REST paths with subdirectories](../concept/api/rest.md#advanced-rest-paths-with-subdirectories)

## Introducing: HTTP response compression

DAB 2.0 adds HTTP response compression for REST and GraphQL responses. Now, you can reduce payload sizes over the wire with a single config setting, which is especially useful for large result sets or low-bandwidth environments.

Supported levels: `optimal`, `fastest`, `none`.

### Command line

```bash
dab configure --runtime.compression.level "optimal"
```

#### Resulting configuration

```json
{
	"runtime": {
		"compression": {
			"level": "optimal"
		}
	}
}
```

### Read the docs

- [Compression configuration](../configuration/runtime.md#compression-runtime)
- [HTTP response compression](../concept/api/rest.md#http-response-compression)

## Keyless `PUT` and `PATCH` for autogenerated keys

DAB 2.0 allows `PUT` and `PATCH` requests without a key in the URL when the database autogenerates all omitted key columns. With keyless upserts, you can insert a new row with a server-generated key using the same upsert semantics you're used to—no need to pregenerate or supply the key yourself.

### Read the docs

- [Keyless PUT and PATCH](../concept/api/rest.md#keyless-put-and-patch-for-autogenerated-primary-keys)


## OpenTelemetry tracing for MCP execution

MCP tool execution is now included in OpenTelemetry traces alongside REST and GraphQL traffic. Now, you can monitor and correlate AI agent tool calls the same way you monitor API requests—using the same dashboards, the same trace IDs, and the same tooling. This works automatically when OpenTelemetry is configured. Because `dab init` now generates a default telemetry section, new apps have out-of-the-box observability for all three endpoint types.

### Read the docs

- [Use OpenTelemetry and activity traces](../concept/monitor/open-telemetry.md)
- [MCP overview](../mcp/overview.md)


