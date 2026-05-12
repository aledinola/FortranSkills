---
name: economics-referee-report
description: "Draft referee reports for economics and closely related academic papers from PDF manuscripts. Use when Codex needs to read a paper PDF, extract text with pdfplumber, optionally normalize extracted notes with pandoc, and produce a referee report with three sections: (1) overview and overall assessment, (2) major comments, and (3) minor comments."
---

# Economics Referee Report

Follow this workflow when asked to review an economics paper, especially from a PDF manuscript.

## Reviewer Perspective

Write from the user's actual research background rather than from a generic economist perspective.

The user's comparative strengths are:

- Quantitative dynamic macro.
- Structural labor economics.
- Heterogeneous-agent models in partial and general equilibrium.
- Financial frictions.
- Fiscal policy.
- Search and matching models.
- Labor market policy.
- Applied micro methods at the level of implementation, identification, and how methods should be used in practice.

Use that background to sharpen comments on:

- Dynamic model structure and discipline.
- Structural assumptions and identification.
- Mechanisms in quantitative models.
- Calibration, estimation, and counterfactual design.
- Labor-market institutions, policies, and search frictions.
- Whether empirical work supports the mechanisms claimed in the model.

Be more cautious in areas outside that background. In particular, do not overstate authority on advanced econometric theory beyond identification, design, and applied implementation. If a paper turns on specialized econometric theory or other technical areas outside the user's core expertise, keep the comment modest, conditional, and focused on what can be assessed credibly.

## Quick Start

1. Locate the paper PDF and identify whether the user wants a full referee report or a lighter set of comments.
2. Identify the journal of submission and infer its level from the journal's ranking, field standing, and recent publications.
3. Run [`scripts/extract_paper_text.py`](./scripts/extract_paper_text.py) to extract page-by-page text with `pdfplumber`.
4. Review the extracted markdown to locate section boundaries, tables, figures, appendices, and the paper's core claims.
5. If the extracted markdown needs cleaner wrapping for reading or quoting, normalize it with `pandoc`.
6. Read the paper's own literature review section and also perform an independent literature review to assess whether the paper is appropriately positioned in the literature.
7. If the installed skill `economics-literature-review` is available, use it for the independent literature review step.
8. Compare the paper to other papers recently published in the submission journal and calibrate the recommendation to that journal-specific standard.
9. Draft the report using the structure in [`references/report-guidelines.md`](./references/report-guidelines.md).
10. Write the final referee report in LaTeX and follow the installed `latex` skill when preparing the `.tex` output.

## Extraction Workflow

Use `pdfplumber` as the primary extraction path when reading a paper PDF.

### 1. Extract full text with `pdfplumber`

Use the helper script:

```powershell
python <codex-home>\skills\economics-referee-report\scripts\extract_paper_text.py <absolute-path-to-paper.pdf>
```

The script creates a markdown file with page markers and a JSON diagnostics file. Resolve `<codex-home>` to `$env:CODEX_HOME` when it is set, otherwise use `%USERPROFILE%\.codex`. Read the markdown file rather than the raw PDF tool output when possible.

If the PDF has severe OCR or layout issues, say so explicitly in the report and avoid pretending that you verified details you could not read confidently.

### 2. Normalize only when helpful with `pandoc`

If the extracted markdown is difficult to scan because of line breaks or hyphenation, normalize it:

```powershell
pandoc extracted-paper.md -f gfm -t plain -o extracted-paper.txt
```

Use `pandoc` as a cleanup step, not as a substitute for the primary extraction.

## Literature Positioning Workflow

Do not rely only on the paper's own literature review. An independent literature review is part of the referee task.

### 1. Read the paper's literature review critically

Identify:

- Which papers the authors present as the closest antecedents.
- What they claim is novel relative to the literature.
- Which literatures they engage and which they omit.
- Whether the comparison set is too narrow, outdated, or strategically chosen.

### 2. Do an independent literature review

Use the installed `economics-literature-review` skill when available. Use it to:

- Map the closest papers and adjacent literatures.
- Check whether more recent or more relevant papers are missing.
- Assess whether the claimed innovation is genuinely new, incremental, or overstated.
- Compare the paper's method, identification, model, structural approach, or data contribution against the closest papers.

If that skill is not available, still do an independent review using reputable economics sources and state any limits of the search.

### 3. Feed the literature review into the referee report

Use the independent literature review to inform:

- The overview's discussion of contribution and innovation.
- Major comments about novelty, framing, or overstatement when the literature comparison materially changes the evaluation.
- Requests for additional references or sharper comparisons when those omissions matter for the paper's claims.

Do not treat fit with the literature as a default major comment category. Raise it only when it materially affects the assessment of contribution, novelty, or correctness.

Do not complain in a generic way that the references are outdated or incomplete. Raise a reference issue only when there is an important missing paper, and then name the paper and explain why it matters for the contribution claim, comparison set, or interpretation.

