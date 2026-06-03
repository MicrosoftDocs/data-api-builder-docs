---
name: dab-docs-copilot-prompt
description: 'Author, revise, audit, or review Copilot prompt sections in Data API builder documentation. Use when adding "Use GitHub Copilot" prompts, DAB CLI, .NET Aspire, Docker Compose, MCP Inspector, SQL Commander, secrets, finish-first behavior, cost-first Azure defaults, validation, and Microsoft Learn style.'
argument-hint: 'Provide: target doc path, sample or scenario name, expected generated project, local/Azure scope, database/auth mode, and any required tools such as Aspire, MCP Inspector, or SQL Commander.'
user-invocable: true
---

# DAB Docs Copilot Prompt

Use this skill whenever you add, revise, or audit a `copilot-prompt` section in Data API builder (DAB) documentation. The goal is to produce prompts that let GitHub Copilot in agent mode build complete, runnable samples with minimal user interruption, consistent structure across pages, and enough detail to avoid common implementation failures. Prompts should default to the current VS Code workspace, ask as few questions as possible, and keep the implementing agent working until the sample runs end-to-end.

## When to use

Use this skill for requests such as:

- Add a **Use GitHub Copilot to recreate this sample** section to a DAB quickstart.
- Rewrite an existing `copilot-prompt` block so it can build a complete project.
- Make prompt sections consistent across related DAB quickstarts.
- Add prompt guidance for DAB CLI, DAB MCP, MCP Inspector, SQL Commander, .NET Aspire, Docker Compose, Azure Container Apps, or Azure-Samples source repository reuse.
- Audit prompts for finish-first behavior, cost-first Azure choices, validation coverage, and Microsoft Learn style.

Do not use this skill for normal article prose unless the request includes a Copilot prompt or prompt-like instructions.

## Required inputs

Before editing a docs `.md` page, confirm the author identity with a low-friction choice instead of forcing the user to retype values.

For an existing page:

- Read the page frontmatter first.
- Treat the existing `author` and `ms.author` values as the default author identity for the edit.
- Ask the user to confirm by offering choices such as:
  - Keep existing: `<author>` / `<ms.author>`
  - Use a different GitHub username and Microsoft alias
- If the user keeps the existing identity, update only `ms.date` unless other frontmatter must change.
- If either value is missing, offer values found in peer files as selectable suggestions and allow a custom entry.
- Never guess or silently replace `author` or `ms.author`.

For a new page:

- Inspect peer files in the target folder and offer their `author` / `ms.author` pairs as selectable defaults.
- Allow the user to enter a different GitHub username and Microsoft alias.
- Do not create the page until the author identity is confirmed.

Update the target page's `author`, `ms.author`, and `ms.date` frontmatter whenever you edit the prompt section.

Before drafting, identify these inputs from the user request, the active file, peer docs, or the sample repository:

- Target documentation file.
- Prompt heading text.
- Generated sample name and default subfolder name.
- Source repository URL when the quickstart is backed by an Azure-Samples repository.
- Current VS Code workspace root. Use it as the generated project root unless the user explicitly asks to write somewhere else.
- Scenario type: local-only, Azure deployment, or local plus Azure.
- Database type or decision point: SQL Server, PostgreSQL, MySQL, Azure SQL, Cosmos DB, or user-selected.
- Authentication and authorization model.
- Required tools: DAB CLI, Docker Compose, .NET Aspire, MCP Inspector, SQL Commander, Azure CLI, `sqlpackage`, MSAL, or Microsoft Entra app registrations.
- Required validation evidence.
- Related docs links that should appear in the prompt.

If a required implementation variable is missing, make the prompt ask the downstream user for it. Do not leave vague placeholders for decisions that the implementing agent must make.

## Article integration pattern

Add prompt sections near the end of the article, after the main sample/use instructions and before **Related content** or **Next step**.

Use this structure:

`````markdown
## Use GitHub Copilot to recreate this sample

Open an empty folder in Visual Studio Code, switch GitHub Copilot to agent mode, and paste this prompt.

````copilot-prompt
...
````
`````

For a general quickstart that is not tied to a named sample, use:

```markdown
## Use GitHub Copilot to recreate this quickstart
```

Use a four-backtick outer fence with the `copilot-prompt` language tag so the prompt can contain nested triple-backtick code fences safely.

