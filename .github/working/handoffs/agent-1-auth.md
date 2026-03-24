# Agent 1 Handoff: Authentication & Authorization

## Your Mission
You are a "DAB Docs Author" agent. Hunt through ALL documentation files for references to authentication, authorization, permissions, roles, and security. Update them to reflect DAB 2.0 changes. Add new content where needed. Add cross-links to the what's-new article.

## Repository Structure
- Docs root: `data-api-builder/`
- Key folders: `configuration/`, `concept/security/`, `command-line/`, `how-to/`, `mcp/`, `deployment/`
- What's new: `data-api-builder/whats-new/version-2-0.md`
- TOC: `data-api-builder/TOC.yml`

## Changes in DAB 2.0

### 1. Unauthenticated Provider (NEW DEFAULT)
- `Unauthenticated` is a new authentication provider value
- It is now the DEFAULT for new configurations (previously was `StaticWebApps` or similar)
- When active: all requests run as `anonymous`, DAB does NOT inspect/validate JWT
- Auth is expected to be handled upstream (APIM, app gateway)
- `dab init` now produces a config with `"provider": "Unauthenticated"` by default
- To use another provider, you must set it explicitly: `dab init ... --auth.provider AppService`
- IMPORTANT: When `Unauthenticated` is active, `authenticated` and custom roles are NEVER activated. DAB emits a warning if those roles exist in config.
- Valid provider values in schema: `StaticWebApps`, `EntraID`, `Simulator`, `AppService`, `AzureAD`, `Custom`, `Unauthenticated`

**What to find and update:**
- Any docs that say the default auth provider is something other than `Unauthenticated`
- Any docs that list valid authentication providers (must now include `Unauthenticated`)
- `dab init` docs — default behavior changed
- Configuration reference for `runtime.host.authentication.provider`
- Security how-to articles that assume JWT is always configured
- Deployment docs/checklists that reference auth setup

### 2. Role Inheritance for Entity Permissions
- NEW behavior: `named-role → authenticated → anonymous` inheritance chain
- If `authenticated` is NOT configured for an entity, it inherits from `anonymous`
- If a named role is NOT configured, it inherits from `authenticated` (or `anonymous` if `authenticated` is also absent)
- You can define permissions once on `anonymous` and every broader role gets access automatically

**What to find and update:**
- Permission docs (`concept/security/authorization.md`)
- Entity permissions config docs (`configuration/entities.md`)
- Any example showing duplicate permission blocks across roles
- Database policy docs that discuss role resolution

### 3. Show Effective Permissions CLI Option
- New `--show-effective-permissions` flag on `dab configure`
- Displays resolved permissions for every entity after inheritance
- Works with `--config` flag

**What to find and update:**
- `command-line/dab-configure.md` — add this new flag
- Any CLI reference tables listing dab configure options

### 4. On-Behalf-Of (OBO) User-Delegated Authentication
- NEW feature for SQL Server and Azure SQL only
- DAB exchanges incoming user token for downstream SQL token
- Database authenticates as the actual calling user
- Config: `data-source.user-delegated-auth` with `enabled`, `provider` (EntraId), `database-audience`
- Required env vars: `DAB_OBO_CLIENTID`, `DAB_OBO_CLIENTSECRET`, `DAB_OBO_TENANTID`
- CLI: `dab configure --data-source.user-delegated-auth.enabled true`
- Only supported for `mssql` data sources
- Enables per-user connection pooling (separate SQL pools per user)

**What to find and update:**
- `configuration/data-source.md` — add `user-delegated-auth` section
- Security docs — add OBO as an authentication option
- Row-level security docs (`concept/security/row-level-security.md`) — mention OBO as enabler
- Connection string docs if they exist
- `command-line/dab-configure.md` — add OBO CLI options

## MS Learn Requirements
- Every .md file needs YAML front matter (title, description, author, ms.author, ms.reviewer, ms.service, ms.topic, ms.date)
- Use `> [!NOTE]`, `> [!IMPORTANT]`, `> [!TIP]`, `> [!WARNING]` for callouts
- Use `##` for H2, `###` for H3 (never H1 in body — that's the title)
- Code blocks need language identifiers (```json, ```bash, ```text)
- Links use relative paths: `../concept/security/authorization.md`
- No trailing whitespace, files end with newline
- ms.date format: MM/DD/YYYY

## Cross-Links
Add brief cross-links from updated docs back to `../whats-new/version-2-0.md` where appropriate (e.g., "> [!TIP]\n> This behavior changed in version 2.0. For more information, see [what's new](../whats-new/version-2-0.md).").

## Output
After completing all changes, write a detailed report to:
`.github/working/reports/agent-1-auth-report.md`

The report should list every file changed, what was changed, and why. Also list any files where you considered changes but decided against them, with reasoning.

Then stage and commit your changes:
```
git add -A
git commit -m "docs: update auth & authorization docs for DAB 2.0

- Add Unauthenticated as new default authentication provider
- Document role inheritance for entity permissions  
- Add --show-effective-permissions CLI option
- Document OBO user-delegated authentication for SQL
- Add cross-links to what's-new article

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
```
