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
command -v python3 >/dev/null 2>&1 || die "requiere python3 (stdlib json) — ausente en el entorno"

# --- python3 helper: extracts the canonical ```json block and operates on it ---
# Usage: _py sets_changed OLD NEW  |  _py schema_valid FILE
_py(){
  python3 - "$@" <<'PYEOF'
import sys, json, re

def load(path):
    with open(path, encoding="utf-8") as fh:
        txt = fh.read()
    m = re.search(r"```json\s*\n(.*?)\n```", txt, re.S)
    if not m:
        raise ValueError("sin bloque ```json en %s" % path)
    return json.loads(m.group(1))

def sig(ns):
    """Semantic signature of the governed sets: pillars and scope, order-agnostic."""
    pillars = frozenset(
        (p.get("id"), p.get("statement"), p.get("signal"))
        for p in ns.get("pillars", [])
    )
    sc = ns.get("scope", {}) or {}
    scope = (frozenset(sc.get("in_scope", []) or []),
             frozenset(sc.get("out_of_scope", []) or []))
    return (pillars, scope)

def nonempty_str(v): return isinstance(v, str) and v.strip() != ""

def validate(ns):
    if not nonempty_str(ns.get("mission")):
        return "mission vacío o ausente"
    pillars = ns.get("pillars")
    if not isinstance(pillars, list) or len(pillars) < 1:
        return "pillars debe ser array con >=1 entrada"
    for i, p in enumerate(pillars):
        for k in ("id", "statement", "signal"):
            if not nonempty_str(p.get(k)):
                return "pillars[%d].%s vacío o ausente" % (i, k)
    sc = ns.get("scope")
    if not isinstance(sc, dict):
        return "scope ausente"
    for k in ("in_scope", "out_of_scope"):
        arr = sc.get(k)
        if not isinstance(arr, list) or len(arr) < 1 or not all(nonempty_str(x) for x in arr):
            return "scope.%s debe ser array de strings no vacío" % k
    al = ns.get("alignment")
    if not isinstance(al, dict) or not isinstance(al.get("threshold"), (int, float)):
        return "alignment.threshold debe ser número"
    return ""  # valid

cmd = sys.argv[1]
try:
    if cmd == "sets_changed":
        old, new = load(sys.argv[2]), load(sys.argv[3])
        print("changed" if sig(old) != sig(new) else "same")
        sys.exit(0)
    elif cmd == "schema_valid":
        reason = validate(load(sys.argv[2]))
        if reason:
            sys.stderr.write(reason + "\n"); sys.exit(1)
        sys.exit(0)
    else:
        sys.stderr.write("comando desconocido: %s\n" % cmd); sys.exit(2)
except Exception as e:  # broken JSON / missing block → treat as schema-invalid / error
    sys.stderr.write(str(e) + "\n")
    sys.exit(1 if cmd == "schema_valid" else 2)
PYEOF
}

# --- has_new_adr ADDED… : is any added file a new ADR? ---
has_new_adr(){
  local f
  for f in "$@"; do
    case "$f" in
      *memory/north-star/decisions/[0-9][0-9][0-9][0-9]-*.md) return 0 ;;
    esac
  done
  return 1
}

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
    *) die "argumento desconocido: $1" ;;
  esac
done

# --- --range mode: derive OLD/NEW/ADDED from git ---
if [ -n "$RANGE" ]; then
  BASE="${RANGE%%..*}"; HEAD="${RANGE##*..}"; [ -n "$HEAD" ] || HEAD="HEAD"
  # Invalid BASE (first push / force-push: 000…) → fall back to HEAD's parent; if not, fail-closed
  if ! git cat-file -e "${BASE}^{commit}" 2>/dev/null; then
    BASE="$(git rev-parse "${HEAD}~1" 2>/dev/null)" || die "rango base inválido y sin padre — revisión manual requerida"
  fi
  TMP_OLD="$(mktemp)"; TMP_NEW="$(mktemp)"
  trap 'rm -f "$TMP_OLD" "$TMP_NEW"' EXIT
  git show "${BASE}:${NS_PATH}" > "$TMP_OLD" 2>/dev/null || die "no pude leer ${NS_PATH} en base"
  git show "${HEAD}:${NS_PATH}" > "$TMP_NEW" 2>/dev/null || cp "$NS_PATH" "$TMP_NEW"
  OLD="$TMP_OLD"; NEW="$TMP_NEW"
  ADDED="$(git diff --name-status --diff-filter=A "$BASE" "$HEAD" 2>/dev/null | awk '{print $2}' | tr '\n' ' ')"
fi

[ -n "$OLD" ] && [ -n "$NEW" ] || die "faltan --files OLD NEW (o --range BASE..HEAD)"

# --- Gate logic ---
if [ "$(_py sets_changed "$OLD" "$NEW")" = "same" ]; then
  echo "amendment-gate: sin cambio de sets pillars/scope — no aplica (dev no bloqueado)"
  exit 0
fi

# The sets changed: it is a governed amendment. Require all three conditions.
# shellcheck disable=SC2086
if ! has_new_adr $ADDED; then
  die "amendment de pillars/scope SIN ADR nuevo (memory/north-star/decisions/NNNN-*.md)"
fi
if ! _py schema_valid "$NEW"; then
  die "amendment deja el North Star NO schema-válido (ver base/schema.md)"
fi
if ! suite_green; then
  die "amendment con la suite en rojo — tests/run.sh debe estar verde"
fi

echo "amendment-gate: amendment OK (ADR nuevo + schema-válido + suite verde)"
exit 0
