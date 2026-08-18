# Sourced by tests/run.sh (lib.sh already loaded). Contract of the mutation-coverage gate
# (scripts/mutate.sh coverage): WHICH criteria are obliged to declare a mutation, and whether they
# do.
#
# 020 made the proving repeatable; nothing made it required. 021 measured that the real gap in the
# two audited features was coverage -- seven of 018's sixteen criteria had never declared one --
# so the obligation is derived from the artifact that already names a feature's criteria: its
# coverage matrix.
#
# Exit contract of the deliverable:
#   0 = every obliged criterion declares a mutation (count stated, never silent)
#   1 = at least one obliged criterion declares none, each named
#   2 = a row that looks obliged cannot be resolved, or unusable input
#
# CLI contract:
#   scripts/mutate.sh coverage --spec PATH --tests DIR    gate one feature (dir or coverage.md)
#   scripts/mutate.sh coverage --all --tests DIR          report every specs/*/coverage.md

MUT=scripts/mutate.sh
M97=$(mktemp -d 2>/dev/null || mktemp -d -t m97)
CFX=tests/fixtures/covgate
have_mut(){ [ -f "$MUT" ]; }
# cov ARGS... : run the gate, capture into $M97/out, set CRC. Never inspected before have_mut.
cov(){ if have_mut; then bash "$MUT" coverage --tests tests "$@" >"$M97/out" 2>&1; CRC=$?; else CRC=9; fi; }

# --- COV-OBLIGED-PREDICATE: origin, status and a resolvable check file, all three ---
# The mixed fixture carries one obliged+declared row, one obliged+bare row, and three that own no
# assertion: a [given] inherited row, a case row scored by judgment, a deferred row.
# --- [mut$ sed -i.bak 's|!~ /project/|!~ /projectNEVER/|' scripts/mutate.sh $] ---
cov --spec "$CFX/mixed.md"
if have_mut && grep -qE '2 obliged' "$M97/out" \
   && ! grep -q 'check-can-fail' "$M97/out" && ! grep -q 'FIXTURE-JUDGE' "$M97/out"; then
  _pass "COV-OBLIGED-PREDICATE: 2 obliged in $CFX/mixed.md; given/case/deferred rows own no assertion"
else
  _fail "COV-OBLIGED-PREDICATE: wrong obliged set (rc=${CRC:-absent}): $(head -3 "$M97/out" 2>/dev/null | tr '\n' ' ')"
fi

# --- COV-GAP-NAMED: an obliged criterion that declares nothing blocks, by name ---
# --- [mut$ sed -i.bak 's|^COV_GAP=1$|COV_GAP=0|' scripts/mutate.sh $] ---
cov --spec "$CFX/mixed.md"
if have_mut && [ "${CRC:-9}" -eq 1 ] && grep -q 'FIXTURE-BARE' "$M97/out"; then
  _pass "COV-GAP-NAMED: exit 1 naming FIXTURE-BARE"
else
  _fail "COV-GAP-NAMED: a criterion with no declaration did not block by name (rc=${CRC:-absent})"
fi

# --- COV-IDEM-RESOLVED: an `idem` cell inherits the check file of the row above ---
# FIXTURE-BARE is deliberately the idem row. It can only be reported at all if idem resolved --
# an unresolved idem would drop it from the obligation, and the gate would read clean.
# --- [mut$ sed -i.bak 's|/idem/|/idemNEVER/|' scripts/mutate.sh $] ---
cov --spec "$CFX/mixed.md"
if have_mut && grep -q 'FIXTURE-BARE' "$M97/out" && grep -qE '2 obliged' "$M97/out"; then
  _pass "COV-IDEM-RESOLVED: the idem row resolved to check_fixture.sh and stayed obliged"
else
  _fail "COV-IDEM-RESOLVED: an idem cell was dropped from the obligation (rc=${CRC:-absent})"
fi

# --- COV-NOT-OBLIGED-COUNTED: a row excluded by rule is a number, not a silence ---
# --- [mut$ sed -i.bak 's| excluded| hidden|g' scripts/mutate.sh $] ---
cov --spec "$CFX/mixed.md"
if have_mut && grep -qE '3 excluded' "$M97/out"; then
  _pass "COV-NOT-OBLIGED-COUNTED: 3 rows excluded by rule, reported as a count"
else
  _fail "COV-NOT-OBLIGED-COUNTED: exclusion is silent: $(head -3 "$M97/out" 2>/dev/null | tr '\n' ' ')"
fi

