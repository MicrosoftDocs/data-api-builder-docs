---
title: Role inheritance in Data API builder
description: Learn how role inheritance in Data API builder lets you define permissions once and have narrower roles inherit that access automatically.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: conceptual
ms.date: 03/27/2026
# Customer Intent: As a developer, I want to understand role inheritance so that I can configure entity permissions without repeating the same permission block across every role.
---

# Role inheritance in Data API builder

[!INCLUDE[Note - DAB 2.0 preview](../../includes/note-dab-2-preview.md)]

Role inheritance lets you define permissions once on a broader role and have more specific roles automatically inherit that access. Without role inheritance, you must repeat the same permission block for every role on every entity. With role inheritance, define access on `anonymous` once and every broader role gets the same access.

## The inheritance chain

The inheritance chain flows from least-privileged to most-privileged:

```
named-role → authenticated → anonymous
```

| Role | Inherits from | Notes |
|------|---------------|-------|
| Named role (for example, `editor`) | `authenticated` | Or from `anonymous` if `authenticated` isn't configured |
| `authenticated` | `anonymous` | Applies when no explicit `authenticated` block exists |
| `anonymous` | *(none)* | Base of the chain; no fallback |

The chain means:

- If a **named role** has no permission block, DAB looks for an `authenticated` block. If none exists, it falls back to `anonymous`.
- If **`authenticated`** has no permission block, DAB uses the `anonymous` block.
- If **`anonymous`** has no permission block, the request is rejected with `403 Forbidden`.

## How inheritance resolves

When DAB evaluates a request, it determines the effective role and then walks the inheritance chain to find a permission block:

1. DAB identifies the effective role from the request (via `X-MS-API-ROLE` header, token claims, or defaults).
1. DAB looks for an explicit permission block in `entities.<name>.permissions` that matches the effective role.
1. If no matching block exists, DAB walks up the chain: `authenticated` → `anonymous`.
1. The first matching block found provides the permissions for the request.
1. If no block matches any role in the chain, DAB returns `403 Forbidden`.

> [!NOTE]
> DAB evaluates permissions in the context of exactly one effective role per request. Role inheritance doesn't combine permissions from multiple roles.

## Examples

### Minimum configuration: single permission for all roles

Define a `read` permission on `anonymous`. Every role—`authenticated` and any named role—inherits that access.

```json
{
  "entities": {
    "Book": {
      "source": "dbo.books",
      "permissions": [
        { "role": "anonymous", "actions": [ "read" ] }
      ]
    }
  }
}
```

Effective permissions for this configuration:

```text
Entity: Book
    Role: anonymous        | Actions: Read
    Role: authenticated    | Actions: Read (inherited from: anonymous)
    Unconfigured roles     | Inherit from: anonymous
```

### Layered configuration: different access per role

When you need different access levels per role, define each explicitly. Inheritance fills in only the roles you don't configure.

```json
{
  "entities": {
    "Order": {
      "source": "dbo.orders",
      "permissions": [
        { "role": "anonymous",      "actions": [ "read" ] },
        { "role": "authenticated",  "actions": [ "read", "create" ] },
        { "role": "admin",          "actions": [ "*" ] }
      ]
    }
  }
}
```

Effective permissions for this configuration:

```text
Entity: Order
    Role: anonymous        | Actions: Read
    Role: authenticated    | Actions: Read, Create
    Role: admin            | Actions: Create, Read, Update, Delete
    Unconfigured roles     | Inherit from: authenticated
```

Any named role other than `admin`—for example, `viewer` or `support`—inherits from `authenticated` and gets `read` and `create` access.

### No inheritance: fully blocked

If `anonymous` has no permission block and no other role in the chain has one, every request to that entity is rejected.

```json
{
  "entities": {
    "AuditLog": {
      "source": "dbo.audit_log",
      "permissions": [
        { "role": "admin", "actions": [ "read" ] }
      ]
    }
  }
}
```

In this configuration, only `admin` can access `AuditLog`. `authenticated` and `anonymous` have no block to inherit, so DAB rejects requests from those roles with `403 Forbidden`.

> [!IMPORTANT]
> DAB emits a warning at startup when `authenticated` or named roles are configured on an entity but the `Unauthenticated` provider is active. When `Unauthenticated` is active, those roles are never activated. For more information, see [Configure the Unauthenticated provider](authenticate-unauthenticated.md).

## View effective permissions

Use `dab configure --show-effective-permissions` to display the resolved permissions for every entity, including which roles inherited from which. This command is the fastest way to verify inheritance is working as expected without running the engine.

```bash
dab configure --show-effective-permissions
```

You can also target a specific configuration file:

```bash
dab configure --show-effective-permissions --config my-config.json
```

Example output:

```text
Entity: Book
    Role: anonymous        | Actions: Read
    Role: authenticated    | Actions: Read (inherited from: anonymous)
    Unconfigured roles inherit from: anonymous

Entity: Order
    Role: admin            | Actions: Create, Read, Update, Delete
    Role: anonymous        | Actions: Read
    Role: authenticated    | Actions: Read (inherited from: anonymous)
    Unconfigured roles inherit from: authenticated
```

For full options, see [`--show-effective-permissions`](../../command-line/dab-configure.md#--show-effective-permissions).

## Inheritance vs. explicit permissions

| Scenario | Recommendation |
|----------|----------------|
| All roles should have the same access | Define once on `anonymous`; let all roles inherit |
| Authenticated users need more access than anonymous | Define `anonymous` read, add `authenticated` create/update |
| A named role needs broader access than `authenticated` | Define the named role explicitly; others inherit from `authenticated` |
| A named role needs less access than `authenticated` | Define the named role explicitly with the reduced actions |
| An entity must be fully private | Grant only the specific named role; leave `authenticated` and `anonymous` undefined |

## Related content

- [Authorization overview](authorization-overview.md)
- [Configure database policies](database-policies.md)
- [Configure the Unauthenticated provider](authenticate-unauthenticated.md)
- [`--show-effective-permissions` reference](../../command-line/dab-configure.md#--show-effective-permissions)
- [What's new in version 2.0](../../whats-new/version-2-0.md#introducing-role-inheritance)
