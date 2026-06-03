---
title: 'Quickstart: Use SQL authentication with Data API builder'
description: Run a SQL-backed sample with anonymous web and API access. Use SQL authentication, REST, GraphQL, MCP, Aspire, and Azure deployment.
author: jerrynixon
ms.author: jnixon
ms.reviewer: sidandrews
ms.service: data-api-builder
ms.topic: quickstart
ms.date: 06/02/2026
# Customer Intent: As a developer, I want to run a DAB sample that uses SQL authentication so that I can understand the simplest SQL-backed authentication flow before production hardening.
---

# Quickstart: Use SQL authentication with Data API builder

In this quickstart, you use the [Quickstart 1 SQL Authentication sample](https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_anon-db_sql_auth) to run Data API builder (DAB) over SQL. Users access the web app anonymously. The web app accesses DAB anonymously. DAB uses SQL authentication to connect to SQL Server or Azure SQL.

The sample exposes SQL data through REST, GraphQL, and MCP. It also includes .NET Aspire local orchestration and Azure deployment scripts.

> [!IMPORTANT]
> SQL authentication keeps the setup simple, but it uses stored credentials. Avoid embedded secrets in production. Store local secrets in `.env`, store cloud secrets in a managed secret store, and consider managed identity for production workloads.

## Prerequisites

