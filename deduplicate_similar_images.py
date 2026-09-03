#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.9"
# dependencies = [
#     "pillow>=10.0.0",
#     "imagehash>=4.3.0",
# ]
# ///
"""
deduplicate_similar_images.py

Scans a book directory for visually similar / duplicate images (e.g. >= 90% similarity),
keeps only one canonical image per cluster, updates references in markdown files,
collapses consecutive duplicate image embeds, and deletes redundant images.

Can be run standalone or imported as a reusable module.
"""

import os
import sys
from PIL import Image, ImageChops, ImageStat
import imagehash
import argparse
import filecmp
import urllib.parse
import re
import subprocess
from pathlib import Path
from collections import defaultdict

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


def is_git_repo(path: str) -> bool:
    try:
        res = subprocess.run(
            ["git", "rev-parse", "--is-inside-work-tree"],
            cwd=path, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        return res.returncode == 0
    except Exception:
        return False


def is_git_tracked(file_path: str) -> bool:
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


class UnionFind:
    def __init__(self, elements):
        self.parent = {e: e for e in elements}

    def find(self, x):
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])
        return self.parent[x]

    def union(self, x, y):
        rx = self.find(x)
        ry = self.find(y)
        if rx != ry:
            self.parent[ry] = rx


def compute_image_meta(file_path: str):
    """Load image, calculate perceptual hashes, dimensions and file size."""
    try:
        with Image.open(file_path) as im:
            width, height = im.size
            rgb_im = im.convert("RGB")
            phash = imagehash.phash(rgb_im)
            dhash = imagehash.dhash(rgb_im)
        size = os.path.getsize(file_path)
        return {
            "path": file_path,
            "width": width,
            "height": height,
            "area": width * height,
            "aspect_ratio": width / height if height > 0 else 0,
            "phash": phash,
            "dhash": dhash,
            "size": size,
        }
    except Exception as e:
        return None


def compute_image_similarity(meta1, meta2):
    """
    Computes similarity percentage (0.0 to 100.0) between two images.
    Combines exact byte comparison, aspect ratio check, perceptual hash,
    and normalized pixel difference on common overlap.
    """
    # 1. Exact byte match
    if meta1["size"] == meta2["size"]:
        if filecmp.cmp(meta1["path"], meta2["path"], shallow=False):
            return 100.0

    # 2. Check aspect ratio compatibility (must be within ~8%)
    ar1 = meta1["aspect_ratio"]
    ar2 = meta2["aspect_ratio"]
    if ar1 <= 0 or ar2 <= 0 or abs(ar1 - ar2) / max(ar1, ar2) > 0.08:
        return 0.0

    # 3. Perceptual hash distance (phash and dhash)
    dist = min(meta1["phash"] - meta2["phash"], meta1["dhash"] - meta2["dhash"])
    phash_sim = (1.0 - (dist / 64.0)) * 100.0
    if phash_sim < 80.0:
        return phash_sim

    # 4. Normalized pixel similarity on common resized dimensions
    try:
        with Image.open(meta1["path"]) as im1, Image.open(meta2["path"]) as im2:
            rgb1 = im1.convert("RGB")
            rgb2 = im2.convert("RGB")
            target_size = (min(im1.width, im2.width), min(im1.height, im2.height))
            r1 = rgb1.resize(target_size, Image.Resampling.BILINEAR)
            r2 = rgb2.resize(target_size, Image.Resampling.BILINEAR)
            diff = ImageChops.difference(r1, r2)
            stat = ImageStat.Stat(diff)
            mean_diff = sum(stat.mean) / len(stat.mean) # 0 to 255
            pixel_sim = (1.0 - (mean_diff / 255.0)) * 100.0

        # Weighted combination: 50% perceptual hash, 50% pixel overlap similarity
        return (phash_sim * 0.5) + (pixel_sim * 0.5)
    except Exception:
        return phash_sim


