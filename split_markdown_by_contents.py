#!/usr/bin/env python3
"""
split_markdown_by_contents.py

Splits a large Markdown book (such as main.md) into separate Markdown files
based on its Table of Contents.

Usage:
    python3 split_markdown_by_contents.py [path/to/main.md] [options]

Example:
    python3 split_markdown_by_contents.py "The Beginning of Infinity/main.md"
"""

import argparse
import os
import re
import sys
from pathlib import Path
from typing import List, Optional, Tuple

DEFAULT_TOC = [
    "Acknowledgements",
    "Introduction",
    "1. The Reach of Explanations",
    "2. Closer to Reality",
    "3. The Spark",
    "4. Creation",
    "5. The Reality of Abstractions",
    "6. The Jump to Universality",
    "7. Artificial Creativity",
    "8. A Window on Infinity",
    "9. Optimism",
    "10. A Dream of Socrates",
    "11. The Multiverse",
    "12. A Physicist’s History of Bad Philosophy",
    "13. Choices",
    "14. Why are Flowers Beautiful?",
    "15. The Evolution of Culture",
    "16. The Evolution of Creativity",
    "17. Unsustainable",
    "18. The Beginning",
    "Bibliography",
    "Index",
]


def extract_toc_from_markdown(content: str) -> Optional[List[str]]:
    """
    Attempts to locate a Markdown table under a 'Contents' header and parse section titles.
    """
    match = re.search(
        r"(?im)^#{1,6}\s*\*?Contents\*?\s*\n+((?:\|[^\n]+\|\r?\n?)+)",
        content,
    )
    if not match:
        return None

    table_text = match.group(1)
    titles: List[str] = []
    for line in table_text.strip().splitlines():
        cells = [c.strip() for c in line.strip("|").split("|")]
        # Skip header separators like |---|---|
        if len(cells) >= 2 and not all(set(c).issubset({"-", " ", ":"}) for c in cells):
            title = cells[0].strip()
            if title.lower() != "contents":
                titles.append(title)

    return titles if titles else None


def build_heading_pattern(title: str) -> re.Pattern:
    """
    Builds a flexible regex pattern to find the section heading in Markdown.
    Handles:
      - Any header level (# to ######)
      - HTML tags / anchors such as <span id="..."></span>
      - Optional numbering (e.g. '1 ' or '1. ')
      - Markdown formatting like *Title* or **Title**
      - Straight and curly apostrophes/quotes
    """
    # Remove leading number like '1. ' if present in the TOC title
    clean_title = re.sub(r"^\d+\.\s*", "", title).strip()

    # Normalize straight and curly quotes for pattern matching
    clean_re = clean_title.replace("’", "'").replace("‘", "'")
    clean_re = re.escape(clean_re)
    # Replace escaped quotes with a class matching both straight and curly quotes
    clean_re = clean_re.replace(r"\'", r"['’‘]")

    pattern_str = (
        r"^(#{1,6})\s+"
        r"(?:<span[^>]*></span>\s*)*"
        r"(?:\d+\.?\s+)?"
        r"\*?" + clean_re + r"\*?\s*$"
    )
    return re.compile(pattern_str, re.IGNORECASE)


def sanitize_filename(name: str, replace_invalid: bool = False) -> str:
    """Sanitizes filename for filesystem safety if requested."""
    if replace_invalid:
        return re.sub(r'[<>:"/\\|?*]', "_", name).strip()
    return name.replace("/", "_").replace("\0", "").strip()


