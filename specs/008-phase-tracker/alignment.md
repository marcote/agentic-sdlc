# Alignment — 008-phase-tracker

Measurability Gate (`/align`) over `brief.md` × `memory/north-star/north-star.md`, run
deterministically by the 006 engine: `schema-valid` → exit 0; `scope-reject` → exit 1 for
both objectives (no `out_of_scope` hit); `align-verdict` → `aligned`.

## Verdict

**`aligned`** — all 3 dimensions ≥ threshold (3), no `out_of_scope` hit, no orphan.
`/distill` may proceed. The floor (pillarFit 3, missionAdvancement 3) comes from the
secondary tooling objective (the shared DEPFREE helper), not the core phase-tracker.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 3 | The phase-tracker maps cleanly to `real-enforcement` (workflow state becomes authoritative/mechanical instead of inferred) and `frictionless-adoption` (see where you are + next command). The secondary DEPFREE-helper objective maps to `real-enforcement` only **loosely** (test-tooling hygiene), pulling the min to 3. |
| scope compliance | 5 | Fully in-scope — `scope-reject` cleared both objectives. The tracker is "commands, gates, and skills of the governance workflow" + "adoption tooling"; the helper is "evals, verification, and UAT of the method". No edge. |
| mission advancement | 3 | The tracker has a measurable effect (it removes hand-inference from the workflow — observable in its output). The helper's mission effect is indirect (tooling hygiene), so the min is 3. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| Derived phase-tracker `scripts/status.sh` (phases done / current / next / gaps) | `real-enforcement`, `frictionless-adoption` |
| Shared invocation-aware DEPFREE helper in `tests/lib.sh` (candidate B) | `real-enforcement` |

## Orphans

None. Both objectives map to ≥1 pillar.

## Gate note

Clean run on the engine, no friction. The floor scores flag the secondary objective (the
DEPFREE helper) as the weakest link — it is tooling folded in from 007's retro (candidate B),
not the core value. If `/distill` finds it dilutes the feature, it can be split out; kept here
because the tracker's own `check_NN` needs the helper anyway.
