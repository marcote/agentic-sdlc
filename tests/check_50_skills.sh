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
assert_contains .claude/skills/wow-report/SKILL.md "pilar"
assert_contains .claude/skills/wow-report/SKILL.md "olor"
