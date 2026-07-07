# Coverage — One-command bootstrap for from-zero adoption

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** via the mapping in `alignment.md` (`aligned`).

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) · `deferred` (justified gap)

No `base/pattern` applies as `[given]`: `bootstrap.sh` is a mechanical wrapper (no write
endpoints, retries/webhooks/payments, or audited user actions). All criteria are deterministic
and hermetic via `check_88_bootstrap.sh` (the fetch runs against a local checkout through the
`HARNESS_REPO` override — no real network), except `CONFIRM-TTY`, which is UAT-only because a
real terminal prompt cannot be faked hermetically.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `frictionless-adoption` | One-command bootstrap (fetch→plan→confirm→apply→cleanup) | Clone harness into temp, no manual clone | FETCH | project | `check_88_bootstrap.sh` | ✅ uat |
| `real-enforcement` · `frictionless-adoption` | Preserve dry-run-first safety | Plan printed before any write | PLAN-FIRST | project | `check_88_bootstrap.sh` | ✅ uat |
| `frictionless-adoption` | One-command bootstrap | `--yes` apply == direct `vendor.sh --apply` | APPLY-YES | project | `check_88_bootstrap.sh` | ✅ uat |
| `real-enforcement` | Preserve dry-run-first safety | No TTY + no `--yes` → abort, target unchanged | NOTTY-ABORT | project | `check_88_bootstrap.sh` | ✅ uat |
| `frictionless-adoption` | One-command bootstrap (cleanup) | Temp clone removed on apply and abort paths | CLEANUP | project | `check_88_bootstrap.sh` | ✅ uat |
| `agnostic-portability` | Dependency-free wrapper (git + bash) | `git` absent → clear error, nothing written | GIT-REQUIRED | project | `check_88_bootstrap.sh` | ✅ uat |
| `agnostic-portability` | `bootstrap.sh` added to vendor DROP | `bootstrap.sh` not vendored into a target | DROP-SELF | project | `check_88_bootstrap.sh` | ✅ uat |
| `agnostic-portability` | Dependency-free wrapper | bootstrap.sh: git + bash/coreutils only, no manifest | DEPFREE | project | `check_88_bootstrap.sh` | ✅ uat |
| `frictionless-adoption` | Documented one-liner | README + docs/vendoring.md document `curl…\| bash` (+ `--yes`) | HANDOFF-DOC | project | `check_88_bootstrap.sh` | ✅ uat |
| `real-enforcement` | Preserve dry-run-first safety | Interactive `[y/N]` from /dev/tty; N aborts, y applies | CONFIRM-TTY | project | `verification/uat-checklist.md` | ✅ uat |
| `agnostic-portability` · `real-enforcement` | Self-check green | Suite exercises bootstrap.sh hermetically and stays green | SELF-CHECK | project | `tests/run.sh` + `check_88_bootstrap.sh` | ✅ uat |

**No orphan rows:** every brief objective (one-command bootstrap, dry-run-first safety,
dependency-free/DROP wrapper, documented one-liner) maps to ≥1 criterion with a pillar; every
criterion has a deterministic test (or, for `CONFIRM-TTY`, a UAT step). Spec freezable.

**RED plan (for `/contract`):** all 10 deterministic criteria redden together — `bootstrap.sh`
does not exist yet, so `check_88_bootstrap.sh` fails honestly. `DEPFREE` is an **invariant tied
to the deliverable** (`bootstrap.sh` existing and invoking no toolchain): a genuine RED→GREEN
arc, not green-by-construction. `CONFIRM-TTY` is **UAT-observed**, excluded from the
`/contract` RED-required set (like the `UAT (config)` rows), since a real terminal prompt has no
honest hermetic RED.

Implementation done: **all 10 deterministic criteria 🟢 GREEN** (`bash tests/run.sh` → 234 PASS,
0 FAIL; was 223/10 at RED). `DEPFREE` had a genuine RED→GREEN arc — it failed at `/contract`
because `bootstrap.sh` did not exist. `CONFIRM-TTY` stays `deferred → uat` for `/uat`.
