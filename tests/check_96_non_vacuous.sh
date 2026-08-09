# Sourced by tests/run.sh (lib.sh already loaded). Contract of the non-vacuity meta-check
# (scripts/nvc.sh): every criterion label declared in a check file must emit a result in the
# actual run, labels are unique across files, and a check whose scan target can include itself
# must assemble its pattern at runtime and declare a self-test.
#
# Exercised hermetically against temp fixtures. Every negative fixture gets its OWN sandbox:
# a shared one leaked state twice on 2026-08-09, and `git checkout` cannot restore an untracked
# file. Covers 19 deterministic criteria.
#
# Exit contract of the deliverable: 0 clean · 1 violations found · 2 unusable input.

NVC="$PWD/scripts/nvc.sh"
have_nvc(){ [ -f "$NVC" ]; }

# nvcrepo: a minimal fake suite. Fixtures are written as HEREDOCS on purpose: their bodies are
# check-shaped, and the declaration parser must ignore them or it manufactures phantom criteria
# that can never emit. Measured: the first run of this file reported 110 declarations across the
# suite instead of ~78, every extra one a fixture string of this file's own.
nvcrepo(){ local r; r=$(mktemp -d); mkdir -p "$r/tests"; echo "$r"; }
runlog(){ printf '%s\n' "$2" > "$1"; }

# --- NVC-DECLARED-EMITTED: a declared label that never emits is a violation ---
R=$(nvcrepo)
cat > "$R/tests/check_a.sh" <<'FIXTURE'
# --- ALPHA: does a thing ---
if true; then _pass "ALPHA: ok"; else _fail "ALPHA: no"; fi
# --- GHOST: declared but never reached ---
if false; then _pass "GHOST: ok"; else :; fi
FIXTURE
runlog "$R/log.txt" '== tests/check_a.sh ==
  PASS: ALPHA: ok'
if have_nvc; then ( cd "$R" && bash "$NVC" traceability --tests tests --output log.txt ) >/tmp/nvc_out 2>&1; RC=$?; fi
if have_nvc && [ "${RC:-0}" -eq 1 ] && grep -q "GHOST" /tmp/nvc_out && ! grep -q "ALPHA" /tmp/nvc_out; then
  _pass "NVC-DECLARED-EMITTED: unemitted label flagged, emitted one left alone"
else _fail "NVC-DECLARED-EMITTED: silent criterion not caught (rc=${RC:-absent})"; fi
rm -rf "$R"

# --- NVC-DECLARE-FORMS: header form counts, heredoc body does not ---
R=$(nvcrepo)
cat > "$R/tests/check_b.sh" <<'FIXTURE'
# --- HEADERONLY: declared only as a header ---
assert_dep_free "$X" "HEADERONLY"
cat > "$T/tests/check_fake.sh" <<'EOF'
# --- PHANTOM: this lives inside a heredoc and is not a declaration ---
_pass "PHANTOM: ok"
EOF
FIXTURE
if have_nvc; then ( cd "$R" && bash "$NVC" declarations tests/check_b.sh ) >/tmp/nvc_out 2>&1; fi
if have_nvc && grep -q "HEADERONLY" /tmp/nvc_out && ! grep -q "PHANTOM" /tmp/nvc_out; then
  _pass "NVC-DECLARE-FORMS: header declared, heredoc body ignored"
else _fail "NVC-DECLARE-FORMS: parser took a heredoc body as a declaration, or missed a header"; fi
rm -rf "$R"

# --- NVC-INNER-GUARD: the nested run terminates, and this check judges its own file ---
# `timeout` is NOT used: it is absent on macOS, so it exits 127 and the assertion would have
# passed for an unrelated reason -- the exact shape occurrences 6-8 had. Non-recursion is proved
# by counting how many times the runner announced its first check: exactly one means no nesting.
if [ "${NVC_INNER:-0}" = "1" ]; then
  _skip "NVC-INNER-GUARD: nested run, spawn suppressed by the guard"
  _skip "NVC-ZERO-FP: nested run, the real-log scan belongs to the outer run"
