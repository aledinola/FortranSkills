---
name: pdf-reading-efficiently
description: Read and extract information from PDF files efficiently on this Windows PC using Poppler, ripgrep, and Python PDF libraries. Use when Codex needs to inspect a PDF, pull text quickly, read metadata/page counts, render pages for visual debugging, extract layout-aware text or tables, or batch-process PDFs.
---

# PDF Reading Efficiently

Use the fastest tool that preserves the structure needed for the task. Prefer a quick Poppler probe first for diagnostics, simple text, and keyword search. Escalate to Python when page-level control, cleaner layout, table extraction, repeated structured processing, or custom scripts will save time.

## Installed Tools On This PC

- Poppler 26.02.0 is installed at `C:\Program Files\Poppler\Library\bin`.
- Use `pdftotext` for fast plain-text extraction from digital PDFs.
- Use `pdfinfo` for metadata, page count, page size, encryption status, and basic PDF diagnostics.
- Use `pdftoppm` for rendering pages to PNG/JPEG/PPM when visual inspection helps.
- ripgrep 15.1.0 is installed at `C:\Program Files\ripgrep\rg.exe`; use it to search extracted `.txt` files quickly.
- The machine PATH includes both install folders, but in a long-running Codex session prefer explicit paths if `rg` resolves to the blocked Codex-bundled executable.
- Python 3.14.4 is installed at `C:\Program Files\Python314\python.exe` and is available through the launcher command `py`.
- The tested PDF Python libraries are installed and import successfully: `pdfplumber 0.11.9`, `PyMuPDF 1.27.2.3` (`import fitz`), and `pypdf 6.11.0`.
- These Python packages are in the user site at `C:\Users\aledi\AppData\Roaming\Python\Python314\site-packages`, which is normal with a protected machine-wide Python install. Use `py -c ...` or `py -m ...`; do not rely on package console scripts being on PATH.

## Tool Choice

- Use `pdfinfo` first when page count, encryption, page size, metadata, or basic diagnostics matter.
- Use `pdftotext` first when the task is quick reading, a rough text dump, or keyword search on a born-digital PDF.
- Use `rg` on extracted text when repeated lookup is needed.
- Use `pdftoppm` when visual inspection matters, extraction is empty, or the PDF may be scanned.
- Use `PyMuPDF` for fast page-by-page text extraction, rendering, page counts, clipping regions, and scripts that need speed.
- Use `pdfplumber` when reading order, layout, words with coordinates, or table-like structure matters.
- Use `pypdf` for metadata, page counts, splitting, merging, rotation, and lightweight PDF manipulation. Do not use it as the primary text extractor unless the need is simple.
- Treat scanned PDFs as OCR problems. Poppler and PyMuPDF can render scanned pages, but OCR requires separate OCR tooling such as Tesseract, which is not part of this tested setup.

## Workflow Decision Tree

1. Determine whether the task needs plain text, metadata/page count, keyword search, or rendered pages.
2. Run `pdfinfo` for basic diagnostics when useful, especially before deeper work on an unfamiliar PDF.
3. Start with `pdftotext` if the goal is quick reading or keyword search on a digital PDF.
4. Save extracted text to a temporary `.txt` file and search it with `rg` if repeated lookup is needed.
5. If the output is good enough, stop there; Poppler is usually the fastest path.
6. If text order, spacing, tables, or page-level control matter, use Python:
   - `PyMuPDF` for speed and page-level operations.
   - `pdfplumber` for layout-aware text and tables.
   - `pypdf` for PDF structure and page manipulation.
7. Use `pdftoppm` or `PyMuPDF` rendering for relevant pages when text extraction is empty, suspicious, or insufficient.
8. Treat scanned PDFs as OCR problems and say so explicitly.

## Quick Commands

### Fast Plain-Text Dump

```powershell
& "C:\Program Files\Poppler\Library\bin\pdftotext.exe" input.pdf -
```

Write to a text file for repeated search:

```powershell
& "C:\Program Files\Poppler\Library\bin\pdftotext.exe" input.pdf output.txt
& "C:\Program Files\ripgrep\rg.exe" "search phrase" output.txt
```

### Metadata And Page Count

```powershell
& "C:\Program Files\Poppler\Library\bin\pdfinfo.exe" input.pdf
```

### Render A Page For Visual Inspection

```powershell
& "C:\Program Files\Poppler\Library\bin\pdftoppm.exe" -f 1 -l 1 -png -singlefile input.pdf page1
```

