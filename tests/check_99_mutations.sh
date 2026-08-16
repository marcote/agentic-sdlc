# Sourced by tests/run.sh (lib.sh already loaded). Contract of the mutation runner
# (scripts/mutate.sh): a criterion declares the edit that must break it, and the runner applies
# that edit in a sandbox and requires the criterion to fail.
#
# `check-can-fail` has been injected as a coverage row since 015 and never executed once. It was
# satisfied by a human writing "proved failable" in a report. This is the same move 017 made for
# `[deriv:]` -> `[deriv$ … $]`: a prose promise becomes a command the suite runs.
#
# Exit contract of the deliverable:
#   0 = every declared mutation broke its criterion
#   1 = at least one criterion was not proved failable (named, with its mutation)
#   2 = unusable input: a malformed or unbound declaration, or no tests directory
#
# CLI contract:
#   scripts/mutate.sh list --tests DIR          one line per declaration: FILE:LINE:LABEL
#   scripts/mutate.sh run  --tests DIR [--only LABEL]

MUT=scripts/mutate.sh
# Per-invocation scratch, for the same reason mutate.sh needs one: this file is executed BY the
# runner, so an inner run and an outer run of it are live at once.
M99=$(mktemp -d 2>/dev/null || mktemp -d -t m99)
MFX=tests/fixtures/mutations
have_mut(){ [ -f "$MUT" ]; }
mrepo(){ local r; r=$(mktemp -d 2>/dev/null || mktemp -d -t mut); mkdir -p "$r/tests"; cp tests/lib.sh "$r/tests/" 2>/dev/null; echo "$r"; }

# --- MUT-GRAMMAR: a declaration binds to the criterion header above it ---
# --- [mut$ sed -i.bak 's|^      label = l$|      label = ""|' scripts/mutate.sh $] ---
R=$(mrepo)
cat > "$R/tests/check_a.sh" <<'FIXTURE'
# --- ALPHA: a thing that is true ---
# --- [mut$ true $] ---
if true; then _pass "ALPHA: ok"; else _fail "ALPHA: no"; fi
FIXTURE
if have_mut; then ( cd "$R" && bash "$OLDPWD/$MUT" list --tests tests ) >"$M99/out" 2>&1; MRC=$?; fi
if have_mut && [ "${MRC:-9}" -eq 0 ] && grep -q 'ALPHA' "$M99/out"; then
  _pass "MUT-GRAMMAR: the declaration in $R/tests/check_a.sh binds to ALPHA"
else
  _fail "MUT-GRAMMAR: declaration not bound (rc=${MRC:-absent}, out: $(head -1 "$M99/out" 2>/dev/null))"
fi
rm -rf "$R"

# --- MUT-UNBOUND-REJECTED: a declaration under no criterion header is rejected by name ---
# --- [mut$ sed -i.bak 's|rc=2|rc=0|' scripts/mutate.sh $] ---
R=$(mrepo)
cat > "$R/tests/check_b.sh" <<'FIXTURE'
# --- [mut$ true $] ---
echo "orphan declaration, bound to nothing"
FIXTURE
if have_mut; then ( cd "$R" && bash "$OLDPWD/$MUT" list --tests tests ) >"$M99/out" 2>&1; MRC=$?; fi
if have_mut && [ "${MRC:-9}" -eq 2 ] && grep -qiE 'unbound|no criterion' "$M99/out"; then
  _pass "MUT-UNBOUND-REJECTED: exit 2 naming the unbound declaration in $R/tests/check_b.sh"
else
  _fail "MUT-UNBOUND-REJECTED: unbound declaration not rejected (rc=${MRC:-absent})"
fi
rm -rf "$R"

