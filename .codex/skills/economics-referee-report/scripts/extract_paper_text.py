#!/usr/bin/env python3
"""Extract readable text and quick diagnostics from an academic paper PDF."""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

import pdfplumber


SECTION_PATTERN = (
    r"^(abstract|introduction|related (literature|work)|institutional background|"
    r"data|empirical strategy|identification|model|theory|estimation|results|"
    r"conclusion|appendix|references)$"
)

KEYWORDS = [
    "identification",
    "instrument",
    "parallel trends",
    "event study",
    "calibration",
    "counterfactual",
    "welfare",
    "robustness",
    "external validity",
]


def clean_text(text: str) -> str:
    text = text.replace("\x00", " ")
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def run_command(command: list[str]) -> str:
    try:
        completed = subprocess.run(
            command,
            check=False,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
    except OSError:
        return ""
    return completed.stdout.strip()


def collect_pdfgrep_hits(pdf_path: Path) -> dict[str, list[str]]:
    pdfgrep = shutil.which("pdfgrep")
    if not pdfgrep:
        return {}

    hits: dict[str, list[str]] = {}
    section_hits = run_command([pdfgrep, "-n", "-i", SECTION_PATTERN, str(pdf_path)])
    if section_hits:
        hits["section_headers"] = section_hits.splitlines()

    for keyword in KEYWORDS:
        keyword_hits = run_command([pdfgrep, "-n", "-i", keyword, str(pdf_path)])
        if keyword_hits:
            hits[keyword] = keyword_hits.splitlines()[:10]

    return hits


def extract_pages(pdf_path: Path) -> list[dict[str, str | int]]:
    pages: list[dict[str, str | int]] = []
    with pdfplumber.open(pdf_path) as pdf:
        for index, page in enumerate(pdf.pages, start=1):
            text = page.extract_text(x_tolerance=2, y_tolerance=2) or ""
            pages.append({"page": index, "text": clean_text(text)})
    return pages


def write_markdown(output_path: Path, pdf_path: Path, pages: list[dict[str, str | int]]) -> None:
    lines = [f"# Extracted Text for {pdf_path.name}", ""]
    for page_info in pages:
        page_number = page_info["page"]
        text = page_info["text"] or "[No extractable text on this page]"
        lines.extend([f"## Page {page_number}", "", str(text), ""])
    output_path.write_text("\n".join(lines), encoding="utf-8")


def normalize_with_pandoc(markdown_path: Path, output_path: Path) -> bool:
    pandoc = shutil.which("pandoc")
    if not pandoc:
        return False

    completed = subprocess.run(
        [pandoc, str(markdown_path), "-f", "gfm", "-t", "plain", "-o", str(output_path)],
        check=False,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    return completed.returncode == 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Extract page-by-page text and quick diagnostics from a PDF paper."
    )
    parser.add_argument("pdf_path", type=Path, help="Path to the PDF file")
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=None,
        help="Directory for extracted files. Defaults to the PDF folder.",
    )
    parser.add_argument(
        "--pandoc-normalize",
        action="store_true",
        help="Also create a normalized plain-text file from the markdown output using pandoc.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    pdf_path = args.pdf_path.expanduser().resolve()
    if not pdf_path.exists():
        print(f"PDF not found: {pdf_path}", file=sys.stderr)
        return 1

    output_dir = (args.output_dir or pdf_path.parent).expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    stem = pdf_path.stem
    markdown_path = output_dir / f"{stem}.extracted.md"
    json_path = output_dir / f"{stem}.diagnostics.json"
    normalized_path = output_dir / f"{stem}.normalized.txt"

    pages = extract_pages(pdf_path)
    write_markdown(markdown_path, pdf_path, pages)

    diagnostics = {
        "pdf": str(pdf_path),
        "page_count": len(pages),
        "pages_with_text": sum(1 for page in pages if page["text"]),
        "pdfgrep_hits": collect_pdfgrep_hits(pdf_path),
    }
    json_path.write_text(json.dumps(diagnostics, indent=2), encoding="utf-8")

    created = {
        "markdown": str(markdown_path),
        "diagnostics": str(json_path),
    }

    if args.pandoc_normalize and normalize_with_pandoc(markdown_path, normalized_path):
        created["normalized"] = str(normalized_path)

    print(json.dumps(created, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
