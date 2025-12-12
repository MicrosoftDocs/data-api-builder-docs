# DAB docs authoring guide (agent)

This guide teaches an agent how to author Data API builder documentation that is:

- Structurally consistent with existing DAB docs.
- Terse, clear, and grammatically consistent.
- Comprehensive (covers the full CLI surface area).
- Compliant with Microsoft Learn build and review validations.

## Non-negotiables

- Follow the existing page’s structure and tone. Don’t invent a new format.
- Keep content terse and scannable; prefer tables and short examples.
- If a change would alter meaning or product behavior, don’t do it without user confirmation.
- Don’t introduce new UI/UX, new sections, or extra narrative when a page already uses a pattern.

## Agent operating mode (Beast Mode behaviors)

Use these behaviors when they are relevant to the task.

### Persistence and completion

- Keep going until the user’s request is fully resolved end-to-end.
- Don’t stop at analysis or partial fixes; implement, validate, and then summarize.
- If you hit a blocker, try to resolve it autonomously first. If you can’t, explain the blocker and propose the smallest next action that unblocks progress.

### Plan-first execution

- Create and maintain a step-by-step TODO list for non-trivial work.
- Work one step at a time; mark steps complete immediately when finished.
- If the user says “continue”, resume from the next incomplete step.

When you must show the TODO list in chat, use this exact format:

```markdown
- [ ] Step 1: ...
- [ ] Step 2: ...
```

### Tool use and progress narration

- Before each tool call, say (in one sentence) what you’re about to do and why.
- After a small batch of tool calls, provide a short progress update and what’s next.
- Make small, safe, incremental edits instead of large rewrites.

### Research and freshness

- If the user provides URLs, fetch them and recursively fetch relevant links found on those pages.
- For third-party tools/packages/dependencies, verify usage via web research before installing or recommending implementation details.
- Prefer primary sources (official docs) over secondary summaries.

### Validation and quality gates

- Validate changes frequently.
- For docs changes in this repo:
  - Run `.github/agents/Dab Docs Author/preflight.ps1` against changed files.
  - Check Learn validations using `.github/agents/Dab Docs Author/learn-build-rulebook.md` (links, headings, images, code fences).
- If a repo has tests or a build, run the most relevant checks first, then broader checks.

### Safety and scope control

- Fix the root cause (not just symptoms) when you can.
- Don’t introduce unrelated changes or “nice-to-have” additions.
- Don’t guess: if a config shape, behavior, or contract is uncertain, either verify it from authoritative sources or omit speculative output.

### Environment variables

- If you add/require an environment variable for a runnable artifact, check for a `.env` and create one with placeholders if missing.

### Git hygiene

- Never commit changes automatically.
- If asked to commit, stage/commit only after the user confirms.

## Authoring workflow for CLI reference pages

### 1) Inventory the CLI surface area

- Obtain the authoritative option list from the CLI’s help output.
  - Prefer `dab <command> --help`.
  - If you only have captured output, use these captures as baselines:
    - v1.6 (stable): `.github/agents/Dab Docs Author/dab-cli-help-1.6.84.md`
    - v1.7 (RC): `.github/agents/Dab Docs Author/dab-cli-help-1.7.81-rc.md`
  - Use `.github/agents/Dab Docs Author/dab-cli-version-notes.md` to call out version differences, and treat v1.7 as RC.
- Create a checklist of:
  - Positional arguments.
  - Flags (including synonyms like `-c, --config`).
  - Values and allowed enums.
  - “Only applies to …” constraints.

When an option (or config property) accepts an enum, include every supported value:

- Prefer the CLI help output for the authoritative enum list.
- If the CLI help doesn’t enumerate values, validate via the config JSON schema (and/or a real CLI run).
- Keep the enum descriptions terse.
- When possible, link to a deeper doc page in this repo that covers the enum or concept (for example, a configuration reference page). Prefer repo-relative links.

### 2) Make the page complete

- Update the **Quick glance** table so it includes every supported option.
- Ensure each option in Quick glance has a matching section:
  - Heading format: `## \`--flag\`` or `## \`-s, --source\``
  - Consistent substructure:
    - One short description sentence.
    - `### Example`
    - Optional `### Resulting config` (only when it adds clarity).

### 3) Keep the opening examples “fast-start”

When a page already starts with “Quick examples”, keep them as:

- Minimal, runnable command(s) that help a developer get started fast.
- Use the command being documented (`dab add` on `dab-add.md`), not follow-on commands.
- Avoid “all-at-once vs one-at-a-time” walkthroughs in the opening section.

