---
name: dab-docs-audit
description: 'Audit a Data API builder documentation file for Microsoft Learn compliance, style, accuracy, and information architecture. Checks frontmatter, links, images, code fences, alerts, tabs, voice, and peer consistency.'
argument-hint: 'Provide: file path to audit (or use the active file). Optionally specify focus area: full, style, links, metadata, images, or peer-consistency.'
user-invocable: true
---

# DAB Docs Audit

Use this skill to audit one or more Data API builder documentation files against Microsoft Learn publishing requirements, DAB repo conventions, and platform build validation rules. This skill produces a structured findings report grouped by severity.

## When to use

- After creating or substantially editing a file.
- Before submitting a PR.
- When reviewing someone else's contribution.
- As a final check after implementing sub-agent review feedback.

## Audit checklist

Run every check in this list against each file being audited. Report findings grouped by severity: **blocking** (will fail build or violate Learn requirements), **compliance** (should fix before publish), and **polish** (nice to have).

---

### 1. YAML frontmatter

| Check | Rule |
|---|---|
| `title` present | Required. Sentence case. 1–160 characters. |
| `description` present | Required. 75–300 characters. Must not start with a brand name. |
| `author` present | Required. Must be a valid GitHub username. |
| `ms.author` present | Required. Must be a Microsoft alias (without @microsoft.com). |
| `ms.reviewer` present | Expected in this repo. |
| `ms.service` | Must be `data-api-builder`. |
| `ms.topic` | Must be one of: `how-to`, `concept`, `quickstart`, `tutorial`, `whats-new`, `reference`, `landing-page`, `faq`. |
| `ms.date` | Required. Format `MM/DD/YYYY`. Should reflect the last substantial edit. |
| `# Customer Intent` comment | Expected in this repo. Format: `As a <role>, I want to <action> so that I can <outcome>.` |
| No extra/unknown fields | Flag unexpected metadata fields. |

### 2. Heading structure

| Check | Rule |
|---|---|
| Sentence case | Only the first word and proper nouns are capitalized. |
| No skipped levels | `##` before `###`. Never skip from `##` to `####`. |
| No gerunds | Use "Configure..." not "Configuring...". |
| H1 matches `title` | The `#` heading should closely match the `title` frontmatter. |
| No intro phrases as headings | If a "heading" is really an intro to a code block, use body text with a colon instead. |

### 3. Images

| Check | Rule |
|---|---|
| Standard Markdown syntax | Must use `![alt text](path)`. Flag any `:::image` blocks (all forms: `type="complex"`, `type="content"`, or otherwise). |
| Alt text present | Every image must have alt text. |
| Alt text descriptive | Alt text must be 10–250 characters. Must not be just the filename. Should start with "Diagram showing" or "Screenshot of" and end with a period. |
| Page-specific media folder | Images must be in `media/<page-name>/` subfolder matching the doc filename. |
| No shared media folders | Each doc must have its own media subfolder. |
| Files exist | Verify referenced image files exist on disk. |

### 4. Links

| Check | Rule |
|---|---|
| Same-folder links | Use just the filename: `sibling-file.md`. |
| Cross-folder links | Use relative paths: `../concept/config/env-function.md`. |
| Microsoft Learn cross-service | Use site-relative paths starting with `/`: `/cli/azure/install-azure-cli`. |
| No absolute Learn URLs | Flag any `https://learn.microsoft.com/...` links. These should be site-relative. |
| No locale in paths | Remove `/en-us/` from any site-relative links. |
| External links | Must use full HTTPS URLs. |
| No "click here" | Link text must be descriptive, not generic. |
| Bookmark anchors | Anchors must be lowercase, hyphens for spaces, no punctuation. |
| Link targets exist | For internal links, verify the target `.md` or `.yml` file exists. |

### 5. Code blocks

| Check | Rule |
|---|---|
| Language tag present | Every fenced code block must have an explicit language tag. |
| Correct language tags | DAB CLI → `dotnetcli`, .NET CLI → `dotnetcli`, Azure CLI → `azurecli`, PowerShell → `powershell`, Bash → `bash`, JSON → `json`, YAML → `yaml`, Dockerfile → `dockerfile`, plain text → `text`. |
| No indented code blocks | Code blocks must use triple backticks, not indentation. Indented code blocks fail build validation. |
| Unclosed code blocks | Every opening ` ``` ` must have a matching closing ` ``` `. |
| Proper indentation under lists | Code blocks inside numbered/bulleted lists must be indented 4 spaces to align with the list item. |

### 6. Alerts

