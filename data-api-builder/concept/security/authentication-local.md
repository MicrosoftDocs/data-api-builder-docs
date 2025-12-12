---
title: Local authentication
description: Test authentication and authorization locally for Data API builder using a simulated request with specified roles and/or claims.
author: seesharprun
ms.author: sidandrews
ms.reviewer: jerrynixon
ms.service: data-api-builder
ms.topic: concept-article
ms.date: 06/11/2025
# Customer Intent: As a developer, I want to test authentication locally, so that I don't have to rely on authentication "just working" when published.
---

# Local Authentication in Data API builder

When developing a solution using Data API builder locally, or when running Data API builder on-premises, you need to test the configured authentication and authorization options by simulating a request with a specific role or claim.

To simulate an authenticated request without configuring an authentication provider (like Microsoft Entra ID, for example), you can utilize the `Simulator` authentication providers:

## Use the `Simulator` provider

`Simulator` is a configurable authentication provider that instructs the Data API builder engine to treat all requests as authenticated.

- At a minimum, all requests are evaluated in the context of the system role `Authenticated`.
- If desired, the request is evaluated in the context of any role denoted in the `X-MS-API-ROLE` Http header.

> [!NOTE]
> While the desired role will be honored, authorization permissions defining database policies will not work because custom claims can't be set for the authenticated user with the `Simulator` provider.

### 1. Update the runtime configuration authentication provider

Make sure that in the configuration file you're using the `Simulator` authentication provider and `development` mode is specified. Refer to this sample `host` configuration section:

```json
"host": {
  "mode": "development",
  "authentication": {
    "provider": "Simulator"
  }
}
```

### 2. Specify the role context of the request

With `Simulator` as Data API builder's authentication provider, no custom header is necessary to set the role context to the system role `Authenticated`:

```bash
curl --request GET \
  --url http://localhost:5000/api/books \
```

To set the role context to any other role, including the system role `Anonymous`, the `X-MS-API-ROLE` header must be included with the desired role:

```bash
curl --request GET \
  --url http://localhost:5000/api/books \
  --header 'X-MS-API-ROLE: author' \
```

## Use the `AppService` provider

The `AppService` authentication provider instructs Data API builder to look for a set of HTTP headers only present when running within an Azure Container Apps environment. The client sets these HTTP headers when running locally to simulate an authenticated user, including any role membership or custom claims.

```json
"host": {
  "mode": "development",
  "authentication": {
    "provider": "AppService"
  }
}
```

### 1. Send requests providing a generated `X-MS-CLIENT-PRINCIPAL` header

Once Data API builder is running locally and configured to use the `AppService` authentication provider, you can generate a client principal object manually using the following template:

```json
{  
  "identityProvider": "test",
  "userId": "12345",
  "userDetails": "john@contoso.com",
  "userRoles": ["author", "editor"]
}
```

App Service has the following properties:

|Property|Description|
|---|---|
|identityProvider|Any string value.|
|userId|A unique identifier for the user.|
|userDetails|Username or email address of the user.|
|userRoles|An array of the user's assigned roles.|

In order to be passed with the `X-MS-CLIENT-PRINCIPAL` header, the JSON payload must be Base64-encoded. You can use any online or offline tool to do that. One such tool is [DevToys](https://github.com/veler/DevToys). A sample Base64-encoded payload that represents the JSON previously referenced:

```http
eyAgCiAgImlkZW50aXR5UHJvdmlkZXIiOiAidGVzdCIsCiAgInVzZXJJZCI6ICIxMjM0NSIsCiAgInVzZXJEZXRhaWxzIjogImpvaG5AY29udG9zby5jb20iLAogICJ1c2VyUm9sZXMiOiBbImF1dGhvciIsICJlZGl0b3IiXQp9
```

The following cURL request simulates an authenticated user retrieving the list of available `Book` entity records in the context of the `author` role:

```bash
curl --request GET \
  --url http://localhost:5000/api/books \
  --header 'X-MS-API-ROLE: author' \
  --header 'X-MS-CLIENT-PRINCIPAL: eyAgCiAgImlkZW50aXR5UHJvdmlkZXIiOiAidGVzdCIsCiAgInVzZXJJZCI6ICIxMjM0NSIsCiAgInVzZXJEZXRhaWxzIjogImpvaG5AY29udG9zby5jb20iLAogICJ1c2VyUm9sZXMiOiBbImF1dGhvciIsICJlZGl0b3IiXQp9'
```

## Related content

- [Azure authentication](authentication-azure.md)
- [Authorization](authorization.md)
