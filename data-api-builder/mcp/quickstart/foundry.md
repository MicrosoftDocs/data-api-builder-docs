---
title: Quickstart - Connect SQL MCP Server to Microsoft Foundry
description: Deploy SQL MCP Server to Azure Container Apps and connect it to Microsoft Foundry agents using the Chat Playground.
author: jnixon
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 12/09/2025
---

# Quickstart: Connect SQL MCP Server to Microsoft Foundry

> [!IMPORTANT]
> The SQL MCP Server is in preview and this documentation and the engine implementation is subject to change during this evaluation period.

This quickstart shows you how to connect a deployed SQL MCP Server to Microsoft Foundry (Azure AI Foundry) using a Custom MCP Tool. You test everything using the Chat Playground with the GPT-5-mini model - no coding required.

> [!NOTE]
> Microsoft Foundry is in preview. You need to select the "new" Foundry experience in the header when you access https://ai.azure.com.

## Prerequisites

### 1. Deployed SQL MCP Server

You need a SQL MCP Server deployed to Azure Container Apps. If you haven't deployed one yet, complete the [Deploy SQL MCP Server to Azure Container Apps](azure-container-apps.md) quickstart first.

You need the MCP endpoint URL from that deployment (for example, `https://your-app.azurecontainerapps.io/mcp`).

### 2. Microsoft Foundry project

You need access to Microsoft Foundry with an existing project and a deployed GPT-5-mini model.

## Step 1: Access Microsoft Foundry

1. Navigate to https://ai.azure.com
2. In the header, select the **new Foundry experience** (preview toggle)
3. Select your Foundry project
4. In the left navigation, select **Playground**

## Step 2: Create or open an agent

1. Select an existing agent or create a new one
2. In the agent configuration, locate the **Tools** section on the left panel

## Step 3: Add a Model Context Protocol tool

1. In the **Tools** section, select **Add** (the button may show a dropdown or **+** icon)
2. Select **Add a new tool** from the dropdown
3. The **Select a tool** dialog opens with three tabs: **Configured**, **Catalog**, and **Custom**
4. Select the **Custom** tab at the top
5. Select **Model Context Protocol (MCP)** from the available options
6. Select **Create** to proceed

## Step 4: Configure your MCP connection

The **Add Model Context Protocol tool** dialog appears. Fill in the following information:

**Name** (required):

- Enter a unique name: `AcunsoInc`

**Remote MCP Server endpoint** (required):

- Enter your MCP server URL: `https://<your-container-app-url>/mcp` (from your ACA deployment)

**Authentication** (required):

- Select **Unauthenticated** from the dropdown

> [!NOTE]
> This works because the quickstart configured `anonymous:read` permissions. SQL MCP Server doesn't support Key-based or Passthrough authentication modes.

Select **Connect** to add the tool.

## Step 5: Configure agent instructions

In the **Instructions** section at the top of the agent configuration, add or replace the text with:

```text
You are a helpful product catalog assistant. When answering questions about products, use the products-mcp tool to query the database. 

The Products entity contains:
- ProductName: Name of the product
- Category: Product category (Electronics, Furniture, Office Supplies, Appliances)  
- UnitPrice: Price in USD
- UnitsInStock: Current inventory count
- Discontinued: Whether the product is still available

Always use describe_entities first to understand the schema, then use read_records to query the data.
```

## Step 6: Test your agent

Try these prompts in the chat:

**Example 1: Schema discovery**

```text
What products are available?
```

The agent should call `describe_entities` to see the Products entity structure.

**Example 2: Simple query**

```text
List all electronics products
```

The agent should call `read_records` with a filter for Category = 'Electronics'.

**Example 3: Price query**

```text
Show me products under $50
```

The agent should query products where UnitPrice < 50.

**Example 4: Inventory check**

```text
Which products are low in stock (less than 50 units)?
```

The agent should filter UnitsInStock < 50.

**Example 5: Complex query**

```text
What's the most expensive furniture item, and do we have it in stock?
```

The agent should:
1. Call `read_records` filtered by Category = 'Furniture'
2. Sort by UnitPrice descending
3. Check UnitsInStock

## Step 7: View tool calls

In the Chat Playground, you see the agent's reasoning and tool calls:

1. **Tool called**: `describe_entities` or `read_records`
2. **Arguments**: The parameters passed (filters, fields, etc.)
3. **Response**: The data returned from your SQL database

## Troubleshooting

**Issue: Tool not appearing in Foundry**

- Verify the MCP URL is correct and accessible
- Check that the Container App is running (see [monitoring guidance](azure-container-apps.md#monitoring-and-troubleshooting))
- Test the `/mcp` endpoint directly

**Issue: Tool calls require approval**

- In the MCP tool configuration, ensure **Require approval** is set to `never`

**Issue: Agent not using the tool**

- Check your system message includes clear instructions about when to use the tool
- Try asking more specific questions that relate to the Products data

For deployment issues, see the [troubleshooting section](azure-container-apps.md#monitoring-and-troubleshooting) in the Azure Container Apps deployment guide.

## Next steps

- [Add more entities to your MCP server](../descriptions.md)
- [Run SQL MCP Server locally with VS Code](visual-studio-code.md)
- [Run SQL MCP Server with .NET Aspire](dotnet-aspire.md)
- [Learn about MCP tools in Foundry](https://learn.microsoft.com/azure/ai-foundry/agents/concepts/tool-catalog)

## Related content

- [SQL MCP Server Overview](../introduction.md)
- [Deploy to Azure Container Apps](azure-container-apps.md)
- [Microsoft Foundry documentation](https://learn.microsoft.com/azure/ai-foundry/)
