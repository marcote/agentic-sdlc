# Sourced by tests/run.sh (lib.sh already loaded). Contract of the case-resolution gate
# (scripts/cases.sh): a 📋 case row names a case file, that file exists, and it names the row's
# criterion.
#
# A 📋 case row is a criterion scored by judgment. The case file is what an independent judge reads.
# Nothing checked that the row named one. Measured at /distill: 14 rows, 11 resolving, 2 naming a
# file that does not exist, 1 naming no path -- and the backlog entry that motivated this claimed
# 32 rows and 21 unresolvable, both figures taken from a grep that counted the status-legend line
# present in all 19 matrices.
#
# Exit contract of the deliverable:
#   0 = every 📋 case row resolves (count stated, never silent)
#   1 = a row names no path, or its file does not name its criterion
#   2 = a named file does not exist, or a matrix header cannot be understood
#
# CLI contract:
#   scripts/cases.sh                              whole repo: specs/*/coverage.md + evals/cases/
#   scripts/cases.sh --matrix FILE --base DIR     one matrix, paths resolved under DIR

CASES=scripts/cases.sh
C93=$(mktemp -d 2>/dev/null || mktemp -d -t c93)
CFIX=tests/fixtures/cases
have_cases(){ [ -f "$CASES" ]; }
# cs ARGS... : run the gate, capture into $C93/out, set XRC. Never inspected before have_cases.
cs(){ if have_cases; then bash "$CASES" "$@" >"$C93/out" 2>&1; XRC=$?; else XRC=9; fi; }

# --- CASE-RESOLVES-CLEAN: a resolving row passes, and the pass states a count ---
# Exit 0 with no number would make "no case rows at all" and "every case row resolved" identical.
# --- [mut$ sed -i.bak 's|CASE_OK_MSG="|CASE_OK_MSG_UNUSED="|' scripts/cases.sh $] ---
cs --matrix "$CFIX/seven-col.md" --base "$CFIX"
if have_cases && [ "${XRC:-9}" -eq 0 ] && grep -qE '1 case row' "$C93/out" && grep -qE '1 resolved' "$C93/out"; then
  _pass "CASE-RESOLVES-CLEAN: exit 0 stating 1 case row, 1 resolved"
else
  _fail "CASE-RESOLVES-CLEAN: a clean matrix did not pass with its count (rc=${XRC:-absent}): $(head -2 "$C93/out" 2>/dev/null | tr '\n' ' ')"
fi

# --- CASE-MISSING-FILE: a named case file that does not exist is exit 2, by name ---
# --- [mut$ sed -i.bak 's|^CASE_MISSING=2$|CASE_MISSING=0|' scripts/cases.sh $] ---
cs --matrix "$CFIX/missing.md" --base "$CFIX"
if have_cases && [ "${XRC:-9}" -eq 2 ] && grep -q 'FIX-GONE' "$C93/out" && grep -q 'gone.md' "$C93/out"; then
  _pass "CASE-MISSING-FILE: exit 2 naming FIX-GONE and evals/cases/gone.md"
else
  _fail "CASE-MISSING-FILE: a dangling citation was tolerated (rc=${XRC:-absent})"
fi

# --- CASE-NO-PATH: a row naming no case file blocks, by name ---
# A promise to judge later is not a case file. 022 shipped exactly this row.
# --- [mut$ sed -i.bak 's|^CASE_UNRESOLVED=1$|CASE_UNRESOLVED=0|' scripts/cases.sh $] ---
cs --matrix "$CFIX/nopath.md" --base "$CFIX"
if have_cases && [ "${XRC:-9}" -eq 1 ] && grep -q 'FIX-PROMISE' "$C93/out"; then
  _pass "CASE-NO-PATH: exit 1 naming FIX-PROMISE"
else
  _fail "CASE-NO-PATH: a row citing nothing was tolerated (rc=${XRC:-absent})"
fi

# --- CASE-LABEL-BINDS: the cited file must name the row's criterion ---
# Costs nothing today -- all 11 resolving rows already bind. It is the only condition that catches
# a row repointed at the wrong file, and the cheap moment to add it is before the drift.
# --- [mut$ sed -i.bak '/CASE_BIND/d' scripts/cases.sh $] ---
cs --matrix "$CFIX/nobind.md" --base "$CFIX"
if have_cases && [ "${XRC:-9}" -eq 1 ] && grep -q 'FIX-DRIFTED' "$C93/out" && grep -qi 'does not name' "$C93/out"; then
  _pass "CASE-LABEL-BINDS: exit 1 — unbound.md exists and does not name FIX-DRIFTED"