## Prompt structure

A strong DAB docs prompt uses this sequence.

### 1. Mission statement

Start with a direct agent-mode instruction that names the scenario, generated project, current workspace target, default subfolder, and major components.

Include these details when relevant:

- GitHub Copilot is running in agent mode.
- The generated project should be complete and runnable under the current VS Code workspace.
- DAB is the only API, GraphQL, and MCP layer over the database.
- The project includes REST, GraphQL, MCP, a small web app, validation, and cleanup.
- The implementation should be minimal but polished.

Example:

```text
You are GitHub Copilot running in agent mode. Recreate the Data API builder <scenario> sample as a complete, runnable project in the current VS Code workspace under `<sample-folder>`. Build <components>. DAB is the only API, GraphQL, and MCP layer over SQL.
```

### 2. Source repository reuse

When the quickstart has an Azure-Samples repository, include the source repository URL immediately after the mission statement. Tell the implementing agent to inspect or clone the repository before creating files when internet access is available. The prompt must say to reuse and adapt repository files as closely as possible, especially `web-app/`, `data-api/`, `database/`, `aspire-apphost/`, `mcp-inspector/`, `azure-infra/`, scripts, and README patterns. The goal is to implement the published quickstart, not to invent a different sample.

Use this wording as a baseline:

```text
Source repository: <repo-url>. If internet access is available, inspect or clone this repository before you create files. Reuse and adapt its files as closely as possible, especially `web-app/`, `data-api/`, `database/`, `aspire-apphost/`, `mcp-inspector/`, `azure-infra/`, scripts, and README patterns. The goal is to implement the published quickstart, not to invent a different sample. If the repository differs from this prompt or the current Data API builder docs, prefer the current docs for product behavior.
```

Known DAB 2.0 quickstart source repositories:

- Quickstart 1 SQL authentication: `https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_anon-db_sql_auth`
- Quickstart 2 managed identity: `https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_anon-db_entra`
- Quickstart 3 Microsoft Entra provider: `https://github.com/Azure-Samples/dab-2.0-quickstart-web_anon-api_entra-db_entra`
- Quickstart 4 DAB database policies: `https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-api_rls`
- Quickstart 5 SQL row-level security: `https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-db_rls`
- Quickstart 6 On-Behalf-Of flow: `https://github.com/Azure-Samples/dab-2.0-quickstart-web_entra-api_entra-db_entra-obo`

If no dedicated source repository exists, say so plainly. Link to the Azure-Samples DAB 2.0 repository list at `https://github.com/orgs/Azure-Samples/repositories?q=dab-2.0`, tell the implementing agent to reuse only matching shared patterns from the closest published sample, and tell it to otherwise implement from the article and current docs. Do not invent a source repository.

### 3. Question-driven plan

Make the prompt ask only for values that the implementing agent can't safely infer before it creates files or runs commands. Use bullets because the questions are nonsequential. Do not ask for a root folder or project folder name; use the current VS Code workspace and the prompt's default subfolder unless the user explicitly asks to write somewhere else.

Common questions:

- Which database engine should Docker run: SQL Server, PostgreSQL, or MySQL?
- Which Azure subscription, primary region, fallback region, and resource group should Azure deployment use? Default fallback region: `westus2`.
- Which Microsoft Entra tenant, app registration name, redirect URI, scope, user, or group should I use?
- Should the sample use the default demo schema or a custom schema?
- Do you approve creating billable Azure resources if deployment starts?
- Do you approve creating app registrations, client secrets, or new permissions if the scenario requires them?

Ask only for values that are needed for the scenario and that can't be reasonably defaulted. Do not ask questions that the prompt can reasonably default, including schema choice, host ports, generated password choice, local-only workflow, database browser inclusion, API scope shape, claim mapping, or folder names. Tell the implementing agent to use best-guess defaults and proceed when doing so is safe.

### 4. Approval gate

After the answers, require the implementing agent to show a checklist and ask for approval before implementation.

Include phases such as:

- Local scaffold
- Local validation
- Azure infrastructure
- Azure deployment
- Identity or database grants
- End-to-end validation
- Cleanup

For Azure work, preserve approval boundaries:

```text
Do not run any Azure command that creates or changes resources until the user explicitly approves the exact command set.
```

