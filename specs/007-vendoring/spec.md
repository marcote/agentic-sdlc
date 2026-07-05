# Spec — Vendoring the harness onto an existing repo

> WHAT is built. Produced by `/distill` from `brief.md`. Frozen when `coverage.md` has no
> orphan rows. Gate: `alignment.md` verdict = `aligned` (run on the 006 engine).

## Functional requirements

1. **`scripts/vendor.sh [--apply] <target-dir>`.** Copy-once vendoring from the harness
   checkout the script lives in (source root = `$(dirname "$0")/..`) onto `<target-dir>`.
   **Default = dry-run** (writes nothing); `--apply` executes. Dependency-free: bash/coreutils
   + `python3` only.
2. **Dry-run plan.** Without `--apply`, print a plan: each path as **KEEP / SEED / DROP**, any
   **collision** (existing SEED file), the **detected stack + test command**, and the
   **provenance** that would be stamped. Write nothing to the target.
3. **KEEP — governance, copied verbatim, overwrites (authoritative).** On `--apply`, copy and
   **overwrite** (idempotent, re-run brings the snapshot):
   - `.claude/commands/`, `.claude/skills/`, `.claude/hooks/`, `.claude/settings.json`
   - `memory/constitution/base/` + `update-checklist.md`
   - `memory/north-star/base/`
   - `specs/_template/`
   - `evals/rubric.md` + `evals/README.md`
   - `verification/uat-checklist.md` + `code-review-checklist.md` + `verification-report.md`
   - `docs/factory-model.md` + `docs/workflow.md`
   - `scripts/north-star/engine.py` **(the 006 engine — the payoff of sequencing 006 first)**
   - `scripts/amendment-gate.sh` + `scripts/setup-branch-protection.sh`
   - `.github/workflows/amendment-gate.yml`
4. **SEED — customizable layer, stub if absent, NEVER overwrite.** If the target lacks it,
   write a stub; if present, **do not touch it** — write `<file>.harness-new` alongside and
   report it for manual merge:
   - `CLAUDE.md` (adopter stub) · `memory/constitution/constitution.md` (`extends: base`,
     empty Project deltas) · `memory/north-star/north-star.md` (`extends: base`,
     schema-skeleton placeholder) · `scripts/test.sh` (detected default, see req. 6)
5. **DROP — harness-self content, never copied.**
   `specs/0*/` except `_template` · `memory/north-star/decisions/*` ·
   `verification/reports/*` · `verification/wow-report.md` · `docs/superpowers/*` ·
   `evals/cases/*` · `README.md` · `tests/` (harness self-validation; the adopter's runtime
   is `scripts/test.sh`) · `scripts/vendor.sh` + `docs/vendoring.md` (adoption tooling itself).
6. **Stack detection → `scripts/test.sh` stub.** Detect and seed an executable stub with a
   TODO header: `package.json`→`npm test`; `pyproject.toml`/`setup.py`/`setup.cfg`→`pytest`;
   `go.mod`→`go test ./...`; `Cargo.toml`→`cargo test`; **unknown → explicit `# TODO: set
   your test command`**. `scripts/test.sh` is SEED (never clobbered).
7. **Provenance (best-effort, never blocks).** On `--apply`, write a provenance file
   (`.harness-provenance`) at the target root: source commit SHA (`git rev-parse HEAD`),
   remote URL if any, date, a `dirty` flag if the working tree has changes, and the list of
   `.harness-new` files needing merge. Non-git source → record `non-git source` + date and
   continue.
8. **Handoff.** `docs/vendoring.md` documents the buckets, the stack plugs, and the post-vendor
   first step: `/constitution` → seed the North Star → first feature. Vendoring ends where the
   loop begins.

## User stories

- As an **adopter** I want one command to land a working harness onto my repo so that
  adoption is batteries-included, not a manual reverse-engineering of what to keep/seed/drop.
- As an **adopter** I want a dry-run that shows the plan before touching my repo so that I
  trust it.
- As an **adopter with an existing `CLAUDE.md`** I want vendoring to never clobber my files so
  that it is safe to run.

## Edge cases (80% problem)

- **Re-run / already-vendored target:** KEEP overwrites (idempotent, authoritative); SEED
  stays untouched. Running twice is safe and refreshes governance.
- **Existing SEED collision:** target `CLAUDE.md` present → not overwritten; `CLAUDE.md.harness-new`
  written and reported.
- **Unknown stack:** no recognized manifest → `scripts/test.sh` seeded with an explicit TODO
  (never a wrong guess).
- **Non-git harness source:** provenance records `non-git source` + date; vendoring still
  completes.
- **Dry-run is truly read-only:** a dry-run against a target leaves it byte-for-byte unchanged.
- **DROP leakage:** none of `specs/001-example`, `verification/reports/*`, `README.md`, or
  `tests/` appears in the target.

## Open questions / deferred

- **Merging `CLAUDE.md`/constitution/north-star automatically:** deferred — the interactive
  `/adopt` skill (aspirational) would do semantic merges; 007 only writes `.harness-new` and
  reports.
- **Copying the harness self-check (`tests/`):** resolved → DROP. It validates the
  harness-as-product (asserts the harness's own constitution deltas / North Star); the adopter
  runs their own runtime via the seeded `scripts/test.sh`.
- **Update/sync path:** out of scope (copy-once); provenance is the record, not a live link.
