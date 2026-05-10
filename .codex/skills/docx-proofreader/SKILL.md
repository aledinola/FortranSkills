---
name: docx-proofreader
description: Proofread, analyze, and safely modify Microsoft Word .docx documents, especially academic reflective writing, application forms, assignments, and templates with section word or character limits. Use when Codex needs to extract Word document text, read surrounding instruction files for context, count words by section, check author-date references against in-text citations, verify that cited references exist, produce a proofread copy, or apply paragraph-level edits while preserving the original document.
---

# DOCX Proofreader

## Purpose

Use this skill for careful Word-document proofreading where correctness depends on structure: assignment instructions, section word limits, citations, references, and preserving the original `.docx`.

## Default Workflow

1. Identify the target `.docx` and read nearby instruction/context files first (`.txt`, `.md`, `.pdf`, `.pptx`) when relevant.
2. Extract numbered paragraphs with `powershell -ExecutionPolicy Bypass -File scripts/docx_text.ps1 extract <file.docx>`.
3. Count candidate sections with `powershell -ExecutionPolicy Bypass -File scripts/docx_text.ps1 count <file.docx> -Ranges "Name=6-8;Other=12-14"` after mapping paragraph numbers to section boundaries.
4. Check reference hygiene with `powershell -ExecutionPolicy Bypass -File scripts/docx_refs.ps1 <file.docx>`.
5. Verify external references with web search when the user requests existence checks or when bibliographic details look uncertain. Prefer publisher pages, DOI pages, university repository records, library catalogues, or official course materials.
6. Make edits to a copy unless the user explicitly asks to overwrite the original. Prefer a filename such as `<stem> proofread.docx`.
7. Apply paragraph-level replacements with `powershell -ExecutionPolicy Bypass -File scripts/docx_replace.ps1 <source.docx> <output.docx> -ReplaceJson replacements.json` when the edits are deterministic. For extensive prose edits, still inspect the extracted text before and after.
8. Re-extract and recount the edited copy. Report final counts and any reference decisions.

## Editing Rules

- Preserve the original document by default.
- Keep the author's voice; tighten only enough to satisfy limits and clarity.
- Remove bibliography entries that are not cited unless the user asks to keep background reading.
- Add references for local/course materials when the text explicitly cites them and no bibliography entry exists.
- Do not invent bibliographic details. If a reference cannot be verified, flag it.
- If editing XML directly, avoid touching unrelated OOXML parts.

## Scripts

- `scripts/docx_text.ps1`: extract paragraphs, count words/characters by paragraph ranges, and extract PPTX slide text for context.
- `scripts/docx_refs.ps1`: compare author-year in-text citations with reference-list entries and flag likely uncited references or missing references.
- `scripts/docx_replace.ps1`: create an edited copy by applying exact paragraph-text replacements from a JSON mapping.

## Notes

Word counts are approximations based on regex tokenization, suitable for assignment-limit checks. If exact Microsoft Word counts matter, say that Word may differ slightly and recommend the document's built-in count as the final authority.