### Fast Python Page Text With PyMuPDF

```powershell
py -c "import fitz; doc=fitz.open(r'input.pdf'); print(doc[0].get_text()); doc.close()"
```

### Layout-Aware Text With pdfplumber

```powershell
py -c "import pdfplumber; pdf=pdfplumber.open(r'input.pdf'); print(pdf.pages[0].extract_text()); pdf.close()"
```

### Page Count Or Structure With pypdf

```powershell
py -c "from pypdf import PdfReader; r=PdfReader(r'input.pdf'); print(len(r.pages)); print(r.metadata)"
```

## Heuristics

- Prefer `pdftotext` for speed when the PDF is born-digital and the only goal is readable text or search.
- Prefer `pdfinfo` for quick diagnostics before spending time on extraction.
- Prefer `PyMuPDF` when a Python script needs to touch many pages quickly or render selected pages.
- Prefer `pdfplumber` when the plain text dump loses useful layout, table-like rows, columns, or reading order.
- Prefer `pdftoppm` when a command-line render is enough, especially to diagnose scanned or visually complex pages.
- Prefer `pypdf` for page manipulation and metadata, not serious text reading.
- Use explicit `C:\Program Files\...` paths when PATH resolution is ambiguous inside Codex.
- For tables and complex layout, inspect `pdftotext` first only as a cheap probe, then move to `pdfplumber` or rendered pages if structure matters.

## Equation-Heavy PDFs

For economics papers and other PDFs with formal models, use text extraction to navigate, but use rendered pages to verify final equations.

- Use `pdftotext -layout` first to find pages containing terms such as `Bellman`, `s.t.`, `max`, `constraint`, `Euler`, or key state variables.
- Expect the extracted text layer to garble primes, Greek letters, summation limits, inequality symbols, and underlines/overlines.
- Render the relevant page with `pdftoppm` or `pdftocairo` before writing final equations to Markdown.
- Treat the rendered page as authoritative for exact math notation.
- For Markdown artifacts intended for VS Code preview, use `$...$` for short inline math such as `$a$`, `$c$`, and `$\tau$`; avoid `\(...\)` because it may not render reliably. Put formal expressions in fenced `math` display blocks.
- Save both the page-range text extraction and the rendered page image next to the Markdown output when the task is an extraction artifact.
- In the final answer, say that equations were verified visually when text extraction was imperfect.

## Common Failure Modes

- Empty or near-empty text output: suspect a scanned PDF or image-only pages.
- Jumbled reading order: compare `pdftotext`, `PyMuPDF`, and `pdfplumber`; render the page if the right interpretation is still unclear.
- Missing table structure: plain text extraction may be insufficient; use `pdfplumber` and rendered pages to inspect structure.
- Weird symbols or broken ligatures: compare `pdftotext` raw output against visual rendering.
- Python package console scripts may not be on PATH because packages were installed in the user site. Use `py -m ...` or `py -c ...`.

## Efficient Working Pattern

1. Run `pdfinfo` for basic diagnostics when useful.
2. Run a cheap first pass with `pdftotext`.
3. If that is good enough, search the result with `rg`.
4. If not, run a targeted Python extraction with `PyMuPDF` or `pdfplumber`.
5. Render the relevant pages when extraction quality is uncertain or the PDF may be scanned.
6. Delete temporary extracted text/images when the task is complete unless the user asks to keep them.

## Tested Setup

Last tested on 2026-05-10:

- `py -V` returned `Python 3.14.4`.
- `pdftotext` and `pdfinfo` returned Poppler `26.02.0`.
- `pdfplumber`, `PyMuPDF`, and `pypdf` imported successfully.
- A synthetic born-digital PDF was created with `PyMuPDF`.
- `pdfinfo` reported the test PDF correctly.
- `pdftotext` extracted searchable text.
- `pdfplumber` extracted cleaner layout text for the table-like rows.
- `PyMuPDF` extracted fast page text and preserved simple spacing.
- `pdftoppm` rendered the page to PNG.
- In a representative economics paper, `pdftotext -layout` quickly located a household Bellman equation, but rendered page inspection was needed to transcribe primes, Greek-letter primes, and inequality constraints reliably.
- For Markdown equation extracts opened in VS Code, `$...$` inline math rendered better than `\(...\)` delimiters.

## Output Style

When using this skill, report:

- which extractor or renderer was chosen
- why it was chosen
- any limitations noticed, especially if the PDF appears scanned or layout-heavy
- whether temporary files were cleaned up
