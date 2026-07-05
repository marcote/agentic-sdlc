---
description: Decompose into executable tasks. GATE test-first — rejects if RED contract is missing.
---

GATE (machine-checkable, not discretionary): walk through `coverage.md`. For EACH
deterministic row, require `linked test != empty AND state == 🔴 RED`. If any does not comply,
DO NOT emit implementation tasks: report the missing rows and stop.
Only if the gate passes, write `specs/<feature>/tasks.md` (each task links its coverage rows).
