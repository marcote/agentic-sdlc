# Tasks — CI-gate for the North Star amendment

> Executable breakdown. Produced by `/tasks`. GATE: `/tasks` does not issue
> implementation tasks while a deterministic criterion exists without a linked test in 🔴 RED.
> **GATE verified:** the 10 deterministic rows of `coverage.md` have
> `check_95_amendment_gate.sh` linked and status 🔴 RED (`bash tests/run.sh` → FAIL). ✅

## Order
T1 → T2 → T3 in parallel with T4 → T5. Each impl task closes when its `check_95` asserts
turn 🟢 (test-first: the contract is already RED; implement to green, without touching the
test unless there is a bug in the contract itself).

## Tasks

- [ ] **T1 — Gate core (pure functions).** `scripts/amendment-gate.sh`: `python3`-stdlib
  helpers that extract the ```json canonical block from a `.md` and expose
  `sets_changed OLD NEW` (compares pillars/scope sets semantically, not by text),
  `schema_valid FILE` (rules from `base/schema.md`), `has_new_adr ADDED…`
  (`decisions/NNNN-*.md`). Test-mode CLI `--files OLD NEW --added "…" --suite-cmd CMD`:
  if sets do not change → exit 0; if they change → requires ADR ∧ schema-valid ∧ green suite,
  exit ≠0 citing the missing condition. Fails-closed if `python3` is absent.
  **Covers:** AMEND-BLOCK-NO-ADR · AMEND-PASS-WITH-ADR · AMEND-NO-ADR-FOR-PROSE ·
  AMEND-SET-SEMANTICS · AMEND-SCHEMA-VALID · AMEND-SUITE-GREEN · DEV-UNBLOCKED · DEP-FREE.

- [ ] **T2 — CLI wrapper `--range BASE..HEAD` (git I/O).** On top of T1: derives old/new of
  `north-star.md` (`git show BASE:… ` vs HEAD) and the added-files
  (`git diff --name-status --diff-filter=A BASE HEAD`), handles invalid `github.event.before`
  (`000…`/force-push) by failing-closed. This is the entrypoint run by CI.
  **Covers:** enables AMEND-BLOCK-REAL / AMEND-BLOCK-PUSH (validated in `/uat`); no
  dedicated deterministic assert (git I/O is not hermetic — see plan D2).

- [ ] **T3 — Workflow `amendment-gate.yml`.** `.github/workflows/amendment-gate.yml`: runs
  `scripts/amendment-gate.sh --range …` on `pull_request` and `push` to `main`; exposes
  the requirable "amendment-gate" status-check.
  **Covers:** SELF-CHECK (workflow exists + references the script).

- [ ] **T4 — Constitution delta.** `memory/constitution/constitution.md`: records that the
  blocking amendment gate is the only narrow exception to principle 4
  ("nothing blocks commit/push"), bounded to changes of `pillars`/`scope` in the North Star,
  consistent with its productivity-first intent (plan reconciliation D6).
  **Covers:** CONST-EXCEPTION (grep `amendment-gate` ∧ `principio 4` ∧ `pillars/scope`).

- [ ] **T5 — Branch protection + adoption doc.** `scripts/setup-branch-protection.sh`
  (applies via `gh api` the required "amendment-gate" status-check on `main` + prohibits
  bypass; run once by the owner) + short section in `README.md` for adopters.
  **Covers:** AMEND-BLOCK-REAL · AMEND-BLOCK-PUSH — not unit-testable (GitHub config);
  walked in `/uat` (apply protection, attempt invalid amendment by PR and by push,
  confirm block).

## Outside these tasks (deferred, recorded in spec)
- Refining the **literal wording** of principle 4 toward "productivity-first" → separate
  constitution amendment (this feature only records the reconciliation in T4).
