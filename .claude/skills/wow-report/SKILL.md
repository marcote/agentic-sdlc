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
Regenerate `verification/wow-report.md` with five sections:

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

## Honesty of N=1
The report explicitly declares "N=<n>, small sample, no statistics". It does not fake
trends; it shows per-feature + totals + themes.
