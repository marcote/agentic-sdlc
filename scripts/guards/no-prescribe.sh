#!/usr/bin/env bash
# Guard for stack pin S1 — "impose no runtime".
#
# Asserts that nothing in memory/stack/base/ names a tool, language, runtime or vendor
# as a default *in prose*. Names inside fenced blocks and inline code spans are examples,
# not prescriptions, and are ignored — the pin template necessarily illustrates real tools.
#
# Run by /verify via `scripts/stack/engine.py guards`. Exit 0 = the stance holds.
# Dependency-free: shell + coreutils only.
set -u
cd "$(dirname "$0")/../.."

TARGET=${1:-memory/stack/base}

# Word-boundary anchored: an unanchored `rails` matches "guardrails". A dash counts as a
# boundary, so "postgres-first" still trips.
DENY='(^|[^[:alnum:]])(postgres|postgresql|mysql|duckdb|sqlite|mongodb|redis|railway|vercel|heroku|netlify|django|rails|fastapi|express|pytest|jest|vitest|poetry|uv|npm|pnpm|yarn|cargo|gradle|maven|python|bash|ruby|golang|rustc)([^[:alnum:]]|$)'

# prose_only: drop fenced blocks, then inline code spans.
prose_only() { awk '/^[[:space:]]*```/{f=!f; next} !f' "$1" | sed 's/`[^`]*`//g'; }

status=0
found=0
for f in "$TARGET"/*.md; do
  [ -f "$f" ] || continue
  found=1
  if hits=$(prose_only "$f" | grep -inE "$DENY"); then
    status=1
    printf 'no-prescribe: %s names a tool/runtime/vendor in prose:\n' "$f" >&2
    printf '%s\n' "$hits" | sed 's/^/    /' >&2
  fi
done

if [ "$found" -eq 0 ]; then
  # A guard that inspects nothing passes forever. Refuse to be vacuous.
  echo "no-prescribe: no files scanned under $TARGET — guard is vacuous" >&2
  exit 2
fi

exit "$status"