elif have_nvc && [ -f tests/check_96_non_vacuous.sh ]; then
  ( NVC_INNER=1 bash tests/run.sh ) >/tmp/nvc_inner 2>&1
  depth=$(grep -c "== tests/check_00_skeleton.sh ==" /tmp/nvc_inner 2>/dev/null || echo 0)
  own=$(bash "$NVC" declarations tests/check_96_non_vacuous.sh 2>/dev/null | wc -l | tr -d ' ')
  seen=0
  for lbl in $(bash "$NVC" declarations tests/check_96_non_vacuous.sh 2>/dev/null | awk '{print $2}'); do
    grep -qE "(PASS|FAIL|SKIP): ${lbl}:" /tmp/nvc_inner && seen=$((seen+1))
  done
  if [ "${depth:-0}" -eq 1 ] && [ "${own:-0}" -gt 0 ] && [ "${seen:-0}" -eq "${own:-0}" ]; then
    _pass "NVC-INNER-GUARD: exactly one nested run; all ${own} of this check's own labels emitted in it"
  else _fail "NVC-INNER-GUARD: recursion or self-exemption (depth=${depth:-0} own=${own:-0} seen=${seen:-0})"; fi

  # --- NVC-ZERO-FP: all three rules clean against the REAL suite, and provably non-empty ---
  # Corrected at /uat. As frozen this assertion ran only --declarations-only, selfscan and
  # duplicates -- never traceability against a real log. The suite was green at 404/0 while
  # FIFTEEN criteria across five files were untraceable. A zero-false-positive claim that never
  # runs the rule it claims is itself the vacuity this feature exists to catch.
  bash "$NVC" traceability --tests tests --output /tmp/nvc_inner >/tmp/nvc_tr 2>&1; TR=$?
  bash "$NVC" selfscan --tests tests >/tmp/nvc_ss 2>&1; SS=$?
  bash "$NVC" duplicates --tests tests >/tmp/nvc_dup 2>&1; DUP=$?
  n=$(bash "$NVC" traceability --tests tests --output /dev/null --declarations-only 2>/dev/null | wc -l | tr -d ' ')
  if [ "${TR:-1}" -eq 0 ] && [ "${SS:-1}" -eq 0 ] && [ "${DUP:-1}" -eq 0 ] && [ "${n:-0}" -gt 50 ]; then
    _pass "NVC-ZERO-FP: all three rules clean on the real suite, ${n} labels examined (>50, not vacuously empty)"
  else _fail "NVC-ZERO-FP: violations on a known-good suite (trace=${TR:-?} $(head -1 /tmp/nvc_tr 2>/dev/null) selfscan=${SS:-?} dup=${DUP:-?} n=${n:-0})"; fi
else
  _fail "NVC-INNER-GUARD: deliverable absent, nesting unproved"
  _fail "NVC-ZERO-FP: deliverable absent, real-suite scan unproved"
fi

# --- NVC-LABEL-SCOPED: a result must land in its own file's section ---
R=$(nvcrepo)
cat > "$R/tests/check_c.sh" <<'FIXTURE'
# --- TWICE: declared here ---
_pass "TWICE: ok"
FIXTURE
cat > "$R/tests/check_d.sh" <<'FIXTURE'
# --- TWICE: and legitimately here too ---
_pass "TWICE: ok"
FIXTURE
# both emit, each inside its own section -> clean. A globally-unique rule would reject this,
# and it fired four times on the real suite where the recurrence was legitimate.
runlog "$R/ok.log" '== tests/check_c.sh ==
  PASS: TWICE: ok
== tests/check_d.sh ==
  PASS: TWICE: ok'
if have_nvc; then ( cd "$R" && bash "$NVC" traceability --tests tests --output ok.log ) >/tmp/nvc_ok 2>&1; OKRC=$?; fi
# check_d's result is missing from its own section, though the label appears in the log
runlog "$R/bad.log" '== tests/check_c.sh ==
  PASS: TWICE: ok
== tests/check_d.sh ==
  PASS: SOMETHINGELSE: ok'
