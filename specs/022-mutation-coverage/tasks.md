# Tasks — 022-mutation-coverage

> Written before implementation. `/contract` is the boundary: everything under T1 must be RED
> before anything under T2 is written.

## T1 — Contract (RED)

- **T1.1** `tests/check_97_mutation_coverage.sh`, 13 criteria from `acceptance.md`, plus
  `HERMETIC-ENV-97`.
- **T1.2** Fixtures under `tests/fixtures/covgate/` — this repository has **0** unresolvable rows,
  so the two error paths have no natural instance and must be authored:
  - `missing-check.md` — a row naming `check_00_typo.sh`, which does not exist.
  - `not-a-check.md` — a row naming `chek_97_mutation_coverage.sh`, matching no `check_*.sh`.
  - `mixed.md` — one obliged row, one `[given]`, one `📋 case`, one `deferred`, one `idem`.
  Fixtures are tracked, or the sandbox never receives them — 020 shipped both replays broken that
  way and they reported the right verdict for the wrong reason.
- **T1.3** Run the suite. Expect **13 FAIL, 0 PASS**. A criterion green here is green by
  construction and must be rewritten before T2 begins.

## T2 — Implementation

- **T2.1** `scripts/mutate.sh coverage`: argument parsing for `--spec` / `--all`, reusing the
  existing `collect decl` index.
- **T2.2** The row predicate — origin, status, and the extraction rule for the linked-test cell,
  with `idem` inheriting the row above.
- **T2.3** The three buckets and their exits: 0 clean · 1 gap · 2 unresolvable.
- **T2.4** Output: per-feature line, totals for all four counts, measured elapsed time.

## T3 — Self-subjection (`D4`)

- **T3.1** A `[mut$ … $]` for each of the 13 criteria of `check_97`.
- **T3.2** `mutate.sh coverage --spec specs/022-mutation-coverage --tests tests` → exit 0.
- **T3.3** `mutate.sh run --tests tests` → exit 0 with the 13 new declarations included.

## T4 — Wiring and record

- **T4.1** `/verify` skill step and `.github/workflows/verify.yml`; **not** `tests/run.sh`.
- **T4.2** The obligation stated in `memory/constitution/base/patterns/non-vacuous-checks.md`.
- **T4.3** `docs/backlog.md`: `B15` closed with its disposition.
- **T4.4** `/verify` → `/uat` → `/retro`, and the report records the gate's verdict on this feature
  **together with** what that verdict does not prove.
