---
extends: base
---

# North Star — _(completar por proyecto)_

> **Placeholder.** Este repo es la plantilla del harness, no un proyecto adoptante:
> no tiene una misión propia. Cada repo que hereda el harness reemplaza este archivo
> con su propia capa de gobernanza de producto — par de
> `memory/constitution/constitution.md` (que gobierna *cómo* se construye el
> proyecto); este archivo gobierna *para qué existe*.
>
> Extiende `base` (ver `base/schema.md`, `base/alignment-rubric.md`,
> `base/amendment-protocol.md`). Completá cada `_(completar por proyecto)_` de abajo
> y del bloque JSON canónico; el bloque debe pasar `base/schema.md` (misión no
> vacía, ≥1 pilar con `id`+`statement`+`signal`, `scope.in_scope`/`out_of_scope` no
> vacíos, `alignment.threshold` presente) antes de que `/align` pueda gatear features
> contra él. Reference con contenido real de un proyecto:
> `poirot-fe memory/north-star/north-star.md`.

## Misión

_(completar por proyecto)_ — una frase de qué es el producto y qué no es.

## Pilares

- **`_(completar por proyecto)_`** — _(statement: qué significa el pilar)_. Su
  `signal` (en el bloque canónico) es el proxy medible de "¿este pilar está siendo
  servido de verdad?", usado por la dimensión **pillar fit** de la rúbrica.

## Scope

**En alcance:** _(completar por proyecto)_ — qué tipo de trabajo pertenece a la
misión.

**Fuera de alcance:** _(completar por proyecto)_ — los predicados que `/align` usa
como rechazo duro.

## Alignment

Los briefs nuevos se puntúan contra `base/alignment-rubric.md` por la skill
`/align`. Umbral de pase default: **3** de 5 en cada una de las tres dimensiones
(pillar fit, scope compliance, mission advancement), con cualquier hit de
`out_of_scope` como rechazo duro sin importar el score. Ver `base/alignment-rubric.md`
para la regla de agregación completa.

## North Star canónico

El bloque de abajo es la única fuente de verdad, leída por el validador determinista
(per-stack). La prosa de arriba lo explica para humanos; si discrepan, este bloque
gana.

```json
{
  "mission": "_(completar por proyecto)_",
  "pillars": [
    {
      "id": "_(completar por proyecto)_",
      "statement": "_(completar por proyecto)_",
      "signal": "_(completar por proyecto)_"
    }
  ],
  "scope": {
    "in_scope": ["_(completar por proyecto)_"],
    "out_of_scope": ["_(completar por proyecto)_"]
  },
  "alignment": {
    "threshold": 3,
    "rubric": "memory/north-star/base/alignment-rubric.md"
  }
}
```
