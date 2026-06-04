---
title: 'Quickstart: Use SQL row-level security with Data API builder'
description: Use a sample that authenticates users with Microsoft Entra ID, sends bearer tokens to Data API builder, and filters SQL rows with row-level security.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/02/2026
# Customer Intent: As a developer, I want to use SQL row-level security with DAB so that I can enforce per-user data isolation in the database.
---

# Quickstart: Use SQL row-level security with Data API builder

In this quickstart, you use the [Quickstart 5 Row-Level Security sample](https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-db_rls) to enforce per-user data isolation in SQL Server. The web app signs in users with Microsoft Entra ID, sends a bearer token to Data API builder (DAB), and SQL row-level security (RLS) filters rows at the database layer.

The sample uses the Microsoft Authentication Library (MSAL) in a single-page application (SPA), the DAB `authenticated` role, and SQL Server row-level security (RLS) with a predicate function and security policy. DAB maps the authenticated user's `preferred_username` claim into SQL `SESSION_CONTEXT`, and SQL filters rows from that session context. The sample doesn't use DAB per-entity database policies or custom API code.

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
- SQL Server RLS that filters rows by the signed-in user's `preferred_username` claim.
- DAB session context that maps JSON Web Token (JWT) claims into SQL `SESSION_CONTEXT`.
- SQL authentication from DAB to the local SQL Server development container.
- Passwordless DAB access to Azure SQL through a system-assigned managed identity.
- Per-user data filtering in SQL without DAB per-entity database policies.

## Authentication flow

| Hop | Local authentication | Azure authentication |
| --- | --- | --- |
| User to web app | Microsoft Entra ID with automatic redirect | Microsoft Entra ID with automatic redirect |
| Web app to API | Bearer token | Bearer token |
| API role | `authenticated` | `authenticated` |
| API to SQL | SQL authentication with SQL RLS | System-assigned managed identity with SQL RLS |

## Compare with the series

| Step | What changes |
| --- | --- |
| Previous | [Use DAB policies for per-user data](authorization-database-policies.md) filters rows in DAB with policy expressions. |
| This quickstart | Moves per-user filtering into SQL RLS by using DAB-populated session context. |
| Next | [Use on-behalf-of authentication](authentication-on-behalf-of.md) lets Azure SQL authenticate the actual signed-in user. |

## RLS policy

SQL Server enforces row-level access with a predicate function and security policy.

```sql
CREATE FUNCTION dbo.UserFilterPredicate(@OwnerId sysname)
RETURNS TABLE WITH SCHEMABINDING AS
RETURN SELECT 1 AS IsVisible
WHERE @OwnerId = CAST(SESSION_CONTEXT(N'preferred_username') AS sysname);

CREATE SECURITY POLICY UserFilterPolicy
ADD FILTER PREDICATE dbo.UserFilterPredicate(Owner) ON dbo.Todos
WITH (STATE = ON);
```

DAB sends authenticated JWT claims to SQL session context when `data-source.options.set-session-context` is `true`.

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('MSSQL_CONNECTION_STRING')",
    "options": {
      "set-session-context": true
    }
  }
}
```

The database returns only rows where the `Owner` column matches `SESSION_CONTEXT(N'preferred_username')`. DAB can request rows normally; SQL enforces the final filter.

> [!IMPORTANT]
> This sample doesn't use DAB database policies such as `@item.Owner eq @claims.preferred_username`. SQL RLS owns the row filter.

## Use the sample

Clone the sample repository.

```bash
git clone https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-db_rls.git
cd dab-2.0-quickstart-web_entra-api_entra-db_entra-db_rls
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

On first run, Aspire checks the Microsoft Entra configuration. If configuration values are missing, the sample offers to run the Microsoft Entra setup flow interactively. The setup script creates or configures the app registrations, updates `web-app/config.js` and `data-api/dab-config.json`, and starts the local resources.

The web app redirects users to Microsoft sign-in. After sign-in, API calls include bearer tokens, DAB maps `preferred_username` into SQL session context, and SQL RLS returns only matching rows.