def find_similar_image_clusters(images, similarity_threshold=90.0):
    """
    Cluster images into groups of similar images with similarity >= similarity_threshold.
    Returns:
        clusters: list of lists, where each list has [canonical_image_meta, duplicate_meta_1, ...]
    """
    elements = list(range(len(images)))
    uf = UnionFind(elements)
    pair_similarities = {}

    for i in range(len(images)):
        for j in range(i + 1, len(images)):
            sim = compute_image_similarity(images[i], images[j])
            if sim >= similarity_threshold:
                uf.union(i, j)
                pair_similarities[(i, j)] = sim

    grouped = defaultdict(list)
    for idx in elements:
        grouped[uf.find(idx)].append(images[idx])

    clusters = []
    for group in grouped.values():
        if len(group) > 1:
            # Choose canonical image to KEEP:
            # 1) highest resolution/area, 2) largest size, 3) alphabetically earlier filename
            group.sort(
                key=lambda m: (m["area"], m["size"], -len(os.path.basename(m["path"]))),
                reverse=True
            )
            clusters.append(group)

    return clusters, pair_similarities


def update_markdown_references(
    md_path: str,
    replacement_map: dict,
    collapse_consecutive: bool = True,
    dry_run: bool = False
):
    """
    Replace references to duplicate images with canonical image references in md_path.
    Also optionally collapses consecutive identical image embeds.
    """
    try:
        with open(md_path, "r", encoding="utf-8") as f:
            content = f.read()
    except Exception as e:
        print(f"Warning: Could not read {md_path}: {e}", file=sys.stderr)
        return 0, 0

    original_content = content
    num_replacements = 0

    for dup_name, canon_name in replacement_map.items():
        dup_quoted = urllib.parse.quote(dup_name)
        canon_quoted = urllib.parse.quote(canon_name)

        if dup_name in content:
            num_replacements += content.count(dup_name)
            content = content.replace(dup_name, canon_name)

        if dup_quoted != dup_name and dup_quoted in content:
            num_replacements += content.count(dup_quoted)
            content = content.replace(dup_quoted, canon_quoted)

    num_collapsed = 0
    if collapse_consecutive:
        def collapse_cb(match):
            nonlocal num_collapsed
            matched_str = match.group(0)
            first_embed = match.group(1)
            extra = matched_str.count(first_embed) - 1
            num_collapsed += extra
            return first_embed

        embed_collapse_re = re.compile(
            r'(!\[[^\]]*\]\([^\)]+\))(?:\s*\n\s*\1)+',
            re.MULTILINE
        )
        content = embed_collapse_re.sub(collapse_cb, content)

    if not dry_run and content != original_content:
        with open(md_path, "w", encoding="utf-8") as f:
            f.write(content)

    return num_replacements, num_collapsed


