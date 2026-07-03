# Design — Agentic SDLC Harness

**Fecha:** 2026-07-02
**Autor:** Marco Torres
**Estado:** Aprobado (diseño) — pendiente plan de implementación

Basado en el whitepaper de Google *"The New SDLC With Vibe Coding — From ad-hoc
prompting to Agentic Engineering"* (Day 1; Osmani, Saboo, Kartakis) y en el
concepto de *constitution* de GitHub/Microsoft Spec Kit.

---

## 1. Objetivo y alcance

Definir la estructura de un **harness / plantilla de proyecto agnóstica**: un repo
de software (sin código de app) preparado para que agentes de código construyan con
disciplina. Es el *"factory model"* del paper: el desarrollador diseña el sistema
(specs, guardrails, verificación) y el agente produce; la verificación valida la salida.

**Decisiones marco:**

| Decisión | Elección |
|---|---|
| Tipo de repo | Harness / plantilla de proyecto (no un agente de producción, no metodología) |
| Stack | Agnóstico — solo la capa agéntica, se copia encima de cualquier proyecto |
| Convención de agente | **Claude Code first** (`CLAUDE.md` + `.claude/`) |
| Enforcement | Verificación **on-demand** por el agente; **sin hooks bloqueantes** por commit |
| Norte | **Verificación / UAT**: cerrar el loop que Spec Kit deja flojo |
| Herencia de constitution | **Vendored + convención** (`base/` se copia con el template) |
| Test-first | **Enforced por el workflow** (gate de fase), no discrecional; estilo BDD/TDD |

**Norte explícito:** la verificación y el UAT son ciudadanos de primera clase. El
diferencial del harness sobre Spec Kit es cerrar el ciclo de verificación —el propio
artículo de Spec Kit no cubre testing ni criterios de aceptación.

---

## 2. Principios de diseño

1. **Productividad primero.** La verificación la ejecuta el agente *on-demand* vía
   skills/commands, no hooks bloqueantes. Nada frena un commit/push por defecto.
2. **Intent > syntax.** El artefacto primario del dev es el *spec* + los *criterios
   de aceptación*, no el código.
3. **La constitution es código.** Versionada, revisada en PR, con su checklist de
   actualización. *"Add a rule every time the agent does something it should not do again."*
4. **Todo verificable deja rastro.** Cada verificación produce un *reporte*
   (build + trajectory + UAT), no un simple pass/fail efímero.

### Mapeo de conceptos

| Concepto | Origen | Rol en el repo |
|---|---|---|
| **Constitution** | Spec Kit | Principios no-negociables. La capa más estable del *static context*. |
| **Static vs Dynamic context** | Paper (Fig. 4) | `CLAUDE.md` + `memory/` = static. `.claude/skills/` = dynamic (progressive disclosure). |
| **Factory model** | Paper (Fig. 6) | El dev diseña el sistema; el agente produce; la verificación valida. |
| **Verify build + trajectory** | Paper (Fig. 5) | No solo "¿compila?" (output) sino "¿siguió el flujo?" (trajectory) + UAT contra criterios. |

---

## 3. Estructura de directorios

