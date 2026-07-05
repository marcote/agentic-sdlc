for c in constitution distill plan contract tasks verify uat retro; do
  f=".claude/commands/$c.md"
  assert_file "$f"
  assert_contains "$f" "^description:"
done
assert_contains .claude/commands/tasks.md "RED"
assert_contains .claude/commands/contract.md "RED"
