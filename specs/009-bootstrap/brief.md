# Brief — One-command bootstrap for from-zero adoption

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Give a newcomer a **single gesture that lands the harness on a repo starting from zero** —
`curl -fsSL <raw>/bootstrap.sh | bash`. Today feature 007 resolves everything *after*
"I already have the harness cloned locally"; the very first contact — getting the harness
onto the machine and pointing `vendor.sh` at the target — is unwritten folklore. The
deliverable is `bootstrap.sh`, a thin wrapper that **fetches the harness, shows the
vendoring plan, asks for confirmation, applies, and cleans up after itself** — turning the
from-zero step from "clone this by hand, then find and run its script" into one command
that preserves 007's dry-run-first safety.

## Why / motivation

The from-zero flow has a hole at its most-zero point: **the bootstrap**. To adopt, you must
already have the harness checked out and know to run *its* `vendor.sh` against your target —
and since `vendor.sh` is itself DROP, the newcomer has nothing local to guide them. There
is no one-liner, no published entry point; the "clone the harness first" step lives only in
conversation. A harness that preaches frictionless, inspectable adoption leaves its own
front door undocumented and manual. The bootstrap closes the gap between "I heard about
this" and "I'm at `/constitution`".

## Success metrics

- `curl -fsSL <raw>/bootstrap.sh | bash` run in a target repo **fetches the harness
  (`git clone --depth 1 --branch main`) into a temp dir**, no manual clone required.
- It **prints the full vendoring plan first** (reusing `vendor.sh` dry-run: KEEP / SEED /
  DROP, detected stack, provenance) and **writes nothing** until confirmed.
- It **reads a confirmation from `/dev/tty`** (stdin is taken by the pipe) — `[y]` applies
  via `vendor.sh --apply`, `[N]` (default) aborts leaving the target untouched.
- **No TTY → abort**, never apply blind (CI / non-interactive pipe): coherent with
  plan-first.
- The temp checkout is **always removed** (trap on exit), whether applied or aborted.
- After a `[y]` run the target is **identical to a manual `vendor.sh --apply`** — provenance
  stamped, `.harness-new` for collisions, hand-off to `/constitution`.
- **Engine untouched**: `bootstrap.sh` orchestrates the existing `vendor.sh`; it does not
  reimplement classification, stack detection, or provenance.
- **Dependency-free**: `git` + `bash`/coreutils only, consistent with the harness baseline
  (`git` is already a de-facto from-zero requirement).
- `bootstrap.sh` is added to `vendor.sh`'s **DROP** list — like `vendor.sh` itself, it is
  harness tooling and **never vendored into a target**.

## Out of scope

- **Version pinning / `--ref` override.** Tracks `main` HEAD by decision; the provenance SHA
  records exactly what landed. Tagging/releases and a parametrizable ref are a later feature
  when external adopters justify the release discipline.
- **Package-manager distribution** (pipx / npx). Would break the `bash`-only baseline and add
  publishing/versioning surface. Not now.
- **Re-vendoring / update path.** Inherited from 007's copy-once decision; the bootstrap is a
  first-contact tool, not a sync mechanism.
- **Hosting the URL / publishing.** Making `raw.githubusercontent.com/.../bootstrap.sh`
  reachable is an operational step, not code; the feature delivers the script and its
  documented one-liner.
- **Changes to `vendor.sh` or `engine.py`.** The bootstrap is a wrapper; the motor stays as
  features 006/007 left it.

## Dependency

Depends on **feature 007 (vendoring)**: `bootstrap.sh` reuses `vendor.sh`'s dry-run/`--apply`
separation, plan output, stack detection, and provenance. Without 007 there is nothing to
wrap. This feature adds only *fetch + confirm + cleanup* around that motor.
