---
name: pdf-reading-efficiently
description: Read and extract information from PDF documents efficiently on a Windows machine. Use when Codex needs to inspect PDFs, extract text or tables, search papers/manuals/reports, read metadata or page ranges, render pages for visual checks, repair or split difficult PDFs, or decide whether OCR is needed. Prefer Program Files tools such as Poppler, Pandoc, qpdf, and Tesseract, and check exact paths before use.
---

# PDF Reading Efficiently

Use the fastest tool that preserves the structure needed for the task. Prefer Poppler for quick diagnostics, text extraction, page-range extraction, rendering, and keyword search. Use Python only when it is installed under `C:\Program Files` and is better suited for the task, such as tables, metadata, page ranges, layout-aware extraction, or post-processing.

This skill incorporates the online workflow from `https://github.com/aledinola/FortranSkills/tree/main/.codex/skills/pdf-reading-efficiently`.

## Machine Tool Checks

Before using a tool, check its explicit path. Prefer installer-managed command-line tools under `C:\Program Files`; install Python packages through the active Python environment rather than depending on package console scripts.

Recommended Windows tool layout:

- Poppler 25.07.0 is installed at `C:\Program Files\Poppler\poppler-25.07.0\Library\bin`.
- `pdfinfo.exe`, `pdftotext.exe`, `pdftoppm.exe`, `pdftocairo.exe`, and `pdftohtml.exe` are available in that Poppler folder.
- Pandoc 3.9.0.2 is installed at `C:\Program Files\Pandoc\pandoc.exe`.
- Python 3.14.4 is installed at `C:\Program Files\Python314\python.exe`.
- `pdfplumber 0.11.9`, `PyMuPDF 1.27.2.3` (`import fitz`), and `pypdf 6.11.0` have been installed and imported successfully for Python 3.14.
- Python PDF packages may live in the Python user site when the machine-wide Python directory is protected; use the active `python -c ...` or `python -m ...` rather than package console scripts.
- Tesseract OCR 5.4.0 is installed at `C:\Program Files\Tesseract-OCR\tesseract.exe`.
- qpdf 12.3.2 is installed at `C:\Program Files\qpdf 12.3.2\bin\qpdf.exe`.
- If PATH does not see newly installed tools in a long-running shell, refresh the shell or rebuild `$env:Path` from Machine and User PATH.
- `C:\Program Files\ripgrep\rg.exe` is optional; Codex may also have another `rg` on PATH.
- Verify which `rg` is being used with `where.exe rg`; prefer a Program Files install if one exists.

Useful checks:

```powershell
Test-Path "C:\Program Files\Python314\python.exe"
Test-Path "C:\Program Files\Poppler\poppler-25.07.0\Library\bin\pdftotext.exe"
Test-Path "C:\Program Files\Pandoc\pandoc.exe"
Test-Path "C:\Program Files\Tesseract-OCR\tesseract.exe"
Test-Path "C:\Program Files\qpdf 12.3.2\bin\qpdf.exe"
& "C:\Program Files\Python314\python.exe" -c "import pdfplumber, fitz, pypdf; print('pdf libraries ok')"
where.exe pdfinfo
where.exe pdftotext
where.exe tesseract
where.exe qpdf
where.exe rg
```

If Python is missing, report that Python is unavailable before relying on Python PDF libraries.

## Tool Choice

- Use `pdfinfo` first when page count, encryption status, page size, metadata, or basic diagnostics matter.
- Use `pdftotext` first when the PDF is born-digital and the task needs plain text, a page range, or keyword search.
- Use `pdftotext -layout` for columns, tables, equations, captions, and page snippets where spatial layout matters.
- Use `rg` on extracted `.txt` files for repeated keyword search, but verify which `rg` is being used.
- Use `pdftoppm` or `pdftocairo` to render only relevant pages when visual inspection is needed, extraction is empty, or the PDF may be scanned.
- Use Pandoc only after extraction, and only to normalize small extracted snippets into Markdown or another text format. Do not treat Pandoc as the primary PDF extractor.
- Use Python libraries only when Program Files Python is installed and the task needs page-level scripting, tables, metadata, custom cleanup, or structured post-processing.
- Use qpdf when a PDF is malformed, encrypted, linearized, needs page splitting, needs attachment/object inspection, or should be repaired/normalized before extraction.
- Use OCR only as a last resort, and only when the PDF appears scanned or image-based after text extraction fails or returns near-empty output.

