# Spec — A `📋 case` row resolves, or says why it cannot

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- `scripts/cases.sh` — resolves every `📋 case` row in both directions, with three buckets and
  nothing silent.
- `tests/check_93_case_resolution.sh` — its contract, every criterion declaring its mutation.
- Three case files written, and one row repointed.
- `.claude/skills/verify/SKILL.md` and `.github/workflows/verify.yml` — wired where the other
  resolution gates run.
- `docs/backlog.md` — `B14` replaced with figures the tool derives.

## The measurement, taken at `/distill`

| | |
|---|---|
| `📋 case` rows in `specs/*/coverage.md` | **14** |
| resolve: path named, file exists, file names the criterion | **11** |
| name a file that does not exist | 2 |
| name no path at all | 1 |
| file exists but does not name the row's criterion | **0** |
| case files on disk cited by no row | **0** |

`B14` claimed 32 rows and 21 unresolvable. Both figures came from `grep -c '📋 case'`, which counts
the **status-legend line present in all 19 matrices**. The corrected entry ships with this feature.

## The predicate

A `📋 case` row resolves when all three hold:

1. **It names a path** under `evals/cases/`.
2. **That file exists.**
3. **That file names the row's criterion label.**

Condition 3 costs nothing today — all 11 pass — and it is the one that catches drift: a row
repointed at the wrong file, or a case file that lost the criterion it was written for. Without it
the gate proves a file exists, not that it is *this row's* case.

### Why "must name a file" does not force a meaningless stub

The obvious objection, raised at `/align` before the design: 022's row honestly reads *"next
feature"*, because the thing to judge does not exist yet. A rule demanding a file would turn an
honest deferral into a stub and make the matrix look more complete while meaning less.

**The objection does not survive the precedent.** 019 and 020 both deferred a judgment and both
wrote the file anyway. `evals/cases/prevents-the-sixth.md` states its question, what counts as
`Confirmed`, what counts as `Refuted`, a `Not before:` trigger, and a `## Trap` naming the way a
lazy judge would get it wrong — all before anything could be scored. **A deferred case is still a
case; the trigger lives inside the file.** Writing it is what makes the deferral auditable instead
of a row that renders as pending forever.

### Why the structure is NOT checked

Two shapes are in use, both honest: multi-case files (`## Case N — LABEL`, with inputs and
`**Expected judge behavior:**` / `**FAIL if:**`) in 002 and 013–017, and single-case files
(`## Question`, `**Confirmed**`/`**Refuted**`, `Not before:`) in 019 and 020. Only 2 of 8 files
carry the second shape. **A structural check would flag six good files**, so the rule stops at the
label binding — the one thing both shapes share.

Existence is not quality, the same division 022 drew. Scoring is `B2`.

## Requirements

### R1 — Every `📋 case` row resolves, or is named
Exit 0 when all three conditions hold for every row; **1** when a row names no path or its file does
not name its criterion; **2** when a named file does not exist. Each reported with its feature,
label and the cell that failed.

### R2 — A case file cited by no row is reported
Zero today. The check must be able to *say* zero rather than only being able to say nothing — a
directory nobody points at is the mirror of a row pointing nowhere.

### R3 — Columns are resolved by header name, not by fixed index
`001-example`'s matrix has **six** columns, not seven; its label column parsed as `project` under
fixed indexing. The table splits into the same field count either way, so a fixed-index reader does
not fail — **it reads the wrong column and reports confidently.** The header row names its columns;
the reader uses it, and a matrix whose header cannot be understood is reported rather than guessed
at.

### R4 — The three broken rows are fixed
- `evals/cases/audit-worth-it.md` — written; cited by 021 and never created.
- `evals/cases/obligation-caught-one.md` — written; 022's row repointed at it.
- `001-example` — decided in `plan.md`, not assumed.

### R5 — The gate runs at `/verify` and in CI, never in `tests/run.sh`
Same argument 020 recorded and 021 walked into.

### R6 — The counts are derived by the tool
`B14`'s replacement quotes the tool's output, not a grep.

### R7 — The added cost is measured

## Edge cases (`/distill` expansion — 8)

1. **A row citing a file that does not exist** — 2 instances, both real. → R1.
2. **A row citing nothing** — 1 instance, written two days ago by the author of 022. → R1.
3. **A file that exists but does not name the row's criterion** — 0 today; the drift condition. → R1.
4. **A file no row cites** — 0 today, and the check must say so. → R2.
5. **A six-column matrix read by a seven-column reader.** Does not error; reports the wrong column.
   → R3.
6. **One file cited by several rows** — `stack-charter-judge.md` by 3, `ground-rules-judge.md` by 2.
   Each row binds independently, and the file must name each criterion. → R1.
7. **A deferred case with no scorable evidence yet** — resolves like any other, because the trigger
   lives in the file. → the precedent above.
8. **The legend line and the deferral prose both contain `📋 case`.** Only table rows are read;
   this is the miscount that produced `B14`'s 32. → R6.

## Non-goals

Scoring any case (`B2`); judging case-file quality; enforcing one file shape; fixing 022's
`coverage` reader, which has the same fixed-index assumption and lands safely by luck — recorded,
not chased.
