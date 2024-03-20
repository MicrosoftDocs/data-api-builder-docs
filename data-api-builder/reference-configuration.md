---
title: Configuration schema
description: Includes the full schema for the Data API Builder's configuration file with details for each property.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/20/2024
---

# Data API builder configuration schema reference

The Data API builder's engine requires a configuration file. The configuration file defines multiple characteristics of the database service and entities that are used by the engine to generate the API using the well known JSON format.

The configuration file can include options such as:

- Database service and connection information
- Global and runtime configuration options
- Set of exposed entities
- Authentication method
- Security rules required to access identities
- Name mapping rules between API and database
- Relationships between entities that can't be inferred
- Unique features for specific database services

## Sample configuration

Here's a sample configuration file that only includes required properties for a single simple entity. This sample is intended to illustrate a minimal scenario.

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json",
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('sql-connection-string')"
  },
  "entities": {
    "Book": {
      "source": "dbo.books",
      "permissions": [{
          "actions": ["*"],
          "role": "anonymous"
      }]
    }
  }
}
```

For an example of a more complex scenario, see the [end-to-end sample configuration](sample-configuration.md).

## Configuration format

As a reference, here's the full JSON format for valid configuration files.

```json
{
  "$schema": "<string>",
  "data-source": {
    "database-type": "<enum-string>",
    "connection-string": "<string>"
  }
}
```

## Environments

Data API builder's configuration file can support scenarios where you need to support multiple environments, similar to the `appSettings.json` file in ASP.NET Core. The framework provides three [common environment values](/dotnet/api/microsoft.extensions.hosting.environments#fields); `Development`, `Staging`, and `Production`; but you can elect to use any environment value you choose. The environment that Data API builder uses must be configured using the `DAB_ENVIRONMENT` environment variable.

Consider an example where you want a baseline configuration and a development-specific configuration. This example requires two configuration files:

| | Environment |
| --- | --- |
| **dab-config.json** | Base |
| **dab-config.Development.json** | Development |

To use the development-specific configuration, you must set the `DAB_ENVIRONMENT` environment variable to `Development`.

Environment-specific configuration files override property values in the base configuration file. In this example, if the `connection-string` value is set in both files, the value from the **\*.Development.json** file is used.

Refer to this matrix to better understand which value is used depending on where that value is specified (or not specified) in either file.

| | **Specified in base configuration** | **Not specified in base configuration** |
| --- | --- | --- |
| **Specified in current environment configuration** | Current environment | Current environment |
| **Not specified in current environment configuration** | Base | None |

For an example of using multiple configuration files, see [use Data API builder with local data](how-to-develop-local-data.md).

## Configuration properties

This section includes all possible configuration properties that are available for a configuration file.

### Schema

**REQUIRED**: ✔️ Yes

Defines the explicit [JSON schema](https://code.visualstudio.com/Docs/languages/json#_json-schemas-and-settings) used to validate the configuration file.

#### Format

```json
{
  "$schema": "<string>"
}
```

#### Examples

Here are a few examples of valid schema values.

| Version | URI | Description |
| --- | --- | --- |
| 0.3.7-alpha | `https://github.com/Azure/data-api-builder/releases/download/v0.3.7-alpha/dab.draft.schema.json` | Uses the configuration schema from an alpha version of the tool. |
| 0.10.23 | `https://github.com/Azure/data-api-builder/releases/download/v0.10.23/dab.draft.schema.json` | Uses the configuration schema for a stable release of the tool. |
| Latest | `https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json` | Uses the latest version of the configuration schema. |

> [!NOTE]
> Versions of the Data API builder prior to **0.3.7-alpha** may have a different schema URI.

### Data source

**REQUIRED**: ✔️ Yes

The `data-source` property configures the credentials necessary to connect to the backing database.

#### Format

