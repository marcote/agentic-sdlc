# Tasks — Executable mutations

> Done when all criteria are `✅ uat` and the suite is ≥ **505 PASS / 0 FAIL**.

**Written before implementation**, unlike 018 and 019, which both wrote this file afterwards and
recorded it as a deviation. `B13` asked which task lists sequence anything the coverage matrix does
not. This one does: T2 must precede T3, and T4 must precede T5, for reasons the matrix cannot
express.

## T1 — Contract in 🔴 RED
`tests/check_99_mutations.sh` written against a runner that does not exist. Every criterion red
except the ones with no honest red state, which go in `coverage.md`.

## T2 — `scripts/mutate.sh`: parse and list
Bind each `[mut$ … $]` to the criterion header above it. Heredocs stripped before scanning for the
terminator. Reject unbound and unterminated declarations by name.

**Before T3 on purpose:** a runner whose parser is unproven would apply mutations to the wrong
criteria and report confidently.

## T3 — `scripts/mutate.sh`: sandbox, apply, judge
`git ls-files | tar` into `mktemp -d`, apply, run the owning check file, require `FAIL` and no
`PASS` for the label. Three distinct outcomes: proved · not proved · could not apply.

## T4 — The runner's own negative
A fixture criterion whose mutation does not break it, reported. **Before T5:** if the runner cannot
report a failure to break, the replays would pass for the wrong reason and prove nothing.

## T5 — Replay 018 and 019 verbatim
The shipped assertion blocks from `3adc719^` and `babac0a^`, character-identical, with only the
variables they read supplied. These decide whether the feature was worth building.

## T6 — Turn it on this feature (`D4` condition 2)
Every criterion in `check_99` declares its own mutation and is proved failable by it.

## T7 — Close the RED
Suite green and hermetic, cost reported, `nvc.sh` clean, pattern file updated.
