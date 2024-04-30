---
title: Configuration functions
description: List of available functions that can be used to enhance the functionality of Data API builder's configuration file.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 03/20/2024
---

# Functions in Data API builder configuration

Occasionally you need to reference information within your Data API builder configuration file. Functions provide programmatic functionality to reference information for a configuration. This article lists the available functions, describes their functionality, and details usage with examples.

## `@env()`

Access environment data on the local machine. Returns a **string** value.

```json
{
    "<setting-name>": "@env('connection-string-name')"
}
```

This function is often used to access sensitive connection string information from the environment variables on the local machine.

There are two primary ways to set environment variables to use with the Data API builder. First, you can set the environment variable directly on the system. Second, you can create an `.env` file within the same directory as your configuration file. Using an `.env` file is the recommended way to manage environment variables.

### Example

This example `.env` file sets the `DAB_ENVIRONMENT` environment variable to `Development` and the `SQL_CONN_STRING` environment variable to a fictitious value of `Server=localhost;User ID=<user-name>;Password=<password>;`.

```env
SQL_CONN_STRING=Server=localhost;User ID=<user-name>;Password=<password>;
DAB_ENVIRONMENT=Development
```

Now, use the `@env()` function to reference the `SQL_CONN_STRING` environment variable.

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('SQL_CONN_STRING')"
  }
}
```

For more information, see [`data-source` configuration property](reference-configuration.md#data-source).

## Related content

- [Command-line interface (CLI) reference](reference-command-line-interface.md)
- [Configuration reference](reference-configuration.md)
