---
title: Implement external, level 2 cache
description: Implement external, level 2 cache
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: reference
ms.date: 07/16/2025
# Customer Intent: As a developer, I want to use level 2 cache to make stateless containers warm start. 
---

# Implement level 2 cache

Level 2 cache in Data API builder will extend beyond the in-memory scope of level 1 cache by supporting distributed caching via Redis. This will allow cache to persist across multiple instances of the DAB runtime and survive process restarts, making it suitable for scalable production deployments.

## Benefits of level 2 cache

* High availability and fault tolerance
* Horizontal scalability
* Reduced database load across services
* Optional TTL settings for fine-tuned cache control

## Status: Coming soon

This feature is **not yet available**. We're building level 2 cache now. Stay tuned.

## Redis support

Redis is a fast, in-memory data store widely adopted for caching scenarios. Its support for key expiration and distributed access makes it ideal for a level 2 cache strategy.

* Shared cache across scaled-out DAB instances
* Persistent cache beyond application restarts
* Faster start time for stateless containers
* Improved performance for high-load, read-intensive workloads
