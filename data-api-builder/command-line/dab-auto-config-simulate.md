---
title: Auto-config-simulate command reference for DAB CLI
description: Use the Data API builder (DAB) CLI auto-config-simulate command to preview which database objects match your autoentities patterns before committing changes.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/24/2026
# Customer Intent: As a developer, I want to preview which database objects match my autoentities patterns so I can verify include and exclude rules before applying them.
---

# `auto-config-simulate` command

Preview which database objects match the `autoentities` patterns defined in your Data API builder configuration file. The command connects to the database, resolves each pattern, and prints the matched objects. No changes are written to the configuration.

See [Auto configuration concepts](../concept/config/auto-config.md#simulation). 

## Syntax

```sh
dab auto-config-simulate [options]
```

## Quick glance

| Option | Summary |
| --- | --- |
| [`-c, --config`](#-c---config) | Config file path. Default `dab-config.json`. |
| [`-o, --output`](#-o---output) | Path to output CSV file. If not specified, results print to console. |

## `-c, --config`

Path to config file. Defaults to `dab-config.json` unless `dab-config.<DAB_ENVIRONMENT>.json` exists, where `DAB_ENVIRONMENT` is an environment variable.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab auto-config-simulate \
  --config ./dab-config.json
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab auto-config-simulate ^
  --config ./dab-config.json
```

---

## `-o, --output`

Path to output CSV (Comma Separated Values) file. If not specified, results are printed to the console. The CSV includes columns for the filter name, entity name, and database object. This approach is handy when you want to programmatically analyze the results in a CICD (Continuous Integration/Continuous Deployment) pipeline or elsewhere.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab auto-config-simulate \
  --output results.csv
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab auto-config-simulate ^
  --output results.csv
```

---

### Example CSV output

```csv
filter_name,entity_name,database_object
my-def,dbo_Products,dbo.Products
my-def,dbo_Inventory,dbo.Inventory
my-def,dbo_Pricing,dbo.Pricing
```

## Console output

When `--output` isn't specified, results print directly to the console.

### Example

#### [Bash](#tab/bash-cli)

```bash
dab auto-config-simulate
```

#### [Command Prompt](#tab/cmd-cli)

```cmd
dab auto-config-simulate
```

---

### Example console output

```text
AutoEntities Simulation Results

Filter: my-def
Matches: 3
  dbo_Products  →  dbo.Products
  dbo_Inventory →  dbo.Inventory
  dbo_Pricing   →  dbo.Pricing
```

## Related content

- [Auto configuration (concept)](../concept/config/auto-config.md)
- [`dab auto-config` command](dab-auto-config.md)
- [`Autoentities` configuration](../configuration/autoentities.md)
- [What's new in version 2.0](../whats-new/version-2-0.md)
