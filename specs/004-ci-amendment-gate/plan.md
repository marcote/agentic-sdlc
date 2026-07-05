# Plan técnico — CI-gate del amendment del North Star

> CÓMO se construye. Grounded en la constitution. Producido por `/plan` sobre `spec.md`
> congelado.

## Decisiones técnicas

- **D1 — Pure bash/coreutils, sin python3/jq.** La detección de "cambió el set
  pillars/scope" y la validación de schema se hacen con `grep`/`sed`/`sort`/`comm`, no con
  un parser JSON. *Trade-off:* menos robusto que parsear JSON de verdad, pero honra el
  criterio **DEP-FREE** (spec: "solo bash/coreutils + GitHub Actions") ya **congelado**, y
  mantiene la consistencia con `tests/lib.sh` (todo grep, sin frameworks). *Supuesto que lo
  hace viable:* el formato de `north-star.md` es **controlado por nosotros** y sus valores
  JSON son **de una sola línea** (sin newlines embebidos), así que extraer las líneas
  semánticas (`"id"`, `"statement"`, `"signal"`, predicados de scope) + normalizar
  (trim + `sort`) da una comparación por-sets estable frente a reformateo/reorden.
  Restringido por: North Star `out_of_scope` "dependencias de runtime o frameworks".

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

- **D6 (override justificado) — Excepción al principio 4.** El principio 4 dice "nada
  bloquea commit/push". Este feature introduce el **primer gate bloqueante** del harness.
  El override se justifica y se **registra en `constitution.md`** (delta de proyecto): el
  bloqueo está **acotado a cambios de `pillars`/`scope` del North Star** (governance), el
  desarrollo de features sigue sin bloquear. Coherente con `base/amendment-protocol.md`, que
  ya declara los amendments un evento gateado. Sin este registro, el feature contradiría un
  no-negociable en silencio.

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

- **Fragilidad del parseo bash (D1)** → mitigación: normalización por líneas semánticas +
  `sort`; fixtures que cubren reformateo y reorden (AMEND-SET-SEMANTICS) para cazar falsos
  positivos; supuesto de valores de una línea documentado y garantizado por nuestro formato.
- **`github.event.before` en el primer push / force-push** puede ser inválido
  (`000000…`) → mitigación: si BASE no resuelve, el gate trata el rango como "revisar el
  estado actual" (schema-valid + si el HEAD tocó pillars/scope respecto del último commit
  con north-star.md), y en el peor caso falla-cerrado pidiendo revisión manual.
- **Branch protection requiere permisos de admin** → `setup-branch-protection.sh` documenta
  que lo corre el owner una vez; el token del runner no lo aplica en CI.