# --- COV-CLEAN-PASSES: a fully declared feature exits 0 and states what it found ---
# Exit 0 with no count would make "nothing obliged" and "all obliged and declared" identical.
# --- [mut$ sed -i.bak 's|COV_OK_MSG="coverage:|COV_OK_MSG_UNUSED="coverage:|' scripts/mutate.sh $] ---
cov --spec "$CFX/clean.md"
if have_mut && [ "${CRC:-9}" -eq 0 ] && grep -qE '2 obliged' "$M97/out" && grep -qE '0 undeclared' "$M97/out"; then
  _pass "COV-CLEAN-PASSES: exit 0 stating 2 obliged, 0 undeclared"
else
  _fail "COV-CLEAN-PASSES: a clean matrix did not pass with its count (rc=${CRC:-absent})"
fi

# --- COV-UNRESOLVABLE-REPORTED: a named check file that does not exist is exit 2, not an exemption ---
# --- [mut$ sed -i.bak 's|^COV_UNRESOLVED=2$|COV_UNRESOLVED=0|' scripts/mutate.sh $] ---
cov --spec "$CFX/missing-check.md"
if have_mut && [ "${CRC:-9}" -eq 2 ] && grep -q 'FIXTURE-MISSING' "$M97/out" && grep -q 'check_00_typo.sh' "$M97/out"; then
  _pass "COV-UNRESOLVABLE-REPORTED: exit 2 naming FIXTURE-MISSING and check_00_typo.sh"
else
  _fail "COV-UNRESOLVABLE-REPORTED: a missing check file became a silent exemption (rc=${CRC:-absent})"
fi

# --- COV-TYPO-NOT-EXEMPTION: a script name matching no check_*.sh is exit 2 ---
# Extraction finds nothing in `chek_97_…`. Without the .sh fallback the row leaves the obligation
# silently, and the failure renders identically to the success -- B11.
# The edit deletes the fallback BRANCH, not the variable: a global rename would rename the
# definition and its use together and the branch would keep working — a mutation that reads
# destructive and is inert. The pattern ends in a quote so it misses the definition line.
# --- [mut$ sed -i.bak '/COV_SH_FALLBACK"/d' scripts/mutate.sh $] ---
cov --spec "$CFX/not-a-check.md"
if have_mut && [ "${CRC:-9}" -eq 2 ] && grep -q 'FIXTURE-TYPO' "$M97/out"; then
  _pass "COV-TYPO-NOT-EXEMPTION: exit 2 naming FIXTURE-TYPO rather than dropping the row"
else
  _fail "COV-TYPO-NOT-EXEMPTION: a typo'd script name became a silent exemption (rc=${CRC:-absent})"
fi

# --- COV-ALL-REPORTS-DEBT: the standing debt is re-derived, per feature and in total ---
# Not a stored snapshot: a figure written into a report goes stale as features are added, and a
# stale number is worse than none. It names the tree it read (check-names-its-tree).
# --- [mut$ sed -i.bak 's|COV_TOTAL_LINE="TOTAL|COV_TOTAL_LINE_UNUSED="TOTAL|' scripts/mutate.sh $] ---
if have_mut; then bash "$MUT" coverage --all --tests tests >"$M97/all" 2>&1; ARC=$?; fi
if have_mut && [ "${ARC:-9}" -eq 0 ] \
   && grep -qE '^[[:space:]]*specs/021-mutation-audit' "$M97/all" \
   && grep -qE 'TOTAL .*[0-9]+ obliged.*[0-9]+ undeclared' "$M97/all" \
   && grep -q 'specs/' "$M97/all"; then
  _pass "COV-ALL-REPORTS-DEBT: per-feature lines and a TOTAL, exit 0, naming the tree it read"
else
  _fail "COV-ALL-REPORTS-DEBT: no re-derived debt figure (rc=${ARC:-absent})"
fi

# --- COV-NO-GIT: no branch ref, no network, no .git required ---
# 019 shipped a check reading `git show main:…`. Green locally; in CI a shallow checkout has
# neither main nor origin/main, and it failed there. The gate must not reintroduce that.
# --- [mut$ sed -i.bak 's|^cov_one(){|cov_one(){ git rev-parse --abbrev-ref origin/HEAD >/dev/null 2>\&1 \|\| return 9;|' scripts/mutate.sh $] ---
G=$(mktemp -d 2>/dev/null || mktemp -d -t m97g)
mkdir -p "$G/tests" "$G/fx"
cp tests/lib.sh "$G/tests/" 2>/dev/null
cp "$CFX/clean.md" "$G/fx/clean.md" 2>/dev/null
mkdir -p "$G/tests/fixtures/covgate" && cp "$CFX/check_fixture.sh" "$G/tests/fixtures/covgate/" 2>/dev/null
if have_mut; then ( cd "$G" && bash "$OLDPWD/$MUT" coverage --tests tests --spec fx/clean.md ) >"$M97/nogit" 2>&1; GRC=$?; fi
if have_mut && [ ! -d "$G/.git" ] && [ "${GRC:-9}" -eq 0 ] && grep -qE '2 obliged' "$M97/nogit"; then
  _pass "COV-NO-GIT: identical verdict in $G, which has no .git and no remote"
