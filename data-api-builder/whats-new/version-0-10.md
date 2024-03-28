---
title: What's new for version 0.10
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 0.10.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 03/28/2024
---

# What's new in Data API builder version 0.10

Release notes and information about the updates and enhancements in Data API builder version 0.10.

## How to Upgrade

### Update the Developer CLI

The Data API builder CLI is a tool that helps developers build their configuration files with fewer errors. It also runs the DAB engine in the developer's local environment. With each new release of Data API builder, including version 0.10, we revise the CLI.

1. **For first-time installation**

```dotnetcli
dotnet tool install microsoft.dataapibuilder --version 0.10.23 -g
```

1. **For updating an existing installation**

```dotnetcli
dotnet tool update microsoft.dataapibuilder --version 0.10.23 -g
```

You see a message similar to:

```output
Tool 'microsoft.dataapibuilder' was successfully updated from version '0.9.7' to version '0.10.23'.
```

> [!NOTE]
> To incorporate potential subversions of 0.10 released for addressing bugs, you might update the scripts to include those subversions. Omitting `--version` fetches the latest version available.

#### Understanding the Global Installation

The `-g` switch in the `dotnet tool install` and `dotnet tool update` commands indicates a "global" installation. It makes the .NET Core CLI tool accessible from any directory in your command line or terminal session.

### Update the Container Version

The Data API builder container works with desktop Docker or in a container service like Kubernetes. Every DAB version is securely hosted in the [Microsoft Container Registry](https://aka.ms/dab/registry).

1. **To pull the most recent version automatically**

   `docker pull mcr.microsoft.com/azure-databases/data-api-builder:latest`

2. **To pull a specific version**

   `docker pull mcr.microsoft.com/azure-databases/data-api-builder:0.10.2`

## What's New in Version 0.10

Our focus shifts to stability as we approach General Availability. While not all efforts in code quality and engine stability are detailed in this article, this list highlights significant updates.

### In-memory Caching

Version 0.10 introduces in-memory caching for REST and GraphQL endpoints. This feature, designed for internal caching, lays the groundwork for future distributed caching. In-memory caching reduces database load from repetitive queries.

#### Caching Scenarios

- **Reducing database load**: Cache stores results of expensive queries, eliminating the need for repeated database calls.
- **Improving API scalability**: Caching supports more frequent API calls without increasing database requests, significantly scaling your API's capabilities.

#### Configuration Changes

Caching settings are available in the `runtime` section and for each entity, offering granular control.

**Runtime settings**:

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

- Caching is disabled by default.
- The default time-to-live (TTL) is 5 seconds.

**Entity settings**:

```json
{
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
}
```

### Configuration Validation in CLI

The CLI now supports `dab validate` for checking configuration files for errors or inconsistencies, enhancing the development workflow.

#### Validation Steps

1. **Schema validation**
2. **Config properties validation**
3. **Config permission validation**
4. **Database connection validation**
5. **Entities Metadata validation**

### Preview Features

- Initial DWSQL support. [#1864](https://github.com/Azure/data-api-builder/pull/1864)
- Support for multiple data sources. [#1709](https://github.com/Azure/data-api-builder/pull/1709)

## Recent Releases

Review these release pages for a comprehensive list of all the changes and improvements:

- February 6 - Version 0.10.23
  - [0.10.23: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v0.10.23)
- January 31 - Version 0.10.21
  - [0.10.21: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v0.10.21)
- December 7 - Version 0.10.11
  - [0.10.11-rc: Data API builder for Azure Databases](https://github.com/Azure/data-api-builder/releases/tag/v0.10.11-rc)
