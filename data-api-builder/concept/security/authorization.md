---
title: Authorization and roles
description: Define role-based authorization workflow in Data API builder for custom-defined roles and permissions.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 06/11/2025
# Customer Intent: As a developer, I want to configure roles, so that I can use roles to authorize certain endpoints.
---

# Authorization and roles in Data API builder

Data API builder uses a role-based authorization workflow. Any incoming request, authenticated or not, is assigned to a role. [Roles](#roles) can be [System Roles](#system-roles) or [User Roles](#user-roles). The assigned role is then checked against the defined [permissions](#permissions) specified in the configuration to understand what actions, fields, and policies are available for that role on the requested entity.

### Determining the user's role

No `role` has default permissions. Once a rule is determined by Data API builder, the entity's `permissions` must define `actions` for that role for the request to be successful.

| Token Provided | `x-ms-api-role` Provided | `x-ms-api-role` in Token | Resulting Role        |
| -------------- | ------------------------ | ------------------------ | --------------------- |
| No             | No                       | No                       | `anonymous`           |
| Yes            | No                       | No                       | `authenticated`       |
| Yes            | Yes                      | No                       | Exception             |
| Yes            | Yes                      | Yes                      | `x-ms-api-role` value |

To have a role other than `anonymous` or `authenticated`, the `x-ms-api-role` header is required.

> [!NOTE]
> A request can have only one role. Even if the token indicates multiple roles, the `x-ms-api-role` value selects which role is assigned to the request. 

### System roles

System roles are built-in roles recognized by Data API builder. A system role is autoassigned to a requestor regardless of the requestor's role membership denoted in their access tokens. There are two system roles: `anonymous` and `authenticated`.

#### Anonymous system role

The `anonymous` system role is assigned to requests executed by unauthenticated users. Runtime configuration defined entities must include permissions for the `anonymous` role if unauthenticated access is desired.

##### Example

The following Data API builder runtime configuration demonstrates explicitly configuring the system role `anonymous` to include *read* access to the Book entity:

```json
"Book": {
    "source": "books",
    "permissions": [
        {
            "role": "anonymous",
            "actions": [ "read" ]
        }
    ]
}
```

When a client application sends a request accessing the Book entity on behalf of an unauthenticated user, the app shouldn't include the `Authorization` HTTP header.

#### Authenticated system role

The `authenticated` system role is assigned to requests executed by authenticated users.

##### Example

The following Data API builder runtime configuration demonstrates explicitly configuring the system role `authenticated` to include *read* access to the Book entity:

```json
"Book": {
    "source": "books",
    "permissions": [
        {
            "role": "authenticated",
            "actions": [ "read" ]
        }
    ]
}
```

### User roles

User roles are nonsystem roles that are assigned to users within the identity provider you set in the runtime config. For Data API builder to evaluate a request in the context of a user role, two requirements must be met:

1. The client app supplied access token must include role claims that list a user's role membership.
1. The client app must include the HTTP header `X-MS-API-ROLE` with requests and set the header's value as the desired user role.

#### Role evaluation example

The following example demonstrates requests made to the `Book` entity that is configured in the Data API builder runtime configuration as follows:

```json
"Book": {
    "source": "books",
    "permissions": [
        {
            "role": "anonymous",
            "actions": [ "read" ]
        },
        {
            "role": "authenticated",
            "actions": [ "read" ]
        },
        {
            "role": "author",
            "actions": [ "read" ]
        }
    ]
}
```

In Static Web Apps, a user is a member of the anonymous role [by default](/azure/static-web-apps/authentication-custom?tabs=aad%2Cinvitations#manage-roles). If the user is authenticated, the user is a member of both the `anonymous` and `authenticated` roles.

When a client app sends an authenticated request to Data API builder [deployed using Static Web Apps database connections (Preview)](/azure/static-web-apps/database-overview), the client app supplies an access token that Static Web Apps [transforms into JSON](/azure/static-web-apps/user-information?tabs=javascript#client-principal-data):

```json
{
  "identityProvider": "azuread",
  "userId": "d75b260a64504067bfc5b2905e3b8182",
  "userDetails": "username",
  "userRoles": ["anonymous", "authenticated", "author"]
}
```

Because Data API builder evaluates requests in the context of a single role, it evaluates the request in the context of the system role `authenticated` by default.

If the client application's request also includes the HTTP header `X-MS-API-ROLE` with the value `author`, the request is evaluated in the context of the `author` role. An example request including an access token and `X-MS-API-ROLE` HTTP header:

```bash
curl -k -r GET -H 'Authorization: Bearer ey...' -H 'X-MS-API-ROLE: author' https://localhost:5001/api/Book
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
> - By default, either the system role `anonymous` or `authenticated`
> - When included, the role set in the `X-MS-API-ROLE` HTTP header.

### Secure by default

By default, an entity has no permissions configured, which means no one can access the entity. Additionally, Data API builder ignores database objects when they aren't referenced in the runtime configuration.

#### Permissions must be explicitly configured

To allow unauthenticated access to an entity, the `anonymous` role must be explicitly defined in the entity's permissions. For example, the `book` entity's permissions is explicitly set to allow unauthenticated read access:

```json
"book": {
  "source": "dbo.books",
  "permissions": [{
    "role": "anonymous",
    "actions": [ "read" ]
  }]
}
```

To simplify permissions definition on an entity, assume that if there are no specific permissions for the `authenticated` role, then the permissions defined for the `anonymous` role are used. The `book` configuration shown previously allows any anonymous or authenticated user's to perform read operations on the `book` entity.

When read operations should be restricted to authenticated users only, the following permissions configuration should be set, resulting in the rejection of unauthenticated requests:

```json
"book": {
  "source": "dbo.books",
  "permissions": [{
    "role": "authenticated",
    "actions": [ "read" ]
  }]
}
```

An entity doesn't require and isn't preconfigured with permissions for the `anonymous` and `authenticated` roles. One or more user roles can be defined within an entity's permissions configuration and all other undefined roles, system, or user defined, are automatically denied access.

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
> To enforce access control for GraphQL queries when using Data API builder with Azure Cosmos DB, you are required to use the `@authorize` directive in your supplied [GraphQL schema file](database-specific-features.md#user-provided-graphql-schema).
However, for GraphQL mutations and filters in GraphQL queries, access control still is enforced by the permissions configuration as described previously.

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
> To enforce access control for GraphQL queries when using Data API builder with Azure Cosmos DB, you are required to use the `@authorize` directive in your supplied [GraphQL schema file](database-specific-features.md#user-provided-graphql-schema). However, for GraphQL mutations and filters in GraphQL queries, access control still is enforced by the permissions configuration as described here.

#### Item level security

**Database policy** expressions enable results to be restricted even further. Database policies translate expressions to query predicates executed against the database. Database policy expressions are supported for the following actions:

> [!div class="checklist"]
>
> - create
> - read
> - update
> - delete

> [!WARNING]
> The **execute** action, used with stored procedures, **does not support** database policies.

> [!NOTE]
> Database policies are not currently supported by CosmosDB for NoSQL.

For more information about database policies, see the [configuration file](../../configuration/entities.md#policy-notes) documentation.

##### Example

A database policy restricting the `read` action on the `consumer` role to only return records where the *title* is "Sample Title."

```json
{
  "role": "consumer",
  "actions": [
    {
      "action": "read",
      "policy": {
        "database": "@item.title eq 'Sample Title'"
      }
    }
  ]
}
```

## Related content

- [Azure authentication](authentication-azure.md)
- [Local authentication](authentication-local.md)