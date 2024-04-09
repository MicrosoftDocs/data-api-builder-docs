---
title: Database-specific features
description: Various databases have specific features that requires unique configuration properties in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 04/09/2024
---

# Database-specific features for Data API builder

Data API builder allows each database to have its own specific features. This article details the features that are supported for each database.

## Database version support

Many traditional databases require a minimum version to be compatible with Data API builder (DAB).

| | Minimum Supported Version |
| --- | --- |
| **SQL Server** | 2016 |
| **MySQL** | 8 |
| **PostgreSQL** | 11 |

Conversely, Azure cloud database services work with DAB out of the box withour requiring a specific version.

| | Minimum Supported Version |
| --- | --- |
| **Azure SQL** | n/a |
| **Azure Cosmos DB for NoSQL** | n/a |
| **Azure Cosmos DB for PostgreSQL** | n/a |

## Azure SQL and SQL Server

There are a few specific properties that are unique to SQL including both Azure SQL and SQL Server.

### SESSION_CONTEXT

Azure SQL and SQL Server support the use of the `SESSION_CONTEXT` function to access the current user's identity. This is useful when you want to leverage the native support for row level security (RLS) available in Azure SQL and SQL Server.

For Azure SQL and SQL Server, Data API builder can take advantage of `SESSION_CONTEXT` to send user specified metadata to the underlying database. Such metadata is available to Data API builder by virtue of the claims present in the access token. The data sent to the database can then be used to configure an additional level of security (for example, by configuring Security policies) to further prevent access to data in operations like SELECT, UPDATE, DELETE. The `SESSION_CONTEXT` data is available to the database for the duration of the database connection until that connection is closed. The same data can be used inside a stored procedure as well.  

For more information about setting `SESSION_CONTEXT` data, see [`sp_set_session_context` (Transact-SQL)](/sql/relational-databases/system-stored-procedures/sp-set-session-context-transact-sql).

Configure `SESSION_CONTEXT` using the `options` property of the `data-source` section in the configuration file. For more information, see [`data-source` configuraton reference](reference-configuration.md#data-source).

```json
{
  ...
  "data-source": {
    "database-type": "mssql",
    "options": {
      "set-session-context": true
    },
    "connection-string": "<connection-string>"
  },
  ...
}
```

Alternatively, use the `--set-session-context` argument with the `dab init` command.

```console
dab init --database-type mssql --set-session-context true
```

All of the claims present in the EasyAuth/JWT token are sent via the `SESSION_CONTEXT` to the underlying database. All the claims present in the token are translated into key-value pairs passed via `SESSION_CONTEXT` query. These claims include, but are not limited to:

| | Description |
| --- | --- |
| **`aud`** | Audience |
| **`iss`** | Issuer |
| **`iat`** | Issued at |
| **`exp`** | Expiration time |
| **`azp`** | Application identifier |
| **`azpacr`** | Authentication method of the client |
| **`name`** | Subject |
| **`uti`** | Unique token identifier |

For more information on claims, see [Microsoft Entra ID access token claims reference](/entra/identity-platform/access-token-claims-reference).

These claims are translated into a SQL query. This truncated example illustrates how `sp_set_session_context` is used in this context:

```sql
EXEC sp_set_session_context 'aud', '<AudienceID>', @read_only = 1;
EXEC sp_set_session_context 'iss', 'https://login.microsoftonline.com/<TenantID>/v2.0', @read_only = 1;
EXEC sp_set_session_context 'iat', '1637043209', @read_only = 1;
...
EXEC sp_set_session_context 'azp', 'a903e2e6-fd13-4502-8cae-9e09f86b7a6c', @read_only = 1;
EXEC sp_set_session_context 'azpacr', 1, @read_only = 1;
..
EXEC sp_set_session_context 'uti', '_sSP3AwBY0SucuqqJyjEAA', @read_only = 1;
EXEC sp_set_session_context 'ver', '2.0', @read_only = 1;
```

You can then iplement row-level security (RLS) using the session data. For more information, see [implement row-level security with session context](how-to-row-level-security.md)

### Azure Cosmos DB

There are a few specific properties that are unique to various APIs in Azure Cosmos DB.

#### User-Provided GraphQL schema in API for NoSQL

The Azure Cosmos DB NOSQL API is schema-agnostic. In order to use Data API builder with Azure Cosmos DB, you must create a GraphQL schema file that includes the object type definitions representing your Azure Cosmos DB container's data model. Data API builder also expects your GraphQL object type definitions and fields to include the GraphQL schema directive `authorize` when you want to enforce more restrictive read access than `anonymous`.

Example 1:

```graphql 
type Book @model(name:"Book"){
  id: ID
  title: String @authorize(roles:["role1","authenticated"])
  Authors: [Author]
}
```
and the corresponding entities section in config.json

```json
{
  "Book": {
    "source": "Book",
    "permissions": [
      {
        "role": "anonymous",
        "actions": [
          "read"
        ]
      },
      {
        "role": "role1",
        "actions": [
          "read"
        ]
      }
    ]
  }
}

```

The @authorize directive with roles:["role1","authenticated"] restricts access to the title field to only users with the roles "role1" and "authenticated". For authenticated requestors, the system role 'authenticated' is automatically assigned, eliminating the need for `X-MS-API-ROLE` header. If the authenticated request needs to be executed in context of `role1`, it should be accompanied with the value of request header `X-MS-API-ROLE` set to `role1`. However, if anonymous access is desired, you must omit the authorize directive.

The `@model` directive is utilized to establish a correlation between this GraphQL object type and the corresponding entity name in the runtime config. The directive is formatted as: `@model(name:"<Entity_Name>")`

Example 2:

```graphql 
type Book @model(name:"Book") @authorize(roles:["role1","authenticated"]) {
  id: ID
  title: String
  Authors: [Author]
}
```
and the corresponding entities section in config.json

```json
{
  "Book": {
    "source": "Book",
    "permissions": [
      {
        "role": "authenticated",
        "actions": [
          "read"
        ]
      },
      {
        "role": "role1",
        "actions": [
          "read"
        ]
      }
    ]
  }
}

```

By incorporating the @authorize directive in the top-level type definition, you restrict access to the type and its fields are restricted exclusively to the roles specified within the directive.

#### Cross Container Operations in API for NoSQL

Currently, GraphQL operations across containers are unsupported. The engine responds with an error message stating, "Adding/updating Relationships is currently not supported in Cosmos DB."You can work around this limitation by updating your data model to store entities within the same container in an embedded format. To learn more, reference our Cosmos DB NOSQL data modeling [documentation](/azure/cosmos-db/nosql/modeling-data).
