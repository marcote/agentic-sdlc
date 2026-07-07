# Spec — One-command bootstrap for from-zero adoption

> WHAT is built. Produced by `/distill` from `brief.md`. Frozen when `coverage.md` has no
> orphan rows. Gate: `alignment.md` verdict = `aligned` (run on the 006 engine).

## Functional requirements

1. **`bootstrap.sh [--yes|-y] [target]`.** A thin wrapper, at the **harness repo root**, that
   lands the harness onto `target` (default = current directory `.`) in one gesture. It
   **reuses `scripts/vendor.sh` unchanged** — it does not reimplement classification, stack
   detection, or provenance. Dependency-free: `git` + `bash`/coreutils only.
2. **Fetch.** Clone the harness into a fresh temp dir via
   `git clone --depth 1 --branch main "$HARNESS_REPO" <tmp>`. `HARNESS_REPO` defaults to
   `https://github.com/marcote/agentic-sdlc.git` (HTTPS — a `curl | bash` newcomer has no SSH
   key) and is **env-overridable** (for forks and for hermetic tests pointing at a local
   checkout). No manual clone by the user. Pinning/`--ref` is out of scope (tracks `main`; the
   provenance SHA records exactly what landed).
3. **Plan first (reuse 007 dry-run).** Run `<tmp>/scripts/vendor.sh <target>` (dry-run) and
   let its plan — KEEP / SEED / DROP, detected stack + test command, provenance — print to
   stdout **before anything is written** to the target.
4. **Confirm (preserve 007's dry-run-first safety).** After the plan:
   - **Interactive (`target`/stdin has a TTY):** read a `[y/N]` answer from **`/dev/tty`**
     (stdin is taken by the `curl | bash` pipe). `y`/`Y` → apply; anything else (default) →
     abort.
   - **`--yes`/`-y`:** explicit non-interactive consent — apply without prompting (the plan is
     still printed first). The legitimate CI/automation path.
   - **No TTY and no `--yes`:** **abort** with a message (never apply blind); non-zero exit.
5. **Apply.** On consent, run `<tmp>/scripts/vendor.sh --apply <target>`. The result is
   **identical to running `vendor.sh --apply` from a manual clone**: governance landed,
   `.harness-provenance` stamped, `.harness-new` for collisions, hand-off to `/constitution`.
6. **Cleanup (always).** A `trap` removes the temp clone on **every** exit path — applied,
   aborted, or errored.
7. **git required.** If `git` is not on `PATH`, abort early with a clear message; write nothing.
8. **`bootstrap.sh` is DROP.** Add `bootstrap.sh` to `scripts/vendor.sh`'s DROP list — like
   `vendor.sh` itself, it is harness tooling and is **never vendored into a target**.
9. **Documented one-liner.** The `curl -fsSL <raw>/bootstrap.sh | bash` invocation (and the
   `-s -- --yes` CI variant) is documented in `README.md` (the harness front door) and
   cross-referenced from `docs/vendoring.md`. Actually hosting/reaching the raw URL is an
   operational step, out of scope — the feature ships the script and its documented usage.

## User stories

- As a **newcomer starting from zero** I want a single command that fetches the harness and
  lands it on my repo, so adoption does not start with undocumented "clone this by hand".
- As an **adopter** I want the plan shown and a confirmation before anything is written, so the
  one-gesture convenience does not cost me the dry-run-first safety `vendor.sh` gives.
- As a **CI/automation user** I want an explicit `--yes` to apply non-interactively, while a
  bare non-interactive run refuses rather than writing blind.

## Edge cases (80% problem)

- **`curl | bash` pipe holds stdin:** the confirmation is read from `/dev/tty`, not stdin.
- **No TTY, no `--yes`** (CI without opt-in, piped with no terminal): abort, nothing written.
- **`--yes` present:** applies even with no TTY; plan still printed first (plan-first intact).
- **Decline (`N`/empty/anything non-`y`):** abort, target byte-for-byte unchanged.
- **`git` absent:** clear error, nothing written (dep is real, not silent).
- **Temp clone leak:** trap guarantees removal on apply, abort, and error paths.
- **Self-leak:** `bootstrap.sh` must not appear in a vendored target (it is DROP).
- **Fork / test source:** `HARNESS_REPO` override lets the clone come from a non-canonical
  remote or a local checkout, without a `--ref` user flag.

## Open questions / deferred

- **Version pinning / `--ref`:** deferred — tracks `main`; provenance SHA is the record.
  Tagging/releases justify a pinned bootstrap only once external adopters exist.
- **Package-manager distribution (pipx/npx):** out of scope — would break the `bash`-only
  baseline and add publishing surface.
- **Hosting the raw URL:** operational, not code; the feature delivers the script + docs.
- **Changes to `vendor.sh`/`engine.py`:** none beyond adding `bootstrap.sh` to the DROP list —
  the motor stays as 006/007 left it.