```
agentic-sdlc/
│
├── CLAUDE.md                      # STATIC context: stack, convenciones, hard rules,
│                                  #   workflow, punteros a memory/ y skills. Siempre cargado.
│
├── memory/                        # STATIC context persistente (Spec Kit "memory")
│   └── constitution/
│       ├── base/                  # HEREDADO · asset compartido · vendored
│       │   ├── principles.md      #   no-negociables en prosa
│       │   ├── patterns/          #   "given practices" que inyectan criterios
│       │   │   ├── audit-logging.md
│       │   │   ├── rate-limiting.md
│       │   │   └── idempotency.md
│       │   └── README.md          #   cómo funciona la herencia
│       ├── constitution.md        # PROYECTO · `extends: base` + deltas locales
│       └── update-checklist.md    # "add a rule cada vez que el agente falla"
│
├── specs/                         # un folder por feature — el corazón del flujo
│   └── <NNN-feature>/
│       ├── brief.md               #  ORIGEN: objetivo de producto + por qué + métricas
│       ├── spec.md                #  QUÉ: requerimientos, user stories, edge cases
│       ├── acceptance.md          #  criterios medibles (BDD Given/When/Then) ←── eval/UAT
│       ├── coverage.md            #  matriz de trazabilidad (detector de gaps + máquina de estados)
│       ├── plan.md                #  CÓMO: decisiones técnicas (grounded en constitution)
│       └── tasks.md               #  descomposición en unidades ejecutables
│
├── evals/                         # verificación automatizable (output + trajectory)
│   ├── rubric.md                  #  5 dimensiones: task success, tool use, trajectory,
│   │                              #    hallucination, response quality
│   ├── cases/                     #  casos derivados de acceptance.md (no-deterministas)
│   └── README.md                  #  cómo correrlos (plantilla; runner opcional)
│
├── verification/                  # NORTE · verificación on-demand + UAT
│   ├── uat-checklist.md           #  UAT por criterio de aceptación
│   ├── verification-report.md     #  plantilla del reporte (build + trajectory + UAT)
│   ├── code-review-checklist.md   #  scrutiny para código AI (deps alucinadas, error handling)
│   └── reports/                   #  reportes emitidos, versionados (observability / rastro)
│
├── .claude/                       # DYNAMIC context + harness Claude-native
│   ├── skills/                    #  progressive disclosure, se cargan on-demand
│   │   ├── distill/               #    brief → spec (grilling · cubre gaps · matriz)
│   │   ├── verify/                #    corre evals + genera verification-report
│   │   └── uat/                   #    guía el UAT contra acceptance.md
│   ├── commands/                  #  /constitution /distill /plan /contract /tasks /verify /uat
│   └── settings.json              #  permisos + hook mínimo advisory (secret-scan, no bloqueante)
│
├── docs/                          # el "por qué" — didáctico
│   ├── factory-model.md           #  cómo pensar el repo (paper Fig. 6)
│   └── workflow.md                #  el flujo end-to-end con diagrama
│
└── README.md                      # entrada: qué es, cómo se usa, el loop de un vistazo
```

**Mapeo a las capas del paper (Fig. 4 y 7):**
- **Static context** → `CLAUDE.md` + `memory/`
- **Dynamic context** → `.claude/skills/` (progressive disclosure)
- **Guardrails** → `memory/constitution/` (declarativo) + hook mínimo (ejecutable)
- **Feedback loop** → `evals/` + `verification/`
- **Observability** → `verification/reports/`

---

## 4. La constitution como artefacto heredable

Dos capas, estilo herencia (preset que se extiende):

