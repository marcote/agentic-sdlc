# Sourced by tests/run.sh (lib.sh already loaded). Verifies that the North-Star +
# Measurability Gate governance capability is present and wired into the
# harness: base layer, the placeholder north-star.md (extends: base), the
# /align command+skill, the gate wiring in /distill, and the Pillar column in
# the coverage template. Structural/presence only — the concrete deterministic
# engine (schema validation, scope predicates, verdict aggregation) is per-stack
# and is not unit-tested here (see specs/002-north-star-governance/plan.md decision 2;
# poirot-fe scripts/north-star/*.mjs is the reference implementation).
for f in schema.md alignment-rubric.md amendment-protocol.md adr-template.md README.md; do
  assert_file "memory/north-star/base/$f"
done
assert_file memory/north-star/north-star.md
assert_contains memory/north-star/north-star.md "extends: base"
assert_file .claude/commands/align.md
assert_file .claude/skills/align/SKILL.md

# MEAS-GATE: /distill must enforce the gate, not just describe it in another doc.
assert_file .claude/skills/distill/SKILL.md
assert_contains .claude/skills/distill/SKILL.md "alignment.md"
assert_contains .claude/skills/distill/SKILL.md "Measurability Gate"
assert_contains .claude/skills/distill/SKILL.md "aligned"

# COVERAGE-PILLAR: traceability up to the north star.
assert_contains specs/_template/coverage.md "Pillar"
