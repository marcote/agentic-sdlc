# Tasks — Adoption fixture

> Done when all criteria are `✅ uat` and the suite is ≥ **474 PASS / 0 FAIL**.

**Written after implementation, not before it.** `coverage.md` was the work-list this feature
actually ran on, and this file restates it. Recorded in the trajectory eval and filed as `B13`
rather than backdated, because a task list written afterwards that claims to have guided the work
is exactly the filler-to-comply the retro procedure exists to prevent.

## T1 — Contract in 🔴 RED
`tests/check_98_adoption.sh` written against a fixture that does not exist yet. 14 of 18 criteria
red; the 4 that cannot be red documented in `coverage.md` rather than discovered at `/verify`.

## T2 — The fixture
`tests/fixtures/adopter/` — marker, one source file, its own test and test command, two guards,
an authored charter with four `P` pins and three declines, an authored North Star with one ADR,
and a rule layer adding `GR7`.

## T3 — R6, the divergence found at `/distill`
`_default_rule_paths` resolves from the charter's own directory upward, with cwd as the last
resort so every existing caller stays byte-identical.

## T4 — `adopter-violate.sh`
The violation is authored by the fixture. A harness that writes its own violation is testing its
knowledge of the fixture, not the seam.

## T5 — Close the RED, then break it on purpose
Suite green, then eleven mutations one at a time. M1 exposed `ADOPT-REL-RESOLUTION` as vacuous,
which cost the one rework this feature recorded.
