"""Migrate markdown memory files to Qdrant vector store.

Reads .md files, embeds via Ollama, stores in Qdrant directly.
No LLM needed — content is stored as-is.

Usage:
    python migrate_memories.py [--dry-run]
"""

from __future__ import annotations

import asyncio
import os
import re
import sys
from pathlib import Path

from server import mem0_store

MEMORY_DIR = Path(
    os.environ.get(
        "MEMORY_DIR",
        os.path.expanduser(
            "~/.claude/projects/-Users-nelson-frugeri--claude/memory"
        ),
    )
)
SKIP_FILES = {"MEMORY.md"}


def parse_frontmatter(text: str) -> tuple[dict, str]:
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n(.*)", text, re.DOTALL)
    if not match:
        return {}, text
    meta = {}
    for line in match.group(1).splitlines():
        if ":" in line:
            key, _, val = line.partition(":")
            meta[key.strip()] = val.strip()
    return meta, match.group(2).strip()


def load_memories() -> list[dict]:
    memories = []
    for f in sorted(MEMORY_DIR.glob("*.md")):
        if f.name in SKIP_FILES:
            continue
        text = f.read_text(encoding="utf-8")
        meta, body = parse_frontmatter(text)
        if not body:
            continue
        memories.append({
            "filename": f.name,
            "name": meta.get("name", f.stem),
            "type": meta.get("type", "general"),
            "description": meta.get("description", ""),
            "content": body,
        })
    return memories


async def migrate(dry_run: bool = False) -> None:
    memories = load_memories()
    print(f"Found {len(memories)} memories to migrate.\n")

    if dry_run:
        for m in memories:
            print(f"  [{m['type']}] {m['name']} ({m['filename']})")
        print("\n--dry-run: no changes made.")
        return

    success = 0
    for i, m in enumerate(memories, 1):
        content = f"[{m['name']}] {m['description']}\n\n{m['content']}"
        result = await mem0_store(
            content=content,
            memory_type=m["type"],
            tags=f"migration,{m['filename']}",
        )
        import json
        r = json.loads(result)
        status = r.get("status", "error")
        if status == "stored":
            success += 1
            print(f"  [{i}/{len(memories)}] OK: {m['name']}")
        else:
            print(f"  [{i}/{len(memories)}] FAIL: {m['name']} — {r.get('error', '?')}")

    print(f"\nDone: {success}/{len(memories)} migrated.")


if __name__ == "__main__":
    dry_run = "--dry-run" in sys.argv
    asyncio.run(migrate(dry_run))
