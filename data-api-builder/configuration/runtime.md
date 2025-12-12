---
title: Configuration schema - Runtime section
description: The Data API Builder configuration file's runtime section with details for each property.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 06/06/2025
show_latex: true
---

# Runtime

Configuration settings that determine runtime behavior.

### Pagination settings

|Property|Default|Description|
|-|-|-|
|[runtime.pagination.max-page-size](#pagination-runtime)|Defines maximum records per page|
|[runtime.pagination.default-page-size](#pagination-runtime)|Sets default records per response|

### REST settings

|Property|Default|Description|
|-|-|-|
|[runtime.rest.path](#rest-runtime)|`"/api"`|Base path for REST endpoints|
|[runtime.rest.enabled](#rest-runtime)|`true`|Allows enabling or disabling REST requests for all entities|
|[runtime.rest.request-body-strict](#rest-runtime)|`true`|Disallows extraneous fields in request body when true|

### GraphQL settings

|Property|Default|Description|
|-|-|-|
|[runtime.graphql.allow-introspection](#graphql-runtime)|`true`|Allows querying of underlying GraphQL schema|
|[runtime.graphql.path](#graphql-runtime)|`"/graphql"`|Base path for the GraphQL endpoint|
|[runtime.graphql.enabled](#graphql-runtime)|`true`|Allows enabling or disabling GraphQL requests for all entities|
|[runtime.graphql.depth-limit](#graphql-runtime)|`null`|Maximum allowed depth of a GraphQL query|
|[runtime.graphql.multiple-mutations.create.enabled](#graphql-runtime)|`false`|Allows multiple-create mutations for all entities|

### Host settings

|Property|Default|Description|
|-|-|-|
|[runtime.host.max-response-size-mb](#maximum-response-size-host-runtime)|`100`|Maximum size (MB) of database response allowed in a single result|
|[runtime.host.mode](#mode-host-runtime)|`"production"`|Running mode; `"production"` or `"development"`|

### CORS settings

|Property|Default|Description|
|-|-|-|
|[runtime.host.cors.origins](#cors-host-runtime)|`[]`|Allowed CORS origins|
|[runtime.host.cors.allow-credentials](#cors-host-runtime)|`false`|Sets value for Access-Control-Allow-Credentials header|

### Authentication settings

|Property|Default|Description|
|-|-|-|
|[runtime.host.authentication.provider](#provider-authentication-host-runtime)|`null`|Authentication provider|
|[runtime.host.authentication.jwt.audience](#jwt-authentication-host-runtime)|`null`|JWT audience|
|[runtime.host.authentication.jwt.issuer](#jwt-authentication-host-runtime)|`null`|JWT issuer|

### Cache settings

|Property|Default|Description|
|-|-|-|
|[runtime.cache.enabled](#cache-runtime)|`false`|Enables caching of responses globally|
|[runtime.cache.ttl-seconds](#cache-runtime)|`5`|Time to live (seconds) for global cache|

### Telemetry settings

|Property|Default|Description|
|-|-|-|
|[runtime.telemetry.application-insights.connection-string](#telemetry-runtime)|`null`|Application Insights connection string|
|[runtime.telemetry.application-insights.enabled](#telemetry-runtime)|`false`|Enables or disables Application Insights telemetry|
|[runtime.telemetry.open-telemetry.endpoint](#telemetry-runtime)|`null`|OpenTelemetry collector URL|
|[runtime.telemetry.open-telemetry.headers](#telemetry-runtime)|`{}`|OpenTelemetry export headers|
|[runtime.telemetry.open-telemetry.service-name](#telemetry-runtime)|`"dab"`|OpenTelemetry service name|
|[runtime.telemetry.open-telemetry.exporter-protocol](#telemetry-runtime)|`"grpc"`|OpenTelemetry protocol ("grpc" or "httpprotobuf")|
|[runtime.telemetry.open-telemetry.enabled](#telemetry-runtime)|`true`|Enables or disables OpenTelemetry|
|[runtime.telemetry.log-level.namespace](#telemetry-runtime)|`null`|Namespace-specific log level override|
|[runtime.health.enabled](#health-runtime)|`true`|Enables or disables the health check endpoint globally|
|[runtime.health.roles](#health-runtime)|`null`|Allowed roles for the comprehensive health endpoint|
|[runtime.health.cache-ttl-seconds](#health-runtime)|`30`|Time to live (seconds) for the health check report cache entry|

## Format overview

```json
{
  "runtime": {
    "pagination": {
      "max-page-size": <integer|null> (default: `100000`),
      "default-page-size": <integer|null> (default: `100`)
    },
    "rest": {
      "path": <string> (default: "/api"),
      "enabled": <true>|<false>,
      "request-body-strict": <true>|<false> (default: `true`)
    },
    "graphql": {
      "path": <string> (default: "/graphql"),
      "enabled": <true>|<false>,
      "allow-introspection": <true>|<false>,
      "depth-limit": <integer|null> (default: `null`),
      "multiple-mutations": {
        "create": {
          "enabled": <true>|<false> (default: `false`)
        }
      }
    },
    "host": {
      "mode": <"production"> (default) | <"development">,
      "max-response-size-mb": <integer|null> (default: `158`),
      "cors": {
        "origins": [ "<string>" ],
        "allow-credentials": <true>|<false> (default: `false`)
      },
      "authentication": {
        "provider": <string> (default: "AppService"),
        "jwt": {
          "audience": "<string>",
          "issuer": "<string>"
        }
      }
    }
  },
  "cache": {
    "enabled": <true>|<false> (default: `false`),
    "ttl-seconds": <integer> (default: `5`)
  },
  "telemetry": {
    "application-insights": {
      "connection-string": "<string>",
      "enabled": <true>|<false> (default: `true`)
    },
    "open-telemetry": {
      "endpoint": "<string>",
      "headers": "<string>",
      "service-name": <string> (default: "dab"),
      "exporter-protocol": <"grpc"> (default) | <"httpprotobuf">,
      "enabled": <true>|<false> (default: `true`)
    },
    "log-level": {
      // namespace keys
      "<namespace>": <"trace"|"debug"|"information"|"warning"|"error"|"critical"|"none"|null>
    }
  },
  "health": {
    "enabled": <true>|<false> (default: `true`),
    "roles": [ "<string>" ],
    "cache-ttl-seconds": <integer> (default: `5`)
  }
}
```

## Mode (Host runtime)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime` | `host` | enum (`production` \| `development`) | ❌ No | `production` |

#### Development behavior

- Enabled Nitro (formerly Banana Cake Pop) for GraphQL testing
- Enabled Swagger UI for REST testing
- Enabled anonymous health checks
- Increased logging verbosity (Debug)

### Format

```json
{
  "runtime": {
    "host": {
      "mode": "production" (default) | "development"
    }
  }
}
```

## Maximum response size (Host runtime)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.host` | `max-response-size-mb` | integer | ❌ No | 158 |

Sets the maximum size (in megabytes) for any given result. As large responses can strain the system, `max-response-size-mb` caps the total size (different from row count) to prevent overload, which is especially with large columns like text or JSON.

| Value | Result |
|-|-|
| not set | Use default |
| `null` | Use default |
| `integer` | Any positive 32-bit integer |
| `<= 0` | Not supported |

### Format

```json
{
  "runtime": {
    "host": {
      "max-response-size-mb": <integer; default: 158>
    }
  }
}
```

## GraphQL (runtime)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime` | `graphql` | object | ❌ No | - |

Global GraphQL configuration.

### Nested properties

| Parent | Property | Type | Required | Default |
| - | - | - | - | - |
| `runtime.graphql` | `enabled` | boolean | ❌ No | None |
| `runtime.graphql` | `path` | string | ❌ No | "/graphql" |
| `runtime.graphql` | `depth-limit` | integer | ❌ No | None (unlimited) |
| `runtime.graphql` | `allow-introspection` | boolean | ❌ No | True |
| `runtime.graphql` | `multiple-mutations.create.enabled` | boolean | ❌ No | False |

#### Property notes

* Subpaths aren't allowed for the `path` property. 
* Use `depth-limit` to constrain nested queries. 
* Set `allow-introspection` to `false` to hide the GraphQL schema.
* Use `multiple-mutations` to insert multiple entities in a single mutation. 

### Format

```json
{
  "runtime": {
    "graphql": {
      "enabled": <true> (default) | <false>
      "depth-limit": <integer|null> (default: `null`),
      "path": <string> (default: /graphql),
      "allow-introspection": <true> (default) | <false>,
      "multiple-mutations": {
        "create": {
          "enabled": <true> (default) | <false>
        }
    }
  }
}
```

### Example: multiple mutations

Configuration

```json
{
  "runtime": {
    "graphql": {
      "multiple-mutations": {
        "create": {
          "enabled": true
        }
      }
    }
  },
  "entities": {
    "User": {
      "source": "dbo.Users",
      "permissions": [
        {
          "role": "anonymous",
          "actions": ["create"] // entity permissions are required
        }
      ]
    }
  }
}
```

GraphQL mutation

```graphql
mutation {
  createUsers(input: [
    { name: "Alice", age: 30, isAdmin: true },
    { name: "Bob", age: 25, isAdmin: false },
    { name: "Charlie", age: 35, isAdmin: true }
  ]) {
    id
    name
    age
    isAdmin
  }
}
```

## REST (runtime)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime` | `rest` | object | ❌ No | - |

Global REST configuration.

### Nested properties

| Parent | Property | Type | Required | Default |
| - | - | - | - | - |
| `runtime.rest` | `enabled` | boolean | ❌ No | None |
| `runtime.rest` | `path` | string | ❌ No | "/api" |
| `runtime.rest` | `request-body-strict` | boolean | ❌ No | True |

### Property notes

 - If global `enabled` is `false`, individual entity-level `enabled` doesn't matter.
 - The `path` property doesn't support subpath values like `/api/data`. 
 - `request-body-strict` was introduced to help simplify .NET POCO objects. 

| `request-body-strict` | Behavior
| - | -
| **`true`** | Extra fields in the request body cause a `BadRequest` exception.  
| **`false`** | Extra fields in the request body are ignored.

### Format

```json
{
  "runtime": {
    "rest": {
      "enabled": <true> (default) | <false>,
      "path": <string> (default: /api),
      "request-body-strict": <true> (default) | <false>
    }
  }
}
```

### Example: request-body-strict

  - Columns with a `default()` value are ignored during `INSERT` only when their value in the payload is `null`. As a consequence, `INSERT` operations into `default()` columns, when `request-body-strict` is `true`, can't result in explicit `null` values. To accomplish this behavior, an `UPDATE` operation is required.
   - Columns with a `default()` aren't ignored during `UPDATE` regardless of payload value.
   - Computed columns are always ignored.
   - Autogenerated columns are always ignored.

Sample table

```sql
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY, -- auto-generated column
    Name NVARCHAR(50) NOT NULL,
    Age INT DEFAULT 18, -- column with default
    IsAdmin BIT DEFAULT 0, -- column with default
    IsMinor AS IIF(Age <= 18, 1, 0) -- computed column
);
```

Request payload

```json
{
  "Id": 999,
  "Name": "Alice",
  "Age": null,
  "IsAdmin": null,
  "IsMinor": false,
  "ExtraField": "ignored"
}
```

#### Insert behavior when `request-body-strict = false`

```sql
INSERT INTO Users (Name) VALUES ('Alice');
-- Default values for Age (18) and IsAdmin (0) are applied by the database.
-- IsMinor is ignored because it’s a computed column.
-- ExtraField is ignored.
-- The database generates the Id value.
```

Response payload

```json
{
  "Id": 1,          // Auto-generated by the database
  "Name": "Alice",
  "Age": 18,        // Default applied
  "IsAdmin": false, // Default applied
  "IsMinor": true   // Computed
}
```

#### Update behavior when `request-body-strict = false`

```sql
UPDATE Users
SET Name = 'Alice Updated', Age = NULL
WHERE Id = 1;
-- IsMinor and ExtraField are ignored.
```

Response payload

```json
{
  "Id": 1,
  "Name": "Alice Updated",
  "Age": null,
  "IsAdmin": false,
  "IsMinor": false // Recomputed by the database (false when age is `null`)
}
```

## CORS (host runtime)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.host` | `cors` | object | ❌ No | - |

Global CORS configuration.

> [!TIP]
> CORS stands for "Cross-Origin Resource Sharing." It's a browser security feature that controls whether web pages can make requests to a different domain than the one that served them.

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.host.cors` | `allow-credentials` | boolean | ❌ No | False |
| `runtime.host.cors` | `origins` | string array | ❌ No | None |

> [!NOTE]
> The `allow-credentials` property sets the [`Access-Control-Allow-Credentials`](https://developer.mozilla.org/docs/Web/HTTP/Headers/Access-Control-Allow-Credentials) CORS header.

### Format

```json
{
  "runtime": {
    "host": {
      "cors": {
        "allow-credentials": <true> (default) | <false>,
        "origins": ["<array-of-strings>"]
      }
    }
  }
}
```

> [!NOTE]
> The wildcard `*` is valid as a value for `origins`.

## Provider (Authentication host runtime)

| Parent                        | Property   | Type                                                         | Required | Default      |
| ----------------------------- | ---------- | ------------------------------------------------------------ | -------- | ------------ |
| `runtime.host.authentication` | `provider` | enum (`AppService` \| `EntraId` \|  `Custom` \| `Simulator`) | ❌ No     | `AppService` |

Defines the method of authentication used by the Data API builder.

### Anonymous-only (auth provider)

```json
{
 "host": {
    // omit the authentication section
 }
}
```

When the entire `authentication` section is omitted from the dab-config.json file, no authentication provider is used. In this case, Data API builder operates in a "no-auth" mode. In this mode, DAB doesn't look for any tokens or `Authorization` headers. The `X-MS-API-ROLE` header is also ignored in this configuration.

> [!NOTE]
> Every request that comes into the engine is automatically and immediately assigned the system role of `anonymous`. Access control is then exclusively handled by the permissions you define on each entity.

An example of entity permissions.

```json
{
  "entities": {
    "Book": {
      "source": "dbo.books",
      "permissions": [
        {
          "role": "anonymous",
          "actions": [ "read" ]
        }
      ]
    }
  }
}
```

In this example, since no `authentication` provider is configured, all incoming requests are automatically considered to be from an `anonymous` user. The `permissions` array for the `Book` entity explicitly grants the `anonymous` role the ability to perform `read` operations. Any attempt to perform other actions (like `create`, `update`, `delete`) or access other entities not configured for `anonymous` access is denied.

### AppService (auth provider)

```json
{
 "host": {
  "authentication": {
   "provider": "AppService"
  }
 }
}
```

This provider is for applications hosted on Azure App Service, such as Azure Container Apps. The Azure hosting environment handles authentication and then passes the user's identity information to the application via request headers. It is intended for developers who want a simple, out-of-the-box authentication solution managed by the Azure platform.

This provider doesn't use a JWT token from the `Authorization` header. It relies on a special header, `X-MS-CLIENT-PRINCIPAL`, injected by the App Service platform. This header contains a base64-encoded JSON object with the user's identity details.

**Anonymous**: If the `AppService` provider is configured but a request arrives without the `X-MS-CLIENT-PRINCIPAL` header, the request is assigned to the system role of `anonymous`.

The decoded JSON from the `X-MS-CLIENT-PRINCIPAL` header typically looks like this:

```json
{
  "auth_typ": "aad",
  "claims": [
    {"typ": "roles", "val": "admin"},
    {"typ": "roles", "val": "contributor"}
  ],
  "name_typ": "...",
  "role_typ": "..."
}
```

The roles are contained within the `claims` array.

#### About the X-MS-API-ROLE header

* **Role and Behavior**: The `X-MS-API-ROLE` header is used to specify which role the user wants to assume for the current request. The value of this header must match one of the role values found in the `claims` array of the `X-MS-CLIENT-PRINCIPAL` object.
* **Is it required?**: No. If the `X-MS-API-ROLE` header is absent, the request is processed in the context of the `authenticated` system role. This behavior means the user is recognized as logged in, but not as any specific application-defined role from the token.
* **Behavior on Match**: If the `X-MS-API-ROLE` header is provided and its value matches a role in the client principal's `claims`, the user assumes that role for the request.
* **Behavior on Mismatch**: If the `X-MS-API-ROLE` header is provided but the value doesn't match any role in the client principal, the request is rejected with a `403 Forbidden` status code. This validation ensures a user can't claim a role they weren't assigned.

### EntraId (auth provider)

```json
{
 "host": {
  "authentication": {
   "provider": "EntraId", // previously AzureAd
   "jwt": {
    "audience": "00001111-aaaa-2222-bbbb-3333cccc4444",
    "issuer": "https://login.microsoftonline.com/98765f43-21ba-400c-a5de-1f2a3d4e5f6a/v2.0"
   }
  }
 }
}
```

This provider secures endpoints with user and application identities in Microsoft Entra. It's ideal for any service where users or other services need secure access within the Entra tenant.

> [!NOTE]
> The `EntraId` provider was previously named `AzureAd`. The old name still works, but developers are encouraged to migrate their configurations from `AzureAd` to `EntraId`.

This provider expects a standard JWT Bearer token in the `Authorization` header, issued by Microsoft Entra. The token must be configured for the specific application (using the `audience` claim). The roles for the user or service principal are expected to be in a claim within the token. The code looks for a `roles` claim by default.

**Anonymous**: If the `EntraId` provider is configured but a request arrives without the `Authorization` header, the request is assigned to the system role of `anonymous`.

A decoded JWT payload might look like this:

```json
{
  "aud": "...", // Audience - your API
  "iss": "https://login.microsoftonline.com/{tenant-id}/v2.0", // Issuer
  "oid": "...", // User or principal object ID
  "roles": [
    "reader",
    "writer"
  ],
  // ... other claims
}
```

#### About the X-MS-API-ROLE header

* **Role and Behavior**: The `X-MS-API-ROLE` header is used to specify a role the user wishes to assume for the request. The value of this header must match one of the role values found in the `roles` claim of the JWT token.
* **Is it required?**: No. If the `X-MS-API-ROLE` header is absent, the request is processed in the context of the `authenticated` system role. This behavior means the user is recognized as logged in, but not as any specific application-defined role from the token.
* **Behavior on Match**: If the `X-MS-API-ROLE` header is provided and it matches a role in the `roles` claim, the user's context is set to that role.
* **Behavior on Mismatch**: If the `X-MS-API-ROLE` header is provided but its value doesn't match any role in the `roles` claim, the request is rejected with a `403 Forbidden` status code. This validation ensures a user can't claim a role they weren't assigned.

### Custom (auth provider)

```json
{
 "host": {
  "authentication": {
   "provider": "Custom",
   "jwt": {
    "audience": "<client-id-or-api-audience>",
    "issuer": "https://<your-domain>/oauth2/default"
   }
  }
 }
}
```

This provider is for developers who want to integrate Data API builder with a third-party identity provider (like Auth0, Okta, or a custom identity server) that issues JWTs. It provides the flexibility to configure the expected `audience` and `issuer` of the tokens.

The `Custom` provider expects a standard JWT Bearer token in the `Authorization` header. The key difference from the `EntraId` provider is that you configure the valid `issuer` and `audience` in the Data API builder's configuration file. The provider validates the token by checking that the trusted authority issued it. The user's roles are expected to be in a `roles` claim within the JWT payload.

> [!NOTE]
> In some cases, depending on the third-party identity provider, developers need to coerce the structure of their JWT to match the structure expected by Data API builder (shown in the following example).

**Anonymous**: If the `Custom` provider is configured but a request arrives without the `Authorization` header, the request is assigned to the system role of `anonymous`.

A decoded JWT payload for a `custom` provider might look like this:

```json
{
  "aud": "my-api-audience", // Must match configuration
  "iss": "https://my-custom-issuer.com/", // Must match configuration
  "sub": "user-id",
  "roles": [
    "editor",
    "viewer"
  ],
  // ... other claims
}
```

#### About the X-MS-API-ROLE header

* **Role and Behavior**: The `X-MS-API-ROLE` header functions exactly like it does with the `EntraId` provider. It allows the user to select one of their assigned roles. The value of this header must match one of the roles from the `roles` claim in the custom JWT token.
* **Is it required?**: No. If the `X-MS-API-ROLE` header is absent, the user is treated as being in the `authenticated` system role.
* **Behavior on Match**: If the `X-MS-API-ROLE` header's value matches a role in the JWT's `roles` claim, the user's context is set to that role for authorization purposes.
* **Behavior on Mismatch**: If the `X-MS-API-ROLE` header's value doesn't match any role in the `roles` claim, the request is rejected with a `403 Forbidden` status code. This validation ensures a user can't claim a role they weren't assigned.

### Simulator (auth provider)

This provider is designed to make it easy for developers to test their configuration, especially `authorization` policies, without needing to set up a full authentication provider like Entra Identity or EasyAuth. It simulates an `authenticated` user.

The `Simulator` provider doesn't use JWT tokens. Authentication is simulated. When you use this provider, Data API builder treats all requests as if they're coming from an authenticated user.

#### About the X-MS-API-ROLE header

* **Role and Behavior**: The `X-MS-API-ROLE` header is the only way to specify a role when using the `Simulator`. Since there's no token with a list of roles, the system implicitly trusts the role sent in this header.
* **Is it required?**: No.
* **Behavior on Absence**: If the `X-MS-API-ROLE` header is absent, the request is processed in the context of the `authenticated` system role.
* **Behavior on Presence**: If the `X-MS-API-ROLE` header is present, the request is processed in the context of the role specified in the header's value. There's no validation against a claims list, so the developer can simulate any role they need to test their policies.

#### Simulator in Production

If the `authentication.provider` is set to `Simulator` while the `runtime.host.mode` is `production`, Data API builder fails to start. 

```json
"host": {
  "mode": "production", // or "development"
  "authentication": {
    "provider": "Simulator" 
  }
}
```

## JWT (Authentication host runtime)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.host.authentication` | `jwt` | object | ❌ No | - |

Global JSON Web Token (JWT) configuration.

![Diagram of JSON web tokens support in Data API builder.](media/runtime/jwt-server.png)

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.host.authentication.jwt` | `audience` | string | ❌ No | None |
| `runtime.host.authentication.jwt` | `issuer` | string | ❌ No | None |

### Format

```json
{
  "runtime": {
    "host": {
      "authentication": {
        "jwt": {
          "audience": "<client-id>",
          "issuer": "<issuer-url>"
        }
      }
    }
  }
}
```

## Pagination (Runtime)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime` | `pagination` | object | ❌ No | - |

Global pagination limits for REST and GraphQL endpoints.

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.pagination` | `max-page-size` | int | ❌ No | 100,000 |
| `runtime.pagination` | `default-page-size` | int | ❌ No | 100 |

### Max-page-size supported values

| Value | Result |
|-|-|
| `integer` | Any positive 32-bit integer is supported. |
| `0` | Not supported. |
| `-1` | Defaults to the maximum supported value. |
| `< -1` | Not supported. |

### Default-page-size supported values

| Value | Result |
|-|-|
| `integer` | Any positive integer less than the current `max-page-size`. |
| `0` | Not supported. |
| `-1` | Defaults to the current `max-page-size` setting. |
| `< -1` | Not supported. |

### Format

```json
{
  "runtime": {
    "pagination": {
      "max-page-size": <integer; default: 100000>,
      "default-page-size": <integer; default: 100>
    }
  }
}
```

> [!NOTE]
> When the value is greater than `max-page-size`, the results are capped at `max-page-size`.

### Example: Paging in REST

Request
```http
GET https://localhost:5001/api/users
```

Response payload
```json
{
  "value": [
    {
      "Id": 1,
      "Name": "Alice",
      "Age": 30,
      "IsAdmin": true,
      "IsMinor": false
    },
    {
      "Id": 2,
      "Name": "Bob",
      "Age": 17,
      "IsAdmin": false,
      "IsMinor": true
    }
  ],
  "nextLink": "https://localhost:5001/api/users?$after=W3siRW50aXR5TmFtZSI6InVzZXJzIiwiRmllbGROYW1lI=="
}
```

Request Next Page

```http
GET https://localhost:5001/api/users?$after=W3siRW50aXR5TmFtZSI6InVzZXJzIiwiRmllbGROYW1lI==
```

### Example: Paging in GraphQL

Request payload (Query)

```graphql
query {
  users {
    items {
      Id
      Name
      Age
      IsAdmin
      IsMinor
    }
    hasNextPage
    endCursor
  }
}
```

Response payload
```json
{
  "data": {
    "users": {
      "items": [
        {
          "Id": 1,
          "Name": "Alice",
          "Age": 30,
          "IsAdmin": true,
          "IsMinor": false
        },
        {
          "Id": 2,
          "Name": "Bob",
          "Age": 17,
          "IsAdmin": false,
          "IsMinor": true
        }
      ],
      "hasNextPage": true,
      "endCursor": "W3siRW50aXR5TmFtZSI6InVzZXJzIiwiRmllbGROYW1lI=="
    }
  }
}
```

Request Next Page

```graphql
query {
  users(after: "W3siRW50aXR5TmFtZSI6InVzZXJzIiwiRmllbGROYW1lI==") {
    items {
      Id
      Name
      Age
      IsAdmin
      IsMinor
    }
    hasNextPage
    endCursor
  }
}
```

### Example: Accessing `max-page-size` in Requests

Use the `max-page-size` value by setting `$limit` (REST) or `first` (GraphQL) to `-1`.

REST 

```http
GET https://localhost:5001/api/users?$limit=-1
```

GraphQL 

```graphql
query {
  users(first: -1) {
    items {
      ...
    }
  }
}
```

## Cache (runtime)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime` | `cache` | object | ❌ No | - |

Global Cache configuration.

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.cache` | `enabled` | boolean | ❌ No | False |
| `runtime.cache` | `ttl-seconds` | integer | ❌ No | 5 |

> [!TIP]
> The entity-level `cache.ttl-seconds` property defaults to this global value. 

### Format

```json
{
  "runtime": {
    "cache":  {
      "enabled": <boolean>,
      "ttl-seconds": <integer>
    }
  }
}
```

> [!IMPORTANT]
> If global `enabled` is `false`, individual entity-level `enabled` doesn't matter.

## Telemetry (runtime)

| Parent | Property | Type | Required | Default |
| - | - | - | - | - |
| `runtime` | `telemetry` | object | ❌ No | - |

Global telemetry configuration.

### Nested properties

| Parent | Property | Type | Required | Default |
| - | - | - | - | - |
| `runtime.telemetry` | `log-level` | dictionary | ❌ No | None |
| `runtime.telemetry` | [`application-insights`](#application-insights-telemetry) | object | ❌ No | - |
| `runtime.telemetry` | [`open-telemetry`](#opentelemetry-telemetry) | object | ❌ No | - |

Configures logging verbosity per namespace. This follows standard .NET logging conventions and allows granular control, though it assumes some familiarity with Data API builder internals. Data API builder is open source: [https://aka.ms/dab](https://aka.ms/dab)

### Format

```json
{
  "runtime": {
    "telemetry": {
      "log-level": {
        "namespace": "log-level",
        "namespace": "log-level"
      }
    }
  }
}
```

> [!TIP]
> `log-level` can be hot-reloaded in both development and production. It's currently the only property that supports hot reload in production.

### Example

```json
{
  "runtime": {
    "telemetry": {
      "log-level": {
        "Azure.DataApiBuilder.Core.Configurations.RuntimeConfigValidator": "debug",
        "Azure.DataApiBuilder.Core": "information",
        "default": "warning"
      }
    }
  }
}
```

## Application Insights (telemetry)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.telemetry` | `application-insights` | object | ❌ No | - |

Configures logging to [Application Insights](../deployment/how-to-use-application-insights.md). 

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.telemetry.application-insights` | `enabled` | boolean | ❌ No | False |
| `runtime.telemetry.application-insights` | `connection-string` | string | ✔️ Yes | None |

### Format

```json
{
  "runtime": {
    "telemetry": {
      "application-insights": {
        "enabled": <true; default: true> | <false>
        "connection-string": <string>
      }
    }
  }
}
```

## OpenTelemetry (telemetry)

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.telemetry` | `open-telemetry` | object | ❌ No | - |

Configures logging to Open Telemetry. 

### Nested properties

| Parent | Property | Type | Required | Default |
|-|-|-|-|-|
| `runtime.telemetry.open-telemetry` | `enabled` | boolean | ❌ No | true |
| `runtime.telemetry.open-telemetry` | `endpoint` | string | ✔️ Yes | None |
| `runtime.telemetry.open-telemetry` | `headers` | string | ❌ No | None |
| `runtime.telemetry.open-telemetry` | `service-name` | string | ❌ No | "dab" |
| `runtime.telemetry.open-telemetry` | `exporter-protocol` | enum (`grpc` \| `httpprotobuf`) | ❌ No | `grpc` |

Multiple headers are `,` (comma) separated. 

### Format

```json
{
  "runtime": {
    "telemetry": {
      "open-telemetry": {
        "enabled": <true> (default) | <false>,
        "endpoint": <string>,
        "headers": <string>,
        "service-name": <string> (default: "dab"),
        "exporter-protocol": <"grpc" (default) | "httpprotobuf">
      }
    }
  }
}
```

### Example

```json
{
  "runtime": {
    "telemetry": {
      "open-telemetry": {
        "enabled": true,
        // a gRPC endpoint example
        "endpoint": "http://localhost:4317",
        // an HTTP/protobuf endpoint example
        "endpoint": "http://localhost:4318/v1/metrics",
        "headers": "api-key=key,other-config-value=value",
        "service-name": "dab",
      }
    }
  }
}
```

Learn more about [OTEL_EXPORTER_OTLP_HEADERS](https://opentelemetry.io/docs/languages/sdk-configuration/otlp-exporter/#otel_exporter_otlp_headers:~:text=or%20HTTP%20requests.-,OTEL_EXPORTER_OTLP_HEADERS,Example:%20export%20OTEL_EXPORTER_OTLP_HEADERS%3D%22api-key%3Dkey%2Cother-config-value%3Dvalue%22,-OTEL_EXPORTER_OTLP_TRACES_HEADERS).

> [!NOTE]
> gRPC (`4317`) is faster and supports streaming but requires more setup steps. HTTP/protobuf (`4318`) is simpler and easier to debug but less efficient. 

## Health (runtime)

| Parent | Property | Type | Required | Default |
| - | - | - | - | - |
| `runtime` | `health` | object | ❌ No | - |

Global [health check endpoint](../concept/monitor/health-checks.md) (`/health`) configuration.

### Nested properties

| Parent | Property | Type | Required | Default |
| - | - | - | - | - |
| `runtime.health` | `enabled` | boolean | ❌ No | true |
| `runtime.health` | `roles` | string array | ✔️ Yes | None |
| `runtime.health` | `cache-ttl-seconds` | integer | ❌ No | 5 |

### Behavior in development vs. production

| Condition | Development Behavior | Production Behavior |
| - | - | - |
| `health.enabled` = false | `403` status | `403` status |
| `health.enabled` = true | Depends on role | Depends on role |
| `roles` omitted or `null` | Health displayed | `403` status |
| current role not in `roles` | `403` status | `403` status |
| current role in `roles` | Health displayed | Health displayed |
| `roles` includes `anonymous`  | Health displayed | Health displayed |

### Format

```json
{
  "health": {
    "enabled": <true> (default) | <false>,
    "roles": [ <string> ], // required in production
    "cache-ttl-seconds": <integer>
  }
}
```

> [!NOTE]
> If global `enabled` is `false`, individual entity-level `enabled` doesn't matter.

### Example

```json
{
  "health": {
    "enabled": true,
    "roles": ["admin", "support"],
    "cache-ttl-seconds": 10
  }
}
```
