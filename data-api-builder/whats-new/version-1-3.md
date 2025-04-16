---
title: What's new for version 1.3
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 1.3.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 11/16/2024
---

# What's new in Data API builder version 1.3 (November 2024)

Release notes and information about the updates and enhancements in Data API builder (DAB) version 1.3.  
[Release 1.3: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v1.3.19)

## Introducing: Hot Reload

Your developer loop is now smaller, faster, and more efficient. Previously, changing the configuration file required stopping and restarting the engine. With Hot Reload, DAB detects configuration changes automatically and applies updates without restarting the engine. You can test changes instantly and stay in the flow. As of version 1.3, nearly every DAB feature supports Hot Reload.

Hot Reload is always on and can't be disabled. However, in `production` mode, it doesn't apply configuration changes. This behavior prevents unauthorized updates from silently reconfiguring endpoints. In a future release, `production` mode also supports the `log-level` setting—a feature that adjusts log verbosity by namespace to help diagnose runtime behavior.

## Introducing: Cosmos schema generation

Data API builder is one of the first command-line interfaces (CLIs) to help developers generate schemas for NoSQL data sources. When you configure Cosmos DB, DAB needs a schema to build a structured GraphQL endpoint.

Creating that schema manually can be complex. With this release, the DAB CLI includes a schema generation feature. By sampling your data based on the entities you define, it generates a working schema—requiring only minimal review and updates to get started.

```sh
dab init 
  --database-type cosmosdb_nosql 
  --connection-string @env('cosmos-connection-string') 
  --cosmosdb_nosql-database MyDatabase
  --cosmosdb_nosql-container MyContainer

dab add MyEntity
  --source "MyDatabase.MyEntity"
  --permissions "anonymous:*"
  --graphQL "MyEntity:MyEntities"

dab export
  --graphql
  --generate
  -o ./schemas

dab start
```

## Command line everything

As Data API builder evolves, the configuration file grows longer and more sophisticated. This format is JSON—easy to read and edit—it’s also easy to break with a misplaced comma or bracket. That option is why the DAB CLI helps developers safely modify configuration without editing JSON directly.

In version 1.3, the new `dab configure` subcommand updates almost every setting in the `runtime` and `data-source` sections. This update brings DAB closer to full CLI coverage, and each release continues to expand that coverage.

### Example: Update `data-source`

#### Option 1: One comprehensive command
```sh
dab configure 
  --data-source.database-type cosmosdb_nosql
  --data-source.options.database testdbname 
  --data-source.options.schema testschema.gql
```

#### Option 2: Several smaller commands
```sh
dab configure --data-source.database-type cosmosdb_nosql
dab configure --data-source.options.database testdbname
dab configure --data-source.options.schema testschema.gql
```

### A note about `database-type`

Some options are specific to the database type. If your configuration currently uses `mssql` and you apply Cosmos DB options without first switching to `cosmosdb_nosql`, the command fails.

### More examples

```sh
dab configure --runtime.graphql.enabled true
dab configure --runtime.graphql.path /updatedPath
dab configure --runtime.graphql.allow-introspection true 
dab configure --runtime.graphql.multiple-mutations.create.enabled true
```

DAB continues to move toward complete command-line coverage—even for deeply nested configuration properties.