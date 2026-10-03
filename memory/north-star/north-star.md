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

A reusable, stack-agnostic harness that enforces a disciplined, autonomous agentic SDLC (spec-driven, test-first, evidence-verified). Where the owner defines done and agents deliver it, on any project. Governs how software is built, without imposing a stack or execution runtime, and without writing product code.

## Pillars

- **`real-enforcement`** — Discipline is enforced by deterministic gates, not good intentions.
  Its `signal`: gates block closure when a condition is missing and violations are caught before merge; the evidence is the lint, build and accept gates, and the owner approves only at gate H1. Self-validation is not a separate pillar: it is the measurable proxy of *this one*.
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
  Its `signal`: lead time, interventions, and reused against new modules, per slice. Distinguishes *enforcing* (`real-enforcement`) from *enforcement that works* — the same anti-theater line from retro, elevated to the harness level.

## Scope

**In scope:** commands, gates, and skills of the governance workflow; product governance (constitution and North Star); feature templates, glossary, and module map; evals, verification, and UAT of the method; adoption tooling (install, vendoring, inheritance); the autonomous build loop, its metrics, and method documentation.

**Out of scope** (the hard-rejection predicates that `/align` uses): application code or product features of an adopting project; the stack-specific deterministic engine (provided by the adopter — "contract in the template, engine per-stack"); imposing a mandatory agent CLI, model or product stack; blocking commit hooks; dependencies beyond `uv` and inline script dependencies.

## Glossary

Every term here has one meaning. Specs use these terms, and only gate H1 changes them.

| term | meaning |
| --- | --- |
| **slice** | One feature, from brief to merge. |
| **gate H1** | The one approval the owner gives: the spec page. |
| **build** | The step that implements the plan without the owner. A script controls it. |
| **accept** | The step that verifies the result by machine and merges it. |
| **escalation** | A stop that asks the owner for a decision. |

Every statement in this file carries one label: decided, hypothesis, open or reported.
Accept appends results under `## Reported`.

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
  "mission": "A reusable, stack-agnostic harness that enforces a disciplined, autonomous agentic SDLC (spec-driven, test-first, evidence-verified), where the owner defines done and agents deliver it, on any project — governs how software is built, without imposing a stack or execution runtime, and without writing product code.",
  "pillars": [
    {
      "id": "real-enforcement",
      "statement": "Discipline is enforced by deterministic gates, not good intentions.",
      "signal": "Gates block closure when a condition is missing; violations are caught before merge (the evidence is the lint, build and accept gates; the owner approves only at gate H1).", "since": "0001"
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
      "signal": "Lead time, interventions, and reused against new modules, per slice; these are the success criteria of spec 029.", "since": "0002"
    }
  ],
  "scope": {
    "in_scope": [
      "commands, gates, and skills of the governance workflow",
      "product governance: constitution and North Star",
      "feature templates, glossary, and module map",
      "evals, verification, and UAT of the method",
      "adoption tooling: install, vendoring, and harness inheritance",
      "the autonomous build loop, its metrics, and method documentation"
    ],
    "out_of_scope": [
      "application code or product features of an adopting project",
      "stack-specific deterministic engine (provided by the adopter)",
      "imposing a mandatory agent CLI, model or product stack",
      "blocking commit hooks",
      "dependencies beyond `uv` and inline script dependencies",
      "product discovery and demand validation",
      "prioritisation, roadmapping or estimation across features",
      "release, deployment or rollout of the software being built",
      "production monitoring, incident response or usage analytics"
    ]
  },
  "alignment": {
    "threshold": 3,
    "rubric": "memory/north-star/base/alignment-rubric.md"
  }
}
```
