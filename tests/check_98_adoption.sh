# Sourced by tests/run.sh (lib.sh already loaded). Contract of the adoption fixture (feature 018):
# the real gates run against a repository that is not this one. check_84 and check_88 prove that
# vendoring COPIES the right files; nothing before this proved that the harness GOVERNS the
# repository it was copied into.
#
# Subject under test = the harness. The fixture is the input.
#
# S9's Hedge, in its first use: the fixture's location is the ONE constant below. Its pin ids,
# pillar id, guard commands and violation are all read FROM the fixture at runtime, so adding a
# second target is a data change rather than a rewrite of this file.
#
# Every scenario gets its OWN sandbox copy. A shared one leaked state twice on 2026-08-09, and
# `git checkout` cannot restore an untracked file.

A98_FIX=tests/fixtures/adopter                 # the one constant (S9 Hedge)
A98_VIOLATE="${A98_FIX}-violate.sh"            # scaffolding: makes a copy break its own stances
A98_VENDOR=scripts/vendor.sh
A98_SE=scripts/stack/engine.py
A98_NE=scripts/north-star/engine.py
a98_have(){ [ -d "$A98_FIX" ]; }
a98_mk(){ mktemp -d 2>/dev/null || mktemp -d -t adopt; }
# tree digest: what ADOPT-SANDBOX-CLEAN compares before and after everything else has run.
a98_digest(){ find "$1" -type f 2>/dev/null | LC_ALL=C sort | while read -r f; do cksum "$f"; done; }
A98_BEFORE=$(a98_have && a98_digest "$A98_FIX")

# a sandbox copy of the fixture, un-vendored
a98_sandbox(){ local T; T=$(a98_mk); a98_have && cp -R "$A98_FIX/." "$T/" 2>/dev/null; echo "$T"; }
# a sandbox copy with the harness vendored onto it
a98_vendored(){ local T; T=$(a98_sandbox); [ -f "$A98_VENDOR" ] && bash "$A98_VENDOR" --apply "$T" >/dev/null 2>&1; echo "$T"; }

# --- ADOPT-FIXTURE-BUDGET: the product half stays inert and small ---
# --- [mut$ python3 -c "open('tests/fixtures/adopter/ledger.py','a').write('#pad\n'*30)" $] ---
# Product half = everything outside memory/ and scripts/. The budget is what makes "it grew into
# an application" mechanically visible; intent is UAT-FIXTURE-INERT's job, not this one.
if a98_have; then
  a98_pf=$(find "$A98_FIX" -type f ! -path "$A98_FIX/memory/*" ! -path "$A98_FIX/scripts/*" 2>/dev/null)
  a98_nf=$(printf '%s\n' "$a98_pf" | grep -c . )
  a98_nl=$(printf '%s\n' "$a98_pf" | grep . | while read -r f; do wc -l < "$f"; done | awk '{s+=$1} END {print s+0}')
else a98_nf=0; a98_nl=0; fi
if a98_have && [ "$a98_nf" -le 4 ] && [ "$a98_nf" -ge 1 ] && [ "$a98_nl" -le 40 ]; then
  _pass "ADOPT-FIXTURE-BUDGET: $A98_FIX product half is $a98_nf file(s) / $a98_nl line(s) (cap 4/40)"
else
  _fail "ADOPT-FIXTURE-BUDGET: $A98_FIX product half is $a98_nf file(s) / $a98_nl line(s), cap 4/40"
fi

# --- ADOPT-FIXTURE-DROP: the fixture is never vendored into a target ---
# --- [mut$ sed -i.bak 's|^KEEP=(|KEEP=(\n  tests|' scripts/vendor.sh $] ---
T=$(a98_mk)
[ -f "$A98_VENDOR" ] && bash "$A98_VENDOR" --apply "$T" >/dev/null 2>&1
if [ -f "$A98_VENDOR" ] && [ ! -e "$T/$A98_FIX" ] && [ ! -e "$T/tests" ]; then
  _pass "ADOPT-FIXTURE-DROP: $A98_FIX absent from a vendored target ($T)"
