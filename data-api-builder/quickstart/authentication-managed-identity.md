---
title: 'Quickstart: Use managed identity with Data API builder'
description: Use a sample that runs Data API builder with anonymous web and API access, passwordless Azure SQL access through managed identity, REST, GraphQL, MCP, Aspire, and Azure deployment.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/02/2026
# Customer Intent: As a developer, I want to run a DAB sample that uses managed identity so that I can connect DAB to Azure SQL without storing a SQL password.
---

# Quickstart: Use managed identity with Data API builder

In this quickstart, you use the [Quickstart 2 Managed Identity sample](https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_anon-db_entra) to run Data API builder (DAB) with passwordless access to Azure SQL. The sample uses anonymous access from the user to the web app, anonymous access from the web app to DAB, and a system-assigned managed identity from DAB to Azure SQL.

The sample exposes SQL data through REST, GraphQL, and MCP. It also includes .NET Aspire local orchestration and Azure deployment scripts.

> [!IMPORTANT]
> The local path can use SQL authentication as a development fallback. The Azure path uses managed identity and has no SQL password in the DAB configuration.

## Prerequisites

- [.NET 8 or later](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [PowerShell](/powershell/scripting/install/installing-powershell)
- [.NET Aspire tooling](/dotnet/aspire/fundamentals/setup-tooling) for local orchestration
- [Azure CLI](/cli/azure/install-azure-cli) for Azure deployment
- [sqlpackage](/sql/tools/sqlpackage/sqlpackage-download) if you deploy the database project
- An Azure subscription with permission to create Azure SQL, Azure Container Apps, Azure Container Registry, Log Analytics, and a resource group
- A Microsoft Entra user or group that can become the Azure SQL Microsoft Entra admin

## What the sample shows

- A static web app that calls DAB without user sign-in.
- DAB configured as the only API, GraphQL, and MCP layer over SQL.
- SQL authentication from DAB to the local SQL Server development container.
- Passwordless DAB access to Azure SQL through a system-assigned managed identity.
- Azure SQL configured with a Microsoft Entra admin.
- A contained database user created for the DAB managed identity.
- `db_datareader` and `db_datawriter` role grants for the DAB identity.
- .NET Aspire orchestration for local SQL Server, DAB, the web app, SQL Commander, and MCP Inspector.
- Azure deployment and cleanup through PowerShell scripts in `azure-infra`.

## Authentication flow

| Hop | Local authentication | Azure authentication |
| --- | --- | --- |
| User to web app | Anonymous | Anonymous |
| Web app to API | Anonymous | Anonymous |
| API to SQL | SQL authentication | System-assigned managed identity |

## Compare with the series

| Step | What changes |
| --- | --- |
| Previous | [Use SQL authentication](authentication-sql-credentials.md) stores a SQL credential for DAB-to-SQL access. |
| This quickstart | Removes the Azure SQL password by using a system-assigned managed identity. |
| Next | [Add a Microsoft Entra provider](authentication-microsoft-entra-provider.md) wires token validation while keeping anonymous API access. |

## Use the sample

Clone the sample repository.

```bash
git clone https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_anon-db_entra.git
cd dab-2.0-quickstart-web_anon-api_anon-db_entra
```

Run the sample locally.

```dotnetcli
dotnet tool restore
dotnet run --project aspire-apphost
```

The Aspire dashboard opens at `http://localhost:15888`. The web app opens at `http://localhost:5173`. Use the dashboard to inspect the DAB endpoint, SQL Server container, MCP Inspector, and SQL Commander resources.

Deploy the sample to Azure.

```powershell
pwsh ./azure-infra/azure-up.ps1
```

The deployment script provisions Azure SQL and Azure Container Apps resources for DAB, the web app, MCP Inspector, and SQL Commander. It also sets the DAB Container App to use a system-assigned managed identity and configures a passwordless Azure SQL connection string shaped like this example.

```text
Server=tcp:<sql-server>.database.windows.net,1433;Database=<database>;Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;
```

The post-provision script sets the Azure SQL Microsoft Entra admin, creates a contained database user for the DAB managed identity, and grants `db_datareader` and `db_datawriter`.

Clean up Azure resources when you're done.

```powershell
pwsh ./azure-infra/azure-down.ps1
```

## Key files

| Path | Purpose |
| --- | --- |
| `azure-infra/resources.bicep` | Defines Azure resources, enables `SystemAssigned` identity on the DAB Container App, and sets the passwordless Azure SQL connection string. |
| `azure-infra/main.bicep` | Orchestrates the deployment and outputs the DAB Container App principal ID. |
| `azure-infra/post-provision.ps1` | Sets the Azure SQL Microsoft Entra admin, creates the contained database user for the DAB identity, and grants database roles. |
| `data-api/dab-config.json` | DAB runtime configuration for SQL, REST, GraphQL, MCP, and anonymous entity access. |
| `database` | SQL database project, schema files, and seed data scripts. |
| `web-app` | Static web app that calls DAB anonymously. |
| `aspire-apphost` | .NET Aspire AppHost that orchestrates local containers and project resources. |

## Use GitHub Copilot to recreate this sample

Open the workspace where you want to create the sample in Visual Studio Code, switch GitHub Copilot to agent mode, and paste this prompt.

````copilot-prompt
You are GitHub Copilot running in agent mode. Recreate the Data API builder Quickstart 2 Managed Identity sample as a complete, runnable project in the current VS Code workspace under `quickstart-02-managed-identity`. Build a static web app, DAB, local SQL Server with SQL authentication for development, Azure SQL with system-assigned managed identity for Azure, REST, GraphQL, MCP, .NET Aspire, SQL Commander, MCP Inspector, and Azure Container Apps deployment scripts. DAB is the only API, GraphQL, and MCP layer over SQL.

Source repository: https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_anon-db_entra. If internet access is available, inspect or clone this repository before you create files. Reuse and adapt its files as closely as possible, especially `web-app/`, `data-api/`, `database/`, `aspire-apphost/`, `mcp-inspector/`, `azure-infra/`, scripts, and README patterns. The goal is to implement the published quickstart, not to invent a different sample. If the repository differs from this prompt or the current Data API builder docs, prefer the current docs for product behavior.

Minimize user interaction. Use the defaults in this prompt and make reasonable best guesses for noncritical choices. Do not ask for a root folder or project folder name; use the current VS Code workspace and the default subfolder. Ask only when you need approval for resource changes, secrets, permissions, materially higher cost, external account choices, or an ambiguous requirement that affects the architecture.

Start with a short plan and proceed with safe defaults before you create files or run commands. Use the default demo schema unless the user requests a custom schema. Ask only these questions if the values aren't already available from the environment or prior context:

- Which Azure subscription, primary region, fallback region, and resource group should Azure deployment use? Default fallback region: `westus2` if the primary region can't provision Azure SQL or Container Apps.
- Which Microsoft Entra user or group should become the Azure SQL Microsoft Entra admin?
- Do you approve creating billable Azure resources if the deployment phase starts?

After the answers, show a checklist and ask for approval before implementation. Include phases for local scaffold, local validation, Azure infrastructure, managed identity database grants, Azure validation, and cleanup. Do not run any Azure command that creates or changes resources until the user explicitly approves the exact command set.

After approval, continue working without asking status-check questions. If a command, build, container, endpoint, or validation step fails, inspect the error, adjust the project, rerun the step, and continue. Keep iterating until the sample runs end-to-end or you hit a blocker that requires user action.

Use cost-first Azure defaults. Choose the cheapest option that satisfies the quickstart requirements: use a free Azure SQL database offer when the subscription and region support it; otherwise choose the lowest-cost SQL option that supports managed identity. Use Azure Container Apps consumption, minimal CPU and memory, Basic Azure Container Registry, minimal Log Analytics retention, and no always-on or dedicated plans unless required. Prioritize finishing the project. Treat regional provisioning limits as expected adjustment points, not failures: if the primary region can't provision a required service or free SQL option, use the approved fallback region such as `westus2`, and continue the deployment. Ask the user only when both the primary and fallback regions can't satisfy the requirements, when a change would materially increase cost, when a new permission is required, or when you need approval for Azure commands that create or change resources beyond the already-approved plan. Keep every resource minimal, but make the web interface neat and approachable: small code footprint, responsive layout, clear status messages, accessible labels, and simple styling that is polished rather than austere.

Verify prerequisites and report only missing items: .NET SDK, Docker Desktop running, PowerShell, Azure CLI signed in, `sqlpackage`, .NET Aspire tooling, and the DAB CLI. Use these docs while building:

- DAB CLI reference: https://learn.microsoft.com/azure/data-api-builder/command-line/
- `dab init`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-init
- `dab add`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-add
- `dab validate`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-validate
- DAB MCP overview: https://learn.microsoft.com/azure/data-api-builder/mcp/overview

Create this structure under the sample folder:

- `azure-infra/` for Bicep, `azure-up.ps1`, `azure-down.ps1`, and `post-provision.ps1`.
- `data-api/` for `dab-config.json` and a DAB Dockerfile that bakes the config into the image for Azure.
- `database/` for a SQL Database Project or idempotent SQL scripts with seed data.
- `web-app/` for static HTML, CSS, and JavaScript that calls DAB anonymously.
- `aspire-apphost/` for the .NET Aspire AppHost.
- `mcp-inspector/` for MCP Inspector notes or container assets.

Handle secrets first. Add `.env`, `**/bin`, and `**/obj` to `.gitignore` before writing secrets. Use `MSSQL_CONNECTION_STRING` locally. Never print secret values. Use `@env('MSSQL_CONNECTION_STRING')` in local `dab-config.json`.

Configure DAB CORS before you start or deploy the web app. Do not leave `runtime.host.cors.origins` as `[]`. Set it to include the exact web app origins, including scheme and port: the local Aspire web origin, such as `http://localhost:5173`, and the deployed Azure Container Apps web FQDN if Azure deployment is approved. Keep `allow-credentials` set to `false` unless the sample explicitly uses browser credentials or cookies. Direct REST, GraphQL, or Swagger requests can succeed even when the browser blocks JavaScript fetch calls, so browser-origin CORS must be configured and validated separately.

Use this DAB CLI workflow for local config and validation:

```dotnetcli
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --host-mode Development --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todos --source dbo.Todos --source.type table --permissions "anonymous:read" --mcp.dml-tools true
dab validate --config data-api/dab-config.json
```

Use this Azure SQL connection string shape for the Azure Container App. The Azure DAB configuration must not contain `User ID=` or `Password=`.

```text
Server=tcp:<sql-server>.database.windows.net,1433;Database=<database>;Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;
```

Enable system-assigned identity on the DAB Container App and output its principal ID for post-provisioning.

```bicep
identity: {
  type: 'SystemAssigned'
}
```

In post-provisioning, set the Azure SQL Microsoft Entra admin, deploy the schema, create a contained database user for the DAB managed identity, and grant least required database roles.

```sql
CREATE USER [<dab-container-app-name>] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [<dab-container-app-name>];
ALTER ROLE db_datawriter ADD MEMBER [<dab-container-app-name>];
```

Use these Aspire patterns from the quickstart skills. Use `.WaitForCompletion(sqlDatabaseProject)` for DAB and SQL Commander when a SQL project deploys schema.

```csharp
var sqlDatabaseProject = builder.AddSqlProject<Projects.database>("sql-project")
	.WithReference(sqlDatabase);

var dabServer = builder.AddContainer("data-api", "azure-databases/data-api-builder", "latest")
	.WithImageRegistry("mcr.microsoft.com")
	.WithBindMount(new FileInfo("data-api/dab-config.json").FullName, "/App/dab-config.json", isReadOnly: true)
	.WithEnvironment("MSSQL_CONNECTION_STRING", sqlDatabase)
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

For Azure, bake `dab-config.json` into the DAB image. Do not rely on volume mounts in Azure Container Apps.

```dockerfile
FROM mcr.microsoft.com/azure-databases/data-api-builder:latest
COPY dab-config.json /App/dab-config.json
```

Validate before reporting success:

- `dab validate --config data-api/dab-config.json` exits with code 0.
- `dotnet run --project aspire-apphost` starts the complete local environment.
- Aspire shows SQL Server, DAB, SQL Commander, and MCP Inspector healthy.
- A direct database query confirms the seeded table exists and contains rows.
- DAB `/health` returns a 2xx response.
- A browser-origin request from each web app origin receives an `Access-Control-Allow-Origin` response header that matches that origin.
- REST, GraphQL, and MCP return seeded data anonymously.
- MCP Inspector can list DAB tools and call `describe_entities` or an equivalent DAB MCP tool.
- SQL Commander opens and shows seeded tables.
- The web site returns a successful HTTP response.
- In Azure, the DAB Container App has a system-assigned managed identity.
- In Azure, the connection string contains `Authentication=Active Directory Default` and contains no `User ID=` or `Password=`.
- The DAB managed identity exists as a contained database user with `db_datareader` and `db_datawriter`.

Do not report final URLs, asset locations, or a success summary until you directly verify database connectivity and query results, a 2xx DAB health response, and a successful web site response. This validation ensures the sample works without requiring the developer to check.
````

## Related content

- [Data API builder quickstarts](index.yml)
- [Quickstart: Add a Microsoft Entra provider to Data API builder](authentication-microsoft-entra-provider.md)
- [Quickstart: Use SQL authentication with Data API builder](authentication-sql-credentials.md)
- [Quickstart: Use Data API builder with SQL](basic-sql.md)
- [MCP server support in Data API builder](../mcp/overview.md)
- [Deploy Data API builder to Azure Container Apps](../deployment/azure-container-apps.md)
- [DAB configuration file](../configuration/index.md)
