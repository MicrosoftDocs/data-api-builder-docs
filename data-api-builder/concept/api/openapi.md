---
title: Swagger and OpenAPI metadata for REST endpoints
description: Manage OpenAPI description and Swagger UI hosting for Data API builder's REST API endpoints feature, including permission-aware schema generation and role-specific paths.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 03/24/2026
# Customer Intent: As a developer, I want to use the Data API Builder, so that I can host OpenAPI/Swagger metadata.
---

# OpenAPI in Data API builder

> [!TIP]
> This feature is new or updated in Data API builder 2.0. For more information, see [What's new in version 2.0](../../whats-new/version-2-0.md).

The OpenAPI specification is a language-agnostic standard for documenting HTTP APIs. Data API builder supports OpenAPI by:

* Generating metadata for all REST-enabled entities defined in the runtime configuration
* Compiling that metadata into a valid OpenAPI schema
* Exposing the schema through a visual UI (Swagger) or as a serialized JSON file
* Filtering the schema to show only HTTP methods and fields accessible for a given role

## OpenAPI description document

Data API builder generates an OpenAPI description document using the runtime configuration and the database metadata for each REST-enabled entity.

The schema is built using the [OpenAPI.NET SDK](https://github.com/microsoft/OpenAPI.NET) and conforms to the [OpenAPI Specification v3.0.1](https://spec.openapis.org/oas/v3.0.1.html). It is output as a JSON document.

You can access the OpenAPI document at:

```http
GET /{rest-path}/openapi
```

> [!NOTE]
> By default, the `rest-path` is `api`. This value is configurable. See [REST configuration](../../configuration/runtime.md#rest-runtime) for details.

## Permission-aware OpenAPI

Starting in DAB 2.0, the OpenAPI document reflects the actual permissions configured for each entity. Instead of documenting every possible HTTP method, the generated schema shows **only** the methods and fields that a given role can access.

### How permissions map to HTTP methods

DAB translates entity permissions into HTTP method visibility in the OpenAPI document:

| Permission action | HTTP methods shown |
|---|---|
| `read` | `GET` |
| `create` | `POST` |
| `create` + `update` | `PUT`, `PATCH` |
| `delete` | `DELETE` |

For example, if the `anonymous` role has only `read` permission on the `Book` entity, the OpenAPI document for the anonymous role shows only `GET` operations for `/api/Book`. The `POST`, `PUT`, `PATCH`, and `DELETE` operations are omitted entirely.

### Field-level filtering

When permissions include field-level `include` or `exclude` rules, the OpenAPI schema reflects those constraints. Only fields accessible to the role appear in the request and response schemas. This gives consumers an accurate picture of what the API accepts and returns for their role.

### Role-specific OpenAPI paths

DAB provides role-specific OpenAPI endpoints so you can inspect the schema for any configured role:

```http
GET /{rest-path}/openapi
GET /{rest-path}/openapi/anonymous
GET /{rest-path}/openapi/authenticated
GET /{rest-path}/openapi/admin
```

The base `/openapi` path returns the default anonymous view. Each role-specific path returns a schema filtered to that role's permissions.

> [!IMPORTANT]
> Role-specific OpenAPI paths (`/openapi/{role}`) are available **only in Development mode**. In Production mode, these endpoints are disabled to prevent role enumeration. Only the base `/openapi` path is available in Production mode.

### Example

Consider this permission configuration:

```json
{
  "entities": {
    "Book": {
      "permissions": [
        {
          "role": "anonymous",
          "actions": [
            {
              "action": "read",
              "fields": { "include": ["id", "title", "year"] }
            }
          ]
        },
        {
          "role": "authenticated",
          "actions": ["create", "read", "update", "delete"]
        }
      ]
    }
  }
}
```

With this configuration:

- **`/api/openapi/anonymous`** shows only `GET /api/Book` with response fields `id`, `title`, and `year`.
- **`/api/openapi/authenticated`** shows `GET`, `POST`, `PUT`, `PATCH`, and `DELETE` operations on `/api/Book` with all fields.

## Swagger UI

[Swagger UI](https://swagger.io/swagger-ui) provides an interactive, web-based view of the API based on the OpenAPI schema.

In `Development` mode, Data API builder exposes Swagger UI at:

```http
GET /swagger
```

This endpoint is not nested under the `rest-path` to avoid conflicts with user-defined entities.
