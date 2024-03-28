---
title: Configuration Entity Permissions
description: Details the permissions property in Entity
author: jerrynixon
ms.author: jnixon
ms.service: data-api-builder
ms.topic: configuration-file
ms.date: 03/27/2024
---

# Permissions

The section `permissions` defines who (in terms of roles) can access the related entity and using which actions. Actions are the usual CRUD operations: `create`, `read`, `update`, `delete`.

## Syntax overview

```json
{
  ...
  "entities": {
    "<entity-name>": {
      ...
      "permissions": [
        {
          ...
          "actions": [
            "create", 
            "read", 
            "update", 
            "delete", 
            "execute"
          ],
        }
      ]
    }
  }
}
```

## Role property

The `role` string contains the name of the role to which the defined permission applies.

```json
{
  "entities": {
    "entity-name": {
      "permissions": [
        {
          "role": "anonymous" | "authenticated" | "custom-role",
          "actions": [
            "create",
            "read",
            "update",
            "delete",
            "execute", // only when stored-procedure
            "*"
          ],
          "fields": {
            "include": ["field-name", "field-name"],
            "exclude": ["field-name", "field-name"]
          }
        }
      ]
    }
  }
}
```

Roles set the permissions context in which a request should be executed. For each entity defined in the runtime config, you can define a set of roles and associated permissions that determine how the entity can be accessed in both the REST and GraphQL endpoints. Roles aren't additive. [Learn more about roles.](../authorization.md)

Data API builder evaluates requests in the context of a single role:

|Role|Description
|-|-
|`anonymous` | When no access token is presented.
|`authenticated`| When a valid access token is presented.
|`<custom-role>`| When a valid access token is presented and the `X-MS-API-ROLE` HTTP header is included specifying a user role that is also included in the access token's roles claim.

## Actions property

The `actions` array details what actions are allowed on the associated role. When the entity is either a table or view, roles can be configured with a combination of the actions: `create`, `read`, `update`, `delete`.

|Action|SQL Operation
|-|-
|`*`|Wildcard, including execute.
|`create`|Insert one or more rows.
|`read`|Select one or more rows.
|`update`|Modify one or more rows.
|`delete`|Delete one or more rows.
|`execute`|Runs a stored procedure.

**Example**

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

## Fields property

Role configuration is an object type with two internal properties, `include` and `exclude`. These values support granularly defining which database columns (fields) are permitted access in the section `fields`.

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
              "include": ["<field-name>"],
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

Include and exclude work together. The wildcard `*` in the `include` section indicates all fields. The fields noted in the `exclude` section has precedence over fields noted in the `include` section. The definition translates to *include all fields except for the field 'last_updated.'*

## Example

```json
"Book": {
    "source": "books",
    "permissions": [
        {
            "role": "anonymous",
            "actions": [ "read" ],
            // Include All Except Specific Fields
            "fields": {
              "include": [ "*" ],
              "exclude": [ "secret-field" ]
            }
        },
        {
            "role": "authenticated",
            "actions": [ "read", "update" ],
            // Explicit Include and Exclude
            "fields": {
              "include": [ "id", "title", "secret-field" ],
              "exclude": [ "secret-field" ]
            }
        },
        {
            "role": "author",
            "actions": [ "*" ],
            // Include All With No Exclusions (default)
            "fields": {
              "include": ["*"],
              "exclude": []
            }
        }
    ]
}
```

### Walkthrough

**Anonymous Role** Allow anonymous users to read all fields except the `secret-field`. The use of `"include": ["*"]` with `"exclude": ["secret-field"]` effectively hides `secret-field` from anonymous users while allowing access to all other fields.

**Authenticated Role** Allow authenticated users to read and update specific fields, explicitly including `id`, `title`, and `secret-field`, but then excluding `secret-field`. Demonstrates the explicit inclusion and subsequent exclusion of `secret-field`, showcasing the precedence of `exclude`. Since `secret-field` is both included and excluded, it ends up being inaccessible, which matches the intended rule of `exclude` taking precedence.

**Author Role** Authors can do all operations `*` on all fields without exclusions. The file indicates `"include": ["*"]` with an empty `"exclude": []` array grants access to all fields, as no fields are explicitly excluded.

### Variations

This configuration represents the default if nothing is specified. 

```json
"fields": {
  "include": [],
  "exclude": []
}
```

It's effectively identical to:

```json
"fields": {
  "include": [ "*" ],
  "exclude": []
}
```

Also consider the following setup:

```json
"fields": {
  "include": [],
  "exclude": ["*"]
}
```

The above configuration effectively specifies that no fields are explicitly included (`"include": []` is empty, indicating no fields are allowed) and that all fields are excluded (`"exclude": ["*"]` uses the wildcard `*` to indicate all fields).

**Practical Use**: Such a configuration might seem counterintuitive since it restricts access to all fields. However, it could be utilized in scenarios where a role might perform certain actions - like creating an entity - without accessing any of its data. 

The same behavior, but with different syntax, would be:

```json
"fields": {
  "include": ["Id", "Title"],
  "exclude": ["*"]
}
```

The above setup attempts to specify that only the `Id` and `Title` fields should be included, while also indicating that all fields should be excluded with the wildcard `*` in the `exclude` section. Another way to express the same logic would be:

```json
"fields": {
  "include": ["Id", "Title"],
  "exclude": ["Id", "Title"]
}
```

Given the general rule that the `exclude` list takes precedence over the `include` list, specifying `exclude: ["*"]` would typically mean that all fields are excluded, even the fields listed in the `include` section. Thus, at first glance, this configuration might seem to prevent any fields from being accessible, as the exclusion rule is dominant.

**The Reverse**: If the intent is to grant, access only to the `Id` and `Title` fields, it's clearer and more reliable to specify only those fields in the `include` section and not use `exclude` with a wildcard. Alternatively, you could adjust the system's permissions logic to explicitly accommodate such cases, assuming you're in control of its design. For example:

```json
"fields": {
  "include": ["Id", "Title"],
  "exclude": []
}
```