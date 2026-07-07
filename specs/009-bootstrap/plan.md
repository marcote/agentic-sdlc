# Technical plan — One-command bootstrap for from-zero adoption

> HOW it is built. Grounded in the constitution. Produced by `/plan` over the frozen `spec.md`.

## Technical decisions

- **D1 — Thin wrapper over `vendor.sh`, motor untouched.** `bootstrap.sh` only orchestrates
  *fetch → plan → confirm → apply → cleanup*; it shells out to the vendored
  `<tmp>/scripts/vendor.sh` for every classification/stack/provenance concern. No logic from
  006/007 is reimplemented. *Why:* keeps a single source of truth for vendoring and a tiny,
  auditable script. Constrained by: `APPLY-YES` (result must equal a direct `vendor.sh --apply`),
  spec req. 1.

- **D2 — `git` + bash/coreutils only, dependency-free.** Same baseline as 004/006/007 (system
  interpreters, no installable deps). `git` is the one hard dep and is checked explicitly
  (D6). No npm/uv/pip, no manifest added to the harness. Constrained by: `agnostic-portability`
  + the `out_of_scope` "runtime dependencies", `DEPFREE`, `GIT-REQUIRED`.

- **D3 — Fetch via `git clone --depth 1 --branch main "$HARNESS_REPO"` into `mktemp -d`.**
  `HARNESS_REPO` defaults to `https://github.com/marcote/agentic-sdlc.git` (HTTPS — a
  `curl | bash` newcomer has no SSH key) and is **env-overridable**. The override is the single
  seam that makes the fetch **hermetically testable** (point it at a local checkout) and lets a
  fork bootstrap from itself — without exposing a user-facing `--ref` (out of scope). *Why:*
  tracks `main`, provenance SHA is the record. Constrained by: `FETCH`, spec req. 2.

- **D4 — Plan-first ordering is structural.** The apply call is textually *after* the dry-run
  call; `vendor.sh <target>` (no `--apply`) writes nothing (007 guarantee), so the plan always
  reaches stdout before any mutation. The test asserts a byte-for-byte snapshot of the target
  is unchanged at the moment the plan is printed. Constrained by: `PLAN-FIRST` + principle 1
  (verifiability — the plan is inspectable before the write).

- **D5 — Consent gate: `/dev/tty` interactive, `--yes` opt-in, no-TTY aborts.** The pipe holds
  stdin, so the interactive `[y/N]` is read from `/dev/tty`; default (empty/non-`y`) aborts.
  `--yes`/`-y` sets a flag that bypasses the read (plan still printed first). If there is **no**
  controlling TTY (`[ -t 0 ]`/`/dev/tty` unavailable) **and** no `--yes`, abort with a message
  and non-zero exit — never write blind. *Why:* preserves 007's dry-run-first safety inside one
  gesture while giving CI an explicit, auditable consent. Constrained by: `NOTTY-ABORT`,
  `CONFIRM-TTY`, `real-enforcement`.

- **D6 — Fail-closed preconditions before any clone.** `command -v git` first (abort → clear
  message, nothing written); resolve `target` (default `.`). Ordering matters: a missing `git`
  or a no-TTY-no-`--yes` refusal must abort **before** the clone, so there is nothing to clean
  up and no partial state. Constrained by: `GIT-REQUIRED`, `NOTTY-ABORT`.

- **D7 — `trap … EXIT` cleanup of the temp clone.** The `mktemp -d` path is registered in a
  single `trap 'rm -rf "$tmp"' EXIT INT TERM` right after creation, so completion, decline,
  and error all remove it. *Why:* no leaked clones regardless of exit path. Constrained by:
  `CLEANUP`.

- **D8 — `bootstrap.sh` added to `vendor.sh`'s DROP array.** One-line change to the existing
  DROP list (the only edit to `vendor.sh`), mirroring how `vendor.sh` drops itself. Keeps
  harness tooling out of adopter targets. Constrained by: `DROP-SELF`, spec req. 8.

- **D9 — Hermetic test via local `HARNESS_REPO` + non-TTY harness.** `check_88_bootstrap.sh`
  uses `mktemp -d` for target(s), sets `HARNESS_REPO=$(pwd)` (or a local clone) so the fetch is
  offline, and drives `bootstrap.sh` under `< /dev/null` (no TTY): with `--yes` to exercise
  FETCH/PLAN-FIRST/APPLY-YES/CLEANUP, without `--yes` to exercise NOTTY-ABORT. `GIT-REQUIRED`
  runs it with `PATH` stripped of `git`. `APPLY-YES` diffs the bootstrap result against a
  reference `vendor.sh --apply`. Constrained by: principle 2 (test-first) + `run.sh` globs
  `check_*.sh` (no wiring).

- **D10 — Docs: README front door + `docs/vendoring.md` cross-ref.** The `curl … | bash`
  one-liner (and the `-s -- --yes` CI variant) goes in `README.md` as the from-zero entry;
  `docs/vendoring.md` gains a pointer that the bootstrap is the step *before* a manual
  `vendor.sh`. Constrained by: `HANDOFF-DOC`. (Note: `README.md` and `docs/vendoring.md` are
  DROP — documenting the harness's own front door, not vendored into adopters.)

## Components / modules

- **`bootstrap.sh`** (repo root) → the wrapper. CLI: `[--yes|-y] [target]` (target default `.`).
  Flow: check `git` → resolve consent mode → `mktemp -d` + `trap` cleanup →
  `git clone --depth 1 --branch main "$HARNESS_REPO"` → `vendor.sh <target>` (plan) →
  consent → `vendor.sh --apply <target>`. Env: `HARNESS_REPO` (default canonical HTTPS).
- **`scripts/vendor.sh`** → unchanged except **one line**: `bootstrap.sh` appended to the DROP
  array.
- **`README.md`** → the documented one-liner (from-zero entry) + `--yes` CI variant.
- **`docs/vendoring.md`** → cross-reference to `bootstrap.sh` as the pre-`vendor.sh` step.
- **`tests/check_88_bootstrap.sh`** → hermetic exercise (D9), `DEPFREE` (no toolchain / no
  manifest), `HANDOFF-DOC` (grep README + docs). Sourced automatically by `run.sh`.

## Risks

- **`/dev/tty` unavailable in the test harness** — the interactive `[y/N]` path cannot be faked
  hermetically. → Mitigation: automate the two *deterministic* consent outcomes (`--yes` apply,
  no-TTY abort); the real interactive prompt is `CONFIRM-TTY`, validated at `/uat` and excluded
  from the `/contract` RED set (like `UAT (config)` rows).
- **Network in tests** — a real `git clone` from GitHub would make the suite non-hermetic/flaky.
  → Mitigation: `HARNESS_REPO` override points at a local checkout; the suite never hits the
  network (D3/D9).
- **Partial state on early abort** — aborting after the clone could leak a temp dir. →
  Mitigation: preconditions abort *before* the clone (D6); `trap` covers the rest (D7).
- **`APPLY-YES` drift from `vendor.sh`** — the wrapper could diverge from a direct apply. →
  Mitigation: the test diffs bootstrap's result against a reference `vendor.sh --apply` on the
  same source, so equivalence is asserted, not assumed.
- **Raw URL not reachable** — hosting is out of scope; a wrong/placeholder URL would break the
  real one-liner. → Mitigation: `HARNESS_REPO` default is the canonical repo; the documented
  URL and hosting are an operational follow-up, flagged in the spec.
