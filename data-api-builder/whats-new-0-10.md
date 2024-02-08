---
title: Release notes for Data API builder 0.9
description: Release notes for Data API builder 0.9 are available here.
author: yorek
ms.author: damauri
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 11/16/2023
---

# How to Upgrade to version 0.10

## Update the Developer CLI

The Data API Builder CLI is a tool that helps developers easily build their configuration files with fewer errors. Additionally, the CLI runs the DAB engine in the developer's local environment. The CLI is revised with every new Data API Builder release, including version 0.10. If the tool is not already installed, you can install it using the command `dotnet tool install microsoft.dataapibuilder -g`. If the tool is already installed, update it with the command `dotnet tool update microsoft.dataapibuilder -g`. This will result in a message similar to `Tool 'microsoft.dataapibuilder' was successfully updated from version '0.9.7' to version '0.10.23'.`

### Side-by-side CLI versions.

The `-g` switch in the `dotnet tool install` and `dotnet tool update` commands stands for "global". When you use `-g` with these commands, it means you are installing or updating the .NET Core CLI tool globally on your machine. This allows the tool to be accessed from any directory in your command line or terminal session. Without the `-g` switch, the tool would only be installed locally in the current directory or the directory specified, limiting its accessibility to that specific location.

## Update the Container Version

The Data API Builder container can be utilized by the desktop version of Docker or hosted in a container service like Kubernetes. Every version of DAB, including this one, is securely hosted in the [Microsoft Container Registry](https://aka.ms/dab/registry). To automatically pull the most recent version, use the command `docker pull mcr.microsoft.com/azure-databases/data-api-builder:latest`. To pull a specific version, use `docker pull mcr.microsoft.com/azure-databases/data-api-builder:0.10.*`.

# What's new in version 0.10

Note: As we approach General Availability (projected for early May 2024), our focus shifts to stability. Not included below is the significant effort to resolve issues and ensure code quality and engine stability. The following list should not be seen as an exhaustive representation of the engineering work undertaken across the codebase.

## In-memory Caching for REST and Graph QL

Version 0.10 introduces REST and Graph QL endpoint in-memory cache. We built this feature to deliver internal caching with all the hooks to add distributed 2nd level caching at a later date. 

Let's take a moment to discuss the benefits of caching in your Data API layer. Consider a call to your database against a large table or sophisticated view. Each call takes a certain amount of time. Identical subsequent calls take the same amount of time, even though the 

```json
{
  "runtime": {
    "cache": {
      "enabled": false,
      "ttl-seconds": 5
    }
  }
}
```

## Configuration Validation in CLI

TODO

## Complete list of fixes:

Take a look at [0.10 GitHub release page](https://github.com/Azure/data-api-builder/releases/tag/v0.10.23) for a comprehensive list of all the changes and improvements.

