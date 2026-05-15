---
title: Deploy in air-gapped environments
description: Install and run Data API builder in environments without internet access using offline .NET and NuGet package installation.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: how-to
ms.date: 05/14/2026
# Customer Intent: As a developer in a regulated environment, I want to install Data API builder offline so that I can run it without internet access.
---

# Deploy Data API builder in air-gapped environments

This guide shows you how to install and run Data API builder (DAB) in environments without internet access. Air-gapped deployments are common in healthcare, defense, finance, energy, and maritime environments where outbound network connectivity is restricted or prohibited.

## Prerequisites

- A machine with internet access to download packages (the "staging" machine).
- The target air-gapped machine with a supported operating system.
- A method to transfer files between machines (USB drive, approved file transfer, etc.).

## Step 1: Download packages on the staging machine

On a machine with internet access, download all required packages.

### Download .NET runtime

Download the .NET 9.0 ASP.NET Core runtime binary archive for your target operating system from the [.NET download page](https://dotnet.microsoft.com/download/dotnet/9.0). Choose the **ASP.NET Core Runtime** binary archive (`.tar.gz` for Linux, `.zip` for Windows), not the installer or SDK.

> [!IMPORTANT]
> DAB requires the ASP.NET Core runtime, not just the base .NET runtime. Download the ASP.NET Core binary archive so it can be extracted without an installer.

### [Windows](#tab/windows)

Download the ASP.NET Core Runtime `.zip` from the [.NET 9.0 download page](https://dotnet.microsoft.com/download/dotnet/9.0). Select the **Binaries** column for your target platform (x64).

### [Linux](#tab/linux)

Download the ASP.NET Core Runtime `.tar.gz` from the [.NET 9.0 download page](https://dotnet.microsoft.com/download/dotnet/9.0). Select the **Binaries** column for your target platform (x64).

---

### Download Data API builder package

Use `dotnet tool install` with `--tool-path` to download DAB and all its dependencies into a portable directory:

```dotnetcli
dotnet tool install --tool-path ./dab-tool Microsoft.DataApiBuilder
```

This command creates a self-contained tool directory with all required files.

## Step 2: Transfer files to the air-gapped machine

Copy these items to the target machine:

- The ASP.NET Core Runtime binary archive (`.zip` or `.tar.gz`)
- The `dab-tool` directory containing the DAB tool and all dependencies

## Step 3: Install on the air-gapped machine

### Install .NET runtime

Extract the runtime binary archive. No installer or internet access is required.

### [Windows](#tab/windows)

```powershell
Expand-Archive -Path "aspnetcore-runtime-9.0.x-win-x64.zip" -DestinationPath "C:\dotnet"
$env:DOTNET_ROOT = "C:\dotnet"
$env:PATH = "C:\dotnet;$env:PATH"
```

### [Linux](#tab/linux)

```bash
mkdir -p /opt/dotnet
tar -xzf aspnetcore-runtime-9.0.x-linux-x64.tar.gz -C /opt/dotnet
export DOTNET_ROOT="/opt/dotnet"
export PATH="/opt/dotnet:$PATH"
```

---

### Install Data API builder

The `dab-tool` directory from the staging machine is already self-contained. Add it to your `PATH`:

### [Windows](#tab/windows)

```powershell
$env:PATH = "C:\path\to\dab-tool;$env:PATH"
dab --version
```

### [Linux](#tab/linux)

```bash
export PATH="/path/to/dab-tool:$PATH"
dab --version
```

---

## Step 4: Configure and run

1. Create your configuration file:

    ```dotnetcli
    dab init --database-type mssql --connection-string "Server=<server>;Database=<database>;User ID=<user>;Password=<password>;TrustServerCertificate=true"
    ```

1. Add entities:

    ```dotnetcli
    dab add <entity-name> --source <schema>.<table> --permissions "anonymous:*"
    ```

1. Start DAB:

    ```dotnetcli
    dab start
    ```

## Validate the installation

Verify DAB is running by checking the REST API endpoint:

```bash
curl http://localhost:5000/api/<entity-name>
```

For MCP Server validation, verify the health endpoint responds:

```bash
curl http://localhost:5000/health
```

> [!TIP]
> To test MCP tool calls, use [MCP Inspector](https://github.com/modelcontextprotocol/inspector) or an MCP client library that handles the full MCP protocol initialization handshake.

## Network and firewall considerations

- DAB listens on port `5000` by default. Adjust with `ASPNETCORE_URLS` if needed.
- If using CORS, configure allowed origins in your `dab-config.json`.
- No outbound internet access is required at runtime. DAB operates entirely against local or network-accessible databases.

## Related content

- [Run in a Docker container](local-container.md)
- [Install the CLI](../command-line/install.md)
- [Port resolution](local-container.md#port-resolution)