For local-only work, don't require a second approval after presenting the checklist. Tell the implementing agent to proceed with local files and local Docker or Aspire validation unless a true blocker appears.

### 5. Finish-first behavior

Prompts must tell the implementing agent to finish. Avoid wording that tells the agent to stop for minor, recoverable conditions.

Use this guidance for all prompts:

```text
After approval, continue working without asking status-check questions. If a command, build, container, endpoint, or validation step fails, inspect the error, adjust the project, rerun the step, and continue. Keep iterating until the sample runs end-to-end or you hit a blocker that requires user action.
```

Use this guidance for Azure regional or service availability issues:

```text
Prioritize finishing the project. Treat regional provisioning limits as expected adjustment points, not failures: if the primary region can't provision a required service or free SQL option, use the approved fallback region such as `westus2`, and continue the deployment. Ask the user only when both the primary and fallback regions can't satisfy the requirements, when a change would materially increase cost, when a new permission is required, or when you need approval for Azure commands that create or change resources beyond the already-approved plan.
```

Do not tell the downstream agent to halt for fallback-region issues that it can resolve with an approved fallback region.

For configuration inconsistencies, prefer align-and-continue language:

```text
If any artifact uses a different key, align the artifacts to the approved mapping and continue. Ask the user only if the intended mapping is ambiguous.
```

Do not report final URLs, asset locations, or success until validation proves the sample works. The implementing agent must directly verify database connectivity and query results, a 2xx DAB health response, and a successful web site response before it gives the developer final URLs or locations.

### 6. Cost-first defaults

Every Azure-capable prompt should prefer the cheapest viable option.

Include scenario-specific wording:

- Use a free Azure SQL database offer when the subscription, region, and scenario support it.
- Otherwise choose the lowest-cost SQL option that supports the required feature.
- Use Azure Container Apps consumption.
- Use minimal CPU and memory.
- Use Basic Azure Container Registry.
- Use minimal Log Analytics retention.
- Avoid always-on or dedicated plans unless required.

For local-only prompts, state that local Docker is the default and has no Azure cost. If the user asks for an Azure extension, apply the Azure cost-first guidance.

### 7. Prerequisites

Tell the implementing agent to verify prerequisites and report only missing items.

Common prerequisites:

- .NET SDK
- Docker Desktop running
- PowerShell
- Azure CLI signed in
- `sqlpackage`
- .NET Aspire tooling
- DAB CLI
- Node.js, if the web app tooling requires it

If a tool is missing, the prompt should tell the implementing agent to install or restore it only after user approval when installation changes the environment.

### 8. Documentation links

Inside `copilot-prompt` blocks, include full Microsoft Learn URLs. A developer copies the prompt out of the Learn page, so site-relative links such as `/azure/data-api-builder/command-line/` don't provide enough context. In article prose outside the prompt block, continue to follow the repo convention and use site-relative Learn links.

Common prompt-safe DAB links:

- DAB CLI reference: `https://learn.microsoft.com/azure/data-api-builder/command-line/`
- `dab init`: `https://learn.microsoft.com/azure/data-api-builder/command-line/dab-init`
- `dab add`: `https://learn.microsoft.com/azure/data-api-builder/command-line/dab-add`
- `dab update`: `https://learn.microsoft.com/azure/data-api-builder/command-line/dab-update`
- `dab configure`: `https://learn.microsoft.com/azure/data-api-builder/command-line/dab-configure`
- `dab validate`: `https://learn.microsoft.com/azure/data-api-builder/command-line/dab-validate`
- `dab start`: `https://learn.microsoft.com/azure/data-api-builder/command-line/dab-start`
- DAB MCP overview: `https://learn.microsoft.com/azure/data-api-builder/mcp/overview`
- DAB configuration: `https://learn.microsoft.com/azure/data-api-builder/configuration/`
- Deploy to Azure Container Apps: `https://learn.microsoft.com/azure/data-api-builder/deployment/azure-container-apps`

### 9. Generated project structure

Require a predictable folder layout so samples look consistent.

For local plus Azure SQL quickstarts, create this structure under the current VS Code workspace in the default sample subfolder:

```text
- `azure-infra/` for Bicep, deployment scripts, cleanup scripts, and post-provision scripts.
- `data-api/` for `dab-config.json` and a DAB Dockerfile that bakes the config into the image for Azure.
- `database/` for a SQL Database Project or idempotent SQL scripts with seed data.
- `web-app/` for static HTML, CSS, and JavaScript.
- `aspire-apphost/` for the .NET Aspire AppHost.
- `mcp-inspector/` for MCP Inspector notes or container assets.
```

