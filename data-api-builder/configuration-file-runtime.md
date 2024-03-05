---
title: Runtime Configuration Details
description: Part of the configuration documentation for Data API builder, focusing on Runtime Configuration Details.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

## Configuration File

1. [Overview](./configuration-file-overview.md)
1. [Runtime](./configuration-file-runtime.md)
1. [Entities.{entity}](./configuration-file-entities.md)
1. [Entities.{entity}.relationships](./configuration-file-entity-relationships.md)
1. [Entities.{entity}.permissions](./configuration-file-entity-permissions.md)
1. [Entities.{entity}.policy](./configuration-file-entity-policy.md)
1. [Sample](./configuration-file-sample.md)

# Runtime

This section outlines options that influence the runtime behavior and settings for all exposed entities.

```json
{
  "runtime": {
    "rest": { ... },
    "rest": { ... },
    "graphql": { ... },
    "host": { ... }
   }
}
```

## runtime.rest

This section outlines the global settings for the REST endpoints. These settings serve as defaults for all entities but can be overridden on a per-entity basis in their respective configurations.

```json
"runtime": {
  ...
  "rest": {
    "path": "/api",
    "enabled": <true> | <false>
  }
}
```

### rest.path

Sets the URL path for accessing all exposed REST endpoints. For instance, setting this to `/api` makes the REST endpoint accessible at `/api/<entity>`. Sub-paths are not permitted. This field is optional, with `/api` as the default.

> [!NOTE]
> When deploying Data API builder using Static Web Apps (preview), the Azure service automatically injects the additional sub-path `/data-api` to the url. This behavior ensures compatibility with existing Static Web App features. The resulting endpoint would be `/data-api/api/<entity>`. This is only relevant to Static Web Apps.

### rest.enabled

A Boolean flag that determines the global availability of REST endpoints. If disabled, entities cannot be accessed via REST, regardless of individual entity settings.

## runtime.graphql

This section outlines the global settings for the GraphQL endpoint. 

```json
"runtime": {
  ...
  "graphql": {
    "path": "/graphql",
    "enabled": <true> | <false>
  }
}
```

### graphql.path

Specifies the URL path for the GraphQL endpoint. Setting this to `/graphql` exposes the endpoint at `/graphql`. Sub-paths are not allowed. This field is optional, with `graphql` as the default. Custom paths for the GraphQL endpoint are currently unsupported.

### graphql.enabled

A Boolean flag that determines the global availability of GraphQL endpoints. If disabled, entities cannot be accessed via GraphQL, regardless of individual entity settings.

## runtime.host

The `host` section within the runtime configuration provides settings crucial for the operational environment of the Data API builder. These settings include operational modes, CORS configuration, and authentication details, offering a comprehensive control over how your API behaves in different environments and how it interacts with clients and security protocols.


```json
"runtime": {
  ...
  "host": {
    "mode": "...",
    "cors": "...",
    "authentication": "..."
  }
}
```

### host.mode

Indicates how the engine should operate. 

| Mode        | Description
|-|-
| production  | In `production` mode, the engine optimizes for security and performance, setting the default `--LogLevel` to `Error`. This mode limits the detail of error messages, particularly those from the underlying database, to prevent sensitive information exposure.                               |
| development | `development` mode increases the verbosity of logging (`Debug` level) and provides detailed error messages, including those from the underlying database. This mode is beneficial for troubleshooting and development, offering insights into the application's behavior and potential issues. |


```json
"runtime": {
  ...
  "host": {
    "mode": "<production> | <development>",
  }
}
```

### host.cors 

The `host.cors` section within the runtime configuration specifies the Cross-Origin Resource Sharing (CORS) policies for the Data API builder. This defines how resources in your API can be requested from a different domain than the one that served the initial request.

```json
"runtime": {
  ...
  "host": {
    ...
    "cors": {
      "origins": [ "<array-of-strings>" ],
      "credentials": false
    }
  }
}
```

#### cors.origins

This parameter defines the allowed origins that can make requests to your API, enhancing security by limiting cross-site interactions to trusted domains only.
  
#### cors.credentials 

Controls whether browsers should include credentials, like cookies or HTTP authentication, in cross-origin requests. Setting this to `true` allows credentials on cross-origin requests, while `false` prohibits them, aligning with security best practices and specific application needs. 

More about the [`Access-Control-Allow-Credentials`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Access-Control-Allow-Credentials) header.

By default, this is `false`.

### host.authentication

Configures the authentication process.

```json
"runtime": {
  ...
  "host": {
    ...
    "authentication": {
      "provider": "<provider>",
      "jwt": {
        "audience": "<Client_ID>",
        "issuer": "<Identity_Provider_Issuer_URL>"
      }
    }
  }
}
```

#### authentication.provider

The `authentication.provider` setting within the `host` configuration defines the method of authentication used by the Data API builder. It determines how the API validates the identity of users or services attempting to access its resources. This setting allows for flexibility in deployment and integration by supporting various authentication mechanisms tailored to different environments and security requirements. 

|Provider|Description
|-|-
|StaticWebApps| Instructs Data API builder to look for a set of HTTP headers only present when running within a Static Web Apps environment. [more](/local-authentication.md)
|AppService| When the runtime is hosted in Azure AppService with AppService Authentication enabled and configured (EasyAuth). [more](https://github.com/Azure/data-api-builder/pull/97)
|AzureAd| Azure AD needs to be configured so that it can authenticate a request sent to Data API builder (the "Server App"). [more](/authentication-azure-ad.md)
|Simulator| A configurable authentication provider that instructs the Data API builder engine to treat all requests as authenticated. [more](/local-authentication.md)

> [!Note]
> Effective July 2023, Azure Active Directory (Azure AD) underwent a name change and is now known as Microsoft Entra ID. This transition occurred as part of Microsoft’s commitment to simplifying secure access experiences for everyone. 

#### authentication.jwt
  
Required if the authentication provider is `AzureAD`. This section must specify the `audience` and `issuer` to validate the received JWT token against the intended `AzureAD` tenant for authentication. [more](/authentication-azure-ad.md)

|Setting|Description
|-|-
|audience| Identifies the intended recipient of the token. In the context of your API, this is typically the application's identifier registered in Azure AD (or your identity provider), ensuring that the token was indeed issued for your application.
|issuer| Specifies the issuing authority's URL, which is the token service that issued the JWT. This URL should match the identity provider's issuer URL from which the JWT was obtained, validating the token's origin.

