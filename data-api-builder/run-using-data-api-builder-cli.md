---
title: Run using Data API builder CLI
description: This document assists in running Data API builder CLI.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: run-using-data-api-builder-cli
ms.date: 04/06/2023
---

# Running Data API builder for Azure Databases using CLI

The easiest option that doesn't require cloning the repo is to use the `dab` [CLI tool](./data-api-builder-cli.md) that you can find in the `Microsoft.DataApiBuilder` NuGet package [here.](https://www.nuget.org/packages/Microsoft.DataApiBuilder)

## Install `dab` CLI

You can install the latest `dab` CLI using [.NET tools](/dotnet/core/tools/global-tools):

```bash
dotnet tool install --global  Microsoft.DataApiBuilder
```

> [!CAUTION]
> If you are running on Linux or MacOS, you may need to add .NET global tools to your PATH to call `dab` directly. Once installed run: `export PATH=$PATH:~/.dotnet/tools`

## Update `dab` CLI to latest version

If you already have an older version of `dab` CLI installed, update the tool using:

```bash
dotnet tool update -g Microsoft.DataApiBuilder --version <version_number>
```

### Validate the Install

Installing the package makes the `dab` command available on your development machine. To validate your installation, you can check the installed version with:

```bash
dab --version
```

## Run engine using `dab` CLI

To start the Data API builder engine, use the `start` action if you have the configuration file `dab-config.json` as described [here](./configuration-file.md) in the current directory:

```bash
dab start
```

For providing a custom configuration file, you can use the option `-c` or `--config` followed by the config file name.

```bash
dab start -c my-custom-dab-config.json
```

You can also start the engine with a custom log level. This alters the amount of logging that is provided during both startup and runtime of the service. When you start the service with a custom log level, use the `start` action with `--verbose` or `--LogLevel <0-6>`. `--verbose` starts the service with a log level of `informational` whereas `--LogLevel <0-6>` represents one of the following log levels.
![image](https://user-images.githubusercontent.com/93220300/216731511-ea420ee8-3b52-4e1b-a052-87943b135be1.png)

```bash
dab start --verbose
```

```bash
dab start --LogLevel 0
```

This logs the information as follows:

- At startup
  - what configuration file is being used (Level: Information)

- During the (in-memory schema generation)
  - what entities have been loaded (names, paths) (Level: Information)
  - automatically identified relationships columns (Level: Debug)
  - automatically identified primary keys, column types etc. (Level: Debug)

- Whenever a request is received
  - if request has been authenticated or not and which role has been assigned (Level: Debug)
  - the generated queries sent to the database (Level: Debug)

- Internal behavior
  - view which queries are generated (any query, not just those necessarily related to a request) and sent to the database (Level: Debug)

## Get started using `dab` CLI

To quickly get started using the CLI, make sure you have read the [Getting Started](./get-started/get-started-with-data-api-builder.md) guide to become familiar with basic Data API builder concepts, and then use [`dab` CLI](./data-api-builder-cli.md) to learn how to use the CLI tool.

## Uninstall `dab` CLI

For any reason, if you need to uninstall `dab` CLI, simply do:

```bash
dotnet tool uninstall -g Microsoft.DataApiBuilder
```
