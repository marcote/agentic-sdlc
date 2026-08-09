---
name: wow-report
description: Aggregates the retro ledger in verification/wow-report.md — drift by pillar (mapping x signal verdict), pending re-checks, method health, and theater smells. On-demand observability, never gates. Use to answer "is the WoW working?".
---

# WoW Report

Input: all `specs/*/retro.md`, their `alignment.md`, and `verification/reports/*`.
Output: `verification/wow-report.md` (generated and committed snapshot). **Observes, never
gates** — the deterministic teeth are `tests/check_90_retro.sh`; this is synthesis for the
human.

## Procedure
Regenerate `verification/wow-report.md` with six sections:

1. **Mission — is each North Star pillar being served?** Cross the objective→pillar `mapping`
   from each `alignment.md` with the signal verdict from `retro.md`. Table per pillar:
   features that claimed to serve it x whether the signal moved. **A pillar with
   features that promised it but no signal moved = measurable drift** (highlight it).

2. **Pending re-checks (worklist).** Gather the `pending-observation` entries with their
   trigger; mark the overdue ones.

3. **Method — does the WoW add value?** (N=<n>, small sample, no statistics). Per-feature
   table: gaps caught, RED discipline, rework verify/uat, escalations. Group recurring
   friction themes.

4. **Loop — does the WoW improve itself?** Candidate rules proposed vs landed in
   constitution; amendments proposed vs approved (ADR).

5. **Theater smells (human spot-check, Layer 4).** Flag suspicious retros: empty
   Evidence cells, all-green (zero gaps + zero rework + zero friction),
   overdue `pending-observation`. A retro that is too clean IS a signal.

6. **Charter health — is pinning decisions earning its ceremony?** Two signals, read together
   (input: `memory/stack/stack.md` + each feature's `plan.md` and `retro.md`):
   - **Pins that tripped.** A `TRIPPED` verdict at `/plan` means the charter caught a decision
     going bad *before* the rework, which is the mechanism working. Record which pin, which
     criterion tripped it, and — crucially — **whether the `Hedge` was actually in place**, so
     a `PROVISIONAL` pin that never bought its escape is visible.
   - **Rework with no pin.** Rework that a charter *should* have prevented but did not,
     because no pin covered that decision. This is a **charter gap**: the elicitation missed a
     load-bearing choice, or the inclusion test was applied too narrowly.
   The reading is the ratio, not either number alone. Many trips and no gaps = the charter is
   doing its job. Gaps with no trips = ceremony without coverage, and the honest conclusion is
   that the charter is decorative. Also flag **pins that never trip and never constrain
   anything** — charter bloat, the mirror failure of a gap.

## Honesty of N=1
The report explicitly declares "N=<n>, small sample, no statistics". It does not fake
trends; it shows per-feature + totals + themes.
