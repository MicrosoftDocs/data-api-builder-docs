---
title: DAB Code Gen extension
description: Generate C# model and repository scaffolding from Data API builder configuration files.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/10/2026
---

# DAB Code Gen extension

Use the DAB Code Gen extension to generate C# artifacts from selected entities in a DAB configuration.

![Screenshot of DAB Code Gen generated C# project artifacts in the Visual Studio Code explorer.](media/code-gen-screenshot.png)

> [!NOTE]
> Current support is focused on Microsoft SQL Server (`mssql`).

## Command

| Command | Command ID |
|---|---|
| Generate C# | `dabExtension.generateRestClient` |

## Generated outputs

The extension can create a `Gen/` solution with model types, repository helpers, and sample client assets derived from configuration and database metadata.

[!INCLUDE [Related content](includes/related-content.md)]
