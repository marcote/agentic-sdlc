# Retro — 006-north-star-engine @ 1dadb51

closes: `specs/006-north-star-engine/alignment.md` · `verification/reports/006-north-star-engine-8bb07f0.md` · date: 2026-07-05

> Closes the measurable prediction that `/align` opened (align↔retro column). A feature is not
> DONE until this retro closes its three faces.

## Face A — Mission (closes the /align prediction)
Source: `alignment.md` mapping (real-enforcement, frictionless-adoption, agnostic-portability) + `north-star.md` signals.

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| real-enforcement | Gates block closure; harness dogfoods itself (retro ledger) | ✅ moved (dogfood sub-signal) / ⏳ not yet observable (gate-blocking) | RED→GREEN `7968674`→`8bb07f0`; this retro + `verification/reports/006-north-star-engine-8bb07f0.md`; gate-blocking unchanged by design → coverage row `GATE-REGRESSION` ✅ |
| frictionless-adoption | Steps/time to adopt the harness (lower = better) | ⏳ not yet observable | Precondition met: `scripts/north-star/engine.py` @ `8bb07f0` runs; steps-to-adopt measured in feature 007 |
| agnostic-portability | The contract stays intact when vendored onto an arbitrary stack | ⏳ not yet observable | `DEP-FREE` ✅ coverage row (engine imports only stdlib) preserves portability; vendored-intact test in feature 007 |

- **Align calibration:** pillarFit 4 held (the engine cleanly serves the mapped pillars); scopeCompliance 3 held — the batteries-included call was validated in UAT (the engine runs on the real `north-star.md`); missionAdvancement 4 was **slightly optimistic** — for 2 of 3 pillars the signal is only observable once feature 007 vendors the engine, so a 3 would have been better calibrated.
- **Mission verdict:** pending-observation
  - **re-check trigger:** feature 007 (vendoring) — measure frictionless-adoption (engine copied as KEEP with zero adopter wiring) and agnostic-portability (contract intact when vendored). real-enforcement's dogfood sub-signal is already ✅ moved (this retro + the verified RED→GREEN chain); its gate-blocking sub-signal is unchanged by design (`GATE-REGRESSION`, a refactor not a behavior change).

## Face B — Method (validates the WoW) — DERIVED from artifacts
- **Gaps caught by /distill:** 3 grilling ambiguities (boundary, scope-reject algorithm, CLI error contract) + 5 edge cases `[deriv: spec.md "Edge cases" + coverage rows SCHEMA-MALFORMED / SETS-ORDER-AGNOSTIC / SCOPE-NORMALIZE / VERDICT precedence / ADR-ABSENT; git ed5ce11]` — the notable one: malformed (exit 2) must never collapse into schema-invalid (exit 1).
- **RED→GREEN discipline:** yes, no exceptions `[deriv: coverage.md history 🔴 18 FAIL → 🟢 181 PASS; git 7968674 contract RED before 8bb07f0 impl GREEN]` — sentinel 127 added so an absent engine cannot fake a real exit-2.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/006-north-star-engine-8bb07f0.md section 5 — Gaps routed none]` — no BUILD/TRAJECTORY gap, no product gap.
- **Escalations to the human:** 0 inner-loop `[deriv: git — single impl commit 8bb07f0 turned all green, no retry/fix commits]` — the `/align` scope-intent confirmation was a governance checkpoint, not an inner-loop escalation.
- **Friction from the WoW itself:** (1) the pipeline tracklist had to be **inferred by hand** (TaskCreate) instead of the harness deriving it from artifact state — flagged by the maintainer, parked as feature 008. (2) Bootstrap irony: `/align` had **no executable engine** to run against (006 *is* that engine), so the Measurability Gate ran via the LLM judge manually, not deterministically — 006 is exactly what closes that gap for future features.

## Face C — Loop (self-improvement)
- **Candidate rules → constitution:** (1) *Phase state is derived, not inferred* — the workflow phase tracker must be computed from the presence/state of a feature's artifacts + `coverage.md`, never hand-maintained as a parallel list (feature 008). (2) *Must-not-regress guards* — a criterion asserting an existing green behavior stays green through a change (e.g. `GATE-REGRESSION`) is annotated as a guard and excluded from the `/contract` RED-required set, like `UAT (config)` rows. Apply via `memory/constitution/update-checklist.md`.
- **Candidate amendments → North Star:** optional — clarify the `out_of_scope` predicate "stack-specific deterministic engine (provided by the adopter)" to codify the batteries-included reading (the harness MAY ship a dependency-free reference engine in its own baseline), so 007 does not re-litigate the scope edge. Apply via `memory/north-star/base/amendment-protocol.md` only if the edge recurs.
