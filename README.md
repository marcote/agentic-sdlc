# Agentic SDLC Harness

Plantilla agnóstica (Claude Code first) para desarrollo agéntico disciplinado, con
verificación/UAT como norte. Basada en el whitepaper de Google *"The New SDLC With Vibe
Coding"* y en el concepto de *constitution* de Spec Kit.

## El loop de un vistazo
`/constitution → brief → /distill → /plan → /contract → /tasks → implement → /verify → /uat`

---

## Way of Work

### Filosofía

El output primario del desarrollador **no es código: es el sistema que produce código**
(el *factory model*). Vos definís los specs y los guardrails; el agente implementa; la
verificación valida. Cuatro reglas rigen todo:

1. **Productividad primero** — la verificación la corre el agente *on-demand*; nada
   bloquea un commit/push por defecto.
2. **Intent > syntax** — el artefacto que importa es el *spec* + los *criterios de
   aceptación*, no el código.
3. **La constitution es código** — versionada, revisada, heredable. Agregá una regla cada
   vez que el agente comete un error repetible.
4. **Todo verificable deja rastro** — cada verificación emite un reporte versionado.

### El enforcement no vive en hooks

La disciplina se hace cumplir en **transiciones del workflow** (una vez por fase), no en
hooks por commit. Tres capas, de la más gruesa a la más fina:

| Capa | Qué hace | Cuándo |
|---|---|---|
| **Constitution** (declarativa) | no-negociables; el agente la usa de semilla y filtro | siempre |
| **Workflow gates** (deterministas) | gate rojo de `/contract`, máquina de estados de `coverage.md`, cierre AND-estricto | en transiciones de comando · **90% del enforcement** |
| **Hooks** (finos) | solo `secret-scan` advisory (avisa, no bloquea) | opt-in |

### Las 7 fases

Cada comando produce un artefacto y tiene su verificación. La columna vertebral es
`coverage.md`: cada fila viaja del objetivo hasta su reporte.

| # | Comando | Produce | Gate / verificación |
|---|---|---|---|
| 1 | `/constitution` | `memory/constitution/` | semilla + filtro de todo el flujo |
| 2 | *(intake)* | `brief.md` | objetivo de producto + métricas de éxito (no la solución) |
| 3 | `/distill` | `spec.md` + `acceptance.md` + `coverage.md` | loop de grilling; no congela con filas huérfanas |
| 4 | `/plan` | `plan.md` | grounded en la constitution (no puede violar un `[given]`) |
| 5 | `/contract` | tests 🔴 + eval cases 📋 | corre el suite y **prueba que está RED** |
| 6 | `/tasks` | `tasks.md` | **GATE test-first**: rechaza emitir tasks si falta contrato rojo |
| 7 | *(implement)* | código | inner loop 🔴→🟢; escala al humano en el 20% conceptual |
| 8 | `/verify` | `verification/reports/…` | output eval (BUILD) + trajectory eval, contra `rubric.md` |
| 9 | `/uat` | reporte completo | valida contra el **objetivo**; un fallo = gap de producto → `/distill` |

### Los tres loops

- **Grilling** (dentro de `/distill`): cierra *gaps de especificación* antes de codear.
  El agente interroga ambigüedades de a una y expande edge cases (el *80% problem*).
- **Inner loop** (implementación, por task): auto-corrige 🔴→🟢. Condición de corte
  clara — DONE cuando pasan los tests del criterio; **ESCALA** al humano tras 2 fallas
  idénticas o 3 intentos (tuneable en la constitution), en vez de quemar tokens.
- **Feedback** (`/verify` + `/uat`): un fallo de `/verify` es un gap de *implementación*
  → volvé a implementar; un fallo de `/uat` es un gap de *producto* → volvé a `/distill`.

### La columna vertebral: `coverage.md`

Matriz de trazabilidad + máquina de estados. Regla mecánica: **todo objetivo llega a un
criterio; todo criterio mapea a un eval/UAT**. Fila huérfana = gap que bloquea el freeze
del spec. Estados de un criterio determinista:

`sin contrato → 🔴 red → 🟢 green → ✅ uat` · `📋 case` (no-determinista) · `[given]`
(heredado de la constitution) · `deferred` (gap justificado)

### Test-first, estilo BDD

Cada criterio de aceptación se escribe como escenario **Given/When/Then**, y ese escenario
*es* el test. `/contract` lo materializa en rojo; `/tasks` no entrega trabajo de
implementación hasta que existe. No queda a discreción del dev.

### Condición de cierre (AND estricto)

```
feature "DONE"  ⟺  BUILD ✅  AND  TRAJECTORY ✅  AND  UAT ✅  AND  coverage 100%
```

- **BUILD** — 100% de criterios deterministas en 🟢 (el contrato, no-negociable).
- **TRAJECTORY** — pesa igual que BUILD: un build verde que *saltó verificación* es un fail.
- **UAT** — único que valida contra el objetivo del brief y revela gaps de producto.

---

## Estructura
- `CLAUDE.md` — static context (stack, hard rules, workflow).
- `memory/constitution/` — principios no-negociables (base heredable + proyecto).
- `specs/_template/` — plantilla de feature (brief/spec/acceptance/coverage/plan/tasks).
- `evals/` — rubric de 5 dimensiones + cases no-deterministas.
- `verification/` — report, UAT y code-review checklists + `reports/` (observability).
- `.claude/` — skills (distill/verify/uat), 7 commands, hook advisory, settings.
- `docs/` — `factory-model.md` y `workflow.md` (referencia detallada).

## Empezar un feature
1. `cp -r specs/_template specs/001-mi-feature` y escribí el `brief.md`.
2. `/distill` → `/plan` → `/contract` → `/tasks` → implementar → `/verify` → `/uat`.
3. `coverage.md` es tu fuente de verdad del estado.

## Heredar la constitution en otro proyecto
`memory/constitution/base/` es un asset compartido **vendored**: copialo al proyecto
nuevo. El `constitution.md` local declara `extends: base` y agrega sus deltas. Para
actualizar, seguí `memory/constitution/update-checklist.md` y re-copiá `base/`.

## Verificar el harness
`bash tests/run.sh` — el template se auto-verifica (estructura + hook). También corre en CI (advisory).

## Referencias
- Diseño (rationale): `docs/superpowers/specs/2026-07-02-agentic-sdlc-harness-design.md`
- Plan de implementación: `docs/superpowers/plans/2026-07-02-agentic-sdlc-harness.md`
- Detalle del flujo: `docs/workflow.md` · Factory model: `docs/factory-model.md`
