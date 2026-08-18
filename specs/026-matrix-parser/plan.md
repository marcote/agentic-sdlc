# Plan — 026-matrix-parser

> HOW it is built. Fail-closed against `memory/stack/stack.md` before any decision is taken.

## Charter gate

`python3 scripts/stack/engine.py exposure memory/stack/stack.md` → `10 pins · 8 PINNED ·
2 PROVISIONAL`, exposure on `S2` and `S9`.

| Decision this feature takes | Pin | Verdict |
|---|---|---|
| a sourced shell library, `scripts/lib/matrix.sh` | `S3` dependency-free baseline: shell + coreutils | **PASS** |
| the matrix stays line-oriented markdown, read not rewritten | `S6` state lives in versioned markdown | **PASS** |
| a file with no matrix aborts, writing nothing | `S8` fail closed, write nothing, never partially apply | **PASS** |
| the reader serves this repository's tools, none of which vendor | `S7` green proves this repository's harness | **PASS** |
| no format is imposed on an adopter's matrix — the header is read, not required | `S1` impose no answers | **PASS** |

**No `UNPINNED` decision, no pin `TRIPPED`.** `S4` (charter format) governs `stack.md`, not
`coverage.md`, and is untouched. `S2`'s exposure is unchanged: this adds no python.

## Decisions

### D-1 — A sourced shell library, not a subcommand of an existing tool
`mutate.sh coverage` already parses the matrix and could have hosted it. Rejected: `status.sh` would
then shell out to `mutate.sh`, which makes the phase tracker depend on the mutation runner for a
reason a reader would never guess. The precedent is `tests/lib.sh`, whose `assert_dep_free` is
sourced by three checks and asserted by `HELPER-SHARED`.

### D-2 — The table is found, not assumed, and rows stop where it stops
The alternative — read every `|` line and filter afterwards — is what all three tools do today, and
it is why 022's measurement table became a phantom orphan row. Filtering after the fact means the
filter has to anticipate every other table. A range does not.

### D-3 — `001-example` is not reformatted
One edit removes the whole class from this repository and deletes the only proof it exists. The
outlier is the test data. Recorded in `alignment.md` gate note 3 before the temptation arrived.

### D-4 — The reader is harness-only, and that is not a choice
Measured while scoping: `status.sh`, `mutate.sh` and `cases.sh` are in **neither** `KEEP` nor `DROP`
in `scripts/vendor.sh`. All three consumers are invisible to vendoring, so the reader's bucket
question does not arise. **That absence is itself a defect** — an adopter neither receives them nor
is told they were withheld — and it goes to `docs/backlog.md` as `B20` rather than into this feature.

### D-5 — `check_91`, between the retro gate and the stack check
Free number, and it keeps the matrix reader near the artifacts it reads.

## Sequence

1. `tests/check_91_matrix.sh`, 13 criteria — **RED before implementation**.
2. Fixtures under `tests/fixtures/matrix/`: six-column, seven-column, a file with a second table, a
   file with no matrix, a label with spaces. **`git add` before the first `mutate.sh run`** — `B17`,
   third occurrence otherwise.
3. `scripts/lib/matrix.sh`.
4. Port `cases.sh` first — it is closest to the target shape, so it is the smallest diff and proves
   the interface before two harder ports.
5. Port `mutate.sh coverage`, then `status.sh`. After each, re-run the baseline and diff.
6. A `[mut$ … $]` for each of the 13, then `mutate.sh coverage --spec` → exit 0.
7. `/verify` → `/uat` → `/retro`.

## Risks

- **The success condition is that nothing moves**, which makes this the easiest feature to fake. The
  baselines are recorded in `spec.md` R5 before the work and are quoted, not re-derived.
- **`mutate.sh coverage` is currently right by luck.** A port that preserves its output without
  saying why the old output was right is preserving a coincidence — `alignment.md` gate note 4.
- **Three ports, one interface.** If the third port needs an interface change, the first two must be
  re-run against their baselines rather than assumed still correct.
