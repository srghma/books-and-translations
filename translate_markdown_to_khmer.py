#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.10"
# dependencies = [
#     "requests>=2.28.0",
#     "beautifulsoup4>=4.11.0",
# ]
# ///
"""
translate_markdown_to_khmer.py

Translates Markdown (.md) files in a directory to Khmer (or specified language),
saving each translated file as ORIGINALNAME-km.md in the same directory.

Features:
- Safe preservation of all Markdown syntax, images, math ($...$, $$...$$),
  inline code (`...`), code blocks (```...```), and HTML/Typst tags
  (<footnote>, <chapter ... />, <treason />, <sun-symbol />, <dialogue ...>, etc.).
- SQLite caching to avoid duplicate translations and enable instant re-runs.
- Exponential backoff retry logic with browser User-Agent.
- Skips already translated *-km.md files.
"""

import argparse
import logging
import os
import re
import sqlite3
import sys
import time
from pathlib import Path
from typing import List, Optional, Tuple

import requests
from bs4 import BeautifulSoup

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger("translate_km")

DEFAULT_CACHE_PATHS = [
    Path(os.environ.get("MD_TRANSLATE_CACHE_DB", "")),
    Path("/home/srghma/projects/md_docs-trans-app/.cache.sqlite"),
    Path.home() / ".cache" / "md_translate.sqlite",
]

TOKEN_PATTERN = re.compile(
    r"("
    r"```[\s\S]*?```"                      # 1. Code blocks
    r"|`[^`\n]+`"                          # 2. Inline code
    r"|\$\$[\s\S]*?\$\$"                   # 3. Display math
    r"|\$[^$\n]+\$"                        # 4. Inline math
    r"|!\[[^\]]*\]\([^)]+\)"               # 5. Image links
    r"|</?[a-zA-Z0-9_-]+(?:\s+[^>]*)?/?>"  # 6. XML/HTML tags
    r"|\\\s*$"                             # 7. Line-break backslash
    r")",
    flags=re.MULTILINE,
)

PURE_TAG_BLOCK_PATTERN = re.compile(
    r"^\s*(</?[a-zA-Z0-9_-]+(?:\s+[^>]*)?/?>\s*)+$"
)


