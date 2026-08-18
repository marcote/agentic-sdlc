# Retro — 022-mutation-coverage @ 5193356

closes: `specs/022-mutation-coverage/alignment.md` ·
`verification/reports/022-mutation-coverage-5193356.md` · date: 2026-08-16

## Face A — Mission (closes the /align prediction)

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| `real-enforcement` | gates block closure when a condition is missing | ✅ moved | `COV-GAP-NAMED` exits 1 naming `FIXTURE-BARE`; the `/verify` skill step 5 makes it a closure condition |
| `measurable-impact` | gaps caught early and late rework avoided | ✅ moved | 137 undeclared criteria across 12 closed features, re-derivable: `mutate.sh coverage --all` |
| `agnostic-portability` | the contract holds when vendored onto an arbitrary repo | ✅ moved | `COV-NO-GIT` — identical verdict in a tree with no `.git` and no remote |
| `frictionless-adoption` | steps to adopt, every mandatory step carrying a recorded justification | ⏳ not yet observable | a step was **added**; its justification is `B15`'s measurement, its cost 0.08s per feature — but whether it is worth its ceremony needs a feature that runs under it |

- **Align calibration:** the three scores held. **`missionAdvancement: 4` was the right call and I
  want it on the record as the reason this retro is not warmer.** The gate's verdict on its own
  feature is 13 obliged, 0 undeclared — a number I produced by writing thirteen declarations and
  then checking that I had written them. A 5 would have been claiming enforcement from a tautology.
  `pillarFit: 5` also held: `real-enforcement`'s statement needed no interpretation to cover this.
- **Mission verdict:** pending-observation
  - **re-check trigger:** the first feature to close *under* this gate rather than shipping it.
    Did `coverage --spec` name a criterion whose author had not thought to declare one? If it
    reports 0 undeclared on the first try for three consecutive features, the honest reading is that
    the obligation is confirming diligence rather than creating it, and `frictionless-adoption` says
    to charge that step for its ceremony.
    · **sweep by:** 2026-09-16

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted

- **Gaps caught by /distill:** 7 `[deriv: specs/022-mutation-coverage/spec.md § "Edge cases
  (/distill expansion — 7)"]` — the load-bearing one is edge 2, the typo path. `/distill` was where
  the predicate was run against the real matrices three times and returned 157, then 47, then 137;
  the 47 is what exposed that a cleaner number can be the wrong one.
- **RED→GREEN discipline:** yes, with one exception `[deriv: verification/reports/022-mutation-coverage-5193356.md § 3]` — `/contract` was 13 FAIL,
  **1 PASS**. `COV-DEPFREE` was green by construction: it asserts `scripts/mutate.sh` invokes no
  toolchain, and the file already existed and already did not. 020 remains the only feature here
  with a total RED.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/022-mutation-coverage-5193356.md — "Gaps routed: none"]`
- **Escalations to the human:** 0 `[deriv: git log main..HEAD, one commit, one unattended run]`
- **Friction from the WoW itself:** the sandbox lesson from 020 repeated **exactly** — fourteen
  declarations all reported `emitted no result` because the new check file and its fixtures were
  untracked, so `git ls-files` never handed them to the sandbox. 020's report documents this defect
  in detail and I walked into it anyway, two features later, on the first run. The runner's
  diagnostic was correct and specific; reading a report is not the same as having the failure in
  hand. **A `git add` before the first mutation run belongs in `/contract`, not in a report nobody
  re-reads at the moment it matters.**

## Face C — Loop (self-improvement)

- **Candidate rules → constitution:** **landed in this feature.**
  `base/patterns/non-vacuous-checks.md` gains *"Who must declare — the obligation, not the
  capability"*, with the `[given]` row that makes a criterion's declaration a coverage obligation
  rather than an author's option. It carries the three conditions, the reason the trigger is
  *absence of a declaration* rather than *a suspect shape*, and the measured argument against
  deriving it from a branch ref.
- **Second candidate, NOT landed:** *"before the first mutation run, ensure the check file and its
  fixtures are tracked."* Deliberately parked. This repository has measured three times that a
  procedural rule stated as prose does not land — 020 documented this exact failure and it recurred
  here regardless. It goes to `docs/backlog.md` as `B17`, where an unimplemented rule is honest
  instead of decorative, and it waits for a mechanical form: `mutate.sh run` could name an untracked
  file under `--tests` and exit 2, which is the same *"silence is not an outcome"* move the runner
  already makes twice.
- **Third finding, out of scope and filed rather than chased:** the suite is green in ~22s of check
  work and **2923s** of wall clock, reproducibly on `main` as well. Filed as `B18`, which also
  supersedes `B7` — that entry recorded the nested run as a *doubling*, and it is not a doubling.
  Chasing it here is the chaining `docs/backlog.md` exists to prevent, and I stopped at evidence
  plus a hypothesis rather than shipping a diagnosis I had not confirmed.
- **Candidate amendments → North Star:** none. No `pillars`/`scope` change; `amendment-gate.sh
  --range main...HEAD` reports not applicable.
