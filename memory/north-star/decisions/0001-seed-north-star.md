# 0001 — Seed of the harness North Star

> Foundational ADR: the first population of this repo's North Star (from placeholder to
> real). Records the seed rationale and sets the precedent that all subsequent changes
> to `pillars`/`scope` go through `base/amendment-protocol.md`.

## Context

`memory/north-star/north-star.md` was a **placeholder** (`_(fill in per project)_`)
because the repo was treated as "the template; the adopter fills it in". But the repo is
a **real product** — a reusable agentic SDLC harness — and it had been operating without
declaring *why it exists*. Two pressures motivated the change:

1. Without a schema-valid North Star, `/align` is fail-closed: no brief can be gated
   against the mission, and the **Face A (Mission) of the retro** always closes `n/a` (see
   `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`). The align↔retro
   loop was structurally incomplete.
2. Lack of an explicit north to decide which features belong to the harness and which
   do not (e.g. "install from github" belongs; "adopter's app code" does not).

## Decision

Populate the canonical JSON block of `north-star.md`. **Before:** all fields in
`_(fill in per project)_` (not schema-valid). **After:**

- `mission`: "A reusable, stack-agnostic harness that enforces a disciplined agentic SDLC
  … without writing product code." (see the JSON in `north-star.md`).
- `pillars`: three — `real-enforcement`, `agnostic-portability`, `frictionless-adoption`,
  each with `statement` + measurable `signal`. Self-validation/dogfooding is **not** a
  separate pillar: it is the `signal` of `real-enforcement`.
- `scope.in_scope` / `scope.out_of_scope`: populated (see the JSON).
- `alignment.threshold`: 3.

## Scope-delta

The entire `scope` enters for the first time (before: empty/placeholder). `out_of_scope`
predicates that are now hard `/align` rejections: adopter's application code; per-stack
deterministic engine; imposing a mandatory runtime; blocking per-commit hooks; runtime/framework
dependencies. `in_scope`: the governance workflow, governance (constitution/North Star),
feature/coverage templates and state machine, evals/verification/UAT, adoption tooling,
and WoW self-validation.

## Consequences

- **Enables** real `/align` in this repo → unlocks **Face A of the retro** (no longer
  `n/a`; future harness features close their mission prediction with real data). Completes
  the align↔retro loop.
- Future harness briefs are now scored against these 3 pillars. Examples:
  "install from github" → `frictionless-adoption` (eligible); "write adopter's app code"
  → `out_of_scope` (hard rejection).
- Pillars/scope are now under change control: growing or reformulating goes through ADR + PR
  (`base/amendment-protocol.md`). This ADR is the starting point (0001).
- **Follow-ups** (not in this change): the "install from github" feature; the "commands
  in English" convention (goes in `constitution`, not the North Star).