# --- MUT-REQUIRES-FAIL: a mutation that does break its criterion is reported as proved ---
# --- [mut$ sed -i.bak 's/proved/prXved/g' scripts/mutate.sh $] ---
R=$(mrepo); printf 'GOOD\n' > "$R/subject.txt"
cat > "$R/tests/check_c.sh" <<'FIXTURE'
# --- BETA: the subject says GOOD ---
# --- [mut$ printf 'BAD\n' > subject.txt $] ---
if grep -q GOOD subject.txt; then _pass "BETA: subject is GOOD"; else _fail "BETA: subject changed"; fi
FIXTURE
( cd "$R" && git init -q . && git add -A >/dev/null 2>&1 )
if have_mut; then ( cd "$R" && bash "$OLDPWD/$MUT" run --tests tests ) >"$M99/out" 2>&1; MRC=$?; fi
if have_mut && [ "${MRC:-9}" -eq 0 ] && grep -qiE 'BETA.*proved|proved.*BETA' "$M99/out"; then
  _pass "MUT-REQUIRES-FAIL: BETA proved failable by its declared mutation"
else
  _fail "MUT-REQUIRES-FAIL: rc=${MRC:-absent}, out: $(head -2 "$M99/out" 2>/dev/null | tr '\n' ' ')"
fi
rm -rf "$R"

# --- MUT-CATCHES-VACUOUS: the runner's own negative ---
# A runner that reports every criterion as failable while applying nothing is indistinguishable
# from one that works. This is the criterion that makes the difference observable.
# --- [mut$ sed -i.bak 's|FAILED=$((FAILED+1))|:|g' scripts/mutate.sh $] ---
R=$(mrepo); printf 'GOOD\n' > "$R/subject.txt"
cat > "$R/tests/check_d.sh" <<'FIXTURE'
# --- GAMMA: an assertion that cannot fail, because its input comes from its own subject ---
# --- [mut$ printf 'ANYTHING ELSE\n' > subject.txt $] ---
_g=$(cat subject.txt)
if grep -qF "$_g" subject.txt; then _pass "GAMMA: subject contains itself"; else _fail "GAMMA: impossible"; fi
FIXTURE
( cd "$R" && git init -q . && git add -A >/dev/null 2>&1 )
if have_mut; then ( cd "$R" && bash "$OLDPWD/$MUT" run --tests tests ) >"$M99/out" 2>&1; MRC=$?; fi
if have_mut && [ "${MRC:-9}" -eq 1 ] && grep -q 'GAMMA' "$M99/out" \
   && grep -qiE 'not proved|survived|did not' "$M99/out"; then
  _pass "MUT-CATCHES-VACUOUS: GAMMA reported as not proved, with the mutation that failed to break it"
else
  _fail "MUT-CATCHES-VACUOUS: a self-satisfying criterion was reported as proved (rc=${MRC:-absent})"
fi
rm -rf "$R"

# --- MUT-SILENCE-IS-NOT-FAILURE: absent and failed are different observations ---
# --- [mut$ sed -i.bak 's|elif \[ "$got_fail" -eq 0 \] && \[ "$got_pass" -eq 0 \]; then|elif false; then|' scripts/mutate.sh $] ---
R=$(mrepo); printf 'GOOD\n' > "$R/subject.txt"
cat > "$R/tests/check_e.sh" <<'FIXTURE'
# --- DELTA: emits only when the subject file exists ---
# --- [mut$ rm -f subject.txt $] ---
if [ -f subject.txt ]; then
  if grep -q GOOD subject.txt; then _pass "DELTA: GOOD"; else _fail "DELTA: not GOOD"; fi
fi
FIXTURE
( cd "$R" && git init -q . && git add -A >/dev/null 2>&1 )
if have_mut; then ( cd "$R" && bash "$OLDPWD/$MUT" run --tests tests ) >"$M99/out" 2>&1; MRC=$?; fi
if have_mut && [ "${MRC:-9}" -eq 1 ] && grep -q 'DELTA' "$M99/out" && grep -qiE 'no result|silent|nothing' "$M99/out"; then
  _pass "MUT-SILENCE-IS-NOT-FAILURE: DELTA emitting nothing is reported as not proved"
else
  _fail "MUT-SILENCE-IS-NOT-FAILURE: silence read as failure (rc=${MRC:-absent})"
fi
rm -rf "$R"