else
  _fail "ADOPT-FIXTURE-DROP: the fixture leaked into the vendored target $T"
fi
rm -rf "$T"

# --- ADOPT-VENDOR-APPLY: the suite vendors onto the fixture with no manual step ---
# --- [mut$ sed -i.bak 's|^copy_keep$|:|' scripts/vendor.sh $] ---
A98_T=$(a98_vendored)
if a98_have && [ -f "$A98_T/.claude/commands/align.md" ] && [ -f "$A98_T/$A98_SE" ] \
   && [ -f "$A98_T/$A98_NE" ]; then
  _pass "ADOPT-VENDOR-APPLY: governance landed on the fixture copy at $A98_T"
else
  _fail "ADOPT-VENDOR-APPLY: vendoring the fixture copy at $A98_T did not land the governance layer"
fi

# --- ADOPT-SEED-PRESERVED: the fixture's authored files survive, .harness-new is written ---
# --- [mut$ rm -f tests/fixtures/adopter/scripts/test.sh $] ---
a98_seed_ok=1
for a98_s in memory/stack/stack.md memory/north-star/north-star.md scripts/test.sh; do
  [ -f "$A98_FIX/$a98_s" ] || { a98_seed_ok=0; continue; }
  cmp -s "$A98_FIX/$a98_s" "$A98_T/$a98_s" || a98_seed_ok=0
  [ -f "$A98_T/$a98_s.harness-new" ] || a98_seed_ok=0
done
if a98_have && [ "$a98_seed_ok" -eq 1 ]; then
  _pass "ADOPT-SEED-PRESERVED: authored charter, North Star and test.sh intact in $A98_T; .harness-new written"
else
  _fail "ADOPT-SEED-PRESERVED: an authored SEED file was clobbered or got no .harness-new in $A98_T"
fi

# --- ADOPT-CHARTER-PINS: exposure reports the fixture's own pins, not empty ---
# --- [mut$ sed -i.bak 's|(?!GR.d)(\[A-Z\]{1,3}.d+)|(S\\\\d+)|' scripts/stack/engine.py $] ---
# Expected count derived from the fixture (S9 Hedge), never written in here.
# `GR` is excluded here for the same reason the engine excludes it: `### GR2 — n/a` is a
# declination, not a pin, and counting it would make this check disagree with the gate it audits.
a98_ids=$(grep -oE '^### [A-Z]{1,3}[0-9]+' "$A98_FIX/memory/stack/stack.md" 2>/dev/null \
          | awk '{print $2}' | grep -vE '^GR[0-9]')
a98_want=$(printf '%s\n' "$a98_ids" | grep -c .)
a98_pid=$(printf '%s\n' "$a98_ids" | head -1)
A98_EXPO=$(python3 "$A98_SE" exposure "$A98_T/memory/stack/stack.md" 2>&1)
if a98_have && [ "${a98_want:-0}" -ge 1 ] && printf '%s' "$A98_EXPO" | grep -qE "^$a98_want pins"; then
  _pass "ADOPT-CHARTER-PINS: exposure reports $a98_want pins under prefix ${a98_pid%%[0-9]*} in $A98_T"
else
  _fail "ADOPT-CHARTER-PINS: expected $a98_want pins from the fixture charter, got: $(printf '%s' "$A98_EXPO" | head -1)"
fi

# --- ADOPT-NS-VALID: the fixture's authored North Star validates (016's exit 3, inverted) ---
# --- [mut$ sed -i.bak 's|"mission": "Turn[^"]*"|"mission": "TODO: one sentence — why this product exists"|' tests/fixtures/adopter/memory/north-star/north-star.md $] ---
python3 "$A98_NE" schema-valid "$A98_T/memory/north-star/north-star.md" >/tmp/a98_ns 2>&1; a98_nsrc=$?
if a98_have && [ "$a98_nsrc" -eq 0 ]; then
  _pass "ADOPT-NS-VALID: the fixture's filled North Star exits 0 in $A98_T (016 asserts the stub exits 3)"
