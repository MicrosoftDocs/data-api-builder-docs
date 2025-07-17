---
title: Deploy to Azure Container Apps
description: Use the Azure portal to deploy an Azure Container Apps resource with the Data API builder image.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 06/11/2025
#Customer Intent: As a developer, I want to deploy Data API builder to Azure Container Apps so that I can quickly create a REST API for my database.
---

# Deploy Data API builder to Azure Container Apps

:::image type="complex" source="media/how-to-publish-container-apps/map.svg" border="false" alt-text="Diagram of the current location ('Publish') in the sequence of the deployment guide.":::
Diagram of the sequence of the deployment guide including these locations, in order: Overview, Plan, Prepare, Publish, Monitor, and Optimization. The 'Publish' location is currently highlighted.
:::image-end:::

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).

- Data API builder CLI. [Install the CLI](../how-to-install-cli.md).

- Azure CLI. [Install the Azure CLI](/cli/azure/install-azure-cli).

- Existing supported database addressable from Azure.

## Build the configuration file

To start, build a Data API builder (DAB) configuration file to connect to your existing database. This file is used later with the final container.

1. Create an empty directory on your local machine to store the configuration file.

1. Initialize a new base configuration file using [`dab init`](../reference-cli.md#init). Use the following settings at a minimum on initialization.

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

    :::image type="content" source="media/how-to-publish-container-apps/create-resource-group.png" lightbox="media/how-to-publish-container-apps/create-resource-group.png" alt-text="Screenshot of the 'Create a resource group' page's 'Basics' tab in the Azure portal.":::

    > [!TIP]
    > We recommend naming the resource group **msdocs-dab-aca**. All screenshots in this guide use this name.

1. Create an Azure Storage account. Use these settings to configure the account.

    | Setting                               | Value                                         |
    | ------------------------------------- | --------------------------------------------- |
    | **Resource group**                    | Select the resource group you created earlier |
    | **Storage account name**              | Enter a globally unique name                  |
    | **Region**                            | Select an Azure region                        |
    | **Performance**                       | Select **Standard**                           |
    | **Redundancy**                        | Select **Locally-redundant storage (LRS)**    |
    | **Enable storage account key access** | Select **Enabled**                            |

    :::image type="content" source="media/how-to-publish-container-apps/create-storage-account.png" alt-text="Screenshot of the 'Create a storage account' page's 'Advanced' tab in the Azure portal.":::

1. Navigate to the new storage account in the Azure portal.

1. Select **File shares** in the **Data storage** section of the resource menu. Then, select **File share** from the command bar to create a new share in the storage account. Use the following settings to configure the new file share.

    | Setting           | Value          |
    | ----------------- | -------------- |
    | **Name**          | Enter `config` |
    | **Access tier**   | Select **Hot** |
    | **Enable backup** | Do not select  |

    :::image type="content" source="media/how-to-publish-container-apps/storage-file-share-option.png" alt-text="Screenshot of the **File share** resource menu and command bar options in the Azure portal.":::

1. Upload the *dab-config.json* and any other required files to the share. Use the **Upload** option in the command bar to open the **Upload files** dialog. Select both files and then select **Upload**.

    :::image type="content" source="media/how-to-publish-container-apps/upload-files.png" alt-text="Screenshot of the **Upload files** dialog in the Azure portal.":::

1. Select **Access keys** in the **Security + networking** section of the resource menu. Then, record the **Storage account name** and **Key** values from this page. You will use these values later in this guide.

    :::image type="content" source="media/how-to-publish-container-apps/storage-credentials.png" alt-text="Screenshot of the 'Access Keys' page within a storage account in the Azure portal.":::

## Create the base container app

Now, create the container in Azure using Azure Container Apps. This container hosts the Data API builder image without a configuration.

1. Create an Azure Container Apps resource. As part of the process of creating the app resource, you will be required to create an environment. Use these settings to configure both resources.

    | Resource        | Setting                           | Value                                           |
    | --------------- | --------------------------------- | ----------------------------------------------- |
    | **Environment** | **Environment name**              | Enter a globally unique name                    |
    | **Environment** | **Environment type**              | Select **Consumption only**                     |
    | **Environment** | **Logs destination**              | Select **Don't save logs**                      |
    | **App**         | **Resource group**                | Select the resource group you created earlier   |
    | **App**         | **Storage account name**          | Enter a globally unique name                    |
    | **App**         | **Region**                        | Select the same region as the storage account   |
    | **App**         | **Use quickstart image**          | Do not select                                   |
    | **App**         | **Image source**                  | Select **Docker Hub or other registries**       |
    | **App**         | **Image type**                    | Select **Public**                               |
    | **App**         | **Registry login server**         | Enter `mcr.microsoft.com`                       |
    | **App**         | **Image and tag**                 | Enter `azure-databases/data-api-builder:latest` |
    | **App**         | **Environment variables - Name**  | Enter `DATABASE_CONNECTION_STRING`              |
    | **App**         | **Environment variables - Value** | Enter the connection string for your database.  |
    | **App**         | **Ingress**                       | Ensure **Enabled** is selected                  |
    | **App**         | **Ingress traffic**               | Select **Accepting traffic from anywhere**      |
    | **App**         | **Client certificate mode**       | Select **Ignore**                               |
    | **App**         | **Ingress type**                  | Select **HTTP**                                 |
    | **App**         | **Target port**                   | Enter `5000`                                    |

    :::image type="content" source="media/how-to-publish-container-apps/create-container-app.png" alt-text="Screenshot of the 'Create Container App' page's 'Container' tab in the Azure portal.":::

    :::image type="content" source="media/how-to-publish-container-apps/create-container-app-environment.png" alt-text="Screenshot of the 'Create Container Apps Environment' page's 'Basics' tab in the Azure portal.":::

    > [!TIP]
    > We recommend using a connection string that does not include authorization keys. Instead, use managed identities and role-based access control to manage access between your database and host. For more information, see [Azure services that use managed identities](/entra/identity/managed-identities-azure-resources/managed-identities-status).    

1. Navigate to the new container app in the Azure portal.

1. Use the **Application URL** field in the **Essentials** section to browse to the container app's website. Observe the response indicating that the DAB container is running and the status is **healthy**.

    ```json
    {
        "status": "healthy",
        "version": "1.1.7",
        "app-name": "dab_oss_1.1.7"
    }
    ```

    > [!NOTE]
    > The version number and name will vary based on your current version of Data API builder. At this point, you cannot navigate to any API endpoints. These endpoints will be available once you mount a DAB configuration file.

## Mount the configuration files

Finally, mount the configuration files from the Azure Files share to the container app. This step allows the Data API builder to use the configuration file to connect to your database.

1. Navigate to the container environment created previously in this guide using the Azure portal.

1. Select **Azure files** in the **Settings** section of the resource menu. Then, select **Add** from the command bar to add an existing file share to the container environment. Use the following settings to configure the new file share. Then **save** the new file share configuration.

    | Setting | Value |
    | --- | --- |
    | **Name** | Enter `config-share` |
    | **Storage account name** | Name of the storage account recorded earlier in this guide. |
    | **Storage account key** | Key of the storage account recorded earlier in this guide. |
    | **File share** | Enter `config` |
    | **Access mode** | Select **Read only** |

    :::image type="content" source="media/how-to-publish-container-apps/azure-files-option.png" alt-text="Screenshot of the 'Azure Files' option in the resource menu within the Azure portal.":::

1. Navigate to the container app again in the Azure portal.

1. Select Revisions and replicas in the Application section of the resource menu. Then, select Create new revision from the command bar to start the process of configuring a new revision for your container app.

1. Navigate to the Volumes section and select the Add option. Use the following settings to configure the new volume. After configuring the volume, Add the volume to the container revision.

    | Setting | Value |
    | --- | --- |
    | **Volume type** | Select **Azure file volume** |
    | **Name** | Enter `config-volume` |
    | **File share** | Enter `config` |


    :::image type="content" source="media/how-to-publish-container-apps/add-volume.png" alt-text="Screenshot of the `Create new volume` section in the Azure portal.":::

1. Navigate to the **Container** section, select the single current container, and then select the **Edit** option. Use the following settings to configure two mounts for the container. **Save** your changes.

    | Setting         | Value                        |
    | --------------- | ---------------------------- |
    | **Volume name** | Enter `config-volume`        |
    | **Mount path**  | Enter `/App/dab-config.json` |
    | **Sub path**    | Enter `dab-config.json`      |

    | Setting         | Value                       |
    | --------------- | --------------------------- |
    | **Volume name** | Enter `config-volume`       |
    | **Mount path**  | Enter `/App/schema.graphql` |
    | **Sub path**    | Enter `schema.graphql`      |

    :::image type="content" source="media/how-to-publish-container-apps/edit-container.png" alt-text="Screenshot of the `Add volume mount` section in the Azure portal.":::
    
1. Select **Create** to create a new revision with the volume mounts you specified. With for the revision to finish deploying.

1. Use the **Application URL** field in the **Essentials** section to browse to the container app's website again. Observe that the response still indicates that the DAB container is **healthy**.

1. Navigate to the `/api/swagger` path for the current running application. Use the Swagger UI to issue an **HTTP GET** request for one of your entities.

## Clean up resources

When you no longer need the sample application or resources, remove the corresponding deployment and all resources.

1. Navigate to the **resource group** using the Azure portal.

1. In the **command bar**, select **Delete**.

## Next step

> [!div class="nextstepaction"]
> [Integrate with Application Insights](../concept/monitor/use-application-insights.md)
