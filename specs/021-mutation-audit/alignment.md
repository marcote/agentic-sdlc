# Alignment — 021-mutation-audit

Measurability Gate over `brief.md` × `north-star.md` as amended by ADR `0005`. Run by the 006
engine: `schema-valid` exit 0; `scope-reject` exit 1 on all six objectives; `align-verdict`
`aligned`. The filter was proved live in the same run — the control objective *"blocking commit
hooks"* fired at exit 0.

## Verdict

**`aligned`** — `{pillarFit: 5, scopeCompliance: 5, missionAdvancement: 5}`, threshold 3.
Falsification run: dropping `missionAdvancement` to 2 returns `needs-amendment`.

**The first 5/5/5 in this repository.** That is not enthusiasm and it is worth defending, because
the rubric is a gate rather than an incentive and the doubt rule says prefer the lower score.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | **5** | `real-enforcement`'s signal is *"the harness proves this by dogfooding itself: retro ledger / wow-report"* — the clause is in the pillar, not inferred. This audits two closed features' own evidence with the tool the last feature shipped. `measurable-impact`'s signal is gaps caught; a vacuous criterion in a green feature is the exact gap. |
| scope compliance | **5** | `in_scope` names *"evals, verification, and UAT of the method"* and *"WoW self-validation (retro, wow-report)"*. Two named items, not one at the edge. No `out_of_scope` predicate is approached, including the four lifecycle ones from ADR `0005`. |
| mission advancement | **5** | The rare case where the evidence exists **before** the feature closes rather than after. Every previous feature that scored 4 here did so because its payoff was deferred to a sweep. This one produces a number during its own `/distill`, and that number is the deliverable. There is nothing to wait for. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — every criterion of 018 and 019 carries a declared mutation | `real-enforcement` |
| O2 — the measurement is reported as two numbers: validity and coverage | `measurable-impact` |
| O3 — every criterion that survives is fixed or explicitly justified | `real-enforcement`, `measurable-impact` |
| O4 — the audited set joins the `/verify` run, so it stays proved | `real-enforcement` |
| O5 — 018's and 019's reports are corrected in place | `measurable-impact` |
| O6 — green, hermetic, and the added cost measured | `frictionless-adoption`, `agnostic-portability` |

## Pillar provenance (stamped by `/align`)

| Pillar | `since` |
|---|---|
| `real-enforcement` | `0001` |
| `measurable-impact` | `0002` |
| `frictionless-adoption` | `0004` |
| `agnostic-portability` | `0001` |

## Orphans

None.

## Pillars deliberately NOT claimed

- **`agnostic-portability` is claimed only by O6**, and only as *"stays hermetic"*. Nothing here
  travels: the runner is DROP and the audited checks are this repository's own.

## Gate note

1. **The result is predicted before it is known, and the prediction is unflattering.** If 020's rate
   holds, roughly **7 or 8 of these 19** mutations will not break their criterion. Writing that here
   means the feature cannot later be presented as a clean pass, and it means a *good* result is
   evidence rather than relief.

2. **The real risk is the temptation to fix the mutation instead of the criterion.** When a mutation
   survives there are two readings: the mutation was too weak, or the criterion cannot fail.
   Reaching for the first every time turns this audit into a rubber stamp. **Each survivor must be
   diagnosed explicitly**, and the count of *criteria found vacuous* reported separately from the
   count of *mutations found weak*. `/uat` checks that both numbers exist.

3. **Coverage is the finding that was not being looked for.** 018 recorded 11 mutations against 16
   criteria, measured while writing the brief. The report presented failability as established for
   the feature. Whatever the validity number turns out to be, **the coverage gap is already
   confirmed** and is not contingent on the audit's outcome.

4. **A vacuous criterion found here is a defect in a closed feature, not in this one.** The honest
   move is to fix it and record it against the feature that shipped it — the same way 015 recorded
   nine untraceable criteria against `check_95`, which had been green since 004.