# --- MUT-APPLY-ERROR-DISTINCT: could-not-apply is not the same as did-not-break ---
# --- [mut$ sed -i.bak 's/could not be applied/did not break/' scripts/mutate.sh $] ---
R=$(mrepo); printf 'GOOD\n' > "$R/subject.txt"
cat > "$R/tests/check_f.sh" <<'FIXTURE'
# --- EPSILON: the subject says GOOD ---
# --- [mut$ sed -i.bak 's/x/y/' /nonexistent/path/that/cannot/exist $] ---
if grep -q GOOD subject.txt; then _pass "EPSILON: GOOD"; else _fail "EPSILON: not GOOD"; fi
FIXTURE
( cd "$R" && git init -q . && git add -A >/dev/null 2>&1 )
if have_mut; then ( cd "$R" && bash "$OLDPWD/$MUT" run --tests tests ) >"$M99/out" 2>&1; MRC=$?; fi
if have_mut && [ "${MRC:-9}" -ne 0 ] && grep -qiE 'could not be applied|apply failed' "$M99/out"; then
  _pass "MUT-APPLY-ERROR-DISTINCT: an unappliable mutation gets its own diagnostic"
else
  _fail "MUT-APPLY-ERROR-DISTINCT: apply failure conflated with did-not-break (rc=${MRC:-absent})"
fi
rm -rf "$R"

# --- MUT-SANDBOXED: the real tree is byte-identical afterwards ---
# --- [mut$ sed -i.bak 's/mktemp -d/echo ./' scripts/mutate.sh $] ---
_mdig(){ find "$1" -type f 2>/dev/null | LC_ALL=C sort | while read -r f; do cksum "$f"; done; }
_before=$(_mdig tests/fixtures)
have_mut && bash "$MUT" run --tests "$MFX" >"$M99/replay" 2>&1
_after=$(_mdig tests/fixtures)
if have_mut && [ "$_before" = "$_after" ]; then
  _pass "MUT-SANDBOXED: tests/fixtures byte-identical after a full replay run"
else
  _fail "MUT-SANDBOXED: the runner wrote into the real tree at tests/fixtures"
fi

# --- MUT-REPLAY-019: the shipped vacuous NS-PREDICATE-REACHABLE is caught ---
# From babac0a^, character-identical. Its input was built by interpolating the artifact under test.
# --- [mut$ sed -i.bak 's/NS-PREDICATE-REACHABLE/NS-PREDICATE-UNREACHABLE/' tests/fixtures/mutations/check_replay_019.sh $] ---
if have_mut && grep -qE 'NOT PROVED +NS-PREDICATE-REACHABLE .*survived its own mutation' "$M99/replay"; then
  _pass "MUT-REPLAY-019: the shipped form of NS-PREDICATE-REACHABLE is reported as not proved"
else
  _fail "MUT-REPLAY-019: the real 019 defect is not caught by this mechanism"
fi

# --- MUT-REPLAY-018: the shipped vacuous ADOPT-REL-RESOLUTION is caught ---
# From 3adc719^, character-identical. Its expected and actual came from copies of the same tree.
# --- [mut$ sed -i.bak 's/ADOPT-REL-RESOLUTION/ADOPT-REL-RESOLUTIOX/' tests/fixtures/mutations/check_replay_018.sh $] ---
if have_mut && grep -qE 'NOT PROVED +ADOPT-REL-RESOLUTION .*survived its own mutation' "$M99/replay"; then
  _pass "MUT-REPLAY-018: the shipped form of ADOPT-REL-RESOLUTION is reported as not proved"
else
  _fail "MUT-REPLAY-018: the real 018 defect is not caught by this mechanism"
fi

# --- MUT-COST-REPORTED: a mandatory cost that hides itself cannot be judged (ADR 0004) ---
# --- [mut$ sed -i.bak 's|^elapsed()|elapsed_removed()|' scripts/mutate.sh $] ---
# A real duration, not the word "elapsed": removing the timing helper leaves the label in place
# and the number gone, and the first version of this criterion could not tell those apart.
# Only the total is asserted here — this replay run has no `proved` line, by design.
if have_mut && grep -qE 'total elapsed [0-9]+\.[0-9]+s' "$M99/replay"; then
  _pass "MUT-COST-REPORTED: elapsed time reported per mutation and in total"
