#!/usr/bin/env bash
# status.sh — derived phase-tracker (read-only). Computes a feature's pipeline phase state
# from its artifacts (specs/<feature>/) + coverage.md states + report verdicts, instead of
# inferring it by hand. Dependency-free: bash/coreutils.
#
#   scripts/status.sh <feature>
#
# Output: "✓ <phase>" done / "· <phase>" pending · "current: <phase>" + "next: <command>"
#   · "feature DONE" when all done · "⚠ anomaly" + non-zero exit when out-of-order
#   · a coverage-gaps section. Exit 0 when coherent; non-zero on anomaly or unknown feature.
set -u

feat="${1:-}"
[ -n "$feat" ] || { echo "usage: status.sh <feature>" >&2; exit 2; }
D="specs/$feat"
[ -d "$D" ] || { echo "status: feature not found: $D" >&2; exit 2; }
report=$(ls -t "verification/reports/$feat"-*.md 2>/dev/null | head -1)

# A doc artifact is "filled" iff it has no leftover template placeholder. The marker is the
# italic-paren form `_(...)_` (present in every _template file) — NOT `<...>`, which real
# briefs/specs use legitimately (e.g. CLI usage `status.sh <feature>`). Backtick code spans
# are stripped first, so a doc that *documents* the marker (e.g. this feature's own spec:
# "markers `_(...)_`") is not misread as unfilled.
filled(){
  [ -f "$1" ] || return 1
  ! sed 's/`[^`]*`//g' "$1" | grep -qE '_\([^)]*\)_'
}
# coverage data rows only (drop header + separator)
# data rows only: drop the markdown separator (only pipes/dashes/colons/spaces) and the header
covrows(){ grep '^|' "$D/coverage.md" 2>/dev/null | grep -vE '^[|:[:space:]-]+$' | grep -viE '\| *Pillar *\|'; }

cmd_for(){ case "$1" in
  brief) echo "(write brief.md)";; align) echo "/align";; distill) echo "/distill";;
  plan) echo "/plan";; contract) echo "/contract";; tasks) echo "/tasks";;
  implement) echo "(implement)";; verify) echo "/verify";; uat) echo "/uat";; retro) echo "/retro";;
esac; }

is_done(){ case "$1" in
  brief)    filled "$D/brief.md" ;;
  align)    [ -f "$D/alignment.md" ] && grep -qi "verdict" "$D/alignment.md" ;;
  distill)  filled "$D/spec.md" && filled "$D/acceptance.md" && filled "$D/coverage.md" ;;
  plan)     filled "$D/plan.md" ;;
  contract) covrows | grep -qE '🔴|🟢|✅' ;;
  tasks)    filled "$D/tasks.md" ;;
  implement)
    covrows | grep -qE '🔴|🟢|✅' || return 1        # criteria materialised (contract done)
    covrows | grep -qE '🔴|no contract' && return 1  # none still red / uncontracted
    return 0 ;;
  verify)   [ -n "$report" ] && grep -qE 'BUILD:[[:space:]]*✅' "$report" ;;
  uat)      [ -n "$report" ] && grep -qE 'UAT:[[:space:]]*✅' "$report" ;;
  retro)    filled "$D/retro.md" && [ -n "$report" ] && grep -qE 'retro:[[:space:]]*✅' "$report" ;;
esac; }

phases="brief align distill plan contract tasks implement verify uat retro"

echo "status: $feat"
current=""; anomaly=""; seen_pending=0; alldone=1
for p in $phases; do
  if is_done "$p"; then
    echo "✓ $p"
    [ "$seen_pending" -eq 1 ] && anomaly="$anomaly $p"
  else
    echo "· $p"
    alldone=0
    [ -z "$current" ] && current="$p"
    seen_pending=1
  fi
done

if [ "$alldone" -eq 1 ]; then
  echo "feature DONE"
else
  echo "current: $current"
  echo "next: $(cmd_for "$current")"
fi

# coverage gaps (non-green criteria + orphan rows)
gaps=$(covrows | awk -F'|' '{
  pil=$2; crit=$5; stat=$(NF-1);
  gsub(/^[ \t]+|[ \t]+$/,"",pil); gsub(/^[ \t]+|[ \t]+$/,"",crit); gsub(/^[ \t]+|[ \t]+$/,"",stat);
  if (pil=="") print "  orphan row (no pillar): " crit;
  else if (stat ~ /🔴|no contract/) print "  non-green: " crit " (" stat ")";
}')
if [ -n "$gaps" ]; then
  echo "coverage gaps:"
  echo "$gaps"
fi

if [ -n "$anomaly" ]; then
  echo "⚠ anomaly: done phase(s)$anomaly follow a pending one (out-of-order / skip)"
  exit 1
fi
exit 0
