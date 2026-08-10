# Brief — The gates run against a vendored target, not only the copying

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

The suite proves that vendoring **copies** the right files. It never proves that the harness
**governs** the repository it was copied into.

This feature adds a fixture target repository and runs the real gates against it: the charter
engine, `/plan`'s verdicts, a declared `Guard`, and the from-zero refusals. The subject under test
stays the harness. The fixture is the input.

## Why / motivation

**Measured.** `check_84` and `check_88` carry 22 criteria between them, and every one asserts a
file landed, a stub was seeded, or a plan was printed. One check runs a gate against a vendored
target: `NS-VENDORED-STUB-REJECTED`, added by 016 two features ago.

**The most valuable defect of the last three features was found there, by hand.** Vendoring onto a
three-file Python repository and writing the pin a user actually asked for — `### P1 — uv` —
returned `empty: no pins yet`. A charter full of pins, silently invisible, and `/plan` would have
waved the feature through on it.

Nothing in the suite could have caught that. The pin id shape was never exercised outside this
repository's own charter, which happens to use the one prefix the parser accepted.

**The cheap half of a gap we have named repeatedly.** The standing gap is that the harness has
never governed a real project end to end. Building an application to close it is expensive and
tests things this feature does not need: whether the flow feels worth it under pressure, and
whether `/uat` works against a product objective. Those need a real project and stay open.

What does **not** need an application is the mechanical half: does a gate behave correctly when the
artifacts belong to someone else?

## Success metrics

- **A fixture target repository exists**, small enough to read in one sitting: a stack marker, one
  source file, its own test command, and a charter with a real pin carrying a `Guard`.
- **The harness vendors onto it and then runs its gates against it**, in the suite, with no
  manual step.
- **A gate that behaves differently on a foreign target than on this repository is caught.** That
  is the whole point, and it is what the pin-id defect was.
- **`/plan`'s `UNCOVERED` fires against ground rules the fixture has not answered**, proving the
  refusal works on someone else's charter and not only on ours.
- **A `Guard` declared by the fixture is executed by name and its failure is observed.** The
  harness must not need to know what it checks.
- **The fixture's own test command is invoked and its result is not counted in `tests/run.sh`.**
  Per `S7`, a passing suite must never silently also claim the fixture works.
- **The fixture is DROP**, and the suite stays green and hermetic.

## Out of scope

- **An application.** No product behaviour is implemented and no product objective is pursued. The
  fixture exists to be governed, not to work.
- **`/uat` against a product objective.** It has never been exercised and this does not exercise
  it. Naming the gap is the honest move; closing it needs a real project.
- **Whether the workflow is worth its cost.** That is a judgment a maintainer makes under time
  pressure, not something a fixture can answer.
- **Testing an adopter's own engine.** The fixture uses the reference engines, per the standing
  contract-in-the-template doctrine.
- **Re-testing what `check_84` and `check_88` already cover.** File copying is proved. This is
  about governing.

## Dependency

`scripts/vendor.sh`, both engines, `scripts/guards/`, and the `_template` artifacts. No new engine.

**`S7` constrains the design and was sharpened for this reason.** What runs in `tests/run.sh` is
the harness's gates over the fixture. The fixture's own suite is invoked to prove the seam exists,
and its result is reported separately, so green keeps meaning one thing.
