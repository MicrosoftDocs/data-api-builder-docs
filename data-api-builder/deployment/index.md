---
title: Deployment guidance
description: Review the fundamentals of deploying Data API builder (DAB) to Azure services or a self-hosted solution.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: overview
ms.date: 06/11/2025
#Customer Intent: As a developer, I want to learn more about deploying DAB, so that I can determine the best option for my workload.
---

# Deployment guidance for Data API builder

:::image type="complex" source="media/index/map.svg" border="false" alt-text="Diagram of the current location ('Overview') in the sequence of the deployment guide.":::
Diagram of the sequence of the deployment guide including these locations, in order: Overview, Plan, Prepare, Publish, Monitor, and Optimization. The 'Overview' location is currently highlighted.
:::image-end:::

This guide helps you to plan, deploy, and manage a Data API builder solution in your production environment. Follow the steps in this guide to:

- Review a checklist of tasks before deployment
- Select the best option for hosting the Data API builder engine
- Deploy Data API builder to the host of your choice
- Monitor Data API builder metrics and logs
- Optimize the Data API builder deployment with best practices

## Engine

The Data API builder (DAB) engine is the core service that hosts REST and GraphQL APIs for your applications based on the [configuration](#configuration) you provide. This engine is hosted as middleware between your application front-end and database services.

:::image type="content" source="media/index/middleware.svg" alt-text="Diagram of Data API builder as the middleware between various Azure web application hosting services and Azure database services." border="false":::

You can retrieve the latest version of the DAB as a Docker container image, a NuGet package, or directly as a build from source code. You control the version of DAB that you deploy making it possible to strategically upgrade DAB as it makes sense for your business requirements.

For example, you can run the latest stable generally available 1.x release of DAB today. Then, you can evaluate new versions to determine if you desire new features and would like to update. You can even run different versions of DAB between your production and staging environments to give you a safe mechanism to evaluate the latest changes with minimal risks to your mission critical workloads.

## Configuration

Configuration file\[s\] largely drive the behavior of the running DAB engine. Use configuration files to ensure that your DAB instance\[s\] behave as you expect across deployments, versions, or environments. Additionally, use combinations of configuration files to apply specific behaviors to distinct environments.

For example, you can use a baseline configuration file with universal settings that apply to most of your environments. For specific environments, like development, staging, or production, you can apply environment-specific configuration files with settings that should be overridden for specific environments. Even further, you can reference environment variables of your host to ensure that you reference environment-specific configurations in the most secure manner possible.

## Next step

> [!div class="nextstepaction"]
> [Deployment checklist](checklist.md)
