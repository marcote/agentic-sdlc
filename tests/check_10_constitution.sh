assert_file CLAUDE.md
assert_contains CLAUDE.md "memory/constitution"
assert_file memory/constitution/base/principles.md
# Regla del criterio invariante (refina el principio 2 test-first): no aceptar
# green-by-construction como RED; atar el invariante a un deliverable.
assert_contains memory/constitution/base/principles.md "invariante"
assert_contains memory/constitution/base/principles.md "green-by-construction"
assert_file memory/constitution/base/README.md
assert_file memory/constitution/constitution.md
assert_contains memory/constitution/constitution.md "extends: base"
assert_file memory/constitution/update-checklist.md
for p in audit-logging rate-limiting idempotency; do
  assert_file "memory/constitution/base/patterns/$p.md"
  assert_contains "memory/constitution/base/patterns/$p.md" "Criterios inyectados"
  assert_contains "memory/constitution/base/patterns/$p.md" "\[given\]"
done
