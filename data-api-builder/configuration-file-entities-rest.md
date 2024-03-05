---
title: Entities REST Configuration
description: Part of the configuration documentation for Data API builder, focusing on Entities REST Configuration.
author: jnixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/04/2024
---

## Configuration File

1. [Overview](./configuration-file-overview.md)
1. [Runtime](./configuration-file-runtime.md)
1. [Entities.{entity}](./configuration-file-entities.md)
1. [Entities.{entity}.relationships](./configuration-file-entity-relationships.md)
1. [Entities.{entity}.permissions](./configuration-file-entity-permissions.md)
1. [Entities.{entity}.policy](./configuration-file-entity-policy.md)
1. [Sample](./configuration-file-sample.md)

# Entity Rest

## `{entity}.rest` property

The `rest` section of the configuration file is dedicated to fine-tuning the RESTful endpoints for each database entity. This customization capability ensures that the exposed REST API matches specific requirements, improving both its utility and integration capabilities. It addresses potential mismatches between default inferred settings and desired endpoint behaviors.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "rest": {
        ...
      }
    }
  }
}
```

### `{entity}.rest.enabled` property

This property acts as a toggle for the visibility of entities within the REST API. By setting the `enabled` property to `true` or `false`, developers can control access to specific entities, enabling a tailored API surface that aligns with application security and functionality requirements.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "rest": {
        "enabled": true | false
      }
    }
  }
}
```

If omitted or missing, the default value of `enabled` is `true`. 

### `{entity}.rest.path` property

The `path` property specifies the URI segment used to access an entity via the REST API. This customization allows for more descriptive or simplified endpoint paths beyond the default entity name, enhancing API navigability and client-side integration.

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "rest": {
        ...
        "path": "/entity-path"
      }
    }
  }
}
```

### `{entity}.rest.methods` property

Applicable specifically to stored procedures, the `methods` property defines which HTTP verbs (e.g., GET, POST) the procedure can respond to. This enables precise control over how stored procedures are exposed through the REST API, ensuring compatibility with RESTful standards and client expectations. This section underlines the platform's commitment to flexibility and developer control, allowing for precise and intuitive API design tailored to the specific needs of each application.

If omitted or missing, the `methods` default is `POST`. 

```json
{
  "entities" {
    "<entity-name>": {
      ...
      "rest": {
        ...
        "methods": [ "GET", "POST" ]
      }
    }
  }
}
```