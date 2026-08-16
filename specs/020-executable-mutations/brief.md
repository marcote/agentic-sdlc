# Brief — A criterion declares the mutation that makes it fail, and the suite runs it

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

`base/patterns/non-vacuous-checks.md` carries a row called `check-can-fail`. Every feature since
015 has injected it into `coverage.md`, and it has never once been executed. It is satisfied by a
human writing *"proved failable"* in a report.

The proving is real — eleven mutations in 018, eight in 019 — but it happens **by hand, once, at
`/verify`, and is never run again**. A criterion that could fail in August is not asserted to still
be able to fail in September.

This makes the mutation executable: a criterion declares the edit that must break it, and the suite
applies that edit and requires the criterion to fail.

## Why / motivation

**Five vacuous assertions in five features, none caught by `nvc.sh`.** 015, 016 (two), 018, 019.
The pattern file declares semantic vacuity out of mechanical scope, so this is a known limit — but
`docs/backlog.md` B8 has held it as unmechanised since 015, on the stated grounds that nobody had
found its mechanical form.

**The last two instances show the form.** They are one shape, not two:

| Feature | Criterion | Why it could not fail |
|---|---|---|
| 018 | `ADOPT-REL-RESOLUTION` | expected and actual were read from two copies of the same tree |
| 019 | `NS-PREDICATE-REACHABLE` | the test input was built by interpolating the artifact under test |

**An assertion whose input guarantees its own outcome.** Both were found the same way and only that
way: by mutating the subject and observing that nothing failed. Reading did not find either.

**The precedent is 017.** `[deriv:]` was a prose locator that a human promised was accurate.
Feature 017 turned it into `[deriv$ … $]`, a command the suite executes and compares. That change
found a wrong number in a closed retro within its first run. This is the same move applied to
`check-can-fail`: a prose promise becomes an executed command.

**Why now rather than at the next instance.** Two consecutive features caught by the same untooled
technique is the evidence B8 was waiting for. A third would add nothing but cost.

## Success metrics

- **A criterion can declare its mutation inline**, in the check file next to the assertion, in a
  grammar the suite parses.
- **The suite applies each declared mutation and requires the named criterion to fail.** A mutation
  that leaves everything green is a reported failure, not a silent pass.
- **The mutation is reverted whether it passed or failed**, and the working tree is proved
  byte-identical afterwards.
- **A criterion that cannot fail is named**, with the mutation that failed to break it, so the
  diagnostic points at the assertion rather than at the runner.
- **019's `NS-PREDICATE-REACHABLE` in its vacuous form is caught by this mechanism**, replayed as a
  fixture. The two real instances are the only honest test of whether this was worth building.
- **The cost is bounded and stated.** Each mutation re-runs one check file, not the whole suite;
  the added wall-clock is measured and recorded, not estimated.
- **The suite stays green and hermetic**, and adopters inherit the pattern without the runner.

## Out of scope

- **Retrofitting every existing criterion.** There are hundreds. This ships the mechanism and
  applies it to a named set; the rest is a backlog item with a measured cost.
- **Generating mutations.** The author writes the mutation. A generated one tests the generator.
- **Detecting the dataflow statically.** *"This variable came from the artifact under test"* is a
  taint analysis over shell, and building one would be a larger, less reliable thing than running
  the edit and looking.
- **Replacing the `/verify` mutation table.** The by-hand exploration at `/verify` finds mutations
  worth declaring. This makes the declared ones repeatable; it does not make exploration optional.
- **`check-traceable` and `check-no-self-match`.** Already discharged by `check_96`.

## Dependency

`tests/lib.sh`, `tests/run.sh`, `scripts/nvc.sh` and `tests/check_96_non_vacuous.sh`, plus
`memory/constitution/base/patterns/non-vacuous-checks.md`, whose `check-can-fail` row this makes
executable.

**`D4` applies.** This feature ships a gate that would judge its own criteria, and it cannot be
blocked by that gate while building it. The exemption is from being blocked, never from being run:
the gate must emit a real verdict against this feature's own criteria before close.

**`B7` is a live constraint.** The suite already re-runs itself once for `check_96`. A mechanism
that re-runs a check file per declared mutation multiplies that, and the brief commits to measuring
the cost rather than discovering it.