Deploy the sample to Azure.

```powershell
pwsh ./azure-infra/azure-up.ps1
```

The deployment script provisions Azure SQL and Azure Container Apps resources for DAB, the web app, Model Context Protocol (MCP) Inspector, and SQL Commander. It also configures the DAB Container App with a system-assigned managed identity and runs `azure-infra/post-provision.ps1` to deploy the database, create the managed identity user, grant database roles, and verify RLS setup.

Clean up Azure resources and app registrations when you're done.

```powershell
pwsh ./azure-infra/azure-down.ps1
```

The cleanup flow deletes Azure resources and runs the Microsoft Entra teardown script. If you need to remove app registrations separately, run the teardown script from the sample's `azure-infra` folder.

## Key files

| Path | Purpose |
| --- | --- |
| `data-api/dab-config.json` | Defines the `EntraId` provider, `authenticated` role, and `set-session-context` setting. |
| `database/Functions/UserFilterPredicate.sql` | Defines the RLS predicate function that compares `Owner` to `SESSION_CONTEXT(N'preferred_username')`. |
| `database/Security/UserFilterPolicy.sql` | Defines the `UserFilterPolicy` security policy on `dbo.Todos`. |
| `web-app/auth.js` | Configures MSAL, automatic redirect, token acquisition, and the sign out action. |
| `web-app/dab.js` | Sends `Authorization: Bearer <token>` headers with DAB calls. |
| `web-app/config.js` | Stores the tenant ID, SPA client ID, API URL, and API scope for MSAL. |
| `azure-infra/post-provision.ps1` | Deploys the dacpac, sets the Azure SQL Microsoft Entra admin, creates the managed identity user, grants database roles, and updates DAB and web app settings. |

## Use GitHub Copilot to recreate this sample

Open the workspace where you want to create the sample in Visual Studio Code, switch GitHub Copilot to agent mode, and paste this prompt.

````copilot-prompt
You are GitHub Copilot running in agent mode. Recreate the Data API builder Quickstart 5 SQL Row-Level Security sample as a complete, runnable project in the current VS Code workspace under `quickstart-05-sql-row-level-security`. Build a static SPA with MSAL browser sign-in, DAB with Microsoft Entra bearer-token validation, SQL Server row-level security (RLS), local SQL Server with SQL authentication, Azure SQL with managed identity, REST, GraphQL, MCP, .NET Aspire, SQL Commander, MCP Inspector, and Azure Container Apps deployment scripts. DAB is the only API, GraphQL, and MCP layer over SQL. Do not create custom API code. Do not add DAB per-entity database policies; SQL RLS must enforce row filtering. Do not create or use a client secret for this quickstart.

Source repository: https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-db_rls. If internet access is available, inspect or clone this repository before you create files. Reuse and adapt its files as closely as possible, especially `web-app/`, `data-api/`, `database/`, `aspire-apphost/`, `mcp-inspector/`, `azure-infra/`, scripts, and README patterns. The goal is to implement the published quickstart, not to invent a different sample. If the repository differs from this prompt or the current Data API builder docs, prefer the current docs for product behavior.

Minimize user interaction. Use the defaults in this prompt and make reasonable best guesses for noncritical choices. Do not ask for a root folder or project folder name; use the current VS Code workspace and the default subfolder. Ask only when you need approval for resource changes, secrets, permissions, materially higher cost, external account choices, or an ambiguous requirement that affects the architecture.

Start with a short plan and proceed with safe defaults before you create files or run commands. Use the default `Owner nvarchar(256) NOT NULL` schema, `api://<api-app-id>/access` scope, and `preferred_username` claim-to-session-context mapping unless the user explicitly asks for different values. Ask only these questions if the values aren't already available from the environment or prior context:

- Which Azure subscription, primary region, fallback region, resource group, and tenant should the sample use? Default fallback region: `westus2` if the primary region can't provision Azure SQL or Container Apps.
- Should I create new app registrations for the SPA and API or reuse existing registrations?
- Do you approve creating billable Azure resources and Microsoft Entra app registrations if deployment starts?

