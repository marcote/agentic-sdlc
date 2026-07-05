# Agentic SDLC Harness

Agnostic template for disciplined agentic development (Claude Code first).
Contains no app code: provides the harness that surrounds the model.

## Stack
Agnostic. Copied on top of any project.

## Conventions
- One feature = one folder `specs/<NNN-feature>/` (kebab-case, NNN zero-padded).
- Acceptance criteria are written in BDD (Given/When/Then).
- `coverage.md` is the source of truth for the state of each criterion.

## Hard rules (details in memory/constitution/)
- No deterministic criterion advances to implementation without a test in 🔴 RED (`/contract`).
- A feature closes only with: BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅ (`/retro` closes the prediction from `/align`).
- Verification is on-demand (`/verify`, `/uat`); no blocking commit hooks.
- Add a rule to memory/constitution/ every time you commit a repeatable mistake.

## Workflow
`/constitution` → (brief.md) → `/align` → `/distill` → `/plan` → `/contract` → `/tasks` → implement → `/verify` → `/uat` → `/retro`
See `docs/workflow.md`.

## Pointers
- Non-negotiable principles: `memory/constitution/`
- Skills (dynamic context): `.claude/skills/` (distill, verify, uat)
- Feature templates: `specs/_template/`
- Evaluation rubric: `evals/rubric.md`
- Verification reports (observability): `verification/reports/`