else
  _fail "CASE-LABEL-BINDS: existence alone bound the row (rc=${XRC:-absent})"
fi

# --- CASE-ORPHAN-FILE-REPORTED: a case file no row cites is named, and the count is always printed ---
# --- [mut$ sed -i.bak 's| orphan| hidden|g' scripts/cases.sh $] ---
cs --matrix "$CFIX/seven-col.md" --base "$CFIX"
if have_cases && grep -q 'lonely.md' "$C93/out" && grep -qE '[0-9]+ orphan' "$C93/out"; then
  _pass "CASE-ORPHAN-FILE-REPORTED: lonely.md named, orphan count printed"
else
  _fail "CASE-ORPHAN-FILE-REPORTED: an uncited case file is invisible: $(head -3 "$C93/out" 2>/dev/null | tr '\n' ' ')"
fi

# --- CASE-COLUMNS-BY-HEADER: six- and seven-column matrices both read correctly ---
# 001-example has SIX columns. Split on the pipe it yields the same field count as seven, so a
# fixed-index reader does not fail -- it reads the wrong column and reports confidently. Its label
# column parsed as `project` while this feature was being measured.
# --- [mut$ sed -i.bak 's|CASE_COL_CRIT=|CASE_COL_CRIT=5; CASE_COL_CRIT_UNUSED=|' scripts/cases.sh $] ---
cs --matrix "$CFIX/six-col.md" --base "$CFIX"
S6RC=${XRC:-9}; cp "$C93/out" "$C93/six" 2>/dev/null
if have_cases && [ "$S6RC" -eq 0 ] && grep -qE '1 resolved' "$C93/six"; then
  _pass "CASE-COLUMNS-BY-HEADER: the six-column matrix resolved FIX-ALPHA like the seven-column one"
else
  _fail "CASE-COLUMNS-BY-HEADER: column layout changed the verdict (rc=$S6RC): $(head -2 "$C93/six" 2>/dev/null | tr '\n' ' ')"
fi

# --- CASE-HEADER-UNREADABLE: a matrix whose header names no criterion or status column is exit 2 ---
# --- [mut$ sed -i.bak 's|^CASE_BADHEADER=2$|CASE_BADHEADER=0|' scripts/cases.sh $] ---
cs --matrix "$CFIX/badheader.md" --base "$CFIX"
if have_cases && [ "${XRC:-9}" -eq 2 ] && grep -q 'badheader.md' "$C93/out"; then
  _pass "CASE-HEADER-UNREADABLE: exit 2 naming $CFIX/badheader.md rather than guessing at it"
else
  _fail "CASE-HEADER-UNREADABLE: an unreadable matrix was parsed anyway (rc=${XRC:-absent})"
fi

# --- CASE-LEGEND-NOT-COUNTED: the marker is read from the STATUS COLUMN, never from the line ---
# This is the miscount that gave B14 its 32: `grep -c` over the matrices counted the legend line
# present in all 19 of them. The fixture carries both traps -- a legend naming the marker outside
# any table, and a 🟢 green row whose prose names it inside one.
# --- [mut$ sed -i.bak 's|st = \$si;|st = $0;|' scripts/cases.sh $] ---
cs --matrix "$CFIX/seven-col.md" --base "$CFIX"
if have_cases && grep -qE '1 case row' "$C93/out" && ! grep -qE '2 case row' "$C93/out"; then
  _pass "CASE-LEGEND-NOT-COUNTED: 1 case row in a matrix whose legend also names the marker"
else
  _fail "CASE-LEGEND-NOT-COUNTED: the legend line was counted as a row: $(head -2 "$C93/out" 2>/dev/null | tr '\n' ' ')"
fi

# --- CASE-MULTI-ROW-FILE: one file cited by three rows resolves all three, counted once ---
# --- [mut$ sed -i.bak 's|CASE_CITED=|CASE_CITED_UNUSED=|' scripts/cases.sh $] ---
cs --matrix "$CFIX/multi.md" --base "$CFIX"
if have_cases && [ "${XRC:-9}" -eq 0 ] && grep -qE '3 case rows' "$C93/out" && grep -qE '3 resolved' "$C93/out" \
   && ! grep -qE 'ORPHAN.*good\.md' "$C93/out"; then
  _pass "CASE-MULTI-ROW-FILE: 3 rows resolved against one file, which is not an orphan"
