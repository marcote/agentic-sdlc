# Alignment — 006-north-star-engine

Measurability Gate (`/align`) over `brief.md` × `memory/north-star/north-star.md`.
North Star schema-valid (4 pillars, `alignment.threshold`=3) → gate runs.

## Verdict

**`aligned`** — all 3 dimensions ≥ threshold (3), no `out_of_scope` hard hit, no orphan.
`/distill` may proceed. **Note:** `scope compliance` sits *on the pass floor* (3) — the
weakest dimension and the one worth a human confirmation (see Gate note).

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 4 | Maps cleanly to `real-enforcement` (deterministic gates need a *runnable* engine; its `signal` — "gates block closure; violations caught before merge" — depends on one) and to `frictionless-adoption` (an in-repo, runnable reference lowers adoption cost vs. building the engine from scratch). Preferred 4 over 5: the dependency-free objective touches `agnostic-portability` only indirectly. |
| scope compliance | 3 | In-scope but **on the edge** of the `out_of_scope` predicate "stack-specific deterministic engine (provided by the adopter — contract in the template, engine per-stack)" — which literally names *deterministic engine*. Resolved in-scope by four converging facts: (1) precedent — 004 scored this same edge in-scope; (2) `amendment-gate.sh` **already ships a python3 slice** of this very engine (schema parse + `requiresAdr`), blessed under 004, so *completing* it cannot be out-of-scope when *starting* it was in; (3) `in_scope` explicitly lists "adoption tooling: install, vendoring, and harness inheritance"; (4) it is dependency-free (`python3` stdlib, the harness's own baseline) and does **not** impose a stack — poirot-fe's Node `.mjs` remains a valid alternative. Preferred 3 over 4 (004's score) because 006 builds *the engine itself*, nearer the named noun than 004's *gate*. |
| mission advancement | 4 | Measurable effect on named signals: converts `/align` and the amendment gate from "contract only, engine elsewhere" to a runnable in-repo engine (`real-enforcement`), and gives adopters a runnable reference (`frictionless-adoption`). Directly observable (the engine runs or it does not). |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| In-repo `python3` reference engine (`schema` validation, `scopeReject`, `alignVerdict`, `requiresAdr`/`hasAdrFor`) | `real-enforcement`, `frictionless-adoption` |
| `amendment-gate.sh` reuses the engine (no duplicated JSON parsing) | `real-enforcement` |
| Dependency-free (`python3` stdlib only, no Node/npm in the source path) | `agnostic-portability` |

## Orphans

None. All objectives map to ≥1 pillar.

## Gate note

The single friction point is `scope compliance`, and it is genuine: the `out_of_scope`
set names "stack-specific deterministic engine (provided by the adopter)", and this
feature builds a North Star engine *inside the harness*. The conservative deterministic
predicate (`scopeReject`, contiguous-phrase match) does **not** hit — the objective says
"deterministic executable engine", not the literal `out_of_scope` phrase, and 006's engine
is explicitly *not* stack-specific (dependency-free `python3`, Node alternative preserved).
So there is no hard `rejected`; the edge is the judge's call under `scope compliance`.

The distinction that resolves it in-scope: **the harness is its own adopter.** "Engine
per-stack, provided by the adopter" forbids the harness from *imposing one stack's engine
on every adopter*; it does not forbid the harness — as one adopting repo among others —
from providing *its own* engine in *its own* baseline stack (`python3`), exactly as 004 built
the harness's own amendment gate in bash. poirot-fe's Node engine stays the reference for
Node adopters; this becomes the reference for the harness and `python3` adopters.

**Human confirmation point (does not block the gate):** if the maintainer's *intent* is
stricter — "the harness must remain pure contract and never host a North Star engine,
even a dependency-free reference" — then this feature would need a North Star **scope
amendment** (ADR in `memory/north-star/decisions/` + PR, per `base/amendment-protocol.md`)
to move an in-repo reference engine from `out_of_scope` into `in_scope` before `/distill`.
The gate reads the current North Star as permitting it (score 3), but flags the intent
question for the maintainer to veto.

**Maintainer confirmation (2026-07-05): in-scope, no amendment.** Rationale: a good
vendoring is *batteries-included* — it delivers something that **runs**, not a contract
the adopter still has to wire. That is **productivity**, the overarching objective of this
SDLC. Shipping a dependency-free reference engine in the harness's own baseline (`python3`)
serves that objective without imposing a stack (Node alternative preserved). Verdict stands:
`aligned`; `/distill` may proceed.