class TranslationCache:
    def __init__(self, db_path: Optional[Path] = None):
        self.db_path = self._resolve_db_path(db_path)
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_db()

    @staticmethod
    def _resolve_db_path(custom_path: Optional[Path]) -> Path:
        if custom_path and str(custom_path).strip():
            return custom_path
        env = os.environ.get("MD_TRANSLATE_CACHE_DB")
        if env and env.strip():
            return Path(env.strip())
        default_app_cache = Path("/home/srghma/projects/md_docs-trans-app/.cache.sqlite")
        if default_app_cache.exists():
            return default_app_cache
        return Path.home() / ".cache" / "md_translate.sqlite"

    def _get_connection(self) -> sqlite3.Connection:
        conn = sqlite3.connect(str(self.db_path), timeout=30.0)
        conn.execute("PRAGMA journal_mode=WAL;")
        return conn

    def _init_db(self) -> None:
        with self._get_connection() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS text_translations (
                    service TEXT NOT NULL,
                    from_lang TEXT NOT NULL,
                    to_lang TEXT NOT NULL,
                    source_text TEXT NOT NULL,
                    translated_text TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    PRIMARY KEY (service, from_lang, to_lang, source_text)
                );
                """
            )
            conn.commit()

    def get(self, service: str, from_lang: str, to_lang: str, source_text: str) -> Optional[str]:
        try:
            with self._get_connection() as conn:
                cur = conn.cursor()
                cur.execute(
                    """
                    SELECT translated_text FROM text_translations
                    WHERE service = ? AND from_lang = ? AND to_lang = ? AND source_text = ?;
                    """,
                    (service, from_lang, to_lang, source_text),
                )
                row = cur.fetchone()
                if row:
                    return row[0]
        except Exception as e:
            logger.warning("Cache read failed: %s", e)
        return None

    def set(self, service: str, from_lang: str, to_lang: str, source_text: str, translated_text: str) -> None:
        try:
            with self._get_connection() as conn:
                conn.execute(
                    """
                    INSERT OR REPLACE INTO text_translations (service, from_lang, to_lang, source_text, translated_text)
                    VALUES (?, ?, ?, ?, ?);
                    """,
                    (service, from_lang, to_lang, source_text, translated_text),
                )
                conn.commit()
        except Exception as e:
            logger.warning("Cache write failed: %s", e)


class GoogleTranslateClient:
    def __init__(self, cache: TranslationCache, service_name: str = "google_direct"):
        self.cache = cache
        self.service_name = service_name
        self.session = requests.Session()
        self.session.headers.update(
            {
                "User-Agent": (
                    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                    "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
                ),
                "Accept-Language": "en-US,en;q=0.9",
            }
        )

    def translate_text(self, text: str, from_lang: str = "en", to_lang: str = "km") -> str:
        text = text.strip()
        if not text:
            return text

        cached = self.cache.get(self.service_name, from_lang, to_lang, text)
        if cached is not None:
            return cached

        # Chunk if longer than 4000 characters
        if len(text) > 4000:
            chunks = self._chunk_text(text, 3500)
            translated_chunks = [self._translate_single(c, from_lang, to_lang) for c in chunks]
            result = "\n\n".join(translated_chunks)
        else:
            result = self._translate_single(text, from_lang, to_lang)

        self.cache.set(self.service_name, from_lang, to_lang, text, result)
        return result

    def _translate_single(self, text: str, from_lang: str, to_lang: str) -> str:
        retries = 5
        backoff = 1.0
        for attempt in range(retries):
            try:
                resp = self.session.get(
                    "https://translate.google.com/m",
                    params={"sl": from_lang, "tl": to_lang, "q": text},
                    timeout=30,
                )
                if resp.status_code == 200:
                    soup = BeautifulSoup(resp.text, "html.parser")
                    el = soup.find("div", {"class": "result-container"}) or soup.find("div", {"class": "t0"})
                    if el:
                        res = el.get_text(strip=True)
                        if res:
                            return res
                logger.warning(
                    "Translation attempt %d/%d received status %d for text: %s...",
                    attempt + 1,
                    retries,
                    resp.status_code,
                    text[:40],
                )
            except Exception as e:
                logger.warning(
                    "Translation attempt %d/%d failed with error: %s for text: %s...",
                    attempt + 1,
                    retries,
                    e,
                    text[:40],
                )

            if attempt < retries - 1:
                time.sleep(backoff)
                backoff *= 2.0

        raise RuntimeError(f"Translation failed after {retries} attempts for: {text[:60]}...")

    @staticmethod
    def _chunk_text(text: str, max_chunk: int) -> List[str]:
        paragraphs = text.split("\n\n")
        chunks: List[str] = []
        current: List[str] = []
        current_len = 0
        for p in paragraphs:
            if current_len + len(p) + 2 > max_chunk and current:
                chunks.append("\n\n".join(current))
                current = [p]
                current_len = len(p)
            else:
                current.append(p)
                current_len += len(p) + 2
        if current:
            chunks.append("\n\n".join(current))
        return chunks


class MarkdownTranslator:
    def __init__(self, client: GoogleTranslateClient, from_lang: str = "en", to_lang: str = "km"):
        self.client = client
        self.from_lang = from_lang
        self.to_lang = to_lang

    def translate_file(self, input_file: Path, output_file: Path, force: bool = False) -> bool:
        if output_file.exists() and not force:
            logger.info("⏩ Skipping (already exists): %s", output_file.name)
            return True

        logger.info("📖 Translating: %s -> %s", input_file.name, output_file.name)
        content = input_file.read_text(encoding="utf-8", errors="replace")

        translated_content = self.translate_markdown(content)
        output_file.write_text(translated_content, encoding="utf-8")
        logger.info("  ✓ Saved: %s", output_file.name)
        return True

    def translate_markdown(self, markdown_text: str) -> str:
        # Split by two or more newlines, preserving them
        raw_blocks = re.split(r"\n{2,}", markdown_text)
        translated_blocks = []

        total = len(raw_blocks)
        for idx, block in enumerate(raw_blocks, 1):
            if idx % 10 == 0 or idx == total:
                logger.debug("  Processing block %d/%d...", idx, total)
            translated_blocks.append(self.translate_block(block))

        return "\n\n".join(translated_blocks) + "\n"

    def translate_block(self, block: str) -> str:
        stripped = block.strip()
        if not stripped:
            return block

        # 1. Pure HTML tags block (e.g. <epigraph>, </epigraph>, <cite>, </cite>, etc.)
        if PURE_TAG_BLOCK_PATTERN.fullmatch(stripped):
            return block

        # 2. Markdown horizontal rule
        if stripped in ("---", "***", "___"):
            return block

        # 3. Standalone code block ``` ... ```
        if stripped.startswith("```") and stripped.endswith("```"):
            return block

        # 4. Standalone image block ![alt](url)
        img_match = re.fullmatch(r"!\[(.*?)\]\(([^)]+)\)", stripped)
        if img_match:
            alt, url = img_match.group(1), img_match.group(2)
            if alt.strip():
                trans_alt = self._translate_inline_protected(alt.strip())
                return f"![{trans_alt}]({url})"
            return block

        # 5. Heading block (#+ Title)
        heading_match = re.match(r"^(#{1,6}\s+)(.*)$", block, flags=re.DOTALL)
        if heading_match:
            prefix, title = heading_match.group(1), heading_match.group(2)
            trans_title = self._translate_inline_protected(title)
            return f"{prefix}{trans_title}"

        # 6. List block (all non-empty lines start with bullet or number)
        lines = block.splitlines()
        is_list = len(lines) > 0 and all(
            re.match(r"^\s*([*+-]|\d+\.)\s+", line) for line in lines if line.strip()
        )
        if is_list:
            trans_lines = []
            for line in lines:
                m = re.match(r"^(\s*([*+-]|\d+\.)\s+)(.*)$", line)
                if m:
                    prefix, item_text = m.group(1), m.group(3)
                    trans_text = self._translate_inline_protected(item_text)
                    trans_lines.append(f"{prefix}{trans_text}")
                else:
                    trans_lines.append(line)
            return "\n".join(trans_lines)

        # 7. Blockquote block (> Line)
        is_quote = len(lines) > 0 and all(line.strip().startswith(">") for line in lines if line.strip())
        if is_quote:
            clean_lines = [re.sub(r"^\s*>\s?", "", line) for line in lines]
            trans_text = self._translate_inline_protected("\n".join(clean_lines))
            return "\n".join(f"> {l}" if l else ">" for l in trans_text.splitlines())

        # 8. Standard paragraph
        return self._translate_inline_protected(block)

    def _translate_inline_protected(self, text: str) -> str:
        if not text.strip():
            return text

        placeholders: List[str] = []

        def save_ph(match: re.Match) -> str:
            idx = len(placeholders)
            tag = f'<x id="{idx}"/>'
            placeholders.append(match.group(0))
            return tag

        protected = TOKEN_PATTERN.sub(save_ph, text)

        # If everything was protected (e.g. only tags, images or math)
        tokens_only = [t for t in protected.split() if t.strip()]
        if tokens_only and all(
            re.fullmatch(r"<\s*x\s+id=[\"'\x27]?\d+[\"'\x27]?\s*/?>", t.strip(), re.IGNORECASE)
            for t in tokens_only
        ):
            return text

        translated = self.client.translate_text(
            protected, from_lang=self.from_lang, to_lang=self.to_lang
        )

        # Restore placeholders with case and spacing tolerance
        for idx, orig in enumerate(placeholders):
            pattern = re.compile(
                rf"<\s*x\s+id\s*=\s*[\"'\x27]?\s*{idx}\s*[\"'\x27]?\s*/?\s*>",
                re.IGNORECASE,
            )
            translated = pattern.sub(lambda _: orig, translated)

        return translated


def get_target_files(targets: List[str], to_lang: str) -> List[Tuple[Path, Path]]:
    """Resolve targets (files or directories) to pairs of (input_file, output_file)."""
    lang_suffix = f"-{to_lang}.md"
    pairs: List[Tuple[Path, Path]] = []

    for target_str in targets:
        target_path = Path(target_str).resolve()
        if target_path.is_file():
            if target_path.name.endswith(lang_suffix):
                logger.debug("Skipping already translated target file: %s", target_path.name)
                continue
            if target_path.suffix.lower() == ".md":
                out_name = f"{target_path.stem}-{to_lang}.md"
                pairs.append((target_path, target_path.parent / out_name))
        elif target_path.is_dir():
            for f in sorted(target_path.glob("*.md")):
                if f.name.endswith(lang_suffix):
                    continue
                out_name = f"{f.stem}-{to_lang}.md"
                pairs.append((f, target_path / out_name))
        else:
            logger.warning("Target not found: %s", target_str)

    return pairs


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Translate Markdown files in a directory to Khmer (ORIGINALNAME-km.md)."
    )
    parser.add_argument(
        "targets",
        nargs="*",
        default=["."],
        help="Directories or markdown files to translate (default: current directory)",
    )
    parser.add_argument(
        "-F", "--from-lang", default="en", help="Source language (default: en)"
    )
    parser.add_argument(
        "-T", "--to-lang", default="km", help="Target language (default: km)"
    )
    parser.add_argument(
        "-f", "--force", action="store_true", help="Force re-translation even if output exists"
    )
    parser.add_argument(
        "--dry-run", action="store_true", help="Show files to translate without translating"
    )
    parser.add_argument(
        "--cache-db", type=Path, default=None, help="Path to SQLite cache DB"
    )

    args = parser.parse_args()

    file_pairs = get_target_files(args.targets, args.to_lang)
    if not file_pairs:
        logger.warning("No markdown files found to translate.")
        sys.exit(0)

    logger.info("Found %d markdown file(s) to process:", len(file_pairs))
    for in_f, out_f in file_pairs:
        status = " (exists)" if out_f.exists() else " (new)"
        logger.info("  • %s -> %s%s", in_f.name, out_f.name, status)

    if args.dry_run:
        logger.info("Dry-run complete. Exiting.")
        sys.exit(0)

    cache = TranslationCache(args.cache_db)
    client = GoogleTranslateClient(cache)
    translator = MarkdownTranslator(client, from_lang=args.from_lang, to_lang=args.to_lang)

    success_count = 0
    start_time = time.time()
    for idx, (in_f, out_f) in enumerate(file_pairs, 1):
        logger.info("[%d/%d] Processing file: %s", idx, len(file_pairs), in_f.name)
        ok = translator.translate_file(in_f, out_f, force=args.force)
        if ok:
            success_count += 1

    elapsed = time.time() - start_time
    logger.info(
        "🎉 Successfully processed %d/%d file(s) in %.1fs!",
        success_count,
        len(file_pairs),
        elapsed,
    )


if __name__ == "__main__":
    main()
