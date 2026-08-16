# Retro — 020-executable-mutations @ b1444f3

closes: `specs/020-executable-mutations/alignment.md` · `verification/reports/020-executable-mutations-b1444f3.md` · date: 2026-08-16

> Closes the measurable prediction that `/align` opened.

## Face A — Mission

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator) |
|---|---|---|---|
| `real-enforcement` | gates block closure when a condition is missing | ✅ moved | `check-can-fail` went from a coverage row satisfied by prose to a command with an exit code: `mutate.sh run --tests tests` → 14 proved, exit 0, wired into `verify.yml` and the `/verify` skill (`MUT-WIRED`) |
| `measurable-impact` | gaps caught early, late rework avoided | ✅ moved | 6 weak assertions caught by the mechanism **in the feature that shipped it**, before `/verify`'s by-hand pass; report §2 |
| `frictionless-adoption` | every mandatory step carries a justification proportional to what it prevents | ✅ moved | the cost is reported on every run — **13.02s for 14 mutations** — rather than discovered later; `MUT-COST-REPORTED` |
| `agnostic-portability` | the contract survives vendoring onto an arbitrary repo | ⏳ not yet observable | the declaration grammar is in `base/patterns/`, the runner is DROP. No adopter has written a `[mut$ … $]` yet |

- **Align calibration.** Two of three held; one was too low.
  - `pillarFit: 5` was right, and for the reason given: `real-enforcement`'s statement is
    *"deterministic gates, not good intentions"*, and this row had been a good intention since 015.
  - `scopeCompliance: 5` was right. `in_scope` names *"evals, verification, and UAT of the method"*.
  - **`missionAdvancement: 4` was too low.** I held it there because the evidence "cannot exist
    until a feature after this one". That was wrong: the mechanism caught six weak assertions in
    **this** feature, which is exactly the signal. The reasoning confused *prevention* with
    *detection*, and only prevention needed the next feature.
- **Mission verdict:** confirmed
- **The falsification test passed.** `alignment.md` set it in advance: replay 018's and 019's real
  vacuous criteria; if the mechanism misses what actually shipped, it does not work. Both are
  reported as surviving their own mutation, from assertion blocks character-identical to
  `3adc719^` and `babac0a^`.
- **`agnostic-portability` is `⏳`, not `✅`.**
  - **re-check trigger:** an adopter, or the adoption fixture, declares a mutation and it runs.
  - **Sweep by: 2026-09-08**, with 013, 014, 016, 017 and 019.

## Face B — Method

- **Gaps caught by `/distill`:** 9 edge cases `[deriv$ awk '/^## Edge cases/,/^## Non-goals/' specs/020-executable-mutations/spec.md | grep -cE '^[0-9]+\. ' $]` plus 5 grilling decisions `[deriv$ grep -cE '^### G-' specs/020-executable-mutations/spec.md $]`.
  G-c came from measuring rather than guessing: 24.68s for the suite against about a second for one
  check file decided the whole design.
- **RED→GREEN discipline:** yes, with **zero** exceptions `[deriv: coverage.md §"RED state (/contract)"]`.
  13 of 13 criteria red, 0 passing. The first feature here with no green-by-construction row.
- **Rework post-`/verify`:** 3 · **post-`/uat`:** 0 `[deriv: verification/reports/020-executable-mutations-b1444f3.md §2]`.
  Six weak mutations rewritten, one reentrancy bug, one falsification test passing for the wrong
  reason.
- **Escalations to the human:** 0 `[deriv: git log main..HEAD; the session ran unattended by request]`.
- **Criteria proved failable:** 14 `[deriv$ bash scripts/mutate.sh run --tests tests | grep -c '^proved' $]`, executed rather than asserted.
- **Friction from the WoW itself.** The friction inverted this time, and that is the finding.

  For five features the complaint was that mutation testing is manual and untooled. It now costs
  **13 seconds and one command**. What it revealed immediately is that the manual practice was
  weaker than it looked: **six of my fourteen mutations broke nothing**, and I had been writing
  mutations by hand for three features under the impression they all did.

  The by-hand tables in 018's and 019's reports are therefore worth less than they read. I have no
  way to re-check them — those mutations were never written down as commands.

## Face C — Loop

- **Candidate rules → constitution: one, and it landed.** `base/patterns/non-vacuous-checks.md`
  gains `check-can-fail, executed` — the declaration grammar, the three non-interchangeable
  outcomes, and the note that the runner needs its own negative. Prose that would have been
  unearned in 015 is earned now, because a mechanism ships with it. 019's retro declined to propose
  it for exactly that reason.
- **Candidate amendments → North Star:** none.
- **Backlog:** `B8` is **partly closed** — the mechanical form exists for the *narrow* family (an
  assertion whose input guarantees its own outcome), not for semantic vacuity generally. Two items
  remain open and are named in `docs/backlog.md`: who must declare a mutation, and re-checking the
  by-hand mutation tables of 018 and 019 that nobody can reproduce. `B14` was filed on the way past.
