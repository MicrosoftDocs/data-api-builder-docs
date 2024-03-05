---
title: Permissions Configuration
description: Part of the configuration documentation for Data API builder, focusing on Permissions Configuration.
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

# Authorization

## {entity}.permissions

The section `permissions` defines who (in terms of roles) can access the related entity and using which actions. Actions are the usual CRUD operations: `create`, `read`, `update`, `delete`.

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          ...
          "actions": ["create", "read", "update", "delete"],
        }
      ]
    }
  }
}
```

## {entity}.permissions.role

The `role` string contains the name of the role to which the defined permission applies.

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          "role": "reader"
          ...
        }
      ]
    }
  }
}
```

## {entity}.permissions.actions

The `actions` array details what actions are allowed on the associated role. When the entity is either a table or view, roles can be configured with a combination of the actions: `create`, `read`, `update`, `delete`.

|Action|SQL Equivalent
|-|-
|`*`|Wildcard, including execute
|`create`|Insert one or more rows
|`read`|Select one or more rows
|`update`|Modify one or more rows
|`delete`|Delete one or more rows
|`execute`|Runs a stored procedure

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          "role": "contributor",
          "actions": ["read", "create"]
        }
      ]
    }
  }
}
```

## {entity}.permissions.fields

Role configuration is an object type with two internal properties, `include` and `exclude`. This supports granularly defining which database columns (fields) are permitted access in the section `fields`.

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          {
            ...
            "fields": {
              "include": ["<action-name>"],
              "exclude": ["<field-name>"]
            }
          }
        }
      ]
    }
  }
}
```  

**How include and exclude interoperate.**

Include and exclude work together. The wildcard `*` in the `include` section indicates all fields. The fields noted in the `exclude` section have precedence over fields noted in the `include` section. The definition translates to *include all fields except for the field 'last_updated'*.

