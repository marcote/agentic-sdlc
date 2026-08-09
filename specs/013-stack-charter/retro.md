# Retro — 013-stack-charter @ 50429cd

closes: `specs/013-stack-charter/alignment.md` · `verification/reports/013-stack-charter-8d94208.md` · date: 2026-08-08

> Closes the measurable prediction that `/align` opened (align↔retro column). A feature is not
> DONE until this retro closes its three faces. Design:
> `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.

## Face A — Mission (closes the /align prediction)
Source: `specs/013-stack-charter/alignment.md` (objective→pillar mapping) + `north-star.md` (signal per pillar).

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| `real-enforcement` | Gates block closure when a condition is missing; violations caught before merge; the harness proves it by dogfooding itself | ✅ moved | Three independent firings, two on real defects: `check_90` blocked this very close (`tests/run.sh` 320/1, "feature 013 DONE but retro.md is missing"); the `/plan` guard returned `UNPINNED` on 013's own plan and minted `S4` (`specs/013-stack-charter/plan.md` §Retroactive run + `memory/stack/stack.md` S4); UAT routed `EMPTY-CHARTER` through a proved RED (315/4 → 320/0, `50429cd`) |
| `measurable-impact` | Gaps caught early (grilling/contract) and late rework avoided, aggregated per feature | ⏳ not yet observable | 8 gaps caught pre-implementation and 1 late (`specs/013-stack-charter/spec.md` Edge cases; report §4) — but that is **the workflow's** credit, not the charter's. The charter has prevented 0 stack-decision rework because no feature has yet run through it. See re-check trigger |
| `agnostic-portability` | The contract remains intact when vendored onto an arbitrary repo/stack | ✅ moved | `VENDOR-STACK` + `EMPTY-CHARTER` both ✅ uat (`coverage.md`); mechanism lands, harness pins do **not** travel, `NO-PRESCRIBE` green on shipped artifacts. Weaker than 012's evidence: the target was synthetic (`2602a36` vendored onto a real repo) |
| `frictionless-adoption` | Steps/time to adopt the harness in a project (lower = better) | ❌ did not move — moved the **wrong** way | +1 mandatory workflow step (`docs/workflow.md` loop line), +1 `memory/` store, +2 documents an adopter must read (`memory/stack/base/`). Not claimed in `alignment.md`, and the prediction there said exactly this |

- **Align calibration:** `pillarFit 5` held — every objective reached a named signal without a
  loose mapping. `scopeCompliance 4` was **exactly right**: the edge it flagged (a charter's
  content *is* runtime and tooling decisions) was the real risk, `NO-PRESCRIBE` was built
  specifically for it, and it stayed clean. `missionAdvancement 4` was **optimistic by about a
  point** — it should have been 3. The reasoning recorded at `/align` ("O3's effect is
  measurable only when a `Falsifier` trips… a sparse measurement") was correct, and I did not
  follow it down to the score. The rubric's own instruction — *when in doubt prefer the lower*
  — existed precisely for this and I did not apply it.
- **Mission verdict:** pending-observation
  - **re-check trigger:** the first feature (014+) whose `/plan` gate emits a real `UNPINNED` or
    `TRIPPED` verdict against a pin that existed *before* that feature started, or whose
    `/stack` run produces a real coherence objection. That is the first moment the charter can
    be observed preventing rework rather than merely recording decisions. The same trigger
    closes the three `📋` eval rows (`JUDGE-TRIPPED`, `JUDGE-COHERENCE`, `JUDGE-HEDGE-COST`),
    deliberately left open because scoring them here would be the authoring model grading
    itself.

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted

- **Gaps caught by /distill:** 8 `[deriv: specs/013-stack-charter/spec.md section "Edge cases" = 9 bullets, minus EMPTY-CHARTER which was found at /uat not /distill; + 3 grilling ambiguities in 086216d]` **(corrected: first written as 12 — the derivation grepped bullets across the whole file instead of the section, and the `[deriv:]` locator made the wrong number look verified. Recorded rather than silently fixed: this is the Face B anti-theater mechanism failing in the exact way theater works.)** — the notable one is an **ordering hole in the already-approved design**: a `[stance]` pin minted by `/plan`'s `UNPINNED` had to inject `[given]` rows into a `coverage.md` that `/distill` had already frozen. The design document did not close that; grilling found it before a line of code, and it became criterion `PLAN-BOUNCE`.
- **RED→GREEN discipline:** yes, with one documented exception `[deriv: coverage.md state history + 3a2bb50 → 05bc134 → 8d94208; suite 244/0 → 251/53 → 278/35 → 313/0, then 315/4 → 320/0 for EMPTY-CHARTER]` — 7 assertions passed at RED **by design** (self-tests of the test infrastructure, not of the deliverable), documented in `coverage.md`; every assertion touching a 013 artifact was red. The `EMPTY-CHARTER` cycle carried its own control (an unreadable charter must still exit 2), without which the empty/malformed distinction would have been unfalsifiable.
- **Rework post-/verify:** 0 · **post-/uat:** 2 `[deriv: verification/reports/013-stack-charter-8d94208.md §4-5 + coverage.md post-UAT sections + git log c9c4baf..HEAD]` — `EMPTY-CHARTER` (adopter day-one state uncovered) and `SUBSTRATE-GUARD` (a declared `Guard` accepted then silently never executed). Both were **missing criteria, not failing ones**, and both went back through `/distill` rather than being patched in place. The second was surfaced by the maintainer asking a plain question — *where would enforcing a dependency tool live?* — which the artifacts could not answer, and that is the more uncomfortable finding: the design error had survived `/distill`, `/plan`, `/contract`, `/verify` and `/uat` untouched.
- **Escalations to the human:** 9 `[deriv: trace — 5 design forks pre-brief, 3 /distill grilling questions, 1 UAT routing decision]` — all were genuine decision forks, none was a stuck-loop escalation; the inner-loop budget (2 identical failures / 3 attempts) was never reached.
- **Friction from the WoW itself:** Two things, one of them structural.
  **(1) A feature that adds a gate cannot be gated by it.** 013 needed a bootstrap exception for `/plan`, exactly as 002 needed one for `/align`. That is now a recurring situation with no rule: each time it is negotiated ad hoc. 013 discharged it with two pre-close obligations (seed the charter; run the finished guard retroactively) and that worked — the retroactive run returned a real `UNPINNED`, not a courtesy `PASS` — but the *pattern* deserves to be written down rather than reinvented.
  **(2) Nothing protects a check from being vacuous.** Five defects of one family appeared in this feature alone: a self-scanning check that matched its own grep line; two assertions that passed because the searched word already existed elsewhere; an unanchored pattern (`rails` matching "guardrails"); and a fifth caught while fixing the fourth — an assertion pointing at a fixture from another block, so it silently checked a missing file and recorded neither PASS nor FAIL. `check_90` was bitten by the same family in `e6bc658`. Every one was caught by hand. The worst — a `Guard` that validated and never ran — was caught only because a human asked a question the artifacts could not answer. The harness has extensive machinery to ensure tests exist and go red. It has none to ensure an assertion can fail. Also minor: the `/tasks` gate had to be walked with hand-written `awk`, since `status.sh` reports phases but does not execute it.

## Face C — Loop (self-improvement)

- **Candidate rules → constitution:** two, both promoted from repeated real mistakes rather than from theory (per `memory/constitution/update-checklist.md`):
  1. **`base/patterns/non-vacuous-checks.md`** — an assertion must be proved capable of failing, and a declared check must be proved to actually *run*. Injected criteria: every check ships a *negative fixture* on which it exits non-zero; any check that scans its own source assembles the forbidden literal at runtime so it cannot match itself; and any newly declared check is confirmed present in what the runner actually executes. Evidence for the rule: 5 occurrences in 013 plus `e6bc658`. This is the strongest candidate the feature produced and arguably outlives the feature itself.
  2. **A project delta (D4) for the gate-bootstrap exception** — when a feature introduces a gate, that gate cannot gate it; the exemption is legitimate only when discharged by explicit pre-close obligations, and a trivial pass against one's own artifacts is recorded as *proved nothing*, not as success. Evidence: 002 and 013.
**Landed 2026-08-09** — both candidates are now in the constitution: `memory/constitution/base/patterns/non-vacuous-checks.md` (five injected `[given]` criteria, each with the occurrences it prevents) and project delta **`D4`** (gate bootstrap, four conditions). Asserted by `tests/check_10_constitution.sh` and proved failable against four isolated fixtures. They landed only after `verification/wow-report.md` §4 counted *proposed twice, landed zero*.

- **Candidate amendments → North Star:** none. One tension is now *watched* rather than amended: the North Star places the per-stack deterministic engine out of scope while the harness hosts two reference engines. 013 recorded this as pin `S2` (`PROVISIONAL`) whose `Falsifier` is precisely "the reference engines start being read as a requirement". If that trips, the amendment conversation is the correct next step — but predicting it now would be inventing evidence.

---

## Deferral hygiene (added 2026-08-09)

**Sweep by: 2026-09-08** — a date, not only an event, whichever comes first. On that date the
verdict is either closed with evidence or re-deferred with a *new* date and a stated reason.

Added because feature 006 sat `pending-observation` for **35 days after its evidence already
existed**: its trigger fired when 007 merged on 2026-07-05 and nobody swept the ledger.
`wow-report` §2 exists to list overdue re-checks and had never been run across eight features.
A deferral mechanism nobody sweeps loses findings while the ledger still reads as rigorous —
which is a worse failure than an open item, because it is invisible.
