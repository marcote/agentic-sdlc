# Plan técnico — Gobernanza North-Star + Measurability Gate

> CÓMO se construye. Producido por `/plan`. Grounded en la constitution (no viola
> ningún no-negociable ni un pattern `[given]` sin override). Diseño:
> `docs/superpowers/specs/2026-07-04-north-star-governance-design.md`

## Decisiones técnicas

1. **North Star = markdown + un bloque JSON canónico machine-readable.**
   `north-star.md` lleva frontmatter YAML `extends: base` (mismo mecanismo que
   `constitution.md`) más **un** bloque ` ```json ` fenced que es el North Star
   canónico, parseable (`mission`, `pillars[]`, `scope.in_scope`/`out_of_scope`,
   `alignment.threshold`); la prosa alrededor lo explica para humanos pero nada
   del flujo la lee para decidir. *Constrained by:* base principio #1
   (Verificabilidad) — "lo que no se puede verificar, no se construye" extendido
   de la técnica al producto.

2. **Contrato en la plantilla, motor por-stack (la decisión central del port).**
   El harness es una plantilla stack-agnóstica, dependency-free (self-check en
   bash puro, sin Node/npm). Por eso este repo trae la **especificación completa**
   (forma del schema, dimensiones+pass-rule de la rúbrica, semántica exacta del
   veredicto, protocolo de amendment) pero **no** implementa el motor determinista
   ejecutable (`parseNorthStar`/`validateNorthStar`/`scopeReject`/`alignVerdict`/
   `requiresAdr`/`hasAdrFor`). Cada repo adoptante lo construye en su propio
   stack — exactamente el mismo patrón que `evals/README.md` ya usa para el
   eval-runner ("depende del stack del proyecto que adopte el harness"). Se cita
   `poirot-fe scripts/north-star/{schema,align,amendment}.mjs` como **reference
   implementation** (Node, ya construida y con su propia suite
   `tests/unit/north-star/*.node.spec.js`, verde). *Trade-off:* un adoptante debe
   escribir su propio checker antes de que `/align` sea ejecutable de verdad —
   mitigado por la spec explícita + la reference impl citada. *Constrained by:*
   el repo es dependency-free (`docs/factory-model.md`, `tests/run.sh` en bash
   puro); no se introduce Node/npm en el source por esta feature.

3. **Agregación del veredicto: fija y determinista, documentada aquí, implementada
   por-stack.** Dado scores + mapping + scope-check: un hit de `out_of_scope` →
   `rejected` (dura, sin importar los otros dos scores); si no, cualquier huérfano
   → bloqueado (no `aligned`); si no, las 3 dimensiones ≥ `threshold` (default 3)
   → `aligned`; si no → `needs-amendment`. *Constrained by:* la regla de
   threshold resuelta en `spec.md` (Preguntas abiertas).

4. **`/align` es harness-owned**, no delegado a ningún execution-runtime
   específico (p. ej. `superpowers`) — la gobernanza vive en el harness, como
   `/constitution`/`/distill`/`/plan`/`/contract`/`/tasks`/`/verify`/`/uat`.
   Sigue el mismo patrón `.claude/commands/<c>.md` (thin, delega) +
   `.claude/skills/<c>/SKILL.md` (procedimiento) que todo el resto del flujo.
   Escribe `specs/<feature>/alignment.md`; `/distill` lo lee y se niega a
   arrancar si el veredicto no es `aligned`. *Constrained by:* README.md, tabla
   "El enforcement no vive en hooks" — los *workflow gates* (deterministas, en
   transiciones de comando) son "el 90% del enforcement"; `/align` se suma como
   gate #0, no como hook.

5. **El gate en `/distill` es un Paso 0 prepended, no una reescritura.**
   `.claude/skills/distill/SKILL.md` gana un **Paso 0 — Measurability Gate**
   antes de su "Paso 1 — Sembrar desde la constitution" actual (los pasos 1–6
   existentes no se renumeran ni se alteran en su contenido). El texto del Paso
   0 declara inline la excepción de bootstrap (para no depender solo de
   `coverage.md` para documentarla). *Constrained by:* base principio #2
   (test-first / gate determinista) y la regla existente "no avances con
   ambigüedades abiertas" del propio skill.

6. **`coverage.md` template gana una columna: Pillar** (primera columna, antes
   de "Objetivo"), consistente con la cadena `pillar → objetivo → criterio` del
   diseño. `tests/check_80_north_star.sh` asserta que
   `specs/_template/coverage.md` contiene la palabra `Pillar` — una decisión
   tomada en este `/contract` (no explícitamente enumerada en el diseño, que solo
   describe 4 grupos de asserts para `check_80`) para que exista un RED real hoy
   que pruebe el gap, en vez de dejar la columna sin ningún check ligado. Extender
   `tests/check_20_spec_templates.sh` con un assert de contenido más rico queda
   como posible follow-up, no requerido por esta feature.

7. **Self-check bash, dependency-free, auto-glob.**
   `tests/check_80_north_star.sh` (nuevo) mirror-ea el estilo de
   `tests/check_10_constitution.sh` (`assert_file`/`assert_contains` de
   `tests/lib.sh`, sin frameworks). No requiere cambios en `tests/run.sh`: el glob
   `for t in tests/check_*.sh` ya lo recoge por orden alfabético/numérico.
   *Constrained by:* constitution base — el self-check es on-demand, nada
   bloquea commit/push por defecto (regla 4).

8. **Bootstrap.** `/align` no puede gatear la feature que lo introduce
   (`002-north-star-governance`, esta misma) — se saltea solo para esta
   feature, documentado en `coverage.md` y (una vez implementado, tarea T3 de
   `tasks.md`) en el propio `.claude/skills/align/SKILL.md`. Desde la próxima
   feature, `/align` corre antes de `/distill` sin excepción.

9. **Way-of-Work de dos capas, genérico.** El README.md (sección "Way of Work")
   y `docs/workflow.md` se enriquecen para distinguir explícitamente: el
   **harness gobierna** (comandos, gates deterministas, constitution,
   North-Star) — capa estable, versionada, la misma para todo adoptante; los
   pasos que **no** son comandos (intake→brief, implement, finish) los
   provee un **execution-runtime** que cada adoptante elige (el harness no
   nombra ninguno como obligatorio — ni siquiera `superpowers`, aunque sea el
   runtime que `poirot-fe` eligió de hecho). Es contenido de prosa: no hay un
   check bash confiable para "explica bien la distinción de dos capas"; se
   cierra por UAT (lectura humana), no por `check_80`.

10. **Aditivo, sin código de motor, sin Node/npm.** Todo lo que aterriza en esta
    feature vive bajo `memory/north-star/`, `.claude/`, `specs/_template/`,
    `tests/`, `evals/`, y docs — nada de runtime app (no hay runtime app en este
    repo: es la plantilla). *Constrained by:* el repo es stack-agnóstico /
    dependency-free por diseño (ver `docs/factory-model.md`); introducir un
    motor Node aquí violaría esa propiedad para todo adoptante no-Node.

## Componentes / módulos

- **`memory/north-star/base/`** — `schema.md` (forma requerida + reglas de
  validez), `alignment-rubric.md` (3 dims × 0–5 + pass rule), `amendment-protocol.md`
  (ADR + PR), `adr-template.md`, `README.md` (`extends: base`), `decisions/.gitkeep`.
- **`memory/north-star/north-star.md`** — placeholder: frontmatter `extends: base`
  + bloque JSON esqueleto `_(completar por proyecto)_`.
- **`.claude/commands/align.md` + `.claude/skills/align/SKILL.md`** — orquestan el
  gate; documentan el modelo de 3 capas y producen `alignment.md`; citan la
  reference impl de poirot para el motor concreto.
- **`.claude/skills/distill/SKILL.md`** — edición: Paso 0 — Measurability Gate.
- **`specs/_template/coverage.md`** — columna **Pillar** agregada.
- **`tests/check_80_north_star.sh`** — self-check de integridad (presencia +
  grep de wiring), auto-tomado por `tests/run.sh`.
- **`evals/cases/north-star-judge.md`** — el eval case no-determinista
  (JUDGE-ALIGNMENT), genérico (pilares ilustrativos — el harness no tiene North
  Star propio con contenido real).
- **Docs:** `README.md` (Way of Work, dos capas), `docs/workflow.md` (`/align`
  como primer gate + nota de Measurability Gate).
- **Fuera de este repo (per-stack, deferred):** el motor determinista
  equivalente a `poirot-fe scripts/north-star/{schema,align,amendment}.mjs` —
  cada adoptante lo escribe en su stack; no hay tarea de `tasks.md` para
  construirlo aquí.

## Riesgos

- **Frontera semántica vs determinista.** Los scope predicates por keyword no
  capturan drift semántico → la dimensión "scope compliance" del judge es el
  backstop; documentado explícitamente para que un adoptante no confunda el
  predicado determinista con la única defensa.
- **Contrato sin motor en la plantilla.** Un repo adoptante debe implementar el
  checker determinista antes de que `/align` sea ejecutable de verdad →
  mitigado con la spec explícita (`schema.md`, rúbrica, semántica del veredicto)
  + la reference impl de `poirot-fe` ya verde y citada por ruta exacta.
- **Confusión de bootstrap.** Que se entienda que `/align` se saltea *solo* para
  la feature que lo introduce, no en general → documentado en tres lugares:
  `coverage.md`, el propio `.claude/skills/align/SKILL.md` (tarea T3), y el
  Paso 0 de `.claude/skills/distill/SKILL.md` (tarea T4).
- **Columna Pillar sin check dedicado en el diseño original.** Se resolvió
  sumando un assert de `Pillar` a `check_80_north_star.sh` (decisión 6) para
  que el criterio COVERAGE-PILLAR tenga un RED real, no una promesa sin
  verificación.
- **Deriva prosa↔bloque JSON** (para cuando exista contenido real): el bloque
  JSON es la única fuente de verdad; la prosa es solo explicativa — el
  validador (per-stack) nunca lee la prosa.
