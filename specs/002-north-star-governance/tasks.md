# Tasks — Gobernanza North-Star + Measurability Gate

> Descomposición ejecutable. GATE (test-first) verificado antes de emitir estas
> tasks: en `coverage.md`, toda fila **determinista/estructural** (la que tiene
> `tests/check_80_north_star.sh` como test ligado) está en `🔴 red` — el archivo
> aún no existe, así que las 7 assertions de `check_80` fallan hoy (ver la
> corrida de `/contract` referenciada abajo). Las filas `NS-SCHEMA-CONTRACT` y
> `ALIGN-VERDICT-CONTRACT` son **contrato documentado — motor per-stack
> (deferred)**, no deterministas-estructurales: quedan explícitamente fuera del
> requisito de "🔴 red con test ligado" (no hay bash check posible para un motor
> que no se construye en este repo — ver `plan.md` decisión 2). `WOW-2LAYER` es
> UAT-only (prosa). Ninguna fila estructural queda sin test ligado. GATE: ✅ pasa.

## Tasks

- [ ] **T1: `memory/north-star/base/*`** — cubre NS-BASE; contribuye a
  NS-SCHEMA-CONTRACT y AMEND-ADR
  - Crear `schema.md` (forma medible: `mission`, `pillars[]` con
    `id`+`statement`+`signal`, `scope.in_scope`/`out_of_scope`,
    `alignment.threshold` — documentar reglas de campo, no un validador
    ejecutable), `alignment-rubric.md` (3 dimensiones × 0–5 + pass rule),
    `amendment-protocol.md` (amendment = ADR + PR; cuándo aplica; qué NO
    requiere amendment), `adr-template.md` (Contexto/Decisión/Scope-delta/
    Consecuencias), `README.md` (mecanismo `extends: base`, cómo se propaga
    `base/`), `decisions/.gitkeep`.
  - Verificar: los 5 `assert_file` + el `assert_contains ... "extends: base"`
    (para README, no north-star.md) de `check_80` relacionados con `base/`
    pasan a verde.

- [ ] **T2: `memory/north-star/north-star.md` (placeholder)** — cubre NS-PLACEHOLDER
  - Frontmatter `extends: base` + bloque ` ```json ` esqueleto con
    `_(completar por proyecto)_` en los campos de contenido (sin misión ni
    pilares reales — este repo es el harness, no un proyecto adoptante).
  - Verificar: `assert_file memory/north-star/north-star.md` +
    `assert_contains ... "extends: base"` de `check_80` en verde.

- [ ] **T3: `.claude/commands/align.md` + `.claude/skills/align/SKILL.md`** —
  cubre ALIGN-CMD; documenta ALIGN-VERDICT-CONTRACT; declara el bootstrap
  - Comando: entrada `brief.md` + North Star, salida `alignment.md`,
    delega a la skill. Skill: procedimiento completo del modelo de 3 capas
    (scope predicates → orphan check → LLM-judge cuantificado), la semántica
    fija del veredicto (decisión 3 de `plan.md`), y la sección "Excepción
    bootstrap" citando `002-north-star-governance` por nombre. Citar
    explícitamente que el motor determinista (`scopeReject`/`alignVerdict`/
    `validateNorthStar` o equivalentes) es per-stack, con
    `poirot-fe scripts/north-star/{schema,align}.mjs` como reference
    implementation — nunca reimplementarlo inline en la skill.
  - Verificar: `assert_file` de ambos + (parcialmente) el bloque `MEAS-GATE`
    de `check_80` en verde.

- [ ] **T4: Paso 0 — Measurability Gate en `.claude/skills/distill/SKILL.md`** —
  cubre MEAS-GATE
  - Prepend un "Paso 0 — Measurability Gate" al procedimiento existente (los
    pasos 1–6 actuales no cambian de número ni de contenido): lee
    `specs/<feature>/alignment.md`; ausente → frena y pide `/align`; presente
    con veredicto `aligned` → avanza; `needs-amendment`/`rejected` → frena y
    señala la ruta (amendment o rechazo, sin continuar en silencio); declara
    inline la excepción de bootstrap para `002-north-star-governance`.
  - Verificar: `assert_contains .claude/skills/distill/SKILL.md` para
    `alignment.md`, `Measurability Gate`, y `aligned` — los 3 de `check_80` en
    verde.

- [ ] **T5: Columna Pillar en `specs/_template/coverage.md`** — cubre COVERAGE-PILLAR
  - Agregar la columna **Pillar** (primera columna de la tabla) al template,
    con una fila de ejemplo mostrando `pillar → objetivo → criterio`.
  - Verificar: `assert_contains specs/_template/coverage.md "Pillar"` de
    `check_80` en verde. (Opcional, no requerido por esta feature: reforzar
    `tests/check_20_spec_templates.sh` con el mismo assert.)

- [ ] **T6: Way-of-Work de dos capas** — cubre WOW-2LAYER
  - Editar `README.md` (sección "Way of Work") y `docs/workflow.md` para
    distinguir explícitamente harness=governance (comandos + gates +
    constitution + North-Star) de execution-runtime=adoptante (intake→brief,
    implement, finish), de forma genérica — sin nombrar ningún runtime como
    obligatorio del harness.
  - Verificar: UAT — lectura manual confirmando que la distinción está clara y
    no contradice la tabla "El enforcement no vive en hooks" existente.

- [ ] **T7: Final green** — cubre SELFCHECK, JUDGE-ALIGNMENT; confirma NOBREAK
  - Crear (ya existe desde `/contract`) `evals/cases/north-star-judge.md` con
    los 2 cases (in-scope pasa las 3 dimensiones; plausible-pero-fuera-de-alcance
    falla específicamente scope compliance) — ejecutarlos contra
    `memory/north-star/base/alignment-rubric.md` una vez T1–T3 existan, y
    registrar el resultado (p. ej. en `verification/reports/`).
  - Correr `bash tests/run.sh`: confirmar `tests/check_80_north_star.sh` 🟢 y
    que los checks `00`–`70` preexistentes siguen 🟢 (ninguna regresión).
  - Actualizar `coverage.md`: filas estructurales `sin contrato`/`🔴 red` →
    `🟢 green`; `JUDGE-ALIGNMENT` → `📋 case` con resultado registrado;
    `WOW-2LAYER` → `✅ uat` tras revisión humana de T6.

## Notas cruzadas
- `check_80` (SELFCHECK) queda completamente verde solo después de T1+T2+T3+T4+T5
  juntas (cada una aporta un subconjunto de sus asserts).
- El motor determinista concreto (equivalente a `poirot-fe scripts/north-star/
  *.mjs`) **no** es una task de este `tasks.md` — es per-stack, fuera de
  alcance de este repo (ver `plan.md` decisión 2 y `spec.md` "Fuera de
  alcance"). Un repo adoptante que quiera un `/align` ejecutable de verdad
  necesita construirlo aparte, en su propio stack.
- Ninguna task de este archivo toca código de runtime app (no existe tal cosa
  en este repo) — todo el diff vive en `memory/`, `.claude/`, `specs/_template/`,
  `tests/`, `evals/`, y docs.
