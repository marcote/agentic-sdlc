# Tasks — 026-matrix-parser

> Written before implementation. `/contract` is the boundary.

## T1 — Contract (RED)
- **T1.1** `tests/check_91_matrix.sh`, 13 criteria + `HERMETIC-ENV-91`.
- **T1.2** Fixtures under `tests/fixtures/matrix/`: `six.md`, `seven.md`, `second-table.md`,
  `no-table.md`, `spaced-label.md`, `idem-across-tables.md`. Tracked before the first mutation run.
- **T1.3** Suite → expect 13 FAIL. Any green-by-construction criterion is recorded, not accepted.

## T2 — The reader
- **T2.1** `matrix_header FILE` → `CRIT ORIGIN LINK STATUS FIRST LAST`, empty when no table qualifies.
- **T2.2** `matrix_rows FILE` → tab-separated data rows of that table only, `idem` resolved within it.
- **T2.3** Trimming, never stripping — 023's `message clarity` bug, in the one place that now owns it.

## T3 — Three ports, baselined after each
- **T3.1** `cases.sh` → re-run, expect `15 case rows, 15 resolved, 0 orphan`, byte-identical.
- **T3.2** `mutate.sh coverage` → expect `205 obliged, 137 undeclared, 110 excluded, 0 unresolvable`.
- **T3.3** `status.sh` → expect `001-example` to name `idempotency by key` and `022` to report no
  orphan row; every other feature's output unchanged.

## T4 — Self-subjection
- **T4.1** A `[mut$ … $]` per criterion. **T4.2** `mutate.sh coverage --spec` → 0.
- **T4.3** `mutate.sh run --tests tests` → 0. **T4.4** `cases.sh` → 0.

## T5 — Record
- **T5.1** `docs/backlog.md`: `B19` closed; `B20` opened for the three unvendored tools.
- **T5.2** `/verify` → `/uat` → `/retro`.
