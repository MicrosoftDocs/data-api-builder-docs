---
title: What's new for version 0.6.14
description: Release notes with new features, bug fixes, and updates listed for the Data API builder version 0.6.14.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: whats-new 
ms.date: 03/28/2024
---

# What's new in Data API builder version 0.6.14

This article describes the patch for March 2023 release for Data API builder for Azure Databases.

## Bug Fixes

- Address query filter access denied issue for Cosmos.
- Cosmos DB currently doesn't support field level authorization, to avoid the situation when the users accidentally pass in the ```field``` permissions in the runtime config, we added a validation check.
