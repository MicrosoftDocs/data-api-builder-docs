---
title: Use functions in configuration
description: Use functions in the configuration file to reference environment data dynamically
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 07/21/2025
# Customer Intent: As a developer, I want to use configuration functions like @env() to make my DAB config portable and secure
---

# Use functions in configuration

Data API builder supports basic functions within its configuration file to enable more dynamic and portable setups. These functions allow referencing external values like environment variables without hardcoding them.

## Supported functions

### `@env()`

Use `@env()` to reference environment variables at runtime. This function resolves to a **string**.

```json
"connection-string": "@env('SQL_CONN_STRING')"
```

This is commonly used for secrets or values that differ between environments (e.g., dev, test, prod).

## Setting environment variables

There are two supported approaches:

### 1. System environment variables

Set environment variables in your operating system's environment. These are resolved at runtime by DAB.

### 2. `.env` file (recommended)

Place a `.env` file in the same directory as your configuration file.

Example `.env`:

```env
SQL_CONN_STRING=Server=localhost;User ID=user;Password=pass;
DAB_ENVIRONMENT=Development
```

DAB automatically loads this file when starting up, and variables defined here become available for use with `@env()`.

## Example usage

In `dab-config.json`:

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('SQL_CONN_STRING')"
  }
}
```

This enables you to keep secrets out of source control and switch environments by simply changing your `.env` file or system variables.

## Benefits

* Keeps configuration DRY and portable
* Improves security by avoiding secrets in config files
* Enables environment-specific overrides

## Limitations

* Only supports string values
* Environment variable must exist at runtime or DAB will fail to start
* Does not support computed values or fallback/defaults

## Related content

* [Multiple data sources](../../concepts/add-multiple-data-sources.md)
* [Data source configuration](../../configuration/data-source.md)
* [Configuration reference](../../configuration/index.md)
* [Install the CLI](../../how-to/install-cli.md)
