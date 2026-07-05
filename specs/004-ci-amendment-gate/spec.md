# Spec — CI-gate del amendment del North Star

> QUÉ se construye. Producido por `/distill` a partir de `brief.md` + `alignment.md`
> (`aligned`). Se congela cuando `coverage.md` no tiene filas huérfanas.

## Requerimientos funcionales

1. **Script de amendment-gate** (bash, dependency-free). Dado un rango `base..head`,
   detecta si cambiaron los **sets** `pillars`/`scope` del bloque JSON canónico de
   `memory/north-star/north-star.md` — comparación **semántica por sets**, no por texto
   (reordenar/reformatear sin alterar el contenido no cuenta). Si cambiaron, exige las
   tres condiciones y falla (exit ≠ 0) si falta alguna:
   - (a) un archivo `memory/north-star/decisions/NNNN-*.md` **nuevo** en el rango
     (`hasAdrFor`);
   - (b) el bloque JSON resultante es **schema-válido** (`base/schema.md`);
   - (c) `tests/run.sh` en verde.
2. **GitHub Action** que corre el gate en `pull_request` y `push` hacia `main` y lo
   expone como **status-check** requerible.
3. **Branch protection** en `main` que exige ese status-check → bloquea tanto PRs como
   pushes directos con un amendment inválido.
4. **Delta de constitution**: la `constitution.md` del proyecto declara el gate
   bloqueante de amendments como la **única excepción** al principio 4 ("nada bloquea
   commit/push"), acotada a cambios de `pillars`/`scope` del North Star.
5. **Self-check**: `tests/` cubre el script del gate (con fixtures base/head) y el wiring
   (el script y el workflow existen); `tests/run.sh` sigue verde y dependency-free.

## User stories

- Como **mantenedor del harness**, quiero que un cambio de `pillars`/`scope` sin ADR sea
  bloqueado por CI, para que la gobernanza no dependa de un approval que un mantenedor
  solo no puede darse.
- Como **adoptante**, quiero un script + doc para activar la misma gate en mi repo, para
  heredar el enforcement del amendment sin reinventarlo.

## Edge cases (80% problem)

- Reformatear/reordenar el bloque JSON **sin** cambiar los sets → **no** exige ADR
  (semántica por sets).
- Agregar un ADR **sin** tocar el North Star → permitido (no bloquea).
- Cambio de `pillars`/`scope` con ADR pero que deja el JSON **schema-inválido** →
  bloqueado (condición b).
- Cambio **solo** de `alignment.threshold`, prosa, o redacción de `mission` que no altera
  los sets → **no** exige ADR.
- "ADR nuevo" = archivo `decisions/NNNN-*.md` **agregado** en el rango; editar uno
  existente no satisface `hasAdrFor`.
- Trabajo normal de feature (no toca `pillars`/`scope`) → el gate **no bloquea**
  (preserva "productividad primero").

## Preguntas abiertas / deferred

- **Aplicar branch protection a este repo ahora** vs solo proveer el script → resuelto:
  se aplica a este repo en el finish + se provee script/doc para adoptantes.
- La verificación de "**realmente bloqueante**" (branch protection) es **config de
  GitHub, no unit test hermético**: los criterios `AMEND-BLOCK-REAL` y `AMEND-BLOCK-PUSH`
  se validan en **UAT** (walk: aplicar protection, intentar un amendment inválido,
  confirmar bloqueo), no con un test local.
