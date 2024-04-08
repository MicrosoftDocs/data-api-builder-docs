---
title: |
  Quickstart: Use with Azure Cosmos DB for NoSQL
description: Deploy an Azure Developer CLI template that uses Data API builder with Azure Static Web apps and Azure Cosmos DB for NoSQL.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 04/08/2024
# Customer Intent: As a developer, I want to get started using Data API builder quickly, so that I can evaluate the tool.
---

# Quickstart: Use Data API builder with Azure Cosmos DB for NoSQL and Azure Static Web Apps

In this Quickstart, you deploy an Azure Developer CLI (AZD) template. The template deploys an Azure Static Web App that hosts the Data API builder using it's **database connections** feature. The template also includes a sample application that you can use as a starting point for your solutions.

## Prerequisites

- Azure subscription. If you don't have an Azure subscription, create a free [trial account](https://azure.microsoft.com/free/?WT.mc_id=A261C142F)
- [.NET 8](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Azure Developer CLI](/azure/developer/azure-developer-cli/install-azd)

> [!TIP]
> Alternatively, open this Quickstart in GitHub Codespaces with all developer prerequisites already installed. Simply bring your own Azure subscription. GitHub accounts include an entitlement of storage and core hours at no cost. For more information, see [included storage and core hours for GitHub accounts](https://docs.github.com/billing/managing-billing-for-github-codespaces/about-billing-for-github-codespaces#monthly-included-storage-and-core-hours-for-personal-accounts).
>
> [![Open in GitHub Codespaces](https://img.shields.io/badge/Open-Open?style=for-the-badge&label=GitHub+Codespaces&logo=github&labelColor=0078D7&color=303030)](https://codespaces.new/azure-samples/dab-azure-cosmos-db-nosql-quickstart?template=true&quickstart=1)

## Deploy the template

First, deploy all of the required services using the AZD template.

1. Open a terminal in the root directory of the project.

1. Authenticate to the Azure Developer CLI using `azd auth login`. Follow the steps specified by the tool to authenticate to the CLI using your preferred Azure credentials.

    ```azurecli
    azd auth login
    ```

1. Use `azd init` to initialize the project.

    ```azurecli
    azd init --template dab-azure-cosmos-db-nosql-quickstart
    ```

    > [!IMPORTANT]
    > If you are running in GitHub Codespaces, you can safely omit the `--template` argument since the code has already been cloned to your environment.

1. During initialization, configure a unique environment name.

    > [!TIP]
    > The environment name will also be used as the target resource group name. For this quickstart, consider using `msdocs-swa-dab`.

1. Deploy the Azure Static Web Apps solution using `azd up`. The Bicep templates deploy an **Azure Cosmos DB for NoSQL account** along with the supporting storage, identity, and host services. A sample web application is deployed to the web host.

    ```azurecli
    azd up
    ```

1. During the provisioning process, select your subscription and desired location. Wait for the provisioning process to complete. The process can take **approximately five minutes**.

1. Once the provisioning of your Azure resources is done, the template outputs a **SUCCESS** message along with the duration of the run.

    ```output
    SUCCESS: Your application was provisioned and deployed to Azure in 5 minutes 0 seconds.
    ```

## Configure the database connection

Now, use the **database connections** feature of Azure Static Web Apps to create a connection between the deployed static web app and the deployed database. This feature uses Data API builder seamlessly to create a connection to a running Azure Cosmos DB for NoSQL account using the credentials you specify.

1. Navigate to the **Azure Static Web App** resource in the Azure portal.

1. Configure the static web app to add a **Database Connection** to the Azure Cosmos DB for NoSQL account using these settings. Then, select **Link**.

    | | Value |
    | --- | --- |
    | **Database type** | `Azure Cosmos DB for NoSQL` |
    | **Subscription** | *Select the subscription you used for the AZD deployment* |
    | **Resource group** | *Select the resource group (environment) you used for the AZD deployment* |
    | **Resource name** | *Select the only Azure Cosmos DB for NoSQL resource with a prefix of `nosql-*`* |
    | **Database name** | `cosmicworks` |
    | **Authentication type** | `User-assigned managed identity` |
    | **User-assigned managed identity** | *Select the only managed identity resource with a prefix of `ua-id-*` |

    :::image type="content" source="media/quickstart-azure-cosmos-db-nosql/database-connection-config.png" alt-text="Screenshot of the database connection page for a static web app in the Azure portal.":::

1. Now, select the **Browse** option on the resource page to observe running web application.

    :::image type="content" source="media/quickstart-azure-cosmos-db-nosql/running-application.png" alt-text="Screenshot of the running web application on Azure Static Web Apps.":::

## Clean up

When you no longer need the sample application or resources, remove the corresponding deployment and all resources.

1. Remove the deployment from your Azure subscription.

    ```azurecli
    azd down
    ```

1. Delete the running codespace to maximize your storage and core entitlements if you're using GitHub Codespaces.

## Next step

> [!div class="nextstepaction"]
> [Install the DAB CLI on your local machine](how-to-install-cli.md)
