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

## CLI command page requirements

- Ensure the **Quick glance** table covers every option from `dab <command> --help`.
- Ensure each option has a matching `##` section and a minimal example.
- Keep opening examples “fast-start” and only using the documented command.
- For CLI examples, prefer multi-line commands and include both Bash and Windows Command Prompt via Learn conceptual tabs.

## Validation (Markdown-only)

- Treat DocFX build warnings as blocking, especially broken links and `bookmark-not-found`.
- If you changed headings/anchors in commonly-linked pages (for example, `data-api-builder/command-line/*.md`), search the repo for inbound links and update them.

Use `.github/agents/DAB Docs Author.agent.md` for the full playbook.
