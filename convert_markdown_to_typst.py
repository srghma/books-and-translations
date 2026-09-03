#!/usr/bin/env -S uv run
"""
convert_markdown_to_typst.py

Automatically converts Markdown file(s) to Typst (.typ) format using Pandoc.
Cleans up any Pandoc Typst edge cases (such as empty image references).
Can be called for a single directory, a list of directories, or a single markdown file.
"""

import os
import sys
import shutil
import argparse
import subprocess
import re
from pathlib import Path

IGNORE_DIRS = {
    ".git", ".ckb", ".svn", ".hg", ".vscode", ".idea",
    ".venv", "node_modules", "__pycache__", ".cache", ".direnv"
}


def run_pandoc(md_path: str, typ_path: str, work_dir: str):
    """Run pandoc, falling back to nix-shell if pandoc is not directly in PATH."""
    if shutil.which("pandoc"):
        cmd = ["pandoc", "-f", "markdown", "-t", "typst", md_path, "-o", typ_path]
        subprocess.run(cmd, check=True, cwd=work_dir)
    elif shutil.which("nix-shell"):
        cmd = [
            "nix-shell", "-p", "pandoc", "--run",
            f'pandoc -f markdown -t typst "{md_path}" -o "{typ_path}"'
        ]
        subprocess.run(cmd, check=True, cwd=work_dir)
    else:
        raise FileNotFoundError("Neither 'pandoc' nor 'nix-shell' found in PATH.")


def run_typst_compile(typ_path: str, pdf_path: str, work_dir: str):
    """Run typst compile, falling back to nix-shell if typst is not in PATH."""
    if shutil.which("typst"):
        subprocess.run(["typst", "compile", typ_path, pdf_path], check=True, cwd=work_dir)
    elif shutil.which("nix-shell"):
        cmd = [
            "nix-shell", "-p", "typst", "--run",
            f'typst compile "{typ_path}" "{pdf_path}"'
        ]
        subprocess.run(cmd, check=True, cwd=work_dir)
    else:
        raise FileNotFoundError("Neither 'typst' nor 'nix-shell' found in PATH.")


def convert_file(md_path: str, compile_pdf: bool = False) -> str:
    """Convert a single markdown file to typst (.typ) using pandoc."""
    md_path = os.path.abspath(md_path)
    typ_path = os.path.splitext(md_path)[0] + ".typ"
    work_dir = os.path.dirname(md_path)

    print(f"Converting: {os.path.basename(md_path)} -> {os.path.basename(typ_path)}")

    try:
        run_pandoc(md_path, typ_path, work_dir)
    except Exception as e:
        print(f"Error converting {md_path}: {e}", file=sys.stderr)
        return ""

    # Post-process typst file: fix empty image("") references if pandoc generated them
    with open(typ_path, "r", encoding="utf-8") as f:
        content = f.read()

    # If pandoc produced empty image(""), replace with empty content [] so typst doesn't error
    if 'image("")' in content:
        content = content.replace('image(""),', '[],')
        content = content.replace('image("")', '[]')
        with open(typ_path, "w", encoding="utf-8") as f:
            f.write(content)

    print(f"  ✓ Generated: {typ_path}")

    if compile_pdf:
        pdf_path = os.path.splitext(md_path)[0] + ".pdf"
        print(f"  Compiling PDF: {os.path.basename(pdf_path)}...")
        try:
            run_typst_compile(typ_path, pdf_path, work_dir)
            print(f"  ✓ Compiled PDF: {pdf_path}")
        except Exception as e:
            print(f"Warning: Failed to compile {typ_path} to PDF: {e}", file=sys.stderr)

    return typ_path


def convert_directory(dir_path: str, compile_pdf: bool = False):
    """Scan directory for markdown files and convert them."""
    dir_path = os.path.abspath(dir_path)
    if not os.path.isdir(dir_path):
        print(f"Error: Directory '{dir_path}' does not exist.", file=sys.stderr)
        return

    md_files = []
    for dirpath, dirnames, filenames in os.walk(dir_path):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS and not d.startswith(".")]
        for f in filenames:
            if f.lower().endswith((".md", ".markdown")):
                md_files.append(os.path.join(dirpath, f))

    if not md_files:
        print(f"No markdown files found in {dir_path}")
        return

    for md_file in md_files:
        convert_file(md_file, compile_pdf=compile_pdf)


def main():
    parser = argparse.ArgumentParser(
        description="Convert Markdown files to Typst (.typ) format."
    )
    parser.add_argument(
        "targets", nargs="+",
        help="Directories or markdown file paths to convert"
    )
    parser.add_argument(
        "-c", "--compile", action="store_true",
        help="Also compile the generated .typ file to PDF using typst"
    )
    args = parser.parse_args()

    for target in args.targets:
        if os.path.isdir(target):
            convert_directory(target, compile_pdf=args.compile)
        elif os.path.isfile(target):
            convert_file(target, compile_pdf=args.compile)
        else:
            print(f"Warning: Target '{target}' not found.", file=sys.stderr)


if __name__ == "__main__":
    main()
