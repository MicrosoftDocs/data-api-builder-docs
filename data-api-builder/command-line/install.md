---
title: Install the DAB CLI
description: Use the Data API builder (DAB) command-line interface (CLI) to create APIs for your databases by installing it on your system.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 09/29/2025
# Customer Intent: As a developer, I want to install the Data API builder CLI, so that I can begin creating APIs for my databases.
---

# Install the Data API builder command-line interface

In this guide, you go through the steps to install the Data API builder (DAB) command-line interface (CLI) on your local machine. You can then use the CLI to perform the most common actions with DAB. The CLI is distributed as a .NET tool.

## Prerequisites

- [.NET 8](https://dotnet.microsoft.com/download/dotnet/8.0)

## Install the CLI

[!INCLUDE[Install CLI](../includes/install-cli.md)]

## Verify that the CLI is installed

Installing the .NET tool makes the `dab` command available on your local machine.

Use the `--version` argument to determine the version of your current installation.

```bash
dab --version
```

```cmd
dab --version
```

> [!IMPORTANT]
> If you are running on Linux or macOS, you could see an error when invoking `dab` directly. To resolve this error, add the .NET global tools to your `PATH`. For more information, see [troubleshooting Data API builder installation](../troubleshoot-installation.md).

Observe the output of the previous command. Assuming the current version of the DAB CLI is `1.0.0`, the command output would include the following content.

```output
Microsoft.DataApiBuilder 1.0.0
```
