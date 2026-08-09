---
extends: base
---

# North Star — Agentic SDLC Harness

> This file governs **why** the product exists; its counterpart
> `memory/constitution/constitution.md` governs **how** it is built. Extends
> `base` (see `base/schema.md`, `base/alignment-rubric.md`,
> `base/amendment-protocol.md`).
>
> **Adopters:** when vendoring the harness onto another repo, replace this file with
> the North Star of *your* product — just as you would replace/extend `constitution.md`. The
> shared `base/` (schema, rubric, protocol) remains; a project's delta is its
> mission, pillars, and scope only.
>
> Changing `pillars` or `scope` is a governed event: it requires an ADR + PR (see
> `base/amendment-protocol.md`). The initial seed is registered in
> `decisions/0001-seed-north-star.md`.

## Mission

A reusable, stack-agnostic harness that enforces a disciplined agentic SDLC (spec-driven, test-first, evidence-verified) on any project — governs how software is built, without imposing a stack or execution runtime, and without writing product code.

## Pillars

- **`real-enforcement`** — Discipline is enforced by deterministic gates, not good intentions.
  Its `signal`: gates block closure when a condition is missing and violations are caught before merge; the harness proves this by **dogfooding itself** (the retro ledger and `wow-report` are the evidence). Self-validation is not a separate pillar: it is the measurable proxy of *this one*.
- **`agnostic-portability`** — Runs on any stack or project without imposing technology or runtime.
  Its `signal`: the contract (schema, gates, artifacts) remains intact when vendored onto an arbitrary repo/stack.
- **`frictionless-adoption`** — Incorporating the harness into a new repo costs little, and
  every cost it does impose is justified by what that cost prevents.
  Its `signal`: steps/time to adopt (lower = better), with every mandatory step carrying a
  recorded justification proportional to what it prevents. The defect is an **unjustified**
  step, not a step as such — a signal that merely counted steps would be maximised by shipping
  nothing, and would put this pillar at war with the mission's word *enforces* (see
  `decisions/0004-*`).
- **`measurable-impact`** — The discipline the harness imposes must translate into better software, not gates that fire for the sake of firing.
  Its `signal`: gaps caught early (grilling/`/contract`) and late rework avoided (post-`/verify`/`/uat`), aggregated per feature in the "Method" section of the `wow-report`. Distinguishes *enforcing* (`real-enforcement`) from *enforcement that works* — the same anti-theater line from retro, elevated to the harness level.

## Scope

**In scope:** commands, gates, and skills of the governance workflow; product governance (constitution and North Star); feature templates, coverage, and criterion state machine; evals, verification, and UAT of the method; adoption tooling (install, vendoring, inheritance); WoW self-validation (retro, wow-report) and method documentation.

**Out of scope** (the hard-rejection predicates that `/align` uses): application code or product features of an adopting project; the stack-specific deterministic engine (provided by the adopter — "contract in the template, engine per-stack"); imposing or naming a mandatory execution runtime; blocking commit hooks; runtime dependencies or frameworks (the harness is dependency-free).

## Alignment

New briefs are scored against `base/alignment-rubric.md` by the `/align` skill.
Pass threshold: **3** out of 5 in each of the three dimensions (pillar fit, scope
compliance, mission advancement), with any `out_of_scope` hit as a hard rejection
regardless of score. See `base/alignment-rubric.md` for the complete aggregation rule.

## Canonical North Star

The block below is the single source of truth, read by the deterministic validator
(per-stack). The prose above explains it for humans; if they conflict, this block wins.

```json
{
  "mission": "A reusable, stack-agnostic harness that enforces a disciplined agentic SDLC (spec-driven, test-first, evidence-verified) on any project — governs how software is built, without imposing a stack or execution runtime, and without writing product code.",
  "pillars": [
    {
      "id": "real-enforcement",
      "statement": "Discipline is enforced by deterministic gates, not good intentions.",
      "signal": "Gates block closure when a condition is missing; violations are caught before merge (and the harness proves this by dogfooding itself: retro ledger / wow-report).", "since": "0001"
    },
    {
      "id": "agnostic-portability",
      "statement": "Runs on any stack or project without imposing technology or runtime.",
      "signal": "The contract (schema, gates, artifacts) remains intact when vendored onto an arbitrary repo/stack.", "since": "0001"
    },
    {
      "id": "frictionless-adoption",
      "statement": "Incorporating the harness into a new repo costs little, and every cost it does impose is justified by what that cost prevents.",
      "signal": "Steps/time to adopt (lower = better), with every mandatory step carrying a recorded justification proportional to what it prevents. The defect is an unjustified step, not a step as such: friction that buys nothing is what is being measured.", "since": "0004"
    },
    {
      "id": "measurable-impact",
      "statement": "The discipline the harness imposes must translate into better software: less rework and gaps caught before production, not gates that fire for the sake of firing.",
      "signal": "Gaps caught early (grilling/contract) and late rework avoided (post-verify/uat), aggregated per feature in the Method section of the wow-report; high = discipline prevents, not just bureaucratizes.", "since": "0002"
    }
  ],
  "scope": {
    "in_scope": [
      "commands, gates, and skills of the governance workflow",
      "product governance: constitution and North Star",
      "feature templates, coverage, and criterion state machine",
      "evals, verification, and UAT of the method",
      "adoption tooling: install, vendoring, and harness inheritance",
      "WoW self-validation (retro, wow-report) and method documentation"
    ],
    "out_of_scope": [
      "application code or product features of an adopting project",
      "stack-specific deterministic engine (provided by the adopter)",
      "imposing or naming a mandatory execution runtime",
      "blocking commit hooks",
      "runtime dependencies or frameworks"
    ]
  },
  "alignment": {
    "threshold": 3,
    "rubric": "memory/north-star/base/alignment-rubric.md"
  }
}
```