- [.NET 8 or later](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [PowerShell](/powershell/scripting/install/installing-powershell)
- [.NET Aspire tooling](/dotnet/aspire/fundamentals/setup-tooling) for local orchestration
- [Azure CLI](/cli/azure/install-azure-cli) for Azure deployment
- [sqlpackage](/sql/tools/sqlpackage/sqlpackage-download) if you deploy the database project

## What the sample shows

- A static web app that calls DAB without user sign-in.
- DAB configured as the only API, GraphQL, and MCP layer over SQL.
- REST, GraphQL, and MCP endpoints exposed from the same DAB configuration.
- SQL authentication from DAB to SQL Server locally and Azure SQL in Azure.
- .NET Aspire orchestration for local SQL Server, DAB, the web app, SQL Commander, and MCP Inspector.
- Azure deployment through PowerShell scripts in `azure-infra`.

## Authentication flow

| Hop | Authentication |
| --- | --- |
| User to web app | Anonymous |
| Web app to API | Anonymous |
| API to SQL local | SQL authentication |
| API to Azure SQL | SQL authentication |

## Compare with the series

| Step | What changes |
| --- | --- |
| Previous | [Use Data API builder with SQL](basic-sql.md) creates local REST and GraphQL endpoints with the DAB CLI. |
| This quickstart | Uses a full sample app and SQL credentials for DAB-to-SQL access. |
| Next | [Use managed identity](authentication-managed-identity.md) removes the Azure SQL password by using DAB's Azure identity. |

## Use the sample

Clone the sample repository.

```bash
git clone https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_anon-db_sql_auth.git
cd dab-2.0-quickstart-web_anon-api_anon-db_sql_auth
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

The deployment script provisions Azure SQL and Azure Container Apps resources for DAB, the web app, MCP Inspector, and SQL Commander.

Clean up Azure resources when you're done.

```powershell
pwsh ./azure-infra/azure-down.ps1
```

## Key files

| Path | Purpose |
| --- | --- |
| `azure-infra` | Bicep files and PowerShell scripts for Azure deployment and cleanup. |
| `data-api/dab-config.json` | DAB runtime configuration for SQL, REST, GraphQL, MCP, and anonymous entity access. |
| `database` | SQL database project, schema files, and seed data scripts. |
| `web-app` | Static web app that calls DAB anonymously. |
| `aspire-apphost` | .NET Aspire AppHost that orchestrates local containers and project resources. |
| `mcp-inspector` | MCP Inspector container configuration for testing DAB MCP tools. |

## Use GitHub Copilot to recreate this sample

Open the workspace where you want to create the sample in Visual Studio Code, switch GitHub Copilot to agent mode, and paste this prompt.

````copilot-prompt
You are GitHub Copilot running in agent mode. Recreate the Data API builder Quickstart 1 SQL Authentication sample as a complete, runnable project in the current VS Code workspace under `quickstart-01-sql-authentication`. Build a static web app, Data API builder (DAB), SQL Server locally, Azure SQL in Azure, REST, GraphQL, MCP, .NET Aspire local orchestration, SQL Commander, MCP Inspector, and Azure Container Apps deployment scripts. DAB is the only API, GraphQL, and MCP layer over SQL.

Source repository: https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_anon-db_sql_auth. If internet access is available, inspect or clone this repository before you create files. Reuse and adapt its files as closely as possible, especially `web-app/`, `data-api/`, `database/`, `aspire-apphost/`, `mcp-inspector/`, `azure-infra/`, scripts, and README patterns. The goal is to implement the published quickstart, not to invent a different sample. If the repository differs from this prompt or the current Data API builder docs, prefer the current docs for product behavior.

Minimize user interaction. Use the defaults in this prompt and make reasonable best guesses for noncritical choices. Do not ask for a root folder or project folder name; use the current VS Code workspace and the default subfolder. Ask only when you need approval for resource changes, secrets, permissions, materially higher cost, external account choices, or an ambiguous requirement that affects the architecture.

Start with a short plan and proceed with safe defaults before you create files or run commands. Ask only these questions if the values aren't already available from the environment or prior context:

- Which Azure subscription, primary region, fallback region, and resource group should Azure deployment use? Default fallback region: `westus2` if the primary region can't provision Azure SQL or Container Apps.
- Do you approve creating billable Azure resources if the deployment phase starts?

Use the default demo SQL Database Project unless the user asks for a simple SQL script. Generate a strong SQL password and store it only in local `.env` files or approved cloud secret stores. Use a conventional SQL admin user name such as `sqladmin` unless the target environment requires a different name.

After the answers, show a short checklist and ask for approval before implementation. Include phases for local scaffold, local validation, Azure infrastructure, Azure deployment, validation, and cleanup. Do not run any Azure command that creates or changes resources until the user explicitly approves the exact command set.

After approval, continue working without asking status-check questions. If a command, build, container, endpoint, or validation step fails, inspect the error, adjust the project, rerun the step, and continue. Keep iterating until the sample runs end-to-end or you hit a blocker that requires user action.

Use cost-first Azure defaults. Choose the cheapest option that satisfies the quickstart requirements: use a free Azure SQL database offer when the subscription and region support it; otherwise choose the lowest-cost SQL option that supports the scenario. Use Azure Container Apps consumption, minimal CPU and memory, Basic Azure Container Registry, minimal Log Analytics retention, and no always-on or dedicated plans unless required. Prioritize finishing the project. Treat regional provisioning limits as expected adjustment points, not failures: if the primary region can't provision a required service or free SQL option, use the approved fallback region such as `westus2`, and continue the deployment. Ask the user only when both the primary and fallback regions can't satisfy the requirements, when a change would materially increase cost, when a new permission is required, or when you need approval for Azure commands that create or change resources beyond the already-approved plan. Keep every resource minimal, but make the web interface neat and approachable: small code footprint, responsive layout, clear status messages, accessible labels, and simple styling that is polished rather than austere.

Verify prerequisites and report only missing items: .NET SDK, Docker Desktop running, PowerShell, Azure CLI, `sqlpackage`, .NET Aspire tooling, and the DAB CLI. If the DAB CLI is missing, install or restore it only after the user approves. Use the DAB CLI docs while building: https://learn.microsoft.com/azure/data-api-builder/command-line/.

Use these docs during implementation:

- DAB CLI reference: https://learn.microsoft.com/azure/data-api-builder/command-line/
- `dab init`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-init
- `dab add`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-add
- `dab validate`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-validate
- `dab start`: https://learn.microsoft.com/azure/data-api-builder/command-line/dab-start
- DAB MCP overview: https://learn.microsoft.com/azure/data-api-builder/mcp/overview

Create this structure under the sample folder:

- `azure-infra/` for Bicep, `azure-up.ps1`, `azure-down.ps1`, and post-provision scripts.
- `data-api/` for `dab-config.json` and a DAB Dockerfile that bakes the config into the image for Azure.
- `database/` for a SQL Database Project or idempotent SQL scripts with seed data.
- `web-app/` for static HTML, CSS, and JavaScript that calls DAB anonymously.
- `aspire-apphost/` for the .NET Aspire AppHost.
- `mcp-inspector/` for MCP Inspector notes or container assets.

Handle secrets first. Add `.env`, `**/bin`, and `**/obj` to `.gitignore` before writing secrets. Use `SQL_PASSWORD` for the SQL password and `MSSQL_CONNECTION_STRING` for the DAB connection string. Never print secret values. Use `@env('MSSQL_CONNECTION_STRING')` in `dab-config.json`.

Configure DAB CORS before you start or deploy the web app. Do not leave `runtime.host.cors.origins` as `[]`. Set it to include the exact web app origins, including scheme and port: the local Aspire web origin, such as `http://localhost:5173`, and the deployed Azure Container Apps web FQDN if Azure deployment is approved. Keep `allow-credentials` set to `false` unless the sample explicitly uses browser credentials or cookies. Direct REST, GraphQL, or Swagger requests can succeed even when the browser blocks JavaScript fetch calls, so browser-origin CORS must be configured and validated separately.

Use this DAB CLI workflow and validate after each config change:

```dotnetcli
dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --host-mode Development --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todos --source dbo.Todos --source.type table --permissions "anonymous:read" --mcp.dml-tools true
dab validate --config data-api/dab-config.json
dab start --config data-api/dab-config.json
```

Use this minimal DAB runtime shape if you write the config directly:

```json
{
	"$schema": "https://dataapibuilder.azureedge.net/schemas/latest/dab.draft.schema.json",
	"data-source": {
		"database-type": "mssql",
		"connection-string": "@env('MSSQL_CONNECTION_STRING')"
	},
	"runtime": {
		"rest": { "enabled": true, "path": "/api" },
		"graphql": { "enabled": true, "path": "/graphql" },
		"mcp": { "enabled": true, "path": "/mcp" },
		"host": { "mode": "development", "cors": { "origins": ["http://localhost:5173"], "allow-credentials": false } }
	},
	"entities": {}
}
```

Use these Aspire patterns from the quickstart skills:

```csharp
var sqlServer = builder.AddSqlServer("sql-server")
		.WithEnvironment("ACCEPT_EULA", "Y")
		.WithDataVolume("sql-data");
var sqlDatabase = sqlServer.AddDatabase("TodoDb");

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

Use `.WaitForCompletion(sqlDatabaseProject)` for DAB and SQL Commander when a SQL project deploys schema. Do not use only `.WaitFor(sqlDatabaseProject)` for a run-to-completion SQL project.

Add SQL Commander exactly enough to work. Use image `jerrynixon/sql-commander:latest`, env var `ConnectionStrings__db`, and ensure the connection string includes `TrustServerCertificate=true`.

```csharp
var sqlCommander = builder.AddContainer("sql-cmdr", "jerrynixon/sql-commander", "latest")
		.WithImageRegistry("docker.io")
		.WithHttpEndpoint(targetPort: 8080, name: "http")
		.WithEnvironment("ConnectionStrings__db", sqlDatabase)
		.WithHttpHealthCheck("/health")
		.WaitForCompletion(sqlDatabaseProject);
```

Add MCP Inspector exactly enough to work with DAB MCP over HTTP. Use Streamable HTTP transport and omit auth only for local development.

```csharp
var mcpInspector = builder.AddMcpInspector("mcp-inspector")
		.WithMcpServer(dabServer, transportType: McpTransportType.StreamableHttp)
		.WithEnvironment("DANGEROUSLY_OMIT_AUTH", "true")
		.WaitFor(dabServer);
```

Also create a VS Code MCP example for local testing:

```json
{
	"servers": {
		"local-dab": { "type": "http", "url": "http://localhost:5000/mcp" }
	}
}
```

For Azure, bake `dab-config.json` into the DAB image. Do not rely on volume mounts in Azure Container Apps.

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
- REST returns seeded rows anonymously.
- GraphQL returns seeded rows anonymously.
- MCP Inspector can list DAB tools and call `describe_entities` or an equivalent DAB MCP tool.
- SQL Commander opens from the Aspire dashboard and shows the seeded table.
- The web site returns a successful HTTP response.
- The web app displays data anonymously.
- Azure Container Apps are healthy if deployment is approved.

Do not report final URLs, asset locations, or a success summary until you directly verify database connectivity and query results, a 2xx DAB health response, and a successful web site response. This validation ensures the sample works without requiring the developer to check.
````

## Related content

- [Data API builder quickstarts](index.yml)
- [Quickstart: Use managed identity with Data API builder](authentication-managed-identity.md)
- [Quickstart: Use Data API builder with SQL](basic-sql.md)
- [MCP server support in Data API builder](../mcp/overview.md)
- [Deploy Data API builder to Azure Container Apps](../deployment/azure-container-apps.md)
- [DAB configuration file](../configuration/index.md)