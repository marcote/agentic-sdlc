# WoW Self-Validation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dar al harness la capacidad de autovalidar su propia Way of Working: un retro que cierra la predicción medible de `/align` (columna align↔retro), enforcement determinista en CI, y un rollup agregado — todo dogfooded construyéndolo con la propia disciplina test-first del harness.

**Architecture:** Un artefacto `retro.md` por feature (dos caras: Misión cierra `alignment.md`, Método deriva señales del WoW de artefactos). El contrato DONE se extiende con `∧ retro ✅`. `tests/check_90_retro.sh` lo enforcea en CI (detecta "cerrado" por veredicto DONE en `verification/reports/`, regla uniforme sin hardcode). `/retro` (skill+comando) produce el retro con orden anti-teatro `derivar→auto-desafiar→escribir`; `/wow-report` (skill+comando) agrega el ledger en `verification/wow-report.md`.

**Tech Stack:** Markdown (skills/comandos/templates/docs) + Bash POSIX (checks, estilo `tests/lib.sh`, dependency-free, sin frameworks). El "test" de cada cambio es una aserción en `tests/check_*.sh` corrida vía `tests/run.sh` — esto ES la disciplina RED→GREEN del harness aplicada a sí mismo.

## Global Constraints

- **Dependency-free:** los checks usan solo `tests/lib.sh` (`assert_file`, `assert_dir`, `assert_contains` con `grep -qE`) + Bash/coreutils. Sin frameworks, sin instalar nada.
- **Verificación on-demand, sin hooks bloqueantes por commit:** el diente es CI (`.github/workflows/verify.yml` corre `tests/run.sh`). No agregar hooks de git.
- **Un feature = un folder `specs/<NNN-feature>/`** (kebab-case, NNN zero-padded).
- **Repo-plantilla:** `north-star.md` es placeholder → `/align` es fail-closed y **no corre acá**. La Cara A (Misión) del retro de `003` cierra como `n/a` + razón; la Cara B (Método) es real. Ver el design doc, sección "Constraint: repo-plantilla vs repo-adoptante".
- **Idioma:** todo el contenido nuevo en español rioplatense, consistente con el harness existente.
- **Cada task corre `bash tests/run.sh` y termina en verde antes de commitear.**
- Design doc de referencia: `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.

---

## Fase 1 — Fundación: template de retro + contrato DONE

### Task 1: Template `specs/_template/retro.md` (RED vía check_20)

**Files:**
- Modify: `tests/check_20_spec_templates.sh:1`
- Create: `specs/_template/retro.md`

**Interfaces:**
- Produces: el archivo `specs/_template/retro.md` con los headers `Cara A` / `Cara B` / `Cara C`, la columna `Evidencia`, y el marcador `deriv` — que las Tasks 3 y 5 asumen presentes.

- [ ] **Step 1: Escribir la aserción que falla** — agregar `retro` al loop de templates en `tests/check_20_spec_templates.sh`. Cambiar la línea 1:

```bash
for f in brief spec acceptance coverage plan tasks retro; do
```

- [ ] **Step 2: Correr el suite para verlo fallar**

Run: `bash tests/run.sh 2>&1 | grep -E "check_20|retro"`
Expected: FAIL con `missing file specs/_template/retro.md`

- [ ] **Step 3: Crear `specs/_template/retro.md`** con este contenido exacto:

```markdown
# Retro — <feature> @ <commit>

cierra: `specs/<feature>/alignment.md` · `verification/reports/<feature>` · fecha: <YYYY-MM-DD>

