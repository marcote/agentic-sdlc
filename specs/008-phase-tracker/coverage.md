# Coverage — Derived phase-tracker (`scripts/status.sh`)

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** via the mapping in `alignment.md` (`aligned`).

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) · `deferred` (justified gap)

No `base/pattern` applies as `[given]`: `status.sh` reads files (no write endpoints / network).
All criteria deterministic, hermetic via `check_86_status.sh` against temp repo fixtures.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` · `frictionless-adoption` | Derived phase-tracker | Doc-phase done from artifacts | PHASE-DERIVE | project | `check_86_status.sh` | ✅ uat |
| `real-enforcement` | Derived phase-tracker | Template stub → pending (not presence-only) | NON-PLACEHOLDER | project | `check_86_status.sh` | ✅ uat |
| `real-enforcement` | Derived phase-tracker | Gate-phase done from coverage states | COVERAGE-DERIVED | project | `check_86_status.sh` | ✅ uat |
| `frictionless-adoption` | Derived phase-tracker | Names current phase + next command | CURRENT-NEXT | project | `check_86_status.sh` | ✅ uat |
| `frictionless-adoption` | Derived phase-tracker | Complete feature → DONE, exit 0 | DONE-FEATURE | project | `check_86_status.sh` | ✅ uat |
| `real-enforcement` | Derived phase-tracker | Out-of-order → ⚠ anomaly + non-zero exit | ANOMALY-FLAG | project | `check_86_status.sh` | ✅ uat |
| `frictionless-adoption` | Derived phase-tracker | Coherent WIP → exit 0 | NORMAL-EXIT0 | project | `check_86_status.sh` | ✅ uat |
| `real-enforcement` · `frictionless-adoption` | Derived phase-tracker | Surfaces coverage gaps (non-green + orphan) | GAPS | project | `check_86_status.sh` | ✅ uat |
| `real-enforcement` | Derived phase-tracker | Read-only (mutates nothing) | READONLY | project | `check_86_status.sh` | ✅ uat |
| `frictionless-adoption` | Derived phase-tracker | Unknown feature → clear error, non-zero | UNKNOWN-FEATURE | project | `check_86_status.sh` | ✅ uat |
| `agnostic-portability` | Dependency-free | status.sh: bash/coreutils + python3 only | DEPFREE | project | `check_86_status.sh` | ✅ uat |
| `real-enforcement` | Shared DEPFREE helper (cand. B) | lib.sh helper + check_82/84/95/86 use it | HELPER-SHARED | project | `check_86_status.sh` | ✅ uat |
| `agnostic-portability` | Self-check green | Suite exercises status.sh and stays green | SELF-CHECK | project | `tests/run.sh` + `check_86_status.sh` | ✅ uat |

**No orphan rows:** every brief objective (phase-tracker O1, shared helper O2) maps to ≥1
criterion with a pillar; every criterion has a deterministic test. Spec freezable.

Implementation done: **all 13 criteria 🟢 GREEN** (`bash tests/run.sh` → 216 PASS, 0 FAIL).

**Plan deviation (D3), honestly recorded:** the placeholder detection was planned to reuse
`check_90`'s regex `_\(...\)_|<...>`. Dogfooding `status.sh` on its own in-flight feature
surfaced two false positives — `<feature>` (legit CLI notation in specs) and a spec that
*documents* the `_(...)_` marker in a code span. Fix: detect only `_(...)_`, and strip
backtick code spans first. Narrower than `check_90` on purpose (that guards `retro.md`, which
has no such content).

**Invariant tied to deliverable:** `DEPFREE` is bound to `scripts/status.sh` existing — a
genuine RED→GREEN arc (`/contract` proved it RED because the script did not exist yet).
