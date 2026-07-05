# Coverage — Vendoring the harness onto an existing repo

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** via the mapping in `alignment.md` (`aligned`).

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) · `deferred` (justified gap)

No `base/pattern` applies as `[given]`: `vendor.sh` copies files (no write endpoints,
retries/webhooks/payments, or network surface). All criteria deterministic, hermetic via
`check_84_vendor.sh` against a temp target.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `frictionless-adoption` | Dry-run plan without writing | Default = dry-run, read-only | DRYRUN-NOWRITE | project | `check_84_vendor.sh` | 🔴 red |
| `frictionless-adoption` | Dry-run plan without writing | Plan lists keep/seed/drop + stack + provenance | DRYRUN-PLAN | project | `check_84_vendor.sh` | 🔴 red |
| `frictionless-adoption` · `agnostic-portability` | Copy-once vendoring | KEEP governance copied verbatim (incl. 006 engine) | KEEP-COPIED | project | `check_84_vendor.sh` | 🔴 red |
| `frictionless-adoption` | Copy-once vendoring | KEEP overwrites on re-run (idempotent, authoritative) | KEEP-OVERWRITE | project | `check_84_vendor.sh` | 🔴 red |
| `frictionless-adoption` | Copy-once vendoring | Harness-self content not copied | DROP-ABSENT | project | `check_84_vendor.sh` | 🔴 red |
| `frictionless-adoption` | Copy-once vendoring | SEED stubs created when absent | SEED-STUB | project | `check_84_vendor.sh` | 🔴 red |
| `frictionless-adoption` · `agnostic-portability` | Non-destructive seed | Existing SEED never clobbered; `.harness-new` alongside | SEED-NOCLOBBER | project | `check_84_vendor.sh` | 🔴 red |
| `agnostic-portability` · `frictionless-adoption` | Stack detection → test cmd | Detect stack, seed `scripts/test.sh`; unknown → TODO | STACK-DETECT | project | `check_84_vendor.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | Stamp provenance | `.harness-provenance`: SHA-or-non-git + date + `.harness-new` list | PROVENANCE | project | `check_84_vendor.sh` | 🔴 red |
| `agnostic-portability` | Dependency-free | vendor.sh: bash/coreutils + python3 only, no manifest | DEPFREE | project | `check_84_vendor.sh` | 🔴 red |
| `frictionless-adoption` | Hands off to the workflow | `docs/vendoring.md` documents buckets, plugs, first step | HANDOFF | project | `check_84_vendor.sh` | 🔴 red |
| `agnostic-portability` | Self-check green | Suite exercises vendor.sh hermetically and stays green | SELF-CHECK | project | `tests/run.sh` + `check_84_vendor.sh` | 🔴 red |

**No orphan rows:** every brief objective (copy-once, dry-run, non-destructive, provenance,
stack-detect, handoff, dep-free) maps to ≥1 criterion with a pillar; every criterion has a
deterministic test. Spec freezable.

**Invariant tied to deliverable:** `DEPFREE` is bound to `scripts/vendor.sh` existing and
invoking no toolchain — a genuine RED→GREEN arc (`/contract` proves it RED because the script
does not exist yet).
