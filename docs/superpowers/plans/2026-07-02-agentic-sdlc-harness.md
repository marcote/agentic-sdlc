# Agentic SDLC Harness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold an agnostic, Claude-Code-first "harness" template repo that enforces spec-driven, verification-first (UAT) development with an inheritable constitution and test-first workflow gates.

**Architecture:** The repo is a template (no app code). It provides: static context (`CLAUDE.md` + `memory/constitution/`), dynamic context (`.claude/skills/`), 7 slash-commands, feature templates (`specs/_template/`), an evaluation rubric + verification report templates, a minimal advisory `secret-scan` hook, an advisory CI workflow, and docs. The template verifies its own structural integrity with a dependency-free bash test suite (`tests/run.sh`), which is also the CI check.

**Tech Stack:** Markdown (skills/commands/templates/docs), JSON (`.claude/settings.json`), POSIX/Bash (hook + test suite), GitHub Actions YAML (advisory CI). No language runtime or package manager — the harness is stack-agnostic.

## Global Constraints

These apply to EVERY task (copied verbatim from the spec):

- **Claude Code first.** Instruction files are `CLAUDE.md` + `.claude/`. No `AGENTS.md`/`GEMINI.md`.
- **Agnostic.** No application code, no stack-specific scaffolding, no language runtime dependency. Tests use only `bash` + coreutils (`grep`, `git`).
- **On-demand verification.** `/verify` and `/uat` are invoked by the dev/agent when closing a unit of work — never as blocking per-commit hooks.
- **No blocking commit hooks by default.** The only hook is `secret-scan`, and it is **advisory** (warns, exits 0) unless `SECRET_SCAN_BLOCK=1`.
- **Constitution inheritance = vendored + convention.** `memory/constitution/base/` is copied with the template; `constitution.md` declares `extends: base`.
- **Test-first enforced by the workflow, not by the dev.** A criterion cannot reach implementation without a linked test in `🔴 RED` state (`/contract` gate, checked in `/tasks`).
- **Feature close condition (AND-strict):** `BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%`.
- **Naming:** feature folders `specs/<NNN-feature>/` (kebab-case, zero-padded NNN); the canonical blank feature lives at `specs/_template/`.
- **Coverage state legend (used verbatim):** `🔴 red` → `🟢 green` → `✅ uat` for deterministic; `📋 case` for non-deterministic; `[given]` marks constitution-inherited rows; `deferred` marks justified gaps.

**Reference:** the approved design at `docs/superpowers/specs/2026-07-02-agentic-sdlc-harness-design.md`. When a task says "see design §N", read that section for rationale.

---

### Task 1: Self-verification test harness + repo skeleton

**Files:**
- Create: `tests/lib.sh`
- Create: `tests/run.sh`
- Create: `tests/check_00_skeleton.sh`
- Create: `.gitkeep` files for empty dirs (see Step 3)