else
  _fail "MUT-COST-REPORTED: the runner does not report what it costs"
fi

# --- MUT-SELF-APPLIED: this feature's own criteria are subject to it (D4 condition 2) ---
# The gate bootstrap exemption is from being BLOCKED, never from being RUN. Both counts come from
# the runner, so a parser that missed declarations and headers equally would pass here — which is
# exactly why this criterion's own mutation deletes a declaration rather than breaking the parser.
# --- [mut$ grep -v '^# --- \[mut\$' tests/check_99_mutations.sh > /tmp/x99 && mv /tmp/x99 tests/check_99_mutations.sh $] ---
_decl99=$(have_mut && bash "$MUT" list     --tests tests 2>/dev/null | grep -c 'check_99_mutations.sh')
_crit99=$(have_mut && bash "$MUT" criteria --tests tests 2>/dev/null | grep -c 'check_99_mutations.sh')
if have_mut && [ "${_decl99:-0}" -eq "${_crit99:-1}" ] && [ "${_crit99:-0}" -ge 12 ]; then
  _pass "MUT-SELF-APPLIED: all $_crit99 criteria in tests/check_99_mutations.sh declare a mutation"
else
  _fail "MUT-SELF-APPLIED: $_decl99 declaration(s) for $_crit99 criteria in tests/check_99_mutations.sh"
fi

# --- MUT-WIRED: the runner is invoked somewhere, so it cannot be accepted and never run ---
# base/pin-template.md names this failure mode as worse than a vacuous check: nothing looks wrong,
# validation passes, and the author believes the thing is enforced. The runner is deliberately NOT
# inside tests/run.sh -- it re-runs check files, and a check file invoking it would re-enter it
# once per declaration, multiplied again by check_96's own suite re-run. It runs where Guards run.
# --- [mut$ sed -i.bak '/mutate.sh run/d' .github/workflows/verify.yml $] ---
_wired_ci=0; _wired_skill=0
grep -qE 'mutate\.sh run' .github/workflows/verify.yml 2>/dev/null && _wired_ci=1
grep -qE 'mutate\.sh run' .claude/skills/verify/SKILL.md 2>/dev/null && _wired_skill=1
if [ "$_wired_ci" -eq 1 ] && [ "$_wired_skill" -eq 1 ]; then
  _pass "MUT-WIRED: invoked by .github/workflows/verify.yml and by the /verify skill"
else
  _fail "MUT-WIRED: not invoked (ci=$_wired_ci skill=$_wired_skill) — a runner nobody runs"
fi

# --- MUT-DEPFREE: S3's baseline, tied to the deliverable ---
# --- [mut$ printf 'npm install\n' >> scripts/mutate.sh $] ---
if have_mut; then assert_dep_free "$MUT" "MUT-DEPFREE"
else _fail "MUT-DEPFREE: deliverable $MUT absent, so its baseline cannot be asserted"; fi

# --- HERMETIC-ENV-99: assembled at runtime so this scan cannot match its own line ---
# 019 wrote this row into its coverage and then broke it with a git ref. The sandbox here uses
# `git ls-files`, which needs no branch and no remote.
# --- [mut$ printf 'read x < /dev/tty\n' >> scripts/mutate.sh $] ---
# Comment lines are stripped first. mutate.sh DOCUMENTS `git show main:…` as the mistake 019
# made, and a comment-blind scan reads the documentation as the defect — the same false positive
# has_placeholder and prose_only exist to avoid.
_T99='/dev'; _T99="$_T99/t""ty"
_code99=$(have_mut && grep -vE '^[[:space:]]*#' "$MUT" 2>/dev/null)
if have_mut && ! printf '%s' "$_code99" | grep -q "$_T99" \
   && ! printf '%s' "$_code99" | grep -qE 'git (show|rev-parse) [^ ]*(origin/)?main'; then
  _pass "HERMETIC-ENV-99: $MUT assumes no terminal and resolves no branch ref"
