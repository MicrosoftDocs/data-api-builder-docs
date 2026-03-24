# Agent 1 Report: Authentication & Authorization

## Summary

Updated 11 documentation files to reflect DAB 2.0 authentication and authorization changes. Added new content for Unauthenticated default provider, role inheritance, `--show-effective-permissions` CLI option, and On-Behalf-Of (OBO) user-delegated authentication.

## Files Changed

### 1. `configuration/runtime.md`
- **What changed**: Updated authentication provider default from `null`/`AppService` to `Unauthenticated`. Added `Unauthenticated` to the enum list, provider summary table, and format overview. Replaced "Anonymous-only (no provider)" section with "Unauthenticated (default)" section including IMPORTANT callout about role activation. Added TIP cross-link to what's-new article.
- **Why**: The default auth provider changed in DAB 2.0. This is the primary configuration reference for authentication.

### 2. `configuration/data-source.md`
- **What changed**: Added `user-delegated-auth` properties to the settings table and format overview. Added full "User-delegated auth" section with nested properties table, required environment variables, per-user connection pooling, format, and example. Includes TIP cross-link to what's-new and IMPORTANT callout about mssql-only support.
- **Why**: OBO is a net-new feature that belongs in the data-source configuration reference.

### 3. `configuration/entities.md`
- **What changed**: Added "Role inheritance" subsection under Permissions with inheritance chain diagram, explanation, TIP cross-link to what's-new, example config, and link to `--show-effective-permissions`.
- **Why**: Entity permissions are where role inheritance manifests. Developers need to know they can define permissions once on `anonymous`.

### 4. `command-line/dab-init.md`
- **What changed**: Updated `--auth.provider` summary to show "(default `Unauthenticated`)" in table. Expanded section description to explain the new default behavior, added TIP cross-link, and listed all valid provider values.
- **Why**: `dab init` now produces configs with `Unauthenticated` by default.

### 5. `command-line/dab-configure.md`
- **What changed**: Added 4 new options to the quick glance table: `--show-effective-permissions`, `--data-source.user-delegated-auth.enabled`, `--data-source.user-delegated-auth.provider`, `--data-source.user-delegated-auth.database-audience`. Added full documentation sections for each with Bash/Command Prompt examples, TIP cross-links, and resulting config.
- **Why**: These are new CLI flags in DAB 2.0 that need documentation.

### 6. `concept/security/authorization.md`
- **What changed**: Added "Role inheritance" section with inheritance chain, explanation, TIP cross-link, example config, and link to `--show-effective-permissions`. Updated "Permissions must be explicitly configured" section to reference inheritance instead of requiring explicit grants for both system roles.
- **Why**: This is the primary authorization concept doc. Role inheritance fundamentally changes how permissions work.

### 7. `concept/security/index.md`
- **What changed**: Added `Unauthenticated` to provider table as first row with "(default)" label. Added TIP about default provider change. Updated Quick reference table to include `Unauthenticated` in provider list. Added OBO to row-level/field-level security table. Added new "Role inheritance" section.
- **Why**: This is the security landing page that developers consult first.

### 8. `concept/security/row-level-security.md`
- **What changed**: Added TIP callout mentioning OBO as an enabler for row-level security, with links to user-delegated auth and what's-new.
- **Why**: OBO directly enables RLS with real user identity — developers implementing RLS need to know this option exists.

### 9. `deployment/checklist.md`
- **What changed**: Added checkbox item about configuring authentication provider, noting the new `Unauthenticated` default and when to set an explicit provider.
- **Why**: Deployment checklists should flag auth configuration decisions.

### 10. `deployment/best-practices-security.md`
- **What changed**: Added "Configure authentication for production" section explaining the `Unauthenticated` default, when to use a different provider, and a subsection on OBO for SQL deployments.
- **Why**: Security best practices must address the new default and OBO for production deployments.

### 11. `overview.md`
- **What changed**: Added `Unauthenticated` as first row in authentication providers table with "(default)" label.
- **Why**: The overview page lists auth providers and should include the new default.

### 12. `mcp/how-to-configure-authentication.md`
- **What changed**: Updated the "Unauthenticated" subsection under Foundry authentication modes to reference DAB 2.0's new default `Unauthenticated` provider.
- **Why**: The MCP auth doc's Unauthenticated section should reflect the new default.

## Files Considered but Not Changed

### `concept/security/how-to-authenticate-entra.md`
- **Reason**: Does not reference a default provider or list valid providers in a way that's inaccurate. Content focuses on Entra-specific setup.

### `concept/security/how-to-authenticate-custom.md`
- **Reason**: No references to default provider or outdated provider lists.

### `concept/security/how-to-authenticate-simulator.md`
- **Reason**: Simulator-specific content doesn't reference the default provider.

### `concept/security/how-to-authenticate-app-service.md`
- **Reason**: App Service-specific content, no outdated default provider references.

### `concept/security/how-to-configure-database-policies.md`
- **Reason**: Mentions "An authentication provider configured" as a prerequisite, which remains correct — database policies do require authentication. No changes needed.

### `command-line/dab-start.md`
- **Reason**: References Simulator mode for `--simulate`, which is correct behavior unrelated to the default provider.

### `quickstart/*.md` files
- **Reason**: Quickstart files use `dab init` without `--auth.provider`, which now produces `Unauthenticated` by default. This is actually correct for quickstart scenarios (anonymous access to test data). No changes needed.

### `configuration/index.md`
- **Reason**: No authentication or provider references found.

### `whats-new/version-0.md` through `version-1-7.md`
- **Reason**: Historical release notes should not be modified.

## Cross-Links Added
All cross-links use the `> [!TIP]` callout pattern pointing to `../whats-new/version-2-0.md` (or appropriate relative path).

## ms.date Updates
All edited files have `ms.date` set to `03/24/2026`.