def deduplicate_similar_images(
    target_dir: str,
    similarity_threshold: float = 90.0,
    collapse_consecutive: bool = True,
    dry_run: bool = False,
    quiet: bool = False,
    verbose: bool = False,
    no_git: bool = False
):
    """
    Scans target_dir for images with similarity >= similarity_threshold,
    keeps only one canonical image per cluster, updates markdown files,
    and deletes redundant image files.
    """
    target_dir = os.path.abspath(target_dir)
    if not os.path.isdir(target_dir):
        raise ValueError(f"Directory '{target_dir}' does not exist.")

    if not quiet:
        mode_str = "[DRY-RUN MODE]" if dry_run else "[DEDUPLICATION MODE]"
        print(f"{mode_str} Scanning directory for similar images (>= {similarity_threshold}%): {target_dir}")

    # 1. Discover all images
    image_paths = []
    for dirpath, dirnames, filenames in os.walk(target_dir):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS and not d.startswith(".")]
        for f in filenames:
            ext = os.path.splitext(f)[1].lower()
            if ext in IMAGE_EXTENSIONS:
                image_paths.append(os.path.join(dirpath, f))

    if not quiet:
        print(f"  Analyzing {len(image_paths)} image(s)...")

    # 2. Extract metadata
    metas = []
    for p in image_paths:
        m = compute_image_meta(p)
        if m is not None:
            metas.append(m)

    # 3. Cluster similar images
    clusters, _ = find_similar_image_clusters(metas, similarity_threshold=similarity_threshold)
    total_duplicates = sum(len(c) - 1 for c in clusters)

    if not quiet:
        print(f"  Found {len(clusters)} cluster(s) with {total_duplicates} duplicate image(s).\n")

    if not clusters:
        if not quiet:
            print("  No duplicate or similar images found.")
        return {
            "target_dir": target_dir,
            "clusters_count": 0,
            "duplicates_count": 0,
            "deleted_count": 0,
            "freed_bytes": 0,
            "replacements_count": 0,
            "collapsed_count": 0,
            "dry_run": dry_run,
        }

    replacement_map = {}
    duplicates_to_delete = []
    freed_bytes = 0

    for cluster in clusters:
        canonical = cluster[0]
        canon_base = os.path.basename(canonical["path"])
        canon_rel = os.path.relpath(canonical["path"], target_dir)

        if not quiet:
            print(f"  Cluster (Keeping: {canon_rel} [{canonical['width']}x{canonical['height']}]):")

        for dup in cluster[1:]:
            dup_base = os.path.basename(dup["path"])
            dup_rel = os.path.relpath(dup["path"], target_dir)
            sim_score = compute_image_similarity(canonical, dup)
            replacement_map[dup_base] = canon_base
            duplicates_to_delete.append(dup)
            freed_bytes += dup["size"]
            action_tag = "[WOULD DELETE]" if dry_run else "[DUPLICATE -> DELETE]"
            if not quiet:
                print(f"    {action_tag} {dup_rel} ({human_readable_size(dup['size'])}, {sim_score:.1f}% similar) -> use {canon_base}")

    if not quiet:
        print()

    # 4. Update Markdown files
    md_files = []
    for dirpath, dirnames, filenames in os.walk(target_dir):
        dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS and not d.startswith(".")]
        for f in filenames:
            ext = os.path.splitext(f)[1].lower()
            if ext in MD_EXTENSIONS:
                md_files.append(os.path.join(dirpath, f))

    total_replacements = 0
    total_collapsed = 0
    for md_path in md_files:
        rel_md = os.path.relpath(md_path, target_dir)
        reps, coll = update_markdown_references(
            md_path, replacement_map,
            collapse_consecutive=collapse_consecutive,
            dry_run=dry_run
        )
        total_replacements += reps
        total_collapsed += coll
        if (reps > 0 or coll > 0) and not quiet:
            action_verb = "Would update" if dry_run else "Updated"
            collapse_info = f", {coll} consecutive embed(s) collapsed" if collapse_consecutive else ""
            print(f"  {action_verb} {rel_md}: {reps} reference(s) updated{collapse_info}.")

    # 5. Delete redundant images
    in_git = not no_git and is_git_repo(target_dir)
    deleted_count = 0

    for dup in duplicates_to_delete:
        full_path = dup["path"]
        rel_path = os.path.relpath(full_path, target_dir)

        if dry_run:
            deleted_count += 1
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
                if verbose and not quiet:
                    print(f"    [DELETED FILE] {rel_path}")

    if not quiet:
        action_word = "Would delete" if dry_run else "Deleted"
        collapse_info = f", consecutive duplicates collapsed: {total_collapsed}" if collapse_consecutive else ""
        print(f"\n  Finished: {action_word} {deleted_count} duplicate image file(s), freeing {human_readable_size(freed_bytes)}.")
        print(f"  Total markdown links updated: {total_replacements}{collapse_info}.\n")

    return {
        "target_dir": target_dir,
        "clusters_count": len(clusters),
        "duplicates_count": len(duplicates_to_delete),
        "deleted_count": deleted_count,
        "freed_bytes": freed_bytes,
        "replacements_count": total_replacements,
        "collapsed_count": total_collapsed,
        "dry_run": dry_run,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Scan a book directory for visually similar images, keep one, and update markdown files."
    )
    parser.add_argument(
        "directory",
        help="Path to the book directory to deduplicate"
    )
    parser.add_argument(
        "-s", "--similarity", type=float, default=90.0,
        help="Minimum similarity percentage to consider duplicates (default: 90.0)"
    )
    parser.add_argument(
        "--no-collapse", action="store_true",
        help="Do not collapse consecutive identical markdown image embeds"
    )
    parser.add_argument(
        "-n", "--dry-run", action="store_true",
        help="Preview changes without modifying markdown or deleting images"
    )
    parser.add_argument(
        "-q", "--quiet", action="store_true",
        help="Minimal output"
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
        deduplicate_similar_images(
            target_dir=args.directory,
            similarity_threshold=args.similarity,
            collapse_consecutive=not args.no_collapse,
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
