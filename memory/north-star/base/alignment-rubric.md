# Alignment Rubric (base)

> "A North Star without a rubric measures nothing." Three dimensions, each scored
> 0–5. Used by the judge (LLM) of the `/align` skill to score the objectives of a
> brief against the project's North Star (`north-star.md`), and by the
> `JUDGE-ALIGNMENT` eval (`evals/cases/north-star-judge.md`) to check that the judge
> scores sensibly.

## Dimensions

| Dimension | What it measures | 0 | 3 (pass floor) | 5 |
|---|---|---|---|---|
| **Pillar fit** | Does the objective map to the `statement`/`signal` of an explicit pillar? | maps to no pillar (orphan) | maps to a pillar, fit is plausible but loose | maps cleanly to one or more pillars; advances a named `signal` |
| **Scope compliance** | Does the objective avoid every `scope.out_of_scope` predicate — including non-obvious ones that a surface reading would miss? | clearly matches an `out_of_scope` predicate | is in-scope but touches the edge of an `out_of_scope` predicate | fully within `scope.in_scope`, without ambiguity |
| **Mission advancement** | Does delivering the objective measurably advance the `mission` forward (via a pillar's `signal`), not just avoid harming it? | no observable effect on any signal | some plausible effect but hard to measure | a clear, measurable effect on a named signal |

## Pass rule (deterministic aggregation)

Scoring follows `plan.md` decision 3 and is implemented by the verdict aggregator
(equivalent to `alignVerdict`, per-stack — the rubric feeds it, does not average around it):

1. **Scope compliance is a hard gate, not an averaging input.** Any
   objective that a deterministic `out_of_scope` predicate matches (`scopeReject`)
   is `rejected` outright, regardless of the other two dimensions. A judge that
   averages a scope violation against a high pillar-fit is a FAIL of the rubric for
   that case — see Case 2 of `evals/cases/north-star-judge.md`.
2. **Orphans block.** Any objective mapped to zero pillars is reported
   as an orphan; the verdict cannot be `aligned` while an orphan exists.
3. **Pass = all three dimensions ≥ `alignment.threshold`** (default `3`, from
   the project's `north-star.md`) **and** no `out_of_scope` hit and no orphan.
4. Anything in-scope, without an orphan, but scoring below the threshold in
   some dimension is `needs-amendment` — neither a hard rejection nor a pass: it signals
   that either the brief needs rework, or the North Star itself may need an
   amendment (`amendment-protocol.md`).

## Scoring guide for the judge

- Score each dimension independently first; apply the pass rule above only after
  scoring, never let one dimension's score influence another.
- A brief can be superficially on-topic (references real services, real topology)
  and still be `out_of_scope` — read the objective by **what it does**
  (consult/visualize vs. provision/mutate), not just by the nouns it uses.
- When in doubt between two adjacent scores, prefer the lower — this rubric is a
  gate, not an incentive.

## Per-stack engine

The deterministic aggregation (schema validation, `scopeReject`, orphan check,
`alignVerdict`) is implemented by each adopting repo in its own stack; this file
specifies the semantic contract, it does not execute it. Reference implementation:
`poirot-fe scripts/north-star/align.mjs` (already built and unit-tested there).
