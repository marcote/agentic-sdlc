# Retro — 008-phase-tracker @ c86ab12

closes: `specs/008-phase-tracker/alignment.md` · `verification/reports/008-phase-tracker-598f615.md` · date: 2026-07-05

> Closes the measurable prediction that `/align` opened. This feature *is* the fix for the
> WoW friction flagged in the 006 and 007 retros (the tracklist was inferred by hand).

## Face A — Mission (closes the /align prediction)
Source: `alignment.md` mapping (real-enforcement, frictionless-adoption) + `north-star.md` signals.

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| real-enforcement | Gates block; violations caught before merge; harness dogfoods itself | ✅ moved (detection) — see caveat | UAT report §4: `status.sh 001-example` flagged a real `⚠ anomaly` (predates `/align`) + exit 1; coverage row `ANOMALY-FLAG` ✅ uat; RED→GREEN `91484cf`→`598f615` |
| frictionless-adoption | Steps/time to adopt the harness (lower = better) | ✅ moved | UAT report §4: correct `current:`/`next:` on 006/007/008 (`status.sh` self-navigates); coverage row `CURRENT-NEXT` ✅ uat |

- **Align calibration:** pillarFit 3 was fair (the secondary DEPFREE-helper objective is loose tooling); scope 5 held; missionAdvancement 3 was slightly conservative — the tracker demonstrably works and caught real bugs, so a 4 was defensible, but the helper's indirect effect justified the floor.
- **Mission verdict:** confirmed
  - Both mapped pillars moved with locators. **Caveat (survived self-challenge):** `status.sh` is **read-only** — it moved the *detectability* of skips (a gate-able non-zero exit, demonstrated on 001-example), not the *blocking* itself. Turning detection into a hard block (CI wiring or a `/next` wrapper) is deferred (spec Open questions).

## Face B — Method (validates the WoW) — DERIVED from artifacts
- **Gaps caught by /distill:** 3 grilling ambiguities (done-signal source, anomaly detection, exit-code semantics) + 5 edge cases (fresh scaffold, red coverage, out-of-order, missing report, unknown feature) `[deriv: spec.md "Edge cases" + coverage rows; git 74ef185]` — the notable one: presence alone is not "done" (the `cp -r _template` scaffold makes everything present).
- **RED→GREEN discipline:** yes `[deriv: coverage.md history 🔴 13 FAIL → 🟢 216 PASS; git 91484cf contract RED before 598f615 impl GREEN]` — two placeholder false positives were found *during* impl and fixed inside the same step (not fake-green).
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/008-phase-tracker-598f615.md section 5 — Gaps routed none]`.
- **Escalations to the human:** 0 inner-loop `[deriv: git — impl converged in a few iterations; the 2 placeholder fixes were <3 attempts, no human escalation]`.
- **Friction from the WoW itself:** the plan's D3 (reuse `check_90`'s placeholder regex) was **wrong** for docs that use angle-bracket argument notation or that *document* the italic-paren placeholder marker — and it was **caught by dogfooding `status.sh` on its own in-flight feature** (the tracker found its own bug). Reflexive validation: a workflow tool run against the workflow's own artifacts surfaces its blind spots. Note: `check_90` (the retro gate) has the **same** blind spot — this very retro tripped it until reworded — so the fix belongs there too (Face C). This is also the third retro to flag the hand-inferred tracklist — now **resolved** (008 is that fix).

## Face C — Loop (self-improvement)
- **Candidate rules → constitution:** *Reflexive dogfood* — a feature that produces workflow tooling (a checker/tracker over the SDLC's own artifacts) should be run against **its own in-flight feature** before closing; 008 caught two real bugs that way. Apply via `memory/constitution/update-checklist.md`.
- **Candidate tooling fix:** `check_90`'s placeholder detection shares `status.sh`'s (now-fixed) blind spot — it flags a code-span that merely *documents* the marker. Factor the code-span-stripping placeholder check into a shared `tests/lib.sh` helper used by both (small follow-up; not blocking 008).
- **Candidate amendments → North Star:** none.
- **Secondary (deferred, feature not rule):** a `/next` command wrapping `status.sh`.
