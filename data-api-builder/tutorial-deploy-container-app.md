---
title: |
  Tutorial: Deploy to Azure Container Apps with Azure CLI
description: This tutorial walks through the steps necessary to deploy an API solution for Azure SQL to Azure Container Apps using the Azure CLI.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: tutorial
ms.date: 04/29/2024
#Customer Intent: As a developer, I want to deploy to Azure, so that I can integrate Data API builder with my other cloud services.
---

# Tutorial: Deploy Data API builder to Azure Container Apps with Azure CLI

Data API builder can be quickly deployed to Azure services like Azure Container Apps as part of your application stack.

In this tutorial, you:

> [!div class="checklist"]
>
> - Create a managed identity with role-based access control permissions
> - Deploy Azure SQL with the sample AdventureWorksLT dataset
> - Stage an Azure Storage account with the configuration file
> - Deploy Azure Container App with the Data API builder container image
> - Deploy Azure Container App with a sample application
>

[!INCLUDE[Azure Subscription Trial](includes/azure-subscription-trial.md)]

## Prerequisites

- Azure subscription

[!INCLUDE[Azure Cloud Shell](includes/azure-cloud-shell.md)]

## Create a managed identity

TODO

1. TODO

    ```azurecli-interactive
    az group create --name "<resource-group>" --location "<location>"
    ```

1. TODO

    ```azurecli-interactive
    RESOURCE_GROUP_ID=$(az group show --name "<resource-group>" --query "id" --output tsv)
    ```

1. TODO

    ```azurecli-interactive
    az identity create --name "<resource-group>" -identity --resource-group "<resource-group>"
    ```

1. TODO

    ```azurecli-interactive
    UA_PRINCIPAL_ID=$(az identity show --name "<resource-group>" -identity --resource-group "<resource-group>" --query "principalId" --output tsv)
    ```

1. TODO

    ```azurecli-interactive
    UA_NAME=$(az identity show --name "<resource-group>" -identity --resource-group "<resource-group>" --query "name" --output tsv)
    ```

1. TODO

    ```azurecli-interactive
    # Storage Blob Data Owner
    
    az role assignment create --assignee-object-id $UA_PRINCIPAL_ID --assignee-principal-type "ServicePrincipal" --role "b7e6dc6d-f1e8-4753-8033-0f276bb0955b" --scope
    ```

1. TODO

    ```azurecli-interactive
    # Storage File Data SMB Share Reader

    az role assignment create --assignee-object-id $UA_PRINCIPAL_ID --assignee-principal-type "ServicePrincipal" --role "aba4ae5f-2193-4029-9191-0cb91df5e314" --scope $STORAGE_RESOURCE_ID
    ```

## Deploy an Azure SQL database

First, deploy a new server and database in the Azure SQL service. The database   the **AdventureWorksLT** sample dataset.

1. Create a new Azure SQL **server** resource using `az sql server create`.

    ```azurecli-interactive
    az sql server create --resource-group "<resource-group>" --name "<resource-group>" -srvr --enable-ad-only-auth --external-admin-principal-type "User" --external-admin-name $UA_NAME --external-admin-sid $UA_PRINCIPAL_ID
    ```

1. TODO

    ```azurecli-interactive
    az sql db create --resource-group "<resource-group>" --server "<resource-group>" -srvr --name adventureworks --sample-name "AdventureWorksLT"
    ```

## Create an Azure Storage file share

TODO

1. TODO

    ```azurecli-interactive
    az storage account create --resource-group "<resource-group>" --name "<unique-storage-account-name>"
    ```

1. TODO

    ```azurecli-interactive
    az storage share create --account-name "<unique-storage-account-name>" --name dab-config
    ```

1. TODO

    ```azurecli-interactive
    dotnet tool install --global TODO
    ```

1. TODO

    ```azurecli-interactive
    dab init TODO
    ```

1. TODO

    ```azurecli-interactive
    dab add TODO
    ```

1. TODO

    ```azurecli-interactive
    az storage file upload --account-name "<unique-storage-account-name>" --share-name dab-config --source dab-config.json --path dab-config.json
    ```

## Deploy Azure Container App DAB container

TODO

1. TODO

    ```azurecli-interactive
    az container create
    ```

1. TODO

    ```azurecli-interactive
    TODO
    ```

1. TODO

    ```azurecli-interactive
    TODO
    ```

1. Navigate to `TODO` and test the API.

## Deploy Azure Container App web application

TODO

1. TODO

    ```azurecli-interactive
    TODO
    ```

1. TODO

    ```azurecli-interactive
    TODO
    ```

1. TODO

    ```azurecli-interactive
    TODO
    ```

## Next step

> [!div class="nextstepaction"]
> [Use Application Insights with Data API builder](how-to-use-application-insights.md)
