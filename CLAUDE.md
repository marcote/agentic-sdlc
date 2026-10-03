# Agentic SDLC Harness

Agnostic template for disciplined agentic development (Claude Code first).
Contains no app code: provides the harness that surrounds the model.

## Stack
Agnostic. Copied on top of any project.

## Conventions
- One feature = one folder `specs/<NNN-feature>/` (kebab-case, NNN zero-padded).
- Acceptance criteria are written in BDD (Given/When/Then).

## Hard rules
- The owner approves once: gate H1, the spec page. Everything after it runs without the owner, except escalations.
- A spec passes `uv run scripts/spec.py lint` before gate H1.
- Build and accept are scripts. Never skip them, and never do their work by hand.
- Code follows `harness/prompts/implementer.md`: the ponytail ladder, library-first.
- A change to the north star or the charter is an amendment approved at gate H1.

## Workflow
`/brief` → `/spec` (gate H1) → `/build` → `/accept`. See `docs/workflow.md`.

## Pointers
- Non-negotiable principles: `memory/constitution/`
- Load-bearing technical decisions: `memory/stack/` (charter + pin grammar)
- Skills (dynamic context): `.claude/skills/` (distill, verify, uat)
- Feature templates: `specs/_template/`
- Evaluation rubric: `evals/rubric.md`
- Verification reports (observability): `verification/reports/`
