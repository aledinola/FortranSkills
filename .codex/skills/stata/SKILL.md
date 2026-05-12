---
name: stata
description: Work with Stata projects, `.do` files, logs, help files, and bundled manuals. Use when Codex needs to create or edit Stata scripts, run Stata from Windows PowerShell, inspect `.dta`-based workflows, or locate documentation shipped with the local Stata installation.
---

# Stata

## Overview

Use this skill for Stata work in a Windows environment with a local desktop installation. Stata is a command-driven package for data management, statistics, econometrics, and reproducible analysis; most project automation lives in plain-text `.do` files.

Read [environment.md](references/environment.md) for machine-specific execution details and [documentation.md](references/documentation.md) when you need the installed manuals or help-file locations.

## Quick Start

Follow this workflow:

1. Identify the target `.do` file, expected inputs, and working directory.
2. Edit the `.do` file as plain text, keeping commands explicit and reproducible.
3. Run it from PowerShell with the local Stata executable when the user wants execution or verification.
4. Read the generated `.log` file and any output artifacts before concluding that the run succeeded.

In this environment, prefer command discovery first:

```powershell
$stata = (Get-Command StataSE-64.exe -ErrorAction SilentlyContinue).Path
if (-not $stata) { $stata = 'C:\Program Files\StataNow19\StataSE-64.exe' }

$p = Start-Process -FilePath $stata `
  -ArgumentList '/e do "C:\full\path\to\script.do"' `
  -PassThru -Wait
$p.ExitCode
```

The verified fallback path on this machine is:

```powershell
$p = Start-Process -FilePath 'C:\Program Files\StataNow19\StataSE-64.exe' `
  -ArgumentList '/e do "C:\full\path\to\script.do"' `
  -PassThru -Wait
$p.ExitCode
```

Expect Stata to write `script.log` next to `script.do` in batch mode.

## Create Or Edit Do-files

Treat `.do` files as the primary automation surface:

- Write them as ASCII or UTF-8 plain-text files.
- Prefer one command per line unless the file already uses `#delimit ;`.
- Preserve the project's existing Stata version/style when it is already established.
- Keep paths quoted when they may contain spaces.
- Use comments sparingly and only where the analysis flow is hard to infer.

For new scripts, prefer a predictable skeleton like:

```stata
version 18.0
clear all
set more off
capture log close
log using "path\to\run.log", text replace

* analysis steps here

log close
exit, clear
```

If the task is interactive rather than batch-oriented, Stata can run scripts from inside the GUI with:

```stata
do "C:\full\path\to\script.do"
```

Use `run` instead of `do` when you want quieter execution from inside Stata.

## Validate Runs

After editing or creating a `.do` file:

1. Run it with the PowerShell batch command from [environment.md](references/environment.md) when execution is feasible.
2. Check the exit code and read the `.log` file.
3. Look for the final `end of do-file` marker and any `r(...)` error codes in the log.
4. Confirm expected output files were created or updated.

Do not assume success from process exit alone if the log shows Stata errors.

## Use Installed Documentation

Prefer the local installation before browsing elsewhere. Start with:

- `help do`
- `help doedit`
- `help log`
- `help use`
- `search <topic>`

Use [documentation.md](references/documentation.md) for local manual paths. In this installation, the most relevant bundled data documentation is the Data Management Reference Manual at `C:\Program Files\StataNow19\docs\d.pdf`.

When you need help-file source locations, remember that Stata help files live under `C:\Program Files\StataNow19\ado\base\` as `.sthlp` files.

Prefer this token-efficient documentation workflow:

1. Check the relevant `.sthlp` file first because it is much lighter than a PDF and often names the exact manual section.
2. Use `.sthlp` files or `help/search` output to identify the command or manual section before opening any PDF.
3. If `pdftotext` is available, extract only the relevant pages with it; do not read whole manuals into context.
4. If Pandoc is available, use it only on the small extracted snippet to normalize it into Markdown for easier reading, summarization, or quoting.
5. If the PDF has tables, columns, or poor text extraction, use `pdfplumber` from Python to pull only the needed pages, text blocks, or tables.

If Pandoc and `pdftotext` are installed, the practical pattern is:

```powershell
pdftotext -f 120 -l 123 -layout "C:\Program Files\StataNow19\docs\d.pdf" "snippet.txt"
pandoc -f markdown -t gfm "snippet.txt" -o "snippet.md"
```

If keyword search across extracted snippets is needed, use `rg` on `.txt` or `.md` files. There is no native `pdfgrep` installation in this environment.

Then read `snippet.md` or summarize it instead of touching the full PDF again.

## Practical Notes

- Respect the project's working directory assumptions before running a script.
- Expect Windows paths with spaces and quote them consistently.
- Prefer reproducible batch runs for verification because they leave a `.log` artifact.
- If a run depends on user-specific globals, local drives, or network shares, inspect the `.do` file before executing it.
- Avoid loading entire Stata manuals into context when a `.sthlp` file, a 1-3 page extracted snippet, or a targeted `pdfplumber` extraction will answer the question.
