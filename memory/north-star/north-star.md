---
extends: base
---

# North Star — Agentic SDLC Harness

> Este archivo gobierna **para qué existe** el producto; su par
> `memory/constitution/constitution.md` gobierna **cómo** se construye. Extiende
> `base` (ver `base/schema.md`, `base/alignment-rubric.md`,
> `base/amendment-protocol.md`).
>
> **Adoptantes:** al vendorear el harness sobre otro repo, reemplazá este archivo con
> el North Star de *tu* producto — igual que reemplazás/extendés `constitution.md`. El
> `base/` compartido (schema, rúbrica, protocolo) queda; el delta de un proyecto es su
> misión, pilares y scope solamente.
>
> Cambiar `pillars` o `scope` es un evento gobernado: requiere ADR + PR (ver
> `base/amendment-protocol.md`). El seed inicial está registrado en
> `decisions/0001-seed-north-star.md`.

## Misión

Un harness reutilizable y agnóstico de stack que hace cumplir un SDLC agéntico
disciplinado (spec-driven, test-first, verificado con evidencia) sobre cualquier
proyecto — gobierna *cómo* se construye, sin imponer stack ni runtime de ejecución, y
sin escribir código de producto.

## Pilares

- **`enforcement-real`** — La disciplina la hacen cumplir gates deterministas, no la
  buena voluntad. Su `signal`: los gates bloquean el cierre cuando falta una condición y
  las violaciones se cazan antes del merge; el harness lo prueba **dogfoodeándose** (el
  ledger de retros y el `wow-report` son la evidencia). La auto-validación no es un pilar
  aparte: es el proxy medible de *este*.
- **`portabilidad-agnostica`** — Corre sobre cualquier stack o proyecto sin imponer
  tecnología ni runtime. Su `signal`: el contrato (schema, gates, artefactos) se mantiene
  íntegro al vendorearlo sobre un repo/stack arbitrario.
- **`adopcion-sin-friccion`** — Incorporar el harness a un repo nuevo cuesta poco. Su
  `signal`: pasos/tiempo para adoptar el harness en un proyecto (menor = mejor).
- **`impacto-medible`** — La disciplina que el harness impone tiene que traducirse en
  mejor software, no en gates que disparan por disparar. Su `signal`: gaps cazados
  temprano (grilling/`/contract`) y rework tardío evitado (post-`/verify`/`/uat`),
  agregados por feature en la sección "Método" del `wow-report`. Distingue *enforçar*
  (`enforcement-real`) de *que enforçar sirva* — la misma línea anti-teatro del retro,
  subida al nivel del harness.

## Scope

**En alcance:** comandos, gates y skills del workflow de governance; la gobernanza de
producto (constitution y North Star); plantillas de feature, `coverage` y la máquina de
estados de criterios; evals, verificación y UAT del método; tooling de adopción
(install, vendoring, herencia); auto-validación del WoW (retro, wow-report) y
documentación del método.

**Fuera de alcance** (los predicados que `/align` usa como rechazo duro): código de
aplicación o features de producto de un proyecto adoptante; el motor determinista
específico de un stack (lo provee el adoptante — "contrato en la plantilla, motor
por-stack"); imponer o nombrar un runtime de ejecución obligatorio; hooks bloqueantes por
commit; dependencias de runtime o frameworks (el harness es dependency-free).

## Alignment

Los briefs nuevos se puntúan contra `base/alignment-rubric.md` por la skill `/align`.
Umbral de pase: **3** de 5 en cada una de las tres dimensiones (pillar fit, scope
compliance, mission advancement), con cualquier hit de `out_of_scope` como rechazo duro
sin importar el score. Ver `base/alignment-rubric.md` para la regla de agregación completa.

## North Star canónico

El bloque de abajo es la única fuente de verdad, leída por el validador determinista
(per-stack). La prosa de arriba lo explica para humanos; si discrepan, este bloque gana.

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
    },
    {
      "id": "impacto-medible",
      "statement": "La disciplina que el harness impone tiene que traducirse en mejor software: menos rework y gaps cazados antes de producción, no gates que disparan por disparar.",
      "signal": "Gaps cazados temprano (grilling/contract) y rework tardío evitado (post-verify/uat), agregados por feature en la sección Método del wow-report; alto = la disciplina previene, no solo burocratiza."
    },
    {
      "id": "pilar-invalido-uat",
      "statement": "Pilar de prueba para el UAT del amendment-gate.",
      "signal": "no debería mergearse."
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
