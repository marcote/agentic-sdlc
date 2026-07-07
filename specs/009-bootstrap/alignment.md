# Alignment — 009-bootstrap

Measurability Gate (`/align`) over `brief.md` × `memory/north-star/north-star.md`.
**Run deterministically by the 006 engine** (`scripts/north-star/engine.py`): `schema-valid`
→ exit 0 (North Star valid, gate runs); `scope-reject` per objective → exit 1 for all three
(no `out_of_scope` hit); `align-verdict` → `aligned`.

## Verdict

**`aligned`** — all 3 dimensions ≥ threshold (3), no `out_of_scope` hit, no orphan.
`/distill` may proceed. This feature sits on the *literal* in_scope item "adoption tooling:
install, vendoring, and harness inheritance" — it closes the from-zero front door that 007
left as folklore.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 4 | The core objective (one-command bootstrap: fetch → plan → confirm → apply → cleanup) maps cleanly to `frictionless-adoption` — its `signal` is *literally* steps/time to adopt, and this collapses the from-zero step from "clone + find + run" to one gesture. The safety objective (plan-first / `/dev/tty` confirm / no-TTY abort) maps to `real-enforcement` more loosely (a confirm prompt is enforcement-flavored but not a deterministic closure gate) → held at 4, not 5. |
| scope compliance | 5 | Fully in-scope, no ambiguity — `scope-reject` returned exit 1 (no hit) for every objective. Bootstrap is adoption tooling, the named in_scope predicate. The dependency-free objective *avoids* the `out_of_scope` "runtime dependencies or frameworks" (git + bash only) rather than touching it; the engine stays untouched, so no edge to the "stack-specific engine (adopter-provided)" predicate. |
| mission advancement | 3 | Min pulled down by the dependency-free / reuse-`vendor.sh` objective, whose effect is largely preventive (keep the baseline portable, don't reimplement the motor) — plausible effect on `agnostic-portability` but hard to measure. The bootstrap objective itself advances the mission strongly (fewer steps to reach `/constitution`); aggregate min is 3 (still ≥ threshold). |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| One-command bootstrap: fetch harness → show plan → confirm → apply → cleanup, from zero | `frictionless-adoption` |
| Preserve dry-run-first safety: plan first, confirm via `/dev/tty`, abort on no TTY, never apply blind | `real-enforcement`, `frictionless-adoption` |
| Dependency-free wrapper (git + bash) that reuses `vendor.sh` unchanged; `bootstrap.sh` added to vendor DROP | `agnostic-portability` |

## Orphans

None. Every objective maps to ≥1 pillar.

## Gate note

No friction: `scope-reject` cleared all three objectives (exit 1) and `align-verdict` returned
`aligned` deterministically. This feature depends on 007 — it wraps `vendor.sh`'s existing
dry-run/`--apply` separation rather than touching the motor — so the `frictionless-adoption`
signal it moves is measured at `/uat` as the delta from "clone the harness by hand, then find
and run its script" to a single `curl … | bash`. The `real-enforcement` mapping (no-TTY abort,
plan-before-write) is the auditable proxy that the one-gesture convenience did **not** cost
007's plan-first safety.