```json
{
  "data-source": {
    "database-type": "<string>",
    "connection-string": "<string>",
    "options": "<object>"
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`database-type`](#database-type)** | ✔️ Yes | enum string |
| **[`connection-string`](#connection-string)** | ✔️ Yes | string |
| **[`options`](#options)** | ❌ No | object |

### Database type

**REQUIRED**: ✔️ Yes

An enum string used to specify the type of database to use as the data source.

#### Format

```json
{
  "data-source"{
    "database-type": "<enum-string>"
  }
}
```

#### Values

Here's a list of allowed values for this property:

| | Description |
| --- | --- |
| **`mssql`** | Used with Azure SQL Database, Azure SQL Managed Instance, or SQL Server |
| **`postgresql`** | Used with Azure Database for PostgreSQL or PostgreSQL |
| **`mysql`** | Used with Azure Database for MySQL or MySQL |
| **`cosmosdb_nosql`** | Use with Azure Cosmos DB for NoSQL |
| **`cosmosdb_postgresql`** | Use with Azure Cosmos DB for PostgreSQL |

### Connection string

**REQUIRED**: ✔️ Yes

A **string** value containing a valid connection string to connect to the target database service.

#### Format

```json
{
  "data-source"{
    "connection-string": "<string>"
  }
}
```

#### Examples

The value used for the connection string largely depends on the database service used in your scenario. You can always elect to store the connection string in an environment variable and access it using the `@env()` function.

| | Value | Description |
| --- | --- | --- |
| **Use Azure SQL Database string value** | `Server=<server-address>;Database=<name-of-database>;User ID=<username>;Password=<password>;` | Connection string to an Azure SQL Database account. For more information, see [Azure SQL Database connection strings](/azure/azure-sql/database/connect-query-content-reference-guide?#get-adonet-connection-information-optional---sql-database-only). |
| **Use Azure Database for PostgreSQL string value** | `Server=<server-address>;Database=<name-of-database>;Port=5432;User Id=<username>;Password=<password>;Ssl Mode=Require;` | Connection string to an Azure Database for PostgreSQL account. For more information, see [Azure Database for PostgreSQL connection strings](/azure/postgresql/single-server/how-to-connection-string-powershell). |
| **Use Azure Cosmos DB for NoSQL string value** | `AccountEndpoint=<endpoint>;AccountKey=<key>;` | Connection string to an Azure Cosmos DB for NoSQL account. For more information, see [Azure Cosmos DB for NoSQL connection strings](/azure/cosmos-db/nosql/how-to-dotnet-get-started#retrieve-your-account-connection-string). |
| **Use Azure Database for MySQL string value** | `Server=<server-address>;Database=<name-of-database>;User ID=<username>;Password=<password>;Sslmode=Required;SslCa=<path-to-certificate>;` | Connection string to an Azure Database for MySQL account. For more information, see [Azure Database for MySQL connection strings](/azure/mysql/single-server/how-to-connection-string). |
| **Access environment variable** | `@env('database-connection-string')` | Access an environment variable from the local machine. In this example, the `database-connection-string` environment variable is referenced. |

> [!TIP]
> As a best practice, avoid storing sensitive information in your configuration file. When possible, use `@env()` to reference environment variables. For more information, see [`@env()` function](reference-functions.md#env).

### Options

**REQUIRED**: ❌ No

An optional section of extra key-value parameters for specific database connections.

#### Format

```json
{
  "data-source"{
    "options": {
        "<key>": "<value>"
    }
  }
}
```

#### Examples

Whether the `options` section is required or not is largely dependent on the database service being used.

| | Value | Description |
| --- | --- | --- |
| **Enable `SESSION_CONTEXT` in Azure SQL or SQL Server** | `"set-session-context": false` | Enables or disables the `SESSION_CONTEXT` feature in Azure SQL and SQL Server to send user-specified metadata to the underlying database. For more information, see [`SESSION_CONTEXT` and row level security](azure-sql-session-context-rls.md). |

### Data source files

**REQUIRED**: ❌ No

This property includes names of runtime configuration files referencing extra databases.

#### Format

```json
{
  "data-source-files": ["<string-array>"]
}
```

### Runtime

**REQUIRED**: ❌ No

This section contains options that affect the runtime behavior of the engine and all exposed entities.

#### Format

```json
{
  "runtime": {
    "rest": "<object>",
    "graphql": "<object>",
    "host": "<object>",
    "cache": "<object>"
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`rest`](#rest-runtime)** | ❌ No | object |
| **[`graphql`](#graphql-runtime)** | ❌ No | object |
| **[`host`](#host-runtime)** | ❌ No | object |
| **[`cache`](#cache-runtime)** | ❌ No | object |

#### Examples

Here's an example of a runtime section with multiple common default parameters specified.

```json
{
  "runtime": {
    "rest": {
      "enabled": true,
      "path": "/api",
      "request-body-strict": true
    },
    "graphql": {
      "enabled": true,
      "path": "/graphql",
      "allow-introspection": true
    },
    "host": {
      "mode": "development",
      "cors": {
        "allow-credentials": false,
        "origins": [
          "*"
        ]
      },
      "authentication": {
        "provider": "StaticWebApps",
        "jwt": {
          "audience": "<client-id>",
          "issuer": "<identity-provider-issuer-uri>"
        }
      }
    },
    "cache": {
      "enabled": true,
      "ttl-seconds": 30
    }
  }
}
```

### GraphQL (runtime)

**REQUIRED**: ❌ No

This object defines whether GraphQL is enabled and the name\[s\] used to expose the entity as a GraphQL type. This object is optional and only used if the default name or settings aren't sufficient.

#### Format

```json
{
  "runtime": {
    "graphql": {
      "enabled": "<boolean>",
      "path": "<string>",
      "allow-introspection": "<boolean>"
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`enabled`](#enabled-graphql-runtime)** | ❌ No | boolean |
| **[`path`](#path-graphql-runtime)** | ❌ No | string |
| **[`allow-introspection`](#allow-introspection-graphql-runtime)** | ❌ No | boolean |

### Enabled (GraphQL runtime)

**REQUIRED**: ❌ No

Defines whether to enable or disable the GraphQL endpoints globally. If disabled globally, no entities would be accessible via GraphQL requests irrespective of the individual entity settings.

#### Format

```json
{
  "runtime": {
    "graphql": {
      "enabled": "<boolean>"
    }
  }
}
```

#### Examples

In this example, the GraphQL endpoint is disabled for all entities.

```json
{
  "runtime": {
    "graphql": {
      "enabled": false
    }
  }
}
```

### Path (GraphQL runtime)

**REQUIRED**: ❌ No

Defines the URL path where the GraphQL endpoint is made available. For example, if this parameter is set to `/graphql`, the GraphQL endpoint is exposed as `/graphql`. By default, the path is `/graphql`.

> [!IMPORTANT]
> Sub-paths are not allowed for this property. A customized path value for the GraphQL endpoint is not currently available.

#### Format

```json
{
  "runtime": {
    "graphql": {
      "path": "<string>"
    }
  }
}
```

#### Examples

In this example, the root GraphQL URI is `/query`.

```json
{
  "runtime": {
    "graphql": {
      "path": "/query"
    }
  }
}
```

### Allow introspection (GraphQL runtime)

**REQUIRED**: ❌ No

Allows querying of the underlying GraphQL schema

#### Format

```json
{
  "runtime": {
    "graphql": {
      "allow-introspection": "<boolean>"
    }
  }
}
```

#### Examples

In this example, the introspection is disabled.

```json
{
  "runtime": {
    "graphql": {
      "allow-introspection": false
    }
  }
}
```

### REST (runtime)

**REQUIRED**: ❌ No

This object defines whether the REST API is enabled and the name\[s\] used to expose the entity using the API. This object is optional and only used if the default name or settings aren't sufficient.

#### Format

```json
{
  "runtime": {
    "rest": {
      "enabled": "<boolean>",
      "path": "<string>",
      "request-body-strict": "<boolean>"
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`enabled`](#enabled-rest-runtime)** | ❌ No | boolean |
| **[`path`](#path-rest-runtime)** | ❌ No | string |
| **[`request-body-strict`](#request-body-strict-rest-runtime)** | ❌ No | boolean |

### Enabled (REST runtime)

**REQUIRED**: ❌ No

Defines whether to enable or disable REST endpoints globally. If disabled globally, no entities would be accessible via REST requests irrespective of the individual entity settings.

#### Format

```json
{
  "runtime": {
    "rest": {
      "enabled": "<boolean>"
    }
  }
}
```

#### Examples

In this example, the REST API endpoint is disabled for all entities.

```json
{
  "runtime": {
    "rest": {
      "enabled": false
    }
  }
}
```

### Path (REST runtime)

**REQUIRED**: ❌ No

Defines the URL path where all exposed REST endpoints are available. For example, if this parameter is set to `/api`, the REST endpoint is exposed `/api/<entity>`. By default, the path is `/api`.

> [!IMPORTANT]
> Sub-paths are not allowed for this property.

#### Format

```json
{
  "runtime": {
    "rest": {
      "path": "<string>"
    }
  }
}
```

#### Examples

In this example, the root REST API URI is `/data`.

```json
{
  "runtime": {
    "rest": {
      "path": "/data"
    }
  }
}
```

> [!TIP]
> If you define an `Author` entity, the endpoint for this entity would be `/data/Author`.

### Request body strict (REST runtime)

**REQUIRED**: ❌ No

Determines whether the request body for a REST mutation operation can contain extraneous fields. By default, this parameter is set to `true`. This default setting causes a **bad request** exception if there are extra fields in the request body. Setting this flag to false allows users to include extra fields in the request body, which the Data API builder engine ignores.

> [!NOTE]
> This flag does not affect HTTP GET requests to the REST API endpoint. The request body is always ignored for GET operations.

#### Format

```json
{
  "runtime": {
    "rest": {
      "request-body-strict": "<boolean>"
    }
  }
}
```

#### Examples

In this example, strict request body validation is disabled.

```json
{
  "runtime": {
    "rest": {
      "request-body-strict": false
    }
  }
}
```

### Host (runtime)

**REQUIRED**: ❌ No

Defines various settings for hosting the Data API builder engine.

#### Format

```json
{
  "runtime": {
    "host": {
      "mode": "<enum-string>",
      "cors": "<object>",
      "authentication": "<object>"
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`mode`](#mode-host-runtime)** | ❌ No | enum string |
| **[`cors`](#cors-host-runtime)** | ❌ No | object |
| **[`authentication`](#authentication-host-runtime)** | ❌ No | object |

#### Examples

Here's an example of a runtime configured for development hosting.

```json
{
  "runtime": {
    "host": {
      "mode": "development",
      "cors": {
        "allow-credentials": false,
        "origins": ["*"]
      },
      "authentication": {
        "provider": "Simulator"
      }
    }
  }
}
```

### Mode (Host runtime)

**REQUIRED**: ❌ No

Defines if the Data API builder engine should run in `development` or `production` mode. The default value is `production`.

Typically, the underlying database errors are exposed in detail by setting the default level of detail for logs to `Debug` when running in development. In production, the level of detail for logs is set to `Error`.

> [!TIP]
> The default log level can be further overriden using `dab start --LogLevel <level-of-detail>`. For more information, see [command-line interface (CLI) reference](reference-cli.md#start).

#### Format

```json
{
  "runtime": {
    "host": {
      "mode": "<enum-string>"
    }
  }
}
```

#### Values

Here's a list of allowed values for this property:

| | Description |
| --- | --- |
| **`production`** | Use when hosting in production on Azure |
| **`development`** | Use in development on local machine |

### CORS (Host runtime)

**REQUIRED**: ❌ No

Cross-origin resource sharing (CORS) settings for the Data API builder engine host.

#### Format

```json
{
  "runtime": {
    "host": {
      "cors": "<object>"
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`allow-credentials`](#allow-credentials-host-runtime)** | ❌ No | boolean |
| **[`origins`](#origins-host-runtime)** | ❌ No | string array |

### Allow credentials (Host runtime)

**REQUIRED**: ❌ No

If true, sets the `Access-Control-Allow-Credentials` CORS header. By default, the value is `false`.

> [!NOTE]
> For more infromation on the `Access-Control-Allow-Credentials` CORS header, see [MDN Web Docs CORS reference](https://developer.mozilla.org/docs/Web/HTTP/Headers/Access-Control-Allow-Credentials).

#### Format

```json
{
  "runtime": {
    "host": {
      "cors": {
        "allow-credentials": "<boolean>",
      }
    }
  }
}
```

### Origins (Host runtime)

**REQUIRED**: ❌ No

Sets an array with a list of allowed origins for CORS. This setting allows the `*` wildcard for all origins.

#### Format

```json
{
  "runtime": {
    "host": {
      "cors": {
        "origins": ["<string-array>"]
      }
    }
  }
}
```

#### Examples

Here's an example of a host that allows CORS without credentials from all origins.

```json
{
  "runtime": {
    "host": {
      "cors": {
        "allow-credentials": false,
        "origins": ["*"]
      }
    }
  }
}
```

### Authentication (Host runtime)

**REQUIRED**: ❌ No

Configures authentication for the Data API builder host.

#### Format

```json
{
  "runtime": {
    "host": {
      "authentication": {
        "provider": "<enum-string>",
        "jwt": "<object>"
      }
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`provider`](#provider-host-runtime)** | ❌ No | enum string |
| **[`jwt`](#json-web-tokens-host-runtime)** | ❌ No | object |

### Provider (Host runtime)

**REQUIRED**: ❌ No

Specifies which authentication provider is used.

#### Format

```json
{
  "runtime": {
    "host": {
      "authentication": {
        "provider": "<enum-string>",
      }
    }
  }
}
```

#### Values

Here's a list of allowed values for this property:

| | Description |
| --- | --- |
| **`StaticWebApps`** | Azure Static Web Apps |
| **`AppService`** | Azure App Service |
| **`AzureAD`** | Microsoft Entra ID |
| **`Simulator`** | Simulator |

### JSON Web Tokens (Host runtime)

**REQUIRED**: ❌ No

If the authentication provider is set to `AzureAD` (Microsoft Entra ID), then this section is required to specify the audience and issuers for the JSOn Web Tokens (JWT) token. This data is used to validate the tokens against your Microsoft Entra tenant.

#### Format

```json
{
  "runtime": {
    "host": {
      "authentication": {
        "jwt": {
          "audience": "<string>",
          "issuer": "<string>"
        }
      }
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`audience`](#audience-host-runtime)** | ❌ No | string |
| **[`issuer`](#issuer-host-runtime)** | ❌ No | string |

### Audience (Host runtime)

**REQUIRED**: ❌ No

Audience for the JWT token.

#### Format

```json
{
  "runtime": {
    "host": {
      "authentication": {
        "jwt": {
          "audience": "<string>",
        }
      }
    }
  }
}
```

### Issuer (Host runtime)

**REQUIRED**: ❌ No

Issuer for the JWT token.

#### Format

```json
{
  "runtime": {
    "host": {
      "authentication": {
        "jwt": {
          "issuer": "<string>"
        }
      }
    }
  }
}
```

### Cache (runtime)

**REQUIRED**: ❌ No

Enables and configures caching for the entire runtime.

#### Format

```json
{
  "runtime": {
    "cache": "<object>"
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`enabled`](#enabled-cache-runtime)** | ❌ No | boolean |
| **[`ttl-seconds`](#ttl-in-seconds-cache-runtime)** | ❌ No | integer |

#### Examples

In this example, cache is enabled and the items expire after 30 seconds.

```json
{
  "runtime": {
    "cache": {
      "enabled": true,
      "ttl-seconds": 30
    }
  }
}
```

### Enabled (Cache runtime)

**REQUIRED**: ❌ No

Enables caching globally for all entities. Defaults to `false`.

#### Format

```json
{
  "runtime": {
    "cache":  {
      "enabled": "<boolean>"
    }
  }
}
```

#### Examples

In this example, cache is disabled.

```json
{
  "runtime": {
    "cache": {
      "enabled": false
    }
  }
}
```

### TTL in seconds (Cache runtime)

**REQUIRED**: ❌ No

Configures the time-to-live (TTL) value in seconds for cached items. After this time elapses, items are automatically pruned from the cache. The default value is `5` seconds.

#### Format

```json
{
  "runtime": {
    "cache":  {
        "ttl-seconds": "<integer>"
    }
  }
}
```

#### Examples

In this example, cache is enabled globally and all items expire after 15 seconds.

```json
{
  "runtime": {
    "cache": {
      "enabled": true,
      "ttl-seconds": 15
    }
  }
}
```

### Entities

**REQUIRED**: ✔️ Yes

This section maps database objects to exposed endpoints. This section also includes properties mapping and permission definition. Each exposed entity is defined in a dedicated object. The property name of the object is used as the name of the entity to expose.

#### Format

```json
{
  "entities": {
    "<example-entity-0>": "<object>",
    "<example-entity-1>": "<object>",
    ...
    "<example-entity-n>": "<object>"
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`source`](#source)** | ✔️ Yes | object |
| **[`permissions`](#permissions)** | ✔️ Yes | array |
| **[`rest`](#rest-entities)** | ❌ No | object |
| **[`graphql`](#graphql-entities)** | ❌ No | object |
| **[`mappings`](#mappings-entities)** | ❌ No | object |
| **[`relationships`](#relationships-entities)** | ❌ No | object |
| **[`cache`](#cache-entities)** | ❌ No | object |

#### Examples

For example, this JSON object instructs Data API builder to expose a GraphQL entity named `Author` and a REST endpoint reachable via the `/Author` path. The `dbo.authors` database table backs the entity and the configuration allows anyone to access the endpoint anonymously.

```json
{
  "entities": {
    "Author": {
      "source": {
        "object": "dbo.authors",
        "type": "table"
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
      ]
    }
  }
}
```

### Source

**REQUIRED**: ✔️ Yes

This property indicates exactly which underlying database object to use for the corresponding entity.

#### Format

```json
{
  "entities": {
    "<string>": {
      "source": {
        "object": "<string>",
        "type": "<enum-string>",
        "parameters": "<object>",
        "key-fields": ["<string-array>"]
      }
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`object`](#object)** | ✔️ Yes | string |
| **[`type`](#type-entities)** | ✔️ Yes | enum string |
| **[`parameters`](#parameters)** | ❌ No | object |
| **[`key-fields`](#key-fields)** | ❌ No | string array |

#### Examples

This example shows the most straightforward structure to associate an entity with a source table.

```json
{
  "entities": {
    "Author": {
      "source": {
        "object": "dbo.authors",
        "type": "table"
      }
    }
  }
}
```

### Object

**REQUIRED**: ✔️ Yes

Name of the database object to be used.

#### Examples

In this example, `object` refers to the `dbo.books` object in the database.

```json
{
  "entities": {
    "Book": {
      "source": {
        "object": "dbo.books",
        "type": "table"
      }
    }
  }
}
```

### Type (entities)

**REQUIRED**: ✔️ Yes

Indicates if the object is a table, a view, or a stored procedure.

#### Values

Here's a list of allowed values for this property:

| | Description |
| --- | --- |
| **`table`** | Represents a table. |
| **`stored-procedure`** | Represents a stored procedure. |
| **`view`** | Represents a view. |

#### Examples

In this example, `type` indicates that this source is a view in the database. This value influences whether other values (ex: `key-fields`) are required.

```json
{
  "entities": {
    "Category": {
      "source": {
        "object": "dbo.vw_category_details",
        "type": "view",
        "key-fields": [
          "category_id"
        ]
      }
    }
  }
}
```

### Key fields

**REQUIRED**: ❌ No

List of columns used to uniquely identify an item.

> [!IMPORTANT]
> This property is required if the type of object is a `view`. Also, this property is required is the type of object is a `table` with no primary key defined.

#### Examples

This example uses the `dbo.vw_category_details` view with `category_id` indicated as the key field.

```json
{
  "entities": {
    "Category": {
      "source": {
        "object": "dbo.vw_category_details",
        "type": "view",
        "key-fields": [
          "category_id"
        ]
      }
    }
  }
}
```

### Parameters

**REQUIRED**: ❌ No

A set of key-value pairs used to supply values to the invoked stored procedure. Alternatively, these values can be specified in the HTTP request.

> [!IMPORTANT]
> This property is required if the type of object is a `stored-procedure`.

#### Examples

This example invokes the `dbo.stp_get_bestselling_books` stored procedure passing in these two parameters:

| | Value |
| --- | --- |
| **`depth`** | 25 |
| **`list`** | contoso-best-sellers |

```json
{
  "entities": {
    "BestsellingBooks": {
      "source": {
        "object": "dbo.stp_get_bestselling_books",
        "type": "stored-procedure",
        "parameters": {
          "depth": 25,
          "list": "contoso-best-sellers"
        }
      }
    }
  }
}
```

### Permissions

**REQUIRED**: ✔️ Yes

This section defines who can access the related entity and what actions are allowed. Permissions are defined in this section in the terms of roles. Actions are defined as typical CRUD operations including: `create`, `read`, `update`, and `delete`.

#### Format

```json
{
  "entities": {
    "<string>": {
      "permissions": [
        {
          "role": "<string>",
          "actions": ["<object-or-string-array>"]
        }
      ]
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`role`](#role)** | ✔️ Yes | string |
| **[`actions` (string-array)](#actions-string-array) or [`actions` (object-array)](#actions-object-array)** | ✔️ Yes | object or string array |

#### Examples

In this example, an anonymous role is defined with access to all possible actions.

```json
{
  "entities": {
    "Writer": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": ["*"]
        }
      ]
    }
  }
}
```

Alternatively, an object can be used to define the wildcard action.

```json
{
  "entities": {
    "Editor": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "*"
            }
          ]        
        }
      ]
    }
  }
}
```

You can also mix and match string and object array actions.

```json
{
  "entities": {
    "Reviewer": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read"
            },
            "create"
          ]        
        }
      ]
    }
  }
}
```

### Role

**REQUIRED**: ✔️ Yes

String containing the name of the role to which the defined permission applies.

#### Examples

This example defines a role named `reader` with only `read` permissions on the endpoint.

```json
{
  "entities": {
    "Book": {
      "permissions": [
        {
          "role": "reader",
          "actions": [
            "read"
          ]        
        }
      ]
    }
  }
}
```

### Actions (string-array)

**REQUIRED**: ✔️ Yes

An array of string values detailing what operations are allowed for the associated role. For `table` and `view` database objects, roles can be configured to use any combination of `create`, `read`, `update`, or `delete` actions. For stored procedures, roles can only have the `execute` action.

> [!NOTE]
> For stored procedures, the wildcard (`*`) action expands to a list that only includes the `execute` action. For tables and views, the wildcard action expands to a list that includes `create`, `read`, `update`, and `delete` actions.

#### Examples

This example gives `create` and `read` permissions to the first role named `contributor`. The second role named `auditor` only has `delete` permissions.

```json
{
  "entities": {
    "CheckoutLogs": {
      "permissions": [
        {
          "role": "auditor",
          "actions": [
            "delete"
          ]        
        },
        {
          "role": "contributor",
          "actions": [
            "read",
            "create"
          ]
        }
      ]
    }
  }
}
```

### Actions (object-array)

**REQUIRED**: ✔️ Yes

An array of string values detailing what operations are allowed for the associated role. For `table` and `view` database objects, roles can be configured to use any combination of `create`, `read`, `update`, or `delete` actions. For stored procedures, roles can only have the `execute` action.

> [!NOTE]
> For stored procedures, the wildcard (`*`) action expands to a list that only includes the `execute` action. For tables and views, the wildcard action expands to a list that includes `create`, `read`, `update`, and `delete` actions.

#### Format

```json
{
  "entities": {
    "<string>": {
      "permissions": [
        {
          "role": "<string>",
          "actions": [
            {
              "action": "<string>",
              "fields": ["<string-array>"],
              "policy": "object"
            }
          ]
        }
      ]
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`action`](#action)** | ✔️ Yes | string |
| **[`fields`](#fields)** | ❌ No | string array |
| **[`policy`](#policy)** | ❌ No | object |

#### Examples

This example grants only `read` permission to the `auditor` role. The `auditor` role can only read specific data using the predicate defined in `policy.database`. The `auditor` role is also limited in what fields it can, or can't read using the `fields` property.

```json
{
  "entities": {
    "CheckoutLogs": {
      "permissions": [
        {
          "role": "auditor",
          "actions": [
            {
              "action": "read",
              "fields": {
                "include": ["*"],
                "exclude": ["last_updated"]
              },
              "policy": {
                "database": "@item.LogDepth lt 3"
              }
            }
          ]
        }
      ]
    }
  }
}
```

### Action

**REQUIRED**: ✔️ Yes

Specifies the specific operation allowed on the database object.

#### Values

Here's a list of allowed values for this property:

| | Tables | Views | Stored Procedures | Description |
| --- | --- | --- | --- | --- |
| **`create`** | ✔️ Yes | ✔️ Yes | ❌ No | Create new items |
| **`read`** | ✔️ Yes | ✔️ Yes | ❌ No | Point read existing items |
| **`update`** | ✔️ Yes | ✔️ Yes | ❌ No | Update or replace existing items |
| **`delete`** | ✔️ Yes | ✔️ Yes | ❌ No | Remove existing items |
| **`execute`** | ❌ No | ❌ No | ✔️ Yes | Execute programmatic operations |

#### Examples

Here's an example where `anonymous` users are allowed to `execute` a specific stored procedure and `read` a specific table.

```json
{
  "entities": {
    "Author": {
      "source": {
        "object": "dbo.authors",
        "type": "table"
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read"
            }
          ]
        }
      ]
    },
    "BestSellingAuthor": {
      "source": {
        "object": "dbo.stp_get_bestselling_authors",
        "type": "stored-procedure",
        "parameters": {
          "depth": 10
        }
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "execute"
            }
          ]
        }
      ]
    }
  }
}
```

### Fields

**REQUIRED**: ❌ No

Granular specifications on which specific fields are permitted access for the database object.

#### Examples

In this example, the `anonymous` role is allowed to read from all fields except `id`, but can use all fields when creating an item.

```json
{
  "entities": {
    "Author": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "fields": {
                "include": ["*"],
                "exclude": ["id"]
              }
            },
            { "action": "create" }
          ]
        }
      ]
    }
  }
}
```

### Policy

**REQUIRED**: ❌ No

This section defines item-level security rules, also known as database policies. These policies limit the results returned from a request.

#### Format

```json
{
  "entities": {
    "<string>": {
      "permissions": [
        {
          "role": "<string>",
          "actions": [
            {
              "action": "<string>",
              "fields": ["<string-array>"],
              "policy": {
                "database": "<string>"
              }
            }
          ]
        }
      ]
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`database`](#database)** | ✔️ Yes | string |

### Database

**REQUIRED**: ✔️ Yes

This property denotes the database policy expression that is evaluated during request execution. The policy string is an OData expression that is translated into a query predicated evaluated by the database. For example, the policy expression `@item.OwnerId eq 2000` is translated to the query predicate `WHERE <schema>.<object-name>.OwnerId = 2000`.

> [!NOTE]
> A *predicate* is an expression that evalutes to `TRUE`, `FALSE`, or `UNKNOWN`. Predicates are used in:
>
> - The search condition of `WHERE` clauses
> - The search condition of `FROM` clauses
> - The join conditions of `FROM` clauses
> - Other constructs where a boolean value is required.
>
> For more information, see [predicates](/sql/t-sql/queries/predicates).

In order for results to be returned for a request, the request's query predicate resolved from a database policy must evaluate to `true` when executing against the database.

Two types of directives can be used when authoring a database policy expression:

| | Description |
| --- | --- |
| **`@claims`** | Accesses a claim within the validated access token provided in the request |
| **`@item`** | Represents a field of the entity for which the database policy is defined |

> [!NOTE]
> A limited number of claim types are available for use in database policies when Azure Static Web Apps authentication (EasyAuth) is configured. These claim types include: `identityProvider`, `userId`, `userDetails`, and `userRoles`. For more information, see [Azure Static Web Apps client principal data](/azure/static-web-apps/user-information#client-principal-data).

#### Examples

For example, a basic policy expression can evaluate whether a specific field is true within the table. This example evaluates if the `soft_delete` field is `false`.

```json
{
  "entities": {
    "Manuscripts": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "policy": {
                "database": "@item.soft_delete eq false"
              }
            }
          ]
        }
      ]
    }
  }
}
```

Predicates can also evaluate both `claims` and `item` directive types. This example pulls the `UserId` field from the access token and compares it to the `owner_id` field in the target database table.

```json
{
  "entities": {
    "Manuscript": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "policy": {
                "database": "@claims.UserId eq @item.owner_id"
              }
            }
          ]
        }
      ]
    }
  }
}
```

#### Limitations

- Database policies are supported for tables and views. Stored procedures can't be configured with policies.
- Database policies can't be used to prevent a request from executing within a database. This limitation is because database policies are resolved as query predicates in the generated database queries. The database engine ultimately evaluates these queries.
- Database policies are only supported for the [`actions`](#action) `create`, `read`, `update`, and `delete`.
- Database policy OData expression syntax only supports these scenarios.
  - Binary operators including, but not limited to; `and`, `or`, `eq`, `gt`, and `lt`. For more information, see [`BinaryOperatorKind`](/dotnet/api/microsoft.odata.uriparser.binaryoperatorkind).
  - Unary operators such as the `-` (negate) and `not` operators. For more information, see [`UnaryOperatorKind`](/dotnet/api/microsoft.odata.uriparser.unaryoperatorkind).
- Database policies also have restrictions related to field names.
  - Entity field names that start with a letter or underscore, followed by at most 127 letters, underscores, or digits.
  - This requirement is per OData specification. For more information, see [OData Common Schema Definition Language](https://docs.oasis-open.org/odata/odata-csdl-json/v4.01/odata-csdl-json-v4.01.html#sec_SimpleIdentifier).

> [!TIP]
> Fields which do not conform to the mentioned restrictions can't be referenced in database policies. As a workaround, configure the entity with a mappings section to assign conforming aliases to the fields.

### GraphQL (entities)

**REQUIRED**: ❌ No

This object defines whether GraphQL is enabled and the name\[s\] used to expose the entity as a GraphQL type. This object is optional and only used if the default name or settings aren't sufficient.

#### Format

```json
{
  "entities": {
    "<string>": {
      "graphql": "<boolean>"
    }
  }
}
```

```json
{
  "entities": {
    "<string>": {
      "graphql": {
        "enabled": "<boolean>",
        "type": "<string-or-object>",
        "operation": "<enum-string>"
      }
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`enabled`](#enabled-graphql-entity)** | ❌ No | boolean |
| **[`type`](#type-graphql-entity)** | ❌ No | string or object |
| **[`operation`](#operation-graphql-entity)** | ❌ No | enum string |

#### Examples

These two examples are functionally equivalent.

```json
{
  "entities": {
    "Author": {
      "graphql": true
    }
  }
}
```

```json
{
  "entities": {
    "Author": {
      "graphql": {
        "enabled": true
      }
    }
  }
}
```

### Type (GraphQL entity)

**REQUIRED**: ❌ No

This property defines the name for the GraphQL type. If this field isn't specified, the name of the entity becomes the singular type and the engine automatically generates a pluralized name for the plural type.

#### Format

```json
{
  "entities": {
    "<string>": {
      "graphql": {
        "type": "<string>"
      }
    }
  }
}
```

```json
{
  "entities": {
    "<string>": {
      "graphql": {
        "type": {
          "singular": "<string>",
          "plural": "<string>"
        }
      }
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **`singular`** | ❌ No | string |
| **`plural`** | ❌ No | string |

#### Examples

A custom entity name can be specified using the `type` parameter with a string value. In this example, the engine differentiates automatically between the singular and plural variants of this name using common English rules for pluralization.

```json
{
  "entities": {
    "Author": {
      "graphql": {
        "type": "bookauthor"
      }
    }
  }
}
```

If you elect to specify the names explicitly, use the `type.singular` and `type.plural` properties. This example explicitly sets both names.

```json
{
  "entities": {
    "Author": {
      "graphql": {
        "type": {
          "singular": "bookauthor",
          "plural": "bookauthors"
        }
      }
    }
  }
}
```

Both examples are functionally equivalent. They both return the same JSON output for a GraphQL query that uses the `bookauthors` entity name.

```graphql
{
  bookauthors {
    items {
      first_name
      last_name
    }
  }
}
```

```json
{
  "data": {
    "bookauthors": {
      "items": [
        {
          "first_name": "Henry",
          "last_name": "Ross"
        },
        {
          "first_name": "Jacob",
          "last_name": "Hancock"
        },
        ...
      ]
    }
  }
}
```

### Operation (GraphQL entity)

**REQUIRED**: ❌ No

The operation property is used specifically for stored procedure. This property specifies whether the operation the underlying database object is a query or mutation. If operation isn't specified for a stored procedure, the default value is `mutation`.

#### Format

```json
{
  "entities": {
    "<string>": {
      "graphql": {
        "operation": "<string-enum>"
      }
    }
  }
}
```

#### Values

Here's a list of allowed values for this property:

| | Description |
| --- | --- |
| **`query`** | The underlying stored procedure is exposed as a query |
| **`mutation`** | The underlying stored procedure is exposed as a mutation |

### Enabled (GraphQL entity)

**REQUIRED**: ❌ No

Enables or disables the GraphQL endpoint.

#### Format

```json
{
  "entities": {
    "<string>": {
      "graphql": {
        "enabled": "<boolean>"
      }
    }
  }
}
```

### REST (entities)

**REQUIRED**: ❌ No

This object defines whether REST is enabled and the name\[s\] used to expose the entity as a REST endpoint. This object is optional and only necessary if the default name or settings aren't sufficient.

#### Format

```json
{
  "entities": {
    "<string>": {
      "rest": "<boolean>"
    }
  }
}
```

```json
{
  "entities": {
    "<string>": {
      "rest": {
        "enabled": "<boolean>",
        "path": "<string>",
        "methods": ["<string-array>"]
      }
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`enabled`](#enabled-rest-entity)** | ✔️ Yes | boolean |
| **[`path`](#path-rest-entity)** | ❌ No | string |
| **[`methods`](#methods-rest-entity)** | ❌ No | string array |

#### Examples

These two examples are functionally equivalent.

```json
{
  "entities": {
    "Author": {
      "source": {
        "object": "dbo.authors",
        "type": "table"
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": ["*"]
        }
      ],
      "rest": true
    }
  }
}
```

```json
{
  "entities": {
    "Author": {
      "source": {
        "object": "dbo.authors",
        "type": "table"
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": ["*"]
        }
      ],
      "rest": {
        "enabled": true
      }
    }
  }
}
```

### Enabled (REST entity)

**REQUIRED**: ❌ No

Enables or disables the REST API endpoint.

#### Format

```json
{
  "entities": {
    "<string>": {
      "rest": {
        "enabled": "<boolean>"
      }
    }
  }
}
```

### Path (REST entity)

**REQUIRED**: ❌ No

This property defines the endpoint that is exposed for the REST API. By default, the path is `/<entity-name>`.

#### Format

```json
{
  "entities": {
    "<string>": {
      "rest": {
        "path": "<string>"
      }
    }
  }
}
```

#### Examples

This example exposes the `Author` entity using the `/auth` endpoint.

```json
{
  "entities": {
    "Author": {
      "rest": {
        "path": "/auth"
      }
    }
  }
}
```

### Methods (REST entity)

**REQUIRED**: ❌ No

This property is only used for stored procedures. This property defines which HTTP actions the stored procedure currently supports.

#### Format

```json
{
  "entities": {
    "<string>": {
      "rest": {
        "methods": ["<string-array>"]
      }
    }
  }
}
```

#### Values

Here's a list of allowed values for this property:

| | Description |
| --- | --- |
| **`get`** | Exposes HTTP GET requests |
| **`put`** | Exposes HTTP PUT requests |
| **`post`** | Exposes HTTP POST requests |
| **`delete`** | Exposes HTTP DELETE requests |
| **`patch`** | Exposes HTTP PATCH requests |

#### Examples

This example instructs the engine that the `stp_get_bestselling_authors` stored procedure only supports `HTTP GET` actions.

```json
{
  "entities": {
    "BestSellingAuthor": {
      "source": {
        "object": "dbo.stp_get_bestselling_authors",
        "type": "stored-procedure",
        "parameters": {
          "depth": 10
        }
      },
      "rest": {
        "path": "/best-selling-authors",
        "methods": [ "get" ]
      }
    }
  }
}
```

### Mappings (entities)

**REQUIRED**: ❌ No

An optional section of extra key-value parameters to explicitly configure mappings between database object fields and exposed names (or aliases). The exposed names apply to both GraphQL and REST endpoints.

> [!IMPORTANT]
> For entities with GraphQL enabled, the configured exposed name must meet GraphQL naming requirements. For more information, see [GraphQL names specification](https://spec.graphql.org/October2021/#sec-Names).

#### Format

```json
{
  "entities": {
    "<string>": {
      "mappings": {
        "<data-object-field>": "<exposed-name>"
      }
    }
  }
}
```

#### Examples

In this example, the `sku_title` field from the database object `dbo.magazines` is exposed using the name `title`. Similarly, the `sku_status` field is exposed as `status` in both REST and GraphQL endpoints.

```json
{
  "entities": {
    "Magazine": {
      "source": {
        "object": "dbo.magazines",
        "type": "table"
      },
      "mappings": {
        "sku_title": "title",
        "sku_status": "status"
      }
    }
  }
}
```

### Relationships (entities)

**REQUIRED**: ❌ No

This section maps includes a set of relationship definitions that map how entities are related to other exposed entities. These relationship definitions can also optionally include details on the underlying database objects used to support and enforce the relationships. Objects defined in this section are exposed as GraphQL fields in the related entity.

#### Format

```json
{
  "relationships": {
    "<example-relationship-0>": "<object>",
    "<example-relationship-1>": "<object>",
    ...
    "<example-relationship-n>": "<object>"
  }
}
```

| | Required | Type |
| --- | --- | --- |
| **[`cardinality`](#cardinality)** | ✔️ Yes | enum string |
| **[`target.entity`](#target-entity)** | ✔️ Yes | string |
| **[`source.fields`](#source-fields)** | ❌ No | string array |
| **[`target.fields`](#target-fields)** | ❌ No | string array |
| **[`linking.<object-or-entity>`](#linking-object-or-entity)** | ❌ No | string |
| **[`linking.source.fields`](#linking-source-fields)** | ❌ No | string array |
| **[`linking.target.fields`](#linking-target-fields)** | ❌ No | string array |

#### Examples

When considering relationships, it's best to compare the differences between **one-to-many**, **many-to-one**, and **many-to-many** relationships.

##### One-to-many

First, let's consider an example of a relationship with the exposed `Category` entity has a **one-to-many** relationship with the `Book` entity. Here, the cardinality is set to `many`. Each `Category` can have multiple related `Book` entities while each `Book` entity is only associated with a single `Category` entity.

```json
{
  "entities": {
    "Book": {
      ...
    },
    "Category": {
      "relationships": {
        "category_books": {
          "cardinality": "many",
          "target.entity": "Book",
          "source.fields": [ "id" ],
          "target.fields": [ "category_id" ]
        }
      }
    }
  }
}
```

In this example, the [`source.fields`](#source-fields) list specifies the `id` field of the source entity (`Category`). This field is used to connect to the related item in the `target` entity. Conversely, the [`target.fields`](#target-fields) list specifies the `category_id` field of the target entity (`Book`). This field is used to connect to the related item in the `source` entity.

With this relationship defined, the resulting exposed GraphQL schema should resemble this example.

```graphql
type Category
{
  id: Int!
  ...
  books: [BookConnection]!
}
```

##### Many-to-one

Next, consider **many-to-one** which sets the cardinality to `one`. The exposed `Book` entity can have a single related `Category` entity. The `Category` entity can have multiple related `Book` entities.

```json
{
  "entities": {
    "Book": {
      "relationships": {
        "books_category": {
          "cardinality": "one",
          "target.entity": "Category",
          "source.fields": [ "category_id" ],
          "target.fields": [ "id" ]
        }
      },
      "Category": {
        ...
      }
    }
  }
}
```

Here, the [`source.fields`](#source-fields) list specifies that the `category_id` field of the source entity (`Book`) references the `id` field of the related target entity (`Category`). Inversely, the [`target.fields`](#target-fields) list specifies the inverse relationship. With this relationship, the resulting GraphQL schema now includes a mapping back from Books to Categories.

```graphql
type Book
{
  id: Int!
  ...
  category: Category
}
```

##### Many-to-many

Finally, a **many-to-many** relationship is defined with a cardinality of `many` and more metadata to define which database objects are used to create the relationship in the backing database. Here, the `Book` entity can have multiple `Author` entities and conversely the `Author` entity can have multiple `Book` entities.

```json
{
  "entities": {
    "Book": {
      "relationships": {
        ...,
        "books_authors": {
          "cardinality": "many",
          "target.entity": "Author",
          "source.fields": [ "id" ],
          "target.fields": [ "id" ],
          "linking.object": "dbo.books_authors",
          "linking.source.fields": [ "book_id" ],
          "linking.target.fields": [ "author_id" ]
        }
      },
      "Category": {
        ...
      },
      "Author": {
        ...
      }
    }
  }
}
```

In this example, the [`source.fields`](#source-fields) and [`target.fields`](#target-fields) both indicate that the relationship table uses the primary identifier (`id`) of both the source (`Book`) and target (`Author`) entities. The [`linking.object`](#linking-object-or-entity) field specifies that the relationship is defined in the `dbo.books_authors` database object. Further, [`linking.source.fields`](#linking-source-fields) specifies that the `book_id` field of the linking object references the `id` field of the `Book` entity and [`linking.target.fields`](#linking-target-fields) specifies that the `author_id` field of the linking object references the `id` field of the `Author` entity.

This example can be described using a GraphQL schema similar to this example.

```graphql
type Book
{
  id: Int!
  ...
  authors: [AuthorConnection]!
}

type Author
{
  id: Int!
  ...
  books: [BookConnection]!
}
```

### Cardinality

**REQUIRED**: ✔️ Yes

Specifies if the current source entity is related to only a single instance of the target entity or multiple.

#### Values

Here's a list of allowed values for this property:

| | Description |
| --- | --- |
| **`one`** | The source only relates to one record from the target |
| **`many`** | The source can relate to zero-to-many records from the target |

### Target entity

**REQUIRED**: ✔️ Yes

The name of the entity defined elsewhere in the configuration that is the target of the relationship.

### Source fields

**REQUIRED**: ❌ No

An optional parameter to define the field used for mapping in the *source* entity used to connect to the related item in the target entity.

> [!TIP]
> This field is not required if there's a **foreign key** restraint on the database between the two database objects that can be used to infer the relationship automatically.

### Target fields

**REQUIRED**: ❌ No

An optional parameter to define the field used for mapping in the *target* entity used to connect to the related item in the source entity.

> [!TIP]
> This field is not required if there's a **foreign key** restraint on the database between the two database objects that can be used to infer the relationship automatically.

### Linking object or entity

**REQUIRED**: ❌ No

For many-to-many relationships, the name of the database object or entity that contains the data necessary to define a relationship between two other entities.

### Linking source fields

**REQUIRED**: ❌ No

The name of the database object or entity field that is related to the source entity.

### Linking target fields

**REQUIRED**: ❌ No

The name of the database object or entity field that is related to the target entity.

### Cache (entities)

**REQUIRED**: ❌ No

Enables and configures caching for the entity.

#### Format

```json
{
  "entities": {
    "<string>": {
      "cache": "<object>"
    }
  }
}
```

#### Properties

| | Required | Type |
| --- | --- | --- |
| **[`enabled`](#enabled-cache-entity)** | ❌ No | boolean |
| **[`ttl-seconds`](#ttl-in-seconds-cache-entity)** | ❌ No | integer |

#### Examples

In this example, cache is enabled and the items expire after 30 seconds.

```json
{
  "entities": {
    "Author": {
      "cache": {
        "enabled": true,
        "ttl-seconds": 30
      }
    }
  }
}
```

### Enabled (Cache entity)

**REQUIRED**: ❌ No

Enables caching for the entity. Defaults to `false`.

#### Format

```json
{
  "entities": {
    "<string>": {
      "cache": {
        "enabled": "<boolean>"
      }
    }
  }
}
```

#### Examples

In this example, cache is disabled.

```json
{
  "entities": {
    "Author": {
      "cache": {
        "enabled": false
      }
    }
  }
}
```

### TTL in seconds (Cache entity)

**REQUIRED**: ❌ No

Configures the time-to-live (TTL) value in seconds for cached items. After this time elapses, items are automatically pruned from the cache. The default value is `5` seconds.

#### Format

```json
{
  "entities": {
    "<string>": {
      "cache": {
        "ttl-seconds": "<integer>"
      }
    }
  }
}
```

#### Examples

In this example, cache is enabled and the items expire after 15 seconds.

```json
{
  "entities": {
    "Author": {
      "cache": {
        "enabled": true,
        "ttl-seconds": 15
      }
    }
  }
}
```

## Related content

- [Functions reference](reference-functions.md)
- [Command-line interface (CLI) reference](reference-cli.md)
