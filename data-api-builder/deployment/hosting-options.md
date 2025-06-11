---
title: API hosting options
description: Select the most appropriate hosting options for your Data API builder solution by comparing various Azure services.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: product-comparison
ms.date: 06/11/2025
---

# Hosting options for Data API builder

:::image type="complex" source="media/hosting-options/map.svg" border="false" alt-text="Diagram of the current location ('Prepare') in the sequence of the deployment guide.":::
Diagram of the sequence of the deployment guide including these locations, in order: Overview, Plan, Prepare, Publish, Monitor, and Optimization. The 'Prepare' location is currently highlighted.
:::image-end:::

There are multiple options available to host Data API builder in Azure or on your own infrastructure. Review these options to select the appropriate hosting options for your Data API builder solution.

## Azure Container Apps

Azure Container Apps is an Azure service that hosts a cluster of [Docker](https://www.docker.com) container images on your behalf. Azure Container Apps is a serverless platform that balances complexity with configuration by reducing the friction to have a container cluster. Azure Container Apps fully manages the details around infrastructure, orchestration, and deployment. Use Azure Container Apps to host a container cluster that can scale out or in quickly and also support multiple container workloads.

Create Azure Container Apps [environments](/azure/container-apps/environment) that include [container\[s\] instances](/azure/container-apps/containers) running Data API builder. These environments could also conceivably include your application instances running in close proximity to the API instances.

For more information, see [Azure Container Apps](/azure/container-apps).

## Azure Container Instances

Azure Container Instances is an Azure service that hosts an individual Docker container image on your behalf. Azure Container Instances is a serverless platform that is a low-friction way of getting a container instance running in Azure without the complexity of a higher-level service. Use Azure Container Instances to quickly deploy a container without worrying about complex clusters or configuration.

Host Data API builder in an Azure Container Instance resource within a [container group](/azure/container-instances/container-instances-container-groups) to have a low-friction method of running the engine. Consider taking advantage of the [virtual networking functionality](/azure/container-instances/container-instances-virtual-network-concepts) by hosting your application instances within the same container group.

For more information, see [Azure Container Instances](/azure/container-instances).

## Azure App Service

Azure App Service is an Azure service that hosts web applications or APIs either running in server-side code or a Docker container. Azure App Service is ideal for complex languages using your preferred programming language server-side. Azure App Service natively supports .NET, Java, Node.js, PHP, and Python applications. You can also support a myriad of extra frameworks and engines using Docker container images, Azure App Service.

You can run Data API builder as either a [native .NET application]/azure/app-service/configure-language-dotnetcore) or a [Docker container image](/azure/app-service/configure-custom-container). Alternatively, you can create a [multi-container-app](/azure/app-service/quickstart-multi-container) using [Docker Compose](https://docs.docker.com/compose) that deploys Data API builder as a sidecar container to an application running your preferred stack.

For more information, see [Azure App Service](/azure/app-service).

## Azure Kubernetes Service

Azure Kubernetes Service is an Azure service that manages a [Kubernetes](https://kubernetes.io) cluster on your behalf. Azure Kubernetes Service is a manage service that handles the infrastructure for your Kubernetes solution while still exposing the individual components for further customizations. Azure Kubernetes Service supports the usage of common Kubernetes manifest files and command-line interfaces so you can apply any existing knowledge or skills about the platform.

Run Data API builder as part of a [Kubernetes container cluster](/azure/aks/concepts-clusters-workloads#kubernetes-cluster-architecture) and allow Azure Kubernetes Service to manage the individual hosts at scale. Consider hosting your applications and API clusters in a manner where they are in close proximity and performant, while being allowed to scale independently using typical Kubernetes control mechanisms.

For more information, see [Azure Kubernetes Service](/azure/aks).

## Azure Static Web Apps (preview)

[!INCLUDE[SWA versioning](includes/static-web-apps-versioning.md)]

Azure Static Web Apps is an Azure service that automatically builds and deploys full stack static web applications from a source control repository to a host in Azure. Azure Static Web Apps is ideal for solutions that are source controlled, built using an automation workflow, and then runs statically in the final hosting service. Use Azure Static Web Apps for applications that result in HTML, CSS, and JavaScript where server-side processing or rendering isn't required.

Data API builder runs as a sidecar service to a static web app. The [database connections](/azure/static-web-apps/database-overview) feature uses a fixed version of the Data API builder engine and can be optionally configured on any static web app.

For more information, see [Azure Static Web Apps](/azure/static-web-apps).

## Next step

> [!div class="nextstepaction"]
> [Deploy to Azure Container Apps](how-to-publish-container-apps.md)

> [!div class="nextstepaction"]
> [Deploy to Azure Container Instances](how-to-publish-container-instances.md)

> [!div class="nextstepaction"]
> [Host in Azure Static Web Apps (preview)](how-to-host-static-web-apps.md)
