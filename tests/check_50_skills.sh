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
if grep -qiE 'since|provenance' "$_AS" 2>/dev/null \
   && grep -qE '"?since"?' specs/016-north-star-integrity/alignment.md 2>/dev/null; then
  _pass "ALIGN-STAMPS-PROVENANCE: the skill stamps provenance and 016's own alignment carries it"
else _fail "ALIGN-STAMPS-PROVENANCE: no provenance stamp in the skill, or 016's alignment lacks it"; fi