else
  _fail "ADOPT-NS-VALID: exit $a98_nsrc on the fixture North Star: $(head -1 /tmp/a98_ns)"
fi

# The fixture extends the base six with its own rule layer, so the effective set it must be
# judged against is NOT this repository's. Both numbers are derived from the target.
a98_ids_in(){ grep -hoE '^### GR[0-9]+' "$@" 2>/dev/null | awk '{print $2}' | LC_ALL=C sort -u; }
a98_eff=$(a98_ids_in "$A98_T/memory/stack/base/ground-rules.md" \
                     "$A98_T/memory/stack/ground-rules.md" | grep -c .)
a98_extra=$(comm -13 <(a98_ids_in "$A98_T/memory/stack/base/ground-rules.md") \
                     <(a98_ids_in "$A98_T/memory/stack/ground-rules.md") | head -1)

# --- ADOPT-GR-COVERED: run from inside the target, every effective rule has a verdict ---
# --- [mut$ sed -i.bak '/^- Answers:    GR4$/d' tests/fixtures/adopter/memory/stack/stack.md $] ---
A98_GR_IN=$( cd "$A98_T" 2>/dev/null && python3 scripts/stack/engine.py ground-rules memory/stack/stack.md 2>&1 )
a98_grin_rc=$?
a98_n=$(printf '%s\n' "$A98_GR_IN" | grep -cE '^GR[0-9]+: ')
if a98_have && [ "$a98_grin_rc" -eq 0 ] && [ "${a98_eff:-0}" -ge 7 ] && [ "$a98_n" -eq "$a98_eff" ] \
   && ! printf '%s' "$A98_GR_IN" | grep -q 'uncovered'; then
  _pass "ADOPT-GR-COVERED: $a98_n verdicts for $a98_eff effective rules, none uncovered, from inside $A98_T"
else
  _fail "ADOPT-GR-COVERED: rc=$a98_grin_rc, $a98_n of $a98_eff verdict(s) from inside $A98_T: $(printf '%s' "$A98_GR_IN" | head -1)"
fi

# --- ADOPT-REL-RESOLUTION: companion files resolve from the artifact, not the process cwd ---
# --- [mut$ sed -i.bak 's|^    roots, d = .*|    return [p for p in ["memory/stack/base/ground-rules.md"] if os.path.exists(p)]|' scripts/stack/engine.py $] ---
# Found at /distill: the stack engine resolved the ground rule file against cwd while the North
# Star engine resolves decisions/ against the artifact.
#
# The first version of this criterion was VACUOUS and mutation testing proved it. Comparing the
# run from this repository's root against the run from inside the target could not discriminate:
# `base/` is KEEP, so both trees carry the SAME six rules, and cwd-resolution produced identical
# output. It discriminates only on something the target has and we do not — the fixture's own
# rule layer — and from a cwd that owns no rules at all.
A98_N=$(a98_mk); A98_SEABS="$PWD/$A98_SE"
A98_GR_OUT=$( cd "$A98_N" && python3 "$A98_SEABS" ground-rules "$A98_T/memory/stack/stack.md" 2>&1 )
a98_grout_rc=$?
A98_GR_EXP=$(python3 "$A98_SE" ground-rules --rules "$A98_T/memory/stack/base/ground-rules.md" \
             --rules "$A98_T/memory/stack/ground-rules.md" "$A98_T/memory/stack/stack.md" 2>&1)
if a98_have && [ -n "${a98_extra:-}" ] && [ "$a98_grout_rc" -eq 0 ] \
   && [ "$A98_GR_OUT" = "$A98_GR_IN" ] && [ "$A98_GR_EXP" = "$A98_GR_IN" ] \
   && printf '%s' "$A98_GR_OUT" | grep -qE "^$a98_extra: "; then
  _pass "ADOPT-REL-RESOLUTION: from a cwd owning no rules ($A98_N), the gate still judged $A98_T by its own set, including $a98_extra; explicit --rules still wins"
