---
title: Use Open Telemetry and Activity Traces
description: Use Open Telemetry and Activity Traces
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 07/16/2025
# Customer Intent: As a developer, I want to trace my activity through connected logs, so I can debug distributed operations. 
---

# Use Open Telemetry and Activity Traces

Data API Builder (DAB) supports OpenTelemetry for distributed tracing and metrics, enabling you to monitor and diagnose your application's behavior across REST, GraphQL, database operations, and internal middleware.

## Data API builder Traces

DAB creates OpenTelemetry "activities" for:

- **Incoming HTTP requests** (REST endpoints)
- **GraphQL operations**
- **Database queries** (per entity)
- **Internal middleware steps** (e.g., request handling, error tracking)

Each activity includes detailed tags (metadata), such as:
- `http.method`, `http.url`, `http.querystring`, `status.code`
- `action.type` (CRUD, GraphQL operation)
- `user.role`, `user-agent`
- `data-source.type`, `data-source.name`
- `api.type` (REST or GraphQL)

Errors and exceptions are also traced with detailed info.

## Data API builder Metrics

DAB emits OpenTelemetry metrics such as:

- **Total Requests**: Counter, labeled by HTTP method, status, endpoint, and API type.
- **Errors**: Counter, labeled by error type, HTTP method, status, endpoint, and API type.
- **Request Duration**: Histogram (in milliseconds), labeled as above.
- **Active Requests**: Up/down counter for concurrent requests.

Metrics use the .NET `Meter` API and OpenTelemetry SDK.

## Configuration

Add an [`open-telemetry` section](../../configuration/runtime.md#opentelemetry-telemetry) under `runtime.telemetry` in your config file. 

```json
{
    "runtime": {
        "telemetry": {
            "open-telemetry": {
                "enabled": true,
                "endpoint": "http://otel-collector:4317",
                "service-name": "dab",
                "exporter-protocol": "grpc"
            }
        }
    }
}
```

## CLI Options

Configure OpenTelemetry via [CLI flags](../../reference-command-line-interface.md#configure):

* `dab configure --otel-enabled true`
* `dab configure --otel-endpoint "http://otel-collector:4317"`
* `dab configure --otel-protocol "grpc"`
* `dab configure --otel-service-name "dab"`
* `dab configure --otel-headers`

## Export and Visualization

Telemetry is exported via .NET OpenTelemetry SDK to your configured backend such as Azure Monitor or Jaeger. Ensure your backend is running and reachable at the specified `endpoint`.

## Implementation Notes

* Traces and metrics cover all REST, GraphQL, and DB operations
* Middleware and error handlers also emit telemetry
* Context is propagated through requests
