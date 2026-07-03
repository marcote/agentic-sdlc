---
name: distill
description: Destila brief.md en spec + acceptance (BDD) + coverage, cazando gaps estilo grilling. Usar tras escribir el brief de un feature.
---

# Distill

Entrada: `specs/<feature>/brief.md`. Salidas: `spec.md`, `acceptance.md`, `coverage.md`.

## Procedimiento (loop hasta converger)
1. **Sembrar desde la constitution.** Leé `memory/constitution/` (base + proyecto). Por cada
   `base/patterns/*.md` aplicable, inyectá su/s criterio/s `[given]` como filas en `coverage.md`.
2. **Extraer.** Del brief: objetivos, user stories, restricciones, métricas de éxito.
3. **Interrogar (grilling).** Preguntá al humano de a una las ambigüedades. NO avances con
   ambigüedades abiertas. (Inspirate en la skill `grilling` si está disponible.)
4. **Expandir edge cases (80% problem).** Generá los casos que el brief no cubre; cada uno
   entra como fila nueva de `coverage.md` y fuerza un criterio.
5. **Trazar.** Cada objetivo → requerimiento → criterio de aceptación (BDD). Marcá deterministas
   vs no-deterministas.
6. **Chequear cobertura.** Si hay filas huérfanas (objetivo sin criterio, o criterio sin
   eval/UAT), volvé al paso 3. Solo cuando no queden (o estén `deferred` con justificación),
   congelá `spec.md` + `acceptance.md`.
