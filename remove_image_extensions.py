#!/usr/bin/env python3
"""
Removes file extensions from image links in markdown files (e.g. ![](_page_14_Diagram_2.svg) -> ![](_page_14_Diagram_2)).
"""

import argparse
import os
import re
import sys
from pathlib import Path

IMAGE_EXT_REGEX = re.compile(r"\.(svg|png|jpe?g|typ|webp)$", re.IGNORECASE)
IMAGE_MD_REGEX = re.compile(r"!\[(.*?)\]\((.*?)\)")


def process_file(file_path: Path, dry_run: bool = False) -> int:
    content = file_path.read_text(encoding="utf-8")
    changes = 0

    def replacer(match: re.Match) -> str:
        nonlocal changes
        alt = match.group(1)
        target = match.group(2).strip()

        if not target:
            return match.group(0)

        # Remove extension if matching
        new_target = IMAGE_EXT_REGEX.sub("", target)
        if new_target != target:
            changes += 1
            return f"![{alt}]({new_target})"
        return match.group(0)

    new_content = IMAGE_MD_REGEX.sub(replacer, content)

    if changes > 0:
        print(f"{file_path}: {changes} image extension(s) removed")
        if not dry_run:
            file_path.write_text(new_content, encoding="utf-8")

    return changes


def main():
    parser = argparse.ArgumentParser(
        description="Remove image extensions from markdown files."
    )
    parser.add_argument(
        "dirs",
        nargs="*",
        default=["The Beginning of Infinity"],
        help="Directories to process (default: 'The Beginning of Infinity')",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show changes without modifying files",
    )
    args = parser.parse_args()

    total_changes = 0
    for dir_arg in args.dirs:
        dir_path = Path(dir_arg)
        if not dir_path.exists():
            print(f"Warning: Directory not found: {dir_path}", file=sys.stderr)
            continue

        for root, _, files in os.walk(dir_path):
            for file in sorted(files):
                if file.endswith(".md"):
                    file_path = Path(root) / file
                    total_changes += process_file(file_path, dry_run=args.dry_run)

    print(f"Total changes: {total_changes}")


if __name__ == "__main__":
    main()
