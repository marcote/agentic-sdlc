# Coverage — North Star engine

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** via the mapping in `alignment.md` (`aligned`).

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) · `deferred` (justified gap)

No `base/pattern` applies as `[given]`: the engine is a stateless dev-time function library
(no write endpoints, retries/webhooks/payments, or network surface) — audit-logging /
idempotency / rate-limiting do not fire.

`/contract` done: `check_82_north_star_engine.sh` materialises 18 criteria and **all are 🔴 RED**
(`bash tests/run.sh` → 18 FAIL, engine absent + gate not yet rewired), proven real. The 19th,
`GATE-REGRESSION`, is a **must-not-regress guard**: `check_95` is green now and must stay green
through the rewire (no RED arc by nature — breaking the gate to make it red would be theater).

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | schema-valid: accepts a valid North Star | SCHEMA-VALID | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | schema-valid: rejects invalid with reason | SCHEMA-INVALID | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | schema-valid: malformed → exit 2, not exit 1 | SCHEMA-MALFORMED | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | sets-changed: detects governed-set change | SETS-CHANGED | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | sets-changed: prose/threshold → same | SETS-SAME-PROSE | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | sets-changed: set-based, order-agnostic | SETS-ORDER-AGNOSTIC | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | scope-reject: full-predicate substring hit | SCOPE-HIT | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | scope-reject: conservative — partial ≠ hit | SCOPE-MISS-PARTIAL | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | scope-reject: case/whitespace normalization | SCOPE-NORMALIZE | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | align-verdict: scopeHit → rejected | VERDICT-REJECTED | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | align-verdict: orphan → blocked | VERDICT-BLOCKED | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | align-verdict: all dims ≥ threshold → aligned | VERDICT-ALIGNED | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | align-verdict: a dim < threshold → needs-amendment | VERDICT-NEEDS-AMENDMENT | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | has-adr-for: matching ADR present | ADR-PRESENT | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` · `frictionless-adoption` | In-repo py3 reference engine | has-adr-for: no ADR / non-slug ≠ match | ADR-ABSENT | project | `check_82_north_star_engine.sh` | 🔴 red |
| `real-enforcement` | amendment-gate reuses the engine (no dup) | Gate calls engine.py; embedded heredoc removed | GATE-REUSE | project | `check_82_north_star_engine.sh` (grep gate) | 🔴 red |
| `real-enforcement` | amendment-gate reuses the engine (no dup) | Gate behavior identical after rewire | GATE-REGRESSION | project | `check_95_amendment_gate.sh` | 🟢 green (guard) |
| `agnostic-portability` | Dependency-free (py3 stdlib) | Engine imports only stdlib; no Node/pip | DEP-FREE | project | `check_82_north_star_engine.sh` | 🔴 red |
| `agnostic-portability` | Self-check green | Suite exercises the engine and stays green | SELF-CHECK | project | `tests/run.sh` + `check_82_north_star_engine.sh` | 🔴 red |

**No orphan rows:** every brief objective (O1 in-repo engine, O2 gate reuse, O3
dependency-free, + self-check green) maps to ≥1 criterion with a pillar; every criterion
has a deterministic test. Spec freezable.

**Invariant tied to deliverable:** `DEP-FREE` is bound to the engine existing at
`scripts/north-star/engine.py` and importing only stdlib (not a repo-wide
green-by-construction guardrail) — so it has a genuine RED→GREEN arc (`/contract` proves it
RED because the module does not exist yet).
