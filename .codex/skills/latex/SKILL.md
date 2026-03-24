---
name: latex
description: Create, edit, and compile LaTeX documents. Use when working with .tex files, fixing LaTeX compilation errors, or preparing TeX sources for reliable builds, including Scientific WorkPlace (SWP) compatibility issues.
---

# LaTeX Skill

## Purpose
Produce compilable LaTeX sources and resolve common build failures quickly.

## Core Rules
- Check for `\input{tcilatex}` before every compilation.
- If present, comment it out as `% \input{tcilatex}` unless the user explicitly requires SWP-only compatibility.
- For slides, always use Beamer (`\documentclass{beamer}`).
- In prose, avoid em dashes; prefer commas, periods, or parentheses for cleaner, less AI-stylized writing.
- Keep edits minimal and preserve document semantics.
- Prefer targeted fixes for compiler errors rather than broad rewrites.

## SWP Note
Scientific WorkPlace (SWP) may inject `\input{tcilatex}`. In standard LaTeX environments this often fails because `tcilatex.tex` is not available. Default action: comment out that line, then compile.

## Output Style
- Return runnable LaTeX edits.
- State exactly what was changed to restore compilation.
