# Schema del North-Star (base)

> La **forma requerida** de un North Star. Este archivo es el contrato legible por
> humanos de las reglas que un validador determinista debe hacer cumplir. El
> validador ejecutable concreto (equivalente a `validateNorthStar`) lo provee
> cada stack adoptante — este repo especifica la forma, no la implementa (ver
> `specs/002-north-star-governance/plan.md` decisión 2). Reference implementation:
> `poirot-fe scripts/north-star/schema.mjs`.

## Dónde vive el North Star

El North Star de un proyecto es `memory/north-star/north-star.md`: markdown para
humanos (misión, rationale, prosa) más **un** bloque ` ```json ` fenced que es el
North Star **canónico y machine-readable**. El validador (per-stack) extrae ese
bloque y lo parsea como JSON — la prosa alrededor existe para explicarlo; nada del
flujo la lee para decidir. Si prosa y bloque JSON discrepan, **el bloque JSON
gana**.

## Forma requerida

```json
{
  "mission": "string",
  "pillars": [
    { "id": "string", "statement": "string", "signal": "string" }
  ],
  "scope": {
    "in_scope": ["string"],
    "out_of_scope": ["string"]
  },
  "alignment": {
    "threshold": 3
  }
}
```

## Reglas de campo

| Campo | Regla |
|---|---|
| `mission` | requerido, string no vacío |
| `pillars` | requerido, array con **≥ 1** entrada |
| `pillars[].id` | requerido, string no vacío — un slug corto (p. ej. `pilar-a`) |
| `pillars[].statement` | requerido, string no vacío — qué significa el pilar |
| `pillars[].signal` | requerido, string no vacío — un indicador **medible** de que el pilar está siendo servido (esto es lo que hace al North Star chequeable, no solo aspiracional) |
| `scope.in_scope` | requerido, array de strings **no vacío** |
| `scope.out_of_scope` | requerido, array de strings **no vacío** — usado por el predicado de scope (`scopeReject`, per-stack) como predicados de rechazo duro |
| `alignment.threshold` | requerido, número — score mínimo (0–5) que cada dimensión de la rúbrica debe superar para contar como alineado (ver `alignment-rubric.md`) |
| `alignment.rubric` | **opcional** — puntero/ruta al archivo de rúbrica usado para puntuar (p. ej. `alignment-rubric.md`); solo `alignment.threshold` es requerido |

Un North Star que falle cualquiera de estas reglas **no es schema-válido**, y por
la Measurability Gate (`specs/002-north-star-governance/acceptance.md`, criterio
MEAS-GATE) el flujo debe negarse a correr contra él — un North Star no medible no
puede gobernar nada.

## Validez, no verdad

El validador solo chequea **forma** (presencia, no-vacío, tipo) — no tiene opinión
sobre si una misión es *buena*. Juzgar la calidad es trabajo de la capa semántica
de la skill `/align` y de las dimensiones de `alignment-rubric.md`, no de este
schema.