> Cierra la predicción medible que abrió `/align` (columna align↔retro). Un feature no
> está DONE hasta que este retro cierra sus tres caras. Diseño:
> `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.

## Cara A — Misión (cierra la predicción de /align)
Fuente: `specs/<feature>/alignment.md` (mapping objetivo→pilar) + `north-star.md` (signal por pilar).

| Pilar (mapping) | Signal predicho | Veredicto | Evidencia (locator OBLIGATORIO) |
|---|---|---|---|
| <pilar-id> | <signal del North Star> | ✅ movió / ❌ no movió / ⏳ aún no observable | <valor/SHA/fila-coverage/URL — no prosa> |

- **Calibración de align:** <los scores pillarFit/scope/mission de alignment.md, ¿acertaron en retrospectiva?>
- **Veredicto de misión:** <confirmed | refuted | pending-observation | n/a>
  - si `confirmed`/`refuted` → la(s) celda(s) Evidencia arriba NO pueden estar vacías.
  - si `pending-observation` → **trigger de re-chequeo:** <cuándo / qué señal mirar>
  - si `n/a` → **razón:** <por qué este feature no cierra contra ningún signal>

## Cara B — Método (valida el WoW) — DERIVADA de artefactos, no redactada
Cada campo trae su marcador `[deriv: …]` — el locator de dónde salió la cifra. Sin locator = inválido.

- **Gaps cazados por /distill:** <N> `[deriv: <coverage.md / git log de distill>]` — <los jugosos>
- **Disciplina RED→GREEN:** <sí / no + excepciones> `[deriv: <historial de estados coverage.md + git>]`
- **Rework post-/verify:** <N> · **post-/uat:** <N> `[deriv: <gaps ruteados en verification/reports/<feature>>]`
- **Escalaciones al humano:** <N> `[deriv: <traza / git>]` — <por qué>
- **Fricción del propio WoW:** <qué del harness estorbó o faltó> (único campo de juicio libre)

## Cara C — Loop (auto-mejora)
- **Reglas candidatas → constitution:** <regla o "ninguna"> (aplicar vía `memory/constitution/update-checklist.md`)
- **Amendments candidatos → North Star:** <ADR propuesto o "ninguno"> (vía `memory/north-star/base/amendment-protocol.md`)
```

- [ ] **Step 4: Correr el suite para verlo pasar**

Run: `bash tests/run.sh 2>&1 | tail -3`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 5: Commit**

```bash
git add tests/check_20_spec_templates.sh specs/_template/retro.md
git commit -m "feat(003): template retro.md (3 caras) + check_20"
```

---

### Task 2: Extender el contrato DONE con `∧ retro ✅`

**Files:**
- Modify: `CLAUDE.md` (hard rule de cierre)
- Modify: `docs/workflow.md` (flujo, tabla, línea de cierre)
- Modify: `verification/verification-report.md` (§5 verdicto)

**Interfaces:**
- Produces: los tres docs mencionan `retro` en el contexto del cierre — que la Task 3 (`check_90`) verifica con `assert_contains`.

- [ ] **Step 1: Editar `CLAUDE.md`** — en la sección "Hard rules", reemplazar la línea de cierre:

De:
```
- Un feature cierra solo con: BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
```
A:
```
- Un feature cierra solo con: BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅ (`/retro` cierra la predicción de `/align`).
```

- [ ] **Step 2: Editar `docs/workflow.md`** — tres cambios.

(a) Línea 4, el flujo, agregar `/retro` al final:
```
/constitution → (brief.md) → /align → /distill → /plan → /contract → /tasks → implement → /verify → /uat → /retro
```

(b) En la tabla de comandos, agregar dos filas después de la de `/uat`:
```
| `/retro` | `alignment.md` + `verification/reports/…` | `retro.md` | cierra la predicción de `/align` (Cara Misión) + deriva señales del WoW (Cara Método) |
| `/wow-report` | todos los `retro.md` | `verification/wow-report.md` | agrega el ledger: drift por pilar, re-chequeos, salud del método, olores de teatro (observa, no gatea) |
```

(c) Línea de cierre (§ Cierre), reemplazar:
```
`feature DONE ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅`.
```

- [ ] **Step 3: Editar `verification/verification-report.md`** — en la sección `## 5. Verdicto`, reemplazar las dos líneas del verdicto:

De:
```
BUILD: <✅/❌> · TRAJECTORY: <✅/❌> · UAT: <✅/❌> · coverage: <N%>
Cierra ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
```
A:
```
BUILD: <✅/❌> · TRAJECTORY: <✅/❌> · UAT: <✅/❌> · coverage: <N%> · retro: <✅/pendiente>
Cierra ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/<feature>/retro.md` (cierra la predicción medible de `/align`).
```

- [ ] **Step 4: Correr el suite (no debe romper check_30, que verifica las secciones del report)**

Run: `bash tests/run.sh 2>&1 | tail -3`
Expected: `TOTAL PASS=… FAIL=0` (check_30 sigue verde: las secciones "Verdicto"/"UAT"/etc. siguen presentes)

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md docs/workflow.md verification/verification-report.md
git commit -m "feat(003): extender contrato DONE con retro ✅ (CLAUDE.md, workflow, report)"
```

---

## Fase 2 — Enforcement determinista: `check_90`

### Task 3: `tests/check_90_retro.sh` — presencia, wiring y cierre por-feature

**Files:**
- Create: `tests/check_90_retro.sh`

