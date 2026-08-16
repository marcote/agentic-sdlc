# Spec — The obligation to declare a mutation, derived from the coverage matrix

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- `scripts/mutate.sh coverage` — a third subcommand: which criteria of a feature are obliged to
  declare a mutation, and which do not.
- `tests/check_97_mutation_coverage.sh` — the subcommand's contract, every criterion declaring its
  own mutation.
- `.claude/skills/verify/SKILL.md` and `.github/workflows/verify.yml` — the gate wired where the
  mutation run already is.
- `memory/constitution/base/patterns/non-vacuous-checks.md` — the obligation stated as the rule it
  now is, rather than as a capability.

## The measurement, taken at `/distill`

| | |
|---|---|
| criteria **obliged** to declare | **179** |
| of those, **undeclared** | **137** |
| rows excluded **by rule** (no assertion to mutate) | 8 |
| rows **unresolvable** (named a check file that does not exist) | **0** |

Per feature, the boundary fell out of the data rather than being chosen:

| feature | obliged | undeclared |
|---|---|---|
| 002 … 017 (twelve features) | 137 | **137** |
| 018, 019, 020, 021 | 42 | **0** |

The four features since the runner existed are complete. Everything before it is untouched. That is
the forward-only line, and it needs no baseline list and no exemption record — which matters,
because `B4` is the standing evidence that a permanent warning trains its reader to skip warnings.

## The predicate, and why each condition is there

A coverage row is **obliged** when all three hold:

1. **Origin is `project`.** A `[given]` row is inherited from a constitution pattern and is
   asserted by whichever criterion the feature routed it to; obliging it would demand a mutation
   for a row that owns no assertion.
2. **Status is a deterministic state** — `🔴 red`, `🟢 green`, `✅ uat`. A `📋 case` row is scored by
   judgment and a `deferred` row is justified as absent. Neither has an assertion to break.
3. **The linked-test cell resolves to a check file that exists.**

### Condition 3 is where the work is, and it is the `B11` family

The linked-test column was never machine-uniform. Measured across sixteen matrices, it holds bare
filenames (`check_92_stack.sh`), prefixed paths (`tests/check_99_mutations.sh`), parentheticals
(`check_80_north_star.sh (grep Pillar)`), compounds (`tests/run.sh + check_88_bootstrap.sh`) and
plain prose (`/uat judgment`, `documented contract — per-stack engine`).

An earlier form of this predicate required the literal `tests/check_`. It reported **47** undeclared
instead of 137, because it silently dropped every feature before 015. **A predicate that discards
what it cannot parse reports a smaller, cleaner, wrong number** — the failure is indistinguishable
from the success, which is exactly `B11`, `B9` and `B5`.

So resolution is by extraction, and non-resolution is **not** silence:

- the first `check_*.sh` token anywhere in the cell → the row is obliged, and that file must exist;
- no `check_*.sh` but the cell names something ending `.sh` → **unresolvable, exit 2, reported by
  name**. This is the typo path: `chek_99_mutations.sh` must not become a quiet exemption;
- no script named at all → **not obliged, and counted**. The count is printed, so a row leaving the
  obligation is visible rather than merely absent.

## Requirements

### R1 — `coverage --spec DIR` gates one feature
Exit 0 when every obliged criterion declares a mutation; **1** when any does not, each named with
its label and the coverage row that obliged it; **2** on an unresolvable row or unusable input.

### R2 — `coverage --all` reports the standing debt
Per feature and total, over every `specs/*/coverage.md`. It is a report, not a gate: exit 0 even at
137 undeclared, because gating the debt would block every feature on twelve closed ones. Exit 2
survives, because an unresolvable row is a defect in the matrix regardless of mode.

### R3 — An unresolvable row is reported, never skipped
Named with its feature, label and the cell that could not be resolved.

### R4 — A row excluded by rule is counted
The excluded total is printed in both modes. Exclusion is a number, not a silence.

### R5 — The gate reads no git ref and no network
`coverage` touches `specs/` and `tests/` only. 019 shipped a check reading `git show main:…` that
was green locally and failed in CI on a shallow detached-HEAD checkout; `run` already avoids this
and `coverage` must not reintroduce it.

### R6 — This feature passes its own gate (`D4`)
Every obliged criterion of 022 declares a mutation, and the verdict is **run and recorded** in the
verification report — not asserted to pass.

### R7 — The gate is wired where the mutation run is
`/verify` and CI, never inside `tests/run.sh`. Same reentrancy argument 020 recorded and then walked
into.

### R8 — The added cost is measured
Reported, not estimated.

## Edge cases (`/distill` expansion — 7)

1. **A cell reading `idem`** — 020 and 021 use it for every row after the first. It resolves to the
   row above; an `idem` inheriting an unresolvable cell inherits the error. → R1, R3.
2. **A typo'd check filename** that no longer matches `check_*.sh`. → R3, the `.sh` fallback.
3. **A check file named in the matrix that has been deleted.** Same exit as a typo, different
   cause, and the message says which. → R3.
4. **A declaration satisfying the gate while being worthless** — `[mut$ true $]` passes `coverage`
   and fails `run`. Deliberate: this asks whether a declaration exists, 020 asks whether it works.
   The pair closes it; neither alone does. → stated in `alignment.md` gate note 4.
5. **A feature with zero obliged rows** (`001-example`) exits 0 and says `0 obliged`, rather than
   exiting 0 silently — silence and success must not be the same output. → R1, R4.
6. **A criterion in a check file with no coverage row at all.** Measured: **0 today**, all 46
   declarations trace to a row. The inverse of the gap and out of this feature's scope.
7. **The debt figure going stale.** Not recorded as a snapshot anywhere; re-derived by `--all` at
   every `/verify`, so the number in a report is the number at that ref. → R2, R8.

## Non-goals

Declaring the 137; gating closed features; judging whether a declaration is any good (020 does);
`B14`'s `📋 case` rows; a baseline or exemption list.
