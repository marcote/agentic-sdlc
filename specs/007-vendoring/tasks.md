# Tasks — Vendoring the harness onto an existing repo

> Executable breakdown. Produced by `/tasks`. GATE PASSED: all 12 deterministic criteria have
> a linked test (`check_84_vendor.sh`) in 🔴 RED. Each task drives its rows 🔴→🟢 via
> `bash tests/run.sh`.

## Tasks

- [ ] **T1: `vendor.sh` skeleton + dry-run plan.** CLI (`[--apply] <target>`, default dry-run);
  KEEP / SEED / DROP as explicit arrays (allowlist); a plan printer listing each entry, the
  detected stack + test command, and the provenance preview; writes nothing without `--apply`.
  — covers `DRYRUN-NOWRITE`, `DRYRUN-PLAN`.

- [ ] **T2: KEEP copy (overwrite) + allowlist drop.** On `--apply`, copy each KEEP path
  verbatim, overwriting; DROP paths are never in the copy set. — covers `KEEP-COPIED`,
  `KEEP-OVERWRITE`, `DROP-ABSENT`.

- [ ] **T3: SEED logic + stubs.** For each SEED path: write the heredoc stub if absent; if
  present, write `<file>.harness-new` and add it to the report (never clobber). Stubs:
  `CLAUDE.md`, `constitution.md` (`extends: base`), `north-star.md` (`extends: base`
  schema-skeleton). — covers `SEED-STUB`, `SEED-NOCLOBBER`.

- [ ] **T4: Stack detection → `scripts/test.sh`.** Detect the target's manifest and seed an
  executable `scripts/test.sh` stub (`npm test` / `pytest` / `go test ./...` / `cargo test`;
  unknown → `# TODO: set your test command`). SEED semantics (never clobber). — covers
  `STACK-DETECT`.

- [ ] **T5: Provenance stamp.** On `--apply`, write `.harness-provenance` (source SHA or
  `non-git source`, remote, date, `dirty` flag, list of `.harness-new` files). Best-effort,
  never blocks. — covers `PROVENANCE`.

- [ ] **T6: `docs/vendoring.md`.** The guide: the four buckets, the stack plugs, and the
  post-vendor first step (`/constitution` → seed North Star → first feature). — covers
  `HANDOFF`.

- [ ] **T7: Close DEPFREE + SELF-CHECK; full green.** Confirm `vendor.sh` invokes no
  installable toolchain and `bash tests/run.sh` is fully green (`check_84` + the rest). —
  covers `DEPFREE`, `SELF-CHECK`.

## Escalation

Inner loop per task: 🔴→🟢. **ESCALATE** to the human after 2 identical failures or 3 attempts
(constitution) instead of burning tokens.