**Interfaces:**
- Consumes: `specs/_template/retro.md` (Task 1), el wiring de contrato DONE en docs (Task 2), `tests/lib.sh` (`_pass`/`_fail`/`assert_*`).
- Produces: la gate `retro ✅`. Detecta "cerrado" por reporte con veredicto DONE; regla uniforme sin excepciones hardcodeadas.

- [ ] **Step 1: Crear el check.** `tests/run.sh` lo sourcea automáticamente (glob `check_*.sh`). Contenido exacto de `tests/check_90_retro.sh`:

```bash
# Sourced by tests/run.sh (lib.sh already loaded). Enforcea el retro gate: la
# mitad trasera de la Measurability Gate. Template + wiring del contrato DONE +
# cierre por-feature. "Cerrado" = su verification/reports/<NNN>-*.md muestra el
# veredicto DONE (BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100%). Feature
# cerrado ⟹ specs/<NNN>-*/retro.md completo. Sin hardcode: un feature sin
# reporte DONE está "en vuelo" y se saltea (regla uniforme).

# --- Template: estructura de 3 caras (Capa 1+2) ---
assert_file specs/_template/retro.md
for h in "Cara A" "Cara B" "Cara C" "Evidencia" "deriv"; do
  assert_contains specs/_template/retro.md "$h"
done

# --- Wiring del contrato DONE ---
assert_contains CLAUDE.md "retro ✅"
assert_contains docs/workflow.md "retro ✅"
assert_contains verification/verification-report.md "retro ✅"

# --- Cierre por-feature (regla uniforme) ---
# "Cerrado" = el report tiene BUILD ✅ y UAT ✅ y coverage 100% (tres greps
# independientes: robusto al layout de línea y evita precedencia ||/&& frágil).
closed_seen=0
for report in verification/reports/*.md; do
  [ -f "$report" ] || continue
  grep -qE "BUILD:[[:space:]]*✅"   "$report" || continue
  grep -qE "UAT:[[:space:]]*✅"     "$report" || continue
  grep -qE "coverage:[[:space:]]*100%" "$report" || continue
  closed_seen=1
  nnn=$(basename "$report" | grep -oE '^[0-9]+')
  featdir=$(ls -d specs/${nnn}-*/ 2>/dev/null | head -1)
  if [ -z "$featdir" ]; then _fail "report $report DONE pero no hay specs/${nnn}-*"; continue; fi
  retro="${featdir}retro.md"
  if [ ! -f "$retro" ]; then _fail "feature $nnn DONE pero falta $retro"; continue; fi
  _pass "feature $nnn DONE tiene $retro"
  # Sin placeholders sin llenar
  if grep -qE '_\(…\)_|<[^ >][^>]*>' "$retro"; then _fail "$retro tiene placeholders sin llenar"; else _pass "$retro sin placeholders"; fi
  # Veredicto de misión válido
  if grep -qE 'Veredicto de misión:[*[:space:]]*(confirmed|refuted|pending-observation|n/a)' "$retro"; then
    _pass "$retro veredicto de misión válido"
  else
    _fail "$retro sin veredicto de misión válido"
  fi
  # n/a exige razón (Capa: anti-escape)
  if grep -qE 'Veredicto de misión:[*[:space:]]*n/a' "$retro"; then
    if grep -qiE 'raz[oó]n' "$retro"; then _pass "$retro n/a con razón"; else _fail "$retro n/a sin razón"; fi
  fi
  # Cada campo de Cara B con [deriv:] (Capa 1)
  if [ "$(grep -cE '\[deriv:' "$retro")" -ge 4 ]; then _pass "$retro Cara B con deriv (≥4)"; else _fail "$retro Cara B con <4 [deriv:] (campos derivables sin locator)"; fi
done
[ "$closed_seen" -eq 1 ] && _pass "loop de cierre ejercitado" || _pass "sin features cerrados aún (vacuo)"
```

- [ ] **Step 2: Correr el suite y verificar verde en el repo actual**

Run: `bash tests/run.sh 2>&1 | grep -E "check_90|retro|FAIL" ; echo "---"; bash tests/run.sh 2>&1 | tail -2`
Expected: aserciones de template + wiring PASS; `sin features cerrados aún (vacuo)` PASS (el único report, `002-north-star-judge.md`, no tiene veredicto DONE); `FAIL=0`.

- [ ] **Step 3: Probar la lógica de cierre con un fixture temporal (RED forzado).** Crear un report DONE falso SIN retro y confirmar que el check falla:

