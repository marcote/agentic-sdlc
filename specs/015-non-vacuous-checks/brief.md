# Brief — Non-vacuous checks: an assertion must be able to fail, and be seen doing it

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

The harness has extensive machinery to ensure a test **exists** and goes **red**, and none to
ensure an assertion **can fail** or that a declared check **actually runs**. Ten defects of that
family landed across features 013 and 014, plus `e6bc658` before them. Every one was caught by
hand; one was caught only because a human asked a question the artifacts could not answer.

This feature closes the half of that gap that can be closed mechanically, and is explicit about
the half that cannot.

**The critical constraint, and the reason this is not simply another pattern file:** this rule
has already been written down twice — proposed in 013's retro, restated as decision D10 in 014's
plan — and occurrences **6 through 10 happened anyway**, in the same branch as the warning. A
rule that only exists as prose has now failed empirically. The deliverable is therefore an
**executable meta-check** plus the pattern, in that order of importance.

## Why / motivation

The failure is worse than a test that does not exist, because nothing looks wrong. A check that
cannot fail reports a floor that is not there, and every gate downstream proceeds with a clean
conscience. The ten occurrences fall into distinct shapes, and naming them matters because they
are not all detectable the same way:

- **Self-detection** — a check that scans its own source for a forbidden literal matches its own
  scanning line (`check_90`/`e6bc658`; `HERMETIC-ENV` and `/dev/tty`; the grace-period pattern
  flagging its own denial).
- **Untraceable results** — an assertion runs, but its output cannot be tied back to a coverage
  row, so "did this criterion actually execute?" is unanswerable (`PLAN-UNCOVERED` in 014).
- **Passing for an unrelated reason** — three assertions passed because a subcommand *did not
  exist* and the runner exited with the same code the assertion expected. All three would have
  stayed green against an empty implementation.
- **Semantic vacuity** — an assertion whose pattern is satisfied by text that was already there
  (`wow-report =~ /pin/`), or a pattern too loose to discriminate (an unanchored name matching
  a longer word).
- **Reporting on the wrong tree** — a check run against uncommitted work or an empty commit
  range returns a confident, false verdict.

Evidence that the mechanical approach works, gathered while writing this brief: a corrected
traceability scan, written in minutes, **immediately found a real instance in feature 008** —
`DEPFREE` in `check_86_status.sh` emits its result through a shared helper that does not carry
the criterion label, so the criterion cannot be traced from the run output. Closed feature,
green suite, undetectable by reading.

Evidence that it is not trivial, gathered the same way: the **first, naive** version of that
scan reported **112 false positives**, because it treated the unused failure-branch label of
every passing assertion as a dead assertion. Designing this correctly is the actual work — which
is precisely why "write down the rule" has not solved it twice already.

## Success metrics

- **A meta-check ships and runs inside the existing suite**, requiring no new dependency and no
  new command — it is one more `tests/check_*.sh` picked up by the runner.
- **Traceability is mechanically enforced**: every criterion label declared in a check file
  emits a result in the run. The scan pairs a criterion's pass and fail branches instead of
  counting labels, and is proved against a fixture where an assertion genuinely never executes.
- **The `DEPFREE` instance in `check_86_status.sh` is detected and then fixed**, demonstrating
  the check against a real defect that predates it rather than only against fixtures.
- **Self-scanning checks are mechanically constrained**: a check that greps its own source must
  assemble the forbidden literal at runtime, so it cannot match its own scanning line. Detected,
  not merely documented.
- **The meta-check is itself proved non-vacuous** — it must fail on a fixture that violates each
  rule it enforces. A meta-check that cannot fail would be the joke this feature is named after.
- **`memory/constitution/base/patterns/non-vacuous-checks.md` ships** with injected `[given]`
  criteria for the shapes that cannot be automated: a negative fixture per assertion, a
  rejection assertion requiring the diagnostic and not only the exit code, and a check that
  states which tree it reports on.
- **The scope split is stated in the pattern itself**: which shapes are enforced mechanically
  and which rely on review. A pattern that implies full coverage would repeat this feature's own
  failure mode at one level up.
- **The suite stays green and hermetic** — detached HEAD, no local branch, no terminal.

## Out of scope

- **Detecting semantic vacuity.** Whether an assertion's pattern is satisfied by text that was
  already present requires knowing what the assertion *means*. It stays an injected `[given]`
  criterion and a review concern. Claiming otherwise is the failure this feature exists to stop.
- **Retrofitting every historical check.** Only the instances the meta-check flags are fixed —
  which, at the time of writing, is `DEPFREE` in `check_86_status.sh`. Features 001–014 are not
  reopened.
- **A per-assertion coverage percentage or any scoring.** The verdict is binary: a criterion
  emits a traceable result or it does not.
- **Enforcing this on an adopter's own test suite.** The meta-check reads `tests/check_*.sh`,
  which is the harness's own convention; an adopter inherits the *pattern* and applies it in
  their stack, per the standing "contract in the template, engine per-stack" doctrine.

## Dependency

None hard. Reuses the existing suite (`tests/run.sh` globs `check_*.sh`, so no wiring), the
shared helpers in `tests/lib.sh`, and `/distill`'s existing `[given]` injection from
`base/patterns/*.md`.

**Expected not to close 014's `pending-observation`.** That trigger requires either a mandatory
step being *rejected* for lacking justification, or a feature being stopped by `UNCOVERED`
against ground rules that predate it. This feature is unlikely to produce either, and saying so
now is cheaper than discovering it at `/retro`.