**Interfaces:**
- Produces (used by all later tasks' test files): shell helpers `assert_file <path>`, `assert_dir <path>`, `assert_contains <path> <ERE>`, and `summary` (exits non-zero if any assertion failed). Later tasks add `tests/check_NN_*.sh` files that source nothing themselves — `run.sh` sources `lib.sh` once, then sources every `check_*.sh` in order.

- [ ] **Step 1: Write the failing structure test**

Create `tests/check_00_skeleton.sh`:

```bash
# Sourced by tests/run.sh (lib.sh already loaded). Verifies top-level layout.
assert_dir memory/constitution/base/patterns
assert_dir specs/_template
assert_dir evals/cases
assert_dir verification/reports
assert_dir .claude/skills
assert_dir .claude/commands
assert_dir .claude/hooks
assert_dir docs
```

- [ ] **Step 2: Create the test library and runner**

Create `tests/lib.sh`:

```bash
# Dependency-free assertion helpers. No frameworks.
FAILS=0; PASSES=0
_pass(){ PASSES=$((PASSES+1)); echo "  PASS: $1"; }
_fail(){ FAILS=$((FAILS+1)); echo "  FAIL: $1"; }
assert_file(){ if [ -f "$1" ]; then _pass "file $1"; else _fail "missing file $1"; fi; }
assert_dir(){ if [ -d "$1" ]; then _pass "dir $1"; else _fail "missing dir $1"; fi; }
assert_contains(){ if grep -qE "$2" "$1" 2>/dev/null; then _pass "$1 =~ /$2/"; else _fail "$1 missing /$2/"; fi; }
summary(){ echo "---"; echo "TOTAL PASS=$PASSES FAIL=$FAILS"; [ "$FAILS" -eq 0 ]; }
```

Create `tests/run.sh`:

```bash
#!/usr/bin/env bash
set -u
cd "$(dirname "$0")/.."
. tests/lib.sh
for t in tests/check_*.sh; do
  [ -f "$t" ] || continue
  echo "== $t =="
  . "$t"
done
summary
```

- [ ] **Step 3: Run the test to verify it fails**

Run: `chmod +x tests/run.sh && bash tests/run.sh`
Expected: FAIL lines for the missing dirs; final line `TOTAL PASS=0 FAIL=8`; exit code non-zero.

- [ ] **Step 4: Create the skeleton dirs to make it pass**

Run:
```bash
mkdir -p memory/constitution/base/patterns specs/_template evals/cases \
  verification/reports .claude/skills .claude/commands .claude/hooks docs
touch evals/cases/.gitkeep verification/reports/.gitkeep
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; final line `TOTAL PASS=8 FAIL=0`; exit code 0.

- [ ] **Step 6: Commit**

```bash
git add tests .gitkeep evals/cases/.gitkeep verification/reports/.gitkeep
git add -A
git commit -m "feat: self-verification test harness + repo skeleton"
```

---

### Task 2: Constitution foundation (base + project + CLAUDE.md)

**Files:**
- Create: `CLAUDE.md`
- Create: `memory/constitution/base/principles.md`
- Create: `memory/constitution/base/README.md`
- Create: `memory/constitution/base/patterns/audit-logging.md`
- Create: `memory/constitution/base/patterns/rate-limiting.md`
- Create: `memory/constitution/base/patterns/idempotency.md`
- Create: `memory/constitution/constitution.md`
- Create: `memory/constitution/update-checklist.md`
- Create: `tests/check_10_constitution.sh`

**Interfaces:**
- Consumes: assertion helpers from Task 1.
- Produces: the pattern file contract — each `patterns/*.md` MUST contain a line beginning `**Criterios inyectados:**` and a `[given]` token, because `/distill` (Task 6) parses these to inject rows into `coverage.md`.

- [ ] **Step 1: Write the failing test**

Create `tests/check_10_constitution.sh`:

```bash
assert_file CLAUDE.md
assert_contains CLAUDE.md "memory/constitution"
assert_file memory/constitution/base/principles.md
assert_file memory/constitution/base/README.md
assert_file memory/constitution/constitution.md
assert_contains memory/constitution/constitution.md "extends: base"
assert_file memory/constitution/update-checklist.md
for p in audit-logging rate-limiting idempotency; do
  assert_file "memory/constitution/base/patterns/$p.md"
  assert_contains "memory/constitution/base/patterns/$p.md" "Criterios inyectados"
  assert_contains "memory/constitution/base/patterns/$p.md" "\[given\]"
done
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create `CLAUDE.md`**

```markdown
# Agentic SDLC Harness

Plantilla agnóstica para desarrollo agéntico disciplinado (Claude Code first).
No contiene código de app: provee el harness que rodea al modelo.

## Stack
Agnóstico. Se copia encima de cualquier proyecto.

## Convenciones
- Un feature = un folder `specs/<NNN-feature>/` (kebab-case, NNN zero-padded).
- Los criterios de aceptación se escriben en BDD (Given/When/Then).
- `coverage.md` es la fuente de verdad del estado de cada criterio.

## Hard rules (detalle en memory/constitution/)
- Ningún criterio determinista avanza a implementación sin test en 🔴 RED (`/contract`).
- Un feature cierra solo con: BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
- La verificación es on-demand (`/verify`, `/uat`); no hay hooks bloqueantes por commit.
- Agregá una regla a memory/constitution/ cada vez que cometas un error repetible.

## Workflow
`/constitution` → (brief) → `/distill` → `/plan` → `/contract` → `/tasks` → implement → `/verify` → `/uat`
Ver `docs/workflow.md`.

## Punteros
- Principios no-negociables: `memory/constitution/`
- Skills (dynamic context): `.claude/skills/` (distill, verify, uat)
- Plantillas de feature: `specs/_template/`
- Rubric de evaluación: `evals/rubric.md`
- Reportes de verificación (observability): `verification/reports/`
```

- [ ] **Step 4: Create the base constitution files**

`memory/constitution/base/principles.md`:

```markdown
# Constitution — Base Principles (heredado, no-negociable)

Estos principios son la capa más estable del static context. Todo spec, plan y
verificación debe cumplirlos. Se heredan vía `extends: base`.

1. **Verificabilidad.** Todo requerimiento se expresa como criterio de aceptación
   medible (BDD). Lo que no se puede verificar, no se construye.
2. **Test-first.** La porción determinista de cada criterio existe como test en 🔴 RED
   antes de escribir implementación (gate de `/contract`).
3. **Trazabilidad total.** Todo objetivo del brief llega a un criterio; todo criterio
   mapea a un eval o paso de UAT. Filas huérfanas = gap que bloquea el freeze del spec.
4. **Productividad primero.** La verificación es on-demand; nada bloquea commit/push.
5. **Rastro auditable.** Cada verificación produce un reporte versionado.
6. **Seguridad por defecto.** Ningún secreto en el repo; los patterns heredados
   (abajo) aplican salvo override justificado en el `constitution.md` del proyecto.
```

`memory/constitution/base/README.md`:

```markdown
# Cómo funciona la herencia de la constitution

- `base/` es un asset compartido **vendored**: se copia con el template.
- El `constitution.md` del proyecto declara `extends: base` y agrega deltas/overrides.
- Cada archivo en `base/patterns/` es una "given practice": además de un principio en
  prosa, declara **criterios de aceptación inyectados** que `/distill` agrega
  automáticamente como filas `[given]` en `coverage.md` de cada feature aplicable.
- Para actualizar la base: editá `base/`, seguí `../update-checklist.md`, y re-copiá
  a los proyectos que la heredan (sincronización explícita, sin submodules).
```

`memory/constitution/base/patterns/audit-logging.md`:

```markdown
# Pattern: Audit Logging (given practice)

**Principio:** toda operación que escribe estado deja rastro auditable.
**Aplica a:** cualquier feature con endpoints/acciones de escritura.
**Criterios inyectados:**
- `[given]` cada operación de escritura emite audit-log con `actor` + `timestamp` + `entidad`.
  → mapea a `eval: audit-trail`.
```

`memory/constitution/base/patterns/rate-limiting.md`:

```markdown
# Pattern: Rate Limiting (given practice)

**Principio:** toda superficie expuesta a red tiene límite de tasa.
**Aplica a:** cualquier feature con endpoints públicos o semi-públicos.
**Criterios inyectados:**
- `[given]` cada endpoint expuesto responde `429` al exceder el límite configurado.
  → mapea a `eval: rate-limit`.
```

`memory/constitution/base/patterns/idempotency.md`:

```markdown
# Pattern: Idempotency (given practice)

**Principio:** las operaciones de escritura repetibles son idempotentes.
**Aplica a:** cualquier feature con reintentos, webhooks o pagos.
**Criterios inyectados:**
- `[given]` reenviar la misma request con igual `idempotency-key` no duplica el efecto.
  → mapea a `eval: idempotency`.
```

- [ ] **Step 5: Create the project constitution + update checklist**

`memory/constitution/constitution.md`:

```markdown
---
extends: base
---

# Constitution — Proyecto

Extiende `base` (ver `base/principles.md`). Agregá aquí principios y overrides
específicos del proyecto. Overridear un `base/pattern` requiere justificación explícita.

## Deltas del proyecto
_(vacío — completar por proyecto)_

## Overrides de patterns heredados
_(ninguno — para desactivar un pattern, listalo aquí con su justificación)_

## Presupuesto del inner loop (tuneable)
- Escalar al humano tras **2 fallas idénticas** o **3 intentos totales** por task.
```

`memory/constitution/update-checklist.md`:

```markdown
# Checklist para actualizar la constitution

Cuando el agente comete un error repetible o cambia una regla:

- [ ] ¿Es un principio universal? → `base/principles.md`. ¿O una práctica con criterios? → nuevo `base/patterns/<x>.md`.
- [ ] Si es un pattern: incluí la sección `**Criterios inyectados:**` con al menos un `[given]`.
- [ ] ¿Es específico del proyecto? → `constitution.md` (deltas/overrides).
- [ ] Actualizá la fecha/razón en el commit.
- [ ] Re-copiá `base/` a los proyectos que la heredan (vendored).
```

- [ ] **Step 6: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS (Task 1 + Task 2 assertions); `FAIL=0`; exit 0.

- [ ] **Step 7: Commit**

```bash
git add -A
git commit -m "feat: constitution foundation (base patterns + project + CLAUDE.md)"
```

---

### Task 3: Feature templates (`specs/_template/`)

**Files:**
- Create: `specs/_template/brief.md`
- Create: `specs/_template/spec.md`
- Create: `specs/_template/acceptance.md`
- Create: `specs/_template/coverage.md`
- Create: `specs/_template/plan.md`
- Create: `specs/_template/tasks.md`
- Create: `tests/check_20_spec_templates.sh`

**Interfaces:**
- Consumes: helpers from Task 1; coverage state legend from Global Constraints.
- Produces: `coverage.md` MUST contain the state legend tokens and a markdown table with columns `Objetivo | Requerimiento | Criterio | Origen | Estado`; `acceptance.md` MUST contain a `Given`/`When`/`Then` block. `/contract` and `/tasks` (Task 5) and `/distill` (Task 6) parse these.

- [ ] **Step 1: Write the failing test**

Create `tests/check_20_spec_templates.sh`:

```bash
for f in brief spec acceptance coverage plan tasks; do
  assert_file "specs/_template/$f.md"
done
assert_contains specs/_template/acceptance.md "Given"
assert_contains specs/_template/acceptance.md "When"
assert_contains specs/_template/acceptance.md "Then"
assert_contains specs/_template/coverage.md "Estado"
assert_contains specs/_template/coverage.md "🔴"
assert_contains specs/_template/coverage.md "\[given\]"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new file/content assertions; exit non-zero.

- [ ] **Step 3: Create `brief.md`, `spec.md`, `acceptance.md`**

`specs/_template/brief.md`:

```markdown
# Brief — <feature>

> ORIGEN del desarrollo. Describe el OBJETIVO y el POR QUÉ, no la solución.

## Objetivo de producto
_(qué problema de negocio/usuario resolvemos)_

## Por qué / motivación
_(por qué ahora, qué pasa si no lo hacemos)_

## Métricas de éxito
_(medibles: p.ej. "↑ conversión móvil 5%", "latencia p95 < 300ms")_

## Fuera de alcance
_(qué explícitamente NO hace)_
```

`specs/_template/spec.md`:

```markdown
# Spec — <feature>

> QUÉ se construye. Producido por `/distill` a partir de `brief.md`. Se congela
> cuando `coverage.md` no tiene filas huérfanas.

## Requerimientos funcionales
1. _(requerimiento)_

## User stories
- Como _<rol>_ quiero _<capacidad>_ para _<beneficio>_.

## Edge cases (80% problem)
- _(casos que el brief no cubre — expandidos en el loop de distilación)_

## Preguntas abiertas / deferred
- _(ambigüedades resueltas o diferidas con justificación)_
```

`specs/_template/acceptance.md`:

```markdown
# Acceptance — <feature>

> Criterios de aceptación medibles en BDD. CADA criterio ES simultáneamente el
> eval y el paso de UAT. La porción determinista se materializa como test en `/contract`.

## Criterio: <nombre>  (determinista)
```gherkin
Given <precondición>
When <acción>
Then <resultado observable y medible>
```

## Criterio: <nombre>  (no-determinista → eval case)
_(comportamiento/calidad que no se unit-testea; genera un case en `evals/cases/`)_
```

- [ ] **Step 4: Create `coverage.md`, `plan.md`, `tasks.md`**

`specs/_template/coverage.md`:

```markdown
# Coverage — <feature>

> Matriz de trazabilidad = fuente de verdad del estado de cada criterio y detector de
> gaps. Regla: todo objetivo → un criterio; todo criterio → un eval/UAT. Fila huérfana = gap.

**Leyenda de estado:** `sin contrato` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (no-determinista) · `[given]` (heredado de constitution) · `deferred` (gap justificado)

| Objetivo (brief) | Requerimiento (spec) | Criterio (acceptance) | Origen | Test/Eval ligado | Estado |
|---|---|---|---|---|---|
| _(ej.)_ ↑ conversión | Guardar tarjeta 1-tap | token < 300ms | proyecto | `card_token.feature` | 🔴 red |
| — | (todas las escrituras) | audit-log actor+ts | `[given] base/audit-logging` | `audit.feature` | 🔴 red |
```

`specs/_template/plan.md`:

```markdown
# Plan técnico — <feature>

> CÓMO se construye. Producido por `/plan`. Debe estar grounded en la constitution
> (no puede proponer nada que viole un no-negociable o un pattern `[given]` sin override).

## Decisiones técnicas
- _(decisión + trade-off + qué principio/pattern de la constitution la restringe)_

## Componentes / módulos
- _(unidad → responsabilidad → interfaz)_

## Riesgos
- _(riesgo → mitigación)_
```

`specs/_template/tasks.md`:

```markdown
# Tasks — <feature>

> Descomposición ejecutable. Producido por `/tasks`. GATE: `/tasks` no emite tasks de
> implementación mientras exista un criterio determinista sin test ligado en 🔴 RED.

## Tasks
- [ ] T1: _(unidad testeable)_ — cubre criterios: _(filas de coverage.md)_
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: feature templates (brief/spec/acceptance/coverage/plan/tasks)"
```

---

### Task 4: Evals rubric + verification templates

**Files:**
- Create: `evals/rubric.md`
- Create: `evals/README.md`
- Create: `verification/verification-report.md`
- Create: `verification/uat-checklist.md`
- Create: `verification/code-review-checklist.md`
- Create: `tests/check_30_verification.sh`

**Interfaces:**
- Consumes: helpers from Task 1.
- Produces: `rubric.md` MUST name all five dimensions (`Task success`, `Tool use`, `Trajectory`, `Hallucination`, `Response quality`); `verification-report.md` MUST contain the five section headers (`Coverage snapshot`, `Output eval`, `Trajectory eval`, `UAT`, `Verdicto`). `/verify` and `/uat` (Task 6) fill these.

- [ ] **Step 1: Write the failing test**

Create `tests/check_30_verification.sh`:

```bash
assert_file evals/rubric.md
for d in "Task success" "Tool use" "Trajectory" "Hallucination" "Response quality"; do
  assert_contains evals/rubric.md "$d"
done
assert_file evals/README.md
assert_file verification/verification-report.md
for s in "Coverage snapshot" "Output eval" "Trajectory eval" "UAT" "Verdicto"; do
  assert_contains verification/verification-report.md "$s"
done
assert_file verification/uat-checklist.md
assert_file verification/code-review-checklist.md
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create `evals/rubric.md` and `evals/README.md`**

`evals/rubric.md`:

```markdown
# Eval Rubric

> "An eval without a clear rubric measures nothing." Cinco dimensiones, cada una con
> escala y umbral explícito. Trajectory pesa igual que Task success: un build verde que
> saltó verificación es un FAIL.

| Dimensión | Qué mide | Tipo | Puntuación | Umbral |
|---|---|---|---|---|
| **Task success** | ¿el artefacto cumple los criterios? | determinista | tests green / total criterios determ. | **100%** (no-negociable) |
| **Tool use** quality | ¿usó las tools correctas, bien? | trajectory | LM judge + checks vs `tasks.md` | ≥ umbral |
| **Trajectory** compliance | ¿siguió el flujo? ¿saltó verificación? | trajectory | LM judge sobre la traza | sin pasos saltados |
| **Hallucination** | ¿deps/APIs inventadas? | mixto | check de imports reales + judge | **0** |
| **Response quality** | criterios no-deterministas | no-determ. | eval cases + LM judge vs `acceptance` | ≥ umbral |
```

`evals/README.md`:

```markdown
# Evals

- `rubric.md` — cómo se puntúa (5 dimensiones).
- `cases/` — un case por criterio NO-determinista (formato libre: `.yaml`/`.md`).
  Los cases se crean en `/contract`, ANTES de implementar.

## Runner
El runner ejecutable concreto depende del stack del proyecto que adopte el harness
(fuera de alcance del template). El contrato: un case debe poder puntuarse contra el
`rubric.md` y su resultado alimenta la sección "Trajectory eval" / "Response quality"
del `verification-report.md`.
```

- [ ] **Step 4: Create the three verification templates**

`verification/verification-report.md`:

```markdown
# Verification Report — <feature> @ <commit/ref>

spec: <spec.md vN> · fecha: <YYYY-MM-DD> · constitution: base v<X> + proyecto v<Y>

## 1. Coverage snapshot
_(copiado de coverage.md: criterio → estado → test/eval ligado)_

## 2. Output eval (BUILD)  — determinista, corre en /verify
_(por criterio: test → pass/fail | Task success: N/N = %)_

## 3. Trajectory eval  — no-determinista, LM judge sobre la traza
_(tool use: score/umbral | pasos saltados: … | hallucination: N)_

## 4. UAT  — agregado por /uat, contra acceptance.md
_(escenario BDD → walked → pass/fail → nota; los fallos de UAT son gaps de PRODUCTO → /distill)_

## 5. Verdicto
BUILD: <✅/❌> · TRAJECTORY: <✅/❌> · UAT: <✅/❌> · coverage: <N%>
Cierra ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
Gaps ruteados: _(a /verify=implementación, a /distill=producto)_
```

`verification/uat-checklist.md`:

```markdown
# UAT Checklist — <feature>

> Se recorre en `/uat`, contra `acceptance.md`. El UAT valida contra el OBJETIVO
> (brief), no solo contra el spec — por eso puede revelar gaps de producto.

Por cada criterio de aceptación:
- [ ] Escenario BDD ejecutado tal como está escrito.
- [ ] Resultado observable coincide con el `Then`.
- [ ] ¿El criterio, cumplido, mueve la métrica de éxito del brief? (si no → GAP de producto → `/distill`)
- [ ] Estado actualizado en `coverage.md` (→ ✅ uat).
```

`verification/code-review-checklist.md`:

```markdown
# Code Review Checklist — código generado por IA

> "AI-generated code requires the same or greater scrutiny than human-written code."

- [ ] Imports/dependencias existen y son las correctas (sin paquetes alucinados).
- [ ] Error handling cubre modos de falla realistas, no solo el happy path.
- [ ] No hay secretos hardcodeados.
- [ ] El código cumple los patterns `[given]` aplicables (audit-log, rate-limit, idempotency…).
- [ ] La lógica "que parece correcta" fue verificada contra el criterio, no asumida.
- [ ] Cambios trazables a filas de `coverage.md`.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: eval rubric + verification/UAT/code-review templates"
```

---

### Task 5: Slash commands (7)

**Files:**
- Create: `.claude/commands/constitution.md`
- Create: `.claude/commands/distill.md`
- Create: `.claude/commands/plan.md`
- Create: `.claude/commands/contract.md`
- Create: `.claude/commands/tasks.md`
- Create: `.claude/commands/verify.md`
- Create: `.claude/commands/uat.md`
- Create: `tests/check_40_commands.sh`

**Interfaces:**
- Consumes: helpers from Task 1; skills from Task 6 are referenced by name (`distill`, `verify`, `uat`).
- Produces: each command file MUST start with YAML frontmatter containing a `description:` line. `/contract` and `/tasks` define the test-first gate procedure that the design §8 mandates.

- [ ] **Step 1: Write the failing test**

Create `tests/check_40_commands.sh`:

```bash
for c in constitution distill plan contract tasks verify uat; do
  f=".claude/commands/$c.md"
  assert_file "$f"
  assert_contains "$f" "^description:"
done
assert_contains .claude/commands/tasks.md "RED"
assert_contains .claude/commands/contract.md "RED"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create the four spec-phase commands**

`.claude/commands/constitution.md`:

```markdown
---
description: Crear o actualizar la constitution (base + proyecto). Semilla y filtro del workflow.
---

Leé `memory/constitution/base/principles.md` y `memory/constitution/constitution.md`.
Para crear/actualizar reglas seguí `memory/constitution/update-checklist.md`:
principios universales → `base/principles.md`; prácticas con criterios → `base/patterns/<x>.md`
(con sección `**Criterios inyectados:**` y al menos un `[given]`); específicos del proyecto → `constitution.md`.
```

`.claude/commands/distill.md`:

```markdown
---
description: Destilar brief.md en spec + acceptance + coverage (loop estilo grilling, cubre gaps).
---

Invocá la skill `distill`. Requiere `specs/<feature>/brief.md`. No avances con ambigüedades
abiertas ni con filas huérfanas en `coverage.md`.
```

`.claude/commands/plan.md`:

```markdown
---
description: Producir el plan técnico (plan.md) grounded en la constitution.
---

Con `spec.md` congelado, escribí `specs/<feature>/plan.md`. Cada decisión técnica debe
respetar los no-negociables y los patterns `[given]`; cualquier override requiere
justificación explícita en `memory/constitution/constitution.md`.
```

`.claude/commands/contract.md`:

```markdown
---
description: Generar el contrato de tests (determinista) y eval cases (no-determinista) y probar que está RED.
---

Para cada criterio de `acceptance.md`:
- Determinista → generá el test (BDD) y ligalo en `coverage.md`. CORRÉ el suite: debe estar 🔴 RED
  (prueba que el test es real y el feature no existe). Registrá el test ligado por criterio.
- No-determinista → creá un case en `evals/cases/` (estado 📋).
No marques ninguna fila como lista hasta confirmar el estado RED (deterministas) o case presente.
```

- [ ] **Step 4: Create the decomposition + verification commands**

`.claude/commands/tasks.md`:

```markdown
---
description: Descomponer en tasks ejecutables. GATE test-first — rechaza si falta contrato RED.
---

GATE (machine-checkable, no discrecional): recorré `coverage.md`. Para CADA fila
determinista, exigí `test ligado != vacío AND estado == 🔴 RED`. Si alguna no cumple,
NO emitas tasks de implementación: reportá las filas faltantes y frená.
Solo si el gate pasa, escribí `specs/<feature>/tasks.md` (cada task liga sus filas de coverage).
```

`.claude/commands/verify.md`:

```markdown
---
description: Verificación on-demand — corre output + trajectory eval y emite el verification-report.
---

Invocá la skill `verify`. Genera `verification/reports/<feature>-<ref>.md` a partir de
`verification/verification-report.md`, puntuando contra `evals/rubric.md`.
```

`.claude/commands/uat.md`:

```markdown
---
description: UAT on-demand contra acceptance.md — valida contra el objetivo del brief.
---

Invocá la skill `uat`. Recorré `verification/uat-checklist.md`. Un fallo de UAT es un
gap de PRODUCTO → routeá a `/distill`. Actualizá `coverage.md` (→ ✅ uat) y el reporte.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: 7 slash-commands (constitution/distill/plan/contract/tasks/verify/uat)"
```

---

### Task 6: Skills (distill, verify, uat)

**Files:**
- Create: `.claude/skills/distill/SKILL.md`
- Create: `.claude/skills/verify/SKILL.md`
- Create: `.claude/skills/uat/SKILL.md`
- Create: `tests/check_50_skills.sh`

**Interfaces:**
- Consumes: helpers from Task 1; the templates from Tasks 3-4 (skills read/write those files).
- Produces: each `SKILL.md` MUST start with YAML frontmatter containing `name:` and `description:` (Claude Code skill contract).

- [ ] **Step 1: Write the failing test**

Create `tests/check_50_skills.sh`:

```bash
for s in distill verify uat; do
  f=".claude/skills/$s/SKILL.md"
  assert_file "$f"
  assert_contains "$f" "^name:"
  assert_contains "$f" "^description:"
done
assert_contains .claude/skills/distill/SKILL.md "grilling"
assert_contains .claude/skills/verify/SKILL.md "rubric"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create `distill/SKILL.md`**

```markdown
---
name: distill
description: Destila brief.md en spec + acceptance (BDD) + coverage, cazando gaps estilo grilling. Usar tras escribir el brief de un feature.
---

# Distill

Entrada: `specs/<feature>/brief.md`. Salidas: `spec.md`, `acceptance.md`, `coverage.md`.

## Procedimiento (loop hasta converger)
1. **Sembrar desde la constitution.** Leé `memory/constitution/` (base + proyecto). Por cada
   `base/patterns/*.md` aplicable, inyectá su/s criterio/s `[given]` como filas en `coverage.md`.
2. **Extraer.** Del brief: objetivos, user stories, restricciones, métricas de éxito.
3. **Interrogar (grilling).** Preguntá al humano de a una las ambigüedades. NO avances con
   ambigüedades abiertas. (Inspirate en la skill `grilling` si está disponible.)
4. **Expandir edge cases (80% problem).** Generá los casos que el brief no cubre; cada uno
   entra como fila nueva de `coverage.md` y fuerza un criterio.
5. **Trazar.** Cada objetivo → requerimiento → criterio de aceptación (BDD). Marcá deterministas
   vs no-deterministas.
6. **Chequear cobertura.** Si hay filas huérfanas (objetivo sin criterio, o criterio sin
   eval/UAT), volvé al paso 3. Solo cuando no queden (o estén `deferred` con justificación),
   congelá `spec.md` + `acceptance.md`.
```

- [ ] **Step 4: Create `verify/SKILL.md` and `uat/SKILL.md`**

`.claude/skills/verify/SKILL.md`:

```markdown
---
name: verify
description: Verificación on-demand de un feature. Corre output + trajectory eval y emite el verification-report. Usar al cerrar la implementación de un feature.
---

# Verify

## Procedimiento
1. Copiá `verification/verification-report.md` a `verification/reports/<feature>-<ref>.md`.
2. **Output eval (BUILD):** corré los tests deterministas ligados en `coverage.md`.
   Task success = green/total. Umbral 100% (no-negociable).
3. **Trajectory eval:** puntuá contra `evals/rubric.md` (tool use, pasos saltados,
   hallucination). Un flujo que saltó verificación es FAIL aunque el build pase.
4. Actualizá los estados en `coverage.md` (🔴→🟢) y completá el Verdicto.
5. Si BUILD/TRAJECTORY fallan → gap de IMPLEMENTACIÓN → volvé a implementar.
   NO llames a UAT ni a evals no-deterministas de cierre desde aquí.
```

`.claude/skills/uat/SKILL.md`:

```markdown
---
name: uat
description: UAT guiado de un feature contra acceptance.md y el objetivo del brief. Usar tras un /verify en verde.
---

# UAT

## Procedimiento
1. Recorré `verification/uat-checklist.md` criterio por criterio contra `acceptance.md`.
2. Preguntá para cada criterio: cumplido, ¿mueve la métrica de éxito del brief?
   Si NO → gap de PRODUCTO → routeá a `/distill` (el spec estaba incompleto).
3. Actualizá `coverage.md` (→ ✅ uat) y la sección UAT + Verdicto del reporte en
   `verification/reports/`.
4. El feature cierra ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: skills (distill/verify/uat)"
```

---

### Task 7: secret-scan hook (TDD) + settings.json

**Files:**
- Create: `.claude/hooks/secret-scan.sh`
- Create: `.claude/settings.json`
- Create: `tests/check_60_secret_scan.sh`

**Interfaces:**
- Consumes: helpers from Task 1.
- Produces: `secret-scan.sh` has a pure, testable mode `--scan-text` (reads stdin; exit 1 if a secret pattern matches, else exit 0). Hook mode (no args) reads the tool-call JSON from stdin, no-ops unless it is a `git commit`, then scans `git diff --cached`; advisory by default (exit 0), blocks (exit 2) only if `SECRET_SCAN_BLOCK=1`.

- [ ] **Step 1: Write the failing behavior test**

Create `tests/check_60_secret_scan.sh`:

```bash
H=.claude/hooks/secret-scan.sh
assert_file "$H"
# --scan-text: secret present → exit 1
if printf 'AKIA1234567890ABCDEF\n' | bash "$H" --scan-text >/dev/null 2>&1; then _fail "AWS key not detected"; else _pass "AWS key detected"; fi
if printf 'BEGIN RSA PRIVATE KEY\n' | bash "$H" --scan-text >/dev/null 2>&1; then _fail "private key not detected"; else _pass "private key detected"; fi
if printf 'password = "hunter2"\n' | bash "$H" --scan-text >/dev/null 2>&1; then _fail "password not detected"; else _pass "password detected"; fi
# --scan-text: clean text → exit 0
if printf 'hello world\n' | bash "$H" --scan-text >/dev/null 2>&1; then _pass "clean text passes"; else _fail "clean text wrongly flagged"; fi
# hook mode: non-commit command → silent exit 0
if printf '{"tool_input":{"command":"ls -la"}}' | bash "$H" >/dev/null 2>&1; then _pass "non-commit no-op"; else _fail "non-commit should exit 0"; fi
assert_file .claude/settings.json
assert_contains .claude/settings.json "secret-scan.sh"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL — file missing / not executable; exit non-zero.

- [ ] **Step 3: Implement `secret-scan.sh`**

```bash
#!/usr/bin/env bash
# Advisory secret scanner. Two modes:
#   --scan-text : read stdin, exit 1 if a secret pattern is found (pure, testable).
#   (no args)   : Claude Code PreToolUse hook. No-op unless the tool call is a git commit.
set -u

PATTERNS='(AKIA[0-9A-Z]{16})|(BEGIN [A-Z ]*PRIVATE KEY)|([Pp]assword[[:space:]]*=[[:space:]]*["'\''][^"'\'']+["'\''])|([Aa][Pp][Ii][_-]?[Kk][Ee][Yy][[:space:]]*[=:])'

scan_text(){ grep -qE "$PATTERNS"; }

if [ "${1:-}" = "--scan-text" ]; then
  if scan_text; then exit 1; else exit 0; fi
fi

# Hook mode: stdin is the tool-call JSON. Only act on git commit.
INPUT="$(cat)"
case "$INPUT" in
  *"git commit"*) : ;;
  *) exit 0 ;;                       # not a commit → silent, zero friction
esac

if git diff --cached 2>/dev/null | scan_text; then
  echo "secret-scan: possible secret in staged changes." >&2
  if [ "${SECRET_SCAN_BLOCK:-0}" = "1" ]; then exit 2; fi   # block only when opted-in
fi
exit 0                              # advisory by default
```

- [ ] **Step 4: Make it executable and create `settings.json`**

Run: `chmod +x .claude/hooks/secret-scan.sh`

`.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": ".claude/hooks/secret-scan.sh" }
        ]
      }
    ]
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS including the 5 secret-scan behavior assertions; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: advisory secret-scan hook (TDD) + settings.json"
```

---

### Task 8: Docs, README, and advisory CI

**Files:**
- Create: `docs/factory-model.md`
- Create: `docs/workflow.md`
- Create: `README.md`
- Create: `.github/workflows/verify.yml`
- Create: `tests/check_70_docs_ci.sh`

**Interfaces:**
- Consumes: helpers from Task 1.
- Produces: nothing consumed by later tasks (final task). CI runs `bash tests/run.sh` as an advisory check.

- [ ] **Step 1: Write the failing test**

Create `tests/check_70_docs_ci.sh`:

```bash
assert_file docs/factory-model.md
assert_file docs/workflow.md
assert_file README.md
assert_contains README.md "constitution"
assert_contains README.md "coverage"
assert_file .github/workflows/verify.yml
assert_contains .github/workflows/verify.yml "tests/run.sh"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash tests/run.sh`
Expected: FAIL for the new assertions; exit non-zero.

- [ ] **Step 3: Create `docs/factory-model.md` and `docs/workflow.md`**

`docs/factory-model.md`:

```markdown
# El Factory Model

El output primario del desarrollador no es código: es el SISTEMA que produce código.
El dev define specs y guardrails (constitution); el agente produce; la verificación valida.

- **Zona del developer:** define specs → diseña guardrails (constitution) → revisa/aprueba.
- **Piso de fábrica (agente):** planning → coding → tests & verification → output verificado.
- **Guardrails transversales:** la constitution (declarativa) + gates de workflow.

`Agent = Model + Harness`. Este repo ES el harness: instrucciones, tools, skills,
guardrails, feedback loops y observability alrededor del modelo.
```

`docs/workflow.md`:

```markdown
# Workflow end-to-end

```
/constitution → (brief.md) → /distill → /plan → /contract → /tasks → implement → /verify → /uat
```

| Comando | Entrada | Salida | Verificación |
|---|---|---|---|
| `/constitution` | — | `memory/constitution/` | semilla + filtro |
| (intake) | objetivo | `brief.md` | métricas de éxito |
| `/distill` | `brief.md` | `spec` + `acceptance` + `coverage` | loop grilling, cero filas huérfanas |
| `/plan` | `spec` | `plan.md` | grounded en constitution |
| `/contract` | `acceptance` | tests 🔴 + eval cases 📋 | prueba que está RED |
| `/tasks` | `coverage` | `tasks.md` | GATE: rechaza si falta contrato RED |
| implement | `tasks` | código | inner loop 🔴→🟢 (budget → ESCALA) |
| `/verify` | código | `verification/reports/…` | output + trajectory eval |
| `/uat` | reporte | reporte completo | contra objetivo; gap → `/distill` |

## Tres loops
1. **Grilling** (en `/distill`): cierra gaps de especificación antes de codear.
2. **Inner loop** (implementación, por task): auto-corrige 🔴→🟢; escala al humano tras
   2 fallas idénticas o 3 intentos (tuneable en la constitution).
3. **Feedback** (`/verify`+`/uat`): fallo de verify → implementación; fallo de UAT → producto → `/distill`.

## Cierre
`feature DONE ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%`.
```

- [ ] **Step 4: Create `README.md` and the CI workflow**

`README.md`:

```markdown
# Agentic SDLC Harness

Plantilla agnóstica (Claude Code first) para desarrollo agéntico disciplinado, con
verificación/UAT como norte. Basada en el whitepaper de Google *"The New SDLC With Vibe
Coding"* y en el concepto de *constitution* de Spec Kit.

## El loop de un vistazo
`/constitution → brief → /distill → /plan → /contract → /tasks → implement → /verify → /uat`

## Estructura
- `CLAUDE.md` — static context (stack, hard rules, workflow).
- `memory/constitution/` — principios no-negociables (base heredable + proyecto).
- `specs/_template/` — plantilla de feature (brief/spec/acceptance/coverage/plan/tasks).
- `evals/` — rubric de 5 dimensiones + cases no-deterministas.
- `verification/` — report, UAT y code-review checklists + `reports/` (observability).
- `.claude/` — skills (distill/verify/uat), 7 commands, hook advisory, settings.
- `docs/` — factory-model y workflow.

## Empezar un feature
1. `cp -r specs/_template specs/001-mi-feature` y escribí el `brief.md`.
2. `/distill` → `/plan` → `/contract` → `/tasks` → implementar → `/verify` → `/uat`.
3. `coverage.md` es tu fuente de verdad del estado.

## Verificar el harness
`bash tests/run.sh` — el template se auto-verifica (estructura + hook). También corre en CI.

## Principios
Productividad primero (verificación on-demand, sin hooks bloqueantes por commit),
intent > syntax, la constitution es código, todo verificable deja rastro.
```

`.github/workflows/verify.yml`:

```yaml
name: verify
on: [pull_request]

# Advisory por defecto: este check puede fallar (X roja) sin bloquear el merge.
# Para volverlo bloqueante, hacelo "required" en Branch protection (decisión de gobernanza).
jobs:
  self-verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Harness self-verification
        run: bash tests/run.sh
      # Placeholder (agent-driven /verify en CI): postear verification-report como comentario
      # del PR queda a criterio del proyecto — depende del stack y del runner de evals.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash tests/run.sh`
Expected: all PASS across every `check_*.sh`; `FAIL=0`; exit 0.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "feat: docs (factory-model/workflow), README, advisory CI"
```

---

## Self-Review

**1. Spec coverage** (design §→ task):
- §2 principios + mapeo → Task 2 (`CLAUDE.md`, principles), Task 8 (docs).
- §3 estructura de directorios → Tasks 1-8 (cada dir/archivo creado y aserido).
- §4 constitution heredable (base + patterns `[given]`) → Task 2.
- §5 capa originante (brief→spec→acceptance) + coverage + grilling → Tasks 3, 6 (distill).
- §6 workflow 7 comandos + 3 loops → Task 5 (commands), Task 8 (workflow.md).
- §7 inner loop + condición de corte → Task 2 (budget en constitution), Task 8 (workflow.md), Task 6 (verify/uat no-cierre-desde-inner).
- §8 test-first gate (contract RED, /tasks gate) → Task 5 (contract.md, tasks.md).
- §9 verificación (rubric 5 dim, report, AND-strict) → Task 4.
- §10 guardrails/hooks/CI (secret-scan advisory, CI advisory) → Task 7, Task 8.
- §11 fuera de alcance → respetado (sin app code, sin submodule, sin runner productivo).
- §12 riesgos → mitigaciones presentes (budget/ESCALA, trajectory peso, vendored, gate por fase).

No gaps.

**2. Placeholder scan:** Los `<feature>`, `<ref>`, `_(completar)_` dentro de los archivos son contenido de PLANTILLA intencional (el template debe tener campos a completar), no placeholders del plan. Cada Step del plan contiene el contenido/código real. Sin `TBD`/`TODO`/`implement later` en instrucciones del plan.

**3. Type/consistency check:**
- Helpers `assert_file`/`assert_dir`/`assert_contains`/`summary` definidos en Task 1 y usados con la misma firma en todos los `check_*.sh`.
- `secret-scan.sh --scan-text` (Task 7) coincide entre test y implementación.
- Tokens de estado de coverage (`🔴`/`🟢`/`✅`/`📋`/`[given]`) consistentes entre §Global Constraints, Task 3 (coverage.md), Task 5 (commands), Task 6 (skills).
- Nombres de skills (`distill`/`verify`/`uat`) consistentes entre Task 5 (commands que las invocan) y Task 6 (SKILL.md).
- Secciones del report (`Coverage snapshot`/`Output eval`/`Trajectory eval`/`UAT`/`Verdicto`) consistentes entre Task 4 (template) y su test.