For Docker-only quickstarts, create this structure under the current VS Code workspace in the default sample subfolder:

```text
- `docker-compose.yml` for the selected database, DAB, MCP Inspector, and the web app.
- `.env` for local passwords and connection strings.
- `.gitignore` with `.env`, `**/bin`, and `**/obj`.
- `database/` for selected-engine initialization scripts.
- `data-api/dab-config.json` for DAB configuration.
- `web-app/` for static HTML, CSS, and JavaScript.
- `mcp-inspector/README.md` with the auto-connect URL.
- `README.md` with run, validation, troubleshooting, and cleanup steps.
```

### 10. Secrets-first handling

Include secret hygiene early in the prompt:

```text
Handle secrets first. Add `.env`, `**/bin`, and `**/obj` to `.gitignore` before writing secrets. Never print secret values. Use `@env('<CONNECTION_STRING_VAR>')` in `dab-config.json`.
```

For Docker Compose passwords, add:

```text
Avoid `$` in Docker Compose passwords because Compose treats `$` as variable interpolation.
```

For Azure, add:

- Use Azure Container Apps secrets or Key Vault references for secrets.
- Do not inline secret values in scripts, config, or logs.
- Use managed identity or delegated auth when the scenario requires passwordless access.

### 11. DAB CLI workflow

Include exact DAB CLI commands for the scenario and validate after each meaningful config change.

SQL Server example:

```dotnetcli
dab init --config data-api/dab-config.json --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --host-mode Development --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todos --config data-api/dab-config.json --source dbo.Todos --source.type table --permissions "anonymous:read" --mcp.dml-tools true
dab validate --config data-api/dab-config.json
```

When the article uses PostgreSQL or MySQL, provide the matching `--database-type` and `--source` values:

```dotnetcli
dab init --config data-api/dab-config.json --database-type postgresql --connection-string "@env('DATABASE_CONNECTION_STRING')" --host-mode Development --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todo --config data-api/dab-config.json --source public.todos --source.type table --permissions "anonymous:*" --mcp.dml-tools true
```

```dotnetcli
dab init --config data-api/dab-config.json --database-type mysql --connection-string "@env('DATABASE_CONNECTION_STRING')" --host-mode Development --rest.enabled true --graphql.enabled true --mcp.enabled true
dab add Todo --config data-api/dab-config.json --source todos --source.type table --permissions "anonymous:*" --mcp.dml-tools true
```

### 12. Minimal DAB config shape

When useful, include a minimal JSON shape so the implementing agent can write the config directly if CLI setup needs adjustment.

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

Prompts that generate a browser-based web app must explicitly configure DAB CORS. Do not let `dab init` leave `runtime.host.cors.origins` as `[]`. Include the exact web app origins, including scheme and port, for every environment the prompt creates:

- Docker Compose local web app, for example `http://localhost:8000`.
- Aspire local web app, for example `http://localhost:5173`.
- Azure Container Apps or other deployed web FQDNs, for example `https://<web-app-fqdn>`.

Use exact origins instead of relying on direct REST, GraphQL, or Swagger tests. Those direct requests can succeed while the browser blocks JavaScript fetch calls because DAB didn't return a matching `Access-Control-Allow-Origin` header. Keep `allow-credentials` set to `false` unless the sample intentionally uses browser credentials or cookies. For MSAL bearer-token SPAs, `allow-credentials` should usually remain `false` because the web app sends `Authorization: Bearer <token>` headers.

### 13. Local orchestration patterns

Choose the orchestration pattern that matches the sample.

#### .NET Aspire

Use Aspire for quickstarts that already use AppHost orchestration.

Key rules:

- Use `.WaitForCompletion(sqlDatabaseProject)` when a SQL Database Project deploys schema.
- Do not use only `.WaitFor(sqlDatabaseProject)` for run-to-completion SQL project deployment.
- Add health checks for DAB, SQL Commander, and the web app when available.
- Keep DAB config mounted read-only for local development.

DAB container pattern:

