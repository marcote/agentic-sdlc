# Plan — 022-mutation-coverage

> HOW it is built. Fail-closed against `memory/stack/stack.md` before any decision is taken.

## Charter gate

`python3 scripts/stack/engine.py exposure memory/stack/stack.md` → `10 pins · 8 PINNED ·
2 PROVISIONAL`, exposure on `S2` and `S9`.

| Decision this feature takes | Pin | Verdict |
|---|---|---|
| a third subcommand on `scripts/mutate.sh`, in shell | `S3` dependency-free baseline: shell + coreutils | **PASS** |
| the obligation is read from versioned markdown (`coverage.md`) | `S6` state lives in versioned markdown | **PASS** |
| an unresolvable row aborts with exit 2 and writes nothing | `S8` fail closed, write nothing, never partially apply | **PASS** |
| the gate asserts this repository's harness, never an adopter's product | `S7` green proves this repository's harness | **PASS** |
| the mandatory step is justified by a measurement, not by preference | `S0` rigor tier: high | **PASS** |
| no tool, format or language is prescribed to an adopting project | `S1` impose no answers | **PASS** |

**No `UNPINNED` decision.** The one that came closest was *where the debt figure lives*, and it was
resolved by removing the decision: nothing stores a snapshot, `--all` re-derives it. A stored number
would have needed a pin for its staleness policy.

**No pin `TRIPPED`.** `S2` is exposed because the North Star engine is python3; `coverage` adds no
python beyond the timing call `run` already makes, so the exposure is unchanged rather than widened.

## Decisions

### D-1 — A subcommand of `mutate.sh`, not a new script
The declaration index already lives in `collect decl`. A second reader of the same grammar is how
`status.sh` and `check_90` came to disagree about DONE (`B9`), and **the reassuring answer is the
wrong one**. One parser, three subcommands.

### D-2 — Resolution by extraction, non-resolution by exit 2
The alternative — require a canonical `tests/check_*.sh` cell — reports 47 instead of 137 and reads
cleaner while being wrong. Rejected at `/distill` after producing that number. Sixteen matrices
written over six weeks are not going to be retro-formatted, and a gate that demands they be is a
gate that gets bypassed.

### D-3 — `--spec` gates, `--all` reports
Gating the standing debt would block every future feature on twelve closed ones, which is `B15`'s
explicit instruction not to require a mutation everywhere. Exit 2 is the exception: an unresolvable
row is a defect in the matrix in either mode.

### D-4 — Forward-only by construction, with no baseline list
018–021 already sit at zero. No exemption record, no known-anomalies file — `B4` is the standing
evidence that a permanent warning trains its reader to skip warnings.

### D-5 — `check_97`, a new file
`check_99_mutations.sh` is already 18k and carries two features' contracts. The linked-test column
of this matrix points somewhere unambiguous.

## Sequence

1. `tests/check_97_mutation_coverage.sh` with all 13 criteria — **RED before any implementation**.
2. `scripts/mutate.sh coverage` — predicate, three buckets, both modes.
3. Fixtures under `tests/fixtures/covgate/` for the unresolvable and typo paths, which have **no
   instance in this repository today** (measured: 0) and therefore need one authored.
4. Declare a `[mut$ … $]` for each of the 13 — `D4`, and the gate's own subject matter.
5. Wire `/verify` and CI.
6. State the obligation in `base/patterns/non-vacuous-checks.md`.
7. `/verify` → `/uat` → `/retro`.

## Risks

- **The gate passing on this feature proves little.** Recorded in `alignment.md` gate note 2 and it
  must reach the verification report, not be quietly dropped between artifacts.
- **`[mut$ true $]` satisfies this gate.** Closed by `run`, not by `coverage`. Stated, so it is not
  later read as an oversight.
- **13 more declarations at about a second each.** Measured at `/verify`, reported, not estimated.
