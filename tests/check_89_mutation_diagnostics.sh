# Sourced by tests/run.sh (lib.sh already loaded). Contract of the runner's DIAGNOSTICS
# (scripts/mutate.sh): two of its four outcomes were each doing the work of two.
#
#   `survived its own mutation` meant EITHER the criterion is weak OR the edit matched nothing
#   `emitted no result`        meant EITHER the check is broken OR its files never reached the sandbox
#
# The difference decides what to fix. Measured across four features: 022 4 of 5 weak mutations were
# anchor errors, 023 1 of 3, 026 7 of 9, plus 4 more that 026's refactor orphaned in 022 and 023 --
# 16 of 21 were declarations that edited nothing, every one reported as a criterion surviving.
#
# Exit contract, unchanged except for the new refusal:
#   0 = every declared mutation broke its criterion
#   1 = at least one not proved (weak, STALE, silent, or unapplied)
#   2 = unusable input, a malformed declaration, OR an untracked file under --tests

MUT=scripts/mutate.sh
M89=$(mktemp -d 2>/dev/null || mktemp -d -t m89)
DFX=tests/fixtures/diagnostics
have_mut(){ [ -f "$MUT" ]; }
# drepo : a throwaway git repo holding one fixture check, so the runner's sandbox can be built.
drepo(){
  local r; r=$(mktemp -d 2>/dev/null || mktemp -d -t m89r)
  mkdir -p "$r/tests"; cp tests/lib.sh "$r/tests/" 2>/dev/null
  ( cd "$r" && git init -q . && git config user.email t@t && git config user.name t )
  echo "$r"
}
# dcommit R : track everything, so git ls-files hands it to the sandbox.
dcommit(){ ( cd "$1" && git add -A && git commit -qm f 2>/dev/null ); }
drun(){ ( cd "$1" && bash "$OLDPWD/$MUT" run --tests tests ) >"$M89/out" 2>&1; DRC=$?; }

# --- MUT-STALE-NAMED: an edit that changes no bytes is STALE, not a surviving criterion ---
# --- [mut$ sed -i.bak 's|STALE: the edit|WEAK: the edit|' scripts/mutate.sh $] ---
R=$(drepo); cp "$DFX/subject.txt" "$R/"; cp "$DFX/stale.sh" "$R/tests/check_s.sh"; dcommit "$R"
if have_mut; then drun "$R"; fi
if have_mut && grep -q 'STALE' "$M89/out" && grep -q 'INERT-ONE' "$M89/out" \
   && ! grep -q 'INERT-ONE.*survived its own mutation' "$M89/out"; then
  _pass "MUT-STALE-NAMED: INERT-ONE reported as STALE, not as a criterion that survived"
else
  _fail "MUT-STALE-NAMED: an inert edit was reported as survival (rc=${DRC:-absent}): $(grep INERT-ONE "$M89/out" 2>/dev/null | head -1)"
fi
rm -rf "$R"

# --- MUT-STALE-NOT-PROVED: the diagnosis sharpens, the verdict does not soften ---
# A stale declaration means the criterion was NEVER TESTED, which is more alarming than a weak
# mutation, not less. Counting it as anything but not-proved would convert loud failures into quiet
# ones -- alignment.md gate note 2.
# --- [mut$ sed -i.bak 's|STALE=$((STALE+1)); FAILED=$((FAILED+1))|STALE=$((STALE+1))|' scripts/mutate.sh $] ---
R=$(drepo); cp "$DFX/subject.txt" "$R/"; cp "$DFX/stale.sh" "$R/tests/check_s.sh"; dcommit "$R"
if have_mut; then drun "$R"; fi
if have_mut && [ "${DRC:-9}" -eq 1 ] && grep -qE '[1-9][0-9]* not proved' "$M89/out"; then
  _pass "MUT-STALE-NOT-PROVED: exit 1, counted in not proved"
else
  _fail "MUT-STALE-NOT-PROVED: stale did not count as a failure (rc=${DRC:-absent}): $(tail -1 "$M89/out" 2>/dev/null)"
fi
rm -rf "$R"

# --- MUT-WEAK-STILL-SURVIVES: the old outcome is intact, not replaced ---
# --- [mut$ sed -i.bak 's|survived its own mutation|STALE: the edit changed no bytes|' scripts/mutate.sh $] ---
R=$(drepo); cp "$DFX/subject.txt" "$R/"; cp "$DFX/weak.sh" "$R/tests/check_w.sh"; dcommit "$R"
if have_mut; then drun "$R"; fi
if have_mut && grep -q 'WEAK-ONE.*survived its own mutation' "$M89/out" \
   && ! grep -q 'WEAK-ONE.*STALE' "$M89/out"; then
  _pass "MUT-WEAK-STILL-SURVIVES: a byte-changing edit still reports survival"
