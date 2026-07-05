#!/usr/bin/env bash
# vendor.sh — copy-once vendoring of the harness onto an existing repo.
# Dependency-free: bash/coreutils + git (for provenance). No installable toolchain.
#
#   scripts/vendor.sh <target>            dry-run: print the plan, write nothing (default)
#   scripts/vendor.sh --apply <target>    apply the vendoring
#
# KEEP = governance, copied verbatim, OVERWRITES (authoritative, idempotent).
# SEED = customizable layer, stub if absent, NEVER clobbered (writes <file>.harness-new).
# DROP = harness-self content, never copied (allowlist: DROP is simply never in the copy set).
set -u

APPLY=0; TARGET=""
while [ $# -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    -h|--help) echo "usage: vendor.sh [--apply] <target-dir>"; exit 0 ;;
    -*) echo "vendor: unknown option $1" >&2; exit 1 ;;
    *) TARGET="$1"; shift ;;
  esac
done
[ -n "$TARGET" ] || { echo "usage: vendor.sh [--apply] <target-dir>" >&2; exit 1; }

SRC="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$TARGET"; TARGET="$(cd "$TARGET" && pwd)"

# --- Classification (single source of truth; docs/vendoring.md mirrors this) ---
KEEP=(
  .claude/commands .claude/skills .claude/hooks .claude/settings.json
  memory/constitution/base memory/constitution/update-checklist.md
  memory/north-star/base
  specs/_template
  evals/rubric.md evals/README.md
  verification/uat-checklist.md verification/code-review-checklist.md verification/verification-report.md
  docs/factory-model.md docs/workflow.md
  scripts/north-star/engine.py scripts/amendment-gate.sh scripts/setup-branch-protection.sh
  .github/workflows/amendment-gate.yml
)
SEED=( CLAUDE.md memory/constitution/constitution.md memory/north-star/north-star.md scripts/test.sh )
DROP=( "specs/0*-* (except _template)" memory/north-star/decisions verification/reports \
  verification/wow-report.md docs/superpowers evals/cases README.md tests \
  scripts/vendor.sh docs/vendoring.md )

# --- Stack detection -> default test command ---
detect_testcmd(){
  if   [ -f "$TARGET/package.json" ]; then echo "npm test"
  elif [ -f "$TARGET/pyproject.toml" ] || [ -f "$TARGET/setup.py" ] || [ -f "$TARGET/setup.cfg" ]; then echo "pytest"
  elif [ -f "$TARGET/go.mod" ]; then echo "go test ./..."
  elif [ -f "$TARGET/Cargo.toml" ]; then echo "cargo test"
  else echo ""; fi
}
TESTCMD="$(detect_testcmd)"

provenance_line(){
  if git -C "$SRC" rev-parse HEAD >/dev/null 2>&1; then
    local sha remote dirty
    sha="$(git -C "$SRC" rev-parse HEAD)"
    remote="$(git -C "$SRC" remote get-url origin 2>/dev/null || echo '(no remote)')"
    [ -n "$(git -C "$SRC" status --porcelain 2>/dev/null)" ] && dirty=" (dirty)" || dirty=""
    echo "source: $remote @ $sha$dirty"
  else
    echo "source: non-git source"
  fi
}

NEWFILES=()

