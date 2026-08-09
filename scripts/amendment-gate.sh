#!/usr/bin/env bash
# amendment-gate — gates changes to the pillars/scope sets of the North Star's canonical
# JSON block. If they changed, requires: (a) a new ADR (decisions/NNNN-*.md), (b) the
# resulting block to be schema-valid (base/schema.md), (c) the suite (tests/run.sh) green.
# Narrow block: if the sets did not change, nothing is blocked (preserves "productivity
# first"). Dependency-free: bash/coreutils + python3 stdlib (json). No installable toolchains.
#
# Modes:
#   --range BASE..HEAD                       (CI: derives old/new/added from git)
#   --files OLD NEW --added "f1 f2 …" [--suite-cmd CMD]   (test: hermetic fixtures)
# Exit 0 = passes (does not block) · exit ≠0 = blocks, citing the missing condition.
set -u

NS_PATH="memory/north-star/north-star.md"
SUITE_CMD=""              # injectable override of suite state (test)
OLD=""; NEW=""; ADDED=""; RANGE=""

die(){ echo "amendment-gate: $*" >&2; exit 1; }

# --- Fail-closed if no system python3 interpreter ---
command -v python3 >/dev/null 2>&1 || die "requires python3 (stdlib json) — not found in environment"

# --- engine: the single source of North Star determinism ---
# All JSON parsing / schema validation / governed-set comparison / ADR detection lives
# in scripts/north-star/engine.py (feature 006). The gate orchestrates; the engine decides.
ENGINE="$(dirname "$0")/north-star/engine.py"
# provenance staleness (016): a pillar whose statement/signal moved while its `since` stayed put.
# ADDITIVE — the governed hash is unchanged. Changing `since` alone is metadata, not an amendment:
# requiring an ADR for it would mean recording that ADR 0005 changed a signal needs ADR 0006,
# forever. This is the inverse check, and it is where the value is: it makes the record
# self-maintaining instead of a convention someone has to remember.
stale_provenance(){ # OLD NEW -> prints offending pillar ids, exit 0 if any
  python3 - "$1" "$2" <<'PROV'
import sys, json, re
def load(p):
    m = re.search(r"```json\s*\n(.*?)\n```", open(p, encoding="utf-8").read(), re.S)
    return json.loads(m.group(1)) if m else {}
try:
    old, new = load(sys.argv[1]), load(sys.argv[2])
except Exception:
    sys.exit(1)
o = {p.get("id"): p for p in old.get("pillars", []) if isinstance(p, dict)}
bad = []
for p in new.get("pillars", []):
    if not isinstance(p, dict):
        continue
    q = o.get(p.get("id"))
    if not q:
        continue                     # a new pillar is a set change, already governed
    governed_moved = (q.get("statement"), q.get("signal")) != (p.get("statement"), p.get("signal"))
    if governed_moved and q.get("since") == p.get("since"):
        bad.append("%s (since stayed %s)" % (p.get("id"), p.get("since")))
print("\n".join(bad))
sys.exit(0 if bad else 1)
PROV
}
[ -f "$ENGINE" ] || die "missing engine: $ENGINE"

# --- suite_green : the suite is green (injectable override in tests) ---
suite_green(){
  if [ -n "$SUITE_CMD" ]; then eval "$SUITE_CMD"; else bash tests/run.sh >/dev/null 2>&1; fi
}

# --- argument parsing ---
while [ $# -gt 0 ]; do
  case "$1" in
    --range)     RANGE="$2"; shift 2 ;;
    --files)     OLD="$2"; NEW="$3"; shift 3 ;;
    --added)     ADDED="$2"; shift 2 ;;
    --suite-cmd) SUITE_CMD="$2"; shift 2 ;;
    *) die "unknown argument: $1" ;;
  esac
done

# --- --range mode: derive OLD/NEW/ADDED from git ---
if [ -n "$RANGE" ]; then
  BASE="${RANGE%%..*}"; HEAD="${RANGE##*..}"; [ -n "$HEAD" ] || HEAD="HEAD"
  # Invalid BASE (first push / force-push: 000…) → fall back to HEAD's parent; if not, fail-closed
  if ! git cat-file -e "${BASE}^{commit}" 2>/dev/null; then
    BASE="$(git rev-parse "${HEAD}~1" 2>/dev/null)" || die "invalid base range with no parent — manual review required"
  fi
  TMP_OLD="$(mktemp)"; TMP_NEW="$(mktemp)"
  trap 'rm -f "$TMP_OLD" "$TMP_NEW"' EXIT
  git show "${BASE}:${NS_PATH}" > "$TMP_OLD" 2>/dev/null || die "could not read ${NS_PATH} at base"
  git show "${HEAD}:${NS_PATH}" > "$TMP_NEW" 2>/dev/null || cp "$NS_PATH" "$TMP_NEW"
  OLD="$TMP_OLD"; NEW="$TMP_NEW"
  ADDED="$(git diff --name-status --diff-filter=A "$BASE" "$HEAD" 2>/dev/null | awk '{print $2}' | tr '\n' ' ')"
fi

[ -n "$OLD" ] && [ -n "$NEW" ] || die "missing --files OLD NEW (or --range BASE..HEAD)"

# --- Gate logic ---
if [ "$(python3 "$ENGINE" sets-changed "$OLD" "$NEW")" = "same" ]; then
  echo "amendment-gate: no change to pillars/scope sets — not applicable (dev not blocked)"
  exit 0
fi

# The sets changed: it is a governed amendment. Require all four conditions.
# Provenance first: it names the specific pillar, so a stale record is fixed in one edit rather
# than after chasing the other three.
if _stale=$(stale_provenance "$OLD" "$NEW"); then
  die "amendment moves a pillar's statement/signal WITHOUT updating its since: $(printf '%s' "$_stale" | tr '\n' ' ')(comparing $OLD -> $NEW)"
fi
if ! python3 "$ENGINE" has-adr-for --added "$ADDED"; then
  die "amendment of pillars/scope WITHOUT a new ADR (memory/north-star/decisions/NNNN-*.md)"
fi
if ! python3 "$ENGINE" schema-valid "$NEW"; then
  die "amendment leaves the North Star NOT schema-valid (see base/schema.md)"
fi
if ! suite_green; then
  die "amendment with suite failing — tests/run.sh must be green"
fi

echo "amendment-gate: amendment OK (new ADR + schema-valid + suite green)"
exit 0
