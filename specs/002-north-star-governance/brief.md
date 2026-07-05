# Brief — North-Star Governance + Measurability Gate (base capability)

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.
>
> Full design (reference): `docs/superpowers/specs/2026-07-04-north-star-governance-design.md`

## Product objective

Give the `agentic-sdlc` harness a **cross-cutting** capability to **prevent product
drift**: perfectly built features that fall outside the project's mission. Add a
**North Star** layer (product governance, **peer** of the technical constitution) and
a checkable **intake gate `/align`**, so that before distilling a feature its
belonging to the mission is verified. Enforce the **Measurability Gate** law: if the
North Star cannot be defined, governed, and quantified, the flow does not execute
against it. The capability is **stack-agnostic** (contract in the template; the
deterministic engine is provided by each adopting repo).

## Why / motivation

An agentic SDLC amplifies drift: the agent lacks the instinct "should this exist?"
and produces features fast, so scope creep accelerates with throughput. The harness
today governs intent drift (well) and architectural drift (partially) but is **blind
to product drift** — an out-of-scope feature passes all gates. Governance that is
not codified and gated does not survive agentic throughput. Already piloted in
`poirot-fe` (PR #24); this brings it to the base harness for every adopting repo.

## Success metrics

- A brief whose objective matches an `out_of_scope` predicate is **blocked**
  (hard rejection) by the gate — measurable, deterministic.
- Every accepted brief has its objectives mapped to ≥1 **pillar** of the North Star
  (zero orphan objectives).
- The flow **refuses to run** if the project's North Star is not schema-valid /
  measurable, or if the alignment score is below the threshold without an approved
  amendment (the Measurability Gate is enforced).
- Alignment is **quantified** (score against rubric), not a yes/no opinion.
- Scope changes occur **only** via the versioned amendment protocol approved by
  a human (**ADR + PR**), never silently.
- The harness self-check covers the new layer (`tests/run.sh` green); the template
  stays **stack-agnostic and dependency-free** (no Node/npm in the source).

## Out of scope

- The **executable deterministic engine** in the source (stays per-stack;
  `poirot-fe scripts/north-star/*.mjs` is the cited reference implementation).
- Project-specific content: `north-star.md` in the source is a
  **placeholder** to be completed per project.
- Rewriting `specs/001-example` to pass through `/align` (predates the gate).
- Changing the language of the source (kept in Spanish).
