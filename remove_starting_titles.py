#!/usr/bin/env python3
import glob
import os
import re

PATTERN = re.compile(r"^\s*#{1,3}\s*(<span[^>]*></span>)?\s*(\d+\s+)?.*?\n\s*")


def main():
    files = sorted(glob.glob("The Beginning of Infinity/[0-9]*.md"))
    modified_count = 0

    for filepath in files:
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        match = PATTERN.match(content)
        if match:
            new_content = content[match.end():]
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(new_content)
            print(f"Removed title from {os.path.basename(filepath)}: {match.group(0).strip()}")
            modified_count += 1
        else:
            print(f"No title found in {os.path.basename(filepath)}")

    print(f"\nDone! Modified {modified_count} files.")


if __name__ == "__main__":
    main()
