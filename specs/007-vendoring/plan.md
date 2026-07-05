# Technical plan — Vendoring the harness onto an existing repo

> HOW it is built. Grounded in the constitution. Produced by `/plan` over the frozen `spec.md`.

## Technical decisions

- **D1 — bash + `python3`, dependency-free.** `vendor.sh` is bash/coreutils for file I/O;
  `python3` only where JSON/text handling helps (none strictly needed — provenance and stubs
  are plain text). Same baseline as 004/006 (system interpreters, not installable deps). No
  npm/uv/pip. Constrained by: `agnostic-portability` + the `out_of_scope` "runtime dependencies".

- **D2 — Allowlist copy, never copy-all-then-delete.** The script **enumerates KEEP and SEED
  explicitly** and copies only those; **DROP is never in the copy set at all** (not copied then
  removed). *Why:* a copy-all-then-`rm` would risk leaking harness-self content (`specs/001`,
  `verification/reports/`, `README.md`, `tests/`) if a delete is missed. An allowlist fails
  safe — an unclassified new path is simply not copied (visible in the dry-run plan).
  Constrained by: `DROP-ABSENT` + principle 1 (verifiability — the plan is inspectable).

- **D3 — Dry-run is the default; `--apply` writes.** No target is mutated without `--apply`.
  Dry-run prints the full plan (per-path KEEP/SEED/DROP, SEED collisions, detected stack + test
  command, provenance preview) and touches nothing. *Why:* safe-by-default for an operation
  that writes into someone's repo. Constrained by: `DRYRUN-NOWRITE`.

- **D4 — KEEP overwrites, SEED never clobbers.** KEEP = `cp` overwrite (governance is
  authoritative; re-run is idempotent and refreshes). SEED = write a stub only if absent; if
  present, write `<file>.harness-new` beside it and add it to the report — **never** touch the
  adopter's file. *Why:* the grilling decision (G1/G2); the governance/customizable split.
  Constrained by: `KEEP-OVERWRITE`, `SEED-STUB`, `SEED-NOCLOBBER`.

- **D5 — Stubs embedded as heredocs.** `CLAUDE.md`, `constitution.md` (`extends: base`, empty
  deltas), `north-star.md` (`extends: base`, schema-skeleton), and `scripts/test.sh` are
  written from in-script heredocs. *Trade-off:* embedding duplicates a little shape knowledge
  vs. a `templates/` dir; chosen for a single self-contained script (dep-free, one file to
  audit). The `north-star.md` stub is a **schema-skeleton** (valid *shape*, empty *content*)
  so the adopter's first `/constitution` fills it. Constrained by: `base/schema.md`.

- **D6 — Stack detection by manifest presence.** In the target: `package.json`→`npm test`;
  `pyproject.toml`/`setup.py`/`setup.cfg`→`pytest`; `go.mod`→`go test ./...`;
  `Cargo.toml`→`cargo test`; none → `# TODO: set your test command`. Result seeded into the
  `scripts/test.sh` stub (SEED, never clobbered). Constrained by: `STACK-DETECT` + the
  `out_of_scope` "imposing a mandatory runtime" (a **default**, adopter overrides — not imposed).

- **D7 — Provenance best-effort, never blocks.** `.harness-provenance` at target root:
  `git rev-parse HEAD` (source SHA) + remote URL + `date` + a `dirty` flag from
  `git status --porcelain`; non-git source → `non-git source` + date. Plus the list of
  `.harness-new` files. *Why:* copy-once wants an auditable record, not a gate (grilling G3).
  Constrained by: principle 5 (auditable trail).

- **D8 — Hermetic test via a temp target.** `check_84_vendor.sh` uses `mktemp -d`, seeds the
  fake target (a `package.json` and a pre-existing `CLAUDE.md` for the collision case), runs
  `vendor.sh --apply`, asserts KEEP present / DROP absent / SEED stubbed / collision→`.harness-new`
  / stack→`scripts/test.sh` / provenance stamped, then removes the temp dir. Dry-run asserted
  read-only by snapshotting the target before/after. Constrained by: principle 2 (test-first)
  + `tests/run.sh` globs `check_*.sh` (no wiring).

## Components / modules

- **`scripts/vendor.sh`** → the vendoring tool. KEEP/SEED/DROP as explicit arrays at the top
  (the single source of truth the doc mirrors). CLI: `[--apply] <target>`; default dry-run.
  Output: the plan (dry-run) or the applied changes + a report of `.harness-new` files.
- **`docs/vendoring.md`** → the guide: the four buckets, the stack plugs (eval-runner + the
  `scripts/test.sh` you fill), and the post-vendor first step (`/constitution` → seed North
  Star → first feature). Renders the same classification the script enforces.
- **`tests/check_84_vendor.sh`** → hermetic exercise of `vendor.sh` (D8) + `DEPFREE` (no
  toolchain in the script; no manifest introduced) + `HANDOFF` (grep `docs/vendoring.md`).
  Sourced automatically by `run.sh`.

## Risks

- **Allowlist drift** — a new governance file added to the harness is silently missed by
  `vendor.sh`'s KEEP list. → Mitigation: `check_84` asserts the plan covers the key governance
  roots (`.claude/commands`, `.claude/skills`, `memory/*/base`, `scripts/north-star/engine.py`,
  `specs/_template`); the dry-run plan makes omissions visible. (A future completeness check
  could diff the KEEP list against the tracked tree.)
- **Stub North Star not schema-valid** → the seeded `north-star.md` must pass
  `engine.py schema-valid` as a skeleton, or the adopter's first `/align` fails closed. →
  Mitigation: `check_84` can validate the seeded stub against the (now vendored) engine.
- **`tests/` dropped → adopter has no self-check** → accepted trade-off (spec Open questions):
  `tests/` validates the harness-as-product; the adopter's runtime is the seeded `scripts/test.sh`.
- **Copying into a dirty/­wrong target** → dry-run default + explicit `<target>` arg + the
  non-destructive SEED policy bound the blast radius.
