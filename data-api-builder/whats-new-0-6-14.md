---
title: Release notes for Data API builder 0.6.14 
description: Release notes for Data API builder 0.6.14 are available here.
author: anagha-todalbagi 
ms.author: atodalbagi
ms.service: data-api-builder 
ms.topic: whats-new 
ms.date: 04/26/2023
---
# What's New in Data API builder 0.6.14

This is the patch for March 2023 release for Data API builder for Azure Databases

## Bug Fixes

- Address query filter access denied issue for Cosmos.
- Cosmos DB currently doesn't support field level authorization, to avoid the situation when the users accidentally pass in the ```field``` permissions in the runtime config, we added a validation check.
