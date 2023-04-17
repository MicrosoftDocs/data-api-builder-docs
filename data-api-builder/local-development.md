---
title: Local development in Data API builder
description: This document contains details about local development in Data API builder.
author: anagha-todalbagi
ms.author: atodalbagi
ms.service: data-api-builder
ms.topic: local-development
ms.date: 04/06/2023
---

# Local development with Data API builder for Azure databases

Data API builder can be used on-premises, if needed. This can be helpful in both cases. In case you prefer to build cloud-solution offline, and then deploy everything in the cloud using a CI/CD pipeline, or in case you want to use Data API builder to give access to on-premises developers to on-premises databases available in your environment.

Depending on what you want to do, you have several options to run Data API builder locally:

- [Run Data API builder using the CLI tool](./run-using-data-api-builder-cli.md)
- [Run Data API builder in a container](./run-using-container.md)
- [Run Data API builder from source code](./run-from-source-code.md)

Data API builder works in the same way if run in Azure or if run locally or in a self-hosted environment. The only difference is related to how authentication can be done or simulated locally, so that even when using a local development experience you can test what happens when an authenticated request is received by Data API builder. Read more how you can simulate authenticated request locally here: [Local Authentication](./local-authentication.md).

### Static Web Apps CLI integration

[Static Web Apps CLI](https://azure.github.io/static-web-apps-cli/) has been integrated to support Data API builder so that you can have a full end-to-end full-stack development experience offline, and then deploy everything in the cloud using a CI/CD pipeline.

To learn more about how to use Data API builder with Static Web Apps CLI, read the following documentation: [Quickstart: Use Data API builder with Azure Databases](/azure/data-api-builder/get-started/get-started-with-data-api-builder)
