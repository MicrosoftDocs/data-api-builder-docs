---
title: DAB Validate extension
description: Validate Data API builder configuration files and review detailed output in Visual Studio Code.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/10/2026
---

# DAB Validate extension

Use the DAB Validate extension to run configuration validation before runtime startup or deployment.

![Screenshot of the DAB Validate command running and reporting validation output in Visual Studio Code.](media/validate-screenshot.png)

## Command

| Command | Command ID |
|---|---|
| DAB Validate | `dabExtension.validateDab` |

## Access

- Explorer: right-click a supported configuration file and select **DAB Validate**.

## Behavior

The extension runs `dab validate` in the configuration directory and streams messages to a dedicated output channel. Validation failures provide quick access to the output for troubleshooting.

[!INCLUDE [Related content](includes/related-content.md)]