## Journal Standard Workflow

Base the overall assessment and the recommendation on the standard of the submission journal, not on an abstract absolute threshold.

### 1. Identify the journal benchmark

Determine the likely quality bar implied by the journal's ranking, field reputation, and audience.

### 2. Compare against recent publications in that journal

Compare the paper to other papers recently published in the submission journal, especially on:

- Novelty and importance of the question.
- Credibility of the empirical or theoretical method.
- Depth of analysis and completeness of evidence.
- Match to the journal's style, audience, and typical contribution size.

### 3. Calibrate the recommendation to the journal

Use only these recommendation categories:

1. `Revise and resubmit`
2. `Accept with minor revision`
3. `Rejection`

`Revise and resubmit` and `Rejection` should be the most common outcomes. Use `Accept with minor revision` rarely, only when the paper is very close to publishable and the remaining changes are genuinely limited.

## Writing Rules

Use an academic referee tone that matches the user's writing style. Keep the prose direct, plain, fairly dry, and not overly polished. Use American English rather than British English.

- Write the final output in LaTeX and follow the installed `latex` skill when preparing the `.tex` file.
- Produce compilable LaTeX, keep edits minimal, avoid em dashes in prose, and check for `\input{tcilatex}` before compilation.
- Match the user's fluent academic style rather than sounding edited by a copyeditor.
- Use American spelling and usage.
- Preserve a slightly dry academic tone. Do not make the prose sound glossy, overly smooth, or performatively polished.
- Clean up only as much as needed for clarity and grammatical correctness. Avoid over-correcting subtle phrasing in a way that changes the user's voice.
- Keep the overall assessment short and relatively positive in tone, even if the recommendation is negative.
- Explain the paper's contribution, its main innovation relative to the literature, and its main weaknesses.
- Base the assessment of contribution and novelty on both the paper's own literature review and an independent literature review.
- Base the overall assessment and recommendation on the ranking and standard of the submission journal, comparing the paper to other papers recently published there.
- Use only these recommendation labels: `Revise and resubmit`, `Accept with minor revision`, or `Rejection`.
- Treat `Revise and resubmit` and `Rejection` as the default outcomes. Use `Accept with minor revision` rarely.
- Let the report reflect the user's strengths in quantitative dynamic macro, structural labor, heterogeneous-agent models, search and matching, fiscal policy, labor-market policy, and applied identification-based reasoning.
- Be more restrained in areas outside the user's expertise, especially specialized econometric theory beyond identification and applied implementation.
- Calibrate the number of major comments to the recommendation.
- For `Revise and resubmit`, include more major comments when needed, with the upper bound increasing to `10` for especially complex papers.
- For `Accept with minor revision` or `Rejection`, use fewer major comments and focus only on the most important points.
- Keep each major comment heading short, usually a few words rather than a full sentence.
- Minor comments do not require headings.
- Make every major comment actionable: each one must include at least one concrete suggestion for how the authors could address it.
- When it helps make the point clearer, a major comment may include an equation, table, or figure drawn from the paper being refereed or from the relevant literature.
- A major comment may contain multiple parts or subpoints. Some parts can be more important than others, but the structure should make the ranking of importance clear.
- Reserve minor comments for issues that are easy to fix, but do not include comments on data statements.
- For typos or copy-editing, mention only errors that materially affect the meaning of key sections, equations, results, or interpretation.
- Do not include comments on trivial typos, minor wording, or small reference-format issues.
- Do not complain about encoding problems, since these may arise from PDF conversion rather than from the original paper.
- Do not complain in a generic way that references are outdated or incomplete. Mention references only when an important missing paper should be added, and explain why it matters.
- Do not invent claims about results, proofs, or robustness checks that were not visible in the paper.
- If the report cites any papers, include a references section listing all cited papers.
- Flag uncertainty when equations, tables, appendices, or figures could not be read cleanly from the PDF.

## Optional Critical Patterns

Use the following patterns only when they are genuinely relevant to the paper. Do not force them into every report.

- Theoretical assumptions: ask whether a key assumption is plausible, whether it drives the main results, and whether the paper should provide either a robustness check or an argument about external validity.
- Identification: ask whether the identification strategy is clear and correct, and whether the tests or supporting evidence used to validate identification are appropriate.
- Alternative mechanisms or algorithms: ask whether a result could be driven by a different mechanism, algorithm, or procedure than the one emphasized in the paper, and how the authors rule out or address those alternatives.

## Report Structure

Always use these top-level sections:

1. `Overview and Overall Assessment`
2. `Major Comments`
3. `Minor Comments`
4. `References` if any papers are cited in the report

Read [`references/report-guidelines.md`](./references/report-guidelines.md) before drafting the final report. It contains the expected section content and style constraints.
