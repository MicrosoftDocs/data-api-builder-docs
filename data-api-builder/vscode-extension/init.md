---
title: DAB Init extension
description: Create a new Data API builder configuration file from Visual Studio Code.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/10/2026
---

# DAB Init extension

Use the DAB Init extension to scaffold a new Data API builder configuration file with practical defaults for local development.

![Screenshot of the DAB Init command creating a new configuration file in Visual Studio Code.](media/init-screenshot.png)

## Command

| Command | Command ID |
|---|---|
| DAB Init | `dabExtension.initDab` |

## What the extension does

1. Prompts for database connection details.
1. Chooses the target folder from the Explorer selection or active workspace.
1. Executes `dab init` with development-focused defaults.
1. Opens the generated configuration file in the editor.

If `dab-config.json` already exists, the extension creates an incremented filename (for example, `dab-config-2.json`).

## Access

- Command Palette: `DAB: DAB Init`
- Explorer: right-click a folder, then select **DAB Init**

[!INCLUDE [Related content](includes/related-content.md)]
