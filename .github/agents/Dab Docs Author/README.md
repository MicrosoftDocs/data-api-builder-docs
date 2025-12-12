# Agent docs guidance (Data API builder)

This folder contains ancillary resources for the DAB docs authoring agent (`../DAB Docs Author.agent.md`).

VS Code/Copilot entrypoints:

- `.github/copilot-instructions.md` points Copilot at `.github/agents/`.
- `.github/instructions/dab-docs.instructions.md` applies focused rules to `data-api-builder/**/*.md`.

Use these files when creating or updating docs:

- `../DAB Docs Author.agent.md` — primary authoring playbook (structure, style, completeness workflow).
- `dab-cli-help-1.7.81-rc.md` — captured `dab` help output for key commands (useful for Quick glance completeness).
- `dab-config-schema-source.md` — link to the authoritative DAB config JSON schema + key excerpts.
- `learn-build-rulebook.md` — consolidated Learn build/review validations (what they mean + how to fix).
- `learn-errors-to-avoid.md` — fast checklist of the most common validation failures.
- `dab-doc-structure.md` — DAB-specific patterns and templates (CLI command pages, concept pages).
- `preflight.ps1` — lightweight preflight checks that focus on *changed files*.
- `preflight-config.json` — allowlist/config used by `preflight.ps1`.

Suggested workflow (authoring a CLI command page):

1. Start from the existing DAB command docs format (see `dab-doc-structure.md`).
2. Copy the command’s `--help` output and ensure every option is documented:
   - Every option appears in the **Quick glance** table.
   - Every option has a matching `##` section.
3. Run `preflight.ps1` before pushing.