### 4) Don’t guess JSON shapes

- Prefer JSON shapes that already exist in the repo’s reference docs.
- For CLI reference pages, validate “Resulting config” snippets by running the CLI and using the generated `dab-config.json` as the source of truth.
  - Create/refresh a sandbox config (for example, `.github/agents/Dab Docs Author/cli-sandbox/`) with `dab init`.
  - Run the exact commands shown in the docs.
  - Copy the relevant JSON emitted by the CLI into the “Resulting config” snippet.
  - If a doc update changes an example command or a “Resulting config” snippet, re-run the CLI for that example before considering the doc done.
- If an output shape is uncertain:
  - Either omit the “Resulting config” snippet, or
  - Use a known-good minimal shape and avoid speculative properties.

Prefer the sandbox config as the starting point for examples:

- Keep the sandbox config small and resettable.
- If a baseline config exists (for example, `dab-config.base.json`), copy it back to `dab-config.json` before each example run.

When documenting configuration properties, validate names/required-ness/enums against the config JSON schema:

- `.github/agents/Dab Docs Author/dab-config-schema-source.md` (includes the authoritative source link)

Before editing a page, read enough of the surrounding file to match its patterns and avoid unintended structure changes.

### 5) Validate against Learn build rules

Use `.github/agents/Dab Docs Author/learn-build-rulebook.md` as your checklist. The most common failures to prevent:

- Absolute Learn links (must be relative or site-relative).
- Locale-pinned URLs (remove `/en-us/` for Microsoft sites in scope).
- `?view=` without `&preserve-view=true`.
- Missing/duplicate/bad alt text.
- Disallowed acronyms/abbreviations in new filenames.
- Unclosed or indented code blocks.

Also use `.github/agents/Dab Docs Author/learn-errors-to-avoid.md` as a quick pre-push scan.

Run `.github/agents/Dab Docs Author/preflight.ps1` before pushing.

### 6) Mark preview and prerelease features

- When a flag/behavior exists only in prerelease/RC (for example, v1.7 RC vs v1.6 stable), add a per-flag `[!NOTE]` indicating it’s prerelease/preview.
- Prefer per-flag notes over a single global note at the top of the page.
- When helpful, include the install hint: `dotnet tool install microsoft.dataapibuilder --prerelease`.

## DAB-specific doc conventions

### Front matter

Use the same metadata pattern as existing DAB docs files. Common required fields:

- `title`, `description`
- `author`, `ms.author`, `ms.reviewer`
- `ms.service`, `ms.topic`, `ms.date`

Keep `description` meaningful and typically 100–160 characters.

### Terminology

- Use “Data API builder” as the product name in narrative text.
- Use “DAB” only when a page explicitly defines the acronym or in CLI contexts.
- Use consistent casing for technologies (`GraphQL`, `REST`, `OData`, `Azure SQL`).

### Examples

- Use fenced code blocks with an explicit language (for example, `bash`, `json`, `http`).
- Ensure code fences are closed.
- Keep examples short and single-purpose.
- For DAB CLI command examples, include both Bash and Windows Command Prompt using Learn conceptual tabs:

  ```markdown
  #### [Bash](#tab/bash)

  ```bash
  dab <command> \
    --flag value
  ```

  #### [Command Prompt](#tab/cmd)

  ```cmd
  dab <command> ^
    --flag value
  ```

  ---
  ```

- Prefer multi-line commands over one-liners. Use `\` for Bash and `^` for Command Prompt line continuation.

### Links

- Prefer repo-relative links for internal pages (for example, `./dab-update.md`).
- For Microsoft Learn, prefer:
  - Relative links within the same docset, or
  - Site-relative links (beginning with `/...`) across docsets.
- Avoid locale (`/en-us/`) in Microsoft links.

### Images

- Every image must have meaningful, unique alt text.
- Keep alt text descriptive and not just the image filename.
- New image names must use complete words, hyphen separated, and be short enough.

## Completeness checklist (CLI page)

- [ ] Quick glance contains all options from CLI help.
- [ ] Each option has a corresponding `##` section.
- [ ] Opening examples are fast-start and use only the command documented.
- [ ] “Only for stored procedures” / “Not valid for views” constraints are stated.
- [ ] Links comply (no absolute Learn links, no locale, preserve-view handled).
- [ ] Images comply (alt text present, unique, meaningful; filenames compliant).
- [ ] Markdown passes basic sanity (H1 present; code fences closed).
