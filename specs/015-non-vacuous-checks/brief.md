# Brief — The meta-check: an assertion must be able to fail, and be seen doing it

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

The harness has extensive machinery to ensure a test **exists** and goes **red**, and none to
ensure an assertion **can fail** or that a declared criterion **actually emits a result**. This
feature builds the mechanical half of that gate — a check that reads the suite's own check files
and fails when an assertion is structurally incapable of reporting.

**The prose half already shipped.** `memory/constitution/base/patterns/non-vacuous-checks.md`
landed on 2026-08-09 with five injected `[given]` criteria. This feature does not restate it; it
executes the subset of it that can be executed, and leaves the rest explicitly to review.

## Why / motivation

The failure is worse than a missing test, because nothing looks wrong. A check that cannot fail
reports a floor that is not there, and every gate downstream proceeds with a clean conscience.
Twelve occurrences are on record across 008, 013, 014 and today's tracker fix.

**Writing the rule down has now failed three times, and the third time is the decisive one.** It
was proposed in 013's retro, restated as decision D10 in 014's plan — occurrences 6 through 10
happened anyway, in the same branch as the warning. It then landed in the constitution as a
pattern, and **within hours a vacuous assertion shipped anyway** (`REPORT-PRECEDENCE` in
`check_86`, which passed against a fixture built to break it because `ls` sorts its arguments).

That last occurrence is the honest core of this brief, and it cuts both ways:

- **It does not formally refute the pattern.** The tracker fix was a direct patch, not a feature —
  it carried no `[given]` rows because it never passed through `/distill`. The pattern's
  falsification condition ("a feature that ships a vacuous check *while carrying these rows*") was
  not met.
- **But it removes the reason to wait.** The vacuity recurred in the one context where attention
  was highest: minutes after landing the rule, while deliberately applying it. If manual
  application fails there, it fails everywhere. And the manual application *did* work — it caught
  the vacuity, and chasing it exposed a second, real defect underneath (precedence resolving by
  mtime, so a stale report could shadow the current one). That is the argument for automating it,
  not against: the method works and is too expensive to run by hand every time.

**Evidence the mechanical approach pays:** a traceability scan written in minutes on 2026-08-09
found a real instance in feature 008 — `DEPFREE` emitted through a shared helper carrying no
criterion label. Closed feature, green suite, undetectable by reading.

**Evidence it is not trivial:** the **first, naive** version of that scan reported **112 false
positives**, because it treated the unused failure-branch label of every passing assertion as a
dead assertion. The correct form pairs each criterion's pass and fail branches. Designing that is
the actual work, and it is precisely why "write down the rule" has not solved this three times.

## Success metrics

- **A meta-check ships and runs inside the existing suite** — one more `tests/check_*.sh` picked up
  by the runner, no new dependency and no new command.
- **Traceability is mechanically enforced**: every criterion label declared in a check file emits a
  result in the run. The scan pairs a criterion's pass and fail branches rather than counting
  labels, and produces **zero false positives** against the current suite, which is green and
  known-good.
- **Self-scanning checks are mechanically constrained**: a check that greps its own source for a
  forbidden literal must assemble that literal at runtime. Detected, not merely documented.
- **The meta-check is itself proved non-vacuous** — it fails on a negative fixture for each rule it
  enforces. A meta-check that cannot fail would be the joke this feature is named after.
- **It is run against the suite as it stands and the instances it flags are fixed** — the feature
  does not ship a check whose first real run is someone else's problem.
- **The scope split is stated in the shipped artifact**: which shapes are enforced mechanically and
  which remain with review. Implying full coverage would repeat this feature's own failure mode one
  level up.
- **The suite stays green and hermetic** — detached HEAD, no local branch, no terminal.

## Out of scope

- **Detecting semantic vacuity.** Whether an assertion's pattern is satisfied by text that was
  already present, or is too loose to discriminate, requires knowing what the assertion *means*. It
  stays an injected `[given]` criterion and a review concern.
- **Amending or restating the constitution pattern.** It landed on 2026-08-09 and is not reopened
  here. If this feature's implementation contradicts it, the pattern is what changes, via
  `update-checklist.md` — not silently.
- **Retrofitting every historical check.** Only the instances the meta-check flags are fixed.
  Features 001–014 are not reopened.
- **A per-assertion coverage percentage or any scoring.** The verdict is binary: a criterion emits
  a traceable result, or it does not.
- **Enforcing this on an adopter's own test suite.** The meta-check reads `tests/check_*.sh`, which
  is the harness's own convention. An adopter inherits the *pattern*, per the standing "contract in
  the template, engine per-stack" doctrine.

## Dependency

None hard. Reuses the existing suite (`tests/run.sh` globs `check_*.sh`, so no wiring), the shared
helpers in `tests/lib.sh`, and `/distill`'s existing `[given]` injection from `base/patterns/*.md`.

**`D4` (gate bootstrap) applies and must be declared in `plan.md`.** This feature ships a check
that reads every `tests/check_*.sh` — including its own. It cannot be blocked by itself, but under
`D4` the exemption is from being *blocked*, never from being *run*: the finished meta-check must be
run against its own file and emit a real verdict before close, and task ordering must bring the
feature into compliance with its own rules before the final verify.

**Expected not to close 013's or 014's `pending-observation`.** 014's trigger needs a mandatory step
*rejected* for lacking justification, or a feature stopped by `UNCOVERED` against pre-existing
ground rules. 013's needs a real `UNPINNED`/`TRIPPED` against a pre-existing pin. This feature is
unlikely to produce any of the three, and saying so now is cheaper than discovering it at `/retro`.
