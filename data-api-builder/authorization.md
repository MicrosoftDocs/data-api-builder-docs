---
title: Authorization in Data API builder
description: This document defines the role-based authorization workflow in Data API builder.
author: seantleonard
ms.author: seantleonard
ms.service: data-api-builder
ms.topic: authentication-azure-ad
ms.date: 06/01/2023
---

# Authorization

Data API builder uses a role-based authorization workflow. Any incoming request, authenticated or not, is assigned to a role. [Roles](#roles) can be [System Roles](#system-roles) or [User Roles](#user-roles). The assigned role is then checked against the defined [permissions](#permissions) specified in the [configuration file](./configuration-file.md) to understand what actions, fields, and policies are available for that role on the requested entity.

## Roles

Roles set the permissions context in which a request should be executed. For each entity defined in the runtime config, you can define a set of roles and associated permissions which determine how the entity can be accessed in both the REST and GraphQL endpoints.

Data API builder evaluates requests in the context of a single role: 
- `anonymous` when no access token is presented.
- `authenticated` when a valid access token is presented.
- `<CUSTOM_USER_ROLE>` when a valid access token is presented *and* the `X-MS-API-ROLE` HTTP header is included specifying a user role that is also included in the access token's `roles` claim.

Roles are **not** additive which means that a user who is a member of both `Role1` and `Role2` does not inherit the permissions associated with both roles. 

### System roles

System roles are built-in roles recognized by Data API builder. A system role will be auto-assigned to a requestor regardless of the requestor's role membership denoted in their access tokens. There are two system roles: `anonymous` and `authenticated`.

#### Anonymous system role

The `anonymous` system role is assigned to requests executed by unauthenticated users. Runtime configuration defined entities must include permissions for the `anonymous` role if unauthenticated access is desired.

##### Example

The following Data API builder runtime configuration demonstrates explicitly configuring the system role `anonymous` to have *read* access to the Book entity:

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

When a client application sends a request accessing the Book entity on behalf of an unauthenticated user, the app should not include the `Authorization` HTTP header.

#### Authenticated system role

The `authenticated` system role is assigned to requests executed by authenticated users. 

##### Example

The following Data API builder runtime configuration demonstrates explicitly configuring the system role `authenticated` to have *read* access to the Book entity:

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

User roles are non-system roles that are assigned to users within the identity provider you set in the runtime config. For Data API builder to evaluate a request in the context of a user role, two requirements must be met:

1. The client app supplied access token must include role claims which list a user's role membership.
1. The client app must include the HTTP header `X-MS-API-ROLE` with requests and set the header's value as the desired user role.

#### Role evaluation example

The following example demonstrates requests made to the `Book` entity which is configured in the Data API builder runtime configuration as follows:

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

When a client app sends an authenticated request to Data API builder [deployed using Static Web Apps database connections (Preview)](/azure/static-web-apps/database-overview), the client app supplies an access token that is processed by Static Web Apps and [transformed into JSON](/azure/static-web-apps/user-information?tabs=javascript#client-principal-data):

```json
{
  "identityProvider": "azuread",
  "userId": "d75b260a64504067bfc5b2905e3b8182",
  "userDetails": "username",
  "userRoles": ["anonymous", "authenticated", "author"]
}
```

Because Data API builder evaluates requests in the context of a single role, it evaluates the request in the context of the system role `authenticated` by default.

If the client application's request also includes the HTTP header `X-MS-API-ROLE` with the value `author`, the request will be evaulated in the context of the `author` role. An example request including an access token and `X-MS-API-ROLE` HTTP header:

```shell
curl -k -r GET -H 'Authorization: Bearer ey...' -H 'X-MS-API-ROLE: author' https://localhost:5001/api/Book
```

> [!IMPORTANT]
> A client app's request is rejected when the supplied access token's `roles` claim does not contain the role listed in the `X-MS-API-ROLE` header.

## Permissions

Permissions describe:
- Who can make requests on an entity (role membership).
- What actions (create, read, update, delete, execute) can that user perform.
- Which fields are accessible for a particular action.
- Additional restrictions on the results returned by a request.

The syntax for defining permissions is described in the [runtime configuration article](./configuration-file.md#permissions).

> [!IMPORTANT]
> There may be multiple roles defined within a single entity's permissions configuration. However, a request is only evaluated in the context of a single role: 
>
> - By default, either the system role `anonymous` or `authenticated`
> - When included, the role set in the `X-MS-API-ROLE` HTTP header.

### Secure by default

By default, an entity has no permissions configured, which means no one can access the entity. Additionally, database objects will be ignored by Data API builder when they are not referenced in the runtime config.

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

To simplify permissions definition on an entity, it's assumed that if there are no specific permissions for the `authenticated` role, then the permissions defined for the `anonymous` role are used. The `book` configuration shown previously allows any anonymous or authenticated user's to perform read operations on the `book` entity. 

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

An entity does not require and is not pre-configured with permissions for the `anonymous` and `authenticated` roles. One or more user roles can be defined within an entity's permissions configuration and all other undefined roles, system or user defined, are automatically denied access. 

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

#### Actions

**Actions** describe the accessibility of an entity within the scope of a role. Actions can be specified individually or with the wildcard shortcut: `*` (asterisk). The wildcard shortcut represents all actions supported for the entity type on which it's defined:

- Tables and Views: `create`, `read`, `update`, `delete`
- Stored Procedures: `execute`

For more information, see the [configuration file](./configuration-file.md#actions) documentation.

#### Field access

You can configure which fields should be accessible for an action. For example, you can set which fields to **include** and **exclude** from the `read` action.

The following example prevents users in the `free-access` role from performing read operations on `Column3`. Any reference to `Column3` in GET requests (REST endpoint) or queries (GraphQL endpoint) will result in a rejected request:

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

#### Item level security

**Database policy** expressions enable results to be restricted even further. Database policies translate expressions to query predicates executed against the database. Database policy expressions are supported for the following actions:

> [!div class="checklist"]
> - create
> - read
> - update
> - delete

> [!WARNING]
> The **execute** action, used with stored procedures, **does not support** database policies.

See the [configuration file](./configuration-file.md#policies) documentation for more details about database policies.

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