if have_nvc; then ( cd "$R" && bash "$NVC" traceability --tests tests --output bad.log ) >/tmp/nvc_out 2>&1; RC=$?; fi
if have_nvc && [ "${OKRC:-1}" -eq 0 ] && [ "${RC:-0}" -eq 1 ] \
   && grep -q "check_d" /tmp/nvc_out && ! grep -q "check_c" /tmp/nvc_out; then
  _pass "NVC-LABEL-SCOPED: result required in its own section; legitimate cross-file repeat is clean"
else _fail "NVC-LABEL-SCOPED: section scoping wrong (ok=${OKRC:-absent} bad=${RC:-absent})"; fi
rm -rf "$R"
# --- NVC-LABEL-SAMEFILE: a label declared twice in one file cannot be disambiguated ---
R=$(nvcrepo)
cat > "$R/tests/check_c2.sh" <<'FIXTURE'
# --- SAME: first ---
_pass "SAME: ok"
# --- SAME: second, and nothing can tell them apart ---
_pass "SAME: ok"
FIXTURE
if have_nvc; then ( cd "$R" && bash "$NVC" duplicates --tests tests ) >/tmp/nvc_out 2>&1; RC=$?; fi
if have_nvc && [ "${RC:-0}" -eq 1 ] && grep -q "SAME" /tmp/nvc_out && grep -q "check_c2" /tmp/nvc_out; then
  _pass "NVC-LABEL-SAMEFILE: same-file duplicate rejected, naming label and file"
else _fail "NVC-LABEL-SAMEFILE: same-file duplicate not caught (rc=${RC:-absent})"; fi
rm -rf "$R"

# --- NVC-SKIP-EXPLICIT: SKIP counts as emitted; silence never does ---
R=$(nvcrepo)
cat > "$R/tests/check_e.sh" <<'FIXTURE'
# --- SKIPPY: cannot run here ---
_skip "SKIPPY: no network in this environment"
# --- MUTE: emits nothing at all ---
:
FIXTURE
runlog "$R/log.txt" '== tests/check_e.sh ==
  SKIP: SKIPPY: no network in this environment'
if have_nvc; then ( cd "$R" && bash "$NVC" traceability --tests tests --output log.txt ) >/tmp/nvc_out 2>&1; RC=$?; fi
if have_nvc && [ "${RC:-0}" -eq 1 ] && grep -q "MUTE" /tmp/nvc_out && ! grep -q "SKIPPY" /tmp/nvc_out; then
  _pass "NVC-SKIP-EXPLICIT: SKIP accepted as emitted, silence rejected"
else _fail "NVC-SKIP-EXPLICIT: skip semantics wrong (rc=${RC:-absent})"; fi
rm -rf "$R"
# and the helper the rule depends on must exist
if type _skip >/dev/null 2>&1; then _pass "NVC-SKIP-EXPLICIT-HELPER: lib.sh provides _skip"
else _fail "NVC-SKIP-EXPLICIT-HELPER: lib.sh has no _skip, so silence is still the only option"; fi

# --- NVC-RED-SUITE: an unusable run yields no traceability verdict, and names what it ran ---
R=$(nvcrepo)
cat > "$R/tests/check_f.sh" <<'FIXTURE'
# --- SOMETHING: x ---
_pass "SOMETHING: ok"
FIXTURE
: > "$R/empty.log"
if have_nvc; then ( cd "$R" && bash "$NVC" traceability --tests tests --output empty.log ) >/tmp/nvc_out 2>&1; RC=$?; fi
if have_nvc && [ "${RC:-0}" -eq 2 ] && grep -qiE "empty|no output|unusable" /tmp/nvc_out \
   && grep -q "empty.log" /tmp/nvc_out && ! grep -q "SOMETHING" /tmp/nvc_out; then
  _pass "NVC-RED-SUITE: refuses on an unusable run, names the log, claims nothing about labels"
else _fail "NVC-RED-SUITE: reported a confident verdict from an unusable run (rc=${RC:-absent})"; fi
rm -rf "$R"

