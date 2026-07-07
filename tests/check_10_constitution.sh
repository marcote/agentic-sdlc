assert_file CLAUDE.md
assert_contains CLAUDE.md "memory/constitution"
assert_file memory/constitution/base/principles.md
# Invariant criterion rule (refines principle 2 test-first): do not accept
# green-by-construction as RED; tie the invariant to a deliverable.
assert_contains memory/constitution/base/principles.md "invariant"
assert_contains memory/constitution/base/principles.md "green-by-construction"
# Interactive-IO exception (candidate from 009 retro): a real /dev/tty prompt has no
# hermetic RED → UAT-observed, excluded from the /contract RED set (its neighbors stay in).
assert_contains memory/constitution/base/principles.md "Interactive-IO exception"
assert_file memory/constitution/base/README.md
assert_file memory/constitution/constitution.md
assert_contains memory/constitution/constitution.md "extends: base"
assert_file memory/constitution/update-checklist.md
for p in audit-logging rate-limiting idempotency hermetic-tests; do
  assert_file "memory/constitution/base/patterns/$p.md"
  assert_contains "memory/constitution/base/patterns/$p.md" "Injected criteria"
  assert_contains "memory/constitution/base/patterns/$p.md" "\[given\]"
done
