---
title: |
  Tutorial: Deploy to Azure Container Apps with Azure CLI
description: This tutorial walks through the steps necessary to deploy an API solution for Azure SQL to Azure Container Apps using the Azure CLI.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: tutorial
ms.date: 04/30/2024
#Customer Intent: As a developer, I want to deploy to Azure, so that I can integrate Data API builder with my other cloud services.
---

# Tutorial: Deploy Data API builder to Azure Container Apps with Azure CLI

Data API builder can be quickly deployed to Azure services like Azure Container Apps as part of your application stack. In this tutorial, you use the Azure CLI to automate common tasks when deploying Data API builder to Azure. First, you build a container image with Data API builder and store it in Azure Container Registry. You then deploy the container image to Azure Container Apps with a backing Azure SQL database. The entire tutorial authenticates to each component using managed identities.

In this tutorial, you:

> [!div class="checklist"]
>
> - Create a managed identity with role-based access control permissions
> - Deploy Azure SQL with the sample AdventureWorksLT dataset
> - Stage the container image in Azure Container Registry
> - Deploy Azure Container App with the Data API builder container image
>

[!INCLUDE[Azure Subscription Trial](includes/azure-subscription-trial.md)]

## Prerequisites

- Azure subscription

[!INCLUDE[Azure Cloud Shell](includes/azure-cloud-shell.md)]

## Assign managed identity permissions

First, create a managed identity and assign it permissions to read data from Azure Storage.

1. Create a variable named `RESOURCE_GROUP_NAME` with the resource group name. For this tutorial, we recommend `msdocs-dab-aca`.

    ```azurecli-interactive
    RESOURCE_GROUP_NAME="msdocs-dab-aca"
    ```

