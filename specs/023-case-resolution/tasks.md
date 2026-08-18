# Tasks — 023-case-resolution

> Written before implementation. `/contract` is the boundary: everything under T1 must be RED
> before anything under T2 is written.

## T1 — Contract (RED)

- **T1.1** `tests/check_93_case_resolution.sh`, 13 criteria from `acceptance.md`, plus
  `HERMETIC-ENV-93`.
- **T1.2** Fixtures under `tests/fixtures/cases/`. Five of the seven shapes have **no natural
  instance** in this repository and must be authored:
  - `seven-col.md` + `six-col.md` — the same case row under both matrix layouts.
  - `missing.md` — cites `evals/cases/gone.md`.
  - `nopath.md` — a `📋 case` row citing no path.
  - `nobind.md` — cites a file that exists and never names the row's criterion.
  - `badheader.md` — a table whose header names no criterion or status column.
  - `multi.md` — three rows citing one file that names all three.
  - a fixture `evals/`-like directory holding the files those rows cite, plus one orphan.
  **`git add` before the first `mutate.sh run`** — 020 and 022 both shipped this bug; `B17`.
- **T1.3** Run the suite. Expect **13 FAIL**. Any criterion green here is green by construction and
  is recorded as such, not quietly accepted.

## T2 — Implementation

- **T2.1** `scripts/cases.sh`: locate the header row, map column name → index, reject a matrix whose
  header yields neither a criterion nor a status column.
- **T2.2** Read only table rows whose status column is `📋 case` — never the legend line.
- **T2.3** The three conditions and their exits: 0 clean · 1 no path / no bind · 2 missing file or
  unreadable matrix.
- **T2.4** The mirror pass: case files under `evals/cases/` cited by no row, counted and named.
- **T2.5** Output: per-feature lines, four counts, measured elapsed time.

## T3 — The three broken rows (`R4`)

- **T3.1** `evals/cases/audit-worth-it.md` — 021's, never written.
- **T3.2** `evals/cases/obligation-caught-one.md` — 022's; repoint that row from `/uat judgment,
  next feature`.
- **T3.3** `evals/cases/reject-msg.yaml` — `001-example`'s, per `plan.md` D-5: a product-criterion
  case in the `.yaml` form `evals/README.md` advertises and nothing demonstrates.
- **T3.4** `evals/cases/cases-now-countable.md` — this feature's own `📋 case` row, written at
  `/contract` as `evals/README.md` requires rather than after the fact.

## T4 — Self-subjection (`D4`)

- **T4.1** A `[mut$ … $]` for each of the 13 criteria of `check_93`.
- **T4.2** `mutate.sh coverage --spec specs/023-case-resolution --tests tests` → exit 0.
- **T4.3** `scripts/cases.sh` → exit 0 over the whole repository.
- **T4.4** `mutate.sh run --tests tests` → exit 0 with the 13 new declarations.

## T5 — Wiring and record

- **T5.1** `/verify` skill step and `.github/workflows/verify.yml`; **not** `tests/run.sh`.
- **T5.2** `docs/backlog.md`: `B14` replaced with the tool's figures; `B19` opened for the shared
  matrix parser (`mutate.sh coverage` carries the same fixed-index assumption and lands safely by
  luck).
- **T5.3** `/verify` → `/uat` → `/retro`, the report recording the gap's real size.