```bash
mkdir -p specs/900-fixture
printf 'BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: pendiente\n' > verification/reports/900-fixture-report.md
bash tests/run.sh 2>&1 | grep -E "900|FAIL"
```
Expected: `FAIL: feature 900 DONE pero falta specs/900-fixture/retro.md`

- [ ] **Step 4: Agregar el retro al fixture y confirmar GREEN** (prueba que la gate pasa cuando el retro existe y está completo):

```bash
cat > specs/900-fixture/retro.md <<'EOF'
## Cara A
- Veredicto de misión: n/a
  - razón: fixture de test
## Cara B
- Gaps: 0 [deriv: n/a]
EOF
bash tests/run.sh 2>&1 | grep -E "900"
```
Expected: `PASS: feature 900 DONE tiene …`, `PASS: … n/a con razón`, `PASS: … Cara B con deriv`.

- [ ] **Step 5: Limpiar el fixture y confirmar verde final**

```bash
rm -rf specs/900-fixture verification/reports/900-fixture-report.md
bash tests/run.sh 2>&1 | tail -2
```
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 6: Commit**

```bash
git add tests/check_90_retro.sh
git commit -m "feat(003): check_90_retro — gate determinista del retro (cierre uniforme, sin hardcode)"
```

---

## Fase 3 — Skills y comandos

### Task 4: Skill + comando `/retro`

**Files:**
- Create: `.claude/commands/retro.md`
- Create: `.claude/skills/retro/SKILL.md`
- Modify: `tests/check_40_commands.sh:1`
- Modify: `tests/check_50_skills.sh:1`

**Interfaces:**
- Consumes: `specs/_template/retro.md` (formato de salida), `alignment.md` + `coverage.md` + `verification/reports/<feature>` (insumos).
- Produces: el comando `/retro` y la skill `retro` que la Task 6 (dogfood) invoca sobre `003`.

- [ ] **Step 1: Escribir las aserciones que fallan.** En `tests/check_40_commands.sh` línea 1, agregar `retro` al loop:

```bash
for c in constitution distill plan contract tasks verify uat retro; do
```

En `tests/check_50_skills.sh` línea 1, agregar `retro` al loop y dos aserciones de contenido al final del archivo:

```bash
for s in distill verify uat retro; do
```
Y agregar tras las líneas existentes:
```bash
assert_contains .claude/skills/retro/SKILL.md "adversarial"
assert_contains .claude/skills/retro/SKILL.md "deriv"
```

- [ ] **Step 2: Correr el suite para verlo fallar**

Run: `bash tests/run.sh 2>&1 | grep -E "retro|FAIL"`
Expected: FAIL con `missing file .claude/commands/retro.md` y `.claude/skills/retro/SKILL.md`

- [ ] **Step 3: Crear `.claude/commands/retro.md`:**

```markdown
---
description: Cierra la predicción medible de /align al cerrar un feature. Escribe specs/<feature>/retro.md (Cara Misión + Cara Método). Requerido para el veredicto DONE.
---

Invocá la skill `retro`. Requiere el feature cerrado en `verification/reports/<feature>`
(BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100%) y `specs/<feature>/alignment.md`.
Escribe `specs/<feature>/retro.md`. Sin retro completo el feature no está DONE.
```

- [ ] **Step 4: Crear `.claude/skills/retro/SKILL.md`:**

