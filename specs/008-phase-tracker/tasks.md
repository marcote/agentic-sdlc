# Tasks — Derived phase-tracker (`scripts/status.sh`)

> Executable breakdown. Produced by `/tasks`. GATE PASSED: all 13 deterministic criteria have
> a linked test (`check_86_status.sh`) in 🔴 RED. Each task drives its rows 🔴→🟢 via
> `bash tests/run.sh`.

## Tasks

- [ ] **T1: `status.sh` skeleton (arg + read-only + phase list).** Resolve `<feature>` under
  `specs/`, error + non-zero on missing; ordered phase list; a per-phase `done` dispatch;
  never write. — covers `UNKNOWN-FEATURE`, `READONLY`.

- [ ] **T2: Doc-phase predicates.** brief/align/distill/plan/tasks done = artifact present AND
  non-placeholder (reuse `check_90`'s marker regex); align also needs a `Verdict` line. —
  covers `PHASE-DERIVE`, `NON-PLACEHOLDER`.

- [ ] **T3: Gate-phase predicates (coverage + report).** contract = a `🔴`/`🟢`/`✅` glyph in
  `coverage.md`; implement = no `🔴`/`no contract` left; verify/uat/retro = `BUILD: ✅` /
  `UAT: ✅` / `retro: ✅` in the newest report. — covers `COVERAGE-DERIVED`.

- [ ] **T4: Current phase + next command + DONE.** current = first not-done phase; print its
  command; all done → `feature DONE`, exit 0. — covers `CURRENT-NEXT`, `DONE-FEATURE`,
  `NORMAL-EXIT0`.

- [ ] **T5: Anomaly detection + exit code.** A done phase after a pending one → `⚠ anomaly`
  line + non-zero exit; coherent → exit 0. — covers `ANOMALY-FLAG`.

- [ ] **T6: Coverage gaps.** Surface non-green criteria (`🔴`/`no contract`) and orphan rows
  (empty Pillar cell) in a gaps section. — covers `GAPS`.

- [ ] **T7: Shared `assert_dep_free` helper (candidate B).** Add an invocation-aware helper to
  `tests/lib.sh` (excludes comment/echo/data lines); adopt it in `check_82`, `check_84`,
  `check_95`, and use it for status.sh in `check_86`. — covers `HELPER-SHARED`, `DEPFREE`.

- [ ] **T8: Full green + self-check.** `bash tests/run.sh` fully green (`check_86` + the
  refactored checks + the rest). — covers `SELF-CHECK`; confirms no regression from T7.

## Escalation

Inner loop per task: 🔴→🟢. **ESCALATE** to the human after 2 identical failures or 3 attempts
(constitution) instead of burning tokens.
