---
name: dab-docs-new-file
description: 'Add a new documentation file to the Data API builder docs repo. Handles all integration points: YAML frontmatter, TOC, index.yml landing pages, media folders, cross-references, and peer-doc consistency.'
argument-hint: 'Provide: target folder, filename, topic type (how-to, concept, quickstart, whats-new, tutorial), title, and a description of the content.'
user-invocable: true
---

# DAB Docs New File

Use this skill whenever you add a new documentation file to this repo. Every new file must be integrated into the information architecture — TOC, landing pages, cross-references, and media structure. Never create a file without completing every step in the checklist.

## Repository structure

```text
data-api-builder/
├── breadcrumb/toc.yml          # Breadcrumb navigation
├── TOC.yml                     # Main table of contents
├── index.yml                   # Root landing page
├── overview.md                 # Product overview
├── command-line/
│   └── index.yml               # CLI landing page
├── deployment/
│   └── index.yml               # Deployment landing page
├── concept/
│   ├── config/
│   ├── database/
│   ├── graphql/
│   │   └── index.yml           # GraphQL landing page
│   ├── monitor/
│   ├── rest/
│   │   └── index.yml           # REST landing page
│   └── security/
│       └── index.yml           # Security landing page
├── configuration/
├── mcp/
│   └── index.yml               # MCP landing page
├── quickstart/
│   └── index.yml               # Quickstart landing page
├── troubleshooting/
├── vscode-extension/
│   └── index.yml               # VS Code extension landing page
├── whats-new/
│   └── index.yml               # What's new landing page
├── includes/                   # Shared include snippets
├── keywords/
└── media/                      # Root-level media (used by overview.md)
```

## Checklist

Complete every applicable step when adding a new file. Do not skip steps.

### 0. Confirm author identity with selectable defaults

Before creating or editing any `.md` file, confirm the GitHub username and Microsoft alias with a low-friction choice.

For a new file:

- Inspect peer files in the target folder and collect existing `author` / `ms.author` pairs.
- Offer those pairs as selectable defaults so the user can reuse the same author identity without retyping.
- Include an option to enter a different GitHub username and Microsoft alias.
- Do not guess or use placeholders for `author` or `ms.author`.

For any existing `.md` page you edit while adding cross-references or related content:

- Read the page frontmatter first.
- Treat the existing `author` and `ms.author` values as the default author identity.
- Offer a choice to keep the existing values or enter different values.
- If either value is missing, offer `author` / `ms.author` pairs from peer files as selectable suggestions and allow a custom entry.
- If the user keeps the existing values, update only `ms.date` unless other frontmatter must change.

### 1. Choose the correct location

- [ ] Identify which **folder** the file belongs in based on content type.
- [ ] Use the naming conventions below to name the file.
- [ ] Confirm no file with the same name already exists in the target folder.

### 2. Create the file with correct YAML frontmatter

Every `.md` file must start with YAML frontmatter. Use this template:

```yaml
---
title: <Title in sentence case>
description: <One-sentence description, 75–300 characters, no brand names at start>
author: <confirmed GitHub username from author identity selection>
ms.author: <confirmed Microsoft alias from author identity selection>
ms.reviewer: <Microsoft alias of reviewer>
ms.service: data-api-builder
ms.topic: <topic-type>
ms.date: <MM/DD/YYYY>
# Customer Intent: As a <role>, I want to <action> so that I can <outcome>.
---
```

Valid `ms.topic` values for this repo:

| Content type | `ms.topic` value |
|---|---|
| How-to guide | `how-to` |
| Concept / overview | `concept` |
| Quickstart | `quickstart` |
| Tutorial | `tutorial` |
| What's new | `whats-new` |
| Reference | `reference` |
| Landing page (YAML) | `landing-page` |
| FAQ (YAML) | `faq` |

### 3. Write the content

Follow these authoring rules:

#### Style rules

