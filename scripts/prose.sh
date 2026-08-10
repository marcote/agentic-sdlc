#!/usr/bin/env bash
# prose.sh — sentence-length check over repo artifacts (read-only).
#
#   scripts/prose.sh [--max N] [PATH...]
#
# Exit: 0 clean · 1 sentences over the cap (each named with file, length and opening words)
#       · 2 unusable input. Dependency-free: bash + python3 stdlib.
#
# WHAT IT ENFORCES: one thing. No sentence in artifact prose runs longer than the cap.
# WHAT IT DOES NOT: word choice, paragraph length, repetition, whether the point is worth making.
# Those stay with review. A short sentence can still be padding.
#
# Tables, fenced blocks and blockquotes are skipped: they are data and citations, not prose.
set -u
MAX=35; PATHS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --max) MAX="${2:-35}"; shift 2 ;;
    -*)    echo "prose: unknown argument: $1" >&2; exit 2 ;;
    *)     PATHS+=("$1"); shift ;;
  esac
done
[ "${#PATHS[@]}" -gt 0 ] || PATHS=(specs memory docs)
python3 - "$MAX" "${PATHS[@]}" <<'PY'
import sys, os, re, glob
mx = int(sys.argv[1]); roots = sys.argv[2:]
files = []
for r in roots:
    files += glob.glob(os.path.join(r, "**", "*.md"), recursive=True) if os.path.isdir(r) else [r]
bad = 0
for f in sorted(set(files)):
    fenced = False
    try:
        lines = open(f, encoding="utf-8").read().splitlines()
    except OSError:
        continue
    for line in lines:
        if line.lstrip().startswith("```"):
            fenced = not fenced; continue
        if fenced or line.startswith(("|", ">")):
            continue
        # a `[deriv$ ... $]` block is a command, not prose. Counting its words made the rule
        # penalise a precise derivation, which is the opposite of what both rules are for.
        s = re.sub(r"\[deriv\$.*?\$\]", "X", line)
        s = re.sub(r"`[^`]*`", "X", s)
        for part in re.split(r"(?<=[.:;!?])\s+", s):
            n = len(part.split())
            if n > mx:
                print("%s: %d-word sentence (cap %d): %s…" % (f, n, mx, part.strip()[:60]))
                bad += 1
if bad:
    print("prose: %d sentence(s) over %d words across %s" % (bad, mx, ", ".join(roots)))
sys.exit(1 if bad else 0)
PY
