# Retro — 004-ci-amendment-gate @ cdf1abc

cierra: `specs/004-ci-amendment-gate/alignment.md` · `verification/reports/004-ci-amendment-gate.md` · fecha: 2026-07-05

> Cierra la predicción medible que abrió `/align` (columna align↔retro). Un feature no
> está DONE hasta que este retro cierra sus tres caras. Diseño:
> `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.

## Cara A — Misión (cierra la predicción de /align)
Fuente: `alignment.md` (mapping objetivo→pilar) + `north-star.md` (signal por pilar).

| Pilar (mapping) | Signal predicho | Veredicto | Evidencia (locator OBLIGATORIO) |
|---|---|---|---|
| enforcement-real | Los gates bloquean el cierre cuando falta una condición; las violaciones se cazan antes del merge | ✅ movió | PR #2 check `amendment-gate` fail → `mergeStateStatus: BLOCKED`; push directo rechazado `GH006`; `verification/reports/004-ci-amendment-gate.md` §4 |
| impacto-medible | Gaps cazados temprano y rework tardío evitado; alto = la disciplina previene, no burocratiza | ✅ movió | Bloqueo angosto verificado (DEV-UNBLOCKED 🟢 en `coverage.md`); el gate cazó drift real pre-merge en PR #2 sin frenar el throughput de features |
| portabilidad-agnostica | El contrato (schema, gates, artefactos) se mantiene íntegro al vendorearlo sobre un repo/stack arbitrario | ⏳ aún no observable | Deliverable dep-free aterrizó (DEP-FREE 🟢 en `coverage.md`; gate = bash+python3+Actions), pero la integridad-al-vendorear no se caminó este feature |

- **Calibración de align:** acertada. pillarFit=4 clavó `enforcement-real` como el fit central (el bloqueo real lo confirma) y marcó `portabilidad` como indirecta (4, no 5) — que materializó como `pending-observation`, exactamente la cautela que el 4 anticipó. scope=4 sobre el borde "motor determinista per-stack" resolvió bien: se construyó la gate *propia* del harness en bash, no el motor del adoptante. mission=4 se sostiene: efecto medible y demostrado sobre el signal de `enforcement-real`. Matiz honesto: incluir `portabilidad` en el mapping sabiendo que su signal no cierra este feature fue algo generoso.
- **Veredicto de misión:** confirmed
  - Cerrado por el pilar central `enforcement-real` con evidencia dura (PR bloqueado + push rechazado, gate vivo en `main`). `portabilidad-agnostica` queda como sub-observación abierta.
  - **trigger de re-chequeo** (portabilidad): al vendorear el harness sobre un repo/stack real, verificar que `amendment-gate.yml` + `scripts/amendment-gate.sh` corren íntegros (python3 stdlib presente, `--range` deriva bien) sin ajustes por-stack.

## Cara B — Método (valida el WoW) — DERIVADA de artefactos, no redactada
Cada campo trae su marcador `[deriv: …]` — el locator de dónde salió la cifra.

- **Gaps cazados por /distill:** 6 edge cases + 1 reframe `[deriv: spec.md "Edge cases (80% problem)" 6 bullets @ 3d13431; 12 criterios en coverage.md]` — los jugosos: set-semantics (reformateo ≠ cambio), schema-inválido-aun-con-ADR, prosa/threshold no exige ADR, editar ADR existente no cuenta como `hasAdrFor`, y el reframe DEP-FREE hacia "bash+python3 stdlib" (python3 es intérprete de sistema, no dep instalable) @ 7c3ad73.
- **Gap cazado por el GATE de /tasks:** 1 `[deriv: git faee99b + nota de coverage.md]` — DEP-FREE era green-by-construction (guardarraíl de repo, sin RED real); el gate machine-checkable lo rebotó y se ató al deliverable para darle fase RED genuina.
- **Disciplina RED→GREEN:** sí, sin excepciones `[deriv: coverage.md — 10 filas 🔴 red @ 8ff6cd2/faee99b, → 🟢 green @ e8c3b89; suite 15 FAIL en contrato → 0 FAIL tras impl]`.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/004-ci-amendment-gate.md §4-5 — BUILD/TRAJECTORY verdes al primer pase, UAT sin gap de producto]`.
- **Escalaciones al humano:** 1 `[deriv: traza de sesión — AskUserQuestion "alcance UAT"]` — decisión outward-facing (config real de GitHub); el usuario eligió "walk real completo".
- **Fricción del propio WoW:** la máquina de estados `sin contrato → red → green` asume que todo criterio determinista tiene un arco RED→GREEN, pero un criterio **invariante** (must-not-regress, como DEP-FREE) no lo tiene — hubo que atarlo a un deliverable para que el gate de `/tasks` no lo rechazara. Además, los criterios de *config de GitHub* (AMEND-BLOCK-REAL/PUSH) no son unit-testeables herméticamente: exigieron un walk real outward-facing, que el harness no valida en `tests/run.sh`.

## Cara C — Loop (auto-mejora)
- **Reglas candidatas → constitution:** un **criterio invariante (must-not-regress)** debe atarse a un deliverable observable para tener fase RED genuina en `/contract`; `green-by-construction` no cuenta como red y el gate de `/tasks` debe rechazarlo (como pasó con DEP-FREE @ faee99b). Aplicar vía `memory/constitution/update-checklist.md`.
- **Amendments candidatos → North Star:** ninguno — este feature operacionalizó el signal de `enforcement-real`, no tocó `pillars`/`scope`. Nota adyacente (constitution, no North Star): afinar la redacción literal del principio 4 hacia "productividad-primero" sigue deferred (registrado en `spec.md` y en el delta D1 de la constitution).
