# Replay fixture — 019's NS-PREDICATE-REACHABLE, in the form actually shipped.
#
# Source: `git show babac0a^:tests/check_80_north_star.sh`. The assertion block below is
# CHARACTER-IDENTICAL to what shipped; only the three variables it reads are supplied here.
# Editing it into something easier to catch would make this fixture prove nothing.
#
# The defect: the test objective is built by interpolating `$_pr19`, which was read from the
# artifact under test. The substring is present by construction, so the assertion cannot fail on
# the property it exists to forbid — a predicate too long to appear verbatim in a brief.
#
# The declared mutation is 019's real M2: rewrite a predicate as an 18-word sentence.
NS19="$PWD/tests/fixtures/mutations/north-star-replay.md"
ENG19=scripts/north-star/engine.py
_lc19=$(python3 - "$NS19" <<'P19'
import sys, json, re
s = open(sys.argv[1], encoding="utf-8").read()
d = json.loads(re.search(r"```json\s*\n(.*?)\n```", s, re.S).group(1))
out = d.get("scope", {}).get("out_of_scope", [])
print("\n".join(p for p in out
      if any(w in p for w in ("discovery", "prioritis", "release", "monitoring"))))
P19
)

# --- NS-PREDICATE-REACHABLE: each new predicate can actually fire ---
# --- [mut$ sed -i.bak 's|product discovery and demand validation|we do not do product discovery or any form of demand validation with real users before a brief is ever written|' tests/fixtures/mutations/north-star-replay.md $] ---
_reach19=1; _nre19=0
while IFS= read -r _pr19; do
  [ -n "$_pr19" ] || continue
  _nre19=$((_nre19+1))
  python3 "$ENG19" scope-reject --north-star "$NS19" "a gate for $_pr19 in every repo" >/dev/null 2>&1 \
    || _reach19=0
done <<EOF
$_lc19
EOF
if [ "$_nre19" -ge 4 ] && [ "$_reach19" -eq 1 ]; then
  _pass "NS-PREDICATE-REACHABLE: all $_nre19 lifecycle predicates fire scope-reject on an objective that names them"
else
  _fail "NS-PREDICATE-REACHABLE: $_nre19 predicate(s) scored, reachable=$_reach19 — a predicate is dead text"
fi
