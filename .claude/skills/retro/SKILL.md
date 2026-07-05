---
name: retro
description: Closes the /align prediction when a feature closes — dictates the verdict on the pillar signal and derives WoW signals from artifacts. Writes specs/<feature>/retro.md. Use after a green /verify+/uat, as the final closing step.
---

# Retro

Input: `specs/<feature>/alignment.md` + `coverage.md` + `verification/reports/<feature>` + git.
Output: `specs/<feature>/retro.md` (template at `specs/_template/retro.md`). This is the
**back half of the Measurability Gate**: `/align` opened a measurable prediction; the
retro closes it. The feature is not DONE until this retro closes its three faces.

## Anti-theater (why order matters)
A check cannot prove honesty. The procedure shrinks the place where filler-to-comply
hides: **derive → self-challenge → write**, never the other way.

## Procedure

1. **Derive first (Face B, Layer 1).** Do not type numbers from memory. Each
   Method field comes from an artifact with its `[deriv: <locator>]`:
   - Gaps caught by /distill → rows of `coverage.md` + `git log` of the distill phase.
   - RED→GREEN discipline → `coverage.md` state history (🔴 before 🟢) + git.
   - Rework post-/verify and post-/uat → gaps routed in `verification/reports/<feature>`.
   - Escalations → trace / git.
   Only "Friction from the WoW itself" is free judgment; everything else is derived.

2. **Dictate Face A with a mandatory evidence locator (Layer 2).** Read `alignment.md`:
   for each pillar in the `mapping`, find its `signal` in `north-star.md` and dictate a verdict
   (`✅ moved` / `❌ did not move` / `⏳ not yet observable`) with an Evidence cell that is
   a **locator** (value, SHA, coverage row, URL) — not prose. Without a locator for a
   `confirmed`/`refuted`, the honest verdict is `pending-observation` with its re-check trigger.
   Note the **align calibration** (did the pillarFit/scope/mission scores hold up in retrospect?).
   If the repo's North Star is a placeholder (not schema-valid), Face A is
   `n/a` with reason — there is no real signal to close.

3. **adversarial self-challenge (Layer 3).** Before writing, argue AGAINST your
   own draft: "the report shows 0 rework — verify against `git log`; it says the
   pillar-fit of align was exact — argue the opposite". Only what survives the challenge
   is written. (Future reinforcement, not now: delegate the challenge to a separate skeptic
   subagent from the one that drafted.)

4. **Face C (loop).** Propose candidate rules → constitution and/or amendments → North
   Star. Only propose; applying them follows `update-checklist.md` / `amendment-protocol.md`.

5. **Mission verdict.** `confirmed` | `refuted` | `pending-observation` (+trigger) |
   `n/a` (+reason required). Write `specs/<feature>/retro.md` from the template.

## Gate
`tests/check_90_retro.sh` requires, for every feature with a DONE report: retro present, no
placeholders, valid mission verdict, non-empty evidence for `confirmed`/`refuted`,
`[deriv:]` on every Face B field, and reason for `n/a`. The feature is not DONE without
`retro ✅`.
