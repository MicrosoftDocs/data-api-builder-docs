---
title: Use @env function in configuration
description: Use environment function in the configuration file to reference environment data dynamically
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 09/26/2025
# Customer Intent: As a developer, I want to use configuration functions like @env() to make my DAB config portable and secure
---

# Using @env() for environment variable substitution in Data API builder

Data API builder (DAB) lets you keep secrets (for example, database connection strings) out of `dab-config.json` by substituting values at load time. The first supported mechanism is the `@env()` function, which resolves environment variables from the host process environment or a local `.env` file.

See also: [the @akv() function](./akv-function.md).

## What @env() does

Place a reference to an environment variable anywhere a string value is expected:

```json
{
  "data-source": {
    "connection-string": "@env('SQL_CONN_STRING')"
  }
}
```

At configuration load time, DAB scans string values for the `@env('VAR_NAME')` pattern and replaces the token with the value of the environment variable `VAR_NAME`.

## Sources for values

| Source                   | Description                                                                                                  |
| ------------------------ | ------------------------------------------------------------------------------------------------------------ |
| OS / process environment | Standard environment variables present when the DAB process starts.                                          |
| `.env` file              | A plaintext file with `NAME=VALUE` lines in the configuration directory (for local development convenience). |

> [!Note]
> The `.env` file overrides existing process/system environment variables when both define the same name.
> If you provide a local `.env` file for development, its entries are used to satisfy @env('var-name') lookups without making a call to the local environment. 

### Example `.env` file:

```
SQL_CONN_STRING=Server=localhost;Database=AppDb;User Id=app;Password=local-dev;
DB_TYPE=mssql
JOB_API_KEY=dev-job-key
```

### Guidelines:

* Keep `.env` adjacent to `dab-config.json` (or wherever your startup process expects it).
* Add `.env` to `.gitignore`.
* Blank lines and lines beginning with `#` (if supported, verify) are typically ignored; confirm before documenting comment support.
* On Linux/macOS, names are case-sensitive. On Windows, they are effectively case-insensitive.

## Using @env() in configuration

### Basic substitution

```json
{
  "data-source": {
    "database-type": "@env('DB_TYPE')",
    "connection-string": "@env('SQL_CONN_STRING')"
  }
}
```

### Combined with @akv()

```json
{
  "data-source": {
    "database-type": "@env('DB_TYPE')",
    "connection-string": "@akv('prod-sql-connection')"
  }
}
```

### Stored procedure parameters

```json
{
  "entities": {
    "RunJob": {
      "source": {
        "object": "dbo.RunJob",
        "type": "stored-procedure",
        "parameters": {
          "intParam": "@env('SP_PARAM1_INT')",
          "boolParam": "@env('SP_PARAM2_BOOL')"
        }
      },
      "permissions": [
        { "role": "anonymous", "actions": [ "execute" ] }
      ]
    }
  }
}
```

Environment values are substituted as strings. Subsequent parsing (for example, to int or bool) is handled by the consuming configuration or runtime logic.

## Troubleshooting

| Scenario                                                    | Outcome                                                                  |
| ----------------------------------------------------------- | ------------------------------------------------------------------------ |
| Variable found                                            | Substitution succeeds.                                                   |
| Variable absent                                             | Likely configuration load fails.           |
| Variable not found                                  | Substituted as empty string.          |
| Multiple `@env()` in different properties                   | All resolved independently.                                              |
| Used where numeric or bool expected                         | Value substituted as string; parsing may succeed. |
| Invalid pattern (for example `@env(DB_VAR)` missing quotes) | Treated as a literal string.  |

## Full example

`dab-config.json`:

```json
{
  "data-source": {
    "database-type": "@env('DB_TYPE')",
    "connection-string": "@env('SQL_CONN_STRING')"
  },
  "runtime": {
    "rest": { "enabled": true }
  },
  "entities": {
    "Books": {
      "source": "dbo.Books",
      "permissions": [
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

`.env`:

```
DB_TYPE=mssql
SQL_CONN_STRING=Server=localhost;Database=BooksDb;User Id=app;Password=StrongPassword!;
```

> [!Important]
> Do not commit `.env` files containing secrets.                                                |

## Quick reference

| Item                     | Summary                                                                  |
| ------------------------ | ------------------------------------------------------------------------ |
| Syntax                   | `@env('variable-name')`                                                    |
| Simulation file          | `.env` with `name=value` lines                                           |
| Mixing with `@env()` | Supported.                                                                  |

## Review

Use `@env()` to keep secrets and environment-specific values out of configuration files. Pair it with disciplined secret management, such as CI/CD variable stores or container definitions, for a secure and flexible deployment. For enterprise vault usage, combine with [the `@akv()` function](./akv-function.md) to centralize secrets.
