# Tasks — Mutation audit

> Done when all criteria are `✅ uat` and the suite is ≥ **518 PASS / 0 FAIL**.

**Written before the remaining implementation.** The 26 declarations and the two `check_98` scan
fixes already exist: they **are** the measurement `/distill` reports, and a spec claiming a number
it had not taken would be the thing this repository keeps catching. T3–T5 are what remains.

## T1 — The 26 declarations *(done at `/distill`, as the measurement)*
Every criterion of 018 and 019, including the seven that never had one.

## T2 — The two `check_98` scan fixes *(done at `/distill`)*
Forced immediately: both criteria went red against their own declarations.

## T3 — Contract in 🔴 RED
Six criteria in `check_99` against a runner that still skips multi-label headers and reports that
still overstate their evidence.

## T4 — `mutate.sh` rejects a multi-label header
By name, with file and line, exit 2. **After T3:** the rejection must be seen to fail first, or the
criterion asserts a behaviour that was already there.

## T5 — Correct the two reports and extend the pattern
Append what the audit found to each report; add the self-scan rule to
`base/patterns/non-vacuous-checks.md`.

## T6 — Close the RED
Suite green, `mutate.sh run --tests tests` exit 0 across all 40, cost reported.
