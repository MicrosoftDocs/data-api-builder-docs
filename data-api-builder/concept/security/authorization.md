---
title: Authorization and roles
description: Define role-based authorization workflow in Data API builder for custom-defined roles and permissions.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 01/21/2026
# Customer Intent: As a developer, I want to configure roles, so that I can use roles to authorize certain endpoints.
---

# Authorization and roles in Data API builder

Data API builder uses a role-based authorization workflow. Any incoming request, authenticated or not, is assigned to a role. Roles can be [System Roles](#system-roles) or [User Roles](#user-roles). The assigned role is then checked against the defined [permissions](#permissions) specified in the configuration to understand what actions, fields, and policies are available for that role on the requested entity.

![Illustration of how Data API builder selects a role and evaluates permissions for a request.](media/authorization/authorization-role-evaluation.svg)

### Determining the user's role

No role has default permissions. Once Data API builder determines a role, the entity's `permissions` must define `actions` for that role for the request to be successful.

The following role evaluation matrix applies to JWT bearer providers (for example, `EntraID`/`AzureAD` and `Custom`) where the client sends `Authorization: Bearer <token>`.

| Bearer token provided | `X-MS-API-ROLE` provided | Requested role present in token `roles` claim | Effective role / outcome |
| --- | --- | --- | --- |
| No | No | N/A | `Anonymous` |
| Yes (valid) | No | N/A | `Authenticated` |
| Yes (valid) | Yes | No | Rejected (403 Forbidden) |
| Yes (valid) | Yes | Yes | `X-MS-API-ROLE` value |
| Yes (invalid) | Any | N/A | Rejected (401 Unauthorized) |

To use a role other than `Anonymous` or `Authenticated`, the `X-MS-API-ROLE` header is required.

> [!NOTE]
> A request can be associated with many roles in the authenticated principal. However, Data API builder evaluates permissions and policies in the context of exactly one effective role. When provided, the `X-MS-API-ROLE` header selects which role is used.

Provider notes:

- EasyAuth providers (for example, `AppService`): authentication can be established by platform-injected headers (such as `X-MS-CLIENT-PRINCIPAL`) rather than a bearer token.
- `Simulator`: requests are treated as authenticated for development/testing, without validating a real token.

### System roles

System roles are built-in roles recognized by Data API builder. A system role is autoassigned to a requestor regardless of the requestor's role membership denoted in their access tokens. There are two system roles: `Anonymous` and `Authenticated`.

#### Anonymous system role

The `Anonymous` system role is assigned to requests executed by unauthenticated users. Runtime configuration defined entities must include permissions for the `Anonymous` role if unauthenticated access is desired.

##### Example

The following Data API builder runtime configuration demonstrates explicitly configuring the system role `Anonymous` to include *read* access to the Book entity:

```json
"Book": {
    "source": "books",
    "permissions": [
        {
            "role": "Anonymous",
            "actions": [ "read" ]
        }
    ]
}
```

When a client application sends a request accessing the Book entity on behalf of an unauthenticated user, the app shouldn't include the `Authorization` HTTP header.

#### Authenticated system role

The `Authenticated` system role is assigned to requests executed by authenticated users.

##### Example

The following Data API builder runtime configuration demonstrates explicitly configuring the system role `Authenticated` to include *read* access to the Book entity:

```json
"Book": {
    "source": "books",
    "permissions": [
        {
            "role": "Authenticated",
            "actions": [ "read" ]
        }
    ]
}
```

### User roles

User roles are nonsystem roles that are assigned to users within the identity provider you set in the runtime config. For Data API builder to evaluate a request in the context of a user role, two requirements must be met:

1. The authenticated principal must include role claims that list a user's role membership (for example, the JWT `roles` claim).
1. The client app must include the HTTP header `X-MS-API-ROLE` with requests and set the header's value as the desired user role.

#### Role evaluation example

The following example demonstrates requests made to the `Book` entity that is configured in the Data API builder runtime configuration as follows:

```json
"Book": {
    "source": "books",
    "permissions": [
        {
      "role": "Anonymous",
            "actions": [ "read" ]
        },
        {
      "role": "Authenticated",
            "actions": [ "read" ]
        },
        {
            "role": "author",
            "actions": [ "read" ]
        }
    ]
}
```

Data API builder evaluates requests in the context of a single effective role. If a request is authenticated and no `X-MS-API-ROLE` header is provided, Data API builder evaluates the request in the context of the `Authenticated` system role by default.

If the client application's request also includes the HTTP header `X-MS-API-ROLE` with the value `author`, the request is evaluated in the context of the `author` role. An example request including an access token and `X-MS-API-ROLE` HTTP header:

```bash
curl -k -X GET \
  -H 'Authorization: Bearer ey...' \
  -H 'X-MS-API-ROLE: author' \
  https://localhost:5001/api/Book
```

> [!IMPORTANT]
> A client app's request is rejected when the supplied access token's `roles` claim doesn't contain the role listed in the `X-MS-API-ROLE` header.

## Permissions

Permissions describe:

- Who can make requests on an entity based on role membership?
- What actions (create, read, update, delete, execute) a user can perform?
- Which fields are accessible for a particular action?
- Which extra restrictions exist on the results returned by a request?

The syntax for defining permissions is described in the [runtime configuration article](../../configuration/entities.md#permissions).

> [!IMPORTANT]
> There may be multiple roles defined within a single entity's permissions configuration. However, a request is only evaluated in the context of a single role:
>
> - By default, either the system role `Anonymous` or `Authenticated`
> - When included, the role set in the `X-MS-API-ROLE` HTTP header.

### Secure by default

By default, an entity has no permissions configured, which means no one can access the entity. Additionally, Data API builder ignores database objects when they aren't referenced in the runtime configuration.

#### Permissions must be explicitly configured

To allow unauthenticated access to an entity, the `Anonymous` role must be explicitly defined in the entity's permissions. For example, the `book` entity's permissions are explicitly set to allow unauthenticated read access:

```json
"book": {
  "source": "dbo.books",
  "permissions": [{
    "role": "Anonymous",
    "actions": [ "read" ]
  }]
}
```

If you want both unauthenticated and authenticated users to have access, explicitly grant permissions to both system roles (`Anonymous` and `Authenticated`).

When read operations should be restricted to authenticated users only, the following permissions configuration should be set, resulting in the rejection of unauthenticated requests:

```json
"book": {
  "source": "dbo.books",
  "permissions": [{
    "role": "Authenticated",
    "actions": [ "read" ]
  }]
}
```

An entity doesn't require and isn't preconfigured with permissions for the `Anonymous` and `Authenticated` roles. One or more user roles can be defined within an entity's permissions configuration and all other undefined roles, system, or user defined, are automatically denied access.

In the following example, the user role `administrator` is the only defined role for the `book` entity. A user must be a member of the `administrator` role and include that role in the `X-MS-API-ROLE` HTTP header to operate on the `book` entity:

```json
"book": {
  "source": "dbo.books",
  "permissions": [{
    "role": "administrator",
    "actions": [ "*" ]
  }]
}
```

> [!NOTE]
> To enforce access control for GraphQL queries when using Data API builder with Azure Cosmos DB, you must use the `@authorize` directive in your supplied [GraphQL schema file](../../reference-database-specific-features.md). However, for GraphQL mutations and filters in GraphQL queries, the permissions configuration still enforces access control as described previously.

#### Actions

**Actions** describe the accessibility of an entity within the scope of a role. Actions can be specified individually or with the wildcard shortcut: `*` (asterisk). The wildcard shortcut represents all actions supported for the entity type:

- Tables and Views: `create`, `read`, `update`, `delete`
- Stored Procedures: `execute`

For more information about actions, see the [configuration file](../../configuration/entities.md#actions-string-array-permissions-entity-name-entities) documentation.

#### Field access

You can configure which fields should be accessible for an action. For example, you can set which fields to **include** and **exclude** from the `read` action.

The following example prevents users in the `free-access` role from performing read operations on `Column3`. References to `Column3` in GET requests (REST endpoint) or queries (GraphQL endpoint) result in a rejected request:

```json
    "book": {
      "source": "dbo.books",
      "permissions": [
        {
          "role": "free-access",
          "actions": [
            "create",
            "update",
            "delete",
            {
              "action": "read",
              "fields": {
                "include": [ "Column1", "Column2" ],
                "exclude": [ "Column3" ]
              }
            }
          ]
        }
      ]
    }
```

> [!NOTE]
> To enforce access control for GraphQL queries when using Data API builder with Azure Cosmos DB, you must use the `@authorize` directive in your supplied [GraphQL schema file](../../reference-database-specific-features.md). However, for GraphQL mutations and filters in GraphQL queries, the permissions configuration still enforces access control as described here.

#### Item level security

**Database policies** let you filter results at the row level. Policies translate to query predicates that the database evaluates, ensuring users access only authorized records.

| Supported actions | Not supported |
|-------------------|---------------|
| `read`, `update`, `delete` | `create`, `execute` |

> [!NOTE]
> Azure Cosmos DB for NoSQL doesn't currently support database policies.

For detailed configuration steps, syntax reference, and examples, see [Configure database policies](how-to-configure-database-policies.md).

##### Quick example

```json
{
  "role": "consumer",
  "actions": [
    {
      "action": "read",
      "policy": {
        "database": "@item.ownerId eq @claims.userId"
      }
    }
  ]
}
```

## Related content

- [Configure database policies for row-level filtering](how-to-configure-database-policies.md)
- [Configure Microsoft Entra ID authentication](how-to-authenticate-entra.md)
- [Configure Simulator authentication for local testing](how-to-authenticate-simulator.md)