# --- Stub contents ---
claude_stub(){ cat <<'EOF'
# <Your Project> — Agentic SDLC Harness (vendored)

Governance harness vendored via `scripts/vendor.sh`. Fill in your stack below,
then run `/constitution` and seed your North Star before your first `/align`.

## Stack
_(your language/framework; your test command lives in `scripts/test.sh`)_

## Workflow
`/constitution` → brief → `/align` → `/distill` → `/plan` → `/contract` → `/tasks`
→ implement → `/verify` → `/uat` → `/retro`. See `docs/workflow.md`.

## Hard rules (details in memory/constitution/)
- No deterministic criterion advances to implementation without a test in 🔴 RED (`/contract`).
- A feature closes only with BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
EOF
}
constitution_stub(){ cat <<'EOF'
---
extends: base
---

# Constitution — Project

Extends `base` (see `base/principles.md`). Add project-specific principles and overrides
here. Overriding a `base/pattern` requires explicit justification.

## Project deltas
_(none yet — add yours)_
EOF
}
northstar_stub(){ cat <<'EOF'
---
extends: base
---

# North Star — <Your Product>

> Replace this placeholder with your product's North Star, then run `/align`.
> The shared `base/` (schema, rubric, protocol) stays; your delta is mission, pillars, scope.

## Canonical North Star

```json
{
  "mission": "TODO: one sentence — why this product exists",
  "pillars": [
    { "id": "todo-pillar", "statement": "TODO: what it means", "signal": "TODO: measurable indicator" }
  ],
  "scope": {
    "in_scope": ["TODO: what this product does"],
    "out_of_scope": ["TODO: what it explicitly does not do"]
  },
  "alignment": { "threshold": 3 }
}
```
EOF
}
testsh_stub(){
  cat <<EOF
#!/usr/bin/env bash
# Seeded by vendor.sh. The one command the workflow (\`/contract\`, \`/verify\`) runs.
set -e
EOF
  if [ -n "$TESTCMD" ]; then echo "$TESTCMD"; else echo "# TODO: set your test command"; fi
}

seed_file(){ # path, content
  local p="$1" content="$2"
  mkdir -p "$TARGET/$(dirname "$p")"
  if [ -e "$TARGET/$p" ]; then
    printf '%s\n' "$content" > "$TARGET/$p.harness-new"; NEWFILES+=("$p.harness-new")
  else
    printf '%s\n' "$content" > "$TARGET/$p"
    [ "$p" = "scripts/test.sh" ] && chmod +x "$TARGET/$p"
  fi
}

copy_keep(){
  local p src dst
  for p in "${KEEP[@]}"; do
    src="$SRC/$p"; dst="$TARGET/$p"
    [ -e "$src" ] || continue
    if [ -d "$src" ]; then mkdir -p "$dst"; cp -R "$src/." "$dst/"; else mkdir -p "$(dirname "$dst")"; cp "$src" "$dst"; fi
  done
}

print_plan(){
  echo "vendor.sh plan → target: $TARGET"
  echo "provenance: $(provenance_line) · date: $(date +%F)"
  echo "stack: ${TESTCMD:-unknown} → scripts/test.sh"
  echo "KEEP (governance, copied verbatim, overwrites):"
  local p; for p in "${KEEP[@]}"; do echo "  KEEP  $p"; done
  echo "SEED (stub if absent, never clobbered → .harness-new):"
  for p in "${SEED[@]}"; do
    if [ -e "$TARGET/$p" ]; then echo "  SEED  $p  (exists → .harness-new)"; else echo "  SEED  $p"; fi
  done
  echo "DROP (harness-self, never copied):"
  for p in "${DROP[@]}"; do echo "  DROP  $p"; done
}

if [ "$APPLY" -eq 0 ]; then
  print_plan
  echo "(dry-run — nothing written; re-run with --apply)"
  exit 0
fi

# --- apply ---
copy_keep
seed_file "CLAUDE.md" "$(claude_stub)"
seed_file "memory/constitution/constitution.md" "$(constitution_stub)"
seed_file "memory/north-star/north-star.md" "$(northstar_stub)"
seed_file "scripts/test.sh" "$(testsh_stub)"

{
  echo "# Harness vendoring provenance"
  provenance_line
  echo "date: $(date +%F)"
  echo "test-command: ${TESTCMD:-(unknown — TODO in scripts/test.sh)}"
  if [ "${#NEWFILES[@]}" -gt 0 ]; then
    echo "needs-merge (.harness-new):"; for f in "${NEWFILES[@]}"; do echo "  - $f"; done
  else
    echo "needs-merge: none"
  fi
} > "$TARGET/.harness-provenance"

echo "vendor.sh: applied to $TARGET"
if [ "${#NEWFILES[@]}" -gt 0 ]; then
  echo "  ${#NEWFILES[@]} file(s) need merge (.harness-new):"
  for f in "${NEWFILES[@]}"; do echo "    - $f"; done
fi
echo "  next: /constitution → seed your North Star → first feature (see docs/vendoring.md)"
