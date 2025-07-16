---
title: Build and run source code
description: Use advanced Git commands and the source code from GitHub to manually build and run Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 06/11/2025
# Customer Intent: As a developer, I want to build Data API builder from source code, so that I can make changes and contribute back to the project.
---

# Build and run Data API builder from source code

Data API builder (DAB) is an open-source project hosted on GitHub. At any time, you can download the source code, modify the code, and run the project directly from source. This guide includes all the steps necessary to build the project directly from its source code.

## Prerequisites

- [GitHub account](https://docs.github.com/get-started/start-your-journey/creating-an-account-on-github)
- [Git](https://git-scm.com/downloads)
  - This tutorial assumes a basic familiarity with Git commands and tooling.
- [.NET 8](https://dotnet.microsoft.com/download/dotnet/8.0)

## Fork and clone the repository

Get started by creating your own fork of the `azure/data-api-builder` GitHub repository. This fork allows you to persist your own changes. If you so choose, you can always open a pull request and suggest the changes to the upstream repository.

1. Navigate to <https://github.com/azure/data-api-builder/fork>.

1. Create a fork of the repository in your own account or organization. Wait for the forking operation to complete before continuing.

1. Open a new terminal.

1. Clone the fork.

    ```bash
    git clone https://github.com/<your-username>/data-api-builder.git
    ```

    > [!TIP]
    > Alternatively, you can open the fork or the original repository as a GitHub Codespace.

1. Build the `src/Azure.DataApiBuilder.sln` solution.

    ```bash
    dotnet build src/Azure.DataApiBuilder.sln
    ```

## Run the engine

The `Azure.DataApiBuilder` solution includes multiple projects. To run the tool from source, run the `Azure.DataApiBuilder.Service` project passing in a configuration file.

1. In the root directory, create a new file named `dab-config.json`.

    > [!TIP]
    > The *.gitignore* file automatically ignores any DAB configuration files.

1. Add the following content to the configuration file.

    ```json
    {
      "$schema": "https://github.com/Azure/data-api-builder/releases/latest/download/dab.draft.schema.json",
      "data-source": {
        "database-type": "mssql",
        "connection-string": "Server=localhost,1433;Initial Catalog=Library;User Id=sa;Password=<your-password>;TrustServerCertificate=true;"
      },
      "entities": {
        "book": {
          "source": "dbo.Books",
          "permissions": [
            {
              "actions": [
                "read"
              ],
              "role": "anonymous"
            }
          ]
        }
      }
    }
    ```

    > [!IMPORTANT]
    > This is a sample configuration that assumes you have a SQL Server available on your local machine. If you do not, you can run a Docker container for SQL Server with your sample data. For more information, see [creating sample data](how-to/run-container.md#create-sample-data).

1. Run the `src/Service/Azure.DataApiBuilder.Service.csproj` project. Use the `--ConfigFileName` argument to specify the configuration file created in the previous step.

    ```bash
    dotnet run --project src/Service/Azure.DataApiBuilder.Service.csproj --ConfigFileName ../../dab-config.json 
    ```

    > [!TIP]
    > The Data API builder engine will try to load the configuration from the `dab-config.json` file in the same folder, if present. If there is no `dab-config.json` file, the engine will start anyway but it will not be able to serve anything.

## Related content

- [`azure/data-api-builder` on GitHub](https://github.com/azure/data-api-builder)
- [Run in a Docker container](how-to/run-container.md)
