#!/usr/bin/env -S uv run
"""
delete_unreferenced_images.py

Scans a directory for images that are not referenced in markdown files and deletes them.
Can be run standalone or imported as a reusable module.
"""

import os
import sys
import argparse
import urllib.parse
import re
import subprocess
from pathlib import Path

IMAGE_EXTENSIONS = {
    ".png", ".jpg", ".jpeg", ".webp", ".gif", ".svg",
    ".bmp", ".ico", ".tiff", ".tif", ".avif", ".apng",
    ".heic", ".heif"
}

MD_EXTENSIONS = {
    ".md", ".markdown", ".mdown", ".mkd"
}

IGNORE_DIRS = {
    ".git", ".ckb", ".svn", ".hg", ".vscode", ".idea",
    ".venv", "node_modules", "__pycache__", ".cache"
}


def human_readable_size(size_bytes: int) -> str:
    """Format bytes into human-readable representation."""
    val = float(size_bytes)
    for unit in ['B', 'KB', 'MB', 'GB']:
        if val < 1024.0 or unit == 'GB':
            return f"{val:.2f} {unit}" if unit != 'B' else f"{int(val)} B"
        val /= 1024.0
    return f"{val:.2f} GB"


def clean_target(raw: str) -> str:
    """Extract clean URL/path target from markdown/HTML link attributes."""
    raw = raw.strip()
    if not raw:
        return ""
    # Strip <...> wrapper if present
    if raw.startswith("<") and ">" in raw:
        raw = raw[1:raw.index(">")]
    else:
        # Strip trailing title (e.g. `img.png "title"` or `img.png 'title'`)
        m = re.match(r'^(\S+)(?:\s+["\'].*["\'])?$', raw)
        if m:
            raw = m.group(1)
        else:
            m2 = re.match(r'^(.*?)\s+["\'].*["\']$', raw)
            if m2:
                raw = m2.group(1)
    # Strip URL fragment and query parameters
    raw = raw.split("#")[0].split("?")[0]
    return raw.strip()


def is_git_repo(path: str) -> bool:
    """Check if the given directory is inside a Git repository."""
    try:
        res = subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            cwd=path, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        return res.returncode == 0
    except Exception:
        return False


def is_git_tracked(file_path: str) -> bool:
    """Check if a specific file is tracked by Git."""
    directory = os.path.dirname(file_path)
    filename = os.path.basename(file_path)
    try:
        res = subprocess.run(
            ["git", "ls-files", "--error-unmatch", filename],
            cwd=directory, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        return res.returncode == 0
    except Exception:
        return False


def find_unreferenced_images(target_dir: str):
    """
    Scan target_dir for markdown files and image files.
    Returns:
        all_images: dict mapping canonical_path -> (full_path, rel_path)
        md_files: list of canonical paths to markdown files
        referenced_images: set of canonical paths of referenced images
        unreferenced_images: list of canonical paths of unreferenced images
    """
    target_dir = os.path.abspath(target_dir)

    all_images = {}
    for dirpath, dirnames, filenames in os.walk(target_dir):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS and not d.startswith(".")]
        for f in filenames:
            ext = os.path.splitext(f)[1].lower()
            if ext in IMAGE_EXTENSIONS:
                full_path = os.path.join(dirpath, f)
                canon = os.path.realpath(full_path)
                rel = os.path.relpath(full_path, target_dir)
                all_images[canon] = (full_path, rel)

    md_files = []
    for dirpath, dirnames, filenames in os.walk(target_dir):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS and not d.startswith(".")]
        for f in filenames:
            ext = os.path.splitext(f)[1].lower()
            if ext in MD_EXTENSIONS:
                md_files.append(os.path.realpath(os.path.join(dirpath, f)))

    referenced_images = set()

    img_ext_pattern = "|".join(e.lstrip(".") for e in IMAGE_EXTENSIONS)
    md_img_re = re.compile(r'!\[[^\]]*\]\((.*?)\)', re.DOTALL)
    md_ref_re = re.compile(r'^\s*\[[^\]]+\]:\s*(\S+)', re.MULTILINE)
    html_re = re.compile(r'<(?:img|source)\s+[^>]*(?:src|srcset)=["\']([^"\']+)["\']', re.IGNORECASE)
    general_re = re.compile(r'[\'"]?([^\s\'"<>\(\)]+\.(?:' + img_ext_pattern + r'))[\'"]?', re.IGNORECASE)

    for md_path in md_files:
        md_dir = os.path.dirname(md_path)
        try:
            with open(md_path, "r", encoding="utf-8", errors="ignore") as f:
                content = f.read()
        except Exception as e:
            print(f"Warning: Could not read {md_path}: {e}", file=sys.stderr)
            continue

        targets = set()
        for m in md_img_re.findall(content):
            t = clean_target(m)
            if t:
                targets.add(t)
        for m in md_ref_re.findall(content):
            t = clean_target(m)
            if t:
                targets.add(t)
        for m in html_re.findall(content):
            for entry in m.split(","):
                t = clean_target(entry.strip().split()[0] if entry.strip() else "")
                if t:
                    targets.add(t)
        for m in general_re.findall(content):
            t = clean_target(m)
            if t:
                targets.add(t)

        for raw_target in targets:
            decoded_target = urllib.parse.unquote(raw_target)
            candidates = [
                os.path.normpath(os.path.join(md_dir, decoded_target)),
                os.path.normpath(os.path.join(md_dir, raw_target)),
                os.path.normpath(os.path.join(target_dir, decoded_target.lstrip("/"))),
                os.path.normpath(decoded_target),
            ]
            # Suffix matching for paths with absolute/stale prefixes
            parts = Path(decoded_target).parts
            for i in range(1, len(parts)):
                subpath = os.path.join(*parts[i:])
                candidates.append(os.path.normpath(os.path.join(md_dir, subpath)))
                candidates.append(os.path.normpath(os.path.join(target_dir, subpath)))

            for cand in candidates:
                cand_real = os.path.realpath(cand)
                if cand_real in all_images:
                    referenced_images.add(cand_real)

    unreferenced_images = [canon for canon in all_images if canon not in referenced_images]
    unreferenced_images.sort(key=lambda c: all_images[c][1])

    return all_images, md_files, referenced_images, unreferenced_images


