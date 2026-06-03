---
title: 'Quickstart: Use on-behalf-of authentication with Data API builder'
description: Run an Azure-only sample that signs in users with Microsoft Entra ID, sends bearer tokens to DAB, and connects to Azure SQL as the actual caller through OBO.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/02/2026
# Customer Intent: As a developer, I want to use OBO authentication with DAB so that I can authenticate the actual calling user in Azure SQL.
---

# Quickstart: Use on-behalf-of authentication with Data API builder

In this quickstart, you use the [Quickstart 6 On-Behalf-Of Flow sample](https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-obo) to run Data API builder (DAB) with user-delegated authentication. The web app signs in users with Microsoft Entra ID, sends bearer tokens to DAB, and DAB exchanges each token for an Azure SQL token for the signed-in user.

The sample uses Azure SQL because local SQL Server can't accept Microsoft Entra tokens. A `WhoAmI` view that runs `SELECT SUSER_NAME()` proves that SQL sees the actual caller, not the DAB managed identity.

## Prerequisites

- [.NET 8 or later](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [PowerShell](/powershell/scripting/install/installing-powershell)
- [.NET Aspire tooling](/dotnet/aspire/fundamentals/setup-tooling) for build orchestration
- [Azure CLI](/cli/azure/install-azure-cli) for Microsoft Entra setup and Azure deployment
- [sqlpackage](/sql/tools/sqlpackage/sqlpackage-download) if you deploy the database project
- An Azure subscription with permission to create Azure SQL, Azure Container Apps, Azure Container Registry, Log Analytics, and a resource group
- Permission to create Microsoft Entra app registrations, create an API app client secret, add Azure SQL Database delegated `user_impersonation` permission, and grant admin consent
- A Microsoft Entra user or group that can become the Azure SQL Microsoft Entra admin

## What the sample shows

- A static web app that uses MSAL browser sign-in.
- Bearer-token calls from the web app to DAB.
- DAB configured with the Microsoft Entra ID `EntraId` authentication provider.
- DAB `user-delegated-auth` configured for OBO token exchange.
- An API app registration with a client secret for the OBO exchange.
- Azure SQL Database delegated `user_impersonation` permission with admin consent.
- A bare Azure SQL connection string with no `User ID`, `Password`, or `Authentication` keyword.
- Authenticated DAB entities with no anonymous access.
- Contained Azure SQL users for signed-in callers.
- A `WhoAmI` view that returns `SUSER_NAME()` to validate the SQL caller identity.
- Azure deployment and cleanup through PowerShell scripts in `azure-infra`.

## Authentication flow

| Hop | Authentication |
| --- | --- |
| User to web app | MSAL browser sign-in with Microsoft Entra ID |
| Web app to DAB API | Bearer token for the DAB API audience |
| DAB API role | `authenticated` |
| DAB to Azure SQL | OBO token for the actual signed-in user |

## Compare with the series

| Step | What changes |
| --- | --- |
| Previous | [Use SQL row-level security](authorization-sql-row-level-security.md) filters rows in SQL, but SQL still authenticates the DAB service identity. |
| This quickstart | Uses OBO so Azure SQL authenticates the actual signed-in user for auditing and user-aware policies. |
| Next | [Configure OBO authentication](../concept/security/authenticate-on-behalf-of.md) explains the OBO configuration properties in detail. |

## Azure-only behavior

OBO requires Azure SQL with Microsoft Entra authentication. A local SQL Server container can't accept Microsoft Entra tokens, so the full OBO path is Azure-only.

Use a bare Azure SQL connection string so DAB can inject the per-user OBO token on each authenticated request.

```text
Server=tcp:<server>.database.windows.net,1433;Database=<database>;Encrypt=True;TrustServerCertificate=False;
```

Don't include these values in the OBO connection string:

- `User ID`
- `Password`
- `Authentication`

> [!IMPORTANT]
> If the connection string includes `Authentication=`, SQL client libraries reject the request when DAB also supplies an access token.

## Use the sample

Clone the sample repository.

```bash
git clone https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-obo.git
cd dab-2.0-quickstart-web_entra-api_entra-db_entra-obo
```

Restore local tools.

```dotnetcli
dotnet tool restore
```

Sign in to Azure.

```azurecli
az login
```

Deploy the sample to Azure.

```powershell
pwsh ./azure-infra/azure-up.ps1
```

The deployment script provisions Azure SQL and Azure Container Apps resources for DAB, the web app, MCP Inspector, and SQL Commander. It also runs Microsoft Entra setup, creates the API app client secret, adds the Azure SQL Database delegated `user_impersonation` permission, grants admin consent, deploys the database, creates contained users, and configures DAB for OBO.

After deployment, open the web app URL printed by the script. Sign in and verify that the **SQL Server sees you as** badge shows your user principal name. The badge reads the `WhoAmI` entity backed by `SELECT SUSER_NAME()`.

Anonymous API requests should return `401 Unauthorized`.

Clean up Azure resources and app registrations when you're done.

```powershell
pwsh ./azure-infra/azure-down.ps1
```

## Key files

| Path | Purpose |
| --- | --- |
| `data-api/dab-config.json` | Enables `user-delegated-auth`, disables cache, configures `EntraId`, and exposes the `WhoAmI` view entity. |
| `database/Views/WhoAmI.sql` | Defines `SELECT SUSER_NAME() AS UserName` for identity verification. |
| `web-app/index.html` | Shows the signed-in user and the SQL identity badge. |
| `web-app/app.js` | Coordinates sign-in, page updates, and identity refresh. |
| `web-app/dab.js` | Sends bearer-token requests to DAB and reads `WhoAmI`. |
| `azure-infra/entra-setup.ps1` | Creates Microsoft Entra app registrations, creates the API client secret, adds Azure SQL Database delegated `user_impersonation`, and grants admin consent. |
| `azure-infra/resources.bicep` | Defines Azure resources and passes the bare Azure SQL connection string and OBO settings to DAB. |
| `azure-infra/post-provision.ps1` | Deploys the database, sets the Azure SQL Microsoft Entra admin, creates contained users, and configures OBO environment values. |

## Use GitHub Copilot to recreate this sample

Open the workspace where you want to create the sample in Visual Studio Code, switch GitHub Copilot to agent mode, and paste this prompt.

````copilot-prompt
You are GitHub Copilot running in agent mode. Recreate the Data API builder Quickstart 6 On-Behalf-Of Flow sample as a complete Azure-only project in the current VS Code workspace under `quickstart-06-on-behalf-of`. Build a static SPA with MSAL browser sign-in, DAB with Microsoft Entra bearer-token validation and OBO user-delegated authentication, Azure SQL, REST, GraphQL, MCP, .NET Aspire build orchestration, SQL Commander, MCP Inspector, and Azure Container Apps deployment scripts. DAB is the only API, GraphQL, and MCP layer over SQL. SQL must authenticate the actual signed-in user, not the DAB managed identity or service principal.

Source repository: https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-obo. If internet access is available, inspect or clone this repository before you create files. Reuse and adapt its files as closely as possible, especially `web-app/`, `data-api/`, `database/`, `aspire-apphost/`, `mcp-inspector/`, `azure-infra/`, scripts, and README patterns. The goal is to implement the published quickstart, not to invent a different sample. If the repository differs from this prompt or the current Data API builder docs, prefer the current docs for product behavior.

Minimize user interaction. Use the defaults in this prompt and make reasonable best guesses for noncritical choices. Do not ask for a root folder or project folder name; use the current VS Code workspace and the default subfolder. Ask only when you need approval for resource changes, secrets, permissions, materially higher cost, external account choices, or an ambiguous requirement that affects the architecture.

Azure-only constraint: do not build a local SQL Server OBO path. Local SQL Server cannot accept Microsoft Entra tokens. Use local tooling only for project generation, web app development, DAB config validation where possible, container builds, and database package builds.

Start with a short plan and proceed with safe defaults before you create files or run commands. Use the default `WhoAmI` view unless the user explicitly asks for additional schema. Ask only these questions if the values aren't already available from the environment or prior context:

- Which Azure subscription, primary region, fallback region, resource group, and tenant should the sample use? Default fallback region: `westus2` if the primary region can't provision Azure SQL or Container Apps.
- Should I create new SPA and API app registrations or reuse existing registrations?
- Confirm that the API app can use a client secret. OBO requires a confidential client.
- Confirm that the API app should receive Azure SQL Database delegated `user_impersonation` permission and admin consent.
- Which Microsoft Entra user or group should become the Azure SQL Microsoft Entra admin?
- Which signed-in users or groups should become contained database users for validation?
- Do you approve creating billable Azure resources, app registrations, and an API app client secret if deployment starts?

After the answers, show a checklist and ask for approval before implementation. Include phases for scaffold, Entra setup, database package, Azure infrastructure, post-provision, validation, and cleanup. Do not run `az`, `az ad`, `azd`, or Azure deployment commands that create or change resources until the user explicitly approves the exact command set.

After approval, continue working without asking status-check questions. If a command, build, container, endpoint, or validation step fails, inspect the error, adjust the project, rerun the step, and continue. Keep iterating until the sample runs end-to-end or you hit a blocker that requires user action.

Use cost-first Azure defaults. Choose the cheapest option that satisfies the quickstart requirements: use a free Azure SQL database offer when the subscription and region support it and it supports Microsoft Entra/OBO validation; otherwise choose the lowest-cost SQL option that supports user-delegated authentication. Use Azure Container Apps consumption, minimal CPU and memory, Basic Azure Container Registry, minimal Log Analytics retention, and no always-on or dedicated plans unless required. Prioritize finishing the project. Treat regional provisioning limits as expected adjustment points, not failures: if the primary region can't provision a required service or free SQL option, use the approved fallback region such as `westus2`, and continue the deployment. Ask the user only when both the primary and fallback regions can't satisfy the requirements, when a change would materially increase cost, when a new permission is required, or when you need approval for Azure commands that create or change resources beyond the already-approved plan. Keep every resource minimal, but make the web interface neat and approachable: small code footprint, responsive layout, clear status messages, accessible labels, and simple styling that is polished rather than austere.

Verify prerequisites and report only missing items: .NET SDK, Docker Desktop running, PowerShell, Azure CLI signed in, permission to create app registrations and grant admin consent, `sqlpackage`, .NET Aspire tooling, and the DAB CLI. Use these docs while building:

- DAB CLI reference: https://learn.microsoft.com/azure/data-api-builder/command-line/
- `dab configure` OBO options: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-configure
- `dab validate`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-validate
- DAB MCP overview: https://learn.microsoft.com/azure/data-api-builder/mcp/overview
- OBO concept: https://learn.microsoft.com/azure/data-api-builder/concept/security/authenticate-on-behalf-of
- User-delegated auth configuration: https://learn.microsoft.com/azure/data-api-builder/configuration/data-source#user-delegated-auth

Create this structure under the sample folder:

- `azure-infra/` for Bicep, `azure-up.ps1`, `azure-down.ps1`, `entra-setup.ps1`, `entra-teardown.ps1`, `resources.bicep`, and `post-provision.ps1`.
- `data-api/` for `dab-config.json` and a DAB Dockerfile that bakes the config into the image.
- `database/` for a SQL Database Project, seed data, and `Views/WhoAmI.sql`.
- `web-app/` for static HTML, CSS, and JavaScript with MSAL browser support.
- `aspire-apphost/` for build orchestration only.
- `mcp-inspector/` for MCP Inspector container assets and nginx same-origin proxy config.

Handle secrets first. Add `.env`, `**/bin`, and `**/obj` to `.gitignore` before writing secrets or local configuration. Store the API client secret only in local `.env` files for local preparation and in Azure Key Vault or Azure Container Apps secrets for Azure. Never inline secret values in Bicep, PowerShell scripts, generated JSON, logs, or reports. Generate secret references for Container Apps instead of plaintext environment values. Never print tokens, passwords, or client secret values. Redact all secret values as `***redacted***`.

Configure DAB CORS before you start or deploy the web app. Do not leave `runtime.host.cors.origins` as `[]`. Set it to include the exact web app origins, including scheme and port: any local web origin used for development and the deployed Azure Container Apps web FQDN. Keep `allow-credentials` set to `false` because this SPA sends bearer tokens, not browser credentials or cookies. Direct REST, GraphQL, or Swagger requests can succeed even when the browser blocks JavaScript fetch calls, so browser-origin CORS must be configured and validated separately.

Use this DAB CLI workflow for config shaping and validation where possible:

```dotnetcli
dab init --database-type mssql --connection-string "@env('DATABASE_CONNECTION_STRING')" --auth.provider EntraID --auth.audience "@env('ENTRA_AUDIENCE')" --auth.issuer "@env('ENTRA_ISSUER')" --rest.enabled true --graphql.enabled true --mcp.enabled true
dab configure --data-source.user-delegated-auth.enabled true --data-source.user-delegated-auth.provider EntraId --data-source.user-delegated-auth.database-audience "https://database.windows.net"
dab add WhoAmI --source dbo.vw_WhoAmI --source.type view --source.key-fields "UserName" --permissions "authenticated:read" --mcp.dml-tools true
dab validate --config data-api/dab-config.json
```

Use a bare Azure SQL connection string so DAB can inject the per-user OBO access token. Do not include `User ID`, `Password`, or `Authentication`.

```text
Server=tcp:<server>.database.windows.net,1433;Database=<database>;Encrypt=True;TrustServerCertificate=False;
```

Use this DAB data-source shape for OBO:

```json
{
	"data-source": {
		"database-type": "mssql",
		"connection-string": "@env('DATABASE_CONNECTION_STRING')",
		"user-delegated-auth": {
			"enabled": true,
			"provider": "EntraId",
			"database-audience": "https://database.windows.net"
		}
	}
}
```

Create `database/Views/WhoAmI.sql` to prove SQL sees the signed-in user.

```sql
CREATE VIEW dbo.vw_WhoAmI AS
SELECT CAST(SUSER_NAME() AS nvarchar(256)) AS UserName;
```

Implement the SPA with MSAL browser. `web-app/dab.js` must send bearer tokens to DAB on every protected request.

```javascript
export async function getAuthHeaders() {
	const token = await acquireAccessToken();
	return { Authorization: `Bearer ${token}` };
}
```

For Azure, bake `dab-config.json` into the DAB image. Do not rely on volume mounts in Azure Container Apps.

```dockerfile
FROM mcr.microsoft.com/azure-databases/data-api-builder:latest
COPY dab-config.json /App/dab-config.json
```

Before any Azure post-provision command, list the exact `az`, `az acr`, `az containerapp`, and `sqlpackage` commands you intend to run and wait for explicit user approval. Post-provision in this order: deploy dacpac, set the Azure SQL Microsoft Entra admin, create contained database users or groups for validation, grant access to demo objects and `WhoAmI`, replace placeholders, build and push the DAB image, then update Container Apps.

```powershell
dotnet build database/database.sqlproj -c Release
sqlpackage /Action:Publish /SourceFile:database/bin/Release/database.dacpac /TargetConnectionString:"$sqlConn" /p:BlockOnPossibleDataLoss=false
az acr build --registry $acrName --image dab-api:latest --file ./data-api/Dockerfile ./data-api/
az containerapp update --name $dabAppName --resource-group $resourceGroup --image "$acrName.azurecr.io/dab-api:latest"
```

Deploy MCP Inspector with a same-origin proxy pattern and set `MCP_SERVER_URL` to the DAB `/mcp` endpoint.

```nginx
location /mcp {
	proxy_pass http://127.0.0.1:6277;
	proxy_http_version 1.1;
	proxy_set_header Upgrade $http_upgrade;
	proxy_set_header Connection "upgrade";
	proxy_buffering off;
}
```

Deploy SQL Commander with env var `ConnectionStrings__db` and ensure the connection string includes `TrustServerCertificate=true`.

```text
ConnectionStrings__db=Server=<server>.database.windows.net;Database=<database>;User Id=<user>;Password=<password>;TrustServerCertificate=true
```

Validation must prove OBO, not only API authentication:

- A direct Azure SQL query confirms the database is reachable, the deployed objects exist, and required contained users or groups exist.
- DAB `/health` returns a 2xx response.
- The web site returns a successful HTTP response.
- A browser-origin request from each web app origin receives an `Access-Control-Allow-Origin` response header that matches that origin.
- The web app signs in with Microsoft Entra ID.
- Signed-in REST, GraphQL, and MCP calls include bearer headers and reach DAB under the `authenticated` role.
- The `WhoAmI` entity returns the signed-in user's UPN from `SUSER_NAME()`.
- `WhoAmI` does not return the DAB managed identity, service principal, or Container App identity.
- Anonymous REST and GraphQL calls return `401`.
- The DAB Container App database connection string contains no SQL password, no `User ID`, and no `Authentication` keyword.
- The API client secret exists only as a secret reference or redacted local value.
- MCP Inspector connects to DAB MCP with streamable HTTP.
- SQL Commander can browse the deployed schema.
- Required contained users or groups exist in Azure SQL.

Do not report final URLs, asset locations, or a success summary until you directly verify database connectivity and query results, a 2xx DAB health response, and a successful web site response. This validation ensures the sample works without requiring the developer to check.

Troubleshoot with these checks:

- OBO token exchange fails: verify the API app has Azure SQL Database delegated `user_impersonation` permission and admin consent.
- SQL login fails for a token-identified principal: add the signed-in user or group as a contained user in the database.
- DAB returns 401 for valid bearer tokens: verify audience and issuer values in `dab-config.json`.
- SQL sees the service identity instead of the user: verify `user-delegated-auth`, the API client secret, and the bare SQL connection string.
````

## Related content

- [Data API builder quickstarts](index.yml)
- [Quickstart: Use SQL row-level security with Data API builder](authorization-sql-row-level-security.md)
- [Configure On-Behalf-Of user-delegated authentication](../concept/security/authenticate-on-behalf-of.md)
- [User-delegated auth configuration reference](../configuration/data-source.md#user-delegated-auth)
- [Quickstart: Add a Microsoft Entra provider to Data API builder](authentication-microsoft-entra-provider.md)
- [Microsoft Entra ID authentication in Data API builder](../concept/security/authenticate-entra.md)
- [What's new in Data API builder version 2.0](../whats-new/version-2-0.md#introducing-on-behalf-of-obo-user-delegation)
