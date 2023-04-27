---
title: Running Data API builder in Azure
description: This document contains details about running Data API builder in Azure.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: running-data-api-builder-in-azure
ms.date: 04/06/2023
---

# Running Data API builder in Azure

Data API builder can be run in Azure in two different ways: using Azure Static Web Apps or using any container service like Azure Container Instances, Azure App Service, Azure Container Apps, etc.

## Use Azure Static Web Apps

When running Data API builder in Azure Static Web Apps, you don't have to worry about the infrastructure since it's managed by Azure. When running Data API builder in Azure Container Instances or Azure App Service, you have to manage the infrastructure yourself.

To learn how to use Data API builder with Azure Static Web Apps, refer to the Azure Static Web Apps documentation: [Connecting to a database with Azure Static Web Apps](/azure/static-web-apps/database-overview).

## Use Azure Container Instance

If you prefer to manage the infrastructure yourself, you can deploy the Data API builder container in Azure. Data API builder image is available on the [Microsoft Container Registry](https://mcr.microsoft.com/product/azure-databases/data-api-builder/about)

To run Data API builder in Azure Container Instances, you need to

- Create a resource group
- Create a storage account, with File Share enabled
- Upload the `dab-config.json` file to the storage account
- Create the Azure Container Instance using the image from the Microsoft Container Registry, and mount the storage account file share, so that it can be accessed by Data API builder

A sample shell script that can be run on Linux (using the [Cloud Shell](/azure/cloud-shell/overview) if you don't have a Linux machine or WSL installed) is available in [`/samples/azure`](https://github.com/Azure/data-api-builder/tree/main/samples/azure) folder.

On first run, the script creates an `.env` file that you have to fill out with the correct values for your environment.

- `RESOURCE_GROUP`: name of the resource group you're using (for example: `my-dab-rg`)
- `STORAGE_ACCOUNT`: the name for the Storage Account you want to create (for example: `dabstorage`)
- `LOCATION`: the region where you want to create the resources (for example: `westus2`)
- `CONTAINER_INSTANCE_NAME`: the name of the Container Instance you want to create (for example: `dab-backend`)
- `DAB_CONFIG_FILE`: the configuration file you want to use (for example: `./my-dab-config.json`).

> [!NOTE]
> Note that the file must be in the same folder where the `./azure-deploy.sh` script is located. You can find `azure-deploy.sh` [here](https://github.com/Azure/data-api-builder/blob/main/samples/azure/azure-deploy.sh).

After the script has finished running, it will return the public container IP address. Use your favorite REST or GraphQL client to access the Data API builder exposed endpoints as configured in the configuration file you provided.

## Use Azure Container Apps

You can also deploy the Data API builder container in Azure for a more hands-on approach to infrastructure management. Data API builder image is available on the [Microsoft Container Registry](https://mcr.microsoft.com/product/azure-databases/data-api-builder/about).

To run Data API builder in Azure Container Apps, you need to

- Create a resource group
- Create a storage account, with File Share enabled
- Upload the `dab-config.json` file to the storage account
- Create the Azure Container Apps environment and mount the storage account file share so that it can be accessed by the containers running in the environment.
- Create the Azure Container Apps application, using the image from the Microsoft Container Registry and mounting the storage account file share so that it can be accessed by Data API builder.

A sample shell script that can be run on Linux (using the [Cloud Shell](/azure/cloud-shell/overview) if you don't have a Linux machine or WSL installed) is available in [`/samples/azure`](https://github.com/Azure/data-api-builder/tree/main/samples/azure) folder.

On first run, the script creates an `.env` file that you have to fill out with the correct values for your environment.

- `RESOURCE_GROUP`: name of the resource group you're using (for example: `my-dab-rg`)
- `STORAGE_ACCOUNT`: the name for the Storage Account you want to create (for example: `dabstorage`)
- `LOCATION`: the region where you want to create the resources (for example: `westus2`)
- `LOG_ANALYTICS_WORKSPACE`: the name of the Log Analytics Workspace you want to create (for example: `dablogging`)
- `CONTAINERAPPS_ENVIRONMENT`: the name of the Container Apps environment you want to create (for example: `dm-dab-aca-env`)
- `CONTAINERAPPS_APP_NAME`: the name of the Container Apps application you want to create (for example: `dm-dab-aca-app`)
- `DAB_CONFIG_FILE`: the configuration file you want to use (for example: `./my-dab-config.json`).

> [Note]
> The file must be in the same folder where the `./azure-container-apps-deploy.sh` script is located. You can find `azure-container-app-deploy.sh` [here](https://github.com/Azure/data-api-builder/blob/main/samples/azure/azure-container-apps-deploy.sh).

After the script has finished running, it will return the FQDN of Azure Container Apps. Use your favorite REST or GraphQL client to access the Data API builder exposed endpoints as configured in the configuration file you provided.
