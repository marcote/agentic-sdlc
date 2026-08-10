# Retro — 018-adoption-fixture @ 34c753f

closes: `specs/018-adoption-fixture/alignment.md` · `verification/reports/018-adoption-fixture-3adc719.md` · date: 2026-08-09

> Closes the measurable prediction that `/align` opened.

## Face A — Mission

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator) |
|---|---|---|---|
| `agnostic-portability` | the contract remains intact when vendored onto an arbitrary repo/stack | ✅ moved | `ADOPT-GR-COVERED`: 7 verdicts for the target's own 7 effective rules, not our 6 · `coverage.md` row 18 |
| `real-enforcement` | gates block closure when a condition is missing | ✅ moved | `ADOPT-UNCOVERED-FIRES`: `GR4: uncovered`, exit 1, on a foreign charter · `ADOPT-GUARD-FAILS`: non-zero on the violated copy |
| `measurable-impact` | gaps caught early, late rework avoided | ✅ moved | 2 defects caught before merge: R6 at `/distill` (`spec.md` §"Found at /distill") and a vacuous assertion at `/verify` (M1, report §2) |

- **Align calibration.** The three scores held.
  - `pillarFit: 5` was right and is the one I would raise if the scale went higher. The pillar's
    signal says the contract must remain intact when vendored; this is the first feature that
    tested *intact* rather than *copied*.
  - `scopeCompliance: 4` was right, and for the reason stated. The fixture carries a source file,
    so it sits on the edge of *"application code of an adopting project"*. `/uat` had to judge
    inertness, and did.
  - `missionAdvancement: 4` was right and stays 4. It closed the cheap half. Whether the workflow
    is worth its cost, and whether `/uat` works against a product objective, still need a real
    project.
- **Mission verdict:** confirmed
- **The falsification test, answered.** `alignment.md` set it before the work: *does a gate behave
  differently on the fixture than on this repository, excluding the known pin-id defect?* It does —
  `ground-rules` resolved companion files against the process cwd. Unknown before this feature.
  Without that, `measurable-impact` would have closed `⏳`, as 016's and 017's did.
- **The severity is small and saying so is the point.** `/plan` runs from the adopter's own root,
  where cwd and artifact coincide, so no adopter had been misled. The finding is that the gate
  could not survive being pointed anywhere else.

## Face B — Method

- **Gaps caught by `/distill`:** 10 edge cases `[deriv$ grep -cE '^[0-9]+\. ' specs/018-adoption-fixture/spec.md $]` plus 6 grilling decisions `[deriv$ grep -cE '^### G-' specs/018-adoption-fixture/spec.md $]`.
  The notable one is in neither count: **R6 was found by running the gate during the grilling**,
  before a line of the check existed.
- **RED→GREEN discipline:** yes, with 4 documented exceptions `[deriv: coverage.md §"RED state (/contract)"]`.
  14 of 18 criteria failed at `/contract`. The 4 that passed are listed with why each has no honest
  red state.
- **Rework post-`/verify`:** 1 · **post-`/uat`:** 0 `[deriv: verification/reports/018-adoption-fixture-3adc719.md §2]`.
  The one is `ADOPT-REL-RESOLUTION`, rewritten after mutation M1 showed it could not discriminate.
- **Escalations to the human:** 0 `[deriv: git log main..HEAD; the session ran unattended by request]`.
- **Criteria that can fail, proved:** 11 mutations `[deriv$ grep -cE '^\| M[0-9]+ \|' verification/reports/018-adoption-fixture-3adc719.md $]`, one at a time, each reverted before the next.
- **Friction from the WoW itself.** Two things, and one of them is not friction.

  **The `UNPINNED` bounce cost about ten minutes and was worth it.** `S9` forced me to write down
  that one fixture buys one stack's worth of evidence. Without the pin that limitation would be a
  fact about the repository nobody had stated.

  **Mutation testing is still hand-run and still the only thing that catches vacuity.** Eleven
  mutations, each a manual edit-run-revert. It caught the one real defect in my own work this
  feature. `docs/backlog.md` B8 has said semantic vacuity is unmechanised since 015; this is the
  third feature to pay that cost, and the second where hand-mutation was what saved it.

## Face C — Loop

- **Candidate rules → constitution:** none. The lesson this feature teaches — *a portability claim
  is only tested by a target you do not control* — is already recorded as `S9` in the charter,
  which is where a decision with a price belongs. Adding a constitution rule on top would be the
  second copy of one idea, and `writing-terse` warns that answering feedback with another rule is
  the trap.
- **Candidate amendments → North Star:** none. No signal changed and none needed to.
- **The one recorded deviation.** `/tasks` was written after implementation. `coverage.md` was the
  actual work-list, which raises a fair question about what `/tasks` buys once a traced criterion
  matrix is frozen. Filed as `B13` rather than answered here, because answering it needs the
  evidence of which features' task lists sequenced anything their coverage did not.
- **Backlog:** `B12` filed at `/distill` — `since` is unvalidated when a repository has no
  `decisions/` directory. Deliberately not widened into this feature.