If any artifact uses a different claim key, align all DAB config, SQL predicate, seed data, and validation steps to `preferred_username` and continue. Ask only if the intended claim mapping is ambiguous after inspecting the artifacts.

After the answers, show a checklist and ask for approval before implementation. Include phases for local scaffold, Entra setup, RLS schema, local validation, Azure infrastructure, Azure validation, and cleanup. Do not run `az`, `az ad`, or Azure deployment commands that create or change resources until the user explicitly approves the exact command set.

After approval, continue working without asking status-check questions. If a command, build, container, endpoint, or validation step fails, inspect the error, adjust the project, rerun the step, and continue. Keep iterating until the sample runs end-to-end or you hit a blocker that requires user action.

Use cost-first Azure defaults. Choose the cheapest option that satisfies the quickstart requirements: use a free Azure SQL database offer when the subscription and region support it; otherwise choose the lowest-cost SQL option that supports managed identity, Microsoft Entra validation, and SQL row-level security. Use Azure Container Apps consumption, minimal CPU and memory, Basic Azure Container Registry, minimal Log Analytics retention, and no always-on or dedicated plans unless required. Prioritize finishing the project. Treat regional provisioning limits as expected adjustment points, not failures: if the primary region can't provision a required service or free SQL option, use the approved fallback region such as `westus2`, and continue the deployment. Ask the user only when both the primary and fallback regions can't satisfy the requirements, when a change would materially increase cost, when a new permission is required, or when you need approval for Azure commands that create or change resources beyond the already-approved plan. Keep every resource minimal, but make the web interface neat and approachable: small code footprint, responsive layout, clear status messages, accessible labels, and simple styling that is polished rather than austere.

Verify prerequisites and report only missing items: .NET SDK, Docker Desktop running, PowerShell, Azure CLI signed in, permission to use `az ad`, `sqlpackage`, .NET Aspire tooling, and the DAB CLI. Use these docs while building:

- DAB CLI reference: https://learn.microsoft.com/azure/data-api-builder/command-line/
- `dab init` session context: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-init
- `dab configure` session context: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-configure
- `dab validate`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-validate
- DAB MCP overview: https://learn.microsoft.com/azure/data-api-builder/mcp/overview

Create this structure under the sample folder:

- `azure-infra/` for Bicep, `azure-up.ps1`, `azure-down.ps1`, `entra-setup.ps1`, `entra-teardown.ps1`, and `post-provision.ps1`.
- `data-api/` for `dab-config.json` and a DAB Dockerfile that bakes the config into the image for Azure.
- `database/` for a SQL Database Project with `Functions/UserFilterPredicate.sql`, `Security/UserFilterPolicy.sql`, and seed rows for at least two owners.
- `web-app/` for static HTML, CSS, and JavaScript with MSAL browser support.
- `aspire-apphost/` for the .NET Aspire AppHost.
- `mcp-inspector/` for MCP Inspector notes or container assets.

Handle generated values first. Add `.env`, `**/bin`, and `**/obj` to `.gitignore` before writing secrets or local configuration. Use `MSSQL_CONNECTION_STRING`, `ENTRA_TENANT_ID`, `ENTRA_AUDIENCE`, `ENTRA_ISSUER`, `SPA_CLIENT_ID`, and `API_SCOPE`. Never print tokens or secret values. Use `@env(...)` placeholders in `dab-config.json` where practical.

Configure DAB CORS before you start or deploy the web app. Do not leave `runtime.host.cors.origins` as `[]`. Set it to include the exact web app origins, including scheme and port: the local Aspire web origin, such as `http://localhost:5173`, and the deployed Azure Container Apps web FQDN if Azure deployment is approved. Keep `allow-credentials` set to `false` because this SPA sends bearer tokens, not browser credentials or cookies. Direct REST, GraphQL, or Swagger requests can succeed even when the browser blocks JavaScript fetch calls, so browser-origin CORS must be configured and validated separately.

Use this DAB CLI workflow and validate after each config change:

