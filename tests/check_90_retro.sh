# Sourced by tests/run.sh (lib.sh already loaded). Enforces the retro gate: the
# back half of the Measurability Gate. Template + wiring of the DONE contract +
# per-feature close. "Closed" = its verification/reports/<NNN>-*.md shows the
# DONE verdict (BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100%). Feature
# closed ⟹ specs/<NNN>-*/retro.md complete. No hardcode: a feature without a
# DONE report is "in-flight" and is skipped (uniform rule).

# --- Template: 3-face structure (Layer 1+2) ---
assert_file specs/_template/retro.md
for h in "Face A" "Face B" "Face C" "Evidence" "deriv"; do
  assert_contains specs/_template/retro.md "$h"
done

# --- has_placeholder blind-spot fix (feature 008 retro): code-span aware ---
_tp=$(mktemp)
printf 'a retro that documents the `_(placeholder)_` marker in prose.\n' > "$_tp"
if has_placeholder "$_tp"; then _fail "has_placeholder: documented marker in a code span is a false positive"
else _pass "has_placeholder: ignores a marker inside a backtick code span"; fi
printf 'a genuinely unfilled _(placeholder)_ line.\n' > "$_tp"
if has_placeholder "$_tp"; then _pass "has_placeholder: catches a bare unfilled marker"
else _fail "has_placeholder: missed a bare unfilled marker"; fi
rm -f "$_tp"

# --- DONE contract wiring ---
assert_contains CLAUDE.md "retro ✅"
assert_contains docs/workflow.md "retro ✅"
assert_contains verification/verification-report.md "retro ✅"

# --- Per-feature close (uniform rule) ---
# "Closed" = the report has BUILD ✅ and UAT ✅ and coverage 100% (three independent
# greps: robust to line layout and avoids fragile ||/&& precedence).
closed_seen=0
for report in verification/reports/*.md; do
  [ -f "$report" ] || continue
  grep -qE "BUILD:[[:space:]]*✅"   "$report" || continue
  grep -qE "UAT:[[:space:]]*✅"     "$report" || continue
  grep -qE "coverage:[[:space:]]*100%" "$report" || continue
  closed_seen=1
  nnn=$(basename "$report" | grep -oE '^[0-9]+')
  featdir=$(ls -d specs/${nnn}-*/ 2>/dev/null | head -1)
  if [ -z "$featdir" ]; then _fail "report $report DONE but no specs/${nnn}-*"; continue; fi
  retro="${featdir}retro.md"
  if [ ! -f "$retro" ]; then _fail "feature $nnn DONE but $retro is missing"; continue; fi
  _pass "feature $nnn DONE has $retro"
  # No unfilled placeholders (code-span aware — a retro may *document* a marker)
  if has_placeholder "$retro"; then _fail "$retro has unfilled placeholders"; else _pass "$retro no placeholders"; fi
  # Valid mission verdict
  if grep -qE '(Veredicto de misión|Mission verdict):[*[:space:]]*(confirmed|refuted|pending-observation|n/a)' "$retro"; then
    _pass "$retro valid mission verdict"
  else
    _fail "$retro missing valid mission verdict"
  fi
  # n/a requires a reason (Layer: anti-escape)
  if grep -qE '(Veredicto de misión|Mission verdict):[*[:space:]]*n/a' "$retro"; then
    if grep -qiE '(raz[oó]n|reason)' "$retro"; then _pass "$retro n/a with reason"; else _fail "$retro n/a without reason"; fi
  fi
  # Layer 2: confirmed/refuted requires evidence locator in Face A table rows.
  if grep -qE '(Veredicto de misión|Mission verdict):[*[:space:]]*(confirmed|refuted)' "$retro"; then
    ev_bad=0; ev_rows=0
    while IFS= read -r row; do
      case "$row" in *Pilar*|*Pillar*|*Signal*|*---*) continue ;; esac   # skip header/separator
      ev=$(printf '%s' "$row" | awk -F'|' '{c=$(NF-1); gsub(/^[ \t]+|[ \t]+$/,"",c); print c}')
      ev_rows=$((ev_rows+1))
      printf '%s' "$ev" | grep -qE '[0-9]|/|https?://|\.md|#' || ev_bad=1
    done < <(grep -E '^\|' "$retro")
    if [ "$ev_rows" -ge 1 ] && [ "$ev_bad" -eq 0 ]; then
      _pass "$retro Layer2: evidence locator in Face A (confirmed/refuted)"
    else
      _fail "$retro Layer2: confirmed/refuted with empty or locator-free evidence"
    fi
  fi
  # Each Face B field with [deriv:] (Layer 1) — anchored to bullet lines to exclude intro
  # Both locator forms count: `[deriv:` is prose, `[deriv$` is executed. Counting only the prose
  # form punished exactly the retros that upgraded to the executable one (015, 016).
  if [ "$(grep -cE '^- .*\[deriv[:$]' "$retro")" -ge 4 ]; then _pass "$retro Face B with deriv (>=4)"; else _fail "$retro Face B with <4 locators (derivable fields without one)"; fi
