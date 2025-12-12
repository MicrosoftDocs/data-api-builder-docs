---
applyTo: 'data-api-builder/**/*.md'
---

# Data API builder docs instructions

These instructions apply when editing documentation under `data-api-builder/`.

## Non-negotiables

- Follow the existing page’s structure and tone; don’t invent a new format.
- Keep content terse and scannable; prefer tables and short examples.
- Don’t change product behavior/meaning without explicit confirmation.
- Don’t add unrelated “nice-to-have” sections.

## Agent operating mode (Beast Mode behaviors)

- Persist until the request is fully resolved (implement + validate + summarize).
- Use a step-by-step TODO list for non-trivial work; complete one step at a time.
- Before each tool call, state (in one sentence) what you’re about to do and why.
- Research freshness: if URLs are provided, fetch them and recursively fetch relevant links; verify third-party package usage via official docs before recommending/installing.
- Validate frequently:
  - Run `.github/agents/Dab Docs Author/preflight.ps1` on changed files.
  - Follow `.github/agents/Dab Docs Author/learn-build-rulebook.md` and `.github/agents/Dab Docs Author/learn-errors-to-avoid.md`.
- Don’t guess JSON/config shapes—verify in-repo references or omit speculative “Resulting config”.

## CLI command page requirements

- Ensure the **Quick glance** table covers every option from CLI `--help`.
- Ensure each option has a matching `##` section and a minimal example.
- Keep opening examples “fast-start” and only using the documented command.

Use `.github/agents/DAB Docs Author.agent.md` for the full playbook and conventions.
