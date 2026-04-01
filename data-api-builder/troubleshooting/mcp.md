---
title: SQL MCP Server troubleshooting - Data API builder
description: Troubleshoot common SQL MCP Server transport, permission, and AI client integration issues in Data API builder.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: troubleshooting
ms.date: 03/29/2026
---

# SQL MCP Server troubleshooting

> [!div class="checklist"]
> Solutions for common SQL MCP Server transport configuration, permission, and AI client integration issues in Data API builder.

## Common questions

### What is the SQL MCP Server in DAB?

Data API builder includes a built-in Model Context Protocol (MCP) server that exposes configured database entities as tools that AI agents and language model clients can invoke. The MCP server allows AI clients to query and manipulate data through the same entity and permission model used by the REST and GraphQL endpoints.

### What transport protocols does the MCP server use?

DAB supports two MCP transport modes: `stdio` for local process-based clients and `http` (Server-Sent Events) for remote or networked clients. The transport is configured in `dab-config.json` under `runtime.mcp`. Stdio transport is used by most local AI clients such as VS Code extensions and desktop agents. HTTP transport is used for cloud-hosted clients such as Azure AI Foundry.

### Which AI clients are supported?

Any MCP-compliant client can connect to DAB's MCP server. Tested clients include GitHub Copilot in Visual Studio Code, Azure AI Foundry agents, and other tools that implement the Model Context Protocol specification. Refer to your client's documentation for instructions on registering an MCP server endpoint.

## Common issues

### MCP server not listed in client

**Symptom:** The AI client does not show DAB tools or the MCP server does not appear in the client's server list.

**Cause:** The client is configured for stdio transport but DAB is not registered as an MCP server in the client's configuration file, or the DAB process is not running.

**Resolution:** Add DAB to the client's MCP server configuration. For VS Code GitHub Copilot, add an entry to `.vscode/mcp.json` with the `command` set to `dab` and `args` set to `["start", "--no-https-redirect"]`. Confirm DAB is running and that the `runtime.mcp.enabled` field is set to `true` in `dab-config.json`.

### Tool call fails with permission error

**Symptom:** The AI client receives a permission denied or unauthorized error when invoking a DAB tool.

**Cause:** The anonymous or system role does not have the required action configured for the entity in `dab-config.json`.

**Resolution:** Check the `permissions` array for the entity. Ensure the role used by the MCP client (typically `anonymous` for unauthenticated local use) has the necessary `read`, `create`, `update`, or `delete` actions. Use `dab update --permissions` to add the required actions, then restart DAB.

### Entity descriptions not visible to agent

**Symptom:** The AI agent cannot determine what tools are available or produces incorrect tool calls because it lacks context about the entities.

**Cause:** The entity and field descriptions are not set in `dab-config.json`, so the MCP server exposes tools with no descriptive metadata for the language model to use.

**Resolution:** Add descriptions to each entity and its fields in `dab-config.json` using the `description` property. Clear descriptions improve the language model's ability to select the correct tool and construct valid queries. Use `dab update --description` to set entity-level descriptions from the command line.

### Authentication error connecting from Azure AI Foundry

**Symptom:** An Azure AI Foundry agent fails to authenticate with the DAB MCP server with a `401 Unauthorized` or token validation error.

**Cause:** The DAB host is configured for anonymous access only, or the managed identity of the Foundry agent has not been granted access to the DAB host or the underlying database.

**Resolution:** Configure DAB to accept Microsoft Entra tokens by setting `host.authentication.provider` to `StaticWebApps` or `AzureAD` and providing the correct audience. Ensure the Foundry agent's managed identity is assigned the appropriate role in the DAB permission model and that the identity has database access. For Azure SQL back ends, create a database user for the managed identity with `CREATE USER [agent-identity] FROM EXTERNAL PROVIDER`.

### Aggregations are not available for Cosmos DB entities via MCP tools

**Symptom:** An AI agent attempting to aggregate data (count, sum, average) from a Cosmos DB-backed entity receives no result or an error.

**Cause:** Data API builder does not support aggregation operations for Azure Cosmos DB. MCP tool calls that translate to aggregate queries will fail for Cosmos DB entities. This is a known limitation tracked in [GitHub issue #2849](https://github.com/Azure/data-api-builder/issues/2849).

**Resolution:** Direct the agent to retrieve the full result set and perform aggregations in the calling application or agent logic. Follow the GitHub issue for updates on when Cosmos DB aggregation support is added.
