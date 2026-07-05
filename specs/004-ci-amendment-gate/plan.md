# Plan técnico — CI-gate del amendment del North Star

> CÓMO se construye. Grounded en la constitution. Producido por `/plan` sobre `spec.md`
> congelado.

## Decisiones técnicas

- **D1 — `python3` stdlib para la lógica JSON (no pure bash).** La detección de "cambió el
  set pillars/scope" y la validación de schema se hacen con un helper `python3` (módulo
  `json` de la stdlib) que extrae el bloque canónico de ambas versiones y compara los sets
  `pillars`/`scope` semánticamente. El resto del gate (I/O de git, orquestación, mensajes)
  es bash. *Trade-off:* pure bash para parsear JSON es frágil; `python3` da robustez real.
  *Costo:* afloja el criterio **DEP-FREE** de "solo bash/coreutils" a "bash/coreutils +
  `python3` stdlib" (re-congelado en el spec). *Por qué no cruza el North Star:* `python3`
  es un **intérprete de sistema** (como bash/grep), no una dependencia instalable
  (sin uv/pip/npm, sin package-manifest) → no matchea `out_of_scope` "dependencias de
  runtime o frameworks", no exige amendment. **node** está descartado por el brief
  ("sin Node/npm"); **uv** sería un toolchain instalable → out_of_scope. Restringido por:
  `portabilidad-agnostica` (mantener el baseline chico) y el `out_of_scope`.

- **D2 — Núcleo lógico separado del I/O de git (testabilidad).** El script expone
  funciones puras que operan sobre **archivos**, no sobre un rango de git:
  `sets_changed OLD NEW`, `schema_valid FILE`, `has_new_adr ADDED_FILES...`. Un wrapper CLI
  las cablea desde un rango `base..head`. *Por qué:* permite que `check_95` las ejercite con
  **fixtures** (pares old/new de `north-star.md` + listas sintéticas de archivos), sin
  construir estados de git — el mismo patrón fixture que usó `check_90`. Restringido por:
  principio 2 (test-first) y 1 (verificabilidad) — un criterio que no se puede unit-testear
  con fixture no es determinista.

- **D3 — Workflow separado `amendment-gate.yml`, no augment de `verify.yml`.** Un workflow
  dedicado da un **status-check con nombre propio** ("amendment-gate") que branch protection
  puede exigir, independiente del `verify` advisory. Corre en `pull_request` y `push` hacia
  `main`. *Trade-off:* un archivo de workflow más, a cambio de un gate requerible sin
  arrastrar la semántica advisory de `verify.yml`.

- **D4 — Rango base..head por evento.** En `pull_request`:
  `${{ github.event.pull_request.base.sha }}..HEAD`. En `push`:
  `${{ github.event.before }}..${{ github.sha }}`. El wrapper deriva los dos contenidos de
  `north-star.md` (`git show BASE:memory/north-star/north-star.md` vs el de HEAD) y la lista
  de archivos agregados (`git diff --name-status --diff-filter=A BASE HEAD`).

- **D5 — `hasAdrFor` = archivo `decisions/NNNN-*.md` con status `A` (added) en el rango.**
  Editar un ADR existente **no** cuenta (protocolo: "número secuencial nuevo"). Restringido
  por: `base/amendment-protocol.md`.

- **D6 — Reconciliación con el principio 4 (no override literal).** El principio 4 dice,
  literal, "nada bloquea commit/push", pero su **intención es productividad-primero**. Este
  gate bloquea **solo** cambios de `pillars`/`scope` del North Star (governance rara), no el
  throughput de features — así que es **consistente con la intención**, no un override de
  ella. Se **registra en `constitution.md`** (delta de proyecto) esa reconciliación.
  Coherente con `base/amendment-protocol.md`, que ya declara los amendments un evento
  gateado. *Deferred (no en este feature):* afinar la **redacción literal** del principio 4
  hacia "productividad-primero" es un amendment de constitution aparte.

## Componentes / módulos

- **`scripts/amendment-gate.sh`** → la gate. Funciones puras (`sets_changed`,
  `schema_valid`, `has_new_adr`) + wrapper CLI (`--range BASE..HEAD` para CI;
  `--files OLD NEW --added "f1 f2"` para test). Salida: exit 0 (pasa) / ≠0 (bloquea) + mensaje
  citando la condición faltante. Dependency-free.
- **`.github/workflows/amendment-gate.yml`** → corre `scripts/amendment-gate.sh --range …`
  en `pull_request` + `push` a `main`; es el status-check requerible.
- **`scripts/setup-branch-protection.sh`** → aplica (vía `gh api`) branch protection en
  `main` exigiendo el check "amendment-gate" y prohibiendo bypass; reusable por adoptantes.
  Documentado en el README.
- **`tests/check_95_amendment_gate.sh`** → ejercita las funciones puras con fixtures
  (escenarios de los 10 criterios deterministas) + asserts de wiring (script + workflow
  existen) + DEP-FREE (no `package.json`/`node_modules`). Sourced por `tests/run.sh`.
- **`memory/constitution/constitution.md`** → delta que registra la excepción D6.
- **`README.md`** → sección corta: cómo activar la branch protection (adoptante).

## Testabilidad de los criterios

- **Deterministas (10)** → `check_95` con fixtures: pares old/new de `north-star.md`
  (reformateo, cambio de set, prosa-only, threshold-only, schema-inválido) + listas de
  added-files (con/sin ADR) + un stub de suite. Van a **RED** en `/contract`.
- **UAT (2)** `AMEND-BLOCK-REAL` / `AMEND-BLOCK-PUSH` → config de branch protection; se
  caminan en `/uat` (aplicar protection, intentar un amendment inválido por PR y por push,
  confirmar bloqueo). No unit-testeables herméticamente.

## Riesgos

- **`python3` ausente en un entorno minimalista** → mitigación: el gate chequea `python3`
  al inicio y falla-cerrado con un mensaje claro ("requiere python3 stdlib"); está presente
  en todos los runners de GitHub y en la práctica en toda máquina de dev. Es el costo
  aceptado de D1 sobre `portabilidad-agnostica` (baseline: bash/coreutils + python3).
- **`github.event.before` en el primer push / force-push** puede ser inválido
  (`000000…`) → mitigación: si BASE no resuelve, el gate trata el rango como "revisar el
  estado actual" (schema-valid + si el HEAD tocó pillars/scope respecto del último commit
  con north-star.md), y en el peor caso falla-cerrado pidiendo revisión manual.
- **Branch protection requiere permisos de admin** → `setup-branch-protection.sh` documenta
  que lo corre el owner una vez; el token del runner no lo aplica en CI.
