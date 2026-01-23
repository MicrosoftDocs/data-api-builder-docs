---
title: |
  Tutorial: Deploy to Azure Container Apps with Azure CLI
description: This tutorial walks through the steps necessary to deploy an API solution for Azure SQL to Azure Container Apps using the Azure CLI.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: tutorial
ms.date: 06/11/2025
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

## Create container app

First, create an Azure Container Apps instance with a system-assigned managed identity. This identity is eventually granted role-based access control permissions to access Azure SQL and Azure Container Registry.

1. Create a universal `SUFFIX` variable to use for multiple resource names later in this tutorial.

    ```azurecli-interactive
    let SUFFIX=$RANDOM*$RANDOM
    ```

1. Create a `LOCATION` variable with an Azure region you selected to use in this tutorial.

    ```azurecli-interactive
    LOCATION="<azure-region>"
    ```

    > [!NOTE]
    > For example, if you want to deploy to the **West US** region, you would use this script.
    >
    > ```azurecli
    > LOCATION="westus"
    > ```
    >
    > For a list of supported regions for the current subscription, use [`az account list-locations`](/cli/azure/account#az-account-list-locations)
    >
    > ```azurecli
    > az account list-locations --query "[].{Name:displayName,Slug:name}" --output table
    > ```
    >
    > For more information, see [Azure regions](/azure/reliability/).

1. Create a variable named `RESOURCE_GROUP_NAME` with the resource group name. For this tutorial, we recommend `msdocs-dab-*`. You use this value multiple times in this tutorial.

    ```azurecli-interactive
    RESOURCE_GROUP_NAME="msdocs-dab$SUFFIX"    
    ```

1. Create a new resource group using [`az group create`](/cli/azure/group#az-group-create).

    ```azurecli-interactive
    az group create \
      --name $RESOURCE_GROUP_NAME \
      --location $LOCATION \
      --tag "source=msdocs-dab-tutorial"
    ```

1. Create variables named `API_CONTAINER_NAME` and `CONTAINER_ENV_NAME` with uniquely generated names for your Azure Container Apps instance. You use these variables throughout the tutorial.

    ```azurecli-interactive
    API_CONTAINER_NAME="api$SUFFIX"
    CONTAINER_ENV_NAME="env$SUFFIX"
    ```

1. Use [`az containerapp env create`](/cli/azure/containerapp/env#az-containerapp-env-create) to create a new Azure Container Apps environment.

    ```azurecli-interactive
    az containerapp env create \ 
      --resource-group $RESOURCE_GROUP_NAME \
      --name $CONTAINER_ENV_NAME \
      --logs-destination none \
      --location $LOCATION
    ```

1. Create a new container app using the `mcr.microsoft.com/azure-databases/data-api-builder` DAB container image and the [`az containerapp create`](/cli/azure/containerapp#az-containerapp-create) command. This container app runs successfully, but isn't connected to any database.

    ```azurecli-interactive
    az containerapp create \ 
      --resource-group $RESOURCE_GROUP_NAME \
      --environment $CONTAINER_ENV_NAME \
      --name $API_CONTAINER_NAME \
      --image "mcr.microsoft.com/azure-databases/data-api-builder" \
      --ingress "external" \
      --target-port "5000" \
      --system-assigned
    ```

1. Get the **principal** identifier of the managed identity using [`az identity show`](/cli/azure/identity#az-identity-show) and store the value in a variable named `MANAGED_IDENTITY_PRINCIPAL_ID`.

    ```azurecli-interactive
    MANAGED_IDENTITY_PRINCIPAL_ID=$( \
      az containerapp show \ 
        --resource-group $RESOURCE_GROUP_NAME \
        --name $API_CONTAINER_NAME \
        --query "identity.principalId" \
        --output "tsv" \
    )
    ```

    > [!TIP]
    > You can always check the output of this command.
    >
    > ```azurecli
    > echo $MANAGED_IDENTITY_PRINCIPAL_ID
    > ```
    >

## Assign permissions

Now, assign the system-assigned managed identity permissions to read data from Azure SQL and Azure Container Registry. Additionally, assign your identity permissions to write to Azure Container Registry.

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
    > You can always check the output of this command.
    >
    > ```azurecli
    > echo $RESOURCE_GROUP_ID
    > ```
    >

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

## Deploy database

Next, deploy a new server and database in the Azure SQL service. The database uses the **AdventureWorksLT** sample dataset.

1. Create a variable named `SQL_SERVER_NAME` with a uniquely generated name for your Azure SQL server instance. You use this variable later in this section.

    ```azurecli-interactive
    SQL_SERVER_NAME="srvr$SUFFIX"
    ```

1. Create a new Azure SQL **server** resource using [`az sql server create`](/cli/azure/sql/server#az-sql-server-create). Configure the managed identity as the admin of this server.

    ```azurecli-interactive
    az sql server create \
      --resource-group $RESOURCE_GROUP_NAME \
      --name $SQL_SERVER_NAME \
      --location $LOCATION \
      --enable-ad-only-auth \
      --external-admin-principal-type "User" \
      --external-admin-name $API_CONTAINER_NAME \
      --external-admin-sid $MANAGED_IDENTITY_PRINCIPAL_ID
    ```

1. Use [`az sql server firewall-rule create`](/cli/azure/sql/server/firewall-rule#az-sql-server-firewall-rule-create) to create a firewall rule to allow access from Azure services.

    ```azurecli-interactive
    az sql server firewall-rule create \
      --resource-group $RESOURCE_GROUP_NAME \
      --server $SQL_SERVER_NAME \
      --name "AllowAzure" \
      --start-ip-address "0.0.0.0" \
      --end-ip-address "0.0.0.0"
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
    > You can always check the output of this command.
    >
    > ```azurecli
    > echo $SQL_CONNECTION_STRING
    > ```
    >

## Build container image

Next, build a container image using a Dockerfile. Then deploy that container image to a newly created Azure Container Registry instance.

1. Create a variable named `CONTAINER_REGISTRY_NAME` with a uniquely generated name for your Azure Container Registry instance. You use this variable later in this section.

    ```azurecli-interactive
    CONTAINER_REGISTRY_NAME="reg$SUFFIX"
    ```

1. Create a new Azure Container Registry instance using [`az acr create`](/cli/azure/acr#az-acr-create).

    ```azurecli-interactive
    az acr create \
      --resource-group $RESOURCE_GROUP_NAME \
      --name $CONTAINER_REGISTRY_NAME \
      --sku "Standard" \
      --location $LOCATION \
      --admin-enabled false
    ```

1. Create a multi-stage Dockerfile named `Dockerfile`. In the file, implement these steps.

    - Use the `mcr.microsoft.com/dotnet/sdk` container image as the base of the build stage

    - Install the [DAB CLI](command-line/install.md).

    - Create a configuration file for a SQL database connection (`mssql`) using the `DATABASE_CONNECTION_STRING` environment variable as the connection string. 

    - Create an entity named `Product` mapped to the `SalesLT.Product` table.

    - Copy the configuration file to the final `mcr.microsoft.com/azure-databases/data-api-builder` container image.

    ```Dockerfile
    FROM mcr.microsoft.com/dotnet/sdk:8.0-cbl-mariner2.0 AS build
    
    WORKDIR /config
    
    RUN dotnet new tool-manifest
    
    RUN dotnet tool install Microsoft.DataApiBuilder
    
    RUN dotnet tool run dab -- init --database-type "mssql" --connection-string "@env('DATABASE_CONNECTION_STRING')"
    
    RUN dotnet tool run dab -- add Product --source "SalesLT.Product" --permissions "anonymous:read"
    
    FROM mcr.microsoft.com/azure-databases/data-api-builder
    
    COPY --from=build /config /App
    ```

1. Build the Dockerfile as an Azure Container Registry task using [`az acr build`](/cli/azure/acr#az-acr-build).

    ```azurecli-interactive
    az acr build \
      --registry $CONTAINER_REGISTRY_NAME \
      --image adventureworkslt-dab:latest \
      --image adventureworkslt-dab:{{.Run.ID}} \
      --file Dockerfile \
      .
    ```

1. Use [`az acr show`](/cli/azure/acr#az-acr-show) to get the endpoint for the container registry and store it in a variable named `CONTAINER_REGISTRY_LOGIN_SERVER`.

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
    > You can always check the output of this command.
    >
    > ```azurecli
    > echo $CONTAINER_REGISTRY_LOGIN_SERVER
    > ```
    >

## Deploy container image

Finally, update the Azure Container App with the new custom container image and credentials. Test the running application to validate its connectivity to the database.

1. Configure the container app to use the container registry using [`az containerapp registry set`](/cli/azure/containerapp/registry#az-containerapp-registry-set).

    ```azurecli-interactive
    az containerapp registry set \
      --resource-group $RESOURCE_GROUP_NAME \
      --name $API_CONTAINER_NAME \
      --server $CONTAINER_REGISTRY_LOGIN_SERVER \
      --identity "system"
    ```

1. Use [`az containerapp secret set`](/cli/azure/containerapp/secret#az-containerapp-secret-set) to create a secret named `conn-string` with the Azure SQL connection string.

    ```azurecli-interactive
    az containerapp secret set \
      --resource-group $RESOURCE_GROUP_NAME \
      --name $API_CONTAINER_NAME \
      --secrets conn-string="$SQL_CONNECTION_STRING"
    ```

    > [!IMPORTANT]
    > This connection string doesn't include any username or passwords. The connection string uses the managed identity to access the Azure SQL database. This makes it safe to use the connection string as a secret in the host.

1. Update the container app with your new custom container image using [`az containerapp update`](/cli/azure/containerapp#az-containerapp-update). Set the `DATABASE_CONNECTION_STRING` environment variable to read from the previously created `conn-string` secret.

    ```azurecli-interactive
    az containerapp update \
      --resource-group $RESOURCE_GROUP_NAME \
      --name $API_CONTAINER_NAME \
      --image "$CONTAINER_REGISTRY_LOGIN_SERVER/adventureworkslt-dab:latest" \
      --set-env-vars DATABASE_CONNECTION_STRING=secretref:conn-string
    ```

1. Retrieve the fully qualified domain name of the latest revision in the running container app using [`az containerapp show`](/cli/azure/containerapp#az-containerapp-show). Store that value in a variable named `APPLICATION_URL`.

    ```azurecli-interactive
    APPLICATION_URL=$( \
      az containerapp show \
        --resource-group $RESOURCE_GROUP_NAME \
        --name $API_CONTAINER_NAME \
        --query "properties.latestRevisionFqdn" \
        --output "tsv" \
    )
    ```

    > [!TIP]
    > You can always check the output of this command.
    >
    > ```azurecli
    > echo $APPLICATION_URL
    > ```
    >

1. Navigate to the URL and test the `Product` REST API.

    ```azurecli-interactive
    echo "https://$APPLICATION_URL/api/Product"
    ```

    > [!WARNING]
    > Deployment can take up to a minute. If you are not seeing a successful response, wait and refresh your browser.

## Clean up resources

When you no longer need the sample application or resources, remove the corresponding deployment and all resources.

```azurecli-interactive
az group delete \
  --name $RESOURCE_GROUP_NAME
```

## Next step

> [!div class="nextstepaction"]
> [Use Application Insights with Data API builder](concept/monitor/application-insights.md)