else
  _fail "MUT-WEAK-STILL-SURVIVES: the old outcome was replaced: $(grep WEAK-ONE "$M89/out" 2>/dev/null | head -1)"
fi
rm -rf "$R"

# --- MUT-COUNTS-SEPARATE: weak and stale are never added together ---
# 021 established that mixing them is how an audit becomes a rubber stamp.
# The pattern avoids a literal `$]`: the grammar terminates on the last one, and `[$]` carries it.
# --- [mut$ sed -i.bak 's|, .STALE stale||' scripts/mutate.sh $] ---
R=$(drepo); cp "$DFX/subject.txt" "$R/"; cp "$DFX/stale.sh" "$R/tests/check_s.sh"
cp "$DFX/weak.sh" "$R/tests/check_w.sh"; dcommit "$R"
if have_mut; then drun "$R"; fi
if have_mut && grep -qE '2 not proved' "$M89/out" && grep -qE '1 stale' "$M89/out"; then
  _pass "MUT-COUNTS-SEPARATE: 2 not proved, of which 1 stale — reported apart"
else
  _fail "MUT-COUNTS-SEPARATE: the two counts are merged: $(tail -1 "$M89/out" 2>/dev/null)"
fi
rm -rf "$R"

# --- MUT-BAK-NOT-A-CHANGE: sed rewrites its target on a no-match, and that is not a change ---
# Verified at /distill: `sed -i.bak` writes the file and creates the backup even when nothing
# matches. mtime therefore moves for EVERY declaration and detects nothing. Content, *.bak excluded.
# --- [mut$ sed -i.bak "s|! -name '[*].bak'||" scripts/mutate.sh $] ---
R=$(drepo); cp "$DFX/subject.txt" "$R/"; cp "$DFX/stale.sh" "$R/tests/check_s.sh"; dcommit "$R"
if have_mut; then drun "$R"; fi
if have_mut && grep -q 'STALE' "$M89/out"; then
  _pass "MUT-BAK-NOT-A-CHANGE: the .bak the edit created did not register as a change"
else
  _fail "MUT-BAK-NOT-A-CHANGE: the backup file was counted as a change, hiding the stale edit"
fi
rm -rf "$R"

# --- MUT-APPLY-ERROR-STILL-DISTINCT: failed-outright and successful-but-inert stay apart ---
# --- [mut$ sed -i.bak 's|the mutation could not be applied|STALE: the edit changed no bytes|' scripts/mutate.sh $] ---
R=$(drepo); cp "$DFX/subject.txt" "$R/"; cp "$DFX/broken.sh" "$R/tests/check_b.sh"; dcommit "$R"
if have_mut; then drun "$R"; fi
if have_mut && grep -q 'BROKEN-ONE.*could not be applied' "$M89/out" \
   && ! grep -q 'BROKEN-ONE.*STALE' "$M89/out"; then
  _pass "MUT-APPLY-ERROR-STILL-DISTINCT: a failing command is not reported as an inert one"
else
  _fail "MUT-APPLY-ERROR-STILL-DISTINCT: the two were merged: $(grep BROKEN-ONE "$M89/out" 2>/dev/null | head -1)"
fi
rm -rf "$R"

# --- MUT-UNTRACKED-REFUSED: untracked files under --tests stop the run before it starts ---
# 020 and 022 each had EVERY declaration in a new file misreported as `emitted no result`, because
# git ls-files never handed the file to the sandbox. One refusal, not many wrong diagnoses.
# --- [mut$ sed -i.bak 's|--others --exclude-standard|--cached|' scripts/mutate.sh $] ---
R=$(drepo); cp "$DFX/subject.txt" "$R/"; cp "$DFX/stale.sh" "$R/tests/check_s.sh"; dcommit "$R"
cp "$DFX/weak.sh" "$R/tests/check_untracked.sh"     # written AFTER the commit, deliberately
if have_mut; then drun "$R"; fi
if have_mut && [ "${DRC:-9}" -eq 2 ] && grep -q 'check_untracked.sh' "$M89/out"; then
  _pass "MUT-UNTRACKED-REFUSED: exit 2 naming tests/check_untracked.sh, before any sandbox"
else
  _fail "MUT-UNTRACKED-REFUSED: an untracked check file was not refused (rc=${DRC:-absent})"
fi
rm -rf "$R"

# --- MUT-TRACKED-RUNS: the pre-flight's negative — a clean tree proceeds ---
# Inverting the emptiness test makes the pre-flight refuse a CLEAN tree, which is what this
# criterion forbids. Disabling the pre-flight outright would leave it passing.
# --- [mut$ sed -i.bak 's|if \[ -n "$_mut_untracked" \]|if [ -z "$_mut_untracked" ]|' scripts/mutate.sh $] ---
R=$(drepo); cp "$DFX/subject.txt" "$R/"; cp "$DFX/weak.sh" "$R/tests/check_w.sh"; dcommit "$R"
if have_mut; then drun "$R"; fi
if have_mut && [ "${DRC:-9}" -ne 2 ] && grep -q 'WEAK-ONE' "$M89/out"; then
  _pass "MUT-TRACKED-RUNS: a fully tracked tests directory runs, the pre-flight silent"
