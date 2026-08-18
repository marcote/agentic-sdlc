# Spec — One reader for the matrix, bound to the matrix

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- `scripts/lib/matrix.sh` — the single reader: locate the coverage table by its header, expose its
  columns by name, emit its rows and nothing else.
- `scripts/status.sh`, `scripts/mutate.sh`, `scripts/cases.sh` — all three source it; none splits
  `coverage.md` on the pipe on its own.
- `tests/check_91_matrix.sh` — its contract, every criterion declaring its mutation.

## Three live defects, all from one cause

Measured at `/distill`, all present on `main` before this feature.

### 1. `status.sh` names the Origin column as the criterion

```
$ bash scripts/status.sh 001-example
coverage gaps:
  non-green: `[given] base/idempotency` (🔴 red)
```

The row is `| — (retries) | Repeatable save | idempotency by key | \`[given] base/idempotency\` |
\`idempotency.feature\` | 🔴 red |` — six columns, criterion at field 4. `status.sh` reads `$5`.
Wrong since 008.

### 2. `status.sh` reads a *different table* in the same file as criteria

```
$ bash scripts/status.sh 022-mutation-coverage
coverage gaps:
  orphan row (no pillar):
```

There is no such row. `specs/022-mutation-coverage/coverage.md` ends with a **measurement table**
(`| obliged | 179 | 192 |`), and `covrows()` takes every line starting with `|` that is not a
separator and does not say `Pillar`. The empty first cell of its header becomes an orphan criterion
with no name.

### 3. `mutate.sh coverage` and `cases.sh` are correct by luck

Both index by the coverage table's column numbers and then read **every** pipe line in the file. On
a six-column matrix and on the trailing measurement table alike, the cell they take for Status is
empty, the row fails the status test, and it drops out. The answer is right; the reason is that the
wrong cell happened to be blank.

**One cause: nothing binds the parse to *the* coverage table.** A markdown file may hold several,
and a fixed-index reader of pipe-split text cannot fail — it reads a different column and reports.

## The reader

```
matrix_header FILE   -> "CRIT ORIGIN LINK STATUS FIRST LAST"  (1-based fields, row range)
                        empty if no table in the file has both a criterion and a status column
matrix_rows   FILE   -> one line per data row of THAT table, tab-separated by column name
```

**The table is found, not assumed:** the first header row followed by a `|---|` separator whose cells
name both a criterion and a status column. Rows are read from there until the table ends — a blank
line or a line that does not start with `|`. A second table below is out of range by construction
rather than by filtering.

**A file with no such table is reported by every consumer, never guessed at.** `cases.sh` already
does this; `status.sh` and `mutate.sh` gain it.

## Requirements

### R1 — One reader, sourced by three tools
No consumer runs `awk -F'|'` over `coverage.md` on its own.

### R2 — Columns are located by header name
`status.sh` names `idempotency by key` on `001-example`, not the Origin cell.

### R3 — Rows come from the coverage table only
`status.sh` reports no orphan row for `022-mutation-coverage`; the measurement table is out of range.

### R4 — A file with no coverage table is reported
Every consumer says which file, and exits non-zero rather than reporting zero rows as a clean result.

### R5 — No other verdict moves
Recorded before the work, in `alignment.md` gate note 1 and repeated here:

| | baseline on `main` |
|---|---|
| `mutate.sh coverage --all` | **205 obliged, 137 undeclared, 110 excluded, 0 unresolvable** |
| `cases.sh` | **15 case rows, 15 resolved, 0 unresolved, 0 missing, 0 orphan** |
| `status.sh`, all features | 2 gap lines + 1 anomaly, listed above |

After: the first two **byte-identical**; `status.sh` differs in exactly the two ways `R2` and `R3`
predict and nowhere else.

### R6 — The suite stays green and hermetic, and the cost is measured

## Edge cases (`/distill` expansion — 7)

1. **Six-column matrix** — `001-example`. → R2, defect 1.
2. **A second pipe table in the same file** — 022's measurement table, and 023's. → R3, defect 2.
3. **A table whose header names neither column** — reported, not skipped. → R4.
4. **A file with no table at all** — same. → R4.
5. **`idem` in the linked cell**, which `mutate.sh` and `cases.sh` both resolve to the row above.
   One reader now owns that rule; it must keep resolving within the coverage table only.
6. **A criterion whose label contains spaces** — `message clarity`. Trimmed, never stripped; 023
   shipped that bug and only the real matrix caught it.
7. **The `Pillar`-based orphan test** in `status.sh` becomes column-driven, so a six-column matrix
   with no pillar column does not report every row as an orphan.

## Non-goals

Changing what any tool decides; reformatting `001-example`; vendoring the three tools (none is in
`KEEP` or `DROP` — filed); the shared parser travelling anywhere.
