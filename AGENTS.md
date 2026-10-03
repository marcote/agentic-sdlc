# Agents

Read `memory/north.md` first. Its rules come before every other rule in this repository. A hook adds it to every prompt.

This repository uses the agentic-sdlc harness. Four steps, one owner approval (gate H1):

1. brief — follow `harness/steps/brief.md`
2. spec — follow `harness/steps/spec.md`
3. build — run `uv run scripts/build.py specs/<slice>` (no owner)
4. accept — follow `harness/steps/accept.md`

When you write code, follow `harness/prompts/implementer.md`.

## Harness

Agnostic template for disciplined agentic development (Claude Code first).
Contains no app code: provides the harness that surrounds the model.

### Conventions
- One feature = one folder `specs/<NNN-feature>/` (kebab-case, NNN zero-padded).
- Requirements are EARS sentences, each with examples. See `specs/_template/spec.md`.

### Hard rules
- The owner approves once: gate H1, the spec page. Everything after it runs without the owner, except escalations.
- A spec passes `uv run scripts/spec.py lint` before gate H1.
- Build and accept are scripts. Never skip them, and never do their work by hand.
- Code follows `harness/prompts/implementer.md`: the ponytail ladder, library-first.
- A change to the north star or the charter is an amendment approved at gate H1.

### Workflow
`/brief` → `/spec` (gate H1) → `/build` → `/accept`. See `docs/workflow.md`.

### Pointers
- Step instructions: `harness/steps/`. Role prompts: `harness/prompts/`. Roles and CLIs: `harness.toml`.
- Slice templates: `specs/_template/`
- Non-negotiable principles: `memory/constitution/`
- Load-bearing technical decisions: `memory/stack/` (charter + pin grammar)
- Why the product exists: `memory/north-star/`

## Memory
- Lessons: `memory/lessons.md`
- Owner preferences: `memory/owner.md`
