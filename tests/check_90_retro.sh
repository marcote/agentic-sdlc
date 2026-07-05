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
  # No unfilled placeholders
  if grep -qE '_\([^)]*\)_|<[^ >][^>]*>' "$retro"; then _fail "$retro has unfilled placeholders"; else _pass "$retro no placeholders"; fi
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
  if [ "$(grep -cE '^- .*\[deriv:' "$retro")" -ge 4 ]; then _pass "$retro Face B with deriv (≥4)"; else _fail "$retro Face B with <4 [deriv:] (derivable fields without locator)"; fi
done
[ "$closed_seen" -eq 1 ] && _pass "close loop exercised" || _pass "no closed features yet (vacuous)"