```markdown
---
name: retro
description: Cierra la predicción de /align al cerrar un feature — dicta el veredicto sobre el signal del pilar y deriva las señales del WoW de artefactos. Escribe specs/<feature>/retro.md. Usar tras un /verify+/uat en verde, como paso final del cierre.
---

# Retro

Entrada: `specs/<feature>/alignment.md` + `coverage.md` + `verification/reports/<feature>` + git.
Salida: `specs/<feature>/retro.md` (plantilla en `specs/_template/retro.md`). Es la
**mitad trasera de la Measurability Gate**: `/align` abrió una predicción medible; el
retro la cierra. El feature no está DONE hasta que este retro cierra sus tres caras.

## Anti-teatro (por qué el orden importa)
Un check no puede probar honestidad. El procedimiento achica el lugar donde el relleno
"por cumplir" se esconde: **derivar → auto-desafiar → escribir**, nunca al revés.

## Procedimiento

1. **Derivá primero (Cara B, Capa 1).** No tipees cifras de memoria. Cada campo de
   Método sale de un artefacto con su `[deriv: <locator>]`:
   - Gaps cazados por /distill → filas de `coverage.md` + `git log` de la fase distill.
   - Disciplina RED→GREEN → historial de estados de `coverage.md` (🔴 antes de 🟢) + git.
   - Rework post-/verify y post-/uat → gaps ruteados en `verification/reports/<feature>`.
   - Escalaciones → traza / git.
   Solo "Fricción del propio WoW" es juicio libre; el resto es derivado.

2. **Dictá la Cara A con evidencia locator obligatoria (Capa 2).** Leé `alignment.md`:
   para cada pilar del `mapping`, buscá su `signal` en `north-star.md` y dictá veredicto
   (`✅ movió` / `❌ no movió` / `⏳ aún no observable`) con una celda de Evidencia que sea
   un **locator** (valor, SHA, fila de coverage, URL) — no prosa. Sin locator para un
   `confirmed`/`refuted`, el veredicto honesto es `pending-observation` con su trigger de
   re-chequeo. Anotá la **calibración de align** (¿los scores pillarFit/scope/mission
   acertaron?). Si el North Star del repo es placeholder (no schema-válido), la Cara A es
   `n/a` con razón — no hay signal real que cerrar.

3. **Auto-desafío adversarial (Capa 3).** Antes de escribir, argumentá EN CONTRA de tu
   propio borrador: "el report dice 0 rework — verificá contra `git log`; dice que el
   pillar-fit de align fue exacto — sostené lo opuesto". Solo lo que sobrevive al desafío
   se escribe. (Refuerzo futuro, no ahora: delegar el desafío a un subagente sképtico
   separado del que redactó.)

4. **Cara C (loop).** Proponé reglas candidatas → constitution y/o amendments → North
   Star. Solo proponé; aplicarlos sigue `update-checklist.md` / `amendment-protocol.md`.

5. **Veredicto de misión.** `confirmed` | `refuted` | `pending-observation` (+trigger) |
   `n/a` (+razón obligatoria). Escribí `specs/<feature>/retro.md` desde la plantilla.

## Gate
`tests/check_90_retro.sh` exige, para todo feature con reporte DONE: retro presente, sin
placeholders, veredicto de misión válido, evidencia no vacía para `confirmed`/`refuted`,
`[deriv:]` en cada campo de Cara B, y razón para `n/a`. El feature no está DONE sin
`retro ✅`.
```

- [ ] **Step 5: Correr el suite para verlo pasar**

Run: `bash tests/run.sh 2>&1 | tail -2`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 6: Commit**

```bash
git add .claude/commands/retro.md .claude/skills/retro/SKILL.md tests/check_40_commands.sh tests/check_50_skills.sh
git commit -m "feat(003): skill+comando /retro (anti-teatro derivar→desafiar→escribir)"
```

---

### Task 5: Skill + comando `/wow-report`

**Files:**
- Create: `.claude/commands/wow-report.md`
- Create: `.claude/skills/wow-report/SKILL.md`
- Modify: `tests/check_40_commands.sh:1`
- Modify: `tests/check_50_skills.sh:1`

**Interfaces:**
- Consumes: todos los `specs/*/retro.md` + `alignment.md` + `verification/reports/*`.
- Produces: el comando `/wow-report` y la skill `wow-report` que la Task 7 invoca para generar `verification/wow-report.md`.

- [ ] **Step 1: Escribir las aserciones que fallan.** En `tests/check_40_commands.sh` línea 1, agregar `wow-report`:

```bash
for c in constitution distill plan contract tasks verify uat retro wow-report; do
```

En `tests/check_50_skills.sh` línea 1, agregar `wow-report`, y dos aserciones de contenido:

```bash
for s in distill verify uat retro wow-report; do
```
Y al final:
```bash
assert_contains .claude/skills/wow-report/SKILL.md "pilar"
assert_contains .claude/skills/wow-report/SKILL.md "olor"
```

- [ ] **Step 2: Correr el suite para verlo fallar**

Run: `bash tests/run.sh 2>&1 | grep -E "wow-report|FAIL"`
Expected: FAIL con `missing file .claude/commands/wow-report.md` y `.claude/skills/wow-report/SKILL.md`

- [ ] **Step 3: Crear `.claude/commands/wow-report.md`:**

