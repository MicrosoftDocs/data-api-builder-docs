---
title: Release notes for Data API builder 0.10
description: Release notes for Data API builder 0.10 are available here.
author: jerrynixon
ms.author: jnixon
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 3/1/2025
---

# Data API builder vresion 0.10

## How to Upgrade 

### Update the Developer CLI

The Data API Builder CLI is a tool that helps developers easily build their configuration files with fewer errors. Additionally, the CLI runs the DAB engine in the developer's local environment. The CLI is revised with every new Data API Builder release, including version 0.10. 

1. **If the tool is not already installed**

`dotnet tool install microsoft.dataapibuilder --version 0.10.23 -g`.

2. **If the tool is already installed**

`dotnet tool update microsoft.dataapibuilder --version 0.10.23 -g`.

This will result in a message similar to 

````
Tool 'microsoft.dataapibuilder' was successfully updated
from version '0.9.7' to version '0.10.23'.
````

> Note: as different subversions of 0.10 are potentially released to address regressions, you may want to update the scripts above to include those subversions. Omitting `--version` completely will get the latest version available.

#### Side-by-side CLI versions

The `-g` switch in the `dotnet tool install` and `dotnet tool update` commands stands for "global". When you use `-g` with these commands, it means you are installing or updating the .NET Core CLI tool globally on your machine. This allows the tool to be accessed from any directory in your command line or terminal session. Without the `-g` switch, the tool would only be installed locally in the current directory or the directory specified, limiting its accessibility to that specific location.

### Update the Container Version

The Data API Builder container can be utilized by the desktop version of Docker or hosted in a container service like Kubernetes. Every version of DAB, including this one, is securely hosted in the [Microsoft Container Registry](https://aka.ms/dab/registry). 

1. **To automatically pull the most recent version**

`docker pull mcr.microsoft.com/azure-databases/data-api-builder:latest`

2. **To pull a specific version**

`docker pull mcr.microsoft.com/azure-databases/data-api-builder:0.10.*`.

## What's new in version 0.10

Note: As we approach General Availability (projected for early May 2024), our focus shifts to stability. Not included below is the significant effort to resolve issues and ensure code quality and engine stability. The following list should not be seen as an exhaustive representation of the engineering work undertaken across the codebase.

### In-memory caching

Version 0.10 introduces REST and Graph QL endpoint in-memory cache. We built this feature to deliver internal caching with all the hooks to add distributed 2nd level caching at a later date. Today, in-memory cache gives a complete story to developers wanting to reduce the database impact of repeating queries.

#### Scenarios for caching

Consider a call to your database against a large table or sophisticated view. Each call takes a certain amount of time. Identical subsequent calls take the same amount of time, even though the results have not changed. Cache can eliminate the database cost of these expensive queries by caching the results for some time on the API layer.

Consider a call to your database against any table that occurs again and again in short succession. This could be the result of multiple clients, or a UX that simply needs the same data over and over. Caching is perfect for this because it allow frequent calls to the API without imposing frequent calls to the database. It can scale and API from supporting hundreds of concurrent calls to thousands of concurrent calls.

#### Configuration changes

The DAB configuration file is impacted by this enhancement in two places: the `runtime` section and within each entity. The latter allows the developer to turn caching on and off at a granular level - according to their requirements.

**Runtime settings**

```json
{
    "runtime": {
        "cache": {
            "enabled": true,
            "ttl-seconds": 6
        }
    }
}
```

 - By default, caching is disabled.
 - The TTL default is 5 seconds.

TTL stands for time-to-live. It is a caching convention that sets the global default for how long a cached value should be returned by an endpoint, in seconds, before it refreshed by a query to the database again. Only identical queries (including filters, et al) receive a cached, of course, and all of this is managed by the Data API builder engine automatically.

**Entity settings**

> Caching must be enabled globally (see above) before entity-level settings will be reflected. Enabling it at the entity level does not change the global setting. In this way, developers can disable or enable caching with one setting, then tailor the caching experience for every entity. 

**Example configuration**
```json
    "Book": {
      "source": {
        "object": "books",
        "type": "table"
      },
      "graphql": {
        "enabled": true,
        "type": {
          "singular": "book",
          "plural": "books"
        }
      },
      "rest": {
        "enabled": true
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
      ],
      "cache": {
        "enabled": true,
        "ttl-seconds": 6
      }
    }
``` 

 - By default, caching is disabled.
 - The TTL default is the global setting.

Every entity can participate in caching and, if desired, specify a custom TTL value. Without the optional `"enabled": true` configuration, caching is disabled for an entity, and without the optional `"ttl-seconds: N` setting, entity caching defaults to the global setting. 

### Configuration [Validation in CLI](https://github.com/Azure/data-api-builder/commit/e26d50717753272ca797c45c19e7aad6b6e52f91)

Today you can start dab using the CLI with `dab start` or create a new configuration file with `dab init`. The CLI is for the developer and makes their workflow easier. With validation, developres can use the CLI to check for logical inconsistencies, sytnax errors, or even schema incompabibilities with `dab validate`.

#### Order of Validation
1. **Schema validation:** fetches the schema file from the `$schema`
property, if not available uses the schema present in the package.
2. **Config properties validation:** validates datasource,
runtime-section, rest and graphQL endpoints
3. **Config permission validation:** validates semantic correctness of
the permission defined for each entity.
4. **Database connection validation:** validates connection to database.
5. **Entities Metadata validation:** validates entites configuration
against database. this check won't run if database connection fails.

### Preview features

Preview features in Data API builder are the initial support of a future enhancement. They can be used today and any additional functionality introduced later will follow DAB's breaking change policy. 

- Initial support for DWSQL. [#1864](https://github.com/Azure/data-api-builder/pull/1864)
- Initial support for multiple data sources. [#1709](https://github.com/Azure/data-api-builder/pull/1709)

### List of releases:

### Feb 6. Version 0.10.23
[0.10.23: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v0.10.23)

#### Jan 31. Version 0.10.21

[0.10.21: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v0.10.21)

#### Dec 7. Version 0.10.11

[0.10.11-rc: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v0.10.11-rc)