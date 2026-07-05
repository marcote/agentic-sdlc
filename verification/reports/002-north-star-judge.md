# Resultado del eval — north-star-judge (feature 002)

> Criterio no-determinista **JUDGE-ALIGNMENT**. Cases en
> `evals/cases/north-star-judge.md`, puntuados contra
> `memory/north-star/base/alignment-rubric.md`. Los pilares son **ilustrativos**
> (`pilar-a`, `pilar-b`) — este repo es la plantilla, `north-star.md` es un
> placeholder. Estado: 📋 case.

## Case 1 — brief in-scope

Objetivo: filtro de solo-lectura que muestra qué elementos avanzan un `signal` de
`pilar-a`, sin modificar datos.

| Dimensión | Score | Nota |
|---|---|---|
| pillar fit | 4 | mapea a `pilar-a` vía un `signal` explícito, sin huérfano |
| scope compliance | 5 | de lleno en `in_scope` (solo-lectura/visualización) |
| mission advancement | 4 | efecto observable sobre el `signal` nombrado |

Veredicto derivado: **`aligned`** (las 3 dimensiones ≥ 3, sin hit de scope, sin
huérfano). **Coincide** con el comportamiento esperado.

## Case 2 — brief plausible-pero-fuera-de-alcance

Objetivo: botón que deja a los usuarios mutar `north-star.md` (pilares/scope) desde
la UI, sin PR ni revisión.

| Dimensión | Score | Nota |
|---|---|---|
| pillar fit | 3 | menciona el North Star; superficialmente relevante |
| **scope compliance** | **1** | muta scope/pillars sin ADR ni PR → viola `amendment-protocol.md`, hit de `out_of_scope` |
| mission advancement | 2 | no avanza ningún `signal` |

Veredicto derivado: **`rejected`** — el hit de scope corta la agregación sin importar
las otras dimensiones (`plan.md` decisión 3). Scope compliance puntúa
específicamente **< 3** (no un promedio bajo diluido). **Coincide** con el
comportamiento esperado.

## Conclusión

Ambos cases coinciden con su veredicto esperado (`aligned` / `rejected`); el Case 2
muestra scope compliance `< 3` de forma específica. El eval **pasa**. El motor
determinista de agregación (`alignVerdict`) es contrato per-stack — no unit-testeado
aquí (criterio `ALIGN-VERDICT-CONTRACT`); reference: `poirot-fe scripts/north-star/`.
