---
title: Deployment overview and checklist
description: Review hosting options and a deployment checklist for Data API builder (DAB) to Azure services or self-hosted solutions.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: overview
ms.date: 03/26/2026
---

# Deployment overview for Data API builder

This guide helps you plan, deploy, and manage a Data API builder (DAB) solution in your production environment.

## Hosting options

There are multiple options available to host Data API builder in Azure or on your own infrastructure.

### Azure Container Apps

Azure Container Apps is a serverless platform that hosts a cluster of [Docker](https://www.docker.com) container images on your behalf. It balances complexity with configuration by reducing the friction to have a container cluster. Use Azure Container Apps to host a container cluster that can scale out or in quickly and also support multiple container workloads.

For more information, see [Azure Container Apps](/azure/container-apps) and [Deploy to Azure Container Apps](azure-container-apps.md).

### Azure Container Instances

Azure Container Instances is a serverless platform that hosts an individual Docker container image on your behalf. It's a low-friction way of getting a container instance running in Azure without the complexity of a higher-level service.

For more information, see [Azure Container Instances](/azure/container-instances) and [Deploy to Azure Container Instances](azure-container-instances.md).

### Azure App Service

Azure App Service hosts web applications or APIs either running in server-side code or a Docker container. You can run Data API builder as either a [native .NET application](/azure/app-service/configure-language-dotnetcore) or a [Docker container image](/azure/app-service/configure-custom-container).

For more information, see [Azure App Service](/azure/app-service).

### Azure Kubernetes Service

Azure Kubernetes Service manages a [Kubernetes](https://kubernetes.io) cluster on your behalf. Run Data API builder as part of a [container cluster](/azure/aks/concepts-clusters-workloads#kubernetes-cluster-architecture) and allow AKS to manage the individual hosts at scale.

For more information, see [Azure Kubernetes Service](/azure/aks) and [Deploy to AKS](azure-kubernetes-service.md).

### Local Docker container

You can also run Data API builder locally in a Docker container for development and testing. For more information, see [Run in a local container](local-container.md).

## Deployment checklist

Before deploying your DAB solution, run through this checklist covering connection information, entity planning, and feature decisions.

### Gather database credentials

| | Recommendation |
| --- | --- |
| **&#9744;** | **Determine if your preferred database platform and version are supported.** Review the [database version support](../reference-database-specific-features.md#database-version-support) table to identify the minimum supported version for each database. Consider this minimum version in both your local and deployed instances of the database. |
| **&#9744;** | **Obtain your database connection string.** Get the connection string for all instances of the database you plan to connect to. We recommend using the [environment variable function (`@env`)](../concept/config/env-function.md) in the DAB configuration file and then setting your connection string using environment variables. In local development, you can optionally use an *.env* file. |
| **&#9744;** | **Configure your database for passwordless authentication.** We highly recommend not using plaintext username and password credentials whenever possible. For Azure-based deployments, use [managed identities](/entra/identity/managed-identities-azure-resources) to connect from the DAB host in development or production to your database. This configuration produces a connection string that only contains the endpoint of the database. Secure your solution further by storing the connection string in an [Azure Key Vault](/azure/key-vault) instance and referencing it using the `@env` function. |

### Plan the exposed entities

| | Recommendation |
| --- | --- |
| **&#9744;** | **Produce a list of entities to expose as API endpoints.** List out any database entities that you wish to explicitly expose as endpoints using DAB. DAB doesn't expose entities implicitly, so it's imperative that you determine ahead of time which entities to manually expose through the configuration file and the [`dab add`](../command-line/dab-add.md) CLI command. Alternatively, you can write a custom database query to find all entities in your database and then generate the appropriate corresponding CLI commands. |
| **&#9744;** | **Document any relationships between entities.** Relationships between entities must be defined in the configuration file. For more information, see [relationships](../concept/database/relationships.md). |

### Decide which features to use

| | Recommendation |
| --- | --- |
| **&#9744;** | **Configure your authentication provider.** Starting in DAB 2.0, which is currently in preview, the default authentication provider is `Unauthenticated`, which means DAB doesn't inspect or validate any JSON Web Token (JWT). All requests run as `anonymous`. If your deployment requires JWT-based authentication, set the provider explicitly (for example, `--auth.provider EntraID`). For more information, see [Configure the Unauthenticated provider](../concept/security/authenticate-unauthenticated.md) and [runtime authentication configuration](../configuration/runtime.md#provider-authentication-host-runtime). |
| **&#9744;** | **Decide if you want to use REST, GraphQL or both API types.** By default, DAB enables both REST and GraphQL endpoints. You can customize each endpoint by enabling or disabling either the [`runtime.graphql.enabled`](../configuration/runtime.md#graphql-runtime) or the [`runtime.rest.enabled`](../configuration/runtime.md#rest-runtime) configuration properties respectively. For more information on GraphQL, see [host GraphQL endpoints](../concept/api/graphql.md). For more information on REST, see [host REST endpoints](../concept/api/rest.md). |
| **&#9744;** | **Select REST and GraphQL features that you wish to enable.** Each endpoint type ships with multiple features enabled out of the box. For example, the default REST endpoint URI is `/data`, but it can be customized using the [`runtime.rest.path`](../configuration/runtime.md#rest-runtime) property. Similarly, the default GraphQL endpoint URI is `/query` and that's customizable using the [`runtime.graphql.path`](../configuration/runtime.md#graphql-runtime) property. |

## Related content

- [Configuration best practices](../concept/config/best-practices.md)
- [Security best practices](../concept/security/best-practices.md)
