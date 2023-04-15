---
title: Release notes for Data API builder 0.6.13 
description: Release notes for Data API builder 0.6.13 are available here.
author: anagha-todalbagi 
ms.author: atodalbagi
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 04/06/2023
---

# What's New in Data API builder 0.6.13

- [New CLI command to export GraphQL schema](#new-cli-command-to-export-graphql-schema)
- [Database policy support for create action for MsSql](#database-policy-support-for-create-action-for-mssql)
- [Ability to configure GraphQL path and disable REST and GraphQL endpoints globally via CLI](#ability-to-configure-graphql-path-and-disable-rest-and-graphql-endpoints-globally-via-cli)
- [Key fields mandatory for adding/updating views in CLI](#key-fields-mandatory-for-adding-and-updating-views-in-cli)
- [Replacing Azure storage link with GitHub links](#replacing-azure-storage-link-with-github-links)

The full list of release notes for this version is available here: [version 0.6.13 release notes](https://github.com/Azure/data-api-builder/releases/tag/v0.6.13)

## New CLI command to export GraphQL schema

A new option is added to export GraphQL schema. This starts up the DAB server and then query it to get the schema before writing it to the location that has been provided

For example:

```text
dab export --graphql -c dab-config.development.json -o ./schemas
```

generates the GraphQL schema file in the ./schemas directory. The path to configuration file is an optional parameter, which defaults to 'dab-config.json' unless 'dab-config.<DAB_ENVIRONMENT>.json' exists, where DAB_ENVIRONMENT is an environment variable.

## Database policy support for create action for MsSql

Database policies are now supported for all the CRUD (Create, Read, Update, Delete) operations for MsSql.
For example:

```json
"entities":{
  "Revenue":{
    "source": "revenues",
    "permissions":[
      "role": "authenticated",
          "actions": [
            {
              "action": "Create",
              "policy": {
                "database": "@item.revenue gt 0"
              }
            },
            "read",
            "update",
            "delete"
          ]
    ]
  }
}
```

The above configuration for `Revenue` entity indicates that the user who is performing an insert operation with role `Authenticated` isn't allowed to create a record with revenue less than or equal to zero.

## Ability to configure GraphQL path and disable REST and GraphQL endpoints globally via CLI

We now support three more options for the `init` command:

- `graphql.path` : To provide custom GraphQL path
- `rest.disabled`: To disable REST endpoints globally
- `graphql.disabled`: To disable GraphQL endpoints globally

For example, an `init` command like:

```text
dab init --database-type mssql --rest.disabled --graphql.disabled --graphql.path /gql
```

would generate a config file where the runtime section looks like this:

```json
"runtime": {
    "rest": {
      "enabled": false,
      "path": "/api"
    },
    "graphql": {
      "allow-introspection": true,
      "enabled": false,
      "path": "/gql"
    },
}
```

## Key fields mandatory for adding and updating views in CLI

It's now mandatory for the user to provide the key-fields (to be used as primary key) via the exposed option `source.key-fields` whenever adding a new database view (via `dab add`) to the config via CLI. Also, whenever updating anything in the view's configuration (via `dab update`) in the config file via CLI, if the update changes anything that relates to the definition of the view in the underlying database (for example, source type, key-fields), it's mandatory to specify the key-fields in the update command as well.

However, we still support views without having explicit primary keys specified in the config, but the configuration for such views have to be written directly in the config file.

For example, a `dab add` command like:

```text
dab add books_view --source books_view --source.type "view" --source.key-fields "id" --permissions "anonymous:*" --rest true --graphql true
```

generates the configuration for `books_view` entity that looks like this:

```json
"books_view": {
      "source": {
        "type": "view",
        "object": "books_view",
        "key-fields":[
          "id"
        ]
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            "*"
          ]
        }
      ],
      "rest": true,
      "graphql": true
    }
```

## Replacing Azure storage link with GitHub links

Since DAB is now open-sourced, we don't need to download the artifacts from the storage account. Instead, we can directly download them from GitHub. Hence, the links are accordingly updated.
