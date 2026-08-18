# Sourced by tests/run.sh (lib.sh already loaded). Contract of the shared matrix reader
# (scripts/lib/matrix.sh): ONE parser for specs/*/coverage.md, bound to the coverage table.
#
# Three tools read the matrix and each grew its own parser. Split on the pipe, a six-column row and
# a seven-column row yield the same field count -- so a fixed-index reader does not fail, it reads a
# different column and reports confidently. Measured on main before this feature:
#   status.sh named the Origin cell as the criterion on 001-example (wrong since 008)
#   status.sh reported a phantom orphan row from 022's trailing measurement table
#   mutate.sh coverage and cases.sh were correct only because the cell they mistook for Status
#   happened to be empty
#
# Interface:
#   matrix_header FILE -> "PILLAR CRIT ORIGIN LINK STATUS FIRST LAST"; empty when none qualifies
#
# The interface was SIX fields when this contract was written. The seventh (PILLAR) was forced by
# the third port: status.sh's orphan test is "a row with no pillar", and against specs/001-example's
# six-column matrix that flags every row. plan.md named this risk before the work -- "if the third
# port needs an interface change, the first two must be re-run against their baselines rather than
# assumed still correct" -- and they were.
#   matrix_rows   FILE -> tab-separated data rows of THAT table only

MLIB=scripts/lib/matrix.sh
M91=$(mktemp -d 2>/dev/null || mktemp -d -t m91)
MFIX=tests/fixtures/matrix
have_mlib(){ [ -f "$MLIB" ]; }
# mrun CODE : source the reader in a subshell and run CODE, capturing into $M91/out.
mrun(){ if have_mlib; then ( . "$MLIB"; eval "$1" ) >"$M91/out" 2>&1; MRC=$?; else MRC=9; fi; }

# --- MTX-HEADER-FOUND: the coverage table is located by its header, not assumed ---
# --- [mut$ sed -i.bak 's|criterion|crIterion|' scripts/lib/matrix.sh $] ---
mrun "matrix_header $MFIX/seven.md"
if have_mlib && [ "$(cat "$M91/out" | wc -w | tr -d ' ')" = "7" ]; then
  _pass "MTX-HEADER-FOUND: seven indices for $MFIX/seven.md — $(cat "$M91/out")"
else
  _fail "MTX-HEADER-FOUND: header not located (rc=${MRC:-absent}): $(head -1 "$M91/out" 2>/dev/null)"
fi

# --- MTX-SIX-AND-SEVEN: layout does not change the answer ---
# The whole defect class: both layouts split into the same field count, so only the header tells
# them apart. Forcing the seven-column index is what status.sh does today.
# --- [mut$ sed -i.bak 's|_mx_crit = idx("criterion")|_mx_crit = 5|' scripts/lib/matrix.sh $] ---
mrun "matrix_rows $MFIX/six.md"
cp "$M91/out" "$M91/six" 2>/dev/null
mrun "matrix_rows $MFIX/seven.md"
if have_mlib && grep -q 'MTX-ALPHA' "$M91/six" && grep -q 'MTX-ALPHA' "$M91/out" \
   && [ "$(head -1 "$M91/six" | cut -f1)" = "MTX-ALPHA" ]; then
  _pass "MTX-SIX-AND-SEVEN: MTX-ALPHA read from both layouts; neither yielded the Origin cell"
else
  _fail "MTX-SIX-AND-SEVEN: layout changed the criterion: six=[$(head -1 "$M91/six" 2>/dev/null)]"
fi

# --- MTX-SECOND-TABLE-EXCLUDED: rows come from the coverage table, and stop where it stops ---
# 022's coverage.md ends with a measurement table. status.sh read its header as a criterion row and
# printed "orphan row (no pillar):" with no name. Out of RANGE, not filtered afterwards.
# --- [mut$ sed -i.bak 's|if (!_mx_last) _mx_last = total|_mx_last = total|' scripts/lib/matrix.sh $] ---
mrun "matrix_rows $MFIX/second-table.md"
if have_mlib && grep -q 'MTX-ALPHA' "$M91/out" && ! grep -q 'MTX-LEAKED' "$M91/out" \
   && [ "$(grep -c . "$M91/out")" = "1" ]; then
  _pass "MTX-SECOND-TABLE-EXCLUDED: 1 row from $MFIX/second-table.md; the measurement table is out of range"
else
  _fail "MTX-SECOND-TABLE-EXCLUDED: $(grep -c . "$M91/out" 2>/dev/null) rows, second table leaked"
fi

# --- MTX-NO-TABLE-REPORTED: a file with no qualifying table yields nothing, and says so ---
# --- [mut$ sed -i.bak 's|return 1|return 0|' scripts/lib/matrix.sh $] ---
mrun "matrix_header $MFIX/no-table.md"
if have_mlib && [ "${MRC:-9}" -ne 0 ] && [ ! -s "$M91/out" ]; then
  _pass "MTX-NO-TABLE-REPORTED: non-zero and empty for $MFIX/no-table.md"