## Efficient Workflow

1. Identify the task: metadata, text, keyword search, page range, table extraction, image/render check, or OCR triage.
2. Check tool paths explicitly before running commands.
3. Run `pdfinfo` for unfamiliar PDFs when page count or document diagnostics might shape the extraction plan.
4. If embedded text exists, start with `pdftotext`; avoid Python for a simple first pass.
5. If only a page range or section is needed, extract only that range.
6. Save extracted text or tables to a file so the workflow is reproducible.
7. Search saved text with `rg` or PowerShell `Select-String`, then narrow to relevant pages or snippets.
8. Move to Python only when Poppler output is insufficient for layout, tables, metadata scripting, or post-processing.
9. Use qpdf before extraction when the PDF appears damaged, encrypted, or structurally unusual, or when page splitting/normalization will make the task smaller.
10. Render selected pages when extraction is empty, suspicious, equation-heavy, or layout-sensitive.
11. Use Tesseract OCR only after confirming that embedded text extraction is unavailable or unusable.
12. Report which tool was used, why, and where outputs were saved.

## Poppler Commands

Set the Poppler bin path in the shell when it makes commands clearer:

```powershell
$poppler = "C:\Program Files\Poppler\poppler-25.07.0\Library\bin"
```

Inspect metadata and page count:

```powershell
& "$poppler\pdfinfo.exe" "document.pdf" | Out-File -Encoding utf8 "document_pdfinfo.txt"
```

Extract all text from a short born-digital PDF:

```powershell
& "$poppler\pdftotext.exe" -layout "document.pdf" "document.txt"
```

Extract only a targeted page range:

```powershell
& "$poppler\pdftotext.exe" -f 20 -l 25 -layout "document.pdf" "document_pages_20_25.txt"
```

Search extracted text:

```powershell
Select-String -Path "document.txt" -Pattern "keyword|section title"
```

If a verified `rg.exe` is available:

```powershell
& "C:\Program Files\ripgrep\rg.exe" -n "keyword|section title" "document.txt"
```

Render selected pages for visual inspection:

```powershell
& "$poppler\pdftoppm.exe" -f 20 -l 20 -r 200 -png "document.pdf" "document_page_20"
```

## Python Use

Use Python only after confirming a machine-wide executable exists, for example:

```powershell
$python = "C:\Program Files\Python314\python.exe"
Test-Path $python
```

If it exists, check the needed libraries before relying on them:

```powershell
& $python -c "import sys; print(sys.version)"
& $python -c "import pdfplumber, fitz, pypdf; print('pdf libraries ok')"
```

Use `PyMuPDF` for fast page-by-page text extraction, rendering, clipping regions, and page counts. Use `pdfplumber` for layout-aware text, words with coordinates, and table extraction. Use `pypdf` for metadata, splitting, merging, rotation, and light PDF manipulation; do not use it as the main extractor unless the task is simple.

Prefer scripts that write outputs:

```powershell
& $python -c "import fitz; doc=fitz.open(r'document.pdf'); open('page1.txt','w',encoding='utf-8').write(doc[0].get_text()); doc.close()"
```

## Pandoc Use

Use Pandoc only after creating a small text or Markdown snippet:

```powershell
& "C:\Program Files\Pandoc\pandoc.exe" -f markdown -t gfm "snippet.txt" -o "snippet.md"
```

Pandoc is useful for normalizing short extracted snippets, not for reading entire PDFs.

