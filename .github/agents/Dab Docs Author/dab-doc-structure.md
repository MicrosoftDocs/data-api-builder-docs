# DAB documentation structure (agent)

This file documents the common structure patterns used across Data API builder docs in this repo.

## CLI command reference pages (`data-api-builder/command-line/*.md`)

### Standard sections (preferred ordering)

1. YAML front matter
2. H1: command name (for example, `# \`add\` command`)
3. One-paragraph purpose
4. Optional `> [!TIP]` callout for cross-command guidance
5. `## Syntax`
6. `### Quick glance` (options table)
7. Options sections, one per flag/argument

### Quick glance table pattern

- Two columns: **Option** and **Summary**.
- Include:
  - Required positional arg(s)
  - Every supported flag from CLI help
  - Each entry links to its section anchor

### Option section pattern

Use these consistent subheadings:

- `## \`--flag\`` or `## \`-s, --source\``
- One short description sentence.
- `### Example`
- Optional `### Resulting config` when it clarifies the outcome.

Constraints and applicability:

- Put “Stored procedures only.” / “Not allowed for …” immediately under the option heading.
- If an option is ignored in some cases, say so explicitly.

### Examples style

- Prefer `bash` fenced blocks for CLI invocations.
- Prefer `json` fenced blocks for config snippets.
- Keep examples minimal and runnable.
- Avoid adding extra narrative unless the page already does.

## Concept pages (`data-api-builder/concept/**/*.md`)

Common patterns:

- Define terms on first use.
- Use short paragraphs and bullet lists.
- Use examples to show the “shape” (GraphQL, HTTP, JSON).
- Use admonitions sparingly and consistently (`[!NOTE]`, `[!TIP]`, `[!IMPORTANT]`).

## Quickstarts (`data-api-builder/quickstart/**/*.md`)

Common patterns:

- Start with prerequisites.
- Provide a minimal happy-path flow.
- Keep code and CLI instructions precise.
- Use screenshots/images only when they materially reduce confusion.
- Ensure every image meets the alt text and naming rules.