else
  _fail "MTX-NO-TABLE-REPORTED: a file with no matrix was parsed anyway (rc=${MRC:-absent})"
fi

# --- MTX-LABEL-TRIMMED: surrounding space and backticks go, internal spaces stay ---
# 023 stripped every space because this harness names criteria UPPER-KEBAB. 001-example's criterion
# is the prose "message clarity", and the binding check went red against a correct file.
# --- [mut$ sed -i.bak 's|return v }|gsub(/ /, "", v); return v }|' scripts/lib/matrix.sh $] ---
mrun "matrix_rows $MFIX/spaced-label.md"
if have_mlib && grep -q 'message clarity' "$M91/out" && ! grep -q 'messageclarity' "$M91/out"; then
  _pass "MTX-LABEL-TRIMMED: 'message clarity' kept its internal space"
else
  _fail "MTX-LABEL-TRIMMED: the label was stripped, not trimmed: $(head -1 "$M91/out" 2>/dev/null)"
fi

# --- MTX-IDEM-IN-RANGE: idem resolves within its own table, never across one ---
# --- [mut$ sed -i.bak 's|NR < lo \|\| NR > hi { next }|NR < lo { next }|' scripts/lib/matrix.sh $] ---
mrun "matrix_rows $MFIX/idem-across-tables.md"
if have_mlib && grep -q 'MTX-BETA.*check_x\.sh' "$M91/out" && ! grep -q 'MTX-LATER' "$M91/out"; then
  _pass "MTX-IDEM-IN-RANGE: MTX-BETA inherited within its table; MTX-LATER is in another one"
else
  _fail "MTX-IDEM-IN-RANGE: idem crossed a table boundary: $(cat "$M91/out" 2>/dev/null | tr '\n' ' ')"
fi

# --- STATUS-NAMES-CRITERION: the defect that shipped in 008 ---
# 001-example has six columns; status.sh read $5 and printed the Origin cell as the criterion.
# --- [mut$ sed -i.bak 's|matrix_rows|matrix_rows_absent|g' scripts/status.sh $] ---
_m91_s=$(bash scripts/status.sh 001-example 2>/dev/null | grep 'non-green:')
if printf '%s' "$_m91_s" | grep -q 'idempotency by key' && ! printf '%s' "$_m91_s" | grep -q 'base/idempotency'; then
  _pass "STATUS-NAMES-CRITERION: status.sh names 'idempotency by key', not the Origin cell"
else
  _fail "STATUS-NAMES-CRITERION: status.sh still names the wrong column: [$_m91_s]"
fi

# --- STATUS-NO-PHANTOM-ORPHAN: the measurement table is not a criterion row ---
# --- [mut$ sed -i.bak 's@covrows(){ matrix_rows@covrows(){ grep "^|" @' scripts/status.sh $] ---
if ! bash scripts/status.sh 022-mutation-coverage 2>/dev/null | grep -q 'orphan row'; then
  _pass "STATUS-NO-PHANTOM-ORPHAN: no orphan row for 022; its measurement table is out of range"
else
  _fail "STATUS-NO-PHANTOM-ORPHAN: status.sh still reads 022's measurement table as criteria"
fi

# --- MTX-SINGLE-READER: no consumer splits coverage.md on the pipe on its own ---
# Comment lines are stripped: this criterion's own declaration names the tools it guards.
# --- [mut$ sed -i.bak 's|^\. "\$(dirname|# unsourced "$(dirname|' scripts/cases.sh $] ---
_m91_src=0; _m91_own=0
for _t in scripts/status.sh scripts/mutate.sh scripts/cases.sh; do
  grep -qE '^[[:space:]]*\.[[:space:]]+.*lib/matrix\.sh' "$_t" 2>/dev/null && _m91_src=$((_m91_src+1))
  grep -vE '^[[:space:]]*#' "$_t" 2>/dev/null | grep -qE "awk -F'\\|'" && _m91_own=$((_m91_own+1))
done
if [ "$_m91_src" -eq 3 ] && [ "$_m91_own" -eq 0 ]; then
  _pass "MTX-SINGLE-READER: 3 of 3 tools source the reader; 0 split the matrix themselves"
else
  _fail "MTX-SINGLE-READER: $_m91_src of 3 source it, $_m91_own still parse the pipe themselves"
fi

