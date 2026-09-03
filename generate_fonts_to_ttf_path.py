#!/usr/bin/env python3
"""
Finds font files for all font families listed in fonts.json using fc-match in parallel,
and generates fonts-to-ttf-path.json mapping font names to absolute paths.
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
    output_path = root_dir / "fonts-to-ttf-path.json"

    if not fonts_json_path.exists():
        print(f"Error: {fonts_json_path} does not exist", file=sys.stderr)
        sys.exit(1)

    with open(fonts_json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    all_fonts = sorted(set(extract_strings(data)))
    print(f"Finding paths for {len(all_fonts)} fonts in parallel...")

    mapping = {}
    max_workers = min(32, (os.cpu_count() or 4) * 4)
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        for font_name, font_path in executor.map(find_font_path, all_fonts):
            if font_path:
                mapping[font_name] = font_path

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(mapping, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"Successfully generated {output_path} ({len(mapping)} fonts mapped).")


if __name__ == "__main__":
    main()
