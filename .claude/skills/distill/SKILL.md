---
name: distill
description: Distills brief.md into spec + acceptance (BDD) + coverage, hunting gaps grilling-style. Use after writing a feature's brief.
---

# Distill

Input: `specs/<feature>/brief.md`. Outputs: `spec.md`, `acceptance.md`, `coverage.md`.

## Procedure (loop until convergence)
0. **Measurability Gate (fail closed).** Read `specs/<feature>/alignment.md` (produced by `/align`).
   - **Absent** → refuse to proceed. Tell the human to run `/align` first to produce it
     (criterion `MEAS-GATE`).
   - **Present** → check its `verdict`; the deterministic gate (equivalent to `canDistill`, per-stack)
     is `true` only when the verdict is exactly `aligned`. Proceed only in that case.
     - `needs-amendment` → stop; the North Star amendment protocol
       (`memory/north-star/base/amendment-protocol.md`: an ADR in
       `memory/north-star/decisions/NNNN-*.md` + PR) is the only path forward, not a
       silent continue.
     - `rejected` → stop; the feature is out of scope, no amendment route from this skill.
   - **Bootstrap exception:** the feature that introduces `/align`
     (`002-north-star-governance`) is exempt from this gate — it is the only exception. Every other
     feature runs `/align` before `/distill`.
1. **Seed from the constitution and the charter.** Read `memory/constitution/` (base + project).
   For each applicable `base/patterns/*.md`, inject its `[given]` criterion/criteria as rows in
   `coverage.md`. Then read `memory/stack/stack.md`: for each **`[stance]`** pin, inject its
   `Injects` clause as `[given]` row(s) too, and for each `PROVISIONAL` pin inject its `Hedge`
   the same way — that is what makes a declared hedge verified rather than merely written.
   Substrate pins inject nothing; they constrain `/plan`, not coverage.
2. **Extract.** From the brief: objectives, user stories, constraints, success metrics.
3. **Interrogate (grilling).** Ask the human about ambiguities one at a time. Do NOT proceed with
   open ambiguities. (Draw inspiration from the `grilling` skill if available.)
4. **Expand edge cases (80% problem).** Generate the cases the brief does not cover; each one
   enters as a new row in `coverage.md` and forces a criterion.
5. **Trace.** Each objective → requirement → acceptance criterion (BDD). Mark deterministic
   vs non-deterministic.
6. **Check coverage.** If there are orphan rows (objective without criterion, or criterion without
   eval/UAT), return to step 3. Only when none remain (or are `deferred` with justification),
   freeze `spec.md` + `acceptance.md`.

## Re-entry: the `/plan` bounce

`/plan`'s stack gate can send a feature **back here** after the freeze. When its `UNPINNED`
verdict mints a `[stance]` pin, that pin's `Injects` rows belong in a `coverage.md` this skill
already froze — so coverage **reopens**, takes the new `[given]` row(s) per step 1, and is
**re-frozen** before `/plan` resumes. It is the only path that runs the loop backwards, and it
is deliberate: deferring the rows to the next feature would let the feature that *created* the
stance close without ever verifying it, which is green by construction.