else
  _fail "COV-NO-GIT: the gate depends on a git ref (rc=${GRC:-absent}): $(head -2 "$M97/nogit" 2>/dev/null | tr '\n' ' ')"
fi
rm -rf "$G"

# --- COV-SELF: the gate is run against the feature that ships it (D4) ---
# D4 exempts a bootstrapping gate from being BLOCKED, never from being RUN. A real verdict.
# --- [mut$ sed -i.bak '/COV-SELF/,$ s|^# --- \[mut\$.*$||' tests/check_97_mutation_coverage.sh $] ---
cov --spec specs/022-mutation-coverage
if have_mut && [ "${CRC:-9}" -eq 0 ]; then
  _pass "COV-SELF: 022's own matrix passes the gate 022 ships — $(grep -oE '[0-9]+ obliged' "$M97/out" | head -1)"
else
  _fail "COV-SELF: this feature does not satisfy its own gate (rc=${CRC:-absent}): $(head -3 "$M97/out" 2>/dev/null | tr '\n' ' ')"
fi

# --- COV-WIRED: the gate runs where Guards run, and never inside the suite ---
# A gate accepted and never run is what base/pin-template.md calls worse than a vacuous check.
# The suite must NOT invoke it: mutate.sh re-runs check files, and check_96 re-runs the whole
# suite, so a call from inside multiplies. 021 walked into exactly that and the suite hung.
# --- [mut$ sed -i.bak 's|mutate.sh coverage|mutate.sh coverahe|g' .claude/skills/verify/SKILL.md $] ---
_c97_skill=0
grep -q 'mutate\.sh coverage' .claude/skills/verify/SKILL.md 2>/dev/null && _c97_skill=$((_c97_skill+1))
grep -q 'mutate\.sh coverage' .github/workflows/verify.yml 2>/dev/null && _c97_skill=$((_c97_skill+1))
if [ "$_c97_skill" -eq 2 ] && ! grep -q 'coverage' tests/run.sh 2>/dev/null; then
  _pass "COV-WIRED: named in the verify skill and in CI; absent from tests/run.sh"
else
  _fail "COV-WIRED: wired in $_c97_skill of 2 places, or invoked from tests/run.sh"
fi

# --- COV-DEPFREE: no installable toolchain ---
# --- [mut$ printf 'npm install --global mutate\n' >> scripts/mutate.sh $] ---
assert_dep_free "$MUT" "COV-DEPFREE"

# --- COV-COST-REPORTED: the run says what it costs, measured ---
# --- [mut$ sed -i.bak 's|total elapsed|total guessed|g' scripts/mutate.sh $] ---
if have_mut && grep -qE 'total elapsed [0-9]+\.[0-9]+s' "$M97/all" 2>/dev/null; then
  _pass "COV-COST-REPORTED: $(grep -oE 'total elapsed [0-9]+\.[0-9]+s' "$M97/all" | head -1) for the full --all sweep"
else
  _fail "COV-COST-REPORTED: no measured elapsed time in the --all output"
fi

# --- HERMETIC-ENV-97: this check assumes nothing about the ambient environment ---
# Comment lines are stripped before scanning: a [mut$ … $] declaration lives INSIDE this file and
# the COV-NO-GIT one necessarily contains `origin/HEAD`. 021 landed that rule after both of
# check_98's self-scans went red against their own declarations.
# --- [mut$ sed -i.bak 's|^_c97_amb=0$|_c97_amb=0; git show main:README.md >/dev/null 2>\&1|' tests/check_97_mutation_coverage.sh $] ---
# The forbidden literals are ASSEMBLED, not written: this scan reads its own file, and a pattern
# spelled out here would match itself on a code line -- where stripping comments cannot help.
# That is check-no-self-match, 015's rule, and it is the half 021's comment-stripping does not cover.
_c97_amb=0
_c97_pat="git sh""ow (main|origin)|/dev/""tty|\\\$TE""RM"
if grep -vE '^[[:space:]]*#' tests/check_97_mutation_coverage.sh | grep -qE "$_c97_pat"; then
  _c97_amb=1
fi
if [ "$_c97_amb" -eq 0 ]; then
  _pass "HERMETIC-ENV-97: no branch ref, controlling terminal or ambient variable in tests/check_97_mutation_coverage.sh"
else
  _fail "HERMETIC-ENV-97: tests/check_97_mutation_coverage.sh depends on the ambient environment"
fi

rm -rf "$M97"
