---
title: Stdio transport for SQL MCP Server
description: Learn how to run SQL MCP Server in stdio mode using the dab start --mcp-stdio flag. Connect AI agents such as GitHub Copilot and Visual Studio (VS) Code directly to your database over standard input/output without exposing an HTTP endpoint.
author: jerrynixon
ms.author: jnixon
ms.topic: concept-article
ms.date: 03/04/2026
---

# Stdio transport for SQL MCP Server

[!INCLUDE[Note - SQL MCP availability](includes/note-availability.md)]

SQL MCP Server supports two transports: **streamable HTTP** for hosted and cloud scenarios, and **stdio** for local development and direct agent integration. This article covers the stdio transport.

In stdio mode, Data API builder (DAB) communicates with an MCP client entirely over standard input/output (stdin/stdout). No HTTP server or network port is started. The MCP client launches DAB as a child process and pipes messages back and forth using the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/).

## When to use stdio transport

| Scenario | Recommended transport |
|---|---|
| Local development on a developer workstation | **stdio** |
| VS Code with GitHub Copilot (agent mode) | **stdio** |
| CI/CD pipelines or scripted agent automation | **stdio** |
| Cloud hosting (Container Apps, App Service) | HTTP |
| AI Foundry agent with remote MCP endpoint | HTTP |
| Teams of agents sharing the same endpoint | HTTP |

Choose stdio when you want the simplest possible local setup with no open ports. Choose HTTP when the MCP server needs to be reachable across a network.

## Prerequisites

- Data API builder CLI installed (version 1.7 or later)
- An existing `dab-config.json` with MCP enabled (see [Required configuration](#required-configuration))
- An MCP-compatible client (VS Code with GitHub Copilot, Claude Desktop, or a custom agent)

## Required configuration

Before using stdio transport, enable MCP in your `dab-config.json`:

```json
"runtime": {
  "mcp": {
    "enabled": true,
    "path": "/mcp",
    "dml-tools": {
      "create-record": true,
      "read-records": true,
      "update-record": true,
      "delete-record": true,
      "aggregate-records": true
    }
  }
}
```

The `path` field is used for HTTP transport only and is ignored in stdio mode. The `dml-tools` block controls which data manipulation operations are available as MCP tools.

> [!IMPORTANT]
> If `"mcp": { "enabled": false }` or the `mcp` block is missing, DAB fails to start in stdio mode.

## Start in stdio mode

Use the `--mcp-stdio` flag on `dab start`:

```bash
dab start --mcp-stdio --config ./dab-config.json
```

To run under a specific permission role:

```bash
dab start --mcp-stdio role:authenticated --config ./dab-config.json
```

The `role:<name>` argument is positional and must immediately follow `--mcp-stdio`. If omitted, the role defaults to `anonymous`. The role name must match a role defined in the `permissions` section of at least one entity in your config.

## How stdio mode works

When `--mcp-stdio` is detected, DAB makes the following changes internally:

### UTF-8 encoding (no byte-order mark)

Console input and output are forced to UTF-8 without a byte-order mark (BOM). This UTF-8 setting is required for clean JSON-over-stdio communication because many MCP clients reject BOM-prefixed streams.

### Simulator authentication

The authentication provider is overridden to **Simulator** mode, regardless of what your config file specifies. This Simulator mode lets the specified role be applied directly without a real JSON Web Token (JWT) or identity provider. The Simulator provider is designed for development scenarios and shouldn't be used to secure production HTTP endpoints—but it's exactly right for local stdio sessions.

The following values are applied in-memory and override your config during the session:

| Key | Value |
|---|---|
| `MCP:StdioMode` | `"true"` |
| `MCP:Role` | `"<role-name>"` or `"anonymous"` |
| `Runtime:Host:Authentication:Provider` | `"Simulator"` |

### No HTTP listener

The ASP.NET Core host starts and all services are registered, but DAB calls `stdio.RunAsync()` instead of `host.Run()`. No Transmission Control Protocol (TCP) port is bound. All MCP protocol messages flow through stdin/stdout.

## Available MCP tools

The following tools are available in stdio mode, subject to your `dml-tools` configuration and entity permissions:

| Tool | Description |
|---|---|
| `describe_entities` | Lists available entities and their fields and permissions |
| `create_record` | Inserts a new record (tables only) |
| `read_records` | Reads records from an entity |
| `update_record` | Updates an existing record |
| `delete_record` | Deletes an existing record (tables and views) |
| `execute_entity` | Executes a stored procedure entity |
| `aggregate_records` | Performs aggregation queries on tables and views |

Custom MCP tools backed by stored procedures are also registered when you use `--mcp-stdio`.

## Configure an MCP client for stdio

MCP clients that support stdio transport launch DAB as a subprocess and pipe its stdin/stdout. The client configuration syntax varies by client.

### VS Code (`mcp.json`)

```json
{
  "servers": {
    "sql-mcp-server": {
      "type": "stdio",
      "command": "dab",
      "args": [
        "start",
        "--mcp-stdio", "role:anonymous",
        "--config", "{path}/dab-config.json",
        "--LogLevel", "none"
      ]
    }
  }
}
```

Save this file as `.vscode/mcp.json` inside your project folder. VS Code detects the configuration automatically and shows the server in **MCP: List Servers**. Because the client manages the process lifecycle, you do **not** need to run `dab start` separately in a terminal.

### Claude Desktop (`claude_desktop_config.json`)

```json
{
  "mcpServers": {
    "sql-mcp-server": {
      "type": "stdio",
      "command": "dab",
      "args": [
        "start",
        "--mcp-stdio", "role:anonymous",
        "--config", "{path}/dab-config.json",
        "--LogLevel", "none"
      ]
    }
  }
}
```

## Combine with other `dab start` options

`--mcp-stdio` is compatible with all other `dab start` options:

| Option | Behavior with `--mcp-stdio` |
|---|---|
| `--config` | Uses the specified config file (same as HTTP mode) |
| `--LogLevel` | Applies the specified log level (`none`: recommended for stdio) |

```bash
dab start \
  --mcp-stdio role:api-reader \
  --config ./dab-config.json \
  --LogLevel None
```

## Troubleshoot stdio mode

### `Failed to start the engine in MCP stdio mode.`

DAB couldn't start. Check that:

- Your config file is valid: run `dab validate --config <path>`
- Your database connection string is correct and reachable
- MCP is enabled in your config: `"mcp": { "enabled": true }`

### Permission denied on MCP tool calls

The role specified by `role:<name>` doesn't have the required permissions for the entity and operation. Check the `permissions` section of the relevant entity in your config.

### MCP tools not listed

Either `dml-tools` is set to `false` globally, or the entity has `"dml-tools": false` in its `mcp` settings. Also verify that `mcp.enabled` is `true`.

### Garbled output or JSON parse errors

Ensure nothing in your startup code writes non-JSON text to stdout before the MCP server starts. Log output should go to stderr or a log file, not stdout. Use `--LogLevel` to suppress verbose startup messages if needed.

## Related content

- [`dab start` command reference](../command-line/dab-start.md)
- [SQL MCP Server overview](overview.md)
- [Quickstart: Use SQL MCP Server with Visual Studio Code](quickstart-visual-studio-code.md)
- [Configure authentication for SQL MCP Server](how-to-configure-authentication.md)
- [Data manipulation tools](data-manipulation-language-tools.md)
