# Alignment — 007-vendoring

Measurability Gate (`/align`) over `brief.md` × `memory/north-star/north-star.md`.
**Run deterministically by the 006 engine** (`scripts/north-star/engine.py`): `schema-valid`
→ exit 0 (North Star valid, gate runs); `scope-reject` per objective → exit 1 for all six
(no `out_of_scope` hit); `align-verdict` → `aligned`. First feature whose `/align` executed
on the real engine rather than the LLM judge alone.

## Verdict

**`aligned`** — all 3 dimensions ≥ threshold (3), no `out_of_scope` hit, no orphan.
`/distill` may proceed. The cleanest scope so far: vendoring is the *literal* in_scope item
"adoption tooling: install, vendoring, and harness inheritance".

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 4 | Core objectives (copy-once vendoring, dry-run, non-destructive seed, stack detect, handoff) map cleanly to `frictionless-adoption` (its `signal` — steps/time to adopt — is *literally* this feature) and `agnostic-portability` (vendored onto an arbitrary repo/stack). Held at 4 (not 5) because provenance maps to `real-enforcement`'s auditable-trail only loosely. |
| scope compliance | 5 | Fully in-scope, no ambiguity — `scope-reject` returned exit 1 (no hit) for every objective. Vendoring is the named in_scope predicate. Stack detection *seeds a default* test command (non-mandatory, adopter overrides) → does **not** touch the `out_of_scope` "imposing or naming a mandatory execution runtime". No edge to resolve (unlike 006). |
| mission advancement | 3 | Min pulled down by the provenance objective, whose effect on a pillar `signal` is indirect (auditable-trail, not a measured signal). The core vendoring objectives advance the mission strongly — vendoring is *how* a "reusable, stack-agnostic harness" reaches "any project" — but the aggregate min is 3 (still ≥ threshold). |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| Copy-once vendoring: land the harness onto an existing repo (`docs/vendoring.md` + `scripts/vendor.sh`) | `frictionless-adoption`, `agnostic-portability` |
| Dry-run default prints the keep/seed/drop plan without writing | `frictionless-adoption` |
| Non-destructive seed: never overwrite; `.harness-new` alongside | `frictionless-adoption`, `agnostic-portability` |
| Stamp provenance (source repo + SHA + date) | `frictionless-adoption`, `real-enforcement` |
| Detect stack → default test command; unknown → documented TODO | `agnostic-portability`, `frictionless-adoption` |
| Hands off to the existing workflow (`/constitution` → first feature) | `frictionless-adoption` |
| Dependency-free (bash + python3) | `agnostic-portability` |

## Orphans

None. Every objective maps to ≥1 pillar.

## Gate note

No friction: `scope-reject` cleared all six objectives (exit 1) and `align-verdict` returned
`aligned` deterministically. This run also closes part of 006's pending `real-enforcement`
signal — the engine 006 shipped is now the thing running `/align`, in-repo, no longer a
"contract only, engine elsewhere". The re-check trigger from 006's retro (frictionless-adoption
+ agnostic-portability, measured when vendoring runs) is exercised by *this* feature's `/uat`.