else
  _fail "MUT-TRACKED-RUNS: the pre-flight refused a clean tree (rc=${DRC:-absent})"
fi
rm -rf "$R"

# --- MUT-STALE-REPLAY-026: 026's declaration, verbatim, against the code as it stood ---
# The falsification test set at /align: if the mechanism does not catch what actually shipped, it
# does not work. The declaration is unedited -- `s|^_mx_crit=0$|_mx_crit=5|` -- and the subject is
# the awk block as it was, where that identifier is indented and inside a quoted program.
# A global rename renames the assignment and its use together and the comparison keeps working --
# the same inert edit 022 shipped. Delete the branch instead.
# --- [mut$ sed -i.bak '/STALE: the edit changed no bytes/d' scripts/mutate.sh $] ---
R=$(drepo); mkdir -p "$R/tests/fixtures/diagnostics"
cp "$DFX/matrix_as_shipped.sh" "$R/tests/fixtures/diagnostics/"
cp "$DFX/replay026.sh" "$R/tests/check_r.sh"; dcommit "$R"
if have_mut; then drun "$R"; fi
if have_mut && grep -q 'REPLAY-026.*STALE' "$M89/out"; then
  _pass "MUT-STALE-REPLAY-026: 026's real declaration reports STALE, unedited"
else
  _fail "MUT-STALE-REPLAY-026: the shipped instance is not caught: $(grep REPLAY-026 "$M89/out" 2>/dev/null | head -1)"
fi
rm -rf "$R"

# --- MUT-SUMMARY-LEGIBLE: the shape of a refactor's damage is readable without every line ---
# --- [mut$ sed -i.bak 's|MUT_SUMMARY="|MUT_SUMMARY_UNUSED="|' scripts/mutate.sh $] ---
R=$(drepo); cp "$DFX/subject.txt" "$R/"; cp "$DFX/stale.sh" "$R/tests/check_s.sh"; dcommit "$R"
if have_mut; then drun "$R"; fi
if have_mut && grep -qE 'mutate: [0-9]+ mutation\(s\).*not proved.*stale' "$M89/out"; then
  _pass "MUT-SUMMARY-LEGIBLE: $(grep -oE '[0-9]+ not proved.*stale[^,]*' "$M89/out" | head -1)"
else
  _fail "MUT-SUMMARY-LEGIBLE: the summary does not state the stale count: $(tail -1 "$M89/out" 2>/dev/null)"
fi
rm -rf "$R"

# --- MUT-DIAG-DEPFREE: no installable toolchain ---
# --- [mut$ printf 'npm install -g hashit\n' >> scripts/mutate.sh $] ---
assert_dep_free "$MUT" "MUT-DIAG-DEPFREE"

# --- MUT-DIAG-COST: the added cost is measured against the 2% predicted at /align ---
# --- [mut$ sed -i.bak 's|## 2.1|## 2.1 (cost removed)|' verification/reports/027-mutation-diagnostics-*.md $] ---
_m89_rep=$(ls verification/reports/027-mutation-diagnostics-*.md 2>/dev/null | head -1)
if grep -qE 'predicted.*2%|2% predicted' "${_m89_rep:-/dev/null}" 2>/dev/null \
   && grep -qE '[0-9]+\.[0-9]+s' "${_m89_rep:-/dev/null}" 2>/dev/null; then
  _pass "MUT-DIAG-COST: ${_m89_rep} compares the measured cost against the prediction"
else
  _fail "MUT-DIAG-COST: no measured-vs-predicted cost in ${_m89_rep:-verification/reports/027-*}"
fi

# --- HERMETIC-ENV-89: this check assumes nothing about the ambient environment ---
# Literals assembled, not spelled: this scan reads its own file (check-no-self-match).
# --- [mut$ sed -i.bak 's|^_m89_amb=0$|_m89_amb=0; git show main:README.md >/dev/null 2>\&1|' tests/check_89_mutation_diagnostics.sh $] ---
_m89_amb=0
_m89_pat="git sh""ow (main|origin)|/dev/""tty|\\\$TE""RM"
if grep -vE '^[[:space:]]*#' tests/check_89_mutation_diagnostics.sh | grep -qE "$_m89_pat"; then _m89_amb=1; fi
if [ "$_m89_amb" -eq 0 ]; then
  _pass "HERMETIC-ENV-89: no branch ref, controlling terminal or ambient variable in tests/check_89_mutation_diagnostics.sh"
else
  _fail "HERMETIC-ENV-89: tests/check_89_mutation_diagnostics.sh depends on the ambient environment"
fi

rm -rf "$M89"
