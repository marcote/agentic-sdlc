# Design — Harness North Star Seed

date: 2026-07-05 · status: approved in brainstorming, pending execution

## Problem

`memory/north-star/north-star.md` is a **placeholder** (all `_(fill in per
project)_`) because historically this repo was treated as "the template — the adopter
replaces it." But the repo **is a real product** — a reusable agentic SDLC
harness — and deserves its own product governance, just as it already has a
real `constitution.md`. The user wants to start defining "where we are headed."

**Structural bonus:** filling the North Star with a schema-valid block **unlocks
Side A (Mission) of the retro** that currently closes as `n/a` (see
`docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`, "Constraint:
repo-template vs adopter"). This completes the align↔retro loop that was left half-done.

## Classification Principle (why this organizes rather than improvises)

The North Star has a precise shape (`memory/north-star/base/schema.md`): `mission` +
`pillars[]` (each with a measurable **`signal`**) + `scope.in/out` + `threshold`. It is not
a feature list or a style guide. The user's three initial examples are three distinct
classes of thing:

| Example | What it is | Where it goes |
|---|---|---|
| "build a reusable SDLC" | the **Mission** (why it exists) | `north-star.md` |
| "install from github" | a **feature/means** (future `brief.md`) | backlog, under the `adopcion-sin-friccion` pillar |
| "commands in English" | a **how convention** (no measurable signal) | `constitution`, outside the North Star |

Rule for deciding whether something is a pillar: **Does it have a measurable `signal` for "are we serving the mission?"**

## Framing: repo-as-product

This repo now has a **real** North Star (retiring the placeholder), analogous to already
having a real `constitution.md`. Adopters replace it when they vendor the harness, just
as they replace the constitution (flow already documented in README and
`memory/north-star/base/README.md`). The `base/` (schema, rubric, amendment-protocol)
remains the shared asset; the project delta is mission/pillars/scope.

## "Incrementally" reconciled with the schema

The schema requires a **complete** minimum to be valid (mission + ≥1 pillar with signal +
scope in/out + threshold) — there is no such thing as a half-valid North Star. So "incrementally" =
**seed a valid minimum now** and **grow pillars/scope later via the
amendment-protocol** (ADR in `memory/north-star/decisions/`). The initial seed is recorded
as **foundational ADR 0001**.

## The Approved North Star

**Mission (umbrella — covers all three pillars):**
> A reusable, stack-agnostic harness that enforces a disciplined agentic SDLC
> (spec-driven, test-first, verified with evidence) on any project — it governs *how*
> things are built, without imposing a stack or execution runtime, and
> without writing product code.

**Pillars (3 — self-validation/dogfooding is NOT a separate pillar: it is the `signal` of
`enforcement-real`):**

| Pillar | Statement | Measurable signal |
|---|---|---|
| `enforcement-real` | Discipline is enforced by deterministic gates, not goodwill | Gates block closure when a condition is missing; violations caught before merge (the harness proves this by dogfooding itself: retro ledger / wow-report) |
| `portabilidad-agnostica` | Runs on any stack/project without imposing technology or runtime | The contract (schema/gates/artifacts) remains intact when vendored onto an arbitrary repo/stack |
| `adopcion-sin-friccion` | Onboarding the harness to a new repo costs little | Steps/time to adopt the harness (lower = better) |

**Scope:**
- **in_scope:** workflow commands/gates/skills; constitution and North Star; feature,
  coverage, and criteria state-machine templates; evals/verification/UAT; adoption
  tooling (install/vendoring/inheritance); WoW self-validation (retro/wow-report) and method docs.
- **out_of_scope (hard rejection by `/align`):** application code or product features of
  an adopter project; stack-specific deterministic engine; imposing or naming a mandatory
  execution runtime; blocking commit hooks; runtime dependencies or frameworks.

**Canonical block** (source of truth, goes in `north-star.md`):

```json
{
  "mission": "A reusable, stack-agnostic harness that enforces a disciplined agentic SDLC (spec-driven, test-first, evidence-verified) on any project — governs how software is built, without imposing a stack or execution runtime, and without writing product code.",
  "pillars": [
    {
      "id": "enforcement-real",
      "statement": "Discipline is enforced by deterministic gates, not good intentions.",
      "signal": "Gates block closure when a condition is missing; violations are caught before merge (and the harness proves this by dogfooding itself: retro ledger / wow-report)."
    },
    {
      "id": "agnostic-portability",
      "statement": "Runs on any stack or project without imposing technology or runtime.",
      "signal": "The contract (schema, gates, artifacts) remains intact when vendored onto an arbitrary repo/stack."
    },
    {
      "id": "frictionless-adoption",
      "statement": "Incorporating the harness into a new repo costs little.",
      "signal": "Steps/time to adopt the harness in a project (lower = better)."
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
      "stack-specific deterministic engine",
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

## Files it touches

| Action | File |
|---|---|
| rewrite | `memory/north-star/north-star.md` (real JSON block + prose; retires the placeholder, keeps `extends: base`) |
| adjust prose | `README.md` (the line `north-star.md (project placeholder)` → real North Star; clarify that the adopter replaces it just like the constitution) |
| new | `memory/north-star/decisions/0001-seed-north-star.md` (foundational ADR with the seed rationale) |

## Verification
- The JSON block passes `memory/north-star/base/schema.md` (non-empty mission; 3 pillars with
  `id`+`statement`+`signal`; non-empty scope in/out; threshold present).
- `bash tests/run.sh` stays green — `check_80_north_star.sh` only requires `extends: base` +
  existence, both preserved.

## Non-goals (YAGNI)
- **No** adding pillars beyond 3 now (they grow via amendment-protocol when needed).
- **No** implementing the "install from github" feature here (it is a future `brief.md` under
  `adopcion-sin-friccion`).
- **No** addressing "commands in English" here (it is a convention → constitution, separate item).
- **No** building the per-stack deterministic engine for `/align` in this repo (contract in
  the template, per-stack engine — remains the adopter's responsibility).
