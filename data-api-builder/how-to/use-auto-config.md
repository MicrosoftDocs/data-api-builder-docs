---
title: Use auto configuration to generate entity definitions in DAB
description: Learn how to use the Data API builder (DAB) CLI auto-config and auto-config-simulate commands to automatically generate entity definitions from an existing SQL Server database.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/26/2026
# Customer Intent: As a developer, I want to use dab auto-config to generate entity definitions from my existing SQL Server schema so I can avoid writing entity blocks manually.
---

# Use auto configuration to generate entity definitions

Auto configuration lets you define pattern-based rules that automatically expose matching SQL Server objects as Data API builder (DAB) entities. Instead of writing one entity block per table or view, you define one or more `autoentities` definitions with include patterns, a naming template, and permissions. DAB resolves the patterns at startup and creates entities dynamically.

This guide walks through initializing a DAB configuration, previewing matched objects with `dab auto-config-simulate`, and committing the patterns with `dab auto-config`.

> [!IMPORTANT]
> Auto configuration currently supports **MSSQL** data sources only.

## Prerequisites

- [DAB CLI installed](../command-line/install.md)
- SQL Server instance with an existing schema
- A database user with read access to the target schema

## Initialize the configuration

If you don't already have a DAB configuration file, create one with `dab init`.

### [Bash](#tab/bash-cli)

```bash
dab init \
  --database-type mssql \
  --connection-string "Server=localhost,1433;Initial Catalog=MyDb;User Id=myUser;Password=myPassword;TrustServerCertificate=true;"
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab init ^
  --database-type mssql ^
  --connection-string "Server=localhost,1433;Initial Catalog=MyDb;User Id=myUser;Password=myPassword;TrustServerCertificate=true;"
```

---

This creates a `dab-config.json` file with the `data-source` section populated. The `entities` section is empty.

## Preview matched objects

Before committing patterns to the configuration, use `dab auto-config-simulate` to preview which database objects match your patterns. The command connects to the database, evaluates each pattern, and prints results. No changes are written.

### [Bash](#tab/bash-cli)

```bash
dab auto-config-simulate \
  --config ./dab-config.json
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab auto-config-simulate ^
  --config ./dab-config.json
```

---

The console output lists each matched object and the entity name it would receive.

```text
AutoEntities Simulation Results

Filter: (default)
Matches: 5
  dbo_Products   →  dbo.Products
  dbo_Customers  →  dbo.Customers
  dbo_Orders     →  dbo.Orders
  dbo_OrderItems →  dbo.OrderItems
  dbo_Inventory  →  dbo.Inventory
```

### Refine with include and exclude patterns

If the default `%.%` pattern matches objects you don't want to expose, add explicit include and exclude patterns and re-run simulate to verify.

### [Bash](#tab/bash-cli)

```bash
dab auto-config-simulate \
  --config ./dab-config.json
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab auto-config-simulate ^
  --config ./dab-config.json
```

---

The patterns are evaluated against the database on each run. Iterate until the output matches your intent.

### Save results to a CSV file

Use `--output` to write simulation results to a CSV (Comma Separated Values) file. This approach is useful in CI/CD pipelines where you want to audit or diff the matched object list.

### [Bash](#tab/bash-cli)

```bash
dab auto-config-simulate \
  --output simulate-results.csv
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab auto-config-simulate ^
  --output simulate-results.csv
```

---

The CSV includes `filter_name`, `entity_name`, and `database_object` columns.

```csv
filter_name,entity_name,database_object
my-def,dbo_Products,dbo.Products
my-def,dbo_Customers,dbo.Customers
my-def,dbo_Orders,dbo.Orders
```

## Add an auto-config definition

When the simulation results look correct, use `dab auto-config` to write the `autoentities` definition to the configuration file.

The following example includes all objects in the `dbo` schema, excludes objects whose names start with `staging`, names entities using the `{schema}_{object}` format, enables REST and GraphQL, and grants anonymous read access.

### [Bash](#tab/bash-cli)

```bash
dab auto-config my-api \
  --patterns.include "dbo.%" \
  --patterns.exclude "dbo.staging%" \
  --patterns.name "{schema}_{object}" \
  --template.rest.enabled true \
  --template.graphql.enabled true \
  --permissions "anonymous:read"
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab auto-config my-api ^
  --patterns.include "dbo.%" ^
  --patterns.exclude "dbo.staging%" ^
  --patterns.name "{schema}_{object}" ^
  --template.rest.enabled true ^
  --template.graphql.enabled true ^
  --permissions "anonymous:read"
```

---

The resulting configuration in `dab-config.json` looks like this:

```json
{
  "autoentities": {
    "my-api": {
      "patterns": {
        "include": [ "dbo.%" ],
        "exclude": [ "dbo.staging%" ],
        "name": "{schema}_{object}"
      },
      "template": {
        "rest": { "enabled": true },
        "graphql": { "enabled": true }
      },
      "permissions": [
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

> [!NOTE]
> When `autoentities` is present, the `entities` section is no longer required. DAB accepts either `autoentities` or `entities` (or both).

## Verify at startup

Start DAB and check the startup log to confirm entities are resolved from the pattern.

### [Bash](#tab/bash-cli)

```bash
dab start
```

### [Command Prompt](#tab/cmd-cli)

```cmd
dab start
```

---

DAB evaluates patterns against the live database at startup. New tables that match your include patterns are automatically added as entities without any configuration change.

## Related content

- [Auto configuration concepts](../concept/config/auto-config.md)
- [`dab auto-config` command reference](../command-line/dab-auto-config.md)
- [`dab auto-config-simulate` command reference](../command-line/dab-auto-config-simulate.md)
- [`Autoentities` configuration reference](../configuration/autoentities.md)
- [What's new in version 2.0](../whats-new/version-2-0.md)