- Use **standard Markdown image syntax** `![]()` for all images. Do not use `:::image` DocFX syntax.
- Use **sentence case** for all headings.
- Use **active voice** and **second person** ("you") throughout.
- Do not use "we recommend" — use "Consider..." or direct imperatives instead.
- Do not use first person ("we", "our", "let's").
- Use **present tense** unless describing a completed past event.
- `---` closes Learn tab groups only; never use it as a decorative separator.

#### Code fence language tags

Use the correct language tag for code blocks:

| Content | Tag |
|---|---|
| DAB CLI commands (`dab init`, `dab add`, etc.) | `dotnetcli` |
| .NET CLI commands (`dotnet tool install`, etc.) | `dotnetcli` |
| Azure CLI commands (`az group create`, etc.) | `azurecli` |
| PowerShell scripts | `powershell` |
| Bash scripts | `bash` |
| JSON configuration | `json` |
| YAML manifests | `yaml` |
| Dockerfile content | `dockerfile` |
| Plain text URLs or output | `text` |

#### Link format rules

- **Same-folder** links: just the filename (`sibling-file.md`).
- **Cross-folder** links: relative paths (`../concept/config/env-function.md`).
- **Microsoft Learn** cross-service links: site-relative paths starting with `/` (`/cli/azure/install-azure-cli`).
- **External** links: full HTTPS URLs.
- Never use absolute `https://learn.microsoft.com/...` links for Learn content — use site-relative paths.
- In `.yml` files, use `url:` (relative) or `href:` (relative).

#### Alert syntax

Use standard Learn alert blocks:

```markdown
> [!NOTE]
> Informational content.

> [!TIP]
> Helpful suggestion.

> [!IMPORTANT]
> Critical information.

> [!WARNING]
> Potential data loss or security issue.
```

#### Tab groups

Use this syntax for platform-specific content:

```markdown
### [PowerShell](#tab/powershell)

content here

### [Bash](#tab/bash)

content here

---
```

Always close tab groups with `---` on its own line.

### 4. Create the media folder

If the file includes images:

- [ ] Create a **page-specific media subfolder** matching the filename (without `.md`).
  - Example: `deployment/azure-app-service.md` → `deployment/media/azure-app-service/`
- [ ] Place all images for this file in that subfolder.
- [ ] Reference images with relative paths: `media/<folder-name>/<image-file>`.
- [ ] Use descriptive **alt text** for every image (not "image" or "screenshot" alone).

### 5. Add the file to `TOC.yml`

- [ ] Open `data-api-builder/TOC.yml`.
- [ ] Find the correct **section** for the new file.
- [ ] Add a new entry with `name`, `href`, and optionally `displayName`.

```yaml
    - name: <Display name>
      href: <relative-path-to-file.md>
      displayName: <comma-separated search keywords>
```

- [ ] Verify the entry is indented correctly under its parent section.
- [ ] Verify alphabetical or logical ordering within the section matches existing patterns.

### 6. Add the file to the folder's `index.yml` (if one exists)

Many folders have a landing page (`index.yml`) that lists all docs in that section. If the target folder has one:

- [ ] Open the folder's `index.yml`.
- [ ] Add the new file to the appropriate `linkListType` section.
- [ ] Update the landing page's `metadata.description` if it enumerates hosting options or features by name.

Example entry:

```yaml
  - title: <Card title>
    linkLists:
      - linkListType: how-to-guide
        links:
          - text: <Link text matching the doc title>
            url: <filename.md>
      - linkListType: reference
        links:
          - text: <Related reference doc>
            url: <relative-path.md>
      - linkListType: sample
        links:
          - text: <Related sample or quickstart>
            url: <relative-path.md>
```

### 7. Add cross-references from related docs

New files don't exist in isolation. Integrate the new file into the existing docs:

- [ ] Check **`overview.md`** — Does it mention the category this file belongs to? If so, add the new file or update the text.
- [ ] Check the **section's parent overview** (e.g., `mcp/overview.md`, `concept/security/authenticate-overview.md`) — Add a cross-reference in its "Related content" section.
- [ ] Check **peer files** in the same folder — Do they have "Related content" or "Next step" sections? Add reciprocal links where appropriate.
- [ ] Check if any existing doc **should link to** the new file inline (e.g., a deployment doc mentioning a hosting option that now has its own page).

