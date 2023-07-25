---
title: Run Data API builder using a container
description: This document contains details about running Data API builder using a container.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: run-dab-using-container
ms.date: 04/06/2023
---

# Running Data API builder for Azure Databases using a container

## Docker run

With Docker, you can run Data API builder using a container from the Microsoft Container Registry `mcr.microsoft.com/azure-databases/data-api-builder`:

```shell
docker run -it -v <configuration-file>:/App/Configs/<configuration-file> -p 5000:5000 mcr.microsoft.com/azure-databases/data-api-builder:latest --ConfigFileName Configs/<configuration-file>
```

### Docker run example

The proceeding command makes the following assumptions:

- You are running the `docker` command from: `C:\data-api-builder`.
- Your configuration file `my-sample-dab-config.json` is in a folder named `configs`.
- You want to use the latest release which can be identified from the [releases page](https://github.com/Azure/data-api-builder/releases).

```shell
docker run -it -v "C:\data-api-builder\config:/App/configs" -p 5000:5000 mcr.microsoft.com/azure-databases/data-api-builder:latest --ConfigFileName ./configs/my-sample-dab-config.json
```

> [!TIP]
> When developing locally, your container may fail to connect to a locally deployed database instance. In that case, you may need to update you config file's connection string server reference to `host.docker.internal`. For example: `Server=host.docker.internal\\<instancename>;`

## Docker compose

You may also use one of the provided 'docker-compose.yml' files to build your own container. The sample docker-compose files are available in the `docker` folder:

```shell
docker compose -f "./docker-compose.yml" up
```

When using your own Docker compose file, make sure you update your docker-compose file to point to the configuration file you want to use.