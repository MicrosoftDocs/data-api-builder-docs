---
title: 'Quickstart: Use Data API builder policies for per-user data'
description: Use a sample that authenticates users with Microsoft Entra ID, sends bearer tokens to Data API builder, and filters SQL rows with a database policy.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/02/2026
# Customer Intent: As a developer, I want to use DAB policies with Microsoft Entra authentication so that I can show each signed-in user only their own data.
---

# Quickstart: Use Data API builder policies for per-user data

In this quickstart, you use the [Quickstart 4 User Authentication with DAB Policies sample](https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-api_rls) to filter data per signed-in user. The web app signs in users with Microsoft Entra ID, sends a bearer token to Data API builder (DAB), and DAB applies a database policy before it returns SQL rows.

The sample uses the Microsoft Authentication Library (MSAL) in a single-page application (SPA), the DAB `authenticated` role, and the policy expression `@item.Owner eq @claims.preferred_username`. The sample doesn't use a client secret or custom API code.

## Prerequisites

- [.NET 8 or later](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [PowerShell](/powershell/scripting/install/installing-powershell)
- [.NET Aspire tooling](/dotnet/aspire/fundamentals/setup-tooling) for local orchestration
- [Azure CLI](/cli/azure/install-azure-cli) for Microsoft Entra setup and Azure deployment
- [sqlpackage](/sql/tools/sqlpackage/sqlpackage-download) if you deploy the database project
- An Azure subscription with permission to create Azure SQL, Azure Container Apps, Azure Container Registry, Log Analytics, and a resource group
- Permission to create or reuse Microsoft Entra app registrations

## What the sample shows

- A static web app that uses MSAL browser sign-in and automatic redirect.
- A SPA app registration for the web app and an API app registration for DAB.
- A delegated API scope that the browser requests for DAB calls.
- Bearer-token calls from the web app to DAB.
- DAB configured with the Microsoft Entra ID `EntraId` authentication provider.
- DAB entity permissions that use the `authenticated` role.
- A DAB database policy that filters rows by the signed-in user's claim.
- SQL authentication from DAB to the local SQL Server development container.
- Passwordless DAB access to Azure SQL through a system-assigned managed identity.
- Per-user data filtering in DAB without custom API code or a client secret.

## Authentication flow

| Hop | Local authentication | Azure authentication |
| --- | --- | --- |
| User to web app | Microsoft Entra ID with automatic redirect | Microsoft Entra ID with automatic redirect |
| Web app to API | Bearer token | Bearer token |
| API role | `authenticated` | `authenticated` |
| API to SQL | SQL authentication with DAB policy | System-assigned managed identity with DAB policy |

## Compare with the series

| Step | What changes |
| --- | --- |
| Previous | [Add a Microsoft Entra provider](authentication-microsoft-entra-provider.md) validates tokens but still allows anonymous entity access. |
| This quickstart | Requires MSAL sign-in, sends bearer tokens to DAB, and filters rows with a DAB database policy. |
| Next | [Use SQL row-level security](authorization-sql-row-level-security.md) moves per-user filtering from DAB into SQL. |

## Policy

DAB applies this database policy to protected entity actions.

```text
@item.Owner eq @claims.preferred_username
```

The policy allows a signed-in user to access only rows where the `Owner` column matches the user's `preferred_username` claim. Remove the `anonymous` role from protected entities so anonymous requests to REST and GraphQL return `401`.

```json
{
  "entities": {
    "Todos": {
      "permissions": [
        {
          "role": "authenticated",
          "actions": [
            {
              "action": "read",
              "policy": {
                "database": "@item.Owner eq @claims.preferred_username"
              }
            },
            {
              "action": "update",
              "policy": {
                "database": "@item.Owner eq @claims.preferred_username"
              }
            },
            {
              "action": "delete",
              "policy": {
                "database": "@item.Owner eq @claims.preferred_username"
              }
            }
          ]
        }
      ]
    }
  }
}
```

## Use the sample

Clone the sample repository.

```bash
git clone https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-api_rls.git
cd dab-2.0-quickstart-web_entra-api_entra-db_entra-api_rls
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

On first run, Aspire checks the Microsoft Entra configuration. If configuration values are missing, the sample offers to run `azure-infra/entra-setup.ps1` interactively. The setup script creates or configures the app registrations, updates `web-app/config.js` and `data-api/dab-config.json`, and starts the local resources.

The web app redirects users to Microsoft sign-in. After sign-in, API calls include bearer tokens, and each user sees only rows that match their `preferred_username` claim.

Deploy the sample to Azure.

```powershell
pwsh ./azure-infra/azure-up.ps1
```

The deployment script provisions Azure SQL and Azure Container Apps resources for DAB, the web app, Model Context Protocol (MCP) Inspector, and SQL Commander. It also configures the DAB Container App with a system-assigned managed identity and runs Microsoft Entra setup during deployment.

Clean up Azure resources and app registrations when you're done.

```powershell
pwsh ./azure-infra/azure-down.ps1
```

The cleanup flow runs the Microsoft Entra teardown script. If you need to remove the app registrations separately, run `azure-infra/entra-teardown.ps1` from the sample.

## Key files

| Path | Purpose |
| --- | --- |
| `data-api/dab-config.json` | Defines the `EntraId` provider, `authenticated` role, and database policy. |
| `web-app/auth.js` | Configures MSAL, automatic redirect, token acquisition, and the sign out action. |
| `web-app/index.html` | Loads MSAL browser support and shows authenticated UI elements. |
| `web-app/app.js` | Initializes the app after authentication and updates the signed-in state. |
| `web-app/dab.js` | Sends `Authorization: Bearer <token>` headers with DAB calls. |
| `web-app/config.js` | Stores the tenant ID, SPA client ID, and API scope for MSAL. |

## Use GitHub Copilot to recreate this sample

Open the workspace where you want to create the sample in Visual Studio Code, switch GitHub Copilot to agent mode, and paste this prompt.

````copilot-prompt
You are GitHub Copilot running in agent mode. Recreate the Data API builder Quickstart 4 User Authentication with DAB Policies sample as a complete, runnable project in the current VS Code workspace under `quickstart-04-dab-policies`. Build a static SPA with MSAL browser sign-in, DAB with Microsoft Entra bearer-token validation, a DAB database policy for per-user rows, local SQL Server with SQL authentication, Azure SQL with managed identity, REST, GraphQL, MCP, .NET Aspire, SQL Commander, MCP Inspector, and Azure Container Apps deployment scripts. DAB is the only API, GraphQL, and MCP layer over SQL. Do not create custom API code. Do not create or use a client secret for this quickstart.

Source repository: https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-api_rls. If internet access is available, inspect or clone this repository before you create files. Reuse and adapt its files as closely as possible, especially `web-app/`, `data-api/`, `database/`, `aspire-apphost/`, `mcp-inspector/`, `azure-infra/`, scripts, and README patterns. The goal is to implement the published quickstart, not to invent a different sample. If the repository differs from this prompt or the current Data API builder docs, prefer the current docs for product behavior.

Minimize user interaction. Use the defaults in this prompt and make reasonable best guesses for noncritical choices. Do not ask for a root folder or project folder name; use the current VS Code workspace and the default subfolder. Ask only when you need approval for resource changes, secrets, permissions, materially higher cost, external account choices, or an ambiguous requirement that affects the architecture.

Start with a short plan and proceed with safe defaults before you create files or run commands. Use the default `Owner nvarchar(256)` schema, `@claims.preferred_username` policy, and `api://<api-app-id>/access` scope unless the user explicitly asks for different values. Ask only these questions if the values aren't already available from the environment or prior context:

- Which Azure subscription, primary region, fallback region, resource group, and tenant should the sample use? Default fallback region: `westus2` if the primary region can't provision Azure SQL or Container Apps.
- Should I create new app registrations for the SPA and API or reuse existing registrations?
- Do you approve creating billable Azure resources and Microsoft Entra app registrations if deployment starts?

After the answers, show a checklist and ask for approval before implementation. Include phases for local scaffold, Entra setup, local validation, Azure infrastructure, Azure validation, and cleanup. Do not run `az`, `az ad`, or Azure deployment commands that create or change resources until the user explicitly approves the exact command set.

After approval, continue working without asking status-check questions. If a command, build, container, endpoint, or validation step fails, inspect the error, adjust the project, rerun the step, and continue. Keep iterating until the sample runs end-to-end or you hit a blocker that requires user action.

Use cost-first Azure defaults. Choose the cheapest option that satisfies the quickstart requirements: use a free Azure SQL database offer when the subscription and region support it; otherwise choose the lowest-cost SQL option that supports managed identity and Microsoft Entra validation. Use Azure Container Apps consumption, minimal CPU and memory, Basic Azure Container Registry, minimal Log Analytics retention, and no always-on or dedicated plans unless required. Prioritize finishing the project. Treat regional provisioning limits as expected adjustment points, not failures: if the primary region can't provision a required service or free SQL option, use the approved fallback region such as `westus2`, and continue the deployment. Ask the user only when both the primary and fallback regions can't satisfy the requirements, when a change would materially increase cost, when a new permission is required, or when you need approval for Azure commands that create or change resources beyond the already-approved plan. Keep every resource minimal, but make the web interface neat and approachable: small code footprint, responsive layout, clear status messages, accessible labels, and simple styling that is polished rather than austere.

Verify prerequisites and report only missing items: .NET SDK, Docker Desktop running, PowerShell, Azure CLI signed in, permission to use `az ad`, `sqlpackage`, .NET Aspire tooling, and the DAB CLI. Use these docs while building:

- DAB CLI reference: https://learn.microsoft.com/azure/data-api-builder/command-line/
- `dab add` policies: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-add
- `dab validate`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-validate
- DAB MCP overview: https://learn.microsoft.com/azure/data-api-builder/mcp/overview
- Microsoft Entra authentication in DAB: https://learn.microsoft.com/azure/data-api-builder/concept/security/authenticate-entra

Create this structure under the sample folder:

- `azure-infra/` for Bicep, `azure-up.ps1`, `azure-down.ps1`, `entra-setup.ps1`, `entra-teardown.ps1`, and post-provision scripts.
- `data-api/` for `dab-config.json` and a DAB Dockerfile that bakes the config into the image for Azure.
- `database/` for a SQL Database Project or idempotent SQL scripts with seed rows for at least two owners.
- `web-app/` for static HTML, CSS, and JavaScript with MSAL browser support.
- `aspire-apphost/` for the .NET Aspire AppHost.
- `mcp-inspector/` for MCP Inspector notes or container assets.

Handle generated values first. Add `.env`, `**/bin`, and `**/obj` to `.gitignore` before writing secrets or local configuration. Use `MSSQL_CONNECTION_STRING`, `ENTRA_TENANT_ID`, `ENTRA_AUDIENCE`, `ENTRA_ISSUER`, `SPA_CLIENT_ID`, and `API_SCOPE`. Never print tokens or secret values. Use `@env(...)` placeholders in `dab-config.json` where practical.

Configure DAB CORS before you start or deploy the web app. Do not leave `runtime.host.cors.origins` as `[]`. Set it to include the exact web app origins, including scheme and port: the local Aspire web origin, such as `http://localhost:5173`, and the deployed Azure Container Apps web FQDN if Azure deployment is approved. Keep `allow-credentials` set to `false` because this SPA sends bearer tokens, not browser credentials or cookies. Direct REST, GraphQL, or Swagger requests can succeed even when the browser blocks JavaScript fetch calls, so browser-origin CORS must be configured and validated separately.

Use this DAB CLI workflow and validate after each config change:

```dotnetcli
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --auth.provider EntraID --auth.audience "@env('ENTRA_AUDIENCE')" --auth.issuer "@env('ENTRA_ISSUER')" --host-mode Development --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todos --source dbo.Todos --source.type table --permissions "authenticated:read,update,delete" --policy-database "@item.Owner eq @claims.preferred_username" --mcp.dml-tools true
dab validate --config data-api/dab-config.json
```

Use this DAB policy shape if you write the config directly. Remove the `anonymous` role from protected entities so anonymous REST, GraphQL, and MCP calls to those entities are denied.

```json
{
  "role": "authenticated",
  "actions": [
    { "action": "read", "policy": { "database": "@item.Owner eq @claims.preferred_username" } },
    { "action": "update", "policy": { "database": "@item.Owner eq @claims.preferred_username" } },
    { "action": "delete", "policy": { "database": "@item.Owner eq @claims.preferred_username" } }
  ]
}
```

Implement the SPA with MSAL browser. `web-app/dab.js` must send bearer tokens to DAB on every protected request.

```javascript
export async function getAuthHeaders() {
  const token = await acquireAccessToken();
  return { Authorization: `Bearer ${token}` };
}
```

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

For Azure, configure the DAB Container App with a system-assigned managed identity and bake `dab-config.json` into the DAB image. Replace web URL and CORS placeholders before image build. Do not rely on volume mounts in Azure Container Apps.

Validate before reporting success:

- `dab validate --config data-api/dab-config.json` exits with code 0.
- `dotnet run --project aspire-apphost` starts the complete local environment.
- A direct database query confirms the seeded table exists and contains rows for at least two owners.
- DAB `/health` returns a 2xx response.
- The web site returns a successful HTTP response.
- A browser-origin request from each web app origin receives an `Access-Control-Allow-Origin` response header that matches that origin.
- Anonymous REST and GraphQL requests to protected entities return `401`.
- Signed-in REST and GraphQL calls include bearer headers and return only rows where `Owner` equals the selected claim.
- Two different users see disjoint row sets.
- The DAB configuration uses the `authenticated` role with DAB database policies and no client secret.
- MCP Inspector can connect to DAB MCP and respects authenticated access for protected entities.
- SQL Commander opens and shows seeded tables for at least two owners.
- In Azure, the DAB Container App has a system-assigned managed identity and Container Apps are healthy.

Do not report final URLs, asset locations, or a success summary until you directly verify database connectivity and query results, a 2xx DAB health response, and a successful web site response. This validation ensures the sample works without requiring the developer to check.
````

## Related content

- [Data API builder quickstarts](index.yml)
- [Quickstart: Use SQL row-level security with Data API builder](authorization-sql-row-level-security.md)
- [Quickstart: Add a Microsoft Entra provider to Data API builder](authentication-microsoft-entra-provider.md)
- [Quickstart: Use managed identity with Data API builder](authentication-managed-identity.md)
- [Quickstart: Use SQL authentication with Data API builder](authentication-sql-credentials.md)
- [Microsoft Entra ID authentication in Data API builder](../concept/security/authenticate-entra.md)
- [DAB configuration file](../configuration/index.md)
- [Deploy Data API builder to Azure Container Apps](../deployment/azure-container-apps.md)