else
  _fail "CASE-MULTI-ROW-FILE: rows sharing a file did not all resolve (rc=${XRC:-absent})"
fi

# --- CASE-REPO-CLEAN: this repository's own case rows all resolve ---
# Green by construction once the three broken rows are fixed -- it is an integration assertion, not
# a discovery. Its mutation therefore breaks the CHECKER, not a case file.
# --- [mut$ sed -i.bak 's|for m in specs/\*/coverage.md|for m in specs/*/coverage.md tests/fixtures/cases/missing.md|' scripts/cases.sh $] ---
if have_cases; then bash "$CASES" >"$C93/repo" 2>&1; RRC=$?; fi
if have_cases && [ "${RRC:-9}" -eq 0 ] && grep -qE '0 orphan' "$C93/repo"; then
  _pass "CASE-REPO-CLEAN: every 📋 case row resolves — $(grep -oE '[0-9]+ case rows?, [0-9]+ resolved' "$C93/repo" | head -1)"
else
  _fail "CASE-REPO-CLEAN: unresolved case rows or orphan files (rc=${RRC:-absent}): $(grep -E 'UNRESOLVED|MISSING|orphan' "$C93/repo" 2>/dev/null | head -2 | tr '\n' ' ')"
fi

# --- CASE-WIRED: the gate runs where the other resolution gates run, never inside the suite ---
# --- [mut$ sed -i.bak 's|scripts/cases.sh|scripts/caseS.sh|g' .claude/skills/verify/SKILL.md $] ---
_c93_w=0
grep -q 'scripts/cases\.sh' .claude/skills/verify/SKILL.md 2>/dev/null && _c93_w=$((_c93_w+1))
grep -q 'scripts/cases\.sh' .github/workflows/verify.yml 2>/dev/null && _c93_w=$((_c93_w+1))
if [ "$_c93_w" -eq 2 ] && ! grep -q 'cases\.sh' tests/run.sh 2>/dev/null; then
  _pass "CASE-WIRED: named in the verify skill and in CI; absent from tests/run.sh"
else
  _fail "CASE-WIRED: wired in $_c93_w of 2 places, or invoked from tests/run.sh"
fi

# --- CASE-DEPFREE: no installable toolchain ---
# --- [mut$ printf 'npx --yes cases\n' >> scripts/cases.sh $] ---
assert_dep_free "$CASES" "CASE-DEPFREE"

# --- CASE-COST-REPORTED: the run says what it costs, measured ---
# --- [mut$ sed -i.bak 's|elapsed|guessed|g' scripts/cases.sh $] ---
if have_cases && grep -qE 'elapsed [0-9]+\.[0-9]+s' "$C93/repo" 2>/dev/null; then
  _pass "CASE-COST-REPORTED: $(grep -oE 'elapsed [0-9]+\.[0-9]+s' "$C93/repo" | head -1) over the whole repository"
else
  _fail "CASE-COST-REPORTED: no measured elapsed time in the repository-wide output"
fi

# --- HERMETIC-ENV-93: this check assumes nothing about the ambient environment ---
# The forbidden literals are ASSEMBLED: this scan reads its own file, and a spelled-out pattern
# would match itself on a code line, where stripping comments cannot help (check-no-self-match).
# --- [mut$ sed -i.bak 's|^_c93_amb=0$|_c93_amb=0; git show main:README.md >/dev/null 2>\&1|' tests/check_93_case_resolution.sh $] ---
_c93_amb=0
_c93_pat="git sh""ow (main|origin)|/dev/""tty|\\\$TE""RM"
if grep -vE '^[[:space:]]*#' tests/check_93_case_resolution.sh | grep -qE "$_c93_pat"; then
  _c93_amb=1
fi
if [ "$_c93_amb" -eq 0 ]; then
  _pass "HERMETIC-ENV-93: no branch ref, controlling terminal or ambient variable in tests/check_93_case_resolution.sh"
else
  _fail "HERMETIC-ENV-93: tests/check_93_case_resolution.sh depends on the ambient environment"
fi

rm -rf "$C93"
