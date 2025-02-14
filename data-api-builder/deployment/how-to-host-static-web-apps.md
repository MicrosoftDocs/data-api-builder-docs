---
title: Host in Azure Static Web Apps (preview)
description: Use the Azure portal to deploy an Azure Static Web Apps resource with Data API builder using the database connections feature.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 02/13/2025
ai-usage: ai-assisted
#Customer Intent: As a developer, I want to host Data API builder in Azure Static Web Apps so that I can quickly create a REST API for my database.
---

# Host Data API builder in Azure Static Web Apps (preview)

:::image type="complex" source="media/how-to-host-static-web-apps/map.svg" border="false" alt-text="Diagram of the current location ('Publish') in the sequence of the deployment guide.":::
Diagram of the sequence of the deployment guide including these locations, in order: Overview, Plan, Prepare, Publish, Monitor, and Optimization. The 'Publish' location is currently highlighted.
:::image-end:::

Host Data API builder quickly in Azure Static Web Apps using just a configuration file. This guide includes steps to integrate Data API builder with a static web app.

In this guide, walk through the steps to build a DAB configuration file, host the file as part of your application, and then use a database connection in Azure Static Web Apps.

## Prerequisites

> [!IMPORTANT]
> Support for Data API builder (DAB) in Azure Static Web Apps using database connections is in preview. Azure Static Web Apps uses a fixed version of the DAB engine that can vary from the latest stable version of DAB. To access the latest DAB features, consider an alternative host for DAB using the latest version of the engine from GitHub, Microsoft Container Registry (Docker Hub), or NuGet.

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/free/?WT.mc_id=A261C142F).
- Azure Static Web Apps CLI. [Install the Static Web Apps (SWA) CLI](/azure/static-web-apps/static-web-apps-cli-install).
- Data API builder CLI. [Install the Data API builder (DAB) CLI](../how-to-install-cli.md).
- Existing supported database addressable from Azure.
- Existing web application in a GitHub repository that can be deployed to Azure Static Web Apps.
    - If you don't have a web application, [generate a repository with a basic web application](https://github.com/staticwebdev/vanilla-basic/generate).
      
## Create a static web app

To start, use the Azure portal to create a new Azure Static Web App using the web application in GitHub.

