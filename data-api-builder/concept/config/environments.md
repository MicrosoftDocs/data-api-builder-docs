---
title: Use configuration file environments in Data API builder  
description: Learn how to use environments in Data API builder to manage configuration differences between development and production.  
author: seesharprun  
ms.author: sidandrews  
ms.reviewer: jerrynixon  
ms.service: data-api-builder  
ms.topic: how-to  
ms.date: 06/11/2025  
# Customer Intent: As a developer, I want to manage configuration differences between development and production environments.  
---

# Use configuration file environments in Data API builder

Data API builder supports multiple configuration environments, similar to ASP.NET Core's `appsettings.json`. You can define a base configuration (`dab-config.json`) and environment-specific variants (`dab-config.Development.json`, `dab-config.Production.json`). This feature enables the flexible management of connection strings, authentication settings, and other configuration changes across environments.

## Step 1: Create a base configuration

### Create a `.env` file

```env
DEV_CONNECTION_STRING=Server=tcp:127.0.0.1,1433;User ID=<username>;Password=<password>;
PROD_CONNECTION_STRING=Server=tcp:127.0.0.1,1433;User ID=<username>;Password=<password>;
```

> [!NOTE]
> The `.env` file has no filename, only an extension. Exclude it from source control to protect secrets.

### Run `dab init` to create the base configuration file

```bash
dab init --database-type "mssql" --connection-string ""
dab add Book --source "dbo.Books" --permissions "anonymous:*"
```

This step produces a basic `dab-config.json` file that is shared across all environments.

## Step 2: Add environment-specific configuration files

```
- dab-config.json
- dab-config.Development.json
- dab-config.Production.json
```

### Development configuration file (`dab-config.Development.json`)

```json
{
  "data-source": {
    "connection-string": "@env('DEV_CONNECTION_STRING')"
  }
}
```

### Production configuration file (`dab-config.Production.json`)

```json
{
  "data-source": {
    "connection-string": "@env('PROD_CONNECTION_STRING')"
  }
}
```

> [!NOTE]
> Environment-specific files override the base configuration when `DAB_ENVIRONMENT` is set.

## Step 3: Start DAB with the correct environment

Use this command to set the environment to `Development`:

```bash
DAB_ENVIRONMENT=Development dab start
```

Use this command to set the environment to `Production`:

```bash
DAB_ENVIRONMENT=Production dab start
```

> [!NOTE]
> If no environment is set, the default environment is `Production`.

## Step 4: Verify setup

* REST: `http://localhost:5000/api/Book`
* GraphQL: `http://localhost:5000/graphql`
* Swagger: `http://localhost:5000/swagger`
* Health: `http://localhost:5000/health`

## Review

* Keep `.env` files out of version control (`.gitignore`)
* Use [`@env()`](../config/env-function.md) or [`@akv()`](../config/akv-function.md) for secrets
* Use `DAB_ENVIRONMENT` to switch between environments easily