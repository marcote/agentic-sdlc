# Alignment — 013-stack-charter

Measurability Gate (`/align`) over `brief.md` × `memory/north-star/north-star.md`.
**Run deterministically by the 006 engine** (`scripts/north-star/engine.py`): `schema-valid`
→ exit 0 (North Star valid, gate runs); `scope-reject` per objective → exit 1 for all five
(no `out_of_scope` hit); `align-verdict` → `aligned`.

## Verdict

**`aligned`** — all 3 dimensions ≥ threshold (3), no `out_of_scope` hit, no orphan.
`/distill` may proceed. The feature sits on the literal in_scope items "commands, gates, and
skills of the governance workflow" and "WoW self-validation (retro, wow-report)". Its
riskiest edge — a charter whose *content* is exactly runtime/tooling decisions, against the
`out_of_scope` predicate "imposing or naming a mandatory execution runtime" — is handled by
the shape of the design, not by wording: the harness ships the **mechanism** that forces an
adopter to declare their own decisions, and names no tool, language, runtime, or vendor in
`base/`. That distinction is what keeps the brief in scope, and it is load-bearing.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 5 | Every objective maps cleanly to a named `signal`, not just to a pillar `id`. O1/O3 land on `measurable-impact`, whose signal is *literally* "gaps caught early and late rework avoided" — the DuckDB and `println` cases are that signal's textbook instances. O2 lands on `real-enforcement` ("gates block closure when a condition is missing") as a fail-closed gate with exact in-repo precedent (`MEAS-GATE`). O5 lands on the clause of `measurable-impact` that names the `wow-report` Method section verbatim. No objective needed a loose or generous mapping to reach a pillar. |
| scope compliance | 4 | Held at 4, not 5, by O1 and O3. **O1** touches the edge of "imposing or naming a mandatory execution runtime": a charter's content *is* runtime and tooling decisions, and only the adopter-declares-their-own framing keeps it clear of the predicate. Real, but requires reading the design to see. **O3** touches "application code or product features of an adopting project": mandating that a `PROVISIONAL` pin buy an architectural hedge constrains adopter app code. Precedent pulls it back up — `base/patterns/idempotency.md` already ships an injected criterion that constrains adopter app code the same way — so the edge is established practice, not a new violation. Neither is a hit (`scope-reject` exit 1 on all five), but "touches the edge" is exactly the rubric's 3–4 band, and per the doubt rule the minimum is not rounded up to 5. |
| mission advancement | 4 | Held at 4 by O3 and O4. **O3**'s effect is measurable only at the moment a `Falsifier` trips and the guard reports whether the hedge was actually built — a real, auditable measurement, but a sparse one; it may not fire for several features. **O4** is partly *defensive*: it preserves `agnostic-portability` (mission: "without imposing a stack") rather than moving it forward, though it does extend the vendorable contract surface, which the pillar's signal does measure. O1/O2/O5 each score 5; the aggregate min is 4. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — Ensure every load-bearing technical decision is declared with its price before it becomes expensive to reverse, so no assumption stays mute | `measurable-impact`, `real-enforcement` |
| O2 — Stop a feature at the step that can still act on it when a new acceptance criterion invalidates a previously declared decision | `real-enforcement`, `measurable-impact` |
| O3 — Make declared uncertainty pay a verifiable architectural hedge, so being wrong stays cheap | `measurable-impact`, `real-enforcement` |
| O4 — Let an adopter's own technical opinions become enforceable without the harness prescribing any stack | `agnostic-portability` |
| O5 — Report charter health in the wow-report so the mechanism's ceremony is backed by evidence | `measurable-impact`, `real-enforcement` |

## Orphans

None. Every objective maps to ≥1 pillar.

## Gate note

`scope-reject` cleared all five objectives (exit 1) and `align-verdict` returned `aligned`
deterministically from `{pillarFit: 5, scopeCompliance: 4, missionAdvancement: 4}`.

Two things this gate flagged that the feature must carry forward:

1. **`frictionless-adoption` is not claimed, and the omission is deliberate.** This feature
   *adds* a workflow step (`/stack`) and a third `memory/` store, which moves that pillar's
   signal (steps/time to adopt) in the **wrong** direction. Claiming it would be theater.
   The mitigation is `S0`, which scales interview depth to blast radius, and the honest
   prediction for `/retro` is: `frictionless-adoption` takes a measurable hit, and the
   feature is only worth it if `measurable-impact` shows a compensating gain in rework
   avoided. **`/retro` must dictate a verdict on that trade, not just on the pillars this
   brief claims.**

2. **The scope-compliance edge is the thing to watch at `/uat`.** If the delivered charter
   ends up naming any specific tool, language, or vendor as a harness default anywhere in
   `base/`, the feature has crossed from "mechanism" to "imposition" and retroactively
   fails the predicate that scored 4 here. The brief already lists this under Out of scope;
   `/uat` should verify it against the shipped artifacts, not against the brief's promise.