else
  _fail "ADOPT-REL-RESOLUTION: rc=$a98_grout_rc from a rule-less cwd, extra rule '${a98_extra:-none}': $(printf '%s' "$A98_GR_OUT" | head -1)"
fi
rm -rf "$A98_N"

# --- ADOPT-GUARD-BY-NAME: guards are executed as the string the engine emitted ---
# --- [mut$ printf '\na98_gname=stdlib-only\n' >> tests/check_98_adoption.sh $] ---
# The harness must not know what a guard checks. Proof: the guard's own name, read from the
# fixture at runtime, must not appear anywhere in this file. The pattern's non-vacuity is
# self-tested against the charter it came from, in the same criterion.
A98_GUARDS=$(python3 "$A98_SE" guards "$A98_T/memory/stack/stack.md" 2>/dev/null)
a98_gname=$(printf '%s\n' "$A98_GUARDS" | head -1 | awk '{print $NF}' | xargs -I{} basename {} .sh 2>/dev/null)
a98_ng=$(printf '%s\n' "$A98_GUARDS" | grep -c .)
a98_selftest=0
[ -n "${a98_gname:-}" ] && grep -qF "$a98_gname" "$A98_FIX/memory/stack/stack.md" 2>/dev/null && a98_selftest=1
if a98_have && [ "$a98_ng" -ge 1 ] && [ "$a98_selftest" -eq 1 ] \
   && ! grep -vE '^[[:space:]]*#' tests/check_98_adoption.sh | grep -qF "$a98_gname"; then
  _pass "ADOPT-GUARD-BY-NAME: $a98_ng guard(s) taken from the engine; no fixture guard name written into this check"
else
  _fail "ADOPT-GUARD-BY-NAME: $a98_ng guard(s), self-test=$a98_selftest — a guard name is hardcoded here or the pattern is vacuous"
fi

# --- ADOPT-GUARD-CLEAN: every emitted guard exits 0 on the clean fixture ---
# --- [mut$ sed -i.bak 's|^exit .bad$|exit 1|' tests/fixtures/adopter/scripts/guards/stdlib-only.sh $] ---
a98_clean=1
printf '%s\n' "$A98_GUARDS" | grep -q . || a98_clean=0
while IFS= read -r a98_cmd; do
  [ -n "$a98_cmd" ] || continue
  ( cd "$A98_T" && eval "$a98_cmd" ) >/dev/null 2>&1 || a98_clean=0
done <<EOF
$A98_GUARDS
EOF
if a98_have && [ "$a98_clean" -eq 1 ]; then
  _pass "ADOPT-GUARD-CLEAN: all $a98_ng emitted guard(s) exit 0 with $A98_T as cwd"
else
  _fail "ADOPT-GUARD-CLEAN: an emitted guard did not exit 0 on the clean fixture at $A98_T"
fi

# --- ADOPT-GUARD-FAILS: the same guards reject a tree that violates their stance ---
# --- [mut$ printf 'exit 0\n' > tests/fixtures/adopter-violate.sh $] ---
# The violation is authored by the fixture, not by this check: a guard that cannot fail
# certifies nothing, and a harness that writes the violation itself is testing its own
# knowledge of the fixture rather than the seam.
A98_V=$(a98_vendored)
[ -f "$A98_VIOLATE" ] && bash "$A98_VIOLATE" "$A98_V" >/dev/null 2>&1
a98_dirty=0
while IFS= read -r a98_cmd; do
  [ -n "$a98_cmd" ] || continue
  ( cd "$A98_V" && eval "$a98_cmd" ) >/dev/null 2>&1 || a98_dirty=1
done <<EOF
$A98_GUARDS
EOF
if a98_have && [ -f "$A98_VIOLATE" ] && [ "$a98_dirty" -eq 1 ]; then
  _pass "ADOPT-GUARD-FAILS: an emitted guard rejects the violated copy at $A98_V"
