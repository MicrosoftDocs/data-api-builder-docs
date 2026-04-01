---
title: Deploy to Azure Kubernetes Service
description: Use kubectl and Azure Container Registry to deploy Data API builder to Azure Kubernetes Service (AKS) with a Kubernetes manifest.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: how-to
ms.date: 03/26/2026
# Customer Intent: As a developer, I want to deploy Data API builder to Azure Kubernetes Service so I can run it at scale in a managed Kubernetes cluster.
---

# Deploy Data API builder to Azure Kubernetes Service

Azure Kubernetes Service (AKS) lets you run Data API builder in a managed Kubernetes cluster alongside your other workloads. This guide walks through building a custom container image that includes your configuration file, pushing it to Azure Container Registry (ACR), and deploying it to AKS with a Kubernetes manifest.

## Prerequisites

- An Azure account with an active subscription. [Create an account for free](https://azure.microsoft.com/pricing/purchase-options/azure-account).
- [Azure CLI](/cli/azure/install-azure-cli) installed
- [kubectl](/azure/aks/tutorial-kubernetes-deploy-cluster#install-the-kubernetes-cli) installed
- [Docker](https://docs.docker.com/get-docker/) installed
- Data API builder CLI. [Install the CLI](../command-line/install.md)
- An existing AKS cluster. [Create an AKS cluster](/azure/aks/learn/quick-kubernetes-deploy-cli)
- An existing supported database reachable from AKS

## Build the configuration file

1. Create a local directory for your configuration files.

1. Initialize a base configuration file using [`dab init`](../command-line/dab-init.md). Use the `@env()` function for the connection string so the secret is injected at runtime, not baked into the image.

    ```bash
    dab init \
      --database-type mssql \
      --connection-string "@env('DATABASE_CONNECTION_STRING')"
    ```

1. Add at least one entity using [`dab add`](../command-line/dab-add.md). Repeat for each table or view you want to expose.

    ```bash
    dab add Books \
      --source dbo.Books \
      --permissions "anonymous:read"
    ```

1. Review `dab-config.json` before continuing.

## Build and push a custom container image

Build an image that includes `dab-config.json` at `/App/dab-config.json`.

1. Create an Azure Container Registry if you don't already have one.

    ```azurecli
    az acr create \
      --resource-group <resource-group> \
      --name <registry-name> \
      --sku Basic \
      --admin-enabled true
    ```

1. Create a `Dockerfile` in the same directory as `dab-config.json`.

    ```dockerfile
    FROM mcr.microsoft.com/azure-databases/data-api-builder:latest
    COPY dab-config.json /App/dab-config.json
    ```

1. Build and push the image using ACR Tasks.

    ```azurecli
    az acr build \
      --registry <registry-name> \
      --image dab:latest \
      .
    ```

1. Note the full image reference: `<registry-name>.azurecr.io/dab:latest`.

## Connect AKS to ACR

Grant your AKS cluster pull access to the registry.

```azurecli
az aks update \
  --name <cluster-name> \
  --resource-group <resource-group> \
  --attach-acr <registry-name>
```

## Store the connection string as a Kubernetes secret

Store the database connection string as a Kubernetes secret so it's never in the manifest file.

```bash
kubectl create secret generic dab-secrets \
  --from-literal=DATABASE_CONNECTION_STRING="<your-connection-string>"
```

> [!WARNING]
> Never place connection strings directly in Kubernetes manifest files or container images. Use secrets or Azure Key Vault.

## Create the Kubernetes manifest

Create a file named `dab-deployment.yaml` with the following content. Replace `<registry-name>` with your ACR name.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dab
  labels:
    app: dab
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dab
  template:
    metadata:
      labels:
        app: dab
    spec:
      containers:
        - name: dab
          image: <registry-name>.azurecr.io/dab:latest
          ports:
            - containerPort: 5000
          env:
            - name: DATABASE_CONNECTION_STRING
              valueFrom:
                secretKeyRef:
                  name: dab-secrets
                  key: DATABASE_CONNECTION_STRING
          readinessProbe:
            httpGet:
              path: /health
              port: 5000
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 5000
            initialDelaySeconds: 15
            periodSeconds: 20
---
apiVersion: v1
kind: Service
metadata:
  name: dab-service
spec:
  selector:
    app: dab
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: LoadBalancer
```

> [!NOTE]
> The `readinessProbe` and `livenessProbe` use the DAB `/health` endpoint. For more information, see [Health checks](../concept/monitor/health-checks.md).

## Deploy to AKS

1. Get credentials for your cluster.

    ```azurecli
    az aks get-credentials \
      --resource-group <resource-group> \
      --name <cluster-name>
    ```

1. Apply the manifest.

    ```bash
    kubectl apply -f dab-deployment.yaml
    ```

1. Watch the rollout until pods are ready.

    ```bash
    kubectl rollout status deployment/dab
    ```

1. Get the external IP address assigned to the service.

    ```bash
    kubectl get service dab-service
    ```

    The `EXTERNAL-IP` column shows the public IP address. Allow a minute for the load balancer to provision.

## Verify the deployment

1. Browse to `http://<external-ip>/health`. A healthy response looks like:

    ```json
    {
      "status": "healthy",
      "version": "2.0.0",
      "app-name": "dab_oss_2.0.0"
    }
    ```

1. Test an entity endpoint.

    ```bash
    curl http://<external-ip>/api/Books
    ```

## Scale the deployment

Change the replica count to scale horizontally.

```bash
kubectl scale deployment/dab --replicas=4
```

Or update `spec.replicas` in `dab-deployment.yaml` and reapply.

## Clean up resources

Remove the deployment and service when no longer needed.

```bash
kubectl delete -f dab-deployment.yaml
kubectl delete secret dab-secrets
```

To delete the AKS cluster and registry, remove the resource group.

```azurecli
az group delete \
  --name <resource-group> \
  --yes --no-wait
```

## Related content

- [Deploy to Azure Container Apps](azure-container-apps.md)
- [Deploy to Azure Container Instances](azure-container-instances.md)
- [Hosting options overview](overview.md)
- [Health checks](../concept/monitor/health-checks.md)
- [Deployment best practices: security](../concept/security/best-practices.md)
