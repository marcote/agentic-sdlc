# Tasks — One-command bootstrap for from-zero adoption

> Executable decomposition. `/tasks` GATE passed: every deterministic coverage row has a
> linked test in 🔴 RED (`check_88_bootstrap.sh`). Each task lists the criteria it turns GREEN.
> Order: implement `bootstrap.sh` core → vendor DROP edit → docs. Re-run `bash tests/run.sh`
> after each; done when all 10 deterministic criteria are 🟢 and the full suite stays green.

## T1 — `bootstrap.sh` skeleton + fail-closed preconditions
Create `bootstrap.sh` at repo root. Parse `[--yes|-y] [target]` (target default `.`).
Resolve `HARNESS_REPO` (default `https://github.com/marcote/agentic-sdlc.git`) and
`HARNESS_REF` (default `main`). **First**: `command -v git` — if absent, print a clear
`git required` message and exit non-zero, writing nothing (abort before any clone).
- Criteria: **GIT-REQUIRED**, **DEPFREE** (git + bash/coreutils only, no toolchain).

## T2 — Consent gate (`--yes` / `/dev/tty` / no-TTY abort)
Decide consent **before** applying: `--yes` → yes; else attempt to read a `[y/N]` line from
`/dev/tty` (default/non-`y` → abort); if `/dev/tty` cannot be opened (no controlling
terminal) and no `--yes` → abort with a message + non-zero exit. Never write blind.
- Criteria: **NOTTY-ABORT** (and **CONFIRM-TTY** at `/uat`).

## T3 — Fetch + cleanup (temp clone)
`tmp=$(mktemp -d)`; register `trap 'rm -rf "$tmp"' EXIT INT TERM` immediately.
`git clone --depth 1 --branch "$HARNESS_REF" "$HARNESS_REPO" "$tmp"`. Precondition aborts
(T1/T2) must happen before the clone so nothing is left to clean.
- Criteria: **FETCH**, **CLEANUP**.

## T4 — Plan-first, then apply
Run `"$tmp/scripts/vendor.sh" "$target"` (dry-run) so the KEEP/SEED/DROP + stack + provenance
plan prints to stdout. Only on consent, run `"$tmp/scripts/vendor.sh" --apply "$target"`.
Result must equal a direct `vendor.sh --apply` (governance + `.harness-provenance`).
- Criteria: **PLAN-FIRST**, **APPLY-YES**.

## T5 — `vendor.sh` DROP edit
Append `bootstrap.sh` to `scripts/vendor.sh`'s DROP array (one line), so the dry-run plan
classifies it as DROP and it is never vendored into a target. Only edit to `vendor.sh`.
- Criteria: **DROP-SELF**.

## T6 — Docs: README one-liner + vendoring.md cross-ref
`README.md`: document `curl -fsSL <raw>/bootstrap.sh | bash` as the from-zero entry, plus the
`... | bash -s -- --yes` CI variant. `docs/vendoring.md`: cross-reference `bootstrap.sh` as the
step **before** a manual `vendor.sh`.
- Criteria: **HANDOFF-DOC**.

## T7 — Green the suite
`bash tests/run.sh` → all 10 deterministic criteria 🟢, total FAIL back to 0 (was 10).
Update `coverage.md` states 🔴→🟢. `check_88_bootstrap.sh` is auto-sourced by `run.sh` (no wiring).
- Criteria: **SELF-CHECK** + confirms all above.