```markdown
---
description: Regenera verification/wow-report.md — el rollup del ledger de retros. Responde "¿está funcionando el WoW?" con drift por pilar, re-chequeos pendientes, salud del método y olores de teatro.
---

Invocá la skill `wow-report`. Lee todos los `specs/*/retro.md` + `alignment.md` +
`verification/reports/*` y regenera `verification/wow-report.md` (snapshot commiteado,
read-only, no gatea).
```

- [ ] **Step 4: Crear `.claude/skills/wow-report/SKILL.md`:**

```markdown
---
name: wow-report
description: Agrega el ledger de retros en verification/wow-report.md — drift por pilar (mapping × veredicto de signal), re-chequeos pendientes, salud del método y olores de teatro. Observabilidad on-demand, nunca gatea. Usar para responder "¿está funcionando el WoW?".
---

# WoW Report

Entrada: todos los `specs/*/retro.md`, sus `alignment.md`, y `verification/reports/*`.
Salida: `verification/wow-report.md` (snapshot generado y commiteado). **Observa, nunca
gatea** — el diente determinista es `tests/check_90_retro.sh`; esto es síntesis para el
humano.

## Procedimiento
Regenerá `verification/wow-report.md` con cinco secciones:

1. **Misión — ¿cada pilar del North Star está siendo servido?** Cruzá el `mapping`
   objetivo→pilar de cada `alignment.md` con el veredicto de signal del `retro.md`. Tabla
   por pilar: features que dijeron servirlo × si el signal se movió. **Un pilar con
   features que lo prometieron pero ningún signal movido = drift medible** (destacalo).

2. **Re-chequeos pendientes (worklist).** Juntá los `pending-observation` con su trigger;
   marcá los vencidos.

3. **Método — ¿el WoW agrega valor?** (N=<n>, muestra chica, sin estadística). Tabla
   por-feature: gaps cazados, disciplina RED, rework verify/uat, escalaciones. Agrupá
   temas de fricción recurrentes.

4. **Loop — ¿el WoW se mejora a sí mismo?** Reglas candidatas propuestas vs aterrizadas
   en constitution; amendments propuestos vs aprobados (ADR).

5. **Olores de teatro (spot-check humano, Capa 4).** Marcá retros sospechosos: celdas de
   Evidencia vacías, all-green (cero gaps + cero rework + cero fricción),
   `pending-observation` vencidos. Un retro demasiado limpio ES una señal.

## Honestidad del N=1
El reporte declara explícito "N=<n>, muestra chica, sin estadística". No finge
tendencias; muestra por-feature + totales + temas.
```

- [ ] **Step 5: Correr el suite para verlo pasar**

Run: `bash tests/run.sh 2>&1 | tail -2`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 6: Commit**

```bash
git add .claude/commands/wow-report.md .claude/skills/wow-report/SKILL.md tests/check_40_commands.sh tests/check_50_skills.sh
git commit -m "feat(003): skill+comando /wow-report (rollup del ledger, observa no gatea)"
```

---

## Fase 4 — Dogfood: `003` se valida a sí mismo

> Esta fase es el capstone reflexivo: usar la capacidad recién construida sobre el propio feature que la construyó. En el repo-plantilla la Cara A cierra como `n/a` (North Star placeholder); la Cara B es real. No son steps TDD clásicos sino invocaciones de la propia WoW con deliverables verificables por `check_90`.

### Task 6: Cerrar `003` con su propio `/retro` (bootstrap recursivo)

**Files:**
- Create: `specs/003-wow-self-validation/brief.md`
- Create: `verification/reports/003-wow-self-validation-report.md`
- Create: `specs/003-wow-self-validation/retro.md`

**Interfaces:**
- Consumes: la skill `retro` (Task 4), `check_90` (Task 3), el diff completo de las Fases 1-3 (git log).
- Produces: la primera entrada real del ledger — que la Task 7 (`/wow-report`) agrega.

- [ ] **Step 1: Crear `specs/003-wow-self-validation/brief.md`** — el brief mínimo que ancla el feature al workflow del harness:

```markdown
# Brief — 003 WoW self-validation

**Objetivo:** el harness se autovalida sometiéndose a su propia Way of Working — un retro
que cierra la predicción medible de `/align` (columna align↔retro), enforcement en CI, y
un rollup agregado.

**Métricas de éxito:** `tests/run.sh` verde con `check_90`; `/retro` y `/wow-report`
presentes y wired; el propio `003` cerrado con un retro completo (Cara B real).

**Nota de alcance:** repo-plantilla → North Star placeholder → `/align` no corre acá; la
Cara A (Misión) cierra como `n/a`. Diseño completo:
`docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.
```

- [ ] **Step 2: Crear el reporte de verificación DONE de `003`** en `verification/reports/003-wow-self-validation-report.md`. El BUILD del harness es `tests/run.sh` en verde:

```markdown
# Verification Report — 003-wow-self-validation @ <commit>

spec: design 2026-07-05 · fecha: 2026-07-05 · constitution: base + proyecto

## 1. Coverage snapshot
Criterios estructurales cubiertos por `tests/check_*.sh` (template, wiring, gate, skills/comandos).

## 2. Output eval (BUILD)
`bash tests/run.sh` → TOTAL FAIL=0. Task success: checks estructurales 100%.

## 3. Trajectory eval
Construido test-first: cada archivo nuevo tuvo su aserción en RED antes de crearse
(git log Fases 1-3). Sin pasos saltados.

## 4. UAT
Capacidad ejercitada end-to-end: fixture DONE sin retro → `check_90` FAIL; con retro →
PASS (Task 3 steps 3-4). `/retro` produce este mismo retro.

## 5. Verdicto
BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% · retro: ✅
Cierra ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/003-wow-self-validation/retro.md`.
```

- [ ] **Step 3: Correr `/retro` sobre `003`** (invocar la skill `retro`; orden derivar→auto-desafiar→escribir). Derivar la Cara B del `git log` real de las Fases 1-3. Escribir `specs/003-wow-self-validation/retro.md`. Contenido esperado (ajustar cifras a lo que muestre `git log`):

```markdown
# Retro — 003-wow-self-validation @ <commit>

cierra: `specs/003-wow-self-validation/alignment.md` (n/a) · `verification/reports/003-wow-self-validation-report.md` · fecha: 2026-07-05

## Cara A — Misión (cierra la predicción de /align)
Fuente: N/A — North Star de este repo es placeholder (no schema-válido); `/align` es fail-closed.

| Pilar (mapping) | Signal predicho | Veredicto | Evidencia (locator OBLIGATORIO) |
|---|---|---|---|
| — | — | n/a | verification/reports/002-north-star-judge.md (NS placeholder) |

- **Calibración de align:** N/A (no corrió `/align`).
- **Veredicto de misión:** n/a
  - **razón:** repo = plantilla del harness; `north-star.md` es placeholder, no hay signal real que cerrar. La columna align↔retro se dogfoodea de verdad en un repo adoptante.

## Cara B — Método (valida el WoW) — DERIVADA de artefactos, no redactada
- **Gaps cazados por /distill:** 0 `[deriv: no hubo /distill; feature vino de brainstorming→design→plan]` — el grilling ocurrió en brainstorming (2 forks + N=1 + placeholder NS).
- **Disciplina RED→GREEN:** sí `[deriv: git log Fases 1-3 — cada check en RED antes del archivo]` — Tasks 1,3,4,5 con step "verlo fallar" antes de crear.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/003-wow-self-validation-report.md]`
- **Escalaciones al humano:** varias por diseño `[deriv: transcript brainstorming]` — todas decisiones de diseño, no fallas de inner loop.
- **Fricción del propio WoW:** el North Star placeholder impide dogfoodear la Cara A acá; se descubrió que `check_90` no necesita bootstrap para `002` (regla uniforme).

## Cara C — Loop (auto-mejora)
- **Reglas candidatas → constitution:** "en repo-plantilla, la Cara A del retro cierra `n/a`; solo un adoptante la valida real" — candidata a nota en la constitution/README.
- **Amendments candidatos → North Star:** ninguno.
```

- [ ] **Step 4: Correr el suite — ahora `003` es un feature cerrado y `check_90` lo exige**

Run: `bash tests/run.sh 2>&1 | grep -E "003|FAIL" ; bash tests/run.sh 2>&1 | tail -2`
Expected: `PASS: feature 003 DONE tiene specs/003-wow-self-validation/retro.md`, `PASS: … n/a con razón`, `PASS: … Cara B con deriv`; `FAIL=0`.

- [ ] **Step 5: Commit**

```bash
git add specs/003-wow-self-validation/ verification/reports/003-wow-self-validation-report.md
git commit -m "feat(003): dogfood — 003 se cierra con su propio /retro (bootstrap recursivo)"
```

---

### Task 7: Generar `verification/wow-report.md` con `/wow-report`

**Files:**
- Create: `verification/wow-report.md`

**Interfaces:**
- Consumes: la skill `wow-report` (Task 5), `specs/003-wow-self-validation/retro.md` (Task 6).
- Produces: el snapshot del ledger — la vista "¿está funcionando el WoW?" con N=1.

- [ ] **Step 1: Correr `/wow-report`** (invocar la skill `wow-report`). Genera `verification/wow-report.md`. Contenido esperado:

```markdown
# WoW Report — @ <commit>  (snapshot generado; no editar a mano)

> N=1, muestra chica, sin estadística. Repo-plantilla: la Cara Misión aún no se mide real
> (North Star placeholder). Este report prueba la maquinaria + la Cara Método.

## 1. Misión — ¿cada pilar del North Star está siendo servido?
North Star placeholder → sin pilares reales. 003: Misión `n/a` (razón: repo-plantilla).
Drift medible: N/A hasta un repo adoptante.

## 2. Re-chequeos pendientes
Ninguno (003 cerró `n/a`, sin `pending-observation`).

## 3. Método — ¿el WoW agrega valor? (N=1)
| Feature | Gaps /distill | RED disciplina | Rework verify/uat | Escalaciones |
|---|---|---|---|---|
| 003 | 0 (grilling en brainstorming) | ✅ sí | 0 / 0 | diseño, no inner-loop |
Temas de fricción: North Star placeholder bloquea Cara A; simplificación de bootstrap descubierta al construir.

## 4. Loop — ¿el WoW se mejora a sí mismo?
Reglas candidatas: 1 propuesta (nota repo-plantilla Cara A), 0 aterrizadas aún.
Amendments North Star: 0 / 0.

## 5. Olores de teatro
003 no es all-green (declara fricción real y 0 gaps justificado por venir de brainstorming, no de /distill). Evidencia presente. Sin olores.
```

- [ ] **Step 2: Correr el suite (no debe romper nada; `/wow-report` no gatea)**

Run: `bash tests/run.sh 2>&1 | tail -2`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 3: Commit**

```bash
git add verification/wow-report.md
git commit -m "feat(003): generar wow-report.md (ledger N=1, cara Método real)"
```

---

### Task 8: Verde final + readiness de merge

**Files:** ninguno (verificación)

- [ ] **Step 1: Suite completo verde**

Run: `bash tests/run.sh 2>&1 | tail -3`
Expected: `TOTAL PASS=… FAIL=0`

- [ ] **Step 2: Secret scan limpio** (si aplica al repo)

Run: `bash tests/run.sh 2>&1 | grep -iE "secret|check_60"`
Expected: sin FAIL

- [ ] **Step 3: Revisar el diff completo de la rama**

Run: `git log --oneline main..HEAD && git diff --stat main..HEAD`
Expected: los commits de Fases 1-4; archivos del manifiesto presentes.

- [ ] **Step 4:** Reportar al humano que la rama `003-wow-self-validation` está lista para merge a `main`. No mergear sin OK explícito.

---

## Self-Review (hecho por el autor del plan)

**1. Cobertura del spec:**
- Template retro 3 caras → Task 1 ✅
- Contrato DONE `∧ retro ✅` → Task 2 ✅
- `check_90` (template + wiring + cierre uniforme, sin hardcode) → Task 3 ✅
- Anti-teatro 4 capas → Cara B `[deriv]` (Task 1/3), evidencia obligatoria + `check_90` (Task 3), auto-desafío en skill (Task 4), olores en `/wow-report` §5 (Task 5) ✅
- Skill+comando `/retro` → Task 4 ✅ · `/wow-report` → Task 5 ✅
- Bootstrap: sin hardcode, `002` no-DONE se saltea → Task 3 (loop vacuo) ✅
- Dogfood recursivo `003` (Cara A `n/a` por NS placeholder, Cara B real) → Tasks 6-7 ✅
- `/wow-report` genera snapshot commiteado → Task 7 ✅

**2. Placeholder scan:** los `<…>` dentro de bloques son sintaxis de template/retro (contenido real a llenar por el ejecutor con git data), no placeholders del plan. Sin TBD/TODO.

**3. Type consistency:** nombres de archivo/comando/skill (`retro`, `wow-report`, `check_90_retro.sh`, `verification/wow-report.md`) consistentes entre tasks; los loops de `check_40`/`check_50` referencian exactamente esos nombres.

**Nota de fragilidad conocida (para el ejecutor):** el `done_re`/detección de DONE en `check_90` usa `grep` sobre emojis UTF-8; si el entorno tiene problemas de locale, verificar con `LC_ALL=C.UTF-8`. El fixture de Task 3 (steps 3-5) existe justo para cazar esto antes de confiar en la gate.
