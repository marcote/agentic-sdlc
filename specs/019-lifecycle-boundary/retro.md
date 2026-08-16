# Retro — 019-lifecycle-boundary @ babac0a

closes: `specs/019-lifecycle-boundary/alignment.md` · `verification/reports/019-lifecycle-boundary-babac0a.md` · date: 2026-08-16

> Closes the measurable prediction that `/align` opened.

## Face A — Mission

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator) |
|---|---|---|---|
| `real-enforcement` | gates block closure when a condition is missing | ✅ moved | `AMEND-LIFECYCLE-REFLEXIVE`: the gate blocks 019's own scope diff with no ADR and passes with `0005`; `amendment-gate.sh --range main..HEAD` exit 0 |

- **Align calibration.** All three scores held.
  - `pillarFit: 4` was right. Excluding something advances no pillar directly, and holding it at 5
    would have claimed more than an exclusion can deliver.
  - `scopeCompliance: 5` was right and remains the second time this score was earned.
    `in_scope` names *"product governance: constitution and North Star"* verbatim.
  - `missionAdvancement: 4` was right, and `/uat` sharpened why. The feature gives the judge a line
    to read; it does not make the deterministic filter fire more often.
- **Mission verdict:** confirmed
- **The immediate half of the falsification test passed.** `alignment.md` set it before the work:
  if any closed feature's objective hit a new predicate, the boundary is wrong. 101 objectives
  across every brief in `specs/`, zero hits.
- **The deferred half is honestly deferred.** Whether the boundary ever changes a verdict pays only
  when a future brief is scored differently because these lines exist.
  - **re-check trigger:** an `alignment.md` cites a lifecycle predicate by name, or the sweep
    arrives and none does.
  - **Sweep by: 2026-09-08**, with 013, 014, 016 and 017.

## Face B — Method

- **Gaps caught by `/distill`:** 8 edge cases `[deriv$ awk '/^## Edge cases/,/^## Non-goals/' specs/019-lifecycle-boundary/spec.md | grep -cE '^[0-9]+\. ' $]` plus 5 grilling decisions `[deriv$ grep -cE '^### G-' specs/019-lifecycle-boundary/spec.md $]`.
  The one that mattered was G-a, and it came from reading `scope-reject`'s implementation rather
  than from imagining it.
- **RED→GREEN discipline:** yes, with 2 documented exceptions `[deriv: coverage.md §"RED state (/contract)"]`.
  6 of 8 criteria failed at `/contract`, before the ADR and the diff existed.
- **Rework post-`/verify`:** 2 · **post-`/uat`:** 0 `[deriv: verification/reports/019-lifecycle-boundary-babac0a.md §2]`.
  `NS-PREDICATE-REACHABLE`, rewritten after M2 showed it could not fail on the property it existed
  to forbid. And `AMEND-LIFECYCLE-REFLEXIVE`, which read `git show main:…` — green locally, failing
  in CI, because a shallow detached-HEAD checkout has neither ref.
- **Escalations to the human:** 0 `[deriv: git log main..HEAD; the session ran unattended by request]`.
- **Criteria that can fail, proved:** 8 mutations `[deriv$ grep -cE '^\| M[0-9]+ \|' verification/reports/019-lifecycle-boundary-babac0a.md $]`, one at a time, each reverted before the next.
- **Friction from the WoW itself.** One thing, and it is the same thing as last feature.

  **Mutation testing caught a vacuous assertion for the second consecutive feature, and it is still
  entirely manual.** 018's `ADOPT-REL-RESOLUTION` compared two runs that could not differ; 019's
  `NS-PREDICATE-REACHABLE` built its test input from the thing under test. Different shapes, same
  family: **an assertion whose input guarantees its own outcome.**

  That is now four vacuous assertions in five features, all caught, none by `nvc.sh`. `B8` has
  tracked this as unmechanised since 015. Two consecutive catches by the same manual technique is
  the strongest argument yet that the technique deserves tooling.

- **The second one is worth more than the first.** I wrote the `hermetic-env` `[given]` row into
  this feature's own `coverage.md` and then broke it in the same feature. The row did its job — CI
  is where it is enforced, and CI is what caught it. A carried `[given]` row is not a reminder;
  it is a check that runs somewhere I am not.

## Face C — Loop

- **Candidate rules → constitution:** one, and I am **not** proposing it yet. The pattern
  *"an assertion must not derive its input from the thing under test"* is real and has now cost two
  features. But `base/patterns/non-vacuous-checks.md` already carries five rows that did not catch
  either instance, and adding a sixth prose row is what failed three times before 015. It belongs in
  `B8` until someone finds its mechanical form.
- **Candidate amendments → North Star:** one, recorded and not written. `measurable-impact`'s signal
  measures gaps caught and rework avoided, which is process hygiene rather than outcome. ADR `0005`
  names this as follow-up 1 and deliberately does not bundle it. It needs its own argument.
- **Backlog:** `B13` gained its second data point — `/tasks` written after implementation again,
  for the same reason.
