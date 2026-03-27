---
title: Start the runtime with the DAB CLI
description: Use the Data API builder (DAB) CLI to start the runtime and serve APIs based on your configuration.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/04/2026
# Customer Intent: As a developer, I want to start the Data API builder runtime, so that my APIs become available for requests.
---

# `start` command

Start the Data API builder runtime with an existing configuration file.

## Syntax

```sh
dab start [options]
```

### Quick glance

| Option                                        | Summary                                                                                            |
| --------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| [`-c, --config`](#-c---config)                | Use a specific config file (defaults to `dab-config.json` or environment-specific file if present) |
| [`--LogLevel <level>`](#--loglevel-level)     | Specifies logging level as provided value.                                                         |
| [`--mcp-stdio`](#--mcp-stdio)                 | *(Model Context Protocol (MCP))* Starts DAB as an MCP server that uses standard input and output (STDIO) instead of HTTP. Requires `mcp.enabled: true` in config. |
| [`--no-https-redirect`](#--no-https-redirect) | Disables automatic HTTP→HTTPS redirection                                                          |
| [`--help`](#--help)                           | Display the help screen.                                                                           |
| [`--version`](#--version)                     | Display version information.                                                                       |

## `-c, --config`

Path to config file. Defaults to `dab-config.json` unless `dab-config.<DAB_ENVIRONMENT>.json` exists, where `DAB_ENVIRONMENT` is an environment variable.

### Example

#### [Bash](#tab/bash)

```bash
dab start \
  --config ./settings/dab-config.json
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start ^
  --config .\settings\dab-config.json
```

---

## `--LogLevel <level>`

Specifies logging level as provided value. For possible values, see [Log levels](https://go.microsoft.com/fwlink/?linkid=2263106).

### Example

#### [Bash](#tab/bash)

```bash
dab start \
  --LogLevel Warning
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start ^
  --LogLevel Warning
```

---

## `--no-https-redirect`

Disables automatic HTTP→HTTPS redirection.

### Example

#### [Bash](#tab/bash)

```bash
dab start \
  --no-https-redirect
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start ^
  --no-https-redirect
```

---

## `--mcp-stdio`

> [!NOTE]
> This option is a **Model Context Protocol (MCP) feature** available in release `1.7` and later. It requires `"mcp": { "enabled": true }` in the `runtime` section of your `dab-config.json`. For full MCP configuration details, see [SQL MCP Server overview](../mcp/overview.md).

Starts Data API builder as an MCP server that uses standard input and output instead of binding to an HTTP port. In this mode, DAB communicates with an MCP client (such as GitHub Copilot, Visual Studio (VS) Code, or any MCP-compatible AI agent) entirely over `stdin` and `stdout` by using the [Model Context Protocol](https://modelcontextprotocol.io/). No HTTP server or network port is exposed.

This flag also accepts an optional positional `role:<role-name>` argument that specifies the DAB permission role under which all MCP tool calls execute. The role must match a name defined in the `permissions` section of your entity configuration. If omitted, the role defaults to `anonymous`.

When `--mcp-stdio` is active, the following behaviors are applied automatically regardless of your config file settings:

- **Encoding**: Console input/output is forced to UTF-8 without a byte order mark (BOM) for clean JSON-over-standard input/output communication.
- **Authentication**: The authentication provider is forced to **Simulator** mode, enabling the specified role without requiring a real JSON Web Token (JWT) or identity provider.
- **No HTTP host**: DAB doesn't bind to any Transmission Control Protocol (TCP) port. The MCP server runs entirely over stdin/stdout.

> [!IMPORTANT]
> The `role:<name>` prefix is required. If the role name doesn't match a role defined in your entity permissions, MCP tool calls are denied.

### Required config

MCP must be enabled in your `dab-config.json` before using `--mcp-stdio`:

```json
"runtime": {
  "mcp": {
    "enabled": true,
    "path": "/mcp",
    "dml-tools": {
      "create-record": true,
      "read-records": true,
      "update-record": true,
      "delete-record": true
    }
  }
}
```

### Example

#### [Bash](#tab/bash)

```bash
# Default anonymous role
dab start \
  --mcp-stdio \
  --config ./dab-config.json

# Specific role
dab start \
  --mcp-stdio role:authenticated \
  --config ./dab-config.json

# With logging
dab start \
  --mcp-stdio role:api-reader \
  --config ./dab-config.json \
  --LogLevel Information
```

#### [Command Prompt](#tab/cmd)

```cmd
:: Default anonymous role
dab start ^
  --mcp-stdio ^
  --config .\dab-config.json

:: Specific role
dab start ^
  --mcp-stdio role:authenticated ^
  --config .\dab-config.json

:: With logging
dab start ^
  --mcp-stdio role:api-reader ^
  --config .\dab-config.json ^
  --LogLevel Information
```

---

### MCP client configuration

Because DAB runs as a subprocess that communicates over standard input and output, your MCP client must launch DAB as a child process and pipe `stdin` and `stdout`. A typical MCP client configuration for Visual Studio (VS) Code or a compatible agent looks like:

```json
{
  "servers": {
    "my-database": {
      "type": "stdio",
      "command": "dab",
      "args": [
        "start",
        "--mcp-stdio",
        "role:anonymous",
        "--config",
        "./dab-config.json"
      ]
    }
  }
}
```

For a complete walkthrough, see [standard input and output transport for SQL MCP Server](../mcp/stdio-transport.md).

---

## `--help`

Display the help screen.

### Example

#### [Bash](#tab/bash)

```bash
dab start --help
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start --help
```

---

## `--version`

Display version information.

### Example

#### [Bash](#tab/bash)

```bash
dab start --version
```

#### [Command Prompt](#tab/cmd)

```cmd
dab start --version
```

---
