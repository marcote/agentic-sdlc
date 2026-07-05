---
name: align
description: Validates a feature's brief against the project's North Star (Measurability Gate) — proposes an objective→pillar mapping, scores the alignment rubric, and writes alignment.md. Use before /distill on any feature's brief.md.
---

# Align

Input: `specs/<feature>/brief.md` + `memory/north-star/north-star.md`. Output:
`specs/<feature>/alignment.md`. This is the **Measurability Gate**: `/distill` reads
`alignment.md` and refuses to start unless its verdict is `aligned`.

## Contract in the template, per-stack engine

The harness is a stack-agnostic, dependency-free template. This skill describes
the **3-layer checkable model** and the **fixed verdict semantics**, but the
**executable deterministic engine** (schema validation, `scopeReject`, orphan check,
`alignVerdict`, `canDistill`) is provided by each adopting repo in its own stack —
just as the harness leaves the eval-runner to the adopter (`evals/README.md`). **Never
re-implement that engine inline in this skill**: an adopter builds it once and
this skill invokes it. Reference implementation:
`poirot-fe scripts/north-star/{schema,align}.mjs` (Node, already built and with its
test suite `tests/unit/north-star/*.node.spec.js` green). While an adopter has no
checker yet, this skill is still valid as a contract, but `/align` cannot be
truly executed until one exists — this is explicit, not a silent fallback.

## Procedure

1. **Validate the North Star first (fail closed).** Read
   `memory/north-star/north-star.md`, extract its canonical JSON block, and run the
   stack's schema validator (equivalent to `validateNorthStar`, see
   `memory/north-star/base/schema.md`). If it is **not** schema-valid — empty mission,
   no pillar with `id`+`statement`+`signal`, empty `scope.in_scope`/`out_of_scope`,
   or missing `alignment.threshold` — **stop**: do not read the brief, do not
   propose a mapping. The Measurability Gate refuses to run against a non-measurable
   North Star (criterion `MEAS-GATE`). Report the errors to the human and exit; do not
   write `alignment.md`.

2. **Extract the brief's objectives.** Read `specs/<feature>/brief.md` and extract its
   distinct objectives/goals as short literal text strings (this same text is the key
   in `mapping`/`scores`; keep it verbatim so that `alignment.md` is traceable back to
   the brief).

3. **Deterministic pre-filter (hard scope rejection).** For each objective, run the
   stack's scope predicate (equivalent to `scopeReject`, conservative contiguous-phrase
   match against `northStar.scope.out_of_scope`). Any objective that returns `true` is
   an obvious, high-confidence `out_of_scope` hit — note it, but let steps 4–6 run
   anyway for the full picture (the step 6 aggregation hard-rejects regardless of
   scores). Do not try to be smarter than the predicate here: it is deliberately
   conservative; borderline/semantic scope violations are the judge's job under the
   "scope compliance" dimension in step 5, not this step.

4. **Propose the objective→pillar mapping.** This is the semantic judgment of the
   skill itself — no script does this. For each objective, decide which of
   `northStar.pillars[].id` it advances (an objective may map to one, several, or — if
   genuinely orphaned — to none). Build:
   ```
   mapping = {
     "<objective text>": ["<pillar-id>", ...],   // or [] / null if orphaned
     ...
   }
   ```
   Read the `statement` and `signal` of each pillar before deciding; a mapping made
   only from the pillar's `id` is not defensible.

5. **Score the rubric.** Per `memory/north-star/base/alignment-rubric.md`,
   score each objective 0–5 on the three dimensions — pillar fit, scope compliance,
   mission advancement — **independently** (do not let one dimension's score bias
   another). Reduce to the **minimum per dimension** across objectives before
   aggregating — the gate must be met for the brief as a whole, not just its best
   objective:
   ```
   scores = {
     pillarFit: <min. across objectives, 0-5>,
     scopeCompliance: <min. across objectives, 0-5>,
     missionAdvancement: <min. across objectives, 0-5>,
   }
   ```
   When in doubt between two adjacent scores, prefer the lower one — the rubric is a
   gate, not an incentive.

6. **Aggregate the verdict (fixed semantics, deterministic — per-stack engine).** Given
   `scores` + `mapping` + the scope check, apply the aggregation (equivalent to
   `alignVerdict`, see `plan.md` decision 3):
   - an `out_of_scope` hit → **`rejected`** (hard gate, regardless of scores);
   - otherwise, any orphan → **`blocked`** (cannot be `aligned`);
   - otherwise, all 3 dimensions ≥ `northStar.alignment.threshold` (default 3) →
     **`aligned`**;
   - otherwise (in scope, no orphan, but some dimension below threshold) →
     **`needs-amendment`**.

7. **Write `specs/<feature>/alignment.md`.** Same directory as `brief.md`.
   Include:
   - the `verdict` and `scores` per dimension (the score the gate actually used,
     from step 5);
   - the `mapping` objective→pillar;
   - the `orphans` (empty list if none);
   - if `verdict` is not `aligned`, the required next step:
     - `rejected` → cite the matched `out_of_scope` predicate(s); the flow is
       blocked with no amendment route from this skill.
     - `blocked` (orphan) → name the orphaned objective(s); either narrow the
       brief or propose a North Star amendment for a missing pillar.
     - `needs-amendment` → name the dimension(s) below threshold and, per
       `memory/north-star/base/amendment-protocol.md`, that a North Star amendment
       (ADR in `memory/north-star/decisions/NNNN-*.md` + PR) is the only path forward
       if the brief cannot be reworked to score higher.

8. **Gate `/distill`.** Only an `aligned` verdict (equivalent to
   `canDistill(alignment)` → `true`) lets `/distill` proceed on this feature.
   Report the verdict to the human in any case; do not continue silently past a
   non-`aligned` verdict.

## Bootstrap exception

`/align` cannot gate the feature that introduces it
(`002-north-star-governance`, this very one) — that run was skipped by design (see
`plan.md` decision 8). Every feature from `002-north-star-governance` onward runs
`/align` before `/distill`, without exception.
