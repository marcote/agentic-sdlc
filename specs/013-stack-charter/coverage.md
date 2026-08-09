# Coverage — Stack Charter: no load-bearing decision stays mute

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → a criterion; every criterion → an eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** via the mapping in `alignment.md` (`aligned`, 5/4/4).

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited from constitution) · `deferred` (justified gap)

`base/pattern` seeding: **`idempotency`** applies (re-running `/stack` is a repeatable write over
an existing charter), **`audit-logging`** applies (a pin amendment is a state write that must
leave a trail), **`hermetic-tests`** applies for `hermetic-env` (the suite creates temp fixtures
and must pass detached-HEAD / no-TTY) but its `hermetic-offline` criterion is `deferred` — 013
reaches no network or remote source, so there is no external dependency to put behind an
override seam. **`rate-limiting`** does not apply: no network-exposed surface.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `measurable-impact` · `real-enforcement` | O1 no assumption stays mute | `memory/stack/` + `/stack` command & skill, positioned in the loop | STACK-CMD | project | `check_92_stack.sh` | no contract |
| `measurable-impact` · `real-enforcement` | O1 no assumption stays mute | A pin is well-formed only with Confidence/Because/Buys/Forecloses/Falsifier | PIN-SHAPE | project | `check_92_stack.sh` | no contract |
| `measurable-impact` · `real-enforcement` | O3 uncertainty pays a verifiable hedge | A PROVISIONAL pin carries a non-empty Hedge | PROVISIONAL-HEDGE | project | `check_92_stack.sh` | no contract |
| `agnostic-portability` | O4 adopter opinions enforceable, no stack prescribed | A [stance] pin names a Guard command + Injects clause | STANCE-GUARD | project | `check_92_stack.sh` | no contract |
| `real-enforcement` · `agnostic-portability` | O4 adopter opinions enforceable | `/verify` runs each stance Guard and requires exit 0 | GUARD-RUNS | project | `check_92_stack.sh` + `tests/run.sh` | no contract |
| `real-enforcement` | O2 stop the feature at the step that can act | `/plan` fails closed: PASS / UNPINNED / TRIPPED, never silence | PLAN-GATE | project | `check_92_stack.sh` | no contract |
| `real-enforcement` | O2 stop the feature at the step that can act | UNPINNED minting a stance pin bounces back to `/distill` | PLAN-BOUNCE | project | `check_92_stack.sh` | no contract |
| `measurable-impact` · `real-enforcement` | O2 · O3 the honest bill | TRIPPED reports criterion×pin, declared cost, hedge-exists, two paths | TRIPPED-BILL | project | `check_92_stack.sh` | no contract |
| `measurable-impact` | O1 no assumption stays mute | S0 is the first pin, blast-radius-derived, carries a Falsifier | S0-PIN | project | `check_92_stack.sh` | no contract |
| `real-enforcement` | O1 · O4 rigor without softening the rules | S0 scales scope only; RED gate, 100% coverage and the P6 floor do not scale | S0-SCOPE-ONLY | project | `check_92_stack.sh` | no contract |
| `agnostic-portability` | O4 no stack prescribed | No tool/language/runtime/vendor named as a required default in `memory/stack/base/` | NO-PRESCRIBE | project | `check_92_stack.sh` | no contract |
| `real-enforcement` | O3 hedge is verified, not written | `/distill` step 1 injects [stance] pins' Injects rows | DISTILL-STANCE | project | `check_92_stack.sh` | no contract |
| `agnostic-portability` · `frictionless-adoption` | O4 the mechanism vendors, the pins do not | `vendor.sh`: `memory/stack/base/` KEEP, `stack.md` SEED, CLAUDE.md `## Stack` points at charter | VENDOR-STACK | project | `check_92_stack.sh` | no contract |
| `measurable-impact` | O5 charter health backed by evidence | `wow-report` emits pins-tripped vs rework-with-no-pin | WOW-HEALTH | project | `check_92_stack.sh` | no contract |
| `real-enforcement` · `measurable-impact` | O1 (D3 reflexive dogfood) | The harness's own live decisions are pinned (py3 engine, bash-only, no-runtime) | CHARTER-SEED | project | `check_92_stack.sh` | no contract |
| — | — | Re-running `/stack` does not duplicate or drop pins; SUPERSEDED preserved | RERUN-IDEMPOTENT | `[given] base/idempotency` | `check_92_stack.sh` | no contract |
| — | — | Each amended pin records date + reason + what tripped it | AMEND-TRAIL | `[given] base/audit-logging` | `check_92_stack.sh` | no contract |
| — | — | Suite builds own fixtures; passes detached-HEAD, no-TTY | HERMETIC-ENV | `[given] base/hermetic-tests` | `check_92_stack.sh` | no contract |
| — | — | External dependency behind an override seam | (hermetic-offline) | `[given] base/hermetic-tests` | — | `deferred` — 013 reaches no network or remote source |
| `real-enforcement` | O2 the TRIPPED verdict is judged, not matched | Judge fires on a real falsifier match, stays silent on keyword overlap | JUDGE-TRIPPED | project | `evals/cases/stack-charter-judge.md` | 📋 case |
| `real-enforcement` | O1 the set must cohere, not just the pins | Judge objects on an incoherent set, returns explicit "coherent" otherwise — never silence | JUDGE-COHERENCE | project | `evals/cases/stack-charter-judge.md` | 📋 case |
| `measurable-impact` | O3 the hedge must stay ~free | Judge rejects a hedge costing real design work as premature abstraction | JUDGE-HEDGE-COST | project | `evals/cases/stack-charter-judge.md` | 📋 case |

**No orphan rows:** every brief objective (O1 mute assumptions, O2 stop-at-the-actionable-step,
O3 verifiable hedge, O4 enforceable-without-prescribing, O5 charter health) maps to ≥1 criterion
carrying a pillar. Every criterion has a deterministic test or an eval case. The one `deferred`
row is justified above. **Spec freezable.**

**RED plan (for `/contract`):** all 18 deterministic criteria redden together — `memory/stack/`,
`.claude/commands/stack.md` and `.claude/skills/stack/SKILL.md` do not exist, so
`check_92_stack.sh` fails honestly on first run.

- **`NO-PRESCRIBE` is an invariant tied to the deliverable** (`memory/stack/base/` existing):
  a genuine RED→GREEN arc per Principle 2, not green-by-construction — the check cannot pass
  before there is a directory to scan.
- **`GUARD-RUNS` carries the same risk it is meant to catch.** A `Guard` that greps a directory
  which does not exist passes vacuously. Its fixture must include a stance pin whose Guard
  *fails* on a violating tree, or the criterion certifies nothing.
- **`NO-PRESCRIBE` must be code-span aware.** The pin template necessarily contains example
  pins naming DuckDB, Postgres and Railway; a naive grep fails on its own documentation. This
  is the exact blind spot fixed in `check_90` (`e6bc658`) — reuse that idiom.
- **The three `📋 case` rows are not in the RED-required set** (non-deterministic, per the
  `UAT (config)` precedent); they are exercised at `/verify` as eval cases.

**Prediction carried to `/retro`** (from `alignment.md`): `frictionless-adoption` was
deliberately not claimed — this feature adds a workflow step and a third `memory/` store, moving
that signal the wrong way. The trade is only worth it if `measurable-impact` shows a
compensating gain in rework avoided, and at close there will be `N=1` charter datapoint.
`/retro` must rule on that trade explicitly, not only on the pillars the brief claims.
