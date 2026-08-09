---
description: Elicit the project's stack charter — the load-bearing decisions, with their price. Runs after seeding the North Star, before the first brief.
---

Read `memory/stack/base/README.md` and `memory/stack/base/pin-template.md`, then follow the
`stack` skill (`.claude/skills/stack/SKILL.md`).

Input: `memory/north-star/north-star.md` (+ the existing `memory/stack/stack.md`, if any).
Output: `memory/stack/stack.md`.

Validate the result before reporting: `python3 scripts/stack/engine.py pin-valid
memory/stack/stack.md`, and regenerate the exposure header with `… exposure …`. Never
hand-write the header.
