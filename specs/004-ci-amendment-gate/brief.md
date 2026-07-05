# Brief — CI-gate del amendment del North Star

> ORIGEN del desarrollo. Describe el OBJETIVO y el PORQUÉ, no la solución.

## Objetivo de producto

Que los amendments del North Star (cambios de `pillars`/`scope` de `north-star.md`)
estén gateados por **CI determinista y bloqueante**, no por un approval humano. Un cambio
que toca `pillars`/`scope` **sin** el ADR correspondiente, o con la suite del harness en
rojo, **no puede mergearse a `main`**. El enforcement del amendment deja de depender de la
buena voluntad (o de un review que un mantenedor solo no puede darse) y pasa a ser una
gate determinista, coherente con el pilar `enforcement-real`.

## Por qué / motivación

El `amendment-protocol` exige "ADR + PR aprobado por humano", pero GitHub no deja al autor
aprobar su propio PR: un mantenedor solo queda trabado, y el enforcement real del amendment
hoy es **por convención**, no por gate. Eso contradice al propio harness, que predica
disciplina hecha cumplir por gates deterministas (`enforcement-real`) y no por gatekeeping
manual. Sin una gate real, un cambio de `pillars`/`scope` puede aterrizar sin ADR y sin
suite verde — el mismo drift de gobernanza que el `amendment-protocol` dice prevenir.

## Métricas de éxito

- Un cambio a `pillars`/`scope` de `north-star.md` **sin** un ADR nuevo en
  `memory/north-star/decisions/` en el mismo PR es **bloqueado** por CI (rojo, no
  mergeable) — determinista.
- El mismo cambio **con** su ADR y la suite verde **pasa** la gate.
- Un cambio que NO toca `pillars`/`scope` (typo en prosa, ajuste de `threshold`) **no**
  exige ADR y no es bloqueado.
- La gate es **realmente bloqueante**: `main` no se puede mergear salvo que el status-check
  esté verde (branch protection activa exigiéndolo).
- El self-check del harness sigue verde (`tests/run.sh`) y cubre la capa nueva.
- La capa se mantiene **dependency-free** (bash/coreutils + GitHub Actions; sin Node/npm en
  el source).

## Fuera de alcance

- Gatear cambios que no son de gobernanza de producto (features de app del adoptante) — la
  gate es específica de `north-star.md` `pillars`/`scope`.
- Reimplementar el motor `/align` completo; esto cubre solo la mitad `requiresAdr`/
  `hasAdrFor` del `amendment-protocol`.
- Portar la gate a otros forges (GitLab/Bitbucket); el objetivo es GitHub Actions +
  branch protection, consistente con el `.github/workflows/verify.yml` ya existente.
- Cambiar el idioma del source (se mantiene español).
