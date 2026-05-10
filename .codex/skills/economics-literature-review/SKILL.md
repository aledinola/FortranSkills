---
name: economics-literature-review
description: Structure literature searches and produce paper summaries and literature syntheses for economics topics. Use when Codex needs to map a research area, find recent and high-quality economics papers, summarize individual papers, compare findings across studies, or identify gaps in the economics literature using reputable sources such as JSTOR, EconLit, Google Scholar, RePEc/IDEAS, and NBER.
---

# Economics Literature Review

Structure the task around one of three outputs: a search plan, paper summaries, or a synthesis.

Start by identifying the economics topic, the exact research question, the outcomes of interest, the population or setting, and any preferred methods, countries, or time periods. If the request is underspecified, make a reasonable first-pass scope and state the assumptions.

## Workflow

### 1. Define the review scope

Extract or infer:
- Topic and subfield
- Core research question
- Main outcomes
- Population, geography, and period
- Preferred empirical methods, if any
- Whether the user needs a quick scan, annotated bibliography, or full synthesis

Turn the scope into search blocks:
- Topic terms and close synonyms
- Outcome terms
- Method terms
- Geography or sample restrictions
- Exclusion terms for common false positives

### 2. Search reputable databases first

Prioritize these sources:
- `EconLit` for field-specific indexing
- `NBER` for recent working papers and frontier research
- `Google Scholar` for broad coverage and citation tracing
- `RePEc/IDEAS` for economics-specific discovery, working-paper versions, and citation trails
- `JSTOR` for established journal articles and older foundational work

Prefer recent papers over older ones unless the older paper is clearly seminal or necessary for context. Start with the last 5 to 10 years, then add classic references only if they anchor the literature.

Do not broaden to lower-quality sources unless the user asks. If a paywalled database or paper requires access beyond the current environment, pause and request permission before proceeding.

Use search strings that combine topic, outcome, and method. Examples:
- `"maternal labor supply" AND childcare AND "difference-in-differences"`
- `"child penalty" AND earnings AND Denmark`
- `"minimum wage" AND employment AND monopsony`

### 3. Rank and filter the search results

Favor papers that satisfy more of the following:
- Published recently
- Appearing in strong economics journals
- Written by authors with strong records in the field
- Affiliated with highly ranked economics departments, policy schools, or research institutes
- Using credible empirical identification or rigorous theory
- Frequently cited relative to publication year
- Closely matching the user's question rather than only the broader topic

Do not treat prestige as proof of correctness. Use it as a prioritization device, then assess the actual method and contribution.

If the result set is large, triage in passes:
1. Screen titles and outlets
2. Read abstracts and introductions
3. Keep the closest and strongest papers
4. Use backward and forward citation tracing to fill gaps

### 4. Summarize papers in a consistent format

For each paper, extract:
- Full citation
- Research question
- Main research method or identification strategy
- Data or sample
- Main findings
- Contribution to the literature
- Important limitations or scope conditions
- Relevance to the user's question

Prefer precise, economics-style summaries over generic prose. Distinguish clearly between descriptive evidence, causal claims, structural estimates, theory, and policy implications.

Use this template:

```markdown
## [Author last names] ([Year])

**Citation:** [Full citation]
**Question:** [One sentence]
**Method:** [One sentence]
**Data/Sample:** [One or two lines]
**Findings:** [2-4 bullets or short sentences]
**Contribution:** [Why this paper matters in the literature]
**Limits:** [Main caveat]
**Relevance:** [Connection to the user's topic]
```

### 5. Synthesize across papers

When multiple papers are in scope, organize the synthesis around:
- Core research questions
- Main methods
- Areas of agreement
- Areas of disagreement
- Sources of heterogeneity
- How the literature has evolved over time
- What remains unresolved

Make the synthesis comparative, not sequential. Group papers by question or method instead of listing one summary after another.

Explicitly note:
- Whether the literature has a consensus
- Whether differences come from data, setting, identification, sample, or period
- Which papers are most central for a newcomer
- Which papers are most relevant for the user's specific project

### 6. Produce the right final format

Adapt the output to the request:
- For a search request: provide databases, search strings, inclusion criteria, and a prioritized reading list
- For paper summaries: provide concise structured summaries
- For a literature review: provide a thematic synthesis and a short list of open questions or research gaps

If useful, read [references/economics-search-guidance.md](references/economics-search-guidance.md) for additional source and quality heuristics.

## Guardrails

- Stay within reputable databases unless the user asks to expand.
- Request permission before using paywalled access routes or tools that need credentials or paid subscriptions.
- Prefer recent papers, but include seminal older papers when needed for context.
- Prefer strong economics journals and strong institutions as a screening heuristic, not as a substitute for reading the paper.
- Do not overstate causality when the design does not support it.
- Surface contradictory findings instead of forcing a false consensus.

## Output patterns

### Search plan

```markdown
# Literature Search Plan: [Topic]

## Scope
[Question, outcomes, population, period]

## Databases
- EconLit
- NBER
- Google Scholar
- RePEc/IDEAS
- JSTOR

## Search strings
- [Query 1]
- [Query 2]
- [Query 3]

## Inclusion criteria
- [Criterion]

## Priority papers to screen
1. [Paper]
2. [Paper]
3. [Paper]
```

### Literature synthesis

```markdown
# Literature Review: [Topic]

## Research questions
- [Question cluster]

## Main methods
- [Method cluster]

## What the literature finds
- [Finding with brief support]

## Points of disagreement
- [Disagreement and likely reason]

## Main contributions in the literature
- [Contribution]

## Gaps
- [Gap]
```


