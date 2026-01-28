---
title: Set up Azure Cosmos DB for NoSQL
description: Configure Data API builder to work with Azure Cosmos DB for NoSQL, including schema creation and authorization directives.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 01/27/2026
# Customer Intent: As a developer, I want to configure Data API builder for Azure Cosmos DB for NoSQL, so that I can use GraphQL to query my document data.
---

# Set up Data API builder for Azure Cosmos DB for NoSQL

Azure Cosmos DB for NoSQL is a schema-agnostic document database. Unlike relational databases, Azure Cosmos DB doesn't have a predefined schema that Data API builder (DAB) can introspect automatically. This guide explains how to create a GraphQL schema file and configure DAB to work with your Azure Cosmos DB containers.

## Prerequisites

- Azure Cosmos DB for NoSQL account with at least one database and container
- Data API builder CLI. [Install the CLI](../command-line/install.md)

## Understand the schema requirement

Because Azure Cosmos DB for NoSQL doesn't enforce a schema, DAB can't automatically generate GraphQL types from your data. Instead, you must provide a GraphQL schema file that defines:

- **Object types** that represent your container's document structure
- **The `@model` directive** that maps GraphQL types to entity names in your DAB configuration
- **The `@authorize` directive** (optional) that restricts field-level access to specific roles

You can handcraft the schema (examples below) or generate it from existing Cosmos DB data with the `dab export` command.

## Create a GraphQL schema file

Create a `.graphql` file that describes your data model. The schema file uses standard GraphQL Schema Definition Language (SDL) with custom directives for DAB.

### Basic schema example

This example defines a `Book` type with common fields found in a books container:

```graphql
type Book @model(name: "Book") {
  id: ID
  title: String
  year: Int
  pages: Int
  Authors: [Author]
}

type Author @model(name: "Author") {
  id: ID
  firstName: String
  lastName: String
}
```

### Generate a schema from Cosmos DB data

If you already have data in your containers, you can sample it to create a starting schema. This command writes an inferred GraphQL schema to the `schema-out` folder.

#### [Bash](#tab/bash-cli)

```bash
dab export \
  --graphql \
  --generate \
  -o ./schema-out
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab export ^
  --graphql ^
  --generate ^
  -o .\schema-out
```

---

By default, sampling uses `TopNExtractor`. For other modes and options, see the [CLI reference for `dab export`](../command-line/dab-export.md).

The `@model` directive is required. It maps the GraphQL type to an entity name in your DAB configuration file. The `name` parameter must match the entity name exactly.

> [!NOTE]
> The `Authors: [Author]` field represents an **embedded array** within the Book document, not a relationship to a separate container. In Azure Cosmos DB for NoSQL, related data should be embedded within the same document rather than stored in separate containers.

### Schema with authorization

To restrict access to specific fields, use the `@authorize` directive. This directive accepts a `roles` parameter that specifies which roles can access the field.

```graphql
type Book @model(name: "Book") {
  id: ID
  title: String @authorize(roles: ["authenticated", "metadataviewer"])
  internalNotes: String @authorize(roles: ["editor"])
  Authors: [Author]
}
```

In this example:

- The `title` field is only accessible to users with the `authenticated` or `metadataviewer` role
- The `internalNotes` field is only accessible to users with the `editor` role
- Fields without `@authorize` are accessible based on entity-level permissions

You can also apply `@authorize` at the type level to restrict access to the entire type:

```graphql
type InternalReport @model(name: "InternalReport") @authorize(roles: ["editor", "authenticated"]) {
  id: ID
  title: String
  confidentialData: String
}
```

> [!IMPORTANT]
> The `@authorize` directive works **in addition to** entity-level permissions defined in the runtime configuration. Both the `@authorize` directive and entity permissions must allow access for a request to succeed.
>
> For example, if a field has `@authorize(roles: ["editor"])`, but the entity has no permission entry for the `editor` role, access to that field is denied.

## Configure the DAB runtime

After creating your schema file, configure DAB to use it with your Azure Cosmos DB account.

### Initialize the configuration

Use the `dab init` command to create a configuration file for Azure Cosmos DB:

#### [Bash](#tab/bash-cli)

```bash
dab init \
  --database-type cosmosdb_nosql \
  --cosmosdb_nosql-database <your-database-name> \
  --graphql-schema schema.graphql \
  --connection-string "<your-connection-string>"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab init ^
  --database-type cosmosdb_nosql ^
  --cosmosdb_nosql-database <your-database-name> ^
  --graphql-schema schema.graphql ^
  --connection-string "<your-connection-string>"
```

---

Replace `<your-database-name>` with your Azure Cosmos DB database name and `<your-connection-string>` with your connection string.