# --- NVC-SELFSCAN-ASSEMBLED: literal pattern over a self-including target is rejected ---
R=$(nvcrepo)
cat > "$R/tests/check_g.sh" <<'FIXTURE'
# --- SCANNER: looks for a bad word across the suite ---
if grep -qE "forbidden-literal" tests/check_*.sh; then _fail "SCANNER: found"; else _pass "SCANNER: clean"; fi
FIXTURE
if have_nvc; then ( cd "$R" && bash "$NVC" selfscan --tests tests ) >/tmp/nvc_out 2>&1; RC=$?; fi
if have_nvc && [ "${RC:-0}" -eq 1 ] && grep -q "check_g" /tmp/nvc_out && grep -q "forbidden-literal" /tmp/nvc_out; then
  _pass "NVC-SELFSCAN-ASSEMBLED: inline literal over a self-including target rejected, both named"
else _fail "NVC-SELFSCAN-ASSEMBLED: self-matching scan not caught, or diagnostic incomplete"; fi
rm -rf "$R"
# closed target set that excludes the scanner must NOT be flagged (this is the false positive
# the rule is designed to avoid -- check_86 in the real suite is exactly this shape)
R=$(nvcrepo)
cat > "$R/tests/check_h.sh" <<'FIXTURE'
# --- CLOSED: greps named files, never itself ---
_P=x
if grep -q "some_helper" tests/lib.sh && grep -q "some_helper" tests/check_g.sh; then
  _pass "CLOSED: ok"; else _fail "CLOSED: no"; fi
# --- CLOSED-SELF: assembled-pattern self test ---
_pass "CLOSED-SELF: ok"
FIXTURE
if have_nvc; then ( cd "$R" && bash "$NVC" selfscan --tests tests ) >/tmp/nvc_out 2>&1; RC=$?; fi
if have_nvc && [ "${RC:-1}" -eq 0 ]; then
  _pass "NVC-SELFSCAN-CLOSED: a closed target set excluding the scanner is not flagged"
else _fail "NVC-SELFSCAN-CLOSED: false positive on a scan that cannot match itself"; fi
rm -rf "$R"

# --- NVC-SELFSCAN-SELFTEST: a self-including scanner with no self-test is rejected ---
R=$(nvcrepo)
cat > "$R/tests/check_i.sh" <<'FIXTURE'
# --- ASSEMBLED: assembles its pattern but declares no self test ---
_PAT="forb""idden"
if grep -qE "$_PAT" tests/check_*.sh; then _fail "ASSEMBLED: found"; else _pass "ASSEMBLED: clean"; fi
FIXTURE
if have_nvc; then ( cd "$R" && bash "$NVC" selfscan --tests tests ) >/tmp/nvc_out 2>&1; RC=$?; fi
if have_nvc && [ "${RC:-0}" -eq 1 ] && grep -q "check_i" /tmp/nvc_out && grep -qi "self.test" /tmp/nvc_out; then
  _pass "NVC-SELFSCAN-SELFTEST: assembled pattern without a self-test rejected"
else _fail "NVC-SELFSCAN-SELFTEST: missing self-test not caught (rc=${RC:-absent})"; fi
rm -rf "$R"

# --- NVC-FIX-82: the real instance this feature's own scan found, in a feature closed 2026-07-05 ---
if grep -qE 'assert_dep_free +"\$ENG" +"DEP-FREE"' tests/check_82_north_star_engine.sh 2>/dev/null; then
  _pass "NVC-FIX-82: check_82's DEP-FREE result is tied to its criterion"
else _fail "NVC-FIX-82: check_82 still emits an untraceable dep-free result"; fi

# --- NVC-CAN-FAIL: the meta-check fails on a negative fixture for each rule it enforces ---
# Proved by the fixtures above: each rule has a fixture that makes nvc.sh exit non-zero, and
# NVC-SELFSCAN-CLOSED is the paired positive proving it is not simply always failing.
if have_nvc; then
  cf=0
  R=$(nvcrepo); cat > "$R/tests/check_j.sh" <<'FIXTURE'
