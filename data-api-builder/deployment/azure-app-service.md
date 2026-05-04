---
title: Deploy to Azure App Service
description: Use the Azure CLI to deploy Data API builder to Azure App Service as a code-based deployment without containers.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: how-to
ms.date: 05/04/2026
# Customer Intent: As a developer, I want to deploy Data API builder to Azure App Service so that I can host REST and GraphQL endpoints without managing containers.
---

# Deploy Data API builder to Azure App Service

This guide shows you how to deploy Data API builder (DAB) to Azure App Service using a code-based deployment model, without building or managing container images. App Service provides built-in support for TLS, custom domains, scaling, monitoring, and Microsoft Entra authentication.

![Diagram of the overall architecture after deployment to Azure App Service is complete.](media/azure-app-service/deploy-app-service.svg)

> [!TIP]
> If your environment uses containers, see [Deploy to Azure Container Apps](azure-container-apps.md) or [Deploy to Azure Kubernetes Service](azure-kubernetes-service.md) instead.

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account?cid=msft_learn).
- Data API builder CLI. [Install the CLI](../command-line/install.md).
- Azure CLI. [Install the Azure CLI](/cli/azure/install-azure-cli).
- [.NET 8](https://dotnet.microsoft.com/download/dotnet/8.0) or later installed locally.
- Existing supported database addressable from Azure.

## Build the configuration file

Build a DAB configuration file to connect to your existing database.

1. Create an empty directory on your local machine to store the configuration file and deployment artifacts.

1. Initialize a new base configuration file using [`dab init`](../command-line/dab-init.md). Use the [`@env()`](../concept/config/env-function.md) function to reference the `DATABASE_CONNECTION_STRING` environment variable so credentials aren't stored in the configuration file.

    ```dotnetcli
    dab init --database-type "<database-type>" --connection-string "@env('DATABASE_CONNECTION_STRING')"
    ```

    > [!IMPORTANT]
    > Replace `<database-type>` with a [supported database type](../configuration/data-source.md#data-source), such as `mssql`, `postgresql`, `mysql`, or `cosmosdb_nosql`. Some database types require extra configuration settings on initialization.

1. Add at least one database entity to the configuration. Use the [`dab add`](../command-line/dab-add.md) command to configure an entity. Repeat `dab add` as many times as you need for your entities.

    ```dotnetcli
    dab add "<entity-name>" --source "<schema>.<table>" --permissions "anonymous:*"
    ```

1. Open and review the contents of the *dab-config.json* file. Verify that:

    - `data-source.connection-string` uses `@env('DATABASE_CONNECTION_STRING')`
    - Your entities and permissions are correct

    > [!IMPORTANT]
    > Don't embed literal connection strings or secrets in `dab-config.json`. Use the `@env()` function so values are resolved from environment variables at runtime.

## Create a local tool manifest

Use a local .NET tool manifest so the deployment package includes DAB as a project dependency. This approach avoids relying on a globally installed tool inside App Service.

1. Create a .NET local tool manifest in your project directory.

    ```dotnetcli
    dotnet new tool-manifest
    ```

1. Install Data API builder as a local tool.

    ```dotnetcli
    dotnet tool install microsoft.dataapibuilder --prerelease
    ```

1. Verify the manifest exists at `.config/dotnet-tools.json`.

    > [!NOTE]
    > The `--prerelease` flag installs the latest Data API builder prerelease version. Remove the flag to install the latest stable release instead.

## Test locally

Before deploying to Azure, confirm the runtime starts and your endpoints work.

1. Set the connection string as a local environment variable.

    ### [PowerShell](#tab/powershell)

    ```powershell
    $env:DATABASE_CONNECTION_STRING = "<your-connection-string>"
    ```

    ### [Bash](#tab/bash)

    ```bash
    export DATABASE_CONNECTION_STRING="<your-connection-string>"
    ```

    ---

1. Start the DAB runtime locally.

    ```dotnetcli
    dab start
    ```

1. Test the REST endpoint by navigating to the Swagger UI or making a request to `/api/<entity-name>`.

1. Test the GraphQL endpoint at `/graphql`.

1. Stop the runtime after verifying all endpoints.

## Create the App Service resources

Create the Azure resources required to host DAB on App Service.

1. Create a new resource group. You use this resource group for all new resources in this guide.

    ```azurecli
    az group create \
      --name <resource-group-name> \
      --location <location>
    ```

    > [!TIP]
    > Consider naming the resource group **msdocs-dab-appservice**.

1. Create an App Service plan.

    ```azurecli
    az appservice plan create \
      --name <plan-name> \
      --resource-group <resource-group-name> \
      --sku B1 \
      --is-linux
    ```

    > [!NOTE]
    > This guide uses the **B1** (Basic) tier on Linux.

1. Create the web app with the .NET 8 runtime.

    ```azurecli
    az webapp create \
      --name <app-name> \
      --resource-group <resource-group-name> \
      --plan <plan-name> \
      --runtime "DOTNETCORE:8.0"
    ```

    > [!TIP]
    > Validate available runtimes for your plan with `az webapp list-runtimes --os linux`.

## Configure App Service settings

Configure the environment variables and startup command that App Service needs to run DAB.

1. Configure the authentication provider for App Service. This setting tells DAB to trust App Service's built-in authentication (Easy Auth) for identity information.

    ```dotnetcli
    dab configure --runtime.host.authentication.provider AppService
    ```

1. Set the database connection string as an App Service application setting.

    ```azurecli
    az webapp config appsettings set \
      --name <app-name> \
      --resource-group <resource-group-name> \
      --settings DATABASE_CONNECTION_STRING="<your-connection-string>"
    ```

    > [!TIP]
    > Use a connection string that doesn't include secrets. Instead, use managed identities and Microsoft Entra authentication to manage access between your database and App Service. For more information, see [Azure services that use managed identities](/entra/identity/managed-identities-azure-resources/managed-identities-status).

1. Create a startup script that restores the local tool manifest and starts DAB. Create a file named `startup.sh` in your project directory.

    ```bash
    #!/bin/sh
    dotnet tool restore
    dotnet tool run dab start
    ```

    > [!IMPORTANT]
    > Ensure `startup.sh` uses LF (Unix) line endings, not CRLF. Windows editors may save with CRLF by default, which causes the script to fail on the Linux App Service host.

1. Set the startup command in App Service.

    ```azurecli
    az webapp config set \
      --name <app-name> \
      --resource-group <resource-group-name> \
      --startup-file "startup.sh"
    ```

## Deploy to App Service

Package your project files and deploy them to App Service using ZIP deploy.

1. Create a deployment package containing your project files. At a minimum, include:

    - `dab-config.json`
    - `.config/dotnet-tools.json`
    - `startup.sh`

    ### [PowerShell](#tab/powershell)

    ```powershell
    Compress-Archive -Path dab-config.json, .config, startup.sh -DestinationPath deploy.zip -Force
    ```

    ### [Bash](#tab/bash)

    ```bash
    zip -r deploy.zip dab-config.json .config startup.sh
    ```

    ---

    > [!IMPORTANT]
    > The ZIP must contain files at the root level. Don't zip a parent folder that contains the files. The archive root should include `dab-config.json`, `.config/`, and `startup.sh` directly.

1. Deploy the ZIP package to App Service.

    ```azurecli
    az webapp deploy \
      --resource-group <resource-group-name> \
      --name <app-name> \
      --src-path deploy.zip \
      --type zip
    ```

## Verify the deployment

After deployment, confirm that DAB starts successfully on App Service.

1. Open the App Service URL.

    ```text
    https://<app-name>.azurewebsites.net
    ```

1. Check the health endpoint.

    ```text
    https://<app-name>.azurewebsites.net/health
    ```

1. Test REST and GraphQL endpoints using the same entity paths you tested locally. The deployed app uses the same `dab-config.json`, so endpoint behavior should match your local runtime.

1. If any endpoint returns an unexpected error, enable application logging and review the logs.

    ```azurecli
    az webapp log config \
      --name <app-name> \
      --resource-group <resource-group-name> \
      --application-logging filesystem \
      --level information

    az webapp log tail \
      --name <app-name> \
      --resource-group <resource-group-name>
    ```

## Configure authentication (optional)

Protect your App Service endpoint with Microsoft Entra ID for production use.

For detailed steps, see [Configure App Service authentication](/azure/app-service/overview-authentication-authorization).

> [!IMPORTANT]
> The `AppService` authentication provider in `dab-config.json` trusts headers injected by App Service authentication. Make sure App Service authentication is enabled when using this provider in production. For more information, see [Easy Auth (App Service)](../concept/security/authenticate-easy-auth.md).

> [!NOTE]
> App Service authentication protects ingress to your endpoint. DAB entity permissions still govern what operations the runtime allows. If you want role-based access, update your entity permissions to use specific roles instead of `anonymous:*`.

## Clean up resources

When you no longer need the sample application or resources, remove the corresponding deployment and all resources.

```azurecli
az group delete \
  --name <resource-group-name> \
  --yes \
  --no-wait
```

## Related content

- [Easy Auth (App Service) authentication](../concept/security/authenticate-easy-auth.md)
- [Configuration file reference](../configuration/index.md)
- [Runtime host and authentication configuration](../configuration/runtime.md#runtime)
- [Deploy to Azure Container Apps](azure-container-apps.md)
- [Integrate with Application Insights](../concept/monitor/application-insights.md)