def delete_unreferenced_images(
    target_dir: str,
    dry_run: bool = False,
    quiet: bool = False,
    verbose: bool = False,
    no_git: bool = False
):
    """
    Delete unreferenced images in target_dir.
    Returns a dict with execution statistics.
    """
    target_dir = os.path.abspath(target_dir)
    if not os.path.isdir(target_dir):
        raise ValueError(f"Directory '{target_dir}' does not exist.")

    if not quiet:
        mode_str = "[DRY-RUN MODE]" if dry_run else "[DELETION MODE]"
        print(f"{mode_str} Scanning: {target_dir}")

    all_images, md_files, referenced_images, unreferenced = find_unreferenced_images(target_dir)

    if not quiet:
        print(f"  Total images found    : {len(all_images)}")
        print(f"  Markdown files found  : {len(md_files)}")
        print(f"  Referenced images     : {len(referenced_images)}")
        print(f"  Unreferenced images   : {len(unreferenced)}")

    in_git = not no_git and is_git_repo(target_dir)
    total_bytes = 0
    deleted_count = 0
    deleted_files = []

    if unreferenced and not quiet:
        print("  Unreferenced files:")

    for canon in unreferenced:
        full_path, rel_path = all_images[canon]
        try:
            file_size = os.path.getsize(full_path)
        except OSError:
            file_size = 0
        total_bytes += file_size

        if dry_run:
            deleted_files.append((rel_path, file_size))
            if not quiet:
                print(f"    [WOULD DELETE] {rel_path} ({human_readable_size(file_size)})")
        else:
            deleted = False
            if in_git and is_git_tracked(full_path):
                res = subprocess.run(
                    ["git", "rm", "-f", "--", os.path.basename(full_path)],
                    cwd=os.path.dirname(full_path),
                    stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
                )
                if res.returncode == 0:
                    deleted = True
            if not deleted:
                try:
                    os.remove(full_path)
                    deleted = True
                except Exception as e:
                    print(f"    [ERROR] Failed to delete {rel_path}: {e}", file=sys.stderr)

            if deleted:
                deleted_count += 1
                deleted_files.append((rel_path, file_size))
                if not quiet:
                    print(f"    [DELETED] {rel_path} ({human_readable_size(file_size)})")

    if not quiet:
        action_label = "Would delete" if dry_run else "Deleted"
        count = len(unreferenced) if dry_run else deleted_count
        print(f"  Finished: {action_label} {count} file(s), freeing {human_readable_size(total_bytes)}.\n")

    return {
        "target_dir": target_dir,
        "total_images": len(all_images),
        "total_md": len(md_files),
        "referenced_count": len(referenced_images),
        "unreferenced_count": len(unreferenced),
        "deleted_count": len(unreferenced) if dry_run else deleted_count,
        "total_bytes": total_bytes,
        "deleted_files": deleted_files,
        "dry_run": dry_run,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Scan a directory for images that are not referenced in markdown files and delete them."
    )
    parser.add_argument(
        "directory",
        help="Path to the directory to scan and clean"
    )
    parser.add_argument(
        "-n", "--dry-run", action="store_true",
        help="Show which files would be deleted without deleting them"
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true",
        help="Minimal output (suppress listing each individual file)"
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true",
        help="Verbose output"
    )
    parser.add_argument(
        "--no-git", action="store_true",
        help="Do not use git rm even if files are tracked by Git"
    )
    args = parser.parse_args()

    try:
        delete_unreferenced_images(
            target_dir=args.directory,
            dry_run=args.dry_run,
            quiet=args.quiet,
            verbose=args.verbose,
            no_git=args.no_git
        )
    except ValueError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
