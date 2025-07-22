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

This function is commonly used for secrets or values that differ between environments (for example, dev, test, prod).

## Setting environment variables

There are two supported approaches:

### 1. System environment variables

Set environment variables in your operating system environment. DAB resolves these at runtime.

### 2. `.env` file (recommended)

Place a `.env` file in the same directory as your configuration file.

Example `.env`:

```env
SQL_CONN_STRING=Server=localhost;User ID=user;Password=pass;
DAB_ENVIRONMENT=Development
```

DAB loads this file when starting up, making the variables available for use with `@env()`.

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

This setup keeps secrets out of source control and allows you to switch environments by changing your `.env` file or system variables.

## Benefits

* Keeps configuration DRY and portable
* Improves security by avoiding secrets in config files
* Enables environment-specific overrides

## Limitations

* Only supports string values
* Environment variables must exist at runtime or DAB won't start
* Doesn't support computed values or fallback/defaults
