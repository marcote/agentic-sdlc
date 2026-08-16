# Retro — 021-mutation-audit @ bf5c909

closes: `specs/021-mutation-audit/alignment.md` · `verification/reports/021-mutation-audit-bf5c909.md` · date: 2026-08-16

> Closes the measurable prediction that `/align` opened.

## Face A — Mission

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator) |
|---|---|---|---|
| `real-enforcement` | gates block closure when a condition is missing; the harness proves it by dogfooding itself | ✅ moved | 46 declarations run at every `/verify` and in CI, exit 0; the 26 audited ones were prose until this feature |
| `measurable-impact` | gaps caught early, late rework avoided | ✅ moved | 3 defects found in 020, one feature after it shipped; report §4 |
| `frictionless-adoption` | every mandatory step carries a justification proportional to what it prevents | ✅ moved | 60.90s, measured and reported on every run; report §6 |

- **Align calibration.** The 5/5/5 held, and it is the first here.
  - `pillarFit: 5` was right: `real-enforcement`'s signal names dogfooding explicitly.
  - `scopeCompliance: 5` was right: two `in_scope` items, not one at the edge.
  - `missionAdvancement: 5` was right for the stated reason — the evidence exists **before** the
    feature closes. The number was the deliverable and it was taken at `/distill`.
- **Mission verdict:** confirmed
- **The prediction in gate note 1 was wrong, and stating it in advance is what makes that useful.**
  I predicted 7 or 8 of 19 mutations would fail. **One did.** Because the prediction was written
  before the measurement, the good result reads as evidence rather than relief — and the reason is
  now recorded: 020's 6-of-14 rate came from mutations written against a tool still being built.
- **Gate note 2's condition was met.** Two counts, reported separately: **0 criteria vacuous, 4
  mutations weak**. Every survivor was diagnosed before being rewritten, and two of the four were
  portability mistakes in the edit (a GNU-only `sed` address, an unreachable `exit`) that say
  nothing about the criterion.

## Face B — Method

- **Gaps caught by `/distill`:** 6 edge cases `[deriv$ awk '/^## Edge cases/,/^## Non-goals/' specs/021-mutation-audit/spec.md | grep -cE '^[0-9]+\. ' $]` plus 4 grilling decisions `[deriv$ grep -cE '^### G-' specs/021-mutation-audit/spec.md $]`.
  Two of the four grilling entries are defects the audit uncovered rather than ambiguities I
  resolved, which is unusual and is the point of the feature.
- **RED→GREEN discipline:** yes, with 0 exceptions `[deriv: coverage.md §"RED state (/contract)"]`.
  6 of 6 criteria red.
- **Rework post-`/verify`:** 2 · **post-`/uat`:** 0 `[deriv: verification/reports/021-mutation-audit-bf5c909.md §4]`.
  The recursion I walked into, and the two check_98 scans that read their own declarations.
- **Escalations to the human:** 0 `[deriv: git log main..HEAD; the session ran unattended by request]`.
- **Criteria proved failable:** 46 `[deriv$ bash scripts/mutate.sh run --tests tests | grep -c '^proved' $]`.
- **Friction from the WoW itself.** One thing, and it is a correction to what I wrote last feature.

  **020's retro said the by-hand tables of 018 and 019 were "worth less than they read".** That was
  a prediction dressed as a finding, and it was wrong. **18 of 19 reproduce.** What was actually
  weak was 020's own set, for a reason specific to 020: its mutations were written against a tool
  that changed under them.

  The real defect in those tables was **coverage, not validity** — 018 recorded 11 for 16 criteria
  — and I only found that by counting, not by suspecting it.

## Face C — Loop

- **Candidate rules → constitution: one, and it landed.** `base/patterns/non-vacuous-checks.md`
  gains two lines with teeth behind them: a scan over its own file excludes comment lines, because
  a mutation declaration lives in one; and a header naming two criteria cannot carry a mutation.
  Both come from defects this feature hit, not from anticipation.
- **Candidate amendments → North Star:** none.
- **Backlog:** `B16` is **closed** — the tables were re-run and the result recorded in both
  reports. `B15` (who must declare) is unchanged and now better informed: coverage was the real gap,
  so the trigger should be about criteria without a declaration rather than about suspect shapes.
