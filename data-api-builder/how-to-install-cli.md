---
title: Install the DAB CLI
description: Get started using the Data API builder (DAB) to generate APIs by installing the command-line interface (CLI).
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/20/2024
# Customer Intent: As a developer, I want to install the Data API builder, so that I can use it to create APIs for my databases.
---

# Install the Data API builder command-line interface

In this guide, you go through the steps to install the Data API builder (DAB) command-line interface (CLI) on your local machine. You can then use the CLI to perform the most common actions with DAB. The CLI is distributed as a .NET tool.

## Prerequisites

- .NET 6

## Install the CLI

[!INCLUDE[Install CLI](includes/install-cli.md)]

## Verify that the CLI is installed

Installing the .NET tool makes the `dab` command available on your local machine.

1. Use the `--version` argument to determine the version of your current installation.

    ```dotnetcli
    dab --version
    ```

    > [!IMPORTANT]
    > If you are running on Linux or macOS, you could see an error when invoking `dab` directly. To resolve this error, add the .NET global tools to your `PATH`. For more information, see [troubleshooting Data API builder installation](troubleshoot-installation.md).

1. Observe the output of the previous command. Assuming the current version of the DAB CLI is `1.0.0`, the command would output would include the following content.

    ```output
    Microsoft.DataApiBuilder 1.0.0
    ```

## Related content

- [.NET tools](/dotnet/core/tools/global-tools)
- [How-to: Develop with local data](how-to-develop-local-data.md)
