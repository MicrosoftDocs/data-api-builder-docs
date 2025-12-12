# Microsoft Learn errors to avoid (agent)

This is a quick checklist of common Learn build/review failures that show up during PR validation.

## Links

- Don’t use absolute Learn links like `https://learn.microsoft.com/...` (use site-relative `/...`).
- Don’t pin locales in Microsoft URLs (remove `/en-us/` and similar).
- Don’t use `?view=...` without `&preserve-view=true`.

## Images

- Don’t leave image alt text empty (`![](...)`).
- Don’t reuse the same alt text for multiple images in one article.
- Don’t use the image filename as the alt text.

## Markdown

- Don’t leave fenced code blocks unclosed.
- Don’t use indented code blocks; use fenced blocks with a language.

## Headings

- Don’t put content before the H1.
- Don’t duplicate H2 headings within a page.

Use `learn-build-rulebook.md` for the rule meanings and fixes, and run `preflight.ps1` before pushing.