# --- MTX-COVERAGE-UNCHANGED: no verdict-bearing number moved for any matrix that predates 026 ---
# `obliged` and `undeclared` decide the exit code, and both are byte-identical to the baseline
# captured from main at 1d506c2 before a line was written.
#
# `excluded` DID move, upward, on 8 of 19 matrices, and the refactor is right and the baseline was
# wrong. The old reader dropped a row before counting it whenever its criterion was prose rather
# than UPPER-KEBAB -- specs/_template's `token < 300ms`, 002's `[given] base/idempotency`. Those
# rows are in the matrix and are excluded by rule; 022's own rule is that exclusion must be a
# COUNTED number and never a silence. The old count was the silence.
#
# This is the one number this feature is allowed to move, and it is named here rather than
# discovered in a diff. Everything else is asserted identical.
# --- [mut$ sed -i.bak 's|org  = idx("origin")|org  = 0|' scripts/lib/matrix.sh $] ---
_m91_base=tests/fixtures/matrix/baseline-coverage.txt
bash scripts/mutate.sh coverage --tests tests --all 2>/dev/null | grep '^specs' >"$M91/cov"
_m91_drift=0; _m91_seen=0; _m91_first=""
while IFS= read -r _bl; do
  [ -n "$_bl" ] || continue
  _m91_seen=$((_m91_seen+1))
  _m91_f=$(printf '%s' "$_bl" | awk '{print $1}')
  _m91_want=$(printf '%s' "$_bl" | grep -oE '[0-9]+ obliged, +[0-9]+ undeclared')
  _m91_got=$(grep -F "$_m91_f " "$M91/cov" | grep -oE '[0-9]+ obliged, +[0-9]+ undeclared')
  [ "$_m91_want" = "$_m91_got" ] || { _m91_drift=$((_m91_drift+1)); [ -n "$_m91_first" ] || _m91_first="$_m91_f: want [$_m91_want] got [$_m91_got]"; }
done < "$_m91_base"
if [ "$_m91_seen" -ge 19 ] && [ "$_m91_drift" -eq 0 ]; then
  _pass "MTX-COVERAGE-UNCHANGED: obliged/undeclared identical for all $_m91_seen pre-026 matrices"
else
  _fail "MTX-COVERAGE-UNCHANGED: $_m91_drift of $_m91_seen drifted — ${_m91_first:-none}"
fi

# --- MTX-CASES-UNCHANGED: same invariant for the case gate ---
# 026 adds one 📋 case row of its own, so the count goes 15 -> 16 -- and 027 made it 17. Asserting
# the exact total was a design error: it breaks on every future feature, forever, for the one reason
# that is never a regression. What must not move is the RESOLUTION: every row resolves, nothing is
# orphaned, and the count never falls below the 15 recorded at the 1d506c2 baseline.
# --- [mut$ sed -i.bak 's|link = idx("linked"); if (!link) link = idx("test/eval")|link = 0|' scripts/lib/matrix.sh $] ---
bash scripts/cases.sh >"$M91/cs" 2>&1; _m91_crc=$?
_m91_n=$(grep -oE '[0-9]+ case rows?' "$M91/cs" | head -1 | grep -oE '[0-9]+')
if [ "$_m91_crc" -eq 0 ] && [ "${_m91_n:-0}" -ge 15 ] \
   && grep -qE "$_m91_n case rows?, $_m91_n resolved, 0 unresolved, 0 missing, 0 orphan" "$M91/cs"; then
  _pass "MTX-CASES-UNCHANGED: $_m91_n rows (>= the 15 at baseline), all resolved, 0 orphan"
else
  _fail "MTX-CASES-UNCHANGED: rc=$_m91_crc — $(tail -1 "$M91/cs" 2>/dev/null)"
fi

# --- MTX-DEPFREE: no installable toolchain ---
# --- [mut$ printf 'npx --yes matrix\n' >> scripts/lib/matrix.sh $] ---
assert_dep_free "$MLIB" "MTX-DEPFREE"

# --- MTX-COST-REPORTED: the added cost is measured, not estimated ---
# --- [mut$ sed -i.bak 's|\*\*1.84s\*\*|about two seconds|' verification/reports/026-matrix-parser-*.md $] ---
_m91_rep=$(ls verification/reports/026-matrix-parser-*.md 2>/dev/null | head -1)
if grep -qE '\*\*[0-9]+\.[0-9]+s\*\*' "${_m91_rep:-/dev/null}" 2>/dev/null; then
  _pass "MTX-COST-REPORTED: ${_m91_rep} carries the measured three-tool figure"
else
  _fail "MTX-COST-REPORTED: no measured cost in ${_m91_rep:-verification/reports/026-*}"
fi

# --- HERMETIC-ENV-91: this check assumes nothing about the ambient environment ---
# Literals assembled, not spelled: this scan reads its own file (check-no-self-match).
# --- [mut$ sed -i.bak 's|^_m91_amb=0$|_m91_amb=0; git show main:README.md >/dev/null 2>\&1|' tests/check_91_matrix.sh $] ---
_m91_amb=0
_m91_pat="git sh""ow (main|origin)|/dev/""tty|\\\$TE""RM"
if grep -vE '^[[:space:]]*#' tests/check_91_matrix.sh | grep -qE "$_m91_pat"; then _m91_amb=1; fi
if [ "$_m91_amb" -eq 0 ]; then
  _pass "HERMETIC-ENV-91: no branch ref, controlling terminal or ambient variable in tests/check_91_matrix.sh"
else
  _fail "HERMETIC-ENV-91: tests/check_91_matrix.sh depends on the ambient environment"
fi

rm -rf "$M91"
