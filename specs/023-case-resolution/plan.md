# Plan — 023-case-resolution

> HOW it is built. Fail-closed against `memory/stack/stack.md` before any decision is taken.

## Charter gate

`python3 scripts/stack/engine.py exposure memory/stack/stack.md` → `10 pins · 8 PINNED ·
2 PROVISIONAL`, exposure on `S2` and `S9`.

| Decision this feature takes | Pin | Verdict |
|---|---|---|
| a new shell script, `scripts/cases.sh` | `S3` dependency-free baseline: shell + coreutils | **PASS** |
| the case set is read from versioned markdown | `S6` state lives in versioned markdown | **PASS** |
| an unreadable matrix aborts with exit 2, writing nothing | `S8` fail closed, write nothing, never partially apply | **PASS** |
| the gate judges this repository's own matrices | `S7` green proves this repository's harness | **PASS** |
| case files stay free-format | `S1` impose no answers | **PASS** |
| columns resolved by header rather than position | `S0` rigor tier: high | **PASS** |

**No `UNPINNED` decision, and no pin `TRIPPED`.** `S2`'s exposure is unchanged: this adds no python.

## Decisions

### D-1 — A separate script, not a `mutate.sh` subcommand
`mutate.sh` is about mutations. Its `coverage` reader happens to parse the same matrices, and the
temptation is to reuse it. **Rejected because it would spread `mutate.sh`'s fixed-index column
assumption**, which `R3` exists to remove. A shared parser is the right end state; introducing it
inside a feature about case files would be the chaining `docs/backlog.md` exists to prevent. Filed
instead.

### D-2 — Columns by header name
`001-example`'s matrix has six columns. Split on `|` it yields the same field count as a
seven-column table, so a fixed-index reader **does not fail — it reads the wrong column and reports
confidently.** Its label column parsed as `project` during `/distill`. Reading the header row costs
one pass and removes the whole class.

### D-3 — The label binding, though it currently costs nothing
All 11 resolving rows already name their criterion in their file. A condition that passes everywhere
today looks like decoration; it is the only one that catches a row repointed at the wrong file. It
ships because the cheap moment to add it is before the drift, not after.

### D-4 — Structure is not checked
Two shapes are in use and only 2 of 8 files carry the newer one. A structural rule would flag six
honest files. The rule stops at what both shapes share.

### D-5 — `001-example` gets a real case file, in `.yaml`
The example is fiction — `one_tap_pay.feature` and `idempotency.feature` do not exist either — so
the first instinct was to exempt it. **Rejected:** an exemption by name is the known-anomalies list
`B4` argues against, and `evals/README.md` states cases are created *at `/contract`, before
implementing*, which makes "the feature is unfinished" a reason for the file to exist rather than
not to.

`reject-msg.yaml` is written as an illustrative case for a **product** criterion, keeping the
extension the row already cites. All eight existing cases judge the harness itself; an adopter
copying this repository has no example of a case for their own product, and `evals/README.md`
advertises a `.yaml` form that nothing demonstrates. The gap was worth filling on its own.

### D-6 — `check_93`, between the ground-rules and amendment checks
`evals/` has no check file yet. 93 is free and keeps the number ordered near the other governance
checks.

## Sequence

1. `tests/check_93_case_resolution.sh` with all 13 criteria — **RED before implementation**.
2. Fixtures under `tests/fixtures/cases/` — six- and seven-column matrices, a missing file, a row
   naming nothing, a label that does not bind, an unreadable header, an orphan file. **None of these
   exists naturally**: the repository has 11 clean rows and 3 broken ones, and only two of the seven
   shapes appear among them.
3. `scripts/cases.sh` — header-driven column resolution, three buckets, both directions.
4. The three case files, and 022's row repointed.
5. A `[mut$ … $]` for each of the 13 (`D4`), then `mutate.sh coverage --spec` → exit 0.
6. Wire `/verify` and CI.
7. `docs/backlog.md`: `B14` replaced with derived figures; `B19` for the shared-parser debt.
8. `/verify` → `/uat` → `/retro`.

## Risks

- **Fixtures must be tracked before the first mutation run.** Third occurrence if missed; `B17`
  exists because 020 and 022 both hit it.
- **The gap is 3 rows.** The report must not present a small cleanup as a large one — `alignment.md`
  gate note 2, and the reason mission advancement scored 3.
- **`CASE-REPO-CLEAN` will be green by construction after step 4**, since fixing the rows is what
  makes it pass. It is an integration assertion, not a discovery; its mutation must break the
  *checker*, not delete a case file.
