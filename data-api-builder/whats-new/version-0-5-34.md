---
title: What's new for version 0.5.34
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 0.5.34.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 03/28/2024
---

# What's new in Data API builder version 0.5.34

The full list of release notes for this version is available on GitHub: <https://github.com/Azure/data-api-builder/releases/tag/v0.5.34>.

## Honor REST and GraphQL enabled flag at runtime level

A new option is added to allow enabling or disabling REST/GraphQL requests for all entities at the runtime level. If disabled globally, no entities would be accessible via REST or GraphQL requests irrespective of the individual entity settings. If enabled globally, individual entities are accessible by default unless disabled explicitly by the entity level settings.

```json
"runtime": {
    "rest": {
      "enabled": false,
      "path": "/api"
    },
    "graphql": {
      "allow-introspection": true,
      "enabled": false,
      "path": "/graphql"
    }
  }
```

## Correlation ID in request logs

To help debugging, we attach a correlation ID to any logs that are generated during a request. Since many requests might be made, having a way to identify the logs to a specific request is important to help the debugging process.

## Wildcard Operation Support for Stored Procedures in Engine and CLI

For stored procedures, roles can now be configured with the wildcard `*` action but it only expands to the `execute` action.