### 8. Add include files (if needed)

If the new file needs shared content:

- [ ] Check `includes/` folders for existing include files that apply.
- [ ] Reference includes with: `[!INCLUDE[<description>](<relative-path-to-include>)]`
- [ ] If creating a new include, place it in the nearest `includes/` folder.

### 9. Verify peer consistency

Before finishing, compare the new file against its peers in the same folder:

- [ ] **Frontmatter pattern** — Does the YAML frontmatter match the same fields and format as peer files?
- [ ] **Section structure** — Does the heading structure follow the same pattern as peer files?
- [ ] **Prerequisites format** — Are prerequisites listed consistently with peers?
- [ ] **Clean-up section** — If peers have a "Clean up resources" section, include one.
- [ ] **Related content / Next step** — Match the pattern used by peers (bullet list vs. nextstepaction).
- [ ] **Image pattern** — If peers use map SVGs or architecture diagrams, include equivalent images.
- [ ] **Intro paragraph** — If peers have a "This guide shows you how to..." intro paragraph between the heading and prerequisites, include one.

### 10. Final verification

- [ ] Run `Get-Errors` or equivalent on the new file — no warnings or errors.
- [ ] Grep for any broken references to the new file across `TOC.yml`, `index.yml`, and `.md` files.
- [ ] Confirm the file renders correctly in a local preview if available.

## Naming conventions

### File names

- Use **lowercase kebab-case**: `azure-app-service.md`, `authenticate-entra.md`.
- Do not use abbreviations in filenames (use `azure-container-apps.md`, not `aca.md`).
- Files in `command-line/` use the `dab-` prefix: `dab-init.md`, `dab-add.md`.
- Files everywhere else do NOT use prefixes like `how-to-` or `dab-`.
- Match the Azure service name when applicable: `azure-container-apps.md`, `azure-kubernetes-service.md`.

### Media folders

- Media folders match their parent file's name (without `.md`).
- Example: `deployment/azure-app-service.md` → `deployment/media/azure-app-service/`.
- Each doc gets its own subfolder — do not share media folders between docs.
- If two docs need the same image, **copy** it into each doc's subfolder. Do not share paths.

### Display names in TOC

- Use the short service name: "App Service (code)", "Container Apps (Portal)", "Container Instances".
- Add `displayName` keywords for search: `displayName: azure, app service, publish, deploy, code`.

## Common patterns by folder

### `deployment/` files

```text
# Deploy Data API builder to <Service Name>

![map SVG](media/<folder>/map.svg)

This guide shows you how to deploy Data API builder (DAB) to <Service Name> using...

![architecture SVG](media/<folder>/deploy-<name>.svg)

## Prerequisites
## Build the configuration file
## <Service-specific setup steps>
## Deploy to <Service Name>
## Verify the deployment
## Clean up resources
## Related content (or ## Next step)
```

### `mcp/` files

Follow the patterns in existing MCP quickstart and how-to files.

### `concept/` files

Concept files explain "what" and "why" rather than step-by-step "how". They typically have:
- An overview section
- Conceptual explanation with diagrams
- Configuration examples
- Related content links

### `whats-new/` files

Use the `dab-whats-new` skill for these files.

## Procedure

1. **Plan** — Identify the target folder, peer files, and integration points (TOC, index.yml, cross-references).
2. **Create** — Write the file with correct frontmatter, content, and images.
3. **Integrate** — Update TOC.yml, folder index.yml, and cross-references.
4. **Verify peers** — Compare against peer files for consistency.
5. **Review** — Spin up a sub-agent using a different model to review the work for accuracy, style, links, and peer consistency. Implement valid feedback.
6. **Audit** — Use the `dab-docs-audit` skill for a final compliance check against Microsoft Learn publishing requirements.
7. **Final check** — Grep for broken references and validate all YAML files.

Always complete all steps before reporting the file as done.
