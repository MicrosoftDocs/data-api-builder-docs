---
title: Environment Configuration
description: Part of the configuration documentation for Data API builder, focusing on Environment Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

## Configuration File

1. [Overview](./configuration-file-overview.md)
1. [Environment](./configuration-file-environment.md)
1. [Runtime](./configuration-file-runtime.md)
1. [Entities.{entity}](./configuration-file-entities.md)
1. [Entities.{entity}.relationships](./configuration-file-entity-relationships.md)
1. [Entities.{entity}.permissions](./configuration-file-entity-permissions.md)
1. [Entities.{entity}.policy](./configuration-file-entity-policy.md)
1. [Sample](./configuration-file-sample.md)

# Environment

The Data API builder configuration supports multiple environments, mirroring the functionality of ASP.NET Core's `appSettings.json`. This feature enables the use of a base configuration file along with environment-specific files to tailor settings accordingly:

- `dab-config.json` for base configurations
- `dab-config.Development.json` for development-specific configurations
- `dab-config.Production.json` for production-specific configurations

## Setting and Selecting Environments

1. **Define a Base Configuration:** Begin with the `dab-config.json` file, incorporating all common settings across environments.
2. **Create Environment-Specific Configurations:** Generate files like `dab-config.development.json` and `dab-config.production.json` for development and production environments, respectively. Include in these files any settings that diverge from the base configuration, focusing on elements such as the `connection-string`.
3. **Environment Variable:** Utilize the `DAB_ENVIRONMENT` variable to specify the active environment. Setting `DAB_ENVIRONMENT=development` or `DAB_ENVIRONMENT=production` determines which set of configurations to apply.
4. **Initialization:** On starting the Data API builder with `dab start`, it identifies the `DAB_ENVIRONMENT` value, combining `dab-config.json` with the relevant environment-specific file into a single merged configuration for operational use.

> [!NOTE]
> Environment-specific configurations take precedence over the base configuration. If a setting like `connection-string` is specified in both the base and an environment-specific file, the setting from the environment-specific file is used.

This approach enhances flexibility and organization in managing configurations across multiple environments, ensuring settings are easily adjustable and clearly defined for each operational context.

### Example

To illustrate the use of environment-specific `connection-string` settings in the Data API builder configuration files, consider the following sample setup:

#### Base Configuration File (`dab-config.json`)
This file contains all common configuration settings that do not vary between different environments. It might not include the `connection-string` since this is likely to differ between development and production environments.

```json
{
  "applicationSettings": {
    "logLevel": "info",
    "featureToggle": {
      "enableFeatureX": true
    }
  }
  // Note: "connection-string" is not included here as it varies by environment
}
```

#### Development Environment Configuration (`dab-config.Development.json`)
This file overrides or adds to the base configuration for the development environment, including a development-specific connection string directly in the file.

```json
{
  "applicationSettings": {
    "logLevel": "debug"
  },
  "connection-string": "<development-connection-string>"
}
```

In this development configuration, the `connection-string` is directly specified, which is a common approach during development for simplicity and ease of use. Replace `<development-connection-string>` with the actual connection string for the development database.

### Production Environment Configuration (`dab-config.Production.json`)
For the production environment, the connection string is securely referenced via an environment variable to avoid hard-coding sensitive information in the configuration files.

```json
{
  "applicationSettings": {
    "logLevel": "error"
  },
  "connection-string": "@env('my-connection-string')"
}
```

In the production configuration, `@env('my-connection-string')` is used to dynamically load the connection string from an environment variable named `my-connection-string`. This approach enhances security by keeping sensitive information out of version control and allows for easy updates without modifying the application's deployed configuration files.

## Setting Environment Variables

Effectively managing environment variables is crucial for the secure and flexible configuration of the Data API builder. Environment variables can be set in two ways:

1. **Direct System Settings:** Configure variables directly within your operating system. This method ensures that the variables are globally recognized across the system but requires administrative access to manage.

2. **Using a `.env` File:** For a more localized and development-friendly approach, create a `.env` file containing key-value pairs of your environment variables. Place this file in the same directory as your Data API builder configuration file. This method enhances the ease of use and maintenance of environment variables during development.

### Best Practices and Security

- **Process Isolation:** When set through a `.env` file or directly in the system, environment variables are established as process variables, safeguarded from being accessed by other processes. This isolation may enhance the security of your configuration by limiting exposure to sensitive information.

- **Exclusion from Version Control:** To prevent the accidental leakage of secrets, include your `.env` file in your project's `.gitignore`. This practice ensures that sensitive information, such as connection strings or API keys, is not inadvertently committed and pushed to version control repositories.

### Practical Application

An `.env` file not only simplifies the management of environment variables but also allows for the dynamic adjustment of settings without the need to modify system-level configurations. For example:

```plaintext
my-connection-string="Server=tcp:127.0.0.1,1433;User ID=<username>;Password=<password>;"
DAB_ENVIRONMENT=Development
```

Use the `.env` file to seamlessly integrate these variables into your Data API builder configuration using the `@env()` function. 

## Accessing Environment Variables

Use the `@env()` function to incorporate environment variables into your configuration file, safeguarding sensitive data.

### Example:

```json
{
  "connection-string": "@env('my-connection-string')"
}
```

The `@env` function can used to access enviornment variables throughout the configuration file. 

```json
{
  "property-name": "@env('variable-name')"
}
```
