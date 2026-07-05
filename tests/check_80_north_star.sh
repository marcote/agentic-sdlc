# Sourced by tests/run.sh (lib.sh already loaded). Verifica que la capacidad de
# gobernanza North-Star + Measurability Gate está presente y conectada al
# harness: capa base, el placeholder north-star.md (extends: base), el
# comando+skill /align, el wiring del gate en /distill, y la columna Pillar en
# el template de coverage. Estructural/presencia únicamente — el motor
# determinista concreto (schema validation, scope predicates, verdict
# aggregation) es per-stack y no se unit-testea aquí (ver
# specs/002-north-star-governance/plan.md decisión 2;
# poirot-fe scripts/north-star/*.mjs es la reference implementation).
for f in schema.md alignment-rubric.md amendment-protocol.md adr-template.md README.md; do
  assert_file "memory/north-star/base/$f"
done
assert_file memory/north-star/north-star.md
assert_contains memory/north-star/north-star.md "extends: base"
assert_file .claude/commands/align.md
assert_file .claude/skills/align/SKILL.md

# MEAS-GATE: /distill debe imponer el gate, no solo describirlo en otro doc.
assert_file .claude/skills/distill/SKILL.md
assert_contains .claude/skills/distill/SKILL.md "alignment.md"
assert_contains .claude/skills/distill/SKILL.md "Measurability Gate"
assert_contains .claude/skills/distill/SKILL.md "aligned"

# COVERAGE-PILLAR: trazabilidad hasta el north star.
assert_contains specs/_template/coverage.md "Pillar"
