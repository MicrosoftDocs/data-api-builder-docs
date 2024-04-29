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

Data API builder can be quickly deployed to Azure services like Azure Container Apps as part of your application stack. In this tutorial, you deploy Data API builder to Azure Container Apps with a backing Azure SQL database and authentication using managed identities.

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

## Assign managed identity permissions

First, create a managed identity and assign it permissions to read data from Azure Storage.

1. Create a variable named `UA_NAME` with the resource group name. For this tutorial, we recommend `msdocs-dab-aca`.

    ```azurecli-interactive
    RESOURCE_GROUP_NAME="msdocs-dab-aca"
    ```

1. Create a new resource group using [`az group create`](/cli/azure/group#az-group-create).

    ```azurecli-interactive
    az group create \
      --name $RESOURCE_GROUP_NAME \
      --location "westus" \
      --tag "msdocs-dab-tutorial"
    ```

1. Create a variable named `RESOURCE_GROUP_ID` to store the identifier of the resource group. Get the identifier using [`az group show`](/cli/azure/group#az-group-show). You will use this variable multiple times in this tutorial.

    ```azurecli-interactive
    RESOURCE_GROUP_ID=$( \
      az group show \
        --name $RESOURCE_GROUP_NAME \
        --query "id" \
        --output "tsv" \
    )
    ```

    > [!TIP]
    > You can always check the output of this command using `echo $RESOURCE_GROUP_ID`.

1. Create a variable named `MANAGED_IDENTITY_NAME` with a uniquely generated name for your user-assigned manager identity. You will also use this variable multiple times in this tutorial.

    ```azurecli-interactive
    MANAGED_IDENTITY_NAME="ua-$RANDOM"
    ```

1. Use [`az identity create`](/cli/azure/identity#az-identity-create) to create a new managed identity.

    ```azurecli-interactive
    az identity create \
      --name $MANAGED_IDENTITY_NAME \
      --resource-group $RESOURCE_GROUP_NAME
    ```

1. Get the **principal identifier** of the managed identity using [`az identity show`](/cli/azure/identity#az-identity-show) and store the value in a variable named `MANAGED_IDENTITY_PRINCIPAL_ID`.

    ```azurecli-interactive
    MANAGED_IDENTITY_PRINCIPAL_ID=$( \
      az identity show \
        --name $MANAGED_IDENTITY_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --query "principalId" \
        --output "tsv" \
    )
    ```

    > [!TIP]
    > You can always check the output of this command using `echo $MANAGED_IDENTITY_PRINCIPAL_ID`.

1. Get the **resource identifier** of the managed identity using [`az identity show`](/cli/azure/identity#az-identity-show) and store the value in a variable named `MANAGED_IDENTITY_RESOURCE_ID`.

    ```azurecli-interactive
    MANAGED_IDENTITY_RESOURCE_ID=$( \
      az identity show \
        --name $MANAGED_IDENTITY_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --query "id" \
        --output "tsv" \
    )
    ```

    > [!TIP]
    > You can always check the output of this command using `echo $MANAGED_IDENTITY_RESOURCE_ID`.

1. Use [`az role assignment create`](/cli/azure/role/assignment#az-role-assignment-create) to assign the **Storage Blob Data Owner** role to your account so you can upload blobs to Azure Storage.

    ```azurecli-interactive
    # Storage Blob Data Owner
    
    az role assignment create \
      --assignee $( \
        az ad signed-in-user show \
          --query "id" \
          --output "tsv" \
      ) \
      --role "b7e6dc6d-f1e8-4753-8033-0f276bb0955b" \
      --scope $RESOURCE_GROUP_ID
    ```

## Deploy an Azure SQL database

Now, deploy a new server and database in the Azure SQL service. The database will use the **AdventureWorksLT** sample dataset.

1. Create a variable named `SQL_SERVER_NAME` with a uniquely generated name for your Azure SQL server instance. You will use this variable later in this section.

    ```azurecli-interactive
    SQL_SERVER_NAME="srvr-$RANDOM"
    ```

1. Create a new Azure SQL **server** resource using [`az sql server create`](/cli/azure/sql/server#az-sql-server-create). Configure the managed identity as the admin of this server.

    ```azurecli-interactive
    az sql server create \
      --resource-group $RESOURCE_GROUP_NAME \
      --name $SQL_SERVER_NAME \
      --enable-ad-only-auth \
      --external-admin-principal-type "User" \
      --external-admin-name $MANAGED_IDENTITY_NAME \
      --external-admin-sid $MANAGED_IDENTITY_PRINCIPAL_ID
    ```

1. Use [`az sql db create`](/cli/azure/sql/db#az-sql-db-create) to create a **database** within the Azure SQL server named `adventureworks`. Configure the database to use the `AdventureWorksLT` sample data.

    ```azurecli-interactive
    az sql db create \
      --resource-group $RESOURCE_GROUP_NAME \
      --server $SQL_SERVER_NAME \
      --name "adventureworks" \
      --sample-name "AdventureWorksLT"
    ```

1. Get the **fully-qualified domain name** of the Azure SQL server using [`az sql server show`](/cli/azure/sql/server#az-sql-server-show) and store the value in a variable named `SQL_SERVER_ENDPOINT`.

    ```azurecli-interactive
    SQL_SERVER_ENDPOINT=$( \
      az sql server show \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $SQL_SERVER_NAME \
        --query "fullyQualifiedDomainName" \
        --output "tsv" \
    )
    ```

    > [!TIP]
    > You can always check the output of this command using `echo $SQL_SERVER_ENDPOINT`.

1. Create a variable named `SQL_CONNECTION_STRING` with the connection string for the `adventureworks` database in your Azure SQL server instance. You will use this variable later in this tutorial.

    ```azurecli-interactive
    SQL_CONNECTION_STRING="Server=$SQL_SERVER_ENDPOINT;Database=adventureworks;Encrypt=true;Authentication=Active Directory Default;"
    ```

## Create an Azure Storage file share

Next, TODO

1. Create a variable named `STORAGE_NAME` with a uniquely generated name for your Azure Storage instance. You will use this variable later in this section.

    ```azurecli-interactive
    STORAGE_NAME="stor$RANDOM"
    ```

1. TODO

    ```azurecli-interactive
    az storage account create \
      --resource-group $RESOURCE_GROUP_NAME \
      --name $STORAGE_NAME \
      --location "westus" \
      --allow-shared-key-access false \
      --allow-blob-public-access true
    ```

1. TODO

    ```azurecli-interactive
    az storage container create \
      --account-name $STORAGE_NAME \
      --name "dab-config" \
      --public-access "blob" \
      --auth-mode "login"
    ```

1. TODO

    ```azurecli-interactive
    dotnet tool install --global Microsoft.DataApiBuilder
    ```

1. TODO

    ```azurecli-interactive
    dab init \
      --type "mssql"
      --connection-string $SQL_CONNECTION_STRING
    ```

1. TODO

    ```azurecli-interactive
    dab add Product --source "SalesLT.Product" --permissions "anonymous:read"
    ```

1. TODO

    ```azurecli-interactive
    az storage blob upload \
      --account-name $STORAGE_NAME \
      --container-name "dab-config" \
      --file "dab-config.json" \
      --auth-mode "login"
    ```

1. TODO

    ```azurecli-interactive
    CONFIG_BLOB_URL=$( \
      az storage blob url \
        --account-name $STORAGE_NAME \
        --container-name "dab-config" \
        --name "dab-config.json" \
        --auth-mode "login" \
        --output "tsv" \
    )
    ```

    > [!TIP]
    > You can always check the output of this command using `echo $CONFIG_BLOB_URL`.

## Deploy Azure Container App DAB container

Finally, TODO

1. Create variables named `API_CONTAINER_NAME` and `CONTAINER_ENV_NAME` with uniquely generated names for your Azure Container Apps instance. You will use these variables later in this section.

    ```azurecli-interactive
    API_CONTAINER_NAME="api-$RANDOM"
    CONTAINER_ENV_NAME="env-$RANDOM"
    ```

1. TODO

    ```azurecli-interactive
    az containerapp env create \ 
      --resource-group $RESOURCE_GROUP_NAME \
      --name $CONTAINER_ENV_NAME \
      --location "westus"
    ```

1. TODO

    ```azurecli-interactive
    az containerapp create \ 
      --resource-group $RESOURCE_GROUP_NAME \
      --environment $CONTAINER_ENV_NAME \
      --name $API_CONTAINER_NAME \
      --image "mcr.microsoft.com/azure-databases/data-api-builder:latest" \
      --ingress "external" \
      --target-port "5000" \
      --user-assigned $MANAGED_IDENTITY_RESOURCE_ID \
      --command "curl $CONFIG_BLOB_URL > /App/dab-config.json"
    ```

1. TODO

    ```azurecli-interactive
    TODO
    ```

1. Navigate to `TODO` and test the API.

## Clean up resources

When you no longer need the sample application or resources, remove the corresponding deployment and all resources.

```azurecli-interactive
az group delete \
  --name $RESOURCE_GROUP_NAME
```

## Next step

> [!div class="nextstepaction"]
> [Use Application Insights with Data API builder](how-to-use-application-insights.md)
