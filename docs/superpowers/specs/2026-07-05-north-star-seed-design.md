# Diseño — Seed del North Star del harness

fecha: 2026-07-05 · estado: aprobado en brainstorming, pendiente de ejecución

## Problema

`memory/north-star/north-star.md` es un **placeholder** (todo `_(completar por
proyecto)_`) porque históricamente este repo se trató como "la plantilla, el adoptante
la reemplaza". Pero el repo **es un producto real** — un harness reutilizable de SDLC
agéntico — y merece su propia gobernanza de producto, igual que ya tiene una
`constitution.md` real. El usuario quiere empezar a definir "hacia dónde vamos".

**Bonus estructural:** llenar el North Star con un bloque schema-válido **destraba la
Cara A (Misión) del retro** que hoy cierra `n/a` (ver
`docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`, "Constraint:
repo-plantilla vs adoptante"). Completa el loop align↔retro que quedó a medias.

## Principio de clasificación (por qué esto ordena, no improvisa)

El North Star tiene una forma precisa (`memory/north-star/base/schema.md`): `mission` +
`pillars[]` (cada uno con un **`signal` medible**) + `scope.in/out` + `threshold`. No es
una lista de features ni una guía de estilo. Los tres ejemplos iniciales del usuario son
tres clases distintas de cosa:

| Ejemplo | Qué es | Dónde va |
|---|---|---|
| "armar un SDLC reutilizable" | la **Misión** (para qué existe) | `north-star.md` |
| "install desde github" | un **feature/medio** (futuro `brief.md`) | backlog, bajo el pilar `adopcion-sin-friccion` |
| "comandos en inglés" | una **convención del cómo** (sin signal medible) | `constitution`, fuera del North Star |

Regla para saber si algo es pilar: **¿tiene un `signal` medible de "¿estamos sirviendo
la misión?"?**

## Framing: repo-como-producto

Este repo pasa a tener North Star **real** (retira el placeholder), análogo a que ya
tiene `constitution.md` real. Los adoptantes lo reemplazan al vendorear el harness, igual
que reemplazan la constitution (flujo ya documentado en README y
`memory/north-star/base/README.md`). El `base/` (schema, rúbrica, amendment-protocol)
sigue siendo el asset compartido; el delta del proyecto es misión/pilares/scope.

## "De a poco" reconciliado con el schema

El schema exige un mínimo **completo** para ser válido (misión + ≥1 pilar con signal +
scope in/out + threshold) — no existe medio-North-Star válido. Entonces "de a poco" =
**seedear un mínimo válido ahora** y **crecer pilares/scope después vía el
amendment-protocol** (ADR en `memory/north-star/decisions/`). El seed inicial se registra
como **ADR fundacional 0001**.

## El North Star aprobado

**Misión (paraguas — abarca los tres pilares):**
> Un harness reutilizable y agnóstico de stack que hace cumplir un SDLC agéntico
> disciplinado (spec-driven, test-first, verificado con evidencia) sobre cualquier
> proyecto — gobierna *cómo* se construye, sin imponer stack ni runtime de ejecución, y
> sin escribir código de producto.

**Pilares (3 — la auto-validación/dogfooding NO es pilar aparte: es el `signal` del
`enforcement-real`):**

| Pilar | Statement | Signal medible |
|---|---|---|
| `enforcement-real` | La disciplina la hacen cumplir gates deterministas, no la buena voluntad | Los gates bloquean el cierre cuando falta una condición; violaciones cazadas antes del merge (el harness lo prueba dogfoodeándose: ledger de retros / wow-report) |
| `portabilidad-agnostica` | Corre sobre cualquier stack/proyecto sin imponer tecnología ni runtime | El contrato (schema/gates/artefactos) se mantiene íntegro al vendorearlo sobre un repo/stack arbitrario |
| `adopcion-sin-friccion` | Incorporar el harness a un repo nuevo cuesta poco | Pasos/tiempo para adoptar el harness (menor = mejor) |

**Scope:**
- **in_scope:** comandos/gates/skills del workflow; constitution y North Star; plantillas
  de feature, coverage y máquina de estados; evals/verificación/UAT; tooling de adopción
  (install/vendoring/herencia); auto-validación del WoW (retro/wow-report) y docs del método.
- **out_of_scope (rechazo duro de `/align`):** código de aplicación o features de producto
  del adoptante; motor determinista específico de un stack; imponer/nombrar un runtime
  obligatorio; hooks bloqueantes por commit; dependencias de runtime o frameworks.

**Bloque canónico** (fuente de verdad, va en `north-star.md`):

```json
{
  "mission": "Un harness reutilizable y agnóstico de stack que hace cumplir un SDLC agéntico disciplinado (spec-driven, test-first, verificado con evidencia) sobre cualquier proyecto — gobierna cómo se construye, sin imponer stack ni runtime de ejecución, y sin escribir código de producto.",
  "pillars": [
    {
      "id": "enforcement-real",
      "statement": "La disciplina la hacen cumplir gates deterministas, no la buena voluntad.",
      "signal": "Los gates bloquean el cierre cuando falta una condición; las violaciones se cazan antes del merge (y el harness lo prueba dogfoodeándose: ledger de retros / wow-report)."
    },
    {
      "id": "portabilidad-agnostica",
      "statement": "Corre sobre cualquier stack o proyecto sin imponer tecnología ni runtime.",
      "signal": "El contrato (schema, gates, artefactos) se mantiene íntegro al vendorearlo sobre un repo/stack arbitrario."
    },
    {
      "id": "adopcion-sin-friccion",
      "statement": "Incorporar el harness a un repo nuevo cuesta poco.",
      "signal": "Pasos/tiempo para adoptar el harness en un proyecto (menor = mejor)."
    }
  ],
  "scope": {
    "in_scope": [
      "comandos, gates y skills del workflow de governance",
      "gobernanza de producto: constitution y North Star",
      "plantillas de feature, coverage y máquina de estados de criterios",
      "evals, verificación y UAT del método",
      "tooling de adopción: install, vendoring y herencia del harness",
      "auto-validación del WoW (retro, wow-report) y documentación del método"
    ],
    "out_of_scope": [
      "código de aplicación o features de producto de un proyecto adoptante",
      "motor determinista específico de un stack",
      "imponer o nombrar un runtime de ejecución obligatorio",
      "hooks bloqueantes por commit",
      "dependencias de runtime o frameworks"
    ]
  },
  "alignment": {
    "threshold": 3,
    "rubric": "memory/north-star/base/alignment-rubric.md"
  }
}
```

## Archivos que toca

| Acción | Archivo |
|---|---|
| reescribir | `memory/north-star/north-star.md` (bloque JSON real + prosa; retira el placeholder, mantiene `extends: base`) |
| ajustar prosa | `README.md` (la línea `north-star.md (placeholder del proyecto)` → North Star real; aclarar que el adoptante lo reemplaza como la constitution) |
| nuevo | `memory/north-star/decisions/0001-seed-north-star.md` (ADR fundacional con el rationale del seed) |

## Verificación
- El bloque JSON pasa `memory/north-star/base/schema.md` (misión no vacía; 3 pilares con
  `id`+`statement`+`signal`; scope in/out no vacíos; threshold presente).
- `bash tests/run.sh` sigue verde — `check_80_north_star.sh` sólo exige `extends: base` +
  existencia, ambos preservados.

## No-objetivos (YAGNI)
- **No** agregar pilares más allá de 3 ahora (crecen vía amendment-protocol cuando haga falta).
- **No** implementar el feature "install desde github" acá (es un futuro `brief.md` bajo
  `adopcion-sin-friccion`).
- **No** abordar "comandos en inglés" acá (es convención → constitution, ítem separado).
- **No** construir el motor determinista per-stack de `/align` en este repo (contrato en
  la plantilla, motor por-stack — sigue siendo del adoptante).