# --- ONLY: never emits ---
:
FIXTURE
  runlog "$R/l" '== tests/check_j.sh ==
  PASS: OTHER: unrelated'
  ( cd "$R" && bash "$NVC" traceability --tests tests --output l ) >/dev/null 2>&1; [ $? -eq 1 ] && cf=$((cf+1)); rm -rf "$R"
  R=$(nvcrepo); cat > "$R/tests/check_k.sh" <<'FIXTURE'
# --- DUP: x ---
_pass "DUP: ok"
# --- DUP: x again, same file ---
_pass "DUP: ok"
FIXTURE
  ( cd "$R" && bash "$NVC" duplicates --tests tests ) >/dev/null 2>&1; [ $? -eq 1 ] && cf=$((cf+1)); rm -rf "$R"
  R=$(nvcrepo); cat > "$R/tests/check_m.sh" <<'FIXTURE'
# --- S: x ---
grep -qE "lit" tests/check_*.sh && _fail "S: a" || _pass "S: b"
FIXTURE
  ( cd "$R" && bash "$NVC" selfscan --tests tests ) >/dev/null 2>&1; [ $? -eq 1 ] && cf=$((cf+1)); rm -rf "$R"
  R=$(nvcrepo); cat > "$R/tests/check_n.sh" <<'FIXTURE'
# --- T: x ---
_pass "T: ok"
FIXTURE
  : > "$R/e"
  ( cd "$R" && bash "$NVC" traceability --tests tests --output e ) >/dev/null 2>&1; [ $? -eq 2 ] && cf=$((cf+1)); rm -rf "$R"
fi
if have_nvc && [ "${cf:-0}" -eq 4 ]; then
  _pass "NVC-CAN-FAIL: all 4 enforced rules fail on their own isolated negative fixture"
else _fail "NVC-CAN-FAIL: ${cf:-0}/4 rules provably reachable -- an unreachable rule is decoration"; fi

# --- NVC-DEPFREE: the deliverable stays inside the S3 baseline, traceably ---
if type assert_dep_free >/dev/null 2>&1 && [ -f "$NVC" ]; then
  assert_dep_free "$NVC" "NVC-DEPFREE"
else
  _fail "NVC-DEPFREE: assert_dep_free helper or scripts/nvc.sh missing"
fi

# --- NVC-SCOPE-STATED: the shipped file states its own limits ---
if have_nvc && grep -qi "review" "$NVC" && grep -qi "undeclared" "$NVC" && grep -qi "semantic" "$NVC"; then
  _pass "NVC-SCOPE-STATED: header names what is mechanical, what is review, and the blind spot"
else _fail "NVC-SCOPE-STATED: the file does not state its own scope limits"; fi

# --- HERMETIC-ENV-96: no controlling terminal, no local branch assumption ---
# Pattern assembled at runtime so this scan cannot match its own scanning line (self-test below).
_TTY96='/dev'; _TTY96="$_TTY96/t""ty"
if have_nvc && ! grep -q "$_TTY96" "$NVC" && ! grep -qE '\bgit +(checkout|switch) +main\b' "$NVC"; then
  _pass "HERMETIC-ENV-96: assumes no terminal and no local main"
else _fail "HERMETIC-ENV-96: deliverable assumes a terminal or a local branch"; fi
# --- HERMETIC-ENV-96-SELF: the assembled pattern is real, and would match if present ---
if printf '%s\n' "/dev/${_TTY96##*/}" | grep -q "$_TTY96"; then
  _pass "HERMETIC-ENV-96-SELF: the assembled pattern matches a genuine occurrence"
else _fail "HERMETIC-ENV-96-SELF: assembled pattern is broken, so the scan above proves nothing"; fi

# --- NVC-SELF: the deliverable exists and is exercised ---
# Emitted with its label rather than via bare assert_file: an unlabelled result is untraceable,
# which is the defect this file exists to catch. Dogfooding starts here.
if [ -f "$NVC" ]; then _pass "NVC-SELF: deliverable present at $NVC"
else _fail "NVC-SELF: missing deliverable $NVC"; fi