```dotnetcli
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --set-session-context true --auth.provider EntraID --auth.audience "@env('ENTRA_AUDIENCE')" --auth.issuer "@env('ENTRA_ISSUER')" --host-mode Development --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todos --source dbo.Todos --source.type table --permissions "authenticated:read,create,update,delete" --mcp.dml-tools true
dab validate --config data-api/dab-config.json
```

Use this DAB data-source shape. `set-session-context` is required so DAB maps claims into SQL `SESSION_CONTEXT`.

```json
{
  "data-source": {
    "database-type": "mssql",
    "connection-string": "@env('MSSQL_CONNECTION_STRING')",
    "options": { "set-session-context": true }
  }
}
```

Create SQL RLS in the database project. The predicate must use the same claim name DAB sends to `SESSION_CONTEXT`; if any artifact uses a different key, align the artifacts to the approved claim mapping and continue. Ask the user only if the intended claim mapping is ambiguous.

```sql
CREATE FUNCTION dbo.UserFilterPredicate(@OwnerId sysname)
RETURNS TABLE WITH SCHEMABINDING AS
RETURN SELECT 1 AS IsVisible
WHERE @OwnerId = CAST(SESSION_CONTEXT(N'preferred_username') AS sysname);

CREATE SECURITY POLICY UserFilterPolicy
ADD FILTER PREDICATE dbo.UserFilterPredicate(Owner) ON dbo.Todos
WITH (STATE = ON);
```

Do not add `policy.database` filters to DAB entity permissions in this quickstart. SQL RLS is the authoritative filter. Remove the `anonymous` role from protected entities so anonymous REST, GraphQL, and MCP calls to those entities are denied.

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

For Azure, configure the DAB Container App with a system-assigned managed identity, deploy the dacpac before image validation, and bake `dab-config.json` into the DAB image. Replace web URL and CORS placeholders before image build. Do not rely on volume mounts in Azure Container Apps.

Validate before reporting success:

- `dab validate --config data-api/dab-config.json` exits with code 0.
- `dotnet run --project aspire-apphost` starts the complete local environment.
- A direct database query confirms the seeded table exists, contains rows for at least two owners, and has the RLS policy enabled.
- DAB `/health` returns a 2xx response.
- The web site returns a successful HTTP response.
- A browser-origin request from each web app origin receives an `Access-Control-Allow-Origin` response header that matches that origin.
- Anonymous REST and GraphQL requests to protected entities return `401`.
- Signed-in REST and GraphQL calls include bearer headers and reach DAB under the `authenticated` role.
- DAB sends `preferred_username` into SQL `SESSION_CONTEXT`.
- `SELECT name, is_enabled FROM sys.security_policies` shows `UserFilterPolicy` with `is_enabled = 1`.
- Two different users see different row sets when `Owner` values differ.
- The DAB configuration has `set-session-context` set to `true` and no per-entity database policies.
- MCP Inspector can connect to DAB MCP and respects authenticated access for protected entities.
- SQL Commander opens and shows seeded tables and the enabled RLS policy.
- In Azure, the DAB Container App has a system-assigned managed identity and Container Apps are healthy.

Do not report final URLs, asset locations, or a success summary until you directly verify database connectivity and query results, a 2xx DAB health response, and a successful web site response. This validation ensures the sample works without requiring the developer to check.
````

## Related content

- [Data API builder quickstarts](index.yml)
- [Quickstart: Use on-behalf-of authentication with Data API builder](authentication-on-behalf-of.md)
- [Quickstart: Use Data API builder policies for per-user data](authorization-database-policies.md)
- [Quickstart: Add a Microsoft Entra provider to Data API builder](authentication-microsoft-entra-provider.md)
- [Quickstart: Use managed identity with Data API builder](authentication-managed-identity.md)
- [Microsoft Entra ID authentication in Data API builder](../concept/security/authenticate-entra.md)
- [DAB configuration file](../configuration/index.md)
- [Deploy Data API builder to Azure Container Apps](../deployment/azure-container-apps.md)