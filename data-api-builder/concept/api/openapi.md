---
title: Swagger and OpenAPI metadata for REST endpoints
description: Manage OpenAPI description and Swagger UI hosting for Data API builder's REST API endpoints feature.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 06/11/2025
# Customer Intent: As a developer, I want to use the Data API Builder, so that I can host OpenAPI/Swagger metadata.
---

# OpenAPI in Data API builder

The OpenAPI specification is a language-agnostic standard for documenting HTTP APIs. Data API builder supports OpenAPI by:

* Generating metadata for all REST-enabled entities defined in the runtime configuration
* Compiling that metadata into a valid OpenAPI schema
* Exposing the schema through a visual UI (Swagger) or as a serialized JSON file

## OpenAPI description document

Data API builder generates an OpenAPI description document using the runtime configuration and the database metadata for each REST-enabled entity.

The schema is built using the [OpenAPI.NET SDK](https://github.com/microsoft/OpenAPI.NET) and conforms to the [OpenAPI Specification v3.0.1](https://spec.openapis.org/oas/v3.0.1.html). It is output as a JSON document.

You can access the OpenAPI document at:

```http
GET /{rest-path}/openapi
```

> \[!NOTE]
> By default, the `rest-path` is `api`. This value is configurable. See [REST configuration](../../configuration/runtime.md#rest-runtime) for details.

## Swagger UI

[Swagger UI](https://swagger.io/swagger-ui) provides an interactive, web-based view of the API based on the OpenAPI schema.

In `Development` mode, Data API builder exposes Swagger UI at:

```http
GET /swagger
```

This endpoint is not nested under the `rest-path` to avoid conflicts with user-defined entities.

## Related content

* [REST configuration reference](../../configuration/runtime.md#rest-runtime)
* [REST endpoints](rest.md)