done
[ "$closed_seen" -eq 1 ] && _pass "close loop exercised" || _pass "no closed features yet (vacuous)"

# --- VERDICT-FORMAT: a report's verdict line must parse, or the retro gate silently skips it ---
# check_90 only judges features whose report reads DONE, and DONE is detected by string format.
# 017 shipped with "BUILD ✅" instead of "BUILD: ✅", so status.sh reported it unverified AND this
# gate never evaluated its retro. The feature merged with its retro unchecked. A typo that exempts
# a feature from a gate is worse than a red gate: nothing looks wrong.
_vf=0; _vfbad=""
for _r in verification/reports/*.md; do
  case "$(basename "$_r")" in 002-*) continue ;; esac   # 002 is a judge report, not a verification report
  if grep -qE 'BUILD:[[:space:]]*[✅❌]' "$_r"; then _vf=$((_vf+1))
  else _vfbad="$_vfbad $(basename "$_r")"; fi
done
if [ -z "$_vfbad" ] && [ "$_vf" -ge 10 ]; then
  _pass "VERDICT-FORMAT: all $_vf verification reports carry a parseable verdict line"
else _fail "VERDICT-FORMAT: report(s) with an unparseable verdict line —$_vfbad (checked $_vf) — the retro gate skips these in silence"; fi

# ================= 017 — executable derivations =================
# A numeric claim in a retro carries `<n> [deriv$ <command>]`. The command is EXECUTED and its
# output compared to n. Prose derivations (`[deriv: ...]`) are never executed.
#
# COMMAND EXECUTION, stated where it happens: these commands come from specs/*/retro.md and run
# from the repository root. Same trust level as the charter's `Guard` field, which /verify already
# runs by name out of stack.md without inspecting it.
# The executed count goes through a FILE, not a variable: callers use `$(deriv_check ...)`, which
# runs in a subshell, so an incremented variable is lost and every assertion read "ran 0". That is
# not a wrong number -- it is a counter that cannot count, and it would have made DERIV-NON-VACUOUS
# permanently red instead of silently green, which is the only reason it was cheap to find.
DERIV_COUNT=$(mktemp); printf '0' > "$DERIV_COUNT"
deriv_ran(){ cat "$DERIV_COUNT" 2>/dev/null || printf '0'; }
deriv_reset(){ printf '0' > "$DERIV_COUNT"; }
# deriv_check FILE -> prints one diagnostic per problem; counts each command executed
deriv_check(){
  local f="$1" line n cmd out rc
  while IFS= read -r line; do
    # `case` is not used for this test: `[deriv$` opens a character class in a case pattern, so
    # the guard matched nothing and every assertion below reported "ran 0". grep needs -F too: in a
    # pattern, a trailing `$` means end-of-line, so `deriv$` matched "deriv" at line end. Two
    # metacharacter bugs in one guard, both caught at /contract by assertions that were already red.
    # A third lived in the fixtures: `printf '- **A:** ...'` reads the leading dash as an option, so
    # every fixture file was EMPTY and every assertion failed for the wrong reason. Red for the
    # wrong reason still reads as red, which is why /contract catches it and /verify would not.
    #
    # The terminator is `$]`, not `]`. A bare `]` cannot work: the first real derivation written
    # for this feature was `grep -cE '^[0-9]+\.'`, which contains a bracket, so the command was
    # truncated mid-pattern and failed. The constraint the spec imposed was violated by the spec's
    # own first use of it. Only `$]` is forbidden inside a command now, and nothing needs it.
    # Code spans are stripped first. A retro that DOCUMENTS the form writes it inside backticks,
    # and parsing that as a derivation is the same blind spot has_placeholder() and prose_only()
    # already carry. This feature's own retro tripped it while describing its own parser bugs.
    line=$(printf '%s' "$line" | sed 's/`[^`]*`//g')
    printf '%s' "$line" | grep -qF 'deriv$' || continue
    # each `<number> [deriv$ <cmd>]` on the line, in order
    while [ -n "$line" ]; do
      printf '%s' "$line" | grep -qF 'deriv$' || break
      n=$(printf '%s' "${line%%\[deriv\$*}" | grep -oE '[0-9]+[^0-9]*$' | grep -oE '^[0-9]+')
      cmd=${line#*\[deriv\$}; cmd=${cmd%%\$\]*}
      line=${line#*\[deriv\$}; line=${line#*\$\]}
      [ -n "$cmd" ] || continue
      if [ -z "$n" ]; then echo "$f: a deriv\$ with no number before it: ${cmd:0:40}"; continue; fi
      out=$(eval "$cmd" 2>/dev/null); rc=$?
      printf '%s' "$(( $(cat "$DERIV_COUNT") + 1 ))" > "$DERIV_COUNT"
      if [ "$rc" -ne 0 ] || [ -z "$out" ]; then
        echo "$f: deriv command FAILED (exit $rc, no usable output), claim was $n: ${cmd:0:50}"
      elif ! printf '%s' "$out" | grep -qE '^[0-9]+$'; then
        echo "$f: deriv command printed a NON-INTEGER ('$(printf '%s' "$out" | head -c 20)'), claim was $n"
      elif [ "$out" != "$n" ]; then
        echo "$f: claim $n DISAGREES with its derivation, which printed $out: ${cmd:0:50}"
      fi
    done
  done < "$f"
}

# --- DERIV-RUNS / DERIV-MISMATCH / DERIV-BROKEN-CMD / DERIV-NON-INTEGER / DERIV-MULTI ---
_dfx=$(mktemp -d)
printf '%s\n' '- **A:** 3 [deriv$ printf 3$]' > "$_dfx/ok.md"
deriv_reset; _o=$(deriv_check "$_dfx/ok.md")
[ -z "$_o" ] && [ "$(deriv_ran)" -eq 1 ] && _pass "DERIV-RUNS: an agreeing derivation is executed and passes" \
  || _fail "DERIV-RUNS: agreeing derivation reported '$_o' (ran $(deriv_ran))"

printf '%s\n' '- **A:** 8 [deriv$ printf 10$]' > "$_dfx/bad.md"
_o=$(deriv_check "$_dfx/bad.md")
printf '%s' "$_o" | grep -q "DISAGREES" && printf '%s' "$_o" | grep -q "10" && printf '%s' "$_o" | grep -q "bad.md" \
  && _pass "DERIV-MISMATCH: a wrong number fails, naming file, claim and output" \
  || _fail "DERIV-MISMATCH: mismatch not reported with its detail ('$_o')"

printf '%s\n' '- **A:** 3 [deriv$ false$]' > "$_dfx/broken.md"
_o=$(deriv_check "$_dfx/broken.md")
printf '%s' "$_o" | grep -q "FAILED" && ! printf '%s' "$_o" | grep -q "DISAGREES" \
  && _pass "DERIV-BROKEN-CMD: a failing command is reported as failing, not as a wrong number" \
  || _fail "DERIV-BROKEN-CMD: broken command reported as '$_o'"

printf '%s\n' '- **A:** 3 [deriv$ printf hello$]' > "$_dfx/text.md"
_o=$(deriv_check "$_dfx/text.md")
printf '%s' "$_o" | grep -q "NON-INTEGER" && printf '%s' "$_o" | grep -q "hello" \
  && _pass "DERIV-NON-INTEGER: a non-integer output fails, naming what was printed" \
  || _fail "DERIV-NON-INTEGER: reported '$_o'"

printf '%s\n' '- **A:** 1 [deriv$ printf 1$] · **B:** 2 [deriv$ printf 9$]' > "$_dfx/multi.md"
deriv_reset; _o=$(deriv_check "$_dfx/multi.md")
[ "$(deriv_ran)" -eq 2 ] && printf '%s' "$_o" | grep -q "DISAGREES" && printf '%s' "$_o" | grep -q "9" \
  && _pass "DERIV-MULTI: both derivations run; the second mismatch is not masked by the first" \
  || _fail "DERIV-MULTI: ran $(deriv_ran), reported '$_o'"

printf '%s\n' '- **A:** yes [deriv: state history in coverage.md]' > "$_dfx/prose.md"
deriv_reset; _o=$(deriv_check "$_dfx/prose.md")
[ -z "$_o" ] && [ "$(deriv_ran)" -eq 0 ] && _pass "DERIV-PROSE-KEPT: a prose derivation is accepted and never executed" \
  || _fail "DERIV-PROSE-KEPT: prose derivation was executed or reported ('$_o', ran $(deriv_ran))"
rm -rf "$_dfx"

# --- DERIV-BRACKET: a command containing ']' cannot be parsed, so it is rejected by name ---
# A real derivation contains `]` inside a character class, so a bare `]` terminator truncates it.
# The fixture is the exact command that broke: it must parse whole and print an integer.
_bfx=$(mktemp -d)
printf '%s\n' '- **A:** 9 [deriv$ awk "/^## Edge cases/,/^## Non-goals/" specs/016-north-star-integrity/spec.md | grep -cE "^[0-9]+\." $]' > "$_bfx/br.md"
_o=$(deriv_check "$_bfx/br.md")
[ -z "$_o" ] && _pass "DERIV-BRACKET: a command containing ] parses whole, because the terminator is \$]" \
  || _fail "DERIV-BRACKET: a command containing ] was truncated ('$_o')"
rm -rf "$_bfx"

# --- DERIV-MIGRATED / DERIV-NON-VACUOUS: run over every closed retro ---
deriv_reset; _all=""
for _r in specs/0*/retro.md; do _all="$_all$(deriv_check "$_r")"; done
_ran=$(deriv_ran)
if [ -z "$_all" ] && [ "$_ran" -ge 3 ]; then
  _pass "DERIV-MIGRATED: every derivation across $(ls specs/0*/retro.md | wc -l | tr -d ' ') retros agrees ($_ran commands run)"
else _fail "DERIV-MIGRATED: $_ran commands run; $_all"; fi
if [ "$_ran" -ge 3 ]; then
  _pass "DERIV-NON-VACUOUS: $_ran derivations executed, so the scan is not silently empty"
else _fail "DERIV-NON-VACUOUS: only $_ran derivations executed (expected >=3) — a migration that skips everything passes forever"; fi

# --- DERIV-FROM-014: every retro from 014 on carries an executable derivation on its count ---
# 004-009 are excluded by fact, not by choice: their specs have no countable "Edge cases" section,
# so there is nothing for a command to read. 013 is excluded and RECORDED: its prose derivation is
# internally contradictory ("9 bullets minus one" and "+3 grilling", claiming 8) and the section now
# holds 10 bullets. No combination yields 8. Inventing a command that prints 8 would be the
# filler-to-comply this whole feature exists to stop.
_missing=""
for _f in specs/014-ground-rules specs/015-non-vacuous-checks specs/016-north-star-integrity; do
  grep -qF 'deriv$' "$_f/retro.md" || _missing="$_missing $_f"
done
[ -z "$_missing" ] && _pass "DERIV-FROM-014: 014, 015 and 016 each carry an executable derivation" \
  || _fail "DERIV-FROM-014: no executable derivation in$_missing"
# 013's finding must stay written down, or the exclusion silently becomes a gap
grep -qi 'unreproducible' specs/013-stack-charter/retro.md \
  && _pass "DERIV-013-RECORDED: 013's count is recorded as unreproducible rather than quietly dropped" \
  || _fail "DERIV-013-RECORDED: 013 is excluded from the check with nothing written down"

# --- DERIV-SCOPE-STATED: the template tells the author commands are executed ---
if grep -qiE 'execut' specs/_template/retro.md && grep -qE 'deriv\$' specs/_template/retro.md \
   && grep -qi 'guard' specs/_template/retro.md; then
  _pass "DERIV-SCOPE-STATED: the template states the form, that commands run, and the Guard precedent"
else _fail "DERIV-SCOPE-STATED: the template does not tell an author that derivations are executed"; fi

# --- HERMETIC-ENV-90: pattern assembled at runtime, with its own non-vacuity self-test ---
_T90='/dev'; _T90="$_T90/t""ty"
grep -q "$_T90" tests/check_90_retro.sh && _fail "HERMETIC-ENV-90: check_90 reads a terminal" \
  || _pass "HERMETIC-ENV-90: check_90 assumes no terminal"
printf 'read x < %s\n' "$_T90" > /tmp/h90 && grep -q "$_T90" /tmp/h90 \
  && _pass "HERMETIC-ENV-90-SELF: the assembled pattern matches a genuine occurrence" \
  || _fail "HERMETIC-ENV-90-SELF: assembled pattern is vacuous"
rm -f /tmp/h90
rm -f "$DERIV_COUNT"
