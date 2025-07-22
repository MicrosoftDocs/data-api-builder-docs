---
title: Configuration environments
description: Manage different sets of settings for development or production using the environments capability of configuration files.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 06/11/2025
# Customer Intent: As a developer, I want to use the environments feature, so that I can change which connection strings or other settings I use in development or production.
---

# Configuration environments

The Data API builder configuration file supports multiple environments, mirroring the functionality of ASP.NET Core's `appSettings.json`. This feature enables the use of a base configuration file along with environment-specific files to tailor settings accordingly:

- `dab-config.json` for base configurations
- `dab-config.Development.json` for development-specific configurations
- `dab-config.Production.json` for production-specific configurations

## Setting and selecting environments

Here's the most common things you should consider when setting or selecting environments.

- **Define a Base Configuration:** Begin with the `dab-config.json` file, incorporating all common settings across environments.
- **Create Environment-Specific Configurations:** Generate files like `dab-config.development.json` and `dab-config.production.json` for development and production environments, respectively. Include in these files any settings that diverge from the base configuration, focusing on elements such as the `connection-string`.
- **Environment Variable:** Utilize the `DAB_ENVIRONMENT` variable to specify the active environment. Setting `DAB_ENVIRONMENT=development` or `DAB_ENVIRONMENT=production` determines which set of configurations to apply.
- **Initialization:** On starting the Data API builder with `dab start`, it identifies the `DAB_ENVIRONMENT` value, combining `dab-config.json` with the relevant environment-specific file into a single merged configuration for operational use.

> [!NOTE]
> Environment-specific configurations take precedence over the base configuration. If a setting like `connection-string` is specified in both the base and an environment-specific file, the setting from the environment-specific file is used.

This approach enhances flexibility and organization in managing configurations across multiple environments, ensuring settings are easily adjustable and clearly defined for each operational context.

### Example

To illustrate the use of environment-specific `connection-string` settings in the Data API builder configuration files, consider the following sample setup:

#### Base configuration file

The `dab-config.json` file contains all common configuration settings that don't vary between different environments. It might not include the `connection-string` since it differs between development and production environments.

```json
{
  "<all-environments-feature>": {
    "<property>": <value>
  }
  // Note: "connection-string" isn't included here as it varies by environment
}
```

#### Development environment configuration

The `dab-config.Development.json` file overrides or adds to the base configuration for the development environment, including a development-specific connection string directly in the file.

```json
{
  "<development-specific-feature>": {
    "<property>": <value>
  },
  "connection-string": "<development-connection-string>"
}
```

In this development configuration, the `connection-string` is directly specified, which is a common approach during development for simplicity and ease of use. Replace `<development-connection-string>` with the actual connection string for the development database.

### Production environment configuration

For the `dab-config.Production.json` file, the connection string is securely referenced via an environment variable to avoid hard-coding sensitive information in the configuration files.

```json
{
  "connection-string": "@env('my-connection-string')"
}
```

In the production configuration, `@env('my-connection-string')` is used to dynamically load the connection string from an environment variable named `my-connection-string`. This approach enhances security by keeping sensitive information out of version control and allows for easy updates without modifying the application's deployed configuration files.

## Setting environment variables

Effectively managing environment variables is crucial for the secure and flexible configuration of the Data API builder. Environment variables can be set in two ways:

- **Direct System Settings:** Configure variables directly within your operating system. This method ensures that the variables are globally recognized across the system but requires administrative access to manage.

- **Using a `.env` File:** For a more localized and development-friendly approach, create a `.env` file containing key-value pairs of your environment variables. Place this file in the same directory as your Data API builder configuration file. This method enhances the ease of use and maintenance of environment variables during development.

  > [!NOTE]
  > The `.env` filename, like `.gitignore` and `.editorconfig` files has no filename, only a file extension. The name is case insensitive but the convention is lower-case.

### Best practices and security

- **Process Isolation:** When set through a `.env` file or directly in the system, environment variables are established as process variables, safeguarded from other processes. This isolation can enhance the security of your configuration by limiting exposure to sensitive information.

- **Exclusion from Version Control:** To prevent the accidental leakage of secrets, include your `.env` file in your project's `.gitignore`. This practice ensures that sensitive information, such as connection strings or API keys, isn't inadvertently committed and pushed to version control repositories.

### Practical application

An `.env` file not only simplifies the management of environment variables but also allows for the dynamic adjustment of settings without the need to modify system-level configurations. For example:

```plaintext
my-connection-string="Server=tcp:127.0.0.1,1433;User ID=<username>;Password=<password>;"
ASPNETCORE_URLS="http://localhost:5000;https://localhost:5001"
DAB_ENVIRONMENT=Development
```

Use the `.env` file to seamlessly integrate these variables into your Data API builder configuration using the `@env()` function.

## Accessing environment variables

Use the `@env()` function to incorporate environment variables into your configuration file, safeguarding sensitive data.

### Example

```json
{
  "connection-string": "@env('my-connection-string')"
}
```

The `@env` function can be used to access environment variables throughout the configuration file.

```json
{
  "property-name": "@env('variable-name')"
}
```

