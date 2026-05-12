---
name: latex
description: Create, edit, and compile LaTeX documents. Use when working with .tex files, fixing LaTeX compilation errors, or preparing TeX sources for reliable builds, including Scientific WorkPlace (SWP) compatibility issues.
---

# LaTeX Skill

## Purpose
Produce compilable LaTeX sources and resolve common build failures quickly.

On Windows, `pdflatex` is expected to be available on `PATH` through MiKTeX or another TeX distribution. Use this discovery order only if `pdflatex` is not resolving in the current shell:
1. Try `pdflatex` on `PATH`.
2. If that fails, check with `Get-Command pdflatex -ErrorAction SilentlyContinue` or `where.exe pdflatex`.
3. Check common MiKTeX roots such as `%LOCALAPPDATA%\Programs\MiKTeX\miktex\bin\x64`, `%LOCALAPPDATA%\MiKTeX\miktex\bin\x64`, and `%APPDATA%\MiKTeX\miktex\bin\x64`.
4. Reuse any successfully discovered `pdflatex.exe` path immediately for the current build, quoting it when needed.
5. Only if no TeX engine is found after those checks should you limit the work to source fixes and say compilation was not verified.

## PDF Text Extraction
Use `pdftotext` for lightweight PDF text checks before falling back to Python PDF libraries.

Prefer the real Poppler `pdftotext.exe` installed under `C:\Program Files\Poppler\...\Library\bin` when available. Do not create or rely on a `pdftotext.cmd` shim.

Use this discovery order if `pdftotext` is needed:
1. Try `pdftotext` on `PATH`.
2. If that fails, check `Get-Command pdftotext -ErrorAction SilentlyContinue` and `where.exe pdftotext`.
3. If PATH is stale after a tool install, try the discovered full Program Files path directly.
4. Git's bundled executable at `C:\Program Files\Git\mingw64\bin\pdftotext.exe` can be used only as a diagnostic or temporary fallback, not as the preferred permanent setup.
5. Only after those fail should you use Python PDF-text extraction.

Do not say that the local shell does not expose `pdftotext` until checking the preferred Program Files Poppler path.

## Core Rules
- Check for `\input{tcilatex}` before every compilation.
- If present, comment it out as `% \input{tcilatex}` unless the user explicitly requires SWP-only compatibility.
- For slides, always use Beamer (`\documentclass{beamer}`).
- In prose, avoid em dashes; prefer commas, periods, or parentheses for cleaner, less AI-stylized writing.
- Keep edits minimal and preserve document semantics.
- Prefer targeted fixes for compiler errors rather than broad rewrites.

## SWP Note
Scientific WorkPlace (SWP) may inject `\input{tcilatex}`. In standard LaTeX environments this often fails because `tcilatex.tex` is not available. Default action: comment out that line, then compile.

## VS Code Note
If the user is building from VS Code LaTeX Workshop and the build fails through `latexmk` with a message about missing `perl` or a missing script engine, treat that as an editor recipe problem rather than a TeX-source problem. Prefer a workspace-level LaTeX Workshop recipe that uses `pdflatex` directly instead of `latexmk`, especially when `pdflatex` works but `latexmk` depends on a Perl engine that is not installed.

## Output Style
- Return runnable LaTeX edits.
- State exactly what was changed to restore compilation.
