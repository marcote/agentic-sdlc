# Tasks — CI-gate del amendment del North Star

> Descomposición ejecutable. Producido por `/tasks`. GATE: `/tasks` no emite tasks de
> implementación mientras exista un criterio determinista sin test ligado en 🔴 RED.
> **GATE verificado:** las 10 filas deterministas de `coverage.md` tienen
> `check_95_amendment_gate.sh` ligado y estado 🔴 RED (`bash tests/run.sh` → FAIL). ✅

## Orden
T1 → T2 → T3 en paralelo con T4 → T5. Cada task de impl se cierra cuando sus asserts de
`check_95` pasan a 🟢 (test-first: el contrato ya está RED; implementar hasta verde, sin
tocar el test salvo bug del propio contrato).

## Tasks

- [ ] **T1 — Núcleo del gate (funciones puras).** `scripts/amendment-gate.sh`: helpers
  `python3`-stdlib que extraen el bloque ```json canónico de un `.md` y exponen
  `sets_changed OLD NEW` (compara sets pillars/scope semánticamente, no por texto),
  `schema_valid FILE` (reglas de `base/schema.md`), `has_new_adr ADDED…`
  (`decisions/NNNN-*.md`). CLI test-mode `--files OLD NEW --added "…" --suite-cmd CMD`:
  si los sets no cambian → exit 0; si cambian → exige ADR ∧ schema-válido ∧ suite verde,
  exit ≠0 citando la condición faltante. Falla-cerrado si falta `python3`.
  **Cubre:** AMEND-BLOCK-NO-ADR · AMEND-PASS-WITH-ADR · AMEND-NO-ADR-FOR-PROSE ·
  AMEND-SET-SEMANTICS · AMEND-SCHEMA-VALID · AMEND-SUITE-GREEN · DEV-UNBLOCKED · DEP-FREE.

- [ ] **T2 — Wrapper CLI `--range BASE..HEAD` (I/O de git).** Sobre T1: deriva old/new de
  `north-star.md` (`git show BASE:… ` vs HEAD) y los added-files
  (`git diff --name-status --diff-filter=A BASE HEAD`), maneja `github.event.before`
  inválido (`000…`/force-push) fallando-cerrado. Es el entrypoint que corre CI.
  **Cubre:** habilita AMEND-BLOCK-REAL / AMEND-BLOCK-PUSH (validados en `/uat`); sin
  assert determinista propio (I/O de git no es hermético — ver plan D2).

- [ ] **T3 — Workflow `amendment-gate.yml`.** `.github/workflows/amendment-gate.yml`: corre
  `scripts/amendment-gate.sh --range …` en `pull_request` y `push` a `main`; expone el
  status-check requerible "amendment-gate".
  **Cubre:** SELF-CHECK (workflow existe + referencia al script).

- [ ] **T4 — Delta de constitution.** `memory/constitution/constitution.md`: registra que
  el amendment-gate bloqueante es la única excepción angosta al principio 4
  ("nada bloquea commit/push"), acotada a cambios de `pillars`/`scope` del North Star,
  consistente con su intención productividad-primero (reconciliación D6 del plan).
  **Cubre:** CONST-EXCEPTION (grep `amendment-gate` ∧ `principio 4` ∧ `pillars/scope`).

- [ ] **T5 — Branch protection + doc de adopción.** `scripts/setup-branch-protection.sh`
  (aplica vía `gh api` el required status-check "amendment-gate" en `main` + prohíbe
  bypass; lo corre el owner una vez) + sección corta en `README.md` para adoptantes.
  **Cubre:** AMEND-BLOCK-REAL · AMEND-BLOCK-PUSH — no unit-testeables (config de GitHub);
  se caminan en `/uat` (aplicar protection, intentar amendment inválido por PR y por push,
  confirmar bloqueo).

## Fuera de estas tasks (deferred, registrado en spec)
- Afinar la redacción **literal** del principio 4 hacia "productividad-primero" → amendment
  de constitution aparte (este feature solo registra la reconciliación en T4).
