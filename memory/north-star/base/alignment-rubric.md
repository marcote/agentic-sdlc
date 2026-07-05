# Rúbrica de alineación (base)

> "Un North Star sin rúbrica no mide nada." Tres dimensiones, cada una puntuada
> 0–5. La usa el judge (LLM) de la skill `/align` para puntuar los objetivos de un
> brief contra el North Star del proyecto (`north-star.md`), y el eval
> `JUDGE-ALIGNMENT` (`evals/cases/north-star-judge.md`) para chequear que el judge
> puntúe con sensatez.

## Dimensiones

| Dimensión | Qué mide | 0 | 3 (piso de pase) | 5 |
|---|---|---|---|---|
| **Pillar fit** (encaje con el pilar) | ¿el objetivo mapea al `statement`/`signal` de un pilar explícito? | no mapea a ningún pilar (huérfano) | mapea a un pilar, el encaje es plausible pero flojo | mapea limpiamente a uno o más pilares; avanza un `signal` nombrado |
| **Scope compliance** (cumplimiento de alcance) | ¿el objetivo evita todo predicado `scope.out_of_scope` — incluidos los no obvios que una lectura superficial pasaría por alto? | matchea claramente un predicado `out_of_scope` | está en alcance pero toca el borde de un predicado `out_of_scope` | está de lleno dentro de `scope.in_scope`, sin ambigüedad |
| **Mission advancement** (avance de la misión) | ¿entregar el objetivo mueve de forma medible la `mission` hacia adelante (vía un `signal` de un pilar), no solo evita dañarla? | ningún efecto observable sobre ningún signal | algún efecto plausible pero difícil de medir | un efecto claro y medible sobre un signal nombrado |

## Regla de pase (agregación determinista)

La puntuación sigue `plan.md` decisión 3 y la implementa el agregador de veredicto
(equivalente a `alignVerdict`, per-stack — la rúbrica lo alimenta, no promedia
alrededor de él):

1. **Scope compliance es un gate duro, no un insumo de promedio.** Cualquier
   objetivo que un predicado determinista de `out_of_scope` matchee (`scopeReject`)
   es `rejected` de plano, sin importar las otras dos dimensiones. Un judge que
   promedia una violación de scope contra un pillar-fit alto es un FAIL de la
   rúbrica para ese case — ver Case 2 de `evals/cases/north-star-judge.md`.
2. **Los huérfanos bloquean.** Cualquier objetivo mapeado a cero pilares se reporta
   como huérfano; el veredicto no puede ser `aligned` mientras exista un huérfano.
3. **Pase = las tres dimensiones ≥ `alignment.threshold`** (default `3`, del
   `north-star.md` del proyecto) **y** sin hit de `out_of_scope` y sin huérfano.
4. Cualquier cosa en alcance, sin huérfano, pero puntuando por debajo del umbral en
   alguna dimensión es `needs-amendment` — ni un rechazo duro ni un pase: señala que
   o bien el brief necesita retrabajo, o bien el North Star mismo puede necesitar un
   amendment (`amendment-protocol.md`).

## Guía de puntuación para el judge

- Puntuá cada dimensión de forma independiente primero; aplicá la regla de pase de
  arriba solo después de puntuar, nunca dejes que el score de una dimensión influya
  en otra.
- Un brief puede ser superficialmente on-topic (referencia servicios reales,
  topología real) y aún así estar `out_of_scope` — leé el objetivo por **qué hace**
  (consultar/visualizar vs. provisionar/mutar), no solo por los sustantivos que usa.
- Ante la duda entre dos scores adyacentes, preferí el más bajo — esta rúbrica es un
  gate, no un estímulo.

## Motor per-stack

La agregación determinista (schema validation, `scopeReject`, orphan check,
`alignVerdict`) la implementa cada repo adoptante en su propio stack; este archivo
especifica el contrato semántico, no lo ejecuta. Reference implementation:
`poirot-fe scripts/north-star/align.mjs` (ya construida y unit-testeada allí).