else
  _fail "ADOPT-GUARD-FAILS: every guard still passed after $A98_VIOLATE ran on $A98_V — vacuous"
fi
rm -rf "$A98_V"

# --- ADOPT-NO-SILENT-EMPTY: no gate returns a result that names nothing the fixture owns ---
# --- [mut$ sed -i.bak '/^- Guard: /d' tests/fixtures/adopter/memory/stack/stack.md $] ---
# The generalisation of the pin-id defect: a gate that reports empty, or reports this
# repository's own artifacts, on a target that is not this repository.
a98_pillar=$(grep -oE '"id"[[:space:]]*:[[:space:]]*"[^"]+"' "$A98_FIX/memory/north-star/north-star.md" 2>/dev/null \
             | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
# names_a_pin TEXT : true when the text mentions ANY pin id the fixture declares. Any, not a
# specific one -- which id a gate happens to surface is that gate's business, and pinning this
# to one id would test our reading of the gate rather than whether it saw the fixture at all.
a98_names_a_pin(){
  local t="$1" i
  for i in $a98_ids; do printf '%s' "$t" | grep -qF "$i" && return 0; done
  return 1
}
a98_own=1
a98_names_a_pin "$A98_EXPO"  || a98_own=0
a98_names_a_pin "$A98_GR_IN" || a98_own=0
printf '%s' "$A98_GUARDS" | grep -q . || a98_own=0
grep -qF "$a98_pillar" "$A98_T/memory/north-star/north-star.md" 2>/dev/null || a98_own=0
if a98_have && [ -n "${a98_ids:-}" ] && [ -n "${a98_pillar:-}" ] && [ "$a98_own" -eq 1 ]; then
  _pass "ADOPT-NO-SILENT-EMPTY: exposure, ground-rules, guards and schema-valid each named the fixture's own artifacts in $A98_T"
else
  _fail "ADOPT-NO-SILENT-EMPTY: a gate returned a result naming nothing the fixture owns (pins='$a98_ids' pillar=$a98_pillar)"
fi

# --- ADOPT-UNCOVERED-FIRES: the floor blocks on a foreign charter, naming the rule ---
# --- [mut$ sed -i.bak 's|%s: uncovered|%s: unknown|' scripts/stack/engine.py $] ---
A98_U=$(a98_vendored)
a98_gr4=$(grep -B12 -E '^- Answers:.*GR4' "$A98_U/memory/stack/stack.md" 2>/dev/null \
          | grep -oE '^### [A-Z]{1,3}[0-9]+' | tail -1 | awk '{print $2}')
if [ -n "${a98_gr4:-}" ]; then
  awk -v id="### $a98_gr4 " 'index($0,id)==1{skip=1;next} /^### /{skip=0} !skip' \
      "$A98_U/memory/stack/stack.md" > "$A98_U/stripped.md"
fi
A98_UOUT=$( cd "$A98_U" 2>/dev/null && python3 scripts/stack/engine.py ground-rules stripped.md 2>&1 )
a98_urc=$?
if a98_have && [ -n "${a98_gr4:-}" ] && [ "$a98_urc" -eq 1 ] \
   && printf '%s' "$A98_UOUT" | grep -qE 'GR4: uncovered'; then
  _pass "ADOPT-UNCOVERED-FIRES: removing $a98_gr4 from the fixture charter reports GR4 uncovered (exit 1)"
else
  _fail "ADOPT-UNCOVERED-FIRES: rc=$a98_urc after removing pin '${a98_gr4:-none}' in $A98_U: $(printf '%s' "$A98_UOUT" | head -1)"
fi
rm -rf "$A98_U"

# --- ADOPT-TESTCMD-INVOKED: the seam, never the verdict ---
# --- [mut$ printf '#!/usr/bin/env bash\nexit 127\n' > tests/fixtures/adopter/scripts/test.sh $] ---
# --- ADOPT-TESTCMD-NOT-COUNTED: and the fixture's result stays out of the harness count ---
# --- [mut$ sed -i.bak 's|^  a98_p1=.PASSES; a98_f1=.FAILS|  _pass "leak"; a98_p1=$PASSES; a98_f1=$FAILS|' tests/check_98_adoption.sh $] ---
# S7: the exit code is observed and reported, NOT required to be 0. Requiring it would make a
# green tests/run.sh also claim the fixture works, which is exactly S7's falsifier.
if ! command -v python3 >/dev/null 2>&1; then
  _skip "ADOPT-TESTCMD-INVOKED: python3 unavailable, the fixture's own command cannot run here"
  _skip "ADOPT-TESTCMD-NOT-COUNTED: nothing was invoked, so there is no count to compare"
else
  a98_p0=$PASSES; a98_f0=$FAILS
  a98_out=$( cd "$A98_T" && bash scripts/test.sh 2>&1 ); a98_trc=$?
  a98_p1=$PASSES; a98_f1=$FAILS
  if [ "$a98_trc" -ne 127 ] && [ "$a98_trc" -ne 126 ] && [ -n "$a98_out" ]; then
    _pass "ADOPT-TESTCMD-INVOKED: the fixture's own scripts/test.sh ran in $A98_T, exit $a98_trc, reported: $(printf '%s' "$a98_out" | head -1)"
  else
    _fail "ADOPT-TESTCMD-INVOKED: the fixture's command was not found or produced nothing (exit $a98_trc)"
  fi
  if [ "$a98_p0" -eq "$a98_p1" ] && [ "$a98_f0" -eq "$a98_f1" ]; then
    _pass "ADOPT-TESTCMD-NOT-COUNTED: harness totals unmoved by the fixture's suite (S7)"
  else
    _fail "ADOPT-TESTCMD-NOT-COUNTED: the fixture's suite moved the harness count $a98_p0/$a98_f0 → $a98_p1/$a98_f1"
  fi
fi
rm -rf "$A98_T"

# --- S2-HEDGE-98: the engine change stays behind the shell CLI ---
# --- [mut$ printf '\nimport engine\n' >> scripts/stack/engine.py $] ---
if grep -qE '^\s+ground-rules FILE' "$A98_SE" 2>/dev/null \
   && ! grep -qE '^\s*from\s+engine\s+import|^\s*import\s+engine' scripts/*.sh scripts/*/*.py tests/*.sh 2>/dev/null; then
  _pass "S2-HEDGE-98: ground-rules stays a documented subcommand, no importable caller"
else
  _fail "S2-HEDGE-98: S2's hedge unpaid — the resolution change opened an import-based seam"
fi

# --- HERMETIC-ENV-98: assembled at runtime so this scan cannot match its own line ---
# --- [mut$ printf 'read x < /dev/tty\n' >> tests/check_98_adoption.sh $] ---
_T98='/dev'; _T98="$_T98/t""ty"
if ! grep -vE '^[[:space:]]*#' tests/check_98_adoption.sh | grep -q "$_T98"; then
  _pass "HERMETIC-ENV-98: this check assumes no terminal"
else _fail "HERMETIC-ENV-98: this check reads a terminal"; fi

# --- ADOPT-SANDBOX-CLEAN: the committed fixture is untouched by everything above ---
# --- [mut$ sed -i.bak 's|^# --- ADOPT-VENDOR-APPLY:|echo tampered >> tests/fixtures/adopter/ledger.py\n# --- ADOPT-VENDOR-APPLY:|' tests/check_98_adoption.sh $] ---
# Runs last on purpose. git checkout cannot restore an untracked file, so a leak here is not
# recoverable by the usual means — it silently changes what every later run tests.
A98_AFTER=$(a98_have && a98_digest "$A98_FIX")
if a98_have && [ "$A98_BEFORE" = "$A98_AFTER" ]; then
  _pass "ADOPT-SANDBOX-CLEAN: $A98_FIX byte-identical after every scenario (each used its own copy)"
else
  _fail "ADOPT-SANDBOX-CLEAN: $A98_FIX changed during this check — a scenario wrote to the committed tree"
fi
