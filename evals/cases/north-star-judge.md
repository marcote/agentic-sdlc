# Eval case — north-star-judge

> Non-deterministic criterion: **JUDGE-ALIGNMENT**
> (`specs/002-north-star-governance/acceptance.md`). Scored manually (or by
> an LLM judge) against `memory/north-star/base/alignment-rubric.md`, per
> `evals/README.md`. State: 📋 case.
>
> This repo is the harness template: `memory/north-star/north-star.md` is a
> **placeholder** without real pillars. The pillars used below (`pillar-a`,
> `pillar-b`) are **illustrative** — an adopting repo runs these same two
> cases against its own North Star, with its own real pillars (see
> `poirot-fe evals/cases/north-star-judge.md` for an example with concrete
> project content).

## What is being judged

The semantic judgment of the `/align` skill: given the objectives of a brief and the
project's North Star, the judge (a) proposes an objective→pillar mapping and (b)
scores 3 rubric dimensions (0–5 each, pass threshold 3 — see
`alignment-rubric.md`). This eval checks that the score is *sensible*, not just
that the deterministic aggregation runs — that part is a documented contract,
per-stack (criterion `ALIGN-VERDICT-CONTRACT`), not unit-tested in this repo.

## Case 1 — in-scope brief scores well on all 3 dimensions

**Brief objective (input, illustrative):**
> "Add a read-only filter that lets users see which elements advance a
> signal of pillar `pillar-a`, without modifying any existing data."

**Expected judge behavior:**
- Maps cleanly to `pillar-a` (no orphan).
- No `out_of_scope` predicate fires (it is read-only/visualization).
- All 3 dimensions score **≥ 3**:
  - pillar fit — maps to an explicit `signal` of the pillar.
  - scope compliance — clearly within `scope.in_scope`.
  - mission advancement — the objective has an observable effect on the
    named `signal`.
- Resulting verdict (per-stack aggregation): `aligned`.

## Case 2 — plausible-but-out-of-scope brief scores low on scope compliance

**Brief objective (input, illustrative):**
> "Add a button that lets users directly modify the project's
> `north-star.md` (its pillars or scope) from the UI, bypassing PR
> review."

**Expected judge behavior:**
- Superficially plausible (mentions the North Star, a real pillar) — this is
  the trap: a superficial judge might score it high on relevance alone.
- On inspection, it requires **mutating scope/pillars without ADR or PR**, which
  is explicitly `out_of_scope` (violates `amendment-protocol.md`: every scope/pillars
  change is ADR + PR, never a direct/silent write).
- The **scope compliance** dimension must score **< 3** even if the other two
  dimensions (pillar fit, mission advancement) score reasonably — a judge that
  averages and dilutes the scope violation is a FAIL for this case.
- Resulting verdict: `rejected`, regardless of the other two scores (the
  scope rejection cuts the aggregation — see `plan.md` decision 3).

## Scoring

Record, per case, the 3 dimension scores assigned by the judge and whether the
derived verdict matches the "Expected judge behavior" above. Pass threshold for this
eval case: both cases must match their expected verdict (`aligned` / `rejected`) and
Case 2 must specifically show scope compliance `< 3` (not just a low average). Record
the result in `verification/reports/` for the feature, per `evals/README.md`.
