# Documentation

## Bundled PDF Manuals

Stata's installed PDF manuals are in:

`C:\Program Files\Stata18\docs`

Useful manuals in this installation:

- Data Management Reference Manual: `C:\Program Files\Stata18\docs\d.pdf`
- User's Guide: `C:\Program Files\Stata18\docs\u.pdf`
- Base Reference Manual: `C:\Program Files\Stata18\docs\r.pdf`
- Getting Started with Stata for Windows: `C:\Program Files\Stata18\docs\gsw.pdf`

When a request is about data import, cleaning, reshaping, merging, appending, variable labels, or storage formats, start with `d.pdf`.

## Installed Help Files

Stata help files are installed as `.sthlp` files under:

`C:\Program Files\Stata18\ado\base`

Examples:

- `C:\Program Files\Stata18\ado\base\d\do.sthlp`
- `C:\Program Files\Stata18\ado\base\d\doedit.sthlp`
- `C:\Program Files\Stata18\ado\base\c\contents_utilities_basic.sthlp`

Those help files reference important manual sections, including:

- `[U] 16 Do-files`
- `[GSW] 13 Using the Do-file Editor---automating Stata`

## Token-Efficient Workflow

Do not load raw Stata PDFs into context unless there is no lighter route.

Prefer this order:

1. Use `help <command>` inside Stata for the fastest command-level answer.
2. Use `search <topic>` inside Stata if the command name is uncertain.
3. Inspect `.sthlp` files on disk when you need a file path, a manual-section label, or a compact source.
4. Open the PDF manual only after narrowing the scope to a specific section or a few pages.

## Use Pandoc, pdftotext, and pdfplumber Efficiently

Available tools in this environment:

- Pandoc: `C:\Users\aledi\AppData\Local\Pandoc\pandoc.exe`
- `pdftotext`: `C:\Users\aledi\AppData\Local\Programs\MiKTeX\miktex\bin\x64\pdftotext.exe`
- `pdfinfo`: `C:\Users\aledi\AppData\Local\Programs\MiKTeX\miktex\bin\x64\pdfinfo.exe`
- Python `pdfplumber`: installed in the active Python environment

`pdfgrep` is not installed natively on this Windows machine, so treat `rg` over extracted `.txt` or `.md` snippets as the practical substitute.

Pandoc does not accept PDF as an input format here, so do not point it at `d.pdf`, `u.pdf`, or other full Stata manuals directly.

Instead:

1. Identify the needed pages or section from `.sthlp` or the Stata help system.
2. If the layout is simple, extract only those pages with `pdftotext`.
3. Convert the extracted snippet into Markdown with Pandoc when Markdown is easier to inspect or summarize.
4. If the extraction is messy because of layout, use `pdfplumber` to pull only the needed text blocks or tables.
5. Search extracted snippets with `rg` instead of repeatedly reopening the PDF.

Example with `pdftotext` and Pandoc:

```powershell
pdftotext -f 120 -l 123 -layout "C:\Program Files\Stata18\docs\d.pdf" "snippet.txt"
& 'C:\Users\aledi\AppData\Local\Pandoc\pandoc.exe' -f markdown -t gfm "snippet.txt" -o "snippet.md"
```

Example with `pdfplumber`:

```powershell
@'
import pdfplumber
from pathlib import Path

pdf_path = Path(r"C:\Program Files\Stata18\docs\d.pdf")
out_path = Path("snippet.txt")

with pdfplumber.open(pdf_path) as pdf:
    text = pdf.pages[119].extract_text()  # page 120 in the manual

out_path.write_text(text or "", encoding="utf-8")
'@ | python -
```

Use `pdfplumber` when page layout matters, not as the default first pass.

## Search Strategy

When local documentation is needed:

1. Find the command and manual family from `help` or `.sthlp`.
2. Narrow to the smallest relevant PDF section or page range.
3. Use `pdftotext` for simple extraction or `pdfplumber` for layout-sensitive extraction.
4. Use Pandoc on the extracted text if Markdown would be easier to inspect or reuse.
5. Search the extracted snippets with `rg`.
