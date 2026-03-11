---
title: DAB Health extension
description: Check the health endpoint of a running Data API builder instance from Visual Studio Code.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/10/2026
---

# DAB Health extension

Use the DAB Health extension to query the runtime `/health` endpoint and review status in an interactive report.

![Screenshot of the DAB Health extension displaying the health report in Visual Studio Code.](media/health-screenshot.png)

## Command

| Command | Command ID |
|---|---|
| Health Check | `healthDataApiBuilder.healthCheck` |

## Behavior

The extension opens a health report webview and retrieves health data from a local or custom runtime URL. The report includes overall status, runtime details, and check-level timing/threshold information.

[!INCLUDE [Related content](includes/related-content.md)]
