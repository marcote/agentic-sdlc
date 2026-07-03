assert_file CLAUDE.md
assert_contains CLAUDE.md "memory/constitution"
assert_file memory/constitution/base/principles.md
assert_file memory/constitution/base/README.md
assert_file memory/constitution/constitution.md
assert_contains memory/constitution/constitution.md "extends: base"
assert_file memory/constitution/update-checklist.md
for p in audit-logging rate-limiting idempotency; do
  assert_file "memory/constitution/base/patterns/$p.md"
  assert_contains "memory/constitution/base/patterns/$p.md" "Criterios inyectados"
  assert_contains "memory/constitution/base/patterns/$p.md" "\[given\]"
done
