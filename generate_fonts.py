#!/usr/bin/env python3
"""
Finds font files for all font families listed in fonts.json using fc-match in parallel,
and creates symlinks in the `.fonts/` directory with names matching each font family key.

Why .fonts/ is created:
1. Typst and the Tinymist VS Code extension enforce a project root sandbox (by default
   the workspace root). In Typst, functions like `read(...)` cannot access paths outside
   the project root (such as `/nix/store/...`).
2. Setting `TYPST_ROOT="/"` causes Tinymist in VS Code to fail because the workspace entry
   file cannot be resolved relative to root.
3. However, Typst sandboxing allows following symlinks located inside the workspace that
   point to outside locations like `/nix/store/...`.
4. Creating symlinks in `.fonts/<font_name>` matching the exact font family key allows
   Typst code to load font bytes simply with `read("/.fonts/" + font_name, encoding: none)`
   working seamlessly in both `typst compile` CLI and VS Code Tinymist preview without
   requiring `TYPST_ROOT="/"`.
"""

import json
import os
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path


def extract_strings(obj):
    """Recursively extract all string values from lists or dicts."""
    if isinstance(obj, str):
        return [obj]
    if isinstance(obj, list):
        res = []
        for x in obj:
            res.extend(extract_strings(x))
        return res
    if isinstance(obj, dict):
        res = []
        for v in obj.values():
            res.extend(extract_strings(v))
        return res
    return []


def find_font_path(font_name: str) -> tuple[str, str | None]:
    """Runs fc-match to locate the font file on the system."""
    try:
        res = subprocess.run(
            ["fc-match", "-f", "%{file}", font_name],
            capture_output=True,
            text=True,
            check=True,
        )
        path = res.stdout.strip()
        if path and os.path.exists(path):
            return font_name, os.path.abspath(path)
        print(f"Warning: path does not exist for '{font_name}': {path}", file=sys.stderr)
        return font_name, None
    except Exception as e:
        print(f"Error finding font for '{font_name}': {e}", file=sys.stderr)
        return font_name, None


def main():
    root_dir = Path(__file__).resolve().parent
    fonts_json_path = root_dir / "fonts.json"
    fonts_dir = root_dir / ".fonts"

    if not fonts_json_path.exists():
        print(f"Error: {fonts_json_path} does not exist", file=sys.stderr)
        sys.exit(1)

    with open(fonts_json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    all_fonts = sorted(set(extract_strings(data)))
    print(f"Finding paths for {len(all_fonts)} fonts in parallel...")

    fonts_dir.mkdir(parents=True, exist_ok=True)

    max_workers = min(32, (os.cpu_count() or 4) * 4)
    mapped_count = 0
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        for font_name, font_path in executor.map(find_font_path, all_fonts):
            if font_path:
                link_path = fonts_dir / font_name
                if link_path.is_symlink() or link_path.exists():
                    link_path.unlink()
                link_path.symlink_to(font_path)
                mapped_count += 1

    print(f"Successfully generated {fonts_dir} ({mapped_count} fonts mapped).")


if __name__ == "__main__":
    main()
