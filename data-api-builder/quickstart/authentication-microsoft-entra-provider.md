---
title: 'Quickstart: Add a Microsoft Entra provider to Data API builder'
description: Use a sample that configures Data API builder with a Microsoft Entra ID provider while keeping anonymous web and API access active.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/02/2026
# Customer Intent: As a developer, I want to add a Microsoft Entra provider to DAB so that I can validate tokens before I require user sign-in.
---

# Quickstart: Add a Microsoft Entra provider to Data API builder

In this quickstart, you use the [Quickstart 3 Setting Up Entra ID sample](https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_entra-db_entra) to configure Data API builder (DAB) with a Microsoft Entra ID authentication provider. The web app and DAB entities remain anonymous, so the browser doesn't need a sign-in UI, MSAL, or bearer tokens.

The sample creates a Microsoft Entra app registration, configures the DAB `EntraId` provider with an audience and issuer, and keeps the `anonymous` role active. This pattern lets you add token validation infrastructure before you require sign-in.

## Prerequisites

- [.NET 8 or later](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [PowerShell](/powershell/scripting/install/installing-powershell)
- [.NET Aspire tooling](/dotnet/aspire/fundamentals/setup-tooling) for local orchestration
- [Azure CLI](/cli/azure/install-azure-cli) for Microsoft Entra setup and Azure deployment
- [sqlpackage](/sql/tools/sqlpackage/sqlpackage-download) if you deploy the database project
- An Azure subscription with permission to create Azure SQL, Azure Container Apps, Azure Container Registry, Log Analytics, and a resource group
- Permission to create or reuse a Microsoft Entra app registration

## What the sample shows

- A static web app that calls DAB without user sign-in.
- DAB configured with the `EntraId` authentication provider.
- A Microsoft Entra app registration that supplies the DAB API audience and issuer.
- Entity permissions that keep the `anonymous` role active.
- Entity permissions that include the `authenticated` role so DAB can accept valid bearer tokens.
- SQL authentication from DAB to the local SQL Server development container.
- Passwordless DAB access to Azure SQL through a system-assigned managed identity.
- .NET Aspire orchestration for local SQL Server, DAB, the web app, SQL Commander, and MCP Inspector.
- Azure deployment and cleanup through PowerShell scripts in `azure-infra`.

## Authentication flow

| Hop | Local authentication | Azure authentication |
| --- | --- | --- |
| User to web app | Anonymous | Anonymous |
| Web app to API | Anonymous | Anonymous |
| API authentication provider | `EntraId`, with anonymous entities | `EntraId`, with anonymous entities |
| API to SQL | SQL authentication | System-assigned managed identity |

> [!IMPORTANT]
> The DAB API validates Microsoft Entra tokens, but anonymous entity permissions still allow unauthenticated requests. Add stricter permissions only when the web app sends bearer tokens.

## Compare with the series

| Step | What changes |
| --- | --- |
| Previous | [Use managed identity](authentication-managed-identity.md) removes the Azure SQL password but leaves the web app and API anonymous. |
| This quickstart | Adds a Microsoft Entra provider, audience, and issuer while keeping anonymous access active. |
| Next | [Use DAB policies for per-user data](authorization-database-policies.md) requires sign-in and filters rows with DAB policy expressions. |

## Use the sample

Clone the sample repository.

```bash
git clone https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_entra-db_entra.git
cd dab-2.0-quickstart-web_anon-api_entra-db_entra
```

Restore local tools.

```dotnetcli
dotnet tool restore
```

Sign in to Azure.

```azurecli
az login
```

Run the sample locally.

```dotnetcli
dotnet run --project aspire-apphost
```

On first run, Aspire checks `dab-config.json` for Microsoft Entra placeholders. If the provider isn't configured, the app offers to run `azure-infra/entra-setup.ps1` interactively. The script creates or configures the app registration, updates the audience and issuer, and then starts the local resources.

The web app loads anonymously. DAB has the `EntraId` provider configured behind the scenes.

Deploy the sample to Azure.

```powershell
pwsh ./azure-infra/azure-up.ps1
```

The deployment script provisions Azure SQL and Azure Container Apps resources for DAB, the web app, MCP Inspector, and SQL Commander. It also configures a system-assigned managed identity for the DAB Container App and passes the Microsoft Entra audience and issuer to DAB.

Clean up Azure resources and the app registration when you're done.

```powershell
pwsh ./azure-infra/azure-down.ps1
```

The cleanup flow runs the Microsoft Entra teardown script. If you need to remove the app registration separately, run `azure-infra/entra-teardown.ps1` from the sample.

## Key files

| Path | Purpose |
| --- | --- |
| `data-api/dab-config.json` | Defines the `EntraId` authentication provider, audience, issuer, and entity roles. |
| `aspire-apphost/Demo.cs` | Checks for Microsoft Entra placeholders in `dab-config.json` and guides local setup. |
| `azure-infra/entra-setup.ps1` | Creates or configures the app registration and API audience. |
| `azure-infra/entra-teardown.ps1` | Deletes the app registration during teardown. |
| `web-app/index.html`, `web-app/app.js`, `web-app/dab.js`, `web-app/config.js` | Static web files that remain anonymous and don't use MSAL. |

## Use GitHub Copilot to recreate this sample

Open the workspace where you want to create the sample in Visual Studio Code, switch GitHub Copilot to agent mode, and paste this prompt.

````copilot-prompt
You are GitHub Copilot running in agent mode. Recreate the Data API builder Quickstart 3 Microsoft Entra provider sample as a complete, runnable project in the current VS Code workspace under `quickstart-03-entra-provider`. Build a static anonymous web app, DAB with the `EntraId` provider configured, local SQL Server with SQL authentication, Azure SQL with managed identity, REST, GraphQL, MCP, .NET Aspire, SQL Commander, MCP Inspector, and Azure Container Apps deployment scripts. Keep the web app anonymous and keep entities callable through the `anonymous` role. Do not add MSAL, sign-in UI, token acquisition, or bearer-token calls to the web app in this quickstart.

Source repository: https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_entra-db_entra. If internet access is available, inspect or clone this repository before you create files. Reuse and adapt its files as closely as possible, especially `web-app/`, `data-api/`, `database/`, `aspire-apphost/`, `mcp-inspector/`, `azure-infra/`, scripts, and README patterns. The goal is to implement the published quickstart, not to invent a different sample. If the repository differs from this prompt or the current Data API builder docs, prefer the current docs for product behavior.

Minimize user interaction. Use the defaults in this prompt and make reasonable best guesses for noncritical choices. Do not ask for a root folder or project folder name; use the current VS Code workspace and the default subfolder. Ask only when you need approval for resource changes, secrets, permissions, materially higher cost, external account choices, or an ambiguous requirement that affects the architecture.

Start with a short plan and proceed with safe defaults before you create files or run commands. Use the default demo schema unless the user requests a custom schema. Ask only these questions if the values aren't already available from the environment or prior context:

- Which Azure subscription, primary region, fallback region, resource group, and tenant should the sample use? Default fallback region: `westus2` if the primary region can't provision Azure SQL or Container Apps.
- Should I create a new Microsoft Entra app registration for the DAB API audience or reuse an existing app ID URI, audience, and issuer?
- Do you approve creating billable Azure resources and a Microsoft Entra app registration if the deployment phase starts?

After the answers, show a checklist and ask for approval before implementation. Include phases for local scaffold, Entra setup, local validation, Azure infrastructure, Azure validation, and cleanup. Do not run `az`, `az ad`, or Azure deployment commands that create or change resources until the user explicitly approves the exact command set.

After approval, continue working without asking status-check questions. If a command, build, container, endpoint, or validation step fails, inspect the error, adjust the project, rerun the step, and continue. Keep iterating until the sample runs end-to-end or you hit a blocker that requires user action.

Use cost-first Azure defaults. Choose the cheapest option that satisfies the quickstart requirements: use a free Azure SQL database offer when the subscription and region support it; otherwise choose the lowest-cost SQL option that supports managed identity and Microsoft Entra validation. Use Azure Container Apps consumption, minimal CPU and memory, Basic Azure Container Registry, minimal Log Analytics retention, and no always-on or dedicated plans unless required. Prioritize finishing the project. Treat regional provisioning limits as expected adjustment points, not failures: if the primary region can't provision a required service or free SQL option, use the approved fallback region such as `westus2`, and continue the deployment. Ask the user only when both the primary and fallback regions can't satisfy the requirements, when a change would materially increase cost, when a new permission is required, or when you need approval for Azure commands that create or change resources beyond the already-approved plan. Keep every resource minimal, but make the web interface neat and approachable: small code footprint, responsive layout, clear status messages, accessible labels, and simple styling that is polished rather than austere.

Verify prerequisites and report only missing items: .NET SDK, Docker Desktop running, PowerShell, Azure CLI signed in, permission to use `az ad` commands, `sqlpackage`, .NET Aspire tooling, and the DAB CLI. Use these docs while building:

- DAB CLI reference: https://learn.microsoft.com/azure/data-api-builder/command-line/
- `dab init`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-init
- `dab add`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-add
- `dab validate`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-validate
- DAB MCP overview: https://learn.microsoft.com/azure/data-api-builder/mcp/overview
- Microsoft Entra authentication in DAB: https://learn.microsoft.com/azure/data-api-builder/concept/security/authenticate-entra

Create this structure under the sample folder:

- `azure-infra/` for Bicep, `azure-up.ps1`, `azure-down.ps1`, `entra-setup.ps1`, `entra-teardown.ps1`, and post-provision scripts.
- `data-api/` for `dab-config.json` and a DAB Dockerfile that bakes the config into the image for Azure.
- `database/` for a SQL Database Project or idempotent SQL scripts with seed data.
- `web-app/` for static anonymous HTML, CSS, and JavaScript.
- `aspire-apphost/` for the .NET Aspire AppHost.
- `mcp-inspector/` for MCP Inspector notes or container assets.

Handle secrets and generated values first. Add `.env`, `**/bin`, and `**/obj` to `.gitignore` before writing secrets. Use `MSSQL_CONNECTION_STRING`, `ENTRA_TENANT_ID`, `ENTRA_AUDIENCE`, and `ENTRA_ISSUER`. Never print tokens or secret values. Use `@env(...)` placeholders in `dab-config.json` where practical.

Configure DAB CORS before you start or deploy the web app. Do not leave `runtime.host.cors.origins` as `[]`. Set it to include the exact web app origins, including scheme and port: the local Aspire web origin, such as `http://localhost:5173`, and the deployed Azure Container Apps web FQDN if Azure deployment is approved. Keep `allow-credentials` set to `false` unless the sample explicitly uses browser credentials or cookies. Direct REST, GraphQL, or Swagger requests can succeed even when the browser blocks JavaScript fetch calls, so browser-origin CORS must be configured and validated separately.

Use this DAB CLI workflow for local config and validation:

```dotnetcli
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --auth.provider EntraID --auth.audience "@env('ENTRA_AUDIENCE')" --auth.issuer "@env('ENTRA_ISSUER')" --host-mode Development --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todos --source dbo.Todos --source.type table --permissions "anonymous:read"
dab validate --config data-api/dab-config.json
```

Use this DAB configuration shape if you write the config directly:

```json
{
	"data-source": {
		"database-type": "mssql",
		"connection-string": "@env('MSSQL_CONNECTION_STRING')"
	},
	"runtime": {
		"rest": { "enabled": true, "path": "/api" },
		"graphql": { "enabled": true, "path": "/graphql" },
		"mcp": { "enabled": true, "path": "/mcp" },
		"host": {
			"mode": "development",
			"authentication": {
				"provider": "EntraId",
				"jwt": {
					"audience": "@env('ENTRA_AUDIENCE')",
					"issuer": "@env('ENTRA_ISSUER')"
				}
			}
		}
	}
}
```

Keep anonymous entity permissions active. Also include `authenticated` where useful so a valid bearer token for the configured audience resolves to the `authenticated` role, but do not require tokens for the web app in this quickstart.

Use these Aspire patterns from the quickstart skills. Use `.WaitForCompletion(sqlDatabaseProject)` for DAB and SQL Commander when a SQL project deploys schema.

```csharp
var dabServer = builder.AddContainer("data-api", "azure-databases/data-api-builder", "latest")
		.WithImageRegistry("mcr.microsoft.com")
		.WithBindMount(new FileInfo("data-api/dab-config.json").FullName, "/App/dab-config.json", isReadOnly: true)
		.WithEnvironment("MSSQL_CONNECTION_STRING", sqlDatabase)
		.WithEnvironment("ENTRA_AUDIENCE", entraAudience)
		.WithEnvironment("ENTRA_ISSUER", entraIssuer)
		.WithHttpEndpoint(targetPort: 5000, name: "http")
		.WithHttpHealthCheck("/health")
		.WaitForCompletion(sqlDatabaseProject);
```

Add SQL Commander with image `jerrynixon/sql-commander:latest`, env var `ConnectionStrings__db`, and a connection string that includes `TrustServerCertificate=true`.

```csharp
var sqlCommander = builder.AddContainer("sql-cmdr", "jerrynixon/sql-commander", "latest")
		.WithImageRegistry("docker.io")
		.WithHttpEndpoint(targetPort: 8080, name: "http")
		.WithEnvironment("ConnectionStrings__db", sqlDatabase)
		.WithHttpHealthCheck("/health")
		.WaitForCompletion(sqlDatabaseProject);
```

Add MCP Inspector with Streamable HTTP transport and omit auth only for local development.

```csharp
var mcpInspector = builder.AddMcpInspector("mcp-inspector")
		.WithMcpServer(dabServer, transportType: McpTransportType.StreamableHttp)
		.WithEnvironment("DANGEROUSLY_OMIT_AUTH", "true")
		.WaitFor(dabServer);
```

For Azure, configure the DAB Container App with a system-assigned managed identity and a passwordless Azure SQL connection string. Bake `dab-config.json` into the DAB image and replace CORS or endpoint placeholders before image build.

```dockerfile
FROM mcr.microsoft.com/azure-databases/data-api-builder:latest
COPY dab-config.json /App/dab-config.json
```

Validate before reporting success:

- `dab validate --config data-api/dab-config.json` exits with code 0.
- `dotnet run --project aspire-apphost` starts the complete local environment.
- A direct database query confirms the seeded table exists and contains rows.
- DAB `/health` returns a 2xx response.
- A browser-origin request from each web app origin receives an `Access-Control-Allow-Origin` response header that matches that origin.
- The web app loads anonymously and does not contain MSAL code.
- REST and GraphQL return seeded rows anonymously.
- A valid bearer token for the configured audience is accepted by DAB and maps to `authenticated`.
- MCP Inspector can list DAB tools and call `describe_entities` or an equivalent DAB MCP tool.
- SQL Commander opens and shows seeded tables.
- The web site returns a successful HTTP response.
- The app registration, audience, issuer, and tenant match DAB configuration.
- In Azure, the DAB Container App has a system-assigned managed identity and uses passwordless Azure SQL.

Do not report final URLs, asset locations, or a success summary until you directly verify database connectivity and query results, a 2xx DAB health response, and a successful web site response. This validation ensures the sample works without requiring the developer to check.
````

## Related content

- [Data API builder quickstarts](index.yml)
- [Quickstart: Use Data API builder policies for per-user data](authorization-database-policies.md)
- [Quickstart: Use managed identity with Data API builder](authentication-managed-identity.md)
- [Quickstart: Use SQL authentication with Data API builder](authentication-sql-credentials.md)
- [Microsoft Entra ID authentication in Data API builder](../concept/security/authenticate-entra.md)
- [DAB configuration file](../configuration/index.md)
- [Deploy Data API builder to Azure Container Apps](../deployment/azure-container-apps.md)