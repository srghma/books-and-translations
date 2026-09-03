#!/usr/bin/env -S uv run
"""
delete_unreferenced_images_all.py

Runs unreferenced image deletion across specified book directories (or defaults).
Can be called with specific directories or driven by a justfile.
"""

import os
import sys
import argparse
from delete_unreferenced_images import delete_unreferenced_images, human_readable_size

def main():
    parser = argparse.ArgumentParser(
        description="Delete unreferenced images across book directories."
    )
    parser.add_argument(
        "directories", nargs="*", default=[],
        help="List of directories to scan (defaults to standard book directories)"
    )
    parser.add_argument(
        "--root", default=".",
        help="Root directory containing book directories (default: current directory)"
    )
    parser.add_argument(
        "-n", "--dry-run", action="store_true",
        help="Perform a dry run without deleting any files"
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true",
        help="Minimal output (suppress individual file listings)"
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

    root_dir = os.path.abspath(args.root)
    target_dirs = args.directories

    mode_str = "[DRY-RUN MODE]" if args.dry_run else "[DELETION MODE]"
    print(f"{mode_str} Starting unreferenced image cleanup...\n" + "=" * 70 + "\n")

    total_images_all = 0
    total_referenced_all = 0
    total_unreferenced_all = 0
    total_deleted_all = 0
    total_bytes_all = 0

    results = []

    for rel_dir in target_dirs:
        full_dir = rel_dir if os.path.isabs(rel_dir) else os.path.join(root_dir, rel_dir)
        display_name = os.path.basename(full_dir) if not os.path.isabs(rel_dir) else rel_dir
        if not os.path.isdir(full_dir):
            print(f"Warning: Directory not found: {full_dir}", file=sys.stderr)
            continue

        res = delete_unreferenced_images(
            target_dir=full_dir,
            dry_run=args.dry_run,
            quiet=args.quiet,
            verbose=args.verbose,
            no_git=args.no_git
        )
        results.append((display_name, res))
        total_images_all += res["total_images"]
        total_referenced_all += res["referenced_count"]
        total_unreferenced_all += res["unreferenced_count"]
        total_deleted_all += res["deleted_count"]
        total_bytes_all += res["total_bytes"]

    # Print overall summary table
    print("=" * 70)
    print("OVERALL SUMMARY:")
    for display_name, res in results:
        action_word = "Would delete" if args.dry_run else "Deleted"
        print(
            f"  • {display_name}:\n"
            f"      {res['referenced_count']}/{res['total_images']} referenced | "
            f"{action_word}: {res['deleted_count']} file(s) ({human_readable_size(res['total_bytes'])})"
        )

    action_label = "Would delete" if args.dry_run else "Deleted"
    print("-" * 70)
    print(
        f"TOTAL: {total_referenced_all}/{total_images_all} images referenced.\n"
        f"{action_label} {total_deleted_all} unreferenced image file(s), "
        f"freeing {human_readable_size(total_bytes_all)} in total."
    )
    print("=" * 70)


if __name__ == "__main__":
    main()