- **`base/`** — HEREDADO, asset compartido, **vendored** (se copia con el template).
  Contiene los no-negociables en prosa (`principles.md`) y **patterns** ("given
  practices"). Cada pattern no es solo prosa: **inyecta criterios de aceptación por
  defecto**.

  Ejemplo `patterns/audit-logging.md`:
  > **Principio:** toda operación que escribe estado deja rastro auditable.
  > **Criterios inyectados:** `[given] cada endpoint de escritura emite audit-log con
  > actor+timestamp` → mapea a `eval: audit-trail`.

- **`constitution.md`** — PROYECTO, declara `extends: base` + deltas/overrides locales.

**Sincronización:** `base/` vive dentro del template y se copia con él. `extends: base`
es una convención que el skill `/distill` resuelve leyendo la carpeta. La base evoluciona
copiando cuando cambia (cero infra).

**Dónde entra en el loop:** la constitution es **semilla + filtro**, no un paso aparte:
- **Siembra** preguntas de interrogación en `/distill` ("¿esto choca con zero-trust?").
- **Filtra**: rechaza requerimientos que violan un no-negociable.
- **Inyecta** filas `[given]` en `coverage.md` *antes* de empezar, de modo que cada spec
  arranca pre-poblado con los criterios heredados y el loop solo cubre el *delta*.

Conecta con el paper *(engineering leaders)*: *"Invest in the harness components as a
shared team asset… build their harness once and refine it many times"* y *"AI amplifies
the engineering culture it lands in."* La `base/` **es** esa cultura, versionada.

---

## 5. La capa originante: del objetivo al spec verificable

Tres artefactos encadenados, cada uno más preciso que el anterior:

```
brief.md        → objetivo de producto + por qué + métricas de éxito (NO solución)
   ↓  (loop de destilación · estilo grilling)
spec.md         → requerimientos funcionales + user stories + edge cases
   ↓
acceptance.md   → criterios de aceptación medibles (BDD)  ←── esto ES el eval/UAT
```

Principio de cierre del paper: **"Specs become eval criteria"**. Cada criterio de
aceptación es simultáneamente lo que el UAT y el eval verifican. Si un objetivo no
llega hasta un criterio, es un gap.

### 5.1 El loop de destilación (cómo se cazan los gaps)

Ciclo que corre `/distill` (estilo `grilling`) hasta converger. Cuatro movimientos:

```
        ┌─────────────────────────────────────────────┐
        │  brief.md (objetivo + métricas de éxito)      │
        └───────────────────┬─────────────────────────┘
                            ▼
   ┌──────────────────────────────────────────────────────┐
   │ 1. EXTRAER   objetivos, stories, restricciones         │
   │ 2. INTERROGAR ambigüedades → preguntas al humano       │ ◄─┐ itera
   │ 3. EXPANDIR  edge cases que el humano no vio (80%)     │   │ (grilling)
   │ 4. TRAZAR    objetivo → requerimiento → criterio       │──┘
   └───────────────────────┬──────────────────────────────┘
                           ▼
              ¿coverage.md sin filas huérfanas? ── no ──► sigue grilling
                           │ sí (freeze)
                           ▼
              spec.md + acceptance.md  (congelados, versionados)
```

**Interrogación (paso 2):** estilo `grilling` — el agente **no avanza** con ambigüedades
abiertas: pregunta de a una, insiste, congela el spec solo cuando la matriz no tiene
filas huérfanas (o están *deferred* con justificación).

### 5.2 La matriz de trazabilidad (`coverage.md`) — detector de gaps

Tabla viva; columna vertebral del enforcement. Regla mecánica: **todo objetivo del brief
debe llegar a un criterio verificable; todo criterio debe mapear a un eval o paso de UAT.**
Cualquier fila huérfana es un gap explícito que bloquea el *freeze* del spec — lo detecta
el agente al correr `/distill`, no un hook.

| Objetivo | Requerimiento | Criterio | Origen | Estado |
|---|---|---|---|---|
| — | (todos) | audit-log en escrituras | `[given] base/audit-logging` | ✅ heredado |
| ↑ conversión | Guardar tarjeta 1-tap | token < 300ms, PCI | proyecto | 🟡 en grilling |

Los edge cases generados en el paso 3 (el **80% problem**) entran como filas nuevas,
forzando criterios para ellos.

---

## 6. Workflow end-to-end

**7 comandos + 3 loops.** El `brief.md` se autoría en el intake (manual o asistido);
los 7 slash-commands son: `/constitution`, `/distill`, `/plan`, `/contract`, `/tasks`,
`/verify`, `/uat`. La columna vertebral es `coverage.md`: cada fila viaja desde
el objetivo hasta su reporte de verificación.

```
 FASE (paper)          COMANDO            ARTEFACTO             VERIFICACIÓN
─────────────────────────────────────────────────────────────────────────────
 Config del harness   /constitution   → memory/constitution/   (semilla + filtro)
 Requirements         intake          → brief.md               objetivo + métricas
                      /distill        → spec + acceptance + coverage   (loop grilling)
 Design/Architecture  /plan           → plan.md                (grounded en constitution)
 Testing (contrato)   /contract       → tests 🔴 + eval cases   (prueba que está RED)
 (descomposición)     /tasks          → tasks.md    GATE: rechaza si falta contrato rojo
 Implementation       (implement)     → código      inner loop 🔴→🟢 (ver §7)
 Testing & QA         /verify         → verification-report     output + trajectory eval
 UAT                  /uat            → append al report        contra acceptance.md
```

### Los tres loops

1. **Loop de grilling** (dentro de `/distill`): cierra *gaps de especificación* antes de
   escribir código. Barato.
2. **Loop de implementación** (inner, por task): el agente auto-corrige 🔴→🟢 (ver §7).
3. **Loop de feedback** (`/verify` y `/uat`): si falla, rutea de vuelta:
   - Falla de **/verify** → problema de *implementación* → vuelve a implement.
   - Falla de **/uat** → el build cumple el spec pero el spec no cumplía el objetivo →
     **gap de producto** → vuelve a `/distill`.

**On-demand, no bloqueante:** `/verify` y `/uat` los invoca el dev (o el agente al cerrar
una task/feature), nunca un hook por commit. El commit/push fluye libre; la verificación
corre al cerrar una unidad de trabajo y siempre deja un reporte versionado.

---

## 7. El loop de implementación (inner loop)

Corre **por cada task de `tasks.md`**. Versión concreta del agent loop del paper (Fig. 2).

```
   pick task de tasks.md
        │  (lee sus filas ligadas en coverage.md = criterios que esta task satisface)
        ▼
   escribir/modificar código  +  hacer pasar los tests de ESOS criterios
        │
        ▼
   ejecutar checks LOCALES deterministas:  typecheck · unit tests de los criterios · lint
        │
        ▼
   OBSERVAR ─┬─ pasa & sin violación de constitution ──► task DONE ─► siguiente task
             ├─ falla MECÁNICA (bug) ──► auto-corrige, reintenta   ┐ budget N intentos
             ├─ misma falla 2 veces (no-progress) ──► ESCALA        │
             └─ falla CONCEPTUAL (ambigüedad / criterio imposible) ─┘─► ESCALA
   ESCALA = frena de codear · no quema tokens · rutea a /distill o al humano
```

### Contra qué compara (Tests vs Evals — paper)

| # | Oráculo | Quién chequea | Cuándo |
|---|---|---|---|
| 1 | **Tests de los criterios** (parte determinista de `acceptance.md`) | inner loop (agente) | cada iteración |
| 2 | **Constitution / patterns `[given]`** (no-negociables) | inner loop (agente) | cada iteración |
| 3 | **Evals** (parte NO determinista: trajectory, calidad, hallucination) | `/verify` (externo) | al cerrar feature |

### Condición de corte

- ✅ **DONE:** todos los checks locales de los criterios de la task pasan **y** cero
  violaciones de constitution → fila de `coverage.md` pasa a `implemented (pending verify)`.
- ⛔ **ESCALA:** budget agotado, **o** no-progreso (misma falla 2 veces), **o** falla
  clasificada como *gap de spec*. El agente para y devuelve el control. Materializa el
  **80% problem**: hace el 80% mecánico y reserva el 20% conceptual para el humano.

**Budget por defecto (tuneable en `constitution`):** escalar tras 2 fallas idénticas o
3 intentos totales por task.

El inner loop **nunca** llama a UAT ni a evals no-deterministas — los deja para el gate.

---

## 8. Test-first enforced (contrato rojo como gate de fase)

El enforcement vive en una **transición del workflow —una vez por feature, antes de
codear— no en un hook por commit.** El dev nunca choca una pared al commitear; simplemente
no obtiene tasks de implementación sin el contrato de tests rojo.

**BDD:** cada criterio de aceptación se escribe como escenario Given/When/Then, y ese
escenario *es* el test.

```gherkin
Criterio: token de tarjeta < 300ms
  Given una tarjeta válida
  When el usuario guarda con 1 tap
  Then el token se retorna en < 300ms
  And la respuesta es PCI-compliant   # ← inyectado [given] por constitution
```

**El gate (`/contract`, comando separado):**

```
 /distill ──► acceptance.md (escenarios BDD) + coverage.md
 /contract ──► genera tests (determinista) + eval cases (no-determinista)
     │          y CORRE el suite → debe estar 🔴 RED (prueba que el test es real)
 /tasks ──► GATE: rechaza emitir tasks de implementación si algún criterio
     │       determinista NO tiene test ligado en estado 🔴 RED
 (implement) ──► inner loop dirige 🔴 RED → 🟢 GREEN
```

El gate de `/tasks` es **machine-checkable, no discrecional**: recorre `coverage.md` y
para cada fila determinista exige `test_ligado != null AND estado == RED`. Sin eso, no hay
tasks de implementación.

**Simétrico para lo no-determinista:** los criterios no unit-testeables generan **eval
cases** en `evals/cases/` también antes de implementar. El gate es "contract-first", no
solo "test-first".

### coverage.md como máquina de estados del criterio

| Criterio | Escenario/Test | Estado |
|---|---|---|
| token < 300ms | `card_token.feature` | 🔴 red → 🟢 green → ✅ uat |
| audit-log `[given]` | `audit.feature` | 🔴 red |
| ↑ conversión (no-determ.) | `eval/conversion.yaml` | 📋 case presente |

Regla: una fila no puede pasar a `implement` sin salir de "sin contrato"; no puede pasar a
`done` sin estar 🟢; no cierra sin ✅ en `/uat`. El agente lo chequea en cada transición de
comando — cero hooks de commit.

---

## 9. La capa de verificación (el norte)

### 9.1 Rubric (`evals/rubric.md`)

*"An eval without a clear rubric measures nothing."* Cinco dimensiones, cada una con
escala y umbral explícito:

| Dimensión | Qué mide | Tipo | Puntuación | Umbral |
|---|---|---|---|---|
| **Task success** | ¿el artefacto cumple los criterios? | determinista | tests green / total criterios determ. | **100%** (no-negociable) |
| **Tool use quality** | ¿usó las tools correctas, bien? | trajectory | LM judge + checks vs `tasks.md` | ≥ umbral def. |
| **Trajectory compliance** | ¿siguió el flujo? ¿saltó verificación? | trajectory | LM judge sobre la traza | sin pasos saltados |
| **Hallucination** | ¿deps/APIs inventadas? | mixto | check de imports reales + judge | **0 alucinaciones** |
| **Response quality** | criterios no-deterministas | no-determ. | eval cases + LM judge vs `acceptance` | ≥ umbral def. |

*"A fluent output that skipped its verification steps is a more dangerous failure than one
with a visible error."* → **Trajectory compliance** pesa igual que Task success.

### 9.2 Verification-report (`verification/verification-report.md`)

Estructura fija, emitida en `/verify` y completada en `/uat`; cada sección trazable a
`coverage.md`:

```markdown
# Verification Report — <feature> @ <commit/ref>
spec: <spec.md vN>   ·   fecha   ·   constitution: base vX + proyecto vY

## 1. Coverage snapshot        (copiado de coverage.md)
## 2. Output eval (BUILD)      ← determinista: test → pass/fail | Task success: N/N
## 3. Trajectory eval          ← LM judge: tool use, pasos saltados, hallucination
## 4. UAT                      ← agregado por /uat, contra acceptance.md (revela gaps de producto)
## 5. Verdicto                 ← BUILD / TRAJECTORY / UAT + gaps ruteados
```

### 9.3 Condición de cierre del feature (AND estricto)

```
   feature "DONE"  ⟺  BUILD ✅  AND  TRAJECTORY ✅  AND  UAT ✅  AND  coverage 100%
```

- **BUILD** (output): binario, no-negociable — 100% de criterios deterministas en 🟢.
- **TRAJECTORY**: rubric con LM judge; falla si saltó verificación o usó mal las tools,
  aunque el build pase.
- **UAT**: valida contra el *objetivo*, no el spec. Único que revela **gaps de producto**
  y rutea a `/distill`.

---

## 10. Guardrails, hooks y CI (el mínimo no-molesto)

El enforcement real vive en el workflow. Los hooks son la última capa fina. Tres
mecanismos, del más grueso al más fino:

```
 1. CONSTITUTION (declarativo)   → no-negociables. Los aplica el AGENTE.
 2. WORKFLOW GATES (determinista) → gate rojo de /contract, máquina de estados de
                                    coverage.md, cierre AND-estricto.  ◄── 90% del enforcement.
 3. HOOKS (ejecutable, fino)      → solo lo baratísimo e irreversible. Opt-in.
```

### 10.1 Hooks (`.claude/settings.json`)

Un solo hook, por defecto **advisory (avisa, no bloquea)**:

| Hook | Punto | Default | Por qué |
|---|---|---|---|
| **secret-scan** | PreToolUse en git commit | avisa (no bloquea) | Único caso irreversible con check trivial. Promovible a bloqueante con un flag. |

### 10.2 CI (opcional, advisory por defecto)

```
 PR abierto ──► CI corre /verify (evals + trajectory) ──► postea verification-report
                                                          como COMENTARIO del PR
                        (advisory · NO required check por defecto)
```

- **Por defecto:** el reporte se postea como comentario; informa, no bloquea el merge.
- **Palanca de governance:** un equipo/leader puede promover el check a *required* con un
  toggle — el *"Require eval coverage as a precondition for any agent shipping into a
  shared workflow"* del paper. Decisión explícita de gobernanza, no fricción por defecto.

### 10.3 Observability

Cada `/verify` deja un `verification-report.md` versionado en `verification/reports/`. Esa
*es* la capa de observability (*"traces what the agent actually did"*) — rastro auditable
de qué se construyó y cómo, más token/latency si el runner los captura. Sin infra extra.

---

## 11. Fuera de alcance (YAGNI)

- Scaffolding de código de app (el harness es agnóstico).
- Soporte multi-agente (GEMINI.md / AGENTS.md portable) — Claude Code first.
- Herencia de `base/` vía submodule o paquete publicado — se usa vendored.
- Hooks bloqueantes por commit/push más allá del secret-scan advisory.
- Runner de evals productivo completo — se entrega la estructura + plantilla; el runner
  ejecutable concreto depende del stack del proyecto que adopte el harness.

---

## 12. Riesgos y mitigaciones

| Riesgo | Mitigación |
|---|---|
| El inner loop entra en bucle infinito (token burn) | Budget de intentos + detección de no-progreso → ESCALA |
| El agente "aparenta" verificar y salta pasos | Trajectory compliance pesa igual que build; el reporte deja traza |
| La constitution `base/` se desincroniza entre proyectos | Vendored + `update-checklist.md`; sincronización explícita al copiar |
| Test-first se vuelve fricción | El gate corre una vez por feature (no por commit); enforcement en transición de workflow |
| Gaps de producto no detectados | UAT valida contra el *objetivo*, no el spec; rutea de vuelta a `/distill` |