else
  _fail "HERMETIC-ENV-99: $MUT reads a terminal or depends on a branch that a shallow checkout lacks"
fi
# ── 021: the audit of 018's and 019's mutation tables ───────────────────────────────────
A21_98=tests/check_98_adoption.sh

# --- AUDIT-COVERAGE-COMPLETE: every criterion of 018 and 019 declares a mutation ---
# 018 recorded 11 mutations against 16 criteria. Seven had none, and the report read as though
# failability was established for the feature.
# --- [mut$ sed -i.bak '/rm -f tests\/fixtures\/adopter\/scripts\/test.sh/d' tests/check_98_adoption.sh $] ---
# The audited set is a historical fact -- which criteria features 018 and 019 shipped -- so it is
# written out rather than derived. A derivation would drift as later features add criteria to the
# same files, and then the audit would silently grow or shrink.
A21_SET="ADOPT-FIXTURE-BUDGET ADOPT-FIXTURE-DROP ADOPT-VENDOR-APPLY ADOPT-SEED-PRESERVED
ADOPT-CHARTER-PINS ADOPT-NS-VALID ADOPT-GR-COVERED ADOPT-REL-RESOLUTION ADOPT-GUARD-BY-NAME
ADOPT-GUARD-CLEAN ADOPT-GUARD-FAILS ADOPT-NO-SILENT-EMPTY ADOPT-UNCOVERED-FIRES S2-HEDGE-98
HERMETIC-ENV-98 ADOPT-SANDBOX-CLEAN ADOPT-TESTCMD-INVOKED ADOPT-TESTCMD-NOT-COUNTED
NS-LIFECYCLE-PREDICATES NS-BOUNDARY-BOUNDED NS-PREDICATE-REACHABLE NS-ADOPTION-STAYS-IN-SCOPE
NS-REJECTS-NOTHING-BUILT NS-ADR-0005-COMPLETE AMEND-LIFECYCLE-REFLEXIVE AMEND-PROVENANCE-QUIET"
_a21_gap=0; _a21_n=0
_a21_decl=$(have_mut && bash "$MUT" list --tests tests 2>/dev/null)
for _lab in $A21_SET; do
  _a21_n=$((_a21_n+1))
  printf '%s\n' "$_a21_decl" | grep -q ":$_lab$" || _a21_gap=$((_a21_gap+1))
done
if have_mut && [ "$_a21_gap" -eq 0 ] && [ "$_a21_n" -eq 26 ]; then
  _pass "AUDIT-COVERAGE-COMPLETE: all $_a21_n criteria of 018 and 019 declare a mutation (018 had recorded 11 of 18)"
else
  _fail "AUDIT-COVERAGE-COMPLETE: $_a21_gap of $_a21_n audited criteria have no declared mutation"
fi

# --- AUDIT-ALL-PROVED: the audited set is kept proved, and its result is recorded ---
# NOT run from here. `mutate.sh run --tests tests` re-runs this very file once per declaration, so
# invoking it from inside the suite is a 40x40 explosion -- the reentrancy 020's plan named and
# that I then walked into. It runs where Guards run: at /verify and in CI (MUT-WIRED). What the
# suite asserts is that the result was recorded with its numbers, the same way a Guard's result is.
# --- [mut$ sed -i.bak 's|mutation(s) under tests, 0 not proved|mutation(s) under tests, 9 not proved|' verification/reports/021-mutation-audit-*.md $] ---
_a21_rep21=$(ls verification/reports/021-mutation-audit-*.md 2>/dev/null | head -1)
if grep -qE '4[0-9] mutation\(s\) under tests, 0 not proved' "$_a21_rep21" 2>/dev/null; then
  _pass "AUDIT-ALL-PROVED: $_a21_rep21 records the audited run at 0 not proved"