```csharp
var dabServer = builder.AddContainer("data-api", "azure-databases/data-api-builder", "latest")
    .WithImageRegistry("mcr.microsoft.com")
    .WithBindMount(new FileInfo("data-api/dab-config.json").FullName, "/App/dab-config.json", isReadOnly: true)
    .WithEnvironment("MSSQL_CONNECTION_STRING", sqlDatabase)
    .WithHttpEndpoint(targetPort: 5000, name: "http")
    .WithHttpHealthCheck("/health")
    .WaitForCompletion(sqlDatabaseProject);
```

#### Docker Compose

Use Docker Compose for local-only or multi-engine quickstarts.

Key rules:

- Use `docker-compose.yml`, not raw `docker run`, in generated projects.
- Containers talk by service name, not `localhost`.
- Use non-default host ports to avoid local conflicts.
- Mount `dab-config.json` read-only into `/App/dab-config.json`.
- Use health checks and `depends_on` so DAB starts after the database is healthy.
- Implement database initialization explicitly.

Database initialization rules:

- PostgreSQL and MySQL can mount scripts into `/docker-entrypoint-initdb.d`.
- SQL Server needs a one-shot init service or setup script that waits for the database service to become healthy and then runs `sqlcmd`.
- Do not assume a database health check creates the database or schema.

### 14. SQL Commander

Include SQL Commander for SQL Server quickstarts unless the scenario intentionally excludes it.

Required details:

- Docker image: `jerrynixon/sql-commander:latest`
- Environment variable: `ConnectionStrings__db`
- Connection string must include `TrustServerCertificate=true`.
- Wait for schema deployment before starting or validating SQL Commander.

Aspire pattern:

```csharp
var sqlCommander = builder.AddContainer("sql-cmdr", "jerrynixon/sql-commander", "latest")
    .WithImageRegistry("docker.io")
    .WithHttpEndpoint(targetPort: 8080, name: "http")
    .WithEnvironment("ConnectionStrings__db", sqlDatabase)
    .WithHttpHealthCheck("/health")
    .WaitForCompletion(sqlDatabaseProject);
```

Docker Compose pattern:

```yaml
sql-commander:
  image: jerrynixon/sql-commander:latest
  environment:
    ConnectionStrings__db: ${DATABASE_CONNECTION_STRING}
  ports:
    - "8080:8080"
  depends_on:
    db:
      condition: service_healthy
```

### 15. MCP Inspector

Include MCP Inspector whenever the prompt enables DAB MCP.

Required details:

- Use Streamable HTTP transport for DAB MCP over HTTP.
- Omit auth only for local development with `DANGEROUSLY_OMIT_AUTH=true`.
- Validate that MCP Inspector can list DAB tools and call `describe_entities` or an equivalent DAB MCP tool.

Aspire pattern:

```csharp
var mcpInspector = builder.AddMcpInspector("mcp-inspector")
    .WithMcpServer(dabServer, transportType: McpTransportType.StreamableHttp)
    .WithEnvironment("DANGEROUSLY_OMIT_AUTH", "true")
    .WaitFor(dabServer);
```

Docker Compose pattern:

```yaml
mcp-inspector:
  image: ghcr.io/modelcontextprotocol/inspector:latest
  environment:
    HOST: 0.0.0.0
    MCP_AUTO_OPEN_ENABLED: "false"
    DANGEROUSLY_OMIT_AUTH: "true"
  ports:
    - "6274:6274"
    - "6277:6277"
  depends_on:
    - data-api
```

For Compose, include the auto-connect URL and host-side URL:

```text
http://localhost:6274/?transport=streamable-http&serverUrl=http%3A%2F%2Fdata-api%3A5000%2Fmcp
```

```text
http://localhost:5000/mcp
```

Explain that the auto-connect URL uses the Compose service name because MCP Inspector runs in the Compose network.

### 16. Azure deployment guidance

For Azure-capable prompts:

- Bake `dab-config.json` into the DAB image. Do not rely on volume mounts in Azure Container Apps.
- Use Azure Container Apps consumption by default.
- Use managed identity, Microsoft Entra, or OBO configuration appropriate to the quickstart.
- Keep Azure SQL connection strings aligned with the auth model.
- Use post-provision scripts for database users, grants, and app registration wiring that cannot happen in Bicep alone.
- Never create or rotate secrets without approval.

DAB Dockerfile pattern:

