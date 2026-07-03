# Agentic SDLC Harness

Plantilla agnóstica (Claude Code first) para desarrollo agéntico disciplinado, con
verificación/UAT como norte. Basada en el whitepaper de Google *"The New SDLC With Vibe
Coding"* y en el concepto de *constitution* de Spec Kit.

## El loop de un vistazo
`/constitution → brief → /distill → /plan → /contract → /tasks → implement → /verify → /uat`

## Estructura
- `CLAUDE.md` — static context (stack, hard rules, workflow).
- `memory/constitution/` — principios no-negociables (base heredable + proyecto).
- `specs/_template/` — plantilla de feature (brief/spec/acceptance/coverage/plan/tasks).
- `evals/` — rubric de 5 dimensiones + cases no-deterministas.
- `verification/` — report, UAT y code-review checklists + `reports/` (observability).
- `.claude/` — skills (distill/verify/uat), 7 commands, hook advisory, settings.
- `docs/` — factory-model y workflow.

## Empezar un feature
1. `cp -r specs/_template specs/001-mi-feature` y escribí el `brief.md`.
2. `/distill` → `/plan` → `/contract` → `/tasks` → implementar → `/verify` → `/uat`.
3. `coverage.md` es tu fuente de verdad del estado.

## Verificar el harness
`bash tests/run.sh` — el template se auto-verifica (estructura + hook). También corre en CI.

## Principios
Productividad primero (verificación on-demand, sin hooks bloqueantes por commit),
intent > syntax, la constitution es código, todo verificable deja rastro.