1. Create a new resource group using [`az group create`](/cli/azure/group#az-group-create).

    ```azurecli-interactive
    az group create \
      --name $RESOURCE_GROUP_NAME \
      --location "<azure-region>" \
      --tag "source=msdocs-dab-tutorial"
    ```

1. Create a variable named `RESOURCE_GROUP_ID` to store the identifier of the resource group. Get the identifier using [`az group show`](/cli/azure/group#az-group-show). You use this variable multiple times in this tutorial.

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

1. Create a variable named `MANAGED_IDENTITY_NAME` with a uniquely generated name for your user-assigned manager identity. You also use this variable multiple times in this tutorial.

    ```azurecli-interactive
    MANAGED_IDENTITY_NAME="ua-$RANDOM"
    ```

1. Use [`az identity create`](/cli/azure/identity#az-identity-create) to create a new managed identity.

    ```azurecli-interactive
    az identity create \
      --name $MANAGED_IDENTITY_NAME \
      --resource-group $RESOURCE_GROUP_NAME
    ```

1. Get the **principal**, **resource**, and **client** identifiers of the managed identity using [`az identity show`](/cli/azure/identity#az-identity-show) and store the values in variables named `MANAGED_IDENTITY_PRINCIPAL_ID`, `MANAGED_IDENTITY_RESOURCE_ID`, and `MANAGED_IDENTITY_RESOURCE_ID`.

    ```azurecli-interactive
    MANAGED_IDENTITY_PRINCIPAL_ID=$( \
      az identity show \
        --name $MANAGED_IDENTITY_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --query "principalId" \
        --output "tsv" \
    )

    MANAGED_IDENTITY_RESOURCE_ID=$( \
      az identity show \
        --name $MANAGED_IDENTITY_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --query "id" \
        --output "tsv" \
    )

    MANAGED_IDENTITY_CLIENT_ID=$( \
      az identity show \
        --name $MANAGED_IDENTITY_NAME \
        --resource-group $RESOURCE_GROUP_NAME \
        --query "clientId" \
        --output "tsv" \
    )
    ```

    > [!TIP]
    > You can always check the output of this command using `echo $MANAGED_IDENTITY_PRINCIPAL_ID`, `echo $MANAGED_IDENTITY_RESOURCE_ID`, or `echo $MANAGED_IDENTITY_CLIENT_ID`.

1. Use [`az role assignment create`](/cli/azure/role/assignment#az-role-assignment-create) to assign the [**AcrPush**](/azure/role-based-access-control/built-in-roles/containers#acrpush) role to your account so you can push containers to Azure Container Registry.

    ```azurecli-interactive
    CURRENT_USER_PRINCIPAL_ID=$( \
      az ad signed-in-user show \
        --query "id" \
        --output "tsv" \
    )

    # AcrPush
    az role assignment create \
      --assignee $CURRENT_USER_PRINCIPAL_ID \
      --role "8311e382-0749-4cb8-b61a-304f252e45ec" \
      --scope $RESOURCE_GROUP_ID
    ```

1. Assign the [**AcrPull**](/azure/role-based-access-control/built-in-roles/containers#acrpull) role to your managed identity using [`az role assignment create`](/cli/azure/role/assignment#az-role-assignment-create) again. This assignment allows the managed identity to pull container images from Azure Container Registry. The managed identity is eventually assigned to an Azure Container Apps instance.

    ```azurecli-interactive
    # AcrPull    
    az role assignment create \
      --assignee $MANAGED_IDENTITY_PRINCIPAL_ID \
      --role "7f951dda-4ed3-4680-a7ca-43fe172d538d" \
      --scope $RESOURCE_GROUP_ID
    ```

## Deploy an Azure SQL database

Now, deploy a new server and database in the Azure SQL service. The database uses the **AdventureWorksLT** sample dataset.

1. Create a variable named `SQL_SERVER_NAME` with a uniquely generated name for your Azure SQL server instance. You use this variable later in this section.

    ```azurecli-interactive
    SQL_SERVER_NAME="srvr-$RANDOM"
    ```

1. Create a new Azure SQL **server** resource using [`az sql server create`](/cli/azure/sql/server#az-sql-server-create). Configure the managed identity as the admin of this server.

    ```azurecli-interactive
    az sql server create \
      --resource-group $RESOURCE_GROUP_NAME \
      --name $SQL_SERVER_NAME \
      --location "<azure-region>" \
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

1. Create a variable named `SQL_CONNECTION_STRING` with the connection string for the `adventureworks` database in your Azure SQL server instance. Construct the connection string with the **fully-qualified domain name** of the server using [`az sql server show`](/cli/azure/sql/server#az-sql-server-show). You use this variable later in this tutorial.

    ```azurecli-interactive
    SQL_SERVER_ENDPOINT=$( \
      az sql server show \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $SQL_SERVER_NAME \
        --query "fullyQualifiedDomainName" \
        --output "tsv" \
    )
    
    SQL_CONNECTION_STRING="Server=$SQL_SERVER_ENDPOINT;Database=adventureworks;Encrypt=true;Authentication=Active Directory Default;"
    ```

    > [!TIP]
    > You can always check the output of this command using `echo $SQL_CONNECTION_STRING`.

## Build image in Azure Container Registry

Next, TODO

1. Create a variable named `CONTAINER_REGISTRY_NAME` with a uniquely generated name for your Azure Container Registry instance. You use this variable later in this section.

    ```azurecli-interactive
    CONTAINER_REGISTRY_NAME="reg$RANDOM"
    ```

1. TODO

    ```azurecli-interactive
    az acr create \
      --resource-group $RESOURCE_GROUP_NAME \
      --name $CONTAINER_REGISTRY_NAME \
      --sku "Standard" \
      --location "<azure-region>" \
      --admin-enabled false
    ```

1. TODO

    ```Dockerfile
    FROM mcr.microsoft.com/dotnet/sdk:6.0-cbl-mariner2.0 AS build
    
    WORKDIR /config
    
    RUN dotnet new tool-manifest
    
    RUN dotnet tool install Microsoft.DataApiBuilder
    
    RUN dotnet tool run dab -- init --database-type "mssql" --connection-string "@env('DATABASE_CONNECTION_STRING')"
    
    RUN dotnet tool run dab -- add Product --source "SalesLT.Product" --permissions "anonymous:read"
    
    FROM mcr.microsoft.com/azure-databases/data-api-builder
    
    COPY --from=build /config /App
    ```

1. TODO

    ```azurecli-interactive
    az acr build \
      --registry $CONTAINER_REGISTRY_NAME \
      --image adventureworkslt-dab:latest \
      --image adventureworkslt-dab:{{.Run.ID}} \
      --file Dockerfile \
      .
    ```

1. TODO

    ```azurecli-interactive
    CONTAINER_REGISTRY_LOGIN_SERVER=$( \
      az acr show \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $CONTAINER_REGISTRY_NAME \
        --query "loginServer" \
        --output "tsv" \
    )
    ```

    > [!TIP]
    > You can always check the output of this command using `echo $CONTAINER_REGISTRY_LOGIN_SERVER`.

## Deploy Azure Container App DAB container

Finally, TODO

1. Create variables named `API_CONTAINER_NAME` and `CONTAINER_ENV_NAME` with uniquely generated names for your Azure Container Apps instance. You use these variables later in this section.

    ```azurecli-interactive
    API_CONTAINER_NAME="api-$RANDOM"
    CONTAINER_ENV_NAME="env-$RANDOM"
    ```

1. TODO

    ```azurecli-interactive
    az containerapp env create \ 
      --resource-group $RESOURCE_GROUP_NAME \
      --name $CONTAINER_ENV_NAME \
      --logs-destination none \
      --location "<azure-region>"
    ```

1. TODO

    ```azurecli-interactive
    az containerapp create \ 
      --resource-group $RESOURCE_GROUP_NAME \
      --environment $CONTAINER_ENV_NAME \
      --name $API_CONTAINER_NAME \
      --image "$CONTAINER_REGISTRY_LOGIN_SERVER/adventureworkslt-dab:latest" \
      --ingress "external" \
      --target-port "5000" \
      --user-assigned $MANAGED_IDENTITY_RESOURCE_ID \
      --registry-server $CONTAINER_REGISTRY_LOGIN_SERVER \
      --registry-identity $MANAGED_IDENTITY_RESOURCE_ID \
      --secrets conn-string="$SQL_CONNECTION_STRING" identity-client-id="$MANAGED_IDENTITY_CLIENT_ID" \
      --env-vars DATABASE_CONNECTION_STRING=secretref:conn-string AZURE_MANAGED_IDENTITY_CLIENT_ID=secretref:identity-client-id
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
