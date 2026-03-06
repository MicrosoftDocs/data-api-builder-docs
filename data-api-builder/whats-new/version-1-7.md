---
title: What's new for version 1.7
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 1.7.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: whats-new
ms.date: 03/05/2026
---

# What’s new in Data API builder version 1.7 (March 2026)

Data API builder 1.7 focuses on AI- and tool-driven workflows, clearer metadata, simpler entity configuration, and runtime reliability improvements.

> [!NOTE]
> The 1.7 release line included multiple release candidates (`-rc`) before the stable release (`v1.7.90`) on March 4, 2026.

## Introducing: SQL MCP Server

SQL MCP Server is Data API builder's implementation of Model Context Protocol (MCP) support. Install Data API builder 1.7 or later and enable MCP capabilities and you have SQL MCP Server. First an MCP for Microsoft SQL, SQL MCP Server also supports every backend data source supported by Data API builder, including Cosmos DB, PostgreSQL, and MySQL.

Learn more about [SQL MCP Server](../mcp/overview.md).

### MCP capability and tools

- [MCP Data Manipulation Language (DML) tools](../mcp/data-manipulation-language-tools.md) for interacting with configured entities.
- [MCP standard input/output (`stdio`)](../mcp/index.yml) support for local and host-driven scenarios.

### Permission-aware behavior

MCP behaviors align with DAB authorization, including explicit allowed-operation surfacing and improved role-aware behavior built into Data API builder.

## Introducing: `fields` for entities

The [new `fields` property entities](../mcp/how-to-add-descriptions.md) replaces earlier `mappings` and `key-fields` patterns, simplifying entity field configuration and introducing `description` for each field, important for MCP success. 

```json
{
  "entities": {
    "Products": {
      "description": "Product catalog with pricing information",
      "source": {
        "object": "dbo.Products",
        "type": "table"
      },
      "fields": [ // new array
        {
          "name": "ProductID",
          "description": "Unique identifier for each product",
          "primary-key": true
        },
        {
          "name": "ProductName",
          "description": "Display name of the product"
        },
        {
          "name": "UnitPrice",
          "description": "Retail price per unit in USD"
        }
      ]
    }
  }
}
```

### Command Line

```sh
dab add Products 
    --source dbo.Products 
    --source.type table 
    --permissions "anonymous:*" 
    --description "Product catalog with pricing information"

dab update Products 
    --fields.name ProductID   
    --fields.description "Unique identifier for each product" 
    --fields.primary-key true
dab update Products 
    --fields.name ProductName 
    --fields.description "Display name of the product"       
    --fields.primary-key false
dab update Products 
    --fields.name UnitPrice   
    --fields.description "Retail price per unit in USD"     
    --fields.primary-key false
```

## Introducing: `parameters` for stored procedures

The [new `parameters` property for stored procedures](../mcp/how-to-add-descriptions.md) simplifies parameter configuration and adds `description` for each parameter, improving clarity and MCP-driven interactions.

```json
{
  "entities": {
    "GetOrdersByDateRange": {
      "description": "Retrieves orders",
      "source": {
        "object": "dbo.GetOrdersByDateRange",
        "type": "stored-procedure",
        "parameters": [ // new array
          {
            "name": "StartDate",
            "description": "Beginning of date range (inclusive)",
            "required": true
          },
          {
            "name": "EndDate",
            "description": "End of date range (inclusive)",
            "required": true
          },
          {
            "name": "CustomerID",
            "description": "Optional customer ID filter",
            "required": false,
            "default": null
          }
        ]
      }
    }
  }
}
```

### Command Line

```sh
dab add GetOrdersByDateRange \
  --source dbo.GetOrdersByDateRange \
  --source.type stored-procedure \
  --permissions "authenticated:execute" \
  --description "Retrieves orders" \
  --parameters.name "StartDate,EndDate,CustomerID" \
  --parameters.description "StartDate desc,EndDate desc,CustomerID desc" \
  --parameters.required "true,true,false" \
  --parameters.default ",,null"
```  

## Introducing: Azure Key Vault (AKV) support

This release adds optional support for Azure Key Vault (AKV) for easy value substitution in the DAB configuration file. Using Key Vault is an important option for securely managing secrets and other sensitive configuration values.

```
{
    "my-config-property": "@akv('secret-value')"
}
```

## General improvements and bug fixes

- Improved user-facing error behavior for unnamed aggregate column scenarios
- Stored procedure execution cleanup improvements after request completion
- Fixed nested entity pagination errors in GraphQL queries
- Enabled boolean properties to be configured through environment variables