| Check | Rule |
|---|---|
| Correct syntax | Must use `> [!NOTE]`, `> [!TIP]`, `> [!IMPORTANT]`, `> [!WARNING]`. |
| No bold-text alerts | Flag `> **Warning**` or similar — use the proper alert syntax. |
| No custom alert types | Only NOTE, TIP, IMPORTANT, and WARNING are valid. |
| No stacked alerts | Avoid consecutive alert blocks unless each carries distinct value. |

### 7. Tab groups

| Check | Rule |
|---|---|
| Closed with `---` | Every tab group must end with `---` on its own line. |
| Consistent IDs | Tab IDs must be consistent across all tab groups on the same page (e.g., always `powershell`/`bash`). |
| `---` not decorative | The `---` delimiter must only be used to close tab groups, never as a horizontal rule or separator. |

### 8. Voice and style

| Check | Rule |
|---|---|
| Second person | Use "you" / "your". Flag any "we", "our", "let's", or first person. |
| Active voice | Flag passive constructions where active alternatives exist. |
| Present tense | Use present tense unless describing a completed past event. |
| No "we recommend" | Use "Consider..." or a direct imperative instead. |
| No marketing language | Flag "revolutionary", "game-changing", "seamless", "best-in-class", etc. |
| No future promises | Do not promise future features. Use "This feature is in preview." |
| Terminology | Use "back end" (two words), not "backend". Use "sign in", not "log in". |
| Concise | Flag unnecessary filler words, redundant phrases, and overly long sentences. |

### 9. Information architecture

| Check | Rule |
|---|---|
| In `TOC.yml` | The file must have an entry in `data-api-builder/TOC.yml`. |
| In folder `index.yml` | If the folder has a landing page, the file should be listed. |
| Cross-references exist | The file should be referenced from at least one peer doc or parent overview. |
| `overview.md` updated | If the file introduces a new feature or deployment option, check whether `overview.md` mentions it. |

### 10. Peer consistency

Compare the file against others in the same folder:

| Check | Rule |
|---|---|
| Frontmatter fields | Same fields and format as peers. |
| Section structure | Same heading order and pattern as peers. |
| Prerequisites format | Listed consistently with peers. |
| Intro paragraph | If peers have "This guide shows you how to...", include one. |
| Clean-up section | If peers have "Clean up resources", include one. |
| Related content pattern | Match the pattern: bullet list vs. `nextstepaction`. |
| Image pattern | If peers use map SVGs or architecture diagrams, include equivalent images. |

---

## Output format

Structure findings as a table grouped by severity:

```text
## Blocking issues (must fix before publish)

| # | Line(s) | Category | Finding |
|---|---------|----------|---------|
| 1 | 15 | Image | `:::image` syntax used — convert to standard Markdown |

## Compliance issues (should fix)

| # | Line(s) | Category | Finding |
|---|---------|----------|---------|
| 2 | 10 | Frontmatter | `ms.date` is more than 12 months old |

## Polish (nice to have)

| # | Line(s) | Category | Finding |
|---|---------|----------|---------|
| 3 | 42 | Style | Passive voice: "is configured" → "configure" |

## Passed checks

| Category | Result |
|----------|--------|
| Alerts | All valid |
| Tab groups | Properly closed |
```

## Platform build validation rules

These are the most commonly triggered platform validation rules in this repo. Flag any violation as **blocking**:

| Rule ID | What it flags |
|---|---|
| `alt-text-missing` | Image without alt text |
| `alt-text-bad-value` | Alt text equals the filename |
| `author-missing` | Missing `author` in frontmatter |
| `description-missing` | Missing `description` in frontmatter |
| `code-block-indented` | Code block created by indentation instead of triple backticks |
| `code-block-unclosed` | Missing closing ` ``` ` |
| `column-header-missing` | Table without column headers |
| `article-toc-connection` | `.md` file not connected to the TOC |
| `docs-link-absolute` | Absolute `https://learn.microsoft.com/...` link used |
| `h1-missing` | No H1 heading in the article |

## Procedure

1. **Read the file** being audited and all frontmatter.
2. **Run each check** in sections 1–10 systematically.
3. **Verify links** — grep for internal link targets to confirm they exist.
4. **Verify images** — check that referenced media files exist on disk.
5. **Compare against peers** — read 1–2 peer files in the same folder for structural comparison.
6. **Produce the findings report** using the output format above.
7. **If fixing**: Before editing any `.md` file, confirm the author identity with a selectable default. Read the existing page frontmatter, offer to keep the current `author` / `ms.author` pair, and offer a custom-entry option. If either value is missing, offer `author` / `ms.author` pairs from peer files as selectable suggestions and allow a custom entry. Never guess or silently replace `author` or `ms.author`. If the user keeps the existing identity, update only `ms.date` unless other frontmatter must change. Apply edits for blocking and compliance issues. Leave polish items for the author to decide.

Do not make edits unless explicitly asked. The default output is a findings report only.