```dockerfile
FROM mcr.microsoft.com/azure-databases/data-api-builder:latest
COPY dab-config.json /App/dab-config.json
```

Managed identity Azure SQL connection string shape:

```text
Server=tcp:<sql-server>.database.windows.net,1433;Database=<database>;Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;
```

OBO/user-delegated Azure SQL connection strings must be bare SQL endpoints without `User ID`, `Password`, or `Authentication` unless the scenario explicitly requires otherwise.

### 17. Web app expectations

The generated web app should be small, dependency-light, and polished.

Include these requirements:

- Use plain HTML, CSS, and JavaScript unless the scenario requires a framework.
- Show loading, empty, and error states.
- Include accessible labels and keyboard-friendly controls.
- Show the API base URL and useful quick links.
- Ensure DAB CORS includes the exact web app origin before the app calls DAB from browser JavaScript.
- Keep code minimal, responsive, and visually neat rather than austere.
- Do not add custom API code; the web app calls DAB directly unless the quickstart explicitly requires a proxy.

### 18. Validation

Every prompt must end with a validation checklist.

Common validation items:

- `dab validate --config data-api/dab-config.json` exits with code 0.
- Direct database connectivity and query validation succeeds.
- DAB `/health` returns a 2xx response.
- The web site returns a successful HTTP response.
- A browser-origin request from each web app origin receives an `Access-Control-Allow-Origin` response header that matches that origin.
- REST returns seeded rows.
- GraphQL returns seeded rows.
- Swagger opens when enabled.
- MCP Inspector can list DAB tools and call a DAB MCP tool.
- SQL Commander opens and shows seeded tables when included.
- The web app displays expected data and states.
- Azure Container Apps are healthy when deployment is approved.
- Identity, app registration, policy, RLS, or OBO behavior is verified for the scenario.

Every prompt must include a no-premature-handoff rule: don't report final URLs, asset locations, or a success summary until the direct database test, DAB 2xx health check, and web site success check all pass.

Prefer “adjustments and fixes” instead of “failures and fixes” so the prompt reinforces finish-first behavior.

## Scenario-specific guidance

### Basic SQL quickstart

Special requirements:

- Ask which database engine Docker should run: SQL Server, PostgreSQL, or MySQL.
- Generate only the selected engine unless the user asks for a matrix sample.
- Default to local Docker only and no Azure cost.
- Include selected-engine schema, seed data, DAB CLI commands, and connection strings.
- Include MCP Inspector.
- Include SQL Commander only for SQL Server unless the user asks for a database browser compatible with another engine.

### SQL authentication quickstart

Special requirements:

- Use SQL authentication locally and in Azure.
- Store `SQL_PASSWORD` and `MSSQL_CONNECTION_STRING` in local secrets.
- Use `@env('MSSQL_CONNECTION_STRING')` in DAB config.
- Validate anonymous REST, GraphQL, and MCP access.

### Managed identity quickstart

Special requirements:

- Use SQL authentication only as a local development fallback.
- Use system-assigned managed identity in Azure.
- Configure a Microsoft Entra admin for Azure SQL.
- Create a contained database user for the DAB managed identity.
- Grant least required roles such as `db_datareader` and `db_datawriter`.
- Verify the Azure connection string uses `Authentication=Active Directory Default` and has no SQL username or password.

### Microsoft Entra provider quickstart

Special requirements:

- Configure DAB token validation with the Microsoft Entra provider.
- Keep the web app anonymous if the quickstart’s purpose is provider wiring without sign-in.
- Do not add MSAL sign-in or bearer-token calls unless the scenario explicitly requires it.

### DAB policies quickstart

Special requirements:

- Use MSAL in the web app when signed-in users are required.
- Send bearer tokens from the web app to DAB.
- Use DAB database policy syntax, not SQL syntax.
- Example policy shape: `@item.Owner eq @claims.preferred_username`.
- Validate anonymous `401` and disjoint row sets for different users.

### SQL row-level security quickstart

Special requirements:

- Use DAB to map the approved claim into SQL `SESSION_CONTEXT`.
- Use `--set-session-context true` or equivalent config.
- Implement SQL predicate function and security policy.
- Do not also add DAB per-entity database policies unless the scenario explicitly asks for both.
- If artifacts disagree on the claim key, align them to the approved claim mapping and continue. Ask only if the intended mapping is ambiguous.

