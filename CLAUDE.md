# Agentic SDLC Harness

Plantilla agnóstica para desarrollo agéntico disciplinado (Claude Code first).
No contiene código de app: provee el harness que rodea al modelo.

## Stack
Agnóstico. Se copia encima de cualquier proyecto.

## Convenciones
- Un feature = un folder `specs/<NNN-feature>/` (kebab-case, NNN zero-padded).
- Los criterios de aceptación se escriben en BDD (Given/When/Then).
- `coverage.md` es la fuente de verdad del estado de cada criterio.

## Hard rules (detalle en memory/constitution/)
- Ningún criterio determinista avanza a implementación sin test en 🔴 RED (`/contract`).
- Un feature cierra solo con: BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅ (`/retro` cierra la predicción de `/align`).
- La verificación es on-demand (`/verify`, `/uat`); no hay hooks bloqueantes por commit.
- Agregá una regla a memory/constitution/ cada vez que cometas un error repetible.

## Workflow
`/constitution` → (brief) → `/distill` → `/plan` → `/contract` → `/tasks` → implement → `/verify` → `/uat`
Ver `docs/workflow.md`.

## Punteros
- Principios no-negociables: `memory/constitution/`
- Skills (dynamic context): `.claude/skills/` (distill, verify, uat)
- Plantillas de feature: `specs/_template/`
- Rubric de evaluación: `evals/rubric.md`
- Reportes de verificación (observability): `verification/reports/`
