---
title: Running Data API builder from source code
description: This document contains details about running Data API builder from source code.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: running-dab-from-source-code
ms.date: 04/06/2023
---

# Running Data API builder for Azure Databases from source code

> [!NOTE]
> Familiarity with Git commands and tooling is assumed throughout the tutorial. Make sure `git` is installed in your machine.

## Clone the Data API builder for Azure Databases engine

Clone the repository locally:

```shell
git clone https://github.com/Azure/data-api-builder.git
```

Check out the branch associated with the latest [release](https://github.com/Azure/data-api-builder/releases). For example:

```shell
cd .\data-api-builder\
git checkout release/Jan2023
```

Create a configuration file (`dab-config.json`) manually or using the [DAB CLI](./data-api-builder-cli.md) tool. If you want to create the file manually, you can use the [empty template](./samples/basic-empty-dab-config.json) as a starting point.

Make sure to add some entities to the configuration file (you can follow the [Getting Started](./get-started/get-started-with-data-api-builder.md) guide if you want) and then start the Data API builder engine.

## Run the Data API builder for Azure Databases engine

Make sure you have [.NET 6.0 SDK](https://dotnet.microsoft.com/download/dotnet/6.0) installed. Clone the repository and then execute, from the root folder of the repository:

```sh
dotnet run --project ./src/Service
```

The Data API builder engine will try to load the configuration from the `dab-config.json` file in the same folder, if present.

If there is no `dab-config.json` the engine will start anyway but it will not be able to serve anything.

You may use the optional `--ConfigFileName` option to specify which configuration file will be used:

```sh
dotnet run --project ./src/Service  --ConfigFileName ../../samples/my-sample-dab-config.json
```