else
  _fail "AUDIT-ALL-PROVED: no recorded audited run in ${_a21_rep21:-verification/reports/021-*}"
fi

# --- MUT-MULTILABEL-REJECTED: a header naming two criteria is unbindable, and says so ---
# nvc.sh reads both labels of such a header; mutate.sh read NEITHER, so both criteria were absent
# from the coverage count and neither could carry a mutation. Silent omission.
# --- [mut$ sed -i.bak '/multi-label criterion header/d' scripts/mutate.sh $] ---
R=$(mrepo)
cat > "$R/tests/check_ml.sh" <<'FIXTURE'
# --- ONE · TWO: two criteria sharing one header ---
if true; then _pass "ONE: ok"; else _fail "ONE: no"; fi
FIXTURE
if have_mut; then ( cd "$R" && bash "$OLDPWD/$MUT" criteria --tests tests ) >"$M99/ml" 2>&1; MRC=$?; fi
if have_mut && [ "${MRC:-9}" -eq 2 ] && grep -qiE 'multi-label|two criteria|unbindable' "$M99/ml"    && grep -q 'check_ml.sh' "$M99/ml"; then
  _pass "MUT-MULTILABEL-REJECTED: exit 2 naming $R/tests/check_ml.sh and the shape"
else
  _fail "MUT-MULTILABEL-REJECTED: a multi-label header was skipped, not rejected (rc=${MRC:-absent})"
fi
rm -rf "$R"

# --- MUT-SELFSCAN-SKIPS-DECLARATION: a scan over its own file ignores comment lines ---
# A [mut$ … $] declaration lives INSIDE the file it mutates, so a scan for a forbidden literal
# reads its own scaffolding as the defect. Both check_98 scans went red the moment their
# declarations were written; neither criterion was wrong.
# --- [mut$ sed -i.bak 's|grep -vE .\^\[\[:space:\]\]\*#. tests/check_98_adoption.sh | cat tests/check_98_adoption.sh |g' tests/check_98_adoption.sh $] ---
_a21_scans=$(grep -cE "grep -vE '\^\[\[:space:\]\]\*#' $A21_98" "$A21_98" 2>/dev/null)
if [ "${_a21_scans:-0}" -ge 2 ]    && grep -q 'mutation declaration lives in' memory/constitution/base/patterns/non-vacuous-checks.md; then
  _pass "MUT-SELFSCAN-SKIPS-DECLARATION: $_a21_scans self-scans in $A21_98 strip comments; the rule is in the pattern"
else
  _fail "MUT-SELFSCAN-SKIPS-DECLARATION: $_a21_scans of 2 self-scans strip comments, or the pattern does not state it"
fi

# --- AUDIT-REPORTS-CORRECTED: the two reports record what the audit found ---
# --- [mut$ sed -i.bak '/## 6. Mutation audit/d' verification/reports/018-adoption-fixture-3adc719.md $] ---
_a21_rep=0
for _r21 in verification/reports/018-adoption-fixture-*.md verification/reports/019-lifecycle-boundary-*.md; do
  grep -q '## 6. Mutation audit' "$_r21" 2>/dev/null && _a21_rep=$((_a21_rep+1))
done
if [ "$_a21_rep" -eq 2 ]; then
  _pass "AUDIT-REPORTS-CORRECTED: both audited reports carry their audit section, neither feature reopened"
else
  _fail "AUDIT-REPORTS-CORRECTED: $_a21_rep of 2 reports corrected in place"
fi

# --- AUDIT-COST-REPORTED: the audited run says what it costs ---
# --- [mut$ sed -i.bak 's|total elapsed|total hidden|' verification/reports/021-mutation-audit-*.md $] ---
if grep -qE 'total elapsed [0-9]+\.[0-9]+s' "$_a21_rep21" 2>/dev/null; then
  _pass "AUDIT-COST-REPORTED: $_a21_rep21 carries the measured total elapsed time"
else
  _fail "AUDIT-COST-REPORTED: no measured total in ${_a21_rep21:-verification/reports/021-*}"
fi

rm -rf "$M99"
