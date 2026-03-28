---
title: Configure custom MCP tools for stored procedures
description: Learn how to expose SQL Server stored procedures as named Model Context Protocol (MCP) tools in Data API builder so AI agents can call them directly by name.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/26/2026
# Customer Intent: As a developer, I want to expose my SQL Server stored procedures as named MCP tools so that AI agents can call them directly without writing SQL.
---

# Configure custom MCP tools for stored procedures

[!INCLUDE[Note - SQL MCP availability](includes/note-availability.md)]

[!INCLUDE[Note - SQL MCP Server 2.0 preview](includes/note-sql-mcp-server-2-preview.md)]

SQL MCP Server exposes tables and views through generic data manipulation language (DML) tools. For stored procedures, you can go further: set `custom-tool: true` on the entity so the procedure appears in the MCP tool list as a named, purpose-built tool. AI agents discover it by name, see its parameters, and call it directly—no SQL required.

The rest of this article shows how to add, configure, and test a custom MCP tool backed by a stored procedure.

## Prerequisites

- Data API builder version 2.0 or later
- SQL Server database with at least one stored procedure
- An existing `dab-config.json` with MCP enabled
- [DAB CLI installed](../command-line/install.md)

## Enable MCP in your configuration

If you haven't already, enable MCP in the runtime section.

```bash
dab configure --runtime.mcp.enabled true
```

This adds the following to your `dab-config.json`:

```json
{
  "runtime": {
    "mcp": {
      "enabled": true
    }
  }
}
```

## Add the stored procedure as a custom tool

Use `dab add` with `--source.type stored-procedure` and `--mcp.custom-tool true`.

### [Bash](#tab/bash-cli)

```bash
dab add GetProductById \
  --source dbo.get_product_by_id \
  --source.type "stored-procedure" \
  --permissions "anonymous:execute" \
  --mcp.custom-tool true
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab add GetProductById ^
  --source dbo.get_product_by_id ^
  --source.type "stored-procedure" ^
  --permissions "anonymous:execute" ^
  --mcp.custom-tool true
```

---

This produces the following entity in `dab-config.json`:

```json
{
  "entities": {
    "GetProductById": {
      "source": {
        "object": "dbo.get_product_by_id",
        "type": "stored-procedure"
      },
      "graphql": {
        "enabled": true,
        "operation": "mutation",
        "type": {
          "singular": "GetProductById",
          "plural": "GetProductByIds"
        }
      },
      "rest": {
        "enabled": true,
        "methods": [
          "post"
        ]
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "execute"
            }
          ]
        }
      ],
      "mcp": {
        "custom-tool": true
      }
    }
  }
}
```

> [!IMPORTANT]
> The `custom-tool` property is only valid on stored-procedure entities. Setting it on a table or view entity results in a configuration error at startup.

## Add a description to improve agent accuracy

Without a description, agents see only the technical name `GetProductById`. With a description, they understand what it does and when to use it.

### [Bash](#tab/bash-cli)

```bash
dab update GetProductById \
  --description "Returns full product details including pricing and inventory for a given product ID"
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab update GetProductById ^
  --description "Returns full product details including pricing and inventory for a given product ID"
```

---

```json
{
  "entities": {
    "GetProductById": {
      "description": "Returns full product details including pricing and inventory for a given product ID",
      "source": {
        "object": "dbo.get_product_by_id",
        "type": "stored-procedure"
      },
      "fields": [],
      "graphql": {
        "enabled": true,
        "operation": "mutation",
        "type": {
          "singular": "GetProductById",
          "plural": "GetProductByIds"
        }
      },
      "rest": {
        "enabled": true,
        "methods": [
          "post"
        ]
      },
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "execute"
            }
          ]
        }
      ],
      "mcp": {
        "custom-tool": true
      }
    }
  }
}
```

## Verify the tool appears in the tool list

Start DAB and call the `tools/list` MCP endpoint to confirm the tool is registered.

### [Bash](#tab/bash-cli)

```bash
dab start
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab start
```

---

When an MCP client calls `tools/list`, the response includes your custom tool alongside the DML tools:

```json
{
  "tools": [
    {
      "name": "GetProductById",
      "description": "Returns full product details including pricing and inventory for a given product ID",
      "inputSchema": {
        "type": "object",
        "properties": {
          "productId": { "type": "integer" }
        },
        "required": [ "productId" ]
      }
    }
  ]
}
```

The parameter names and types are derived from the stored procedure signature. DAB reads the procedure's input parameters from the database at startup.

## Configure multiple custom tools

You can register multiple stored procedures as custom tools in the same configuration.

### [Bash](#tab/bash-cli)

```bash
dab add SearchProducts \
  --source dbo.search_products \
  --source.type "stored-procedure" \
  --permissions "anonymous:execute" \
  --mcp.custom-tool true \
  --description "Full-text search across product names and descriptions"

dab add GetOrderSummary \
  --source dbo.get_order_summary \
  --source.type "stored-procedure" \
  --permissions "authenticated:execute" \
  --mcp.custom-tool true \
  --description "Returns order totals and line item counts for a given customer"
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab add SearchProducts ^
  --source dbo.search_products ^
  --source.type "stored-procedure" ^
  --permissions "anonymous:execute" ^
  --mcp.custom-tool true ^
  --description "Full-text search across product names and descriptions"

dab add GetOrderSummary ^
  --source dbo.get_order_summary ^
  --source.type "stored-procedure" ^
  --permissions "authenticated:execute" ^
  --mcp.custom-tool true ^
  --description "Returns order totals and line item counts for a given customer"
```

---

## Control which roles can call the tool

Custom tools respect the same role-based access control (RBAC) as all other DAB entities. Set the `permissions` on the entity to restrict which roles can execute the procedure.

```json
{
  "entities": {
    "GetOrderSummary": {
      "source": {
        "object": "dbo.get_order_summary",
        "type": "stored-procedure"
      },
      "graphql": {
        "enabled": true,
        "operation": "mutation",
        "type": {
          "singular": "GetOrderSummary",
          "plural": "GetOrderSummarys"
        }
      },
      "rest": {
        "enabled": true,
        "methods": [
          "post"
        ]
      },
      "permissions": [
        {
          "role": "authenticated",
          "actions": [
            {
              "action": "execute"
            }
          ]
        }
      ],
      "mcp": {
        "custom-tool": true
      }
    }
  }
}
```

When an agent calls with the `anonymous` role, `GetOrderSummary` doesn't appear in `tools/list` and any direct `tools/call` returns a permission error.

## Disable a custom tool without removing it

Set `custom-tool` to `false` to hide the tool from agents without deleting the entity.

### [Bash](#tab/bash-cli)

```bash
dab update GetProductById \
  --mcp.custom-tool false
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab update GetProductById ^
  --mcp.custom-tool false
```

---

The entity remains in the configuration and you can re-enable it later by setting `--mcp.custom-tool true`.

## Related content

- [Data manipulation language (DML) tools](data-manipulation-language-tools.md)
- [Add descriptions to entities](how-to-add-descriptions.md)
- [`dab add` command reference](../command-line/dab-add.md)
- [`dab update` command reference](../command-line/dab-update.md)
- [What's new in version 2.0](../whats-new/version-2-0.md#introducing-custom-mcp-tools)
