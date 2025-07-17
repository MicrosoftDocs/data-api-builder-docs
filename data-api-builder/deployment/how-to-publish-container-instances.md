---
title: Deploy to Azure Container Instances
description: Use the Azure portal and Azure CLI to deploy an Azure Container Instances resource with the Data API builder image.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 06/11/2025
#Customer Intent: As a developer, I want to deploy Data API builder to Azure Container Instances so that I can quickly create a REST API for my database.
---

# Deploy Data API builder to Azure Container Instances

:::image type="complex" source="media/how-to-publish-container-instances/map.svg" border="false" alt-text="Diagram of the current location ('Publish') in the sequence of the deployment guide.":::
Diagram of the sequence of the deployment guide including these locations, in order: Overview, Plan, Prepare, Publish, Monitor, and Optimization. The 'Publish' location is currently highlighted.
:::image-end:::

Deploy the Data API builder quickly to Azure using just a configuration file and no custom code. This guide includes steps to host the Data API builder container image from Docker as a container in Azure Container Instances. 

In this guide, walk through the steps to build a Data API builder configuration file, host the file in Azure Files, and then mount the file to a container in Azure Container Instances.

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).

- Data API builder CLI. [Install the CLI](../how-to-install-cli.md).

- Azure CLI. [Install the Azure CLI](/cli/azure/install-azure-cli).

- Existing supported database addressable from Azure.

## Build the configuration file

To start, build a Data API builder (DAB) configuration file to connect to your existing database. This file is used later with the final container.

1. Create an empty directory on your local machine to store the configuration file.

