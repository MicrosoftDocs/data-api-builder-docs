---
title: Azure authentication
description: Configure authentication in Azure for Data API builder using Microsoft Entra ID and various authentication methods/providers.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 04/08/2025
# Customer Intent: As a developer, I want to configure Azure authentication, so that I can authenticate in the Azure environment.
---

# Azure Authentication in Data API builder

Data API builder allows developers to define the authentication mechanism (identity provider) they want Data API builder to use to authenticate who is making requests.

Authentication is delegated to a supported identity provider where access token can be issued. An acquired access token must be included with incoming requests to Data API builder. Data API builder then validates any presented access tokens, ensuring that Data API builder was the intended audience of the token.

The supported identity provider configuration options are:

- StaticWebApps
- JSON Web Tokens (JWT)

## In Development (AZ Login)

Using `Authentication='Active Directory Default'` in Azure SQL Database connection strings means the client will authenticate using Microsoft Entra credentials. The exact authentication method is determined by the environment. When a developer runs `az login`, the Azure CLI opens a browser window prompting the user to sign in with a Microsoft account or corporate credentials. Once authenticated, Azure CLI retrieves and caches the token linked to the identity in Microsoft Entra ID. This token is then used to authenticate requests to Azure services without requiring credentials in the connection string.

```json
"data-source": {
    "connection-string": "...;Authentication='Active Directory Default';"
}
```

To set up local credentials, simply use `az login` after you install the [Azure CLI](/cli/azure/authenticate-azure-cli). 

```bash
az login
```

## Azure Static Web Apps authentication (EasyAuth)

Data API builder expects [Azure Static Web Apps authentication](/azure/static-web-apps/authentication-authorization) (EasyAuth) to authenticate the request, and to provide metadata about the authenticated user in the `X-MS-CLIENT-PRINCIPAL` HTTP header when using the option `StaticWebApps`. The authenticated user metadata provided by Static Web Apps can be referenced in the following documentation: [Accessing User Information](/azure/static-web-apps/user-information?tabs=csharp).

To use the `StaticWebApps` provider, you need to specify the following configuration in the `runtime.host` section of the configuration file:

```json
"authentication": {
    "provider": "StaticWebApps"
}
```

Using the `StaticWebApps` provider is useful when you plan to run Data API builder in Azure, hosting it using App Service and running it in a container: [Run a custom container in Azure App Service](/azure/app-service/quickstart-custom-container?tabs=dotnet&pivots=container-linux-vscode).

## JWT

To use the JWT provider, you need to configure the `runtime.host.authentication` section by providing the needed information to verify the received JWT token:

```json
"authentication": {
    "provider": "EntraId",
    "jwt": {
        "audience": "<APP_ID>",
        "issuer": "https://login.microsoftonline.com/<AZURE_AD_TENANT_ID>/v2.0"
    }
}
```

## Roles selection

Once a request is authenticated via any of the available options, the roles defined in the token are used to help determine how permission rules are evaluated to [authorize](authorization.md) the request. Any authenticated request is automatically assigned to the `authenticated` system role, unless a user role is requested for use. For more information, see [authorization](authorization.md).

## Anonymous requests

Requests can also be made without being authenticated. In such cases, the request is automatically assigned to the `anonymous` system role so that it can be properly [authorized](authorization.md).

## X-MS-API-ROLE request header

Data API builder requires the header `X-MS-API-ROLE` to authorize requests using custom roles. The value of `X-MS-API-ROLE` must match a role specified in the access token's `roles` claim. For example, if the access token has the role **Sample.Role**, then `X-MS-API-ROLE` should also be **Sample.Role**. For more information, see [authorization user roles](./authorization.md#user-roles).

## Related content

- [Local authentication](authentication-local.md)
- [Authorization](authorization.md)