### On-behalf-of quickstart

Special requirements:

- Azure-only unless the scenario provides a local identity substitute.
- Use DAB `user-delegated-auth` for Azure SQL.
- Use a bare Azure SQL connection string without `User ID`, `Password`, or `Authentication`.
- Include app registration, API scope, delegated Azure SQL permission, and admin consent steps.
- Validate with a `WhoAmI` view that shows SQL sees the actual caller.
- Use Key Vault or Container Apps secrets for secrets; never print or commit them.

## Microsoft Learn style rules for prompt sections

Apply the repo’s docs rules even inside prompt sections when practical:

- Use second person in surrounding article prose.
- Avoid “we,” “our,” and “let’s.” In prompt text, use “the deployment phase starts” instead of “we reach deployment.”
- Use bullets for nonsequential lists.
- Use numbered lists only for true sequences.
- Use site-relative Learn links.
- Use correct code fence tags: `dotnetcli`, `powershell`, `bash`, `json`, `yaml`, `dockerfile`, `sql`, `text`, `csharp`.
- Use sentence case for headings.
- Keep every fenced code block closed.
- Use a four-backtick `copilot-prompt` fence when nested code blocks are present.

## Review checklist

Before finishing a prompt edit, verify:

- [ ] The target `.md` frontmatter has confirmed `author`, `ms.author`, and current `ms.date` values according to repo instructions.
- [ ] The prompt uses the standard heading and four-backtick `copilot-prompt` fence.
- [ ] The prompt starts with a clear agent-mode mission statement.
- [ ] The prompt uses the current VS Code workspace and a default subfolder; it doesn't ask for root folder or project folder names.
- [ ] The prompt asks the minimum necessary setup questions before implementation.
- [ ] Azure work has an explicit approval gate before create/change commands.
- [ ] The prompt says to prioritize finishing and use approved fallbacks for recoverable issues.
- [ ] The prompt asks the user only for true blockers, materially higher cost, new permissions, secrets, or approval beyond the existing plan.
- [ ] Cost-first Azure defaults are included when Azure is in scope.
- [ ] Secrets are handled before any secret values are written.
- [ ] DAB CLI commands and minimal config are correct for the database engine and scenario.
- [ ] MCP Inspector is included and validated when MCP is enabled.
- [ ] SQL Commander is included and configured correctly for SQL Server scenarios.
- [ ] The generated web app is minimal but polished.
- [ ] Validation covers direct database checks, DAB 2xx health, REST, GraphQL, MCP, web site success, web app behavior, identity, Azure health, and cleanup as applicable.
- [ ] The prompt tells the implementing agent to keep debugging, revising, rerunning, and documenting retries until the sample runs end-to-end or a genuine external blocker remains.
- [ ] The prompt prevents reporting final URLs, asset locations, or success before direct database validation, DAB 2xx health, and successful web site response checks pass.
- [ ] No absolute Learn URLs are present.
- [ ] Nonsequential lists use bullets.
- [ ] A review subagent has checked technical accuracy, style, links, and peer consistency for substantial edits.
- [ ] The `dab-docs-audit` skill has been used for final compliance validation.

## Procedure

1. **Inspect peers** — Read the target file and 1–2 nearby quickstarts with existing `copilot-prompt` sections.
2. **Extract scenario details** — Identify database, auth, local orchestration, Azure scope, validation goals, and sample-specific tools.
3. **Draft from the standard structure** — Mission, questions, approval gate, cost-first/finish-first guidance, prerequisites, docs links, project structure, secrets, implementation snippets, validation, and report.
4. **Preserve scenario boundaries** — Do not add sign-in, Azure deployment, SQL Commander, MCP tools, or app registrations unless the scenario requires them or the prompt asks the user whether to include them.
5. **Patch the doc** — Add or update only the prompt section and required frontmatter metadata unless the request asks for broader article edits.
6. **Review** — Use a subagent to check prompt completeness, technical accuracy, style, links, peer consistency, and subtle operational issues.
7. **Fix valid feedback** — Apply actionable fixes; avoid over-engineering.
8. **Audit** — Run the DAB docs audit checklist and fix blocking/compliance issues.
9. **Validate** — Run diagnostics and `git diff --check` for edited files.
10. **Report** — Summarize changed files, key prompt behavior, and validation results.
