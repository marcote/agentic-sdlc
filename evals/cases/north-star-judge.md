# Eval case — north-star-judge

> Criterio no-determinista: **JUDGE-ALIGNMENT**
> (`specs/002-north-star-governance/acceptance.md`). Puntuado manualmente (o por
> un LLM judge) contra `memory/north-star/base/alignment-rubric.md`, según
> `evals/README.md`. Estado: 📋 case.
>
> Este repo es la plantilla del harness: `memory/north-star/north-star.md` es un
> **placeholder** sin pilares reales. Los pilares usados abajo (`pilar-a`,
> `pilar-b`) son **ilustrativos** — un repo adoptante corre estos mismos dos
> cases contra su propio North Star, con sus propios pilares reales (ver
> `poirot-fe evals/cases/north-star-judge.md` para un ejemplo con contenido
> concreto de un proyecto).

## Qué se está juzgando

El juicio semántico de la skill `/align`: dado los objetivos de un brief y el
North Star del proyecto, el judge (a) propone un mapping objetivo→pilar y (b)
puntúa 3 dimensiones de la rúbrica (0–5 cada una, umbral de pase 3 — ver
`alignment-rubric.md`). Este eval chequea que el puntaje sea *sensato*, no solo
que la agregación determinista corra — esa parte es contrato documentado,
per-stack (criterio `ALIGN-VERDICT-CONTRACT`), no unit-testeada en este repo.

## Case 1 — brief in-scope puntúa bien en las 3 dimensiones

**Objetivo del brief (input, ilustrativo):**
> "Agregar un filtro de solo-lectura que permita ver qué elementos avanzan una
> señal del pilar `pilar-a`, sin modificar ningún dato existente."

**Comportamiento esperado del judge:**
- Mapea limpiamente a `pilar-a` (sin huérfano).
- Ningún predicado `out_of_scope` se dispara (es de solo lectura/visualización).
- Las 3 dimensiones puntúan **≥ 3**:
  - pillar fit — mapea a un `signal` explícito del pilar.
  - scope compliance — claramente dentro de `scope.in_scope`.
  - mission advancement — el objetivo tiene un efecto observable sobre el
    `signal` nombrado.
- Veredicto resultante (agregación per-stack): `aligned`.

## Case 2 — brief plausible-pero-fuera-de-alcance puntúa bajo en scope compliance

**Objetivo del brief (input, ilustrativo):**
> "Agregar un botón que permita a los usuarios modificar directamente el
> `north-star.md` del proyecto (sus pilares o su scope) desde la UI, sin pasar
> por PR ni revisión."

**Comportamiento esperado del judge:**
- Superficialmente plausible (menciona el North Star, un pilar real) — esta es
  la trampa: un judge superficial podría puntuarlo alto por relevancia sola.
- Al inspeccionarlo, requiere **mutar el scope/pillars sin ADR ni PR**, lo cual
  es explícitamente `out_of_scope` (viola `amendment-protocol.md`: todo cambio
  de scope/pillars es ADR + PR, nunca una escritura directa/silenciosa).
- La dimensión **scope compliance** debe puntuar **< 3** aunque las otras dos
  dimensiones (pillar fit, mission advancement) puntúen razonable — un judge
  que promedia y diluye la violación de scope es un FAIL para este case.
- Veredicto resultante: `rejected`, sin importar los otros dos scores (el
  rechazo de scope corta la agregación — ver `plan.md` decisión 3).

## Puntuación

Registrar, por case, los 3 scores de dimensión que asignó el judge y si el
veredicto derivado coincide con el "Comportamiento esperado" de arriba. Umbral
de pase de este eval case: ambos cases deben coincidir con su veredicto
esperado (`aligned` / `rejected`) y el Case 2 debe mostrar específicamente
scope compliance `< 3` (no solo un promedio bajo). Registrar el resultado en
`verification/reports/` de la feature, según `evals/README.md`.
