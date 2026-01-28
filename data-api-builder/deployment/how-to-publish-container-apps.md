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

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).

- Data API builder CLI. [Install the CLI](../command-line/install.md).

- Azure CLI. [Install the Azure CLI](/cli/azure/install-azure-cli).

- Existing supported database addressable from Azure.

## Build the configuration file

To start, build a Data API builder (DAB) configuration file to connect to your existing database. This file is used later with the final container.

1. Create an empty directory on your local machine to store the configuration file.

1. Initialize a new base configuration file using [`dab init`](../command-line/dab-init.md). Use the following settings at a minimum on initialization.

    | Setting               | Value                                                                                                                          |
    | --------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
    | **Database type**     | Select a supported database type.                                                                                              |
    | **Connection string** | Use the [`@env()`](../concept/config/env-function.md) function to reference the `DATABASE_CONNECTION_STRING` environment variable. |

    ```dotnetcli
    dab init --database-type "<database-type>" --connection-string "@env('DATABASE_CONNECTION_STRING')"
    ```

    > [!IMPORTANT]
    > Some database types require extra configuration settings on initialization.

1. Add at least one database entity to the configuration. Use the [`dab add`](../command-line/dab-add.md) command to configure an entity. Configure each entity to allow all permissions for anonymous users. Repeat `dab add` as many times as you like for your entities.

    ```dotnetcli
    dab add "<entity-name>" --source "<schema>.<table>" --permissions "anonymous:*"
    ```

1. Open and review the contents of the *dab-config.json* file. You use this file later in this guide.

## Build a custom container image

Build a custom image that includes `dab-config.json` at `/App/dab-config.json`. Run these commands from the folder that contains `dab-config.json`.

1. Create a new resource group. You use this resource group for all new resources in this guide.

    > [!TIP]
    > We recommend naming the resource group **msdocs-dab-aca**.

1. Create an Azure Container Registry (ACR) and build the image.

    ```azurecli
    az acr create \
      --resource-group "<resource-group-name>" \
      --name "<registry-name>" \
      --sku Basic \
      --admin-enabled true

    # Create a Dockerfile that embeds dab-config.json
    cat <<'EOF' > Dockerfile
    FROM mcr.microsoft.com/azure-databases/data-api-builder:latest
    COPY dab-config.json /App/dab-config.json
    EOF

    # Build and push the image
    az acr build \
      --registry "<registry-name>" \
      --image "dab:1" \
      .
    ```

1. Record the registry login server (`<registry-name>.azurecr.io`) and image tag (`dab:1`). You use these values when creating the container app.

## Create the container app

Create the container app using the custom image that already includes `dab-config.json`.

1. Create an Azure Container Apps resource. As part of the process of creating the app resource, you're required to create an environment. Use these settings to configure both resources.

    | Resource        | Setting                           | Value                                           |
    | --------------- | --------------------------------- | ----------------------------------------------- |
    | **Environment** | **Environment name**              | Enter a globally unique name                    |
    | **Environment** | **Environment type**              | Select **Consumption only**                     |
    | **Environment** | **Logs destination**              | Select **Don't save logs**                      |
    | **App**         | **Resource group**                | Select the resource group you created earlier   |
    | **App**         | **Region**                        | Select the same region as your resource group   |
    | **App**         | **Use quickstart image**          | Don't select                                    |
    | **App**         | **Image source**                  | Select **Azure Container Registry**             |
    | **App**         | **Registry**                      | Select your ACR instance                         |
    | **App**         | **Image and tag**                 | Enter `dab:1`                                    |
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
    > We recommend using a connection string that doesn't include authorization keys. Instead, use managed identities and role-based access control to manage access between your database and host. For more information, see [Azure services that use managed identities](/entra/identity/managed-identities-azure-resources/managed-identities-status).    

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
    > The version number and name vary based on your current version of Data API builder.

1. Navigate to the `/api/swagger` path for the current running application. Use the Swagger UI to issue an **HTTP GET** request for one of your entities.

## Clean up resources

When you no longer need the sample application or resources, remove the corresponding deployment and all resources.

1. Navigate to the **resource group** using the Azure portal.

1. In the **command bar**, select **Delete**.

## Next step

> [!div class="nextstepaction"]
> [Integrate with Application Insights](../concept/monitor/application-insights.md)
