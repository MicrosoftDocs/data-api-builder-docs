---
title: Use @akv function in configuration
description: Use key vault function in the configuration file to reference environment data dynamically
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 09/26/2025
# Customer Intent: As a developer, I want to use configuration functions like @akv() to make my DAB config portable and secure
---

# Using @akv() for Azure Key Vault secret substitution in Data API builder

Data API builder (DAB) lets you keep secrets, like database connection strings, out of the runtime configuration file by substituting them at load time. Originally this was done with [the `@env()` function](./env-function.md) for environment variables. Beginning with version 1.6, DAB adds support for Azure Key Vault through the `@akv()` function.

## What @akv() does

You can reference a secret stored in Azure Key Vault directly in the configuration JSON:

```json
{
  "data-source": {
    "connection-string": "@akv('my-connection-secret')"
  }
}
```

At configuration load time, DAB resolves the placeholder and replaces it with the secret’s value, similar to how `@env('VAR_NAME')` works. If the secret cannot be retrieved, configuration loading fails. Errors include missing secrets or authorization failures.

## Configuration structure

Add the `azure-key-vault` section at the root level of your configuration:

```json
{
  "azure-key-vault": {
    "endpoint": "https://my-vault-name.vault.azure.net/",
    "retry-policy": {
      "mode": "exponential",
      "max-count": 5,
      "delay-seconds": 2,
      "max-delay-seconds": 30,
      "network-timeout-seconds": 45
    }
  }
}
```

### Properties

| Property       | Required               | Type   | Description                                     |
| -------------- | ---------------------- | ------ | ----------------------------------------------- |
| `endpoint`     | **Yes** if using Key Vault | string | The full Key Vault endpoint URL                 |
| `retry-policy` | No                     | object | Overrides retry behavior when calling Key Vault |

### Retry policy object

| Field                     | Default       | Notes                                                   |
| ------------------------- | ------------- | ------------------------------------------------------- |
| `mode`                    | `exponential` | Allowed values: `fixed` or `exponential`                |
| `max-count`               | 3             | Must be greater than 0                                  |
| `delay-seconds`           | 1             | Must be greater than 0                                  |
| `max-delay-seconds`       | 60            | Must be greater than 0, ceiling for exponential backoff |
| `network-timeout-seconds` | 60            | Must be greater than 0                                  |

### Retry policy modes

| Mode          | Behavior                                                            |
| ------------- | ------------------------------------------------------------------- |
| `fixed`       | Waits a constant `delay-seconds` between attempts until `max-count` |
| `exponential` | Doubles the delay until reaching `max-delay-seconds` or `max-count` |

## Local development: .akv files

For development without an Azure Key Vault, use a `.akv` file to simulate secrets. Format is `name=value` per line:

```
my-connection-secret=Server=.;Database=AppDb;User Id=app;Password=local-dev;
api-key=dev-api-key-123
```

> [!Note]
> If you provide a local `.akv` file for development, its entries are used to satisfy @akv('secret-name') lookups without making a network call to Azure Key Vault. 

### Guidelines:

* Keep `.akv` out of source control
* Secret names must match the names used in `@akv('name')`

## Adding Azure Key Vault settings with CLI

You can configure Key Vault settings using the CLI:

```bash
dab configure \
  --azure-key-vault.endpoint "https://my-vault.vault.azure.net/" \
  --azure-key-vault.retry-policy.mode exponential \
  --azure-key-vault.retry-policy.max-count 5 \
  --azure-key-vault.retry-policy.delay-seconds 2 \
  --azure-key-vault.retry-policy.max-delay-seconds 30 \
  --azure-key-vault.retry-policy.network-timeout-seconds 45 \
  --config dab-config.json
```

### Validation:

* Retry-policy fields without an endpoint cause validation failure
* Optional retry parameters must be positive integers

## Using @akv() in configuration

### Basic substitution

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@akv('primary-sql-connection')"
  }
}
```

### Mixed with @env()

```json
{
  "data-source": {
    "database-type": "@env('DB_TYPE')",
    "connection-string": "@akv('sql-connection')"
  },
  "runtime": {
    "rest": { "enabled": true }
  }
}
```

> [!Note]
> At startup, `@env()` substitutions occur before `@akv()` substitutions.

### Stored procedure parameters

```json
{
  "entities": {
    "RunJob": {
      "source": {
        "object": "dbo.RunJob",
        "type": "stored-procedure",
        "parameters": {
          "apiKey": "@akv('job-runner-apikey')"
        }
      },
      "permissions": [
        { "role": "anonymous", "actions": [ "execute" ] }
      ]
    }
  }
}
```

## Troubleshooting

| Symptom                | Steps                                                                |
| ---------------------- | -------------------------------------------------------------------- |
| Secret not found       | Verify name, existence in vault, and identity permissions            |
| Invalid retry value    | Use a positive integer or remove to use defaults                     |
| Config update fails    | Check logs for validation errors                                     |
| `@akv()` not replaced  | Confirm endpoint, secret name, and that secret resolution is enabled |
| 401/403 from Key Vault | Check identity assignment and permissions                            |

## Full example configuration

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@akv('primary-sql-connection')"
  },
  "azure-key-vault": {
    "endpoint": "https://my-vault.vault.azure.net/",
    "retry-policy": {
      "mode": "exponential",
      "max-count": 5,
      "delay-seconds": 2,
      "max-delay-seconds": 30,
      "network-timeout-seconds": 45
    }
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

### Example `.akv` file:

```
primary-sql-connection=Server=localhost;Database=BooksDb;User Id=app;Password=password;
```

> [!Important]
> Do not commit `.akv` files containing secrets.                                                |

## Quick reference

| Item                     | Summary                                                                  |
| ------------------------ | ------------------------------------------------------------------------ |
| Syntax                   | `@akv('secret-name')`                                                    |
| Endpoint required        | Yes                                                                      |
| Simulation file          | `.akv` with `name=value` lines                                           |
| Mixing with `@env()` | Supported.                                                                  |

## Review

Use `@akv()` to resolve secrets from Azure Key Vault. Configure retry policies for reliability, and use `.akv` files to simulate secrets in development. This keeps sensitive values out of configuration files while supporting consistent development and production workflows.