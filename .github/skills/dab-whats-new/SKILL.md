---
name: dab-whats-new
description: 'Draft, revise, or review a Data API builder whats-new page. Use for release notes, version announcements, preview releases, GA releases, or release summaries.'
argument-hint: 'Provide: version number, month/year, preview or GA status, release themes, and the feature list with CLI/config/output examples.'
user-invocable: true
---

# DAB What's New

Use this skill to turn a feature list into a polished Learn-style Data API builder release page. Use `data-api-builder/whats-new/version-2-0.md` as the reference for scannability, tone, and section rhythm — but adapt to the supplied release scope rather than mimicking its structure literally.

## Hard constraints

These apply unconditionally.

- Use Learn-compliant DocFX Markdown.
- Use site-relative links only (starting with `/`).
- Write in present tense.
- Do not speculate or promise content beyond the supplied release scope.
- Do not pad with marketing language, hype, or vague adjectives.
- Do not turn the page into a raw changelog unless explicitly asked.
- `---` closes Learn tab groups only; never use it as a decorative separator.

## Inputs

If inputs are missing, draft immediately with explicit `[PLACEHOLDER]` markers and list what is missing at the top of the draft. Do not stall waiting for complete inputs.

Required inputs:

- Target version number
- Release month and year
- Release state (preview, GA, RC)
- One-sentence release focus summary
- Ordered feature list — with user value, CLI commands, config snippets, outputs, and canonical docs to link for each item

## Document anatomy

1. YAML frontmatter: `title`, `description`, author metadata, `ms.service: data-api-builder`, `ms.topic: whats-new`, `ms.date`
2. H1: `# What's new in Data API builder version X.Y (Month Year)`
3. Optional release-status note (preview, RC, or other caveats)
4. One or two sentence summary paragraph on release themes
5. One `##` section per major feature or behavior change

## Section pattern

Apply this to most feature sections.

```text
## Introducing: <feature name>     (new capabilities)
## <descriptive heading>           (enhancements)

[Opening paragraph: what changed and which DAB surface area — CLI, config, runtime, MCP, REST, auth, telemetry, etc.]

### Why?
[Direct benefit statement — "Now, when..." or "With ..."]

### Prerequisites for ... | Configuration requirements | Command line | Testing your configuration
[Use only when they materially help; omit otherwise]

### Read the docs
[1–3 targeted relative links]
```

**Section ordering:** Lead with the highest user-impact items. Group related features (auth, observability, MCP, and so on). Keep heading depth shallow; add `###` subsections only when content genuinely needs them.

## House style

These are preferred patterns, not hard rules, but they make the page consistent with existing DAB whats-new content.

- Sound like a product engineer explaining a release to practitioners.
- Short declarative sentences; lead with product behavior, then the benefit.
- Be explicit about defaults, constraints, and supported environments.
- Prefer: "DAB X.Y introduces...", "When enabled...", "Now, you can...", "With ..."
- Avoid: "revolutionary", "game-changing", "seamless", "best-in-class"
- Use callouts only for real safety or supportability boundaries:
  - `> [!NOTE]` — preview state, supportability caveats, scope limitations
  - `> [!IMPORTANT]` — behavior that can surprise users, affect security, or change permissions
- Do not stack callouts unless each carries distinct value.

## Examples

- Include examples only when they clarify how to adopt the feature.
- Prefer small, copyable fragments over full-file samples. A JSON fragment is almost always enough; avoid massive full-config blobs.
- Favor CLI examples for command-driven features, JSON fragments for config-shape features, and text output blocks for console-behavior changes.
- Use realistic but compact entity and schema names.
- Do not include near-duplicate samples.
- Fenced code blocks must have explicit languages: `bash`, `sh`, `json`, `text`, `csv`.
- Use tabs only when variants are materially different (for example, Bash vs. Windows Command Prompt). Keep tab IDs consistent across the page and close tab groups with `---`.

## Procedure

1. Inventory the feature list; identify missing inputs.
2. Group features by user impact and identify the headline items.
3. Draft frontmatter, H1, status note, summary paragraph, and each feature section using the pattern above.
4. Insert `[PLACEHOLDER]` for any missing CLI, config, or link inputs and list them at the top.

## Output

- **New or revised page:** Produce publication-ready Markdown. List missing inputs separately at the top.
- **Review or outline only:** Return a compact issues list or section-order recommendation before drafting.