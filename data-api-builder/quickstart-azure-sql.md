---
title: |
  Quickstart: Use with Azure SQL
description: Deploy an Azure Developer CLI template that uses Data API builder with Azure Container Apps and Azure SQL.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 01/22/2025
# Customer Intent: As a developer, I want to get started using Data API builder quickly, so that I can evaluate the tool.
---

# Quickstart: Use Data API builder with Azure SQL and Azure Static Web Apps

In this quickstart, you deploy Data API builder (DAB) as a Docker container to Azure Container Apps. You use an Azure Developer CLI (AZD) template to deploy DAB along with an Azure SQL database using the latest best practices. The template also deploys a sample web application that connects to the DAB endpoint using GraphQL.

## Prerequisites

- Azure Developer CLI
- .NET 9.0

If you don't have an Azure account, create a [free account](https://azure.microsoft.com/free/?WT.mc_id=A261C142F) before you begin.

## Initialize the project

Use the Azure Developer CLI (`azd`) to create an Azure SQL account, deploy DAB as a containerized solution, and deploy a containerized sample application. The sample application uses DAB to query sample data.

1. Open a terminal in an empty directory.

1. If you're not already authenticated, authenticate to the Azure Developer CLI using `azd auth login`. Follow the steps specified by the tool to authenticate to the CLI using your preferred Azure credentials.

    ```azurecli
    azd auth login
    ```

1. Use `azd init` to initialize the project.

    ```azurecli
    azd init --template dab-azure-sql-quickstart
    ```

1. During initialization, configure a unique environment name.

1. Deploy the full solution to Azure using `azd up`. The Bicep templates deploy an **Azure SQL account** DAB to Azure Container Apps, and a sample web application.

    ```azurecli
    azd up
    ```

1. During the provisioning process, select your subscription and desired location. Wait for the provisioning process to complete. The process can take **approximately seven minutes**.

1. Once the provisioning of your Azure resources is done, a URL to the running web application is included in the output.

    ```output
    Deploying services (azd deploy)

    (✓) Done: Deploying service api
    - Endpoint: <https://[container-app-sub-domain].azurecontainerapps.io>
    
    (✓) Done: Deploying service web
    - Endpoint: <https://[container-app-sub-domain].azurecontainerapps.io>

    SUCCESS: Your up workflow to provision and deploy to Azure completed in 7 minutes 0 seconds.
    ```

1. Record the values for the URL of the **api** and **web** services. You use these values later in this guide.

## Configure the database connection

Now, browse to each containerized application in Azure Container Apps to validate that they're working as expected.

1. First, navigate to the URL for the **api** service. This URL links to the running DAB instance.

1. Observe the JSON output from DAB. It should indicate that the DAB container is running and the status is **healthy**.

    ```json
    {
      "status": "healthy",
      "version": "1.1.7",
      "app-name": "dab_oss_1.1.7"
    }
    ```

1. Navigate to the relative `/swagger` path for the DAB instance. This URL should open the **Swagger UI** REST integrated development environment (IDE).

1. In the Swagger IDE, run a `GET` request for all rows in the Azure SQL `products` table.

1. Finally, navigate to the URL for the **web** service. This URL links to the running sample web application that connects to the GraphQL endpoint you accessed in the previous step.

1. Observe the running web application and review the output data.

    :::image type="content" source="media/quickstart-azure-sql/running-application.png" alt-text="Screenshot of the running web application on Azure Container Apps.":::

## Clean up

When you no longer need the sample application or resources, remove the corresponding deployment and all resources.

1. Remove the deployment from your Azure subscription.

    ```azurecli
    azd down
    ```

1. Delete the running codespace to maximize your storage and core entitlements if you're using GitHub Codespaces.

## Next step

> [!div class="nextstepaction"]
> [REST endpoints](rest.md)