## qpdf Use

Use qpdf for structural PDF work, not as the first text extractor. Prefer it when Poppler reports errors, the PDF is encrypted or damaged, page-level splitting is useful, or normalizing the file may make downstream extraction more reliable.

Check qpdf:

```powershell
& "C:\Program Files\qpdf 12.3.2\bin\qpdf.exe" --version
```

Inspect encryption and structure:

```powershell
& "C:\Program Files\qpdf 12.3.2\bin\qpdf.exe" --show-encryption "document.pdf"
& "C:\Program Files\qpdf 12.3.2\bin\qpdf.exe" --check "document.pdf"
```

Repair or normalize a troublesome file before retrying Poppler/Python extraction:

```powershell
& "C:\Program Files\qpdf 12.3.2\bin\qpdf.exe" "document.pdf" "document.normalized.pdf"
```

Extract a focused page range:

```powershell
& "C:\Program Files\qpdf 12.3.2\bin\qpdf.exe" "document.pdf" --pages "document.pdf" 20-25 -- "document_pages_20_25.pdf"
```

## Long PDFs

- Do not extract or read an entire long PDF when the user asks about a page range, section, theorem, table, figure, appendix, or keyword.
- Use `pdfinfo` to learn the page count.
- Use `pdftotext` page ranges, then search snippets.
- Keep extracted files on disk and summarize only the relevant parts in the answer.
- If the user asks for a paper summary, search headings and extract the abstract, introduction, model/data/method section, results, and conclusion rather than dumping the whole document.

## Equation-Heavy PDFs

For economics papers and other PDFs with formal models, use text extraction to navigate, but use rendered pages to verify the final equations.

- Use `pdftotext -layout` first to find pages containing terms such as `Bellman`, `s.t.`, `max`, `constraint`, `Euler`, or key state variables.
- Expect the extracted text layer to garble primes, Greek letters, summation limits, inequality symbols, and underlines/overlines.
- Render the relevant page with `pdftoppm` or `pdftocairo` before writing final equations to Markdown.
- Treat the rendered page as authoritative for exact math notation.
- For Markdown artifacts intended for VS Code preview, use `$...$` for short inline math such as `$a$`, `$c$`, and `$\tau$`; avoid `\(...\)` because it may not render reliably. Put formal expressions in fenced `math` display blocks.
- Save both the page-range text extraction and the rendered page image next to the Markdown output when the task is an extraction artifact.
- In the final answer, say that equations were verified visually when text extraction was imperfect.

## Scanned Or Image-Based PDFs

Suspect a scanned PDF when `pdftotext` returns empty or near-empty output but rendered pages show text.

- Render one or two pages with `pdftoppm` to confirm.
- Use OCR only after confirming that text extraction is unavailable.
- Use Tesseract for OCR-heavy/scanned PDFs, page images, or rendered page ranges where the text layer is absent or unusable. Do not OCR born-digital PDFs by default.
- Prefer OCRing selected pages or page ranges first, then expand only if the user needs the whole document.
- Use the explicit path when PATH is stale:

```powershell
& "C:\Program Files\Tesseract-OCR\tesseract.exe" "page_001.png" "page_001_ocr" -l eng
```

- Do not pretend OCR has been performed when only rendering or text extraction was used.

## Regression Test Artifacts

Keep regression-test PDFs, rendered pages, and extracted text outside this reusable skill folder, for example in a sibling `pdf-test` folder. Useful regression examples include a tiny born-digital PDF to verify `pdfinfo`, `pdftotext`, `pdftoppm`, and Python PDF imports, plus an equation-heavy economics paper to verify when rendered page inspection is needed for exact math notation.

## Output Style

When answering from a PDF, report:

- the tool used and why it was chosen
- the page range or section extracted
- the saved output path for extracted text, tables, metadata, or rendered pages
- whether the PDF appears born-digital or scanned when relevant
- limitations, especially for equations, tables, multi-column layout, or OCR
