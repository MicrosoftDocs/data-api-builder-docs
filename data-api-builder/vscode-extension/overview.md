---
title: Data API builder Visual Studio Code extensions overview
description: Use Visual Studio Code extensions to initialize, configure, validate, and run Data API builder projects and SQL Model Context Protocol (MCP) Server workflows.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: overview
ms.date: 03/10/2026
---

# What are Data API builder Visual Studio Code extensions?

Data API builder Visual Studio Code (VS Code) extensions provide a task-focused workflow for creating and operating DAB projects directly from VS Code. You can initialize configuration files, add entities, validate settings, start the runtime, check health, and generate helper assets without leaving your editor.

## Prerequisites

- [Visual Studio Code](https://code.visualstudio.com/)
- [Data API builder CLI](/azure/data-api-builder/command-line/install)

## Included extensions

| Extension | Primary use |
|---|---|
| [DAB Init](init.md) | Create a configuration file with sensible defaults. |
| [DAB Add](add.md) | Add tables, views, procedures, and relationships to a config file. |
| [DAB Start](start.md) | Start the DAB runtime from a selected configuration file. |
| [DAB Validate](validate.md) | Validate configuration and surface issues quickly. |
| [DAB Health](health.md) | Check runtime health information from `/health`. |
| [DAB Visualize](visualize.md) | Generate a Mermaid ER diagram from configuration. |
| [DAB Code Gen](code-gen.md) | Generate C# models and repository scaffolding. |
| [DAB Docker](docker.md) | Build and run DAB in Docker containers. |
| [DAB MCP](mcp.md) | Install DAB configurations as Model Context Protocol (MCP) servers. |

## Typical workflow

1. Run [DAB Init](init.md) to create a configuration file.
1. Use [DAB Add](add.md) to add entities and relationships.
1. Run [DAB Visualize](visualize.md) to inspect schema shape.
1. Run [DAB Validate](validate.md) to verify configuration quality.
1. Run [DAB Start](start.md) and then [DAB Health](health.md).
1. Optionally generate helper code with [DAB Code Gen](code-gen.md).
1. Optionally install MCP servers with [DAB MCP](mcp.md).
1. Optionally run DAB in a local container with [DAB Docker](docker.md).

[!INCLUDE [Related content](includes/related-content.md)]