> [!TIP]
> For production environments, use environment variables for connection strings instead of hardcoding them:
>
> ```bash
> dab init \
>     --database-type cosmosdb_nosql \
>     --cosmosdb_nosql-database <your-database-name> \
>     --graphql-schema schema.graphql \
>     --connection-string "@env('COSMOSDB_CONNECTION_STRING')"
> ```

### Add entities

Add entities that correspond to your containers. The entity name must match the `@model(name: "...")` value in your schema:

#### [Bash](#tab/bash-cli)

```bash
dab add Book \
  --source Book \
  --permissions "anonymous:read"
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab add Book ^
  --source Book ^
  --permissions "anonymous:read"
```

---

The `--source` parameter specifies the Azure Cosmos DB container name.

### Configuration file example

After initialization, your configuration file should look similar to this:

```json
{
  "$schema": "https://github.com/Azure/data-api-builder/releases/download/v1.2.11/dab.draft.schema.json",
  "data-source": {
    "database-type": "cosmosdb_nosql",
    "options": {
      "database": "Library",
      "schema": "schema.graphql"
    },
    "connection-string": "@env('COSMOSDB_CONNECTION_STRING')"
  },
  "entities": {
    "Book": {
      "source": "Book",
      "permissions": [
        {
          "role": "anonymous",
          "actions": ["read"]
        },
        {
          "role": "metadataviewer",
          "actions": ["read"]
        }
      ]
    }
  }
}
```

> [!NOTE]
> The `schema` path in the configuration file is relative to the location of the DAB configuration file. Ensure your GraphQL schema file is in the correct directory.

## Role-based field access

When using the `@authorize` directive with roles, consider how roles are assigned:

| Scenario | Role assignment | Access to `@authorize` fields |
| --- | --- | --- |
| **Anonymous request** | No roles assigned | Denied |
| **Authenticated request** | The `authenticated` system role is automatically assigned | Allowed if role matches |
| **Custom role request** | Include the `X-MS-API-ROLE` header with the role name | Allowed if role matches |

For authenticated requests needing a custom role, send the `X-MS-API-ROLE` header:

```http
GET /graphql HTTP/1.1
Host: localhost:5000
Authorization: Bearer <your-jwt-token>
X-MS-API-ROLE: metadataviewer
```

## Cross-container queries

GraphQL operations across containers aren't currently supported in Azure Cosmos DB for NoSQL. If you attempt to configure relationships between entities in different containers, DAB returns an error indicating that relationships between containers aren't supported.

For relationship configuration details (supported for other databases), see [Relationships configuration](../configuration/entities.md#relationships-entity-name-entities).

### Work around cross-container limitations

To work around this limitation, consider restructuring your data model to use embedded documents within a single container. This approach is often more efficient for Azure Cosmos DB and aligns with NoSQL data modeling best practices.

For example, instead of separate `Book` and `Author` containers with relationships:

```json
// Embedded model in a single container
{
  "id": "book-1",
  "title": "Introduction to DAB",
  "authors": [
    {
      "firstName": "Jane",
      "lastName": "Developer"
    }
  ]
}
```

For more information about data modeling strategies, see [Data modeling in Azure Cosmos DB](/azure/cosmos-db/nosql/modeling-data).

## REST API availability

Data API builder doesn't generate REST endpoints for Azure Cosmos DB for NoSQL because Azure Cosmos DB already provides a comprehensive native REST API for document operations.

When using DAB with Azure Cosmos DB for NoSQL, only GraphQL endpoints are available. To access your data via REST, use the [Azure Cosmos DB REST API](/rest/api/cosmos-db/) directly.

## Common configuration issues

**Schema file not found**

- Error: `GraphQL schema file not found`
- Solution: Ensure the `schema` path in your configuration is relative to the config file location.

**Entity name mismatch**

- Error: `Entity '<name>' not found in schema`
- Solution: Verify the entity name in your config matches the `@model(name: "...")` directive exactly. Names are case-sensitive.

**Unauthorized field access**

- Error: Field appears as `null` in response
- Solution: Check that both `@authorize` roles AND entity permissions allow access for the requesting role.

## Next step

> [!div class="nextstepaction"]
> [Quickstart: Use Data API builder with NoSQL](../quickstart/nosql.md)

## Related content

- [Quickstart: Use Data API builder with Azure Cosmos DB for NoSQL and Azure Container Apps](../quickstart/azure-cosmos-db-nosql.md)
- [Feature availability for Data API builder](../feature-availability.md)
- [Data modeling in Azure Cosmos DB](/azure/cosmos-db/nosql/modeling-data)
