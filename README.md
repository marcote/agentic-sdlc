# Agentic SDLC Harness

Plantilla agnóstica (Claude Code first) para desarrollo agéntico disciplinado, con
verificación/UAT como norte.

> **Basado en el trabajo de Google.** Este harness es una implementación práctica de las
> ideas del whitepaper de Google **_"The New SDLC With Vibe Coding — From ad-hoc prompting
> to Agentic Engineering"_** (Addy Osmani, Shubham Saboo y Sokratis Kartakis, mayo 2026):
> el *factory model*, el *context engineering* (static vs dynamic), la ecuación
> `Agent = Model + Harness`, los evals de *output + trajectory*, y el *80% problem*. El
> concepto de **constitution** proviene de **Spec Kit** (GitHub / Microsoft). Ver
> [Créditos y referencias](#créditos-y-referencias).

## El loop de un vistazo
`/constitution → brief → /align → /distill → /plan → /contract → /tasks → implement → /verify → /uat`

`/align` es el **gate de intake** (Measurability Gate): puntúa el brief contra el
North Star del proyecto (`memory/north-star/`) y `/distill` se niega a arrancar
salvo que el veredicto sea `aligned`.

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

### Dos capas: governance vs execution-runtime

El Way of Work se separa en dos capas con dueños distintos:

| Capa | Qué es | Dueño | Estabilidad |
|---|---|---|---|
| **Governance** (el harness) | los comandos (`/align`, `/distill`, `/plan`, `/contract`, `/tasks`, `/verify`, `/uat`), los gates deterministas, la **constitution** (cómo se construye) y el **North Star** (para qué existe el producto) | el harness — versionado, revisado, el mismo para todo adoptante | estable |
| **Execution-runtime** (lo elige el adoptante) | los pasos que **no** son comandos: el intake que produce el `brief.md`, el trabajo de implementación entre `/tasks` y `/verify`, y el finish (merge/PR/cleanup) | cada repo adoptante | intercambiable |

El harness **gobierna**; no impone un runtime de ejecución. Cualquier conjunto de
asistentes puede cubrir intake→brief, implement y finish siempre que respete los
artefactos y gates de la capa de governance. El harness **no nombra ningún runtime
como obligatorio** — los asistentes de brainstorming/TDD/etc. de un proyecto son
ayuda puntual **subordinada** a este flujo, no un proceso paralelo.

Análogamente, la capa de governance trae el **contrato** (schema del North Star,
rúbrica, protocolo de amendment, semántica del veredicto de `/align`) pero **no** el
motor determinista ejecutable que lo evalúa: ese lo provee cada stack adoptante,
igual que el eval-runner (`evals/README.md`). Ver `memory/north-star/base/README.md`.

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
| — | `/align` | `alignment.md` | **Measurability Gate**: puntúa el brief contra el North Star; solo `aligned` avanza a `/distill` |
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
- `memory/north-star/` — gobernanza de producto (para qué existe): `base/` (schema,
  rúbrica, protocolo de amendment) + `north-star.md` (North Star del harness; el
  adoptante lo reemplaza con el suyo, igual que la constitution) + `decisions/` (ADRs
  de amendment).
- `specs/_template/` — plantilla de feature (brief/spec/acceptance/coverage/plan/tasks).
- `evals/` — rubric de 5 dimensiones + cases no-deterministas.
- `verification/` — report, UAT y code-review checklists + `reports/` (observability).
- `.claude/` — skills (distill/verify/uat), 7 commands, hook advisory, settings.
- `docs/` — `factory-model.md` y `workflow.md` (referencia detallada).

## Empezar un feature
1. `cp -r specs/_template specs/001-mi-feature` y escribí el `brief.md`.
2. `/distill` → `/plan` → `/contract` → `/tasks` → implementar → `/verify` → `/uat`.
3. `coverage.md` es tu fuente de verdad del estado.

> 📎 **Ejemplo poblado:** `specs/001-example/` muestra un feature real a mitad de camino
> — con la matriz de `coverage.md` mezclando estados (🔴 / 🟢 / ✅ / 📋 / `[given]` /
> `deferred`) para que se vea el Way of Work en acción.

## Heredar la constitution en otro proyecto
`memory/constitution/base/` es un asset compartido **vendored**: copialo al proyecto
nuevo. El `constitution.md` local declara `extends: base` y agrega sus deltas. Para
actualizar, seguí `memory/constitution/update-checklist.md` y re-copiá `base/`.

## Verificar el harness
`bash tests/run.sh` — el template se auto-verifica (estructura + hook). También corre en CI (advisory).

## Gatear amendments del North Star (opcional pero recomendado)
Cambiar los sets `pillars`/`scope` del North Star es un evento gobernado (ADR + PR, ver
`memory/north-star/base/amendment-protocol.md`). El workflow `.github/workflows/amendment-gate.yml`
lo hace cumplir en CI: si un commit/push cambia esos sets sin un ADR nuevo, sin dejar el
bloque JSON schema-válido, o con la suite en rojo, el check `amendment-gate` falla. El
desarrollo normal de features **no** se bloquea (bloqueo angosto — es la única excepción al
principio 4, registrada en el delta D1 de la constitution).

Para volverlo **realmente bloqueante** (no solo advisory), el owner corre una vez:

```sh
scripts/setup-branch-protection.sh            # repo actual, rama main
scripts/setup-branch-protection.sh OWNER/REPO main
```

Eso hace `amendment-gate` un status-check *required* con `enforce_admins=true`: un PR con el
gate en rojo no es mergeable y un push directo saltándolo es rechazado. Requiere `gh` con
permisos de admin.

## Créditos y referencias

Este harness no inventa la metodología: la operacionaliza. El crédito conceptual es de:

- **Google — _"The New SDLC With Vibe Coding — From ad-hoc prompting to Agentic
  Engineering"_** (Addy Osmani, Shubham Saboo, Sokratis Kartakis; mayo 2026). Fuente del
  *factory model*, *context engineering* (static/dynamic), `Agent = Model + Harness`,
  *harness engineering*, evals de *output + trajectory*, el *conductor/orchestrator* y el
  *80% problem*. Todo el vocabulario del Way of Work proviene de aquí.
- **Spec Kit — GitHub / Microsoft.** Concepto de **constitution** (principios
  no-negociables que gobiernan el flujo) y del pipeline `specify → plan → tasks`.

Documentos internos de este repo:

- Diseño (rationale): `docs/superpowers/specs/2026-07-02-agentic-sdlc-harness-design.md`
- Plan de implementación: `docs/superpowers/plans/2026-07-02-agentic-sdlc-harness.md`
- Detalle del flujo: `docs/workflow.md` · Factory model: `docs/factory-model.md`
