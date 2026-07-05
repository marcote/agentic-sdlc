# Coverage — CI-gate for the North Star amendment

> Traceability matrix = source of truth for the status of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** via the mapping in `alignment.md` (`aligned`).

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) · `deferred` (justified gap)
· `UAT (config)` = GitHub config, not unit-testable — validated in `/uat`, not in `/contract`.

No `base/pattern` applies as `[given]` (no writes/API/rate-limit in a bash checker).

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked Test/Eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` · `measurable-impact` | Gate amendments by deterministic CI | Gate script: detects change of pillars/scope sets, requires ADR | AMEND-BLOCK-NO-ADR | project | `check_95_amendment_gate.sh` | 🟢 green |
| `real-enforcement` · `measurable-impact` | Gate amendments by deterministic CI | Gate script: passes with ADR + schema + suite | AMEND-PASS-WITH-ADR | project | `check_95_amendment_gate.sh` | 🟢 green |
| `real-enforcement` | Gate amendments by deterministic CI | Gate script: does not require ADR for prose/threshold | AMEND-NO-ADR-FOR-PROSE | project | `check_95_amendment_gate.sh` | 🟢 green |
| `real-enforcement` | Gate amendments by deterministic CI | Gate script: detection by sets, not by text | AMEND-SET-SEMANTICS | project | `check_95_amendment_gate.sh` | 🟢 green |
| `real-enforcement` · `measurable-impact` | Gate amendments by deterministic CI | Gate script: requires schema-valid North Star | AMEND-SCHEMA-VALID | project | `check_95_amendment_gate.sh` | 🟢 green |
| `real-enforcement` | Gate amendments by deterministic CI | Gate script: requires green suite | AMEND-SUITE-GREEN | project | `check_95_amendment_gate.sh` | 🟢 green |
| `real-enforcement` | Narrow block (preserves principle 4) | Gate does not block work that does not touch pillars/scope | DEV-UNBLOCKED | project | `check_95_amendment_gate.sh` | 🟢 green |
| `real-enforcement` | Narrow block (preserves principle 4) | Constitution delta declares the exception | CONST-EXCEPTION | project | `check_95_amendment_gate.sh` (grep constitution) | 🟢 green |
| `agnostic-portability` | Dependency-free + self-check green | No new runtime deps | DEP-FREE | project | `check_95_amendment_gate.sh` (gate without toolchain + no manifests) | 🟢 green |
| `agnostic-portability` | Dependency-free + self-check green | Wiring covered (script + workflow exist) | SELF-CHECK | project | `check_95_amendment_gate.sh` + `check_40/70` | 🟢 green |
| `real-enforcement` | Truly blocking (branch protection) | Action + branch protection require the status-check | AMEND-BLOCK-REAL | project | UAT walk (red PR not mergeable) | ✅ uat |
| `real-enforcement` | Truly blocking (branch protection) | Branch protection prohibits bypass on direct push | AMEND-BLOCK-PUSH | project | UAT walk (direct push rejected) | ✅ uat |

**No orphan rows:** every brief objective maps to ≥1 criterion with a pillar; every
criterion has a test (`/contract`) or UAT walk. Spec freezable.

**All 10 deterministic criteria are 🔴 RED verified** (`bash tests/run.sh` → all FAIL due to
gate/workflow/constitution delta absent) and advance to `🟢 green` only when the impl
puts them green. `DEP-FREE` was tied to the deliverable (the gate must exist and not invoke
installable toolchains) instead of being a mere repo green-by-construction guardrail —
so it has a genuine RED phase like the rest.