def split_markdown_file(
    input_file: Path,
    output_dir: Optional[Path] = None,
    toc_titles: Optional[List[str]] = None,
    front_matter_name: str = "Front Matter.md",
    include_front_matter: bool = True,
    dry_run: bool = False,
    replace_invalid_chars: bool = False,
) -> List[Tuple[Path, int]]:
    """
    Splits input_file based on TOC into separate markdown files.
    Returns a list of (output_file_path, line_count).
    """
    input_file = input_file.resolve()
    if not input_file.is_file():
        raise FileNotFoundError(f"Input file not found: {input_file}")

    if output_dir is None:
        output_dir = input_file.parent
    else:
        output_dir = output_dir.resolve()

    with open(input_file, "r", encoding="utf-8") as f:
        text = f.read()

    lines = text.splitlines(keepends=True)

    # Determine TOC titles
    if not toc_titles:
        extracted = extract_toc_from_markdown(text)
        if extracted:
            print(f"Discovered {len(extracted)} sections from Table of Contents table.")
            toc_titles = extracted
        else:
            print(f"No TOC table found in {input_file.name}. Using default TOC list ({len(DEFAULT_TOC)} entries).")
            toc_titles = DEFAULT_TOC

    # Find the position of the TOC table so we only search for headings AFTER it
    toc_match = re.search(r"(?im)^#{1,6}\s*\*?Contents\*?", text)
    min_line_idx = 0
    if toc_match:
        toc_pos = toc_match.end()
        cur_pos = 0
        for idx, line in enumerate(lines):
            cur_pos += len(line)
            if cur_pos >= toc_pos:
                min_line_idx = idx + 1
                break

    # Locate each heading line in lines
    split_points: List[Tuple[int, str]] = []
    last_found_idx = min_line_idx

    for title in toc_titles:
        pattern = build_heading_pattern(title)
        found_idx = None

        for idx in range(last_found_idx, len(lines)):
            line_str = lines[idx].strip()
            if pattern.match(line_str):
                found_idx = idx
                break

        if found_idx is None:
            # Fallback: search from min_line_idx in case of out-of-order or duplicate headings
            for idx in range(min_line_idx, len(lines)):
                line_str = lines[idx].strip()
                if pattern.match(line_str):
                    found_idx = idx
                    break

        if found_idx is None:
            raise ValueError(f"Could not find matching heading for TOC item: '{title}'")

        split_points.append((found_idx, title))
        last_found_idx = found_idx + 1

    # Prepare chunks
    results: List[Tuple[Path, int, str]] = []

    # Front matter: content before the first section
    first_section_idx = split_points[0][0]
    if include_front_matter and first_section_idx > 0:
        front_matter_content = "".join(lines[:first_section_idx])
        if front_matter_content.strip():
            fm_path = output_dir / sanitize_filename(front_matter_name, replace_invalid_chars)
            results.append((fm_path, first_section_idx, front_matter_content))

    # Split each section
    for i, (start_idx, title) in enumerate(split_points):
        end_idx = split_points[i + 1][0] if i + 1 < len(split_points) else len(lines)
        section_content = "".join(lines[start_idx:end_idx])
        filename = f"{sanitize_filename(title, replace_invalid_chars)}.md"
        out_path = output_dir / filename
        results.append((out_path, end_idx - start_idx, section_content))

    # Verification: check total content
    reconstructed = "".join(item[2] for item in results)
    if include_front_matter and reconstructed != text:
        raise RuntimeError("Integrity check failed: Reconstructed content does not match original!")

    # Write files
    if not dry_run:
        output_dir.mkdir(parents=True, exist_ok=True)

    summary: List[Tuple[Path, int]] = []
    for out_path, line_count, content in results:
        summary.append((out_path, line_count))
        if dry_run:
            print(f"[DRY-RUN] Would write {line_count:4d} lines to: {out_path}")
        else:
            with open(out_path, "w", encoding="utf-8") as out_f:
                out_f.write(content)
            print(f"Created ({line_count:4d} lines): {out_path.name}")

    return summary


def main():
    parser = argparse.ArgumentParser(
        description="Split a Markdown book file into multiple Markdown files based on Table of Contents."
    )
    parser.add_argument(
        "input_file",
        nargs="?",
        default="The Beginning of Infinity/main.md",
        help="Path to the input Markdown file (default: 'The Beginning of Infinity/main.md')",
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        default=None,
        help="Output directory (default: same directory as input_file)",
    )
    parser.add_argument(
        "--no-front-matter",
        action="store_true",
        help="Skip writing the leading front-matter content before the first section",
    )
    parser.add_argument(
        "--front-matter-name",
        default="Front Matter.md",
        help="Filename for the front matter content (default: 'Front Matter.md')",
    )
    parser.add_argument(
        "--sanitize-filenames",
        action="store_true",
        help="Replace characters like '?' and ':' in filenames with '_'",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview what files would be generated without writing anything",
    )

    args = parser.parse_args()

    input_path = Path(args.input_file)
    if not input_path.exists():
        # Try finding main.md in current directory
        alt_path = Path("main.md")
        if alt_path.exists():
            input_path = alt_path
        else:
            print(f"Error: File '{args.input_file}' not found.", file=sys.stderr)
            sys.exit(1)

    out_dir = Path(args.output_dir) if args.output_dir else None

    try:
        split_markdown_file(
            input_file=input_path,
            output_dir=out_dir,
            front_matter_name=args.front_matter_name,
            include_front_matter=not args.no_front_matter,
            dry_run=args.dry_run,
            replace_invalid_chars=args.sanitize_filenames,
        )
        print("\nSplitting completed successfully!")
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
