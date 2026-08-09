for s in distill verify uat retro wow-report; do
  f=".claude/skills/$s/SKILL.md"
  assert_file "$f"
  assert_contains "$f" "^name:"
  assert_contains "$f" "^description:"
done
assert_contains .claude/skills/distill/SKILL.md "grilling"
assert_contains .claude/skills/verify/SKILL.md "rubric"
assert_contains .claude/skills/retro/SKILL.md "adversarial"
assert_contains .claude/skills/retro/SKILL.md "deriv"
assert_contains .claude/skills/wow-report/SKILL.md "pillar"
assert_contains .claude/skills/wow-report/SKILL.md "smell"

# --- ALIGN-REFUSES-UNFILLED / ALIGN-STAMPS-PROVENANCE (016) ---
# /align must stop on an UNFILLED North Star (exit 3) with a "seed it" message, not describe it as
# malformed — the same distinction 013 drew for the charter so nobody hunts a bug that is not there.
_AS=.claude/skills/align/SKILL.md
if grep -qiE 'exit 3|unfilled' "$_AS" 2>/dev/null && grep -qiE 'seed' "$_AS" 2>/dev/null; then
  _pass "ALIGN-REFUSES-UNFILLED: the skill stops on exit 3 and says seed it"
else _fail "ALIGN-REFUSES-UNFILLED: the skill has no unfilled/exit-3 contract"; fi
# The first version of this grepped for the word "since" in alignment.md. It passed -- because
# "since" is an ordinary English word and appeared in a scoring rationale. Semantic vacuity, in the
# assertion written to prevent it, caught by reading rather than by any check. The pattern says
# that shape stays with review; this is what that costs. Now it requires the STAMP: each pillar id
# paired with a 4-digit ADR on the same line.
_stamp=0
for _p in real-enforcement:0001 agnostic-portability:0001 measurable-impact:0002 frictionless-adoption:0004; do
  grep -qE "\`${_p%%:*}\`.*\`${_p##*:}\`" specs/016-north-star-integrity/alignment.md 2>/dev/null || _stamp=1
done
if grep -qiE 'since|provenance' "$_AS" 2>/dev/null && [ "$_stamp" -eq 0 ]; then
  _pass "ALIGN-STAMPS-PROVENANCE: the skill stamps provenance and 016's alignment pairs every pillar with its ADR"
else _fail "ALIGN-STAMPS-PROVENANCE: skill lacks the contract, or the stamp does not pair pillars with ADR ids"; fi
