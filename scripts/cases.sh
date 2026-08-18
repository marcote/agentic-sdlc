#!/usr/bin/env bash
# cases.sh — makes a `📋 case` row resolve.
#
# A 📋 case row is a criterion scored by judgment rather than by an assertion. The case file is what
# an independent judge reads. Nothing checked that the row named one, so a row whose case was never
# written and a row whose case is merely unscored rendered identically in the matrix.
#
# A row resolves when all three hold:
#   1. it names a path under evals/cases/
#   2. that file exists
#   3. that file names the row's criterion label
#
# Condition 3 costs nothing today -- every resolving row already binds -- and it is the only one
# that catches a row repointed at the wrong file. The cheap moment to add it is before the drift.
#
#   scripts/cases.sh                            whole repo: specs/*/coverage.md + evals/cases/
#   scripts/cases.sh --matrix FILE --base DIR   one matrix, cited paths resolved under DIR
#
# Exit contract:
#   0 = every 📋 case row resolves
#   1 = a row names no path, or its file does not name its criterion
#   2 = a named file does not exist, or a matrix header cannot be understood
#
# WHY COLUMNS ARE FOUND BY HEADER NAME: specs/001-example/coverage.md has SIX columns, not seven.
# Split on the pipe it yields the same field count, so a fixed-index reader does not fail -- it
# reads the wrong column and reports confidently. Its criterion column parsed as `project` while
# this was being measured.
#
# WHY ONLY TABLE ROWS ARE READ: every matrix carries a status legend naming `📋 case` outside any
# table. A `grep -c` over the matrices counted those 19 lines and produced the figure that sent this
# feature after 32 rows when there were 14.
set -u

MATRIX=""; BASE="."
while [ $# -gt 0 ]; do
  case "$1" in
    --matrix) MATRIX="${2:-}"; shift 2 ;;
    --base)   BASE="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,28p' "$0"; exit 0 ;;
    *) echo "cases: unknown argument: $1" >&2; exit 2 ;;
  esac
done

# "1 case row(s)" is not English and the assertions that read this output had to match a literal
# nobody would write. Pluralise once, here.
plural(){ [ "$1" = "1" ] && echo "row" || echo "rows"; }

CASE_MISSING=2
CASE_UNRESOLVED=1
CASE_BADHEADER=2
# The matrix is read by the ONE reader (026). This file used to locate columns by header itself and
# then grep every `|` line in the document, which meant a second table below the matrix was filtered
# out by luck -- its status cell happened to be empty -- rather than being out of range.
. "$(dirname "$0")/lib/matrix.sh"

CITED="$(mktemp 2>/dev/null || mktemp -t cscited)"
trap 'rm -f "$CITED"' EXIT
T0=$(python3 -c 'import time; print("%.2f" % time.time())' 2>/dev/null || echo 0)
ROWS=0; RESOLVED=0; UNRES=0; MISS=0; RC=0

scan_matrix(){
  local m="$1" lab org cell st pil n=0 r=0 p
  if ! matrix_header "$m" >/dev/null 2>&1; then
    echo "UNREADABLE  $m — its header names no criterion or status column"
    RC=$CASE_BADHEADER; return
  fi
  while IFS=$'\t' read -r lab org cell st pil; do
    [ -n "$lab" ] || continue
    case "$st" in *case*) ;; *) continue ;; esac
    n=$((n+1)); ROWS=$((ROWS+1))
    p=$(printf '%s' "$cell" | tr -d '`' | grep -oE 'evals/cases/[A-Za-z0-9._-]+' | head -1)
    if [ -z "$p" ]; then
      echo "UNRESOLVED  $lab ($m) — names no case file under evals/cases/"
      UNRES=$((UNRES+1)); [ "$RC" -eq 2 ] || RC=$CASE_UNRESOLVED; continue
    fi
    echo "$p" >> "$CITED"
    if [ ! -f "$BASE/$p" ]; then
      echo "MISSING     $lab ($m) — cites $p, which does not exist"
      MISS=$((MISS+1)); RC=$CASE_MISSING; continue
    fi
    # `grep -c` prints 0 AND exits 1 on no match, so `|| echo 0` yields the two-line string "0\n0"
    # and the numeric test then errors out mid-row. Ask the question as a question.
    CASE_BIND=0; grep -qF "$lab" "$BASE/$p" 2>/dev/null && CASE_BIND=1
    if [ "${CASE_BIND:-0}" -eq 0 ]; then
      echo "UNBOUND     $lab ($m) — $p exists and does not name that criterion"
      UNRES=$((UNRES+1)); [ "$RC" -eq 2 ] || RC=$CASE_UNRESOLVED; continue
    fi
    r=$((r+1)); RESOLVED=$((RESOLVED+1))
  done <<EOF
$(matrix_rows "$m")
EOF
  [ -n "$MATRIX" ] || printf '%-46s %2d case %s, %2d resolved\n' "$m" "$n" "$(plural "$n")" "$r"
}

if [ -n "$MATRIX" ]; then
  scan_matrix "$MATRIX"
else
  for m in specs/*/coverage.md; do [ -f "$m" ] && scan_matrix "$m"; done
fi

# The mirror direction: a case file nobody cites. Zero today, and the check must be able to SAY
# zero -- a directory nobody points at is the same silence as a row pointing nowhere.
ORPH=0
CASE_CITED="$CITED"
for f in "$BASE"/evals/cases/*; do
  [ -f "$f" ] || continue
  rel="evals/cases/$(basename "$f")"
  if ! grep -qxF "$rel" "${CASE_CITED:-/dev/null}" 2>/dev/null; then
    echo "ORPHAN      $rel — no 📋 case row cites it"
    ORPH=$((ORPH+1))
  fi
done

T1=$(python3 -c 'import time; print("%.2f" % time.time())' 2>/dev/null || echo 0)
EL=$(python3 -c "print('%.2fs' % ($T1 - $T0))" 2>/dev/null || echo "?")
CASE_OK_MSG="cases: $ROWS case $(plural "$ROWS"), $RESOLVED resolved, $UNRES unresolved, $MISS missing, $ORPH orphan — elapsed $EL"
echo "---"
echo "${CASE_OK_MSG:-}"
exit "$RC"
