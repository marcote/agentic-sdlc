#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["markdown>=3.6"]
# ///
"""prose.py — check the prose of every agent-facing file (the spec lint's sentence limit).

  uv run scripts/prose.py

Exit: 0 clean · 1 findings.
"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import spec  # noqa: E402

GLOBS = ["AGENTS.md", "memory/**/*.md", "harness/prompts/*.md", "harness/steps/*.md", "specs/*/spec.md"]


def main():
    files = sorted({f for g in GLOBS for f in Path().glob(g) if not str(f).startswith(spec.HISTORY)})
    found = [f"{f}: {m}" for f in files for m in spec.prose(f.read_text())]
    print("\n".join(found))
    sys.exit(1 if found else 0)


if __name__ == "__main__":
    main()