1. Initialize a new base configuration file using [`dab init`](/azure/data-api-builder/reference-cli#init). Use the following settings at a minimum on initialization.

    | Setting               | Value                                                                                                                          |
    | --------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
    | **Database type**     | Select a supported database type.                                                                                              |
    | **Connection string** | Use the [`@env()`](../reference-functions.md#env) function to reference the `DATABASE_CONNECTION_STRING` environment variable. |

    ```dotnetcli
    dab init --database-type "<database-type>" --connection-string "@env('DATABASE_CONNECTION_STRING')"
    ```

    > [!IMPORTANT]
    > Some database types will require additional configuration settings on initialization.

1. Add at least one database entity to the configuration. Use the [`dab add`](../reference-cli.md#add) command to configure an entity. Configure each entity to allow all permissions for anonymous users. Repeat `dab add` as many times as you like for your entities.

    ```dotnetcli
    dab add "<entity-name>" --source "<schema>.<table>" --permissions "anonymous:*"
    ```

1. Open and review the contents of the *dab-config.json* file. You use this file later in this guide.

## Host configuration in Azure Files

Next, upload the configuration file to a file share created within Azure Files. This file share is eventually mounted to the final container as a volume.

1. Sign into the Azure portal ([https://portal.azure.com](https://portal.azure.com/)).

1. Create a new resource group. You will use this resource group to for all new resources in this guide.

    :::image type="content" source="media/how-to-publish-container-instances/create-resource-group.png" lightbox="media/how-to-publish-container-instances/create-resource-group.png" alt-text="Screenshot of the 'Create a resource group' page's 'Basics' tab in the Azure portal.":::

    > [!TIP]
    > We recommend naming the resource group **msdocs-dab-aci**. All screenshots in this guide use this name.

1. Create an Azure Storage account. Use these settings to configure the account.

    | Setting                               | Value                                         |
    | ------------------------------------- | --------------------------------------------- |
    | **Resource group**                    | Select the resource group you created earlier |
    | **Storage account name**              | Enter a globally unique name                  |
    | **Region**                            | Select an Azure region                        |
    | **Performance**                       | Select **Standard**                           |
    | **Redundancy**                        | Select **Locally-redundant storage (LRS)**    |
    | **Enable storage account key access** | Select **Enabled**                            |
    
    :::image type="content" source="media/how-to-publish-container-instances/create-storage-account.png" alt-text="Screenshot of the 'Create a storage account' page's 'Advanced' tab in the Azure portal.":::

1. Navigate to the new storage account in the Azure portal.

1. Select **File shares** in the **Data storage** section of the resource menu. Then, select **File share** from the command bar to create a new share in the storage account. Use the following settings to configure the new file share.

    | Setting | Value |
    | --- | --- |
    | **Name** | Enter `config` |
    | **Access tier** | Select **Hot** |
    | **Enable backup** | Do not select |

    :::image type="content" source="media/how-to-publish-container-instances/storage-file-share-option.png" alt-text="Screenshot of the **File share** resource menu and command bar options in the Azure portal.":::    

1. Upload the *dab-config.json* and any other required files to the share. Use the **Upload** option in the command bar to open the **Upload files** dialog. Select both files and then select **Upload**.

    :::image type="content" source="media/how-to-publish-container-instances/upload-files.png" alt-text="Screenshot of the **Upload files** dialog in the Azure portal.":::

1. Select **Access keys** in the **Security + networking** section of the resource menu. Then, record the **Storage account name** and **Key** values from this page. You will use these values later in this guide.

    :::image type="content" source="media/how-to-publish-container-instances/storage-credentials.png" alt-text="Screenshot of the 'Access Keys' page within a storage account in the Azure portal.":::

## Create the base container instance

Finally, create the container in Azure using Azure Container Instances. This container hosts the Data API builder image with a configuration file to connect to your database.

> [!IMPORTANT]
> Today, the only way to create a container instance with a mounted volume is with the Azure CLI.

1. Create an Azure Container Instances resource using [`az container create`](/cli/azure/container#az-container-create). Use these settings to configure the resource.

    | Setting | Value |
    | --- | --- |
    | **Resource group** | Use the resource group you created earlier |
    | **Container name** | Enter a globally unique name |
    | **Region** | Use the same region as the storage account |
    | **SKU** | Use **Standard** |
    | **Image type** | Use **Public** |
    | **Image** | Enter `mcr.microsoft.com/azure-databases/data-api-builder:latest` |
    | **OS Type** | Use **Linux** |
    | **Networking type** | Use **Public** |
    | **Networking ports** | Enter `5000` |
    | **DNS name label** | Enter a globally unique label |
    | **Environment variables** | Enter `DATABASE_CONNECTION_STRING` and the connection string for your database. |
    
    ```azurecli
    az container create \
        --resource-group "<resource-group-name>" \
        --name "<unique-container-instance-name>" \
        --image "mcr.microsoft.com/azure-databases/data-api-builder:latest" \
        --location "<region>" \
        --sku "Standard" \
        --os-type "Linux" \
        --ip-address "public" \
        --ports "5000" \
        --dns-name-label "<unique-dns-label>" \
        --environment-variables "DATABASE_CONNECTION_STRING=<database-connection-string>" \
        --azure-file-volume-mount-path "/cfg" \
        --azure-file-volume-account-name "<storage-account-name>" \
        --azure-file-volume-account-key "<storage-account-key>" \
        --azure-file-volume-share-name "config" \
        --command-line "dotnet Azure.DataApiBuilder.Service.dll --ConfigFileName /cfg/dab-config.json"
        --
    ```
    
    > [!TIP]
    > We recommend using a connection string that does not include authorization keys. Instead, use managed identities and role-based access control to manage access between your database and host. For more information, see [Azure services that use managed identities](/entra/identity/managed-identities-azure-resources/managed-identities-status).

1. Use [`az container show`](/cli/azure/container#az-container-show) to query the fully-qualified domain name (FQDN) for your new container instance. Then, browse to the container instance's website.

    ```azurecli
    az container show \
        --resource-group "<resource-group-name>" \
        --name "<unique-container-instance-name>" \
        --query "join('://', ['https', ipAddress.fqdn])" \
        --output "tsv"
    ```

1. Observe the response indicating that the DAB container is running and the status is **healthy**.

    ```json
    {
        "status": "healthy",
        "version": "1.1.7",
        "app-name": "dab_oss_1.1.7"
    }
    ```

    > [!NOTE]
    > The version number and name will vary based on your current version of Data API builder. At this point, you cannot navigate to any API endpoints. These endpoints will be available once you mount a DAB configuration file.

1. Navigate to the `/api/swagger` path for the current running application. Use the Swagger UI to issue a **HTTP GET** request for one of your entities.

## Clean up resources

When you no longer need the sample application or resources, remove the corresponding deployment and all resources.

1. Navigate to the **resource group** using the Azure portal.

1. In the **command bar**, select **Delete**.

## Next step

> [!div class="nextstepaction"]
> [Integrate with Application Insights](../concept/monitor/use-application-insights.md)