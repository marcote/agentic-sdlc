# Tasks — 027-mutation-diagnostics

> Written before implementation. `/contract` is the boundary.

## T1 — Contract (RED)
- **T1.1** `tests/check_89_mutation_diagnostics.sh`, 12 criteria + `HERMETIC-ENV-89`.
- **T1.2** Fixtures under `tests/fixtures/diagnostics/`: `stale.sh`, `weak.sh`, `broken.sh`,
  `replay026.sh` (026's declaration verbatim + the code as it stood), and a subject file.
  Tracked before the first run.
- **T1.3** Suite → expect 12 FAIL. A green-by-construction criterion is recorded, not accepted.

## T2 — Implementation
- **T2.1** Pre-flight: `git ls-files --others --exclude-standard -- "$TESTS"`; any hit → exit 2,
  naming each.
- **T2.2** `_mut_hash SANDBOX` → content digest, `*.bak` excluded.
- **T2.3** Hash before and after the edit; identical → `STALE`.
- **T2.4** Separate counters; summary states `not proved` with the stale count broken out.

## T3 — Self-subjection (`D4`)
- **T3.1** A `[mut$ … $]` per criterion. **T3.2** `mutate.sh coverage --spec` → 0.
- **T3.3** `mutate.sh run --tests tests` → 0, **full run, before pushing**.

## T4 — Record
- **T4.1** `base/patterns/non-vacuous-checks.md`: the five outcomes and what each means to fix.
- **T4.2** `docs/backlog.md`: `B17`, `B21`, `B22` closed together.
- **T4.3** `/verify` → `/uat` → `/retro`; the report compares measured cost against the 2%.