1. Sign into the Azure portal ([https://portal.azure.com](https://portal.azure.com/)).
1. Create a new resource group. You will use this resource group to for all new resources in this guide.
   
   :::image type="content" source="media/how-to-host-static-web-apps/create-resource-group.png" lightbox="media/how-to-host-static-web-apps/create-resource-group.png" alt-text="Screenshot of the 'Create a resource group' page's 'Basics' tab in the Azure portal.":::
   
   > [!TIP]
   > We recommend naming the resource group **msdocs-dab-swa**. All screenshots in this guide use this name.
1. Create an Azure Static Web App. Use these settings to configure the static web app.       
   
    | Setting            | Value                                                                        |
    | :----------------- | :--------------------------------------------------------------------------- |
    | **Resource group** | Select the resource group you created earlier                                |
    | **Name**           | Enter a globally unique name                                                 |
    | **Plan type**      | Select the best option for your workload                                     |
    | **Source**         | Select **GitHub**                                                            |
    | **GitHub account** | Configure a GitHub account that has access to the web application repository |
    | **Organization**   | Select the parent organization or user for the repository                    |
    | **Repository**     | Select the repository name                                                   |
    | **Branch**         | Select the primary branch                                                    |

    :::image type="content" source="media/how-to-host-static-web-apps/create-static-web-app.png" alt-text="Screenshot of the 'Create Static Web App' page's 'Basics' tab in the Azure portal.":::

1. Wait for the static web application deployment to complete. A GitHub Actions workflow is automatically added to your repository that will deploy the application to Azure Static Web Apps every time you push to the primary branch.

    > [!NOTE]
    > This initial deployment can take a few minutes. You can always check the status of the deployment in either the Azure portal or the GitHub Actions tab in your repository.

1. Navigate to the new static web app in the Azure portal.

1. In the **Essentials** section, use the **URL** hyperlink to navigate to the running web application. Verify that the application is running as expected.

## Add the DAB configuration file

Now, use the DAB and SWA command-line interfaces to create a new DAB configuration file and add it to the web application repository.

1. Open the GitHub repository for your web application in the integrated developer environment (IDE) of your choice.
    
    > [!TIP]
    > You can use any IDE you'd like. If you want to work on the application locally, you can clone the repository to your local machine. If you prefer to work in the browser, you can use [GitHub Codespaces](https://github.com/codespaces). Ensure that the SWA and DAB CLIs is installed in your development environment.

1. Open a terminal in the root of the repository.

1. Use the [`swa db`](/azure/static-web-apps/static-web-apps-cli#swa-db) command from the SWA CLI to initialize a new DAB configuration file using the specified database type. The command will create a new file named *staticwebapp.database.config.json* in the *swa-db-connections* folder.

    ```dotnetcli
    swa db init --database-type "<database-type>"
    ```
    > [!IMPORTANT]
    > Some database types will require additional configuration settings on initialization.
        
1. Use the [`dab add`](../reference-cli.md#add) command to add at least one database entity to the configuration. Configure each entity to allow all permissions for anonymous users. Repeat `dab add` as many times as you like for your entities.

    ```dotnetcli
    dab add "<entity-name>" --source "<schema>.<table>" --permissions "anonymous:*" --config "swa-db-connections/staticwebapp.database.config.json"
    ```
1. Open and review the contents of the swa-db-connections/staticwebapp.database.config.json file.

1. Commit your changes to the repository and push them to the primary branch. This will automatically trigger a new deployment of the web application. Wait for this latest deployment to finish before continuing with this guide.        

## Configure the database connection

Next, configure the database connection in the Azure portal to allow the static web app to access the database.

1. Navigate to the static web app again in the Azure portal.

1. Select the **Database connection** option in the **Settings** section of the resource menu. Then, select **Link existing database** for the **production** environment.

    :::image type="content" source="media/how-to-host-static-web-apps/database-connection-option.png" alt-text="Screenshot of the `Database connection` option in the Azure Static Web Apps page of the Azure portal.":::

1. In the **Link database** dialog, use these settings to configure the database connection.

    | Setting                 | Value                                                                           |
    | ----------------------- | ------------------------------------------------------------------------------- |
    | **Database type**       | Select the same database type you used when creating the DAB configuration file |
    | **Resource group**      | Select the resource group you created earlier in this guide                     |
    | **Resource name**       | Select the database resource you want to link to the static web app             |
    | **Database name**       | Enter the name of the database                                                  |
    | **Authentication type** | Select the type of authentication you intend to use                             |

    :::image type="content" source="media/how-to-host-static-web-apps/link-database-options.png" alt-text="Screenshot of the `Link database` dialog for database connections in the Azure Static Web Apps page of the Azure portal.":::

    > [!TIP]
    > We recommend using a connection string that does not include authorization keys. Instead, use managed identities and role-based access control to manage access between your database and host. For more information, see [Azure services that use managed identities](/entra/identity/managed-identities-azure-resources/managed-identities-status).

## Test the data API endpoint

Finally, validate that the data API endpoint is available on the static web app.

1. Navigate to the static web app again in the Azure portal.

1. Use the **URL** field in the **Essentials** section to browse to the static web app's website again.

1. Navigate to the `/data-api` path for the current running application. Observe that the response still indicates that the DAB container is **healthy**.

    ```output
    { Healthy }
    ```

    > [!NOTE]
    > Static Web Apps automatically set the runtime host mode to `Production`, overwriting any value in the configuration file. As a result, developer features like Swagger and Banana Cake Pop are unavailable in Static Web Apps.

1. Navigate to the `https://<your-static-web-app-url>/data-api/<your-rest-path>/<your-entity-name>` path for the current running application. This issues an **HTTP GET** request for that set of entities. Observe the JSON response.

## Clean up resources

When you no longer need the sample application or resources, remove the corresponding deployment and all resources.

1. Navigate to the **resource group** using the Azure portal.

1. In the **command bar**, select **Delete**.
