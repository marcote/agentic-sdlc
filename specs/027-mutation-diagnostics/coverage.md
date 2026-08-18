# Coverage — 027-mutation-diagnostics

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 stale is its own outcome | R1 | MUT-STALE-NAMED | project | `tests/check_89_mutation_diagnostics.sh` | ✅ uat |
| `real-enforcement` | O3 the verdict does not soften | R2 · gate note 2 | MUT-STALE-NOT-PROVED | project | idem | ✅ uat |
| `real-enforcement` | O1 the old outcome survives | R1 · edge 3 | MUT-WEAK-STILL-SURVIVES | project | idem | ✅ uat |
| `measurable-impact` | O4 weak and stale never added | R3 | MUT-COUNTS-SEPARATE | project | idem | ✅ uat |
| `real-enforcement` | O1 sed rewrites on a no-match | R1 · edge 1 · edge 2 | MUT-BAK-NOT-A-CHANGE | project | idem | ✅ uat |
| `real-enforcement` | O1 inert is not failed | R1 · edge 4 · edge 5 | MUT-APPLY-ERROR-STILL-DISTINCT | project | idem | ✅ uat |
| `real-enforcement` | O2 untracked stops the run | R4 | MUT-UNTRACKED-REFUSED | project | idem | ✅ uat |
| `real-enforcement` | O2 the negative of the pre-flight | R4 | MUT-TRACKED-RUNS | project | idem | ✅ uat |
| `measurable-impact` | O5 the falsification test | R5 · gate note 3 | MUT-STALE-REPLAY-026 | project | idem | ✅ uat |
| `measurable-impact` | O4 a refactor's shape is legible | R3 · edge 7 | MUT-SUMMARY-LEGIBLE | project | idem | ✅ uat |
| `frictionless-adoption` | O6 no toolchain | R6 | MUT-DIAG-DEPFREE | project | idem | ✅ uat |
| `frictionless-adoption` | O6 the cost against the prediction | R6 · gate note 1 | MUT-DIAG-COST | project | idem | ✅ uat |
| `measurable-impact` | O1 does the diagnosis land | — | JUDGE-STALE-READ-FIRST-TIME | project | `evals/cases/stale-read-first-time.md` | 📋 case |
| `real-enforcement` | O1 | each rule has a negative | check-can-fail | `[given] base/non-vacuous-checks` | → the 12 declarations themselves | ✅ uat |
| `real-enforcement` | O1 | a criterion of this feature declares a mutation | mutation-declared | `[given] base/non-vacuous-checks` | → `mutate.sh coverage --spec` | ✅ uat |
| `real-enforcement` | O2 | rejection requires the named diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → MUT-UNTRACKED-REFUSED | ✅ uat |
| `real-enforcement` | O4 | the tool names the tree it read | check-names-its-tree | `[given] base/non-vacuous-checks` | → MUT-SUMMARY-LEGIBLE | ✅ uat |
| `real-enforcement` | O1 | a scan must not match its own declaration | check-no-self-match | `[given] base/non-vacuous-checks` | → MUT-STALE-REPLAY-026 | ✅ uat |
| `agnostic-portability` | O6 | hermetic under CI conditions | HERMETIC-ENV-89 | `[given] base/hermetic-tests` | `tests/check_89_mutation_diagnostics.sh` | ✅ uat |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |
| — | — | `S2` engine reachable only by CLI | S2-HEDGE | `[given] stack/S2 Hedge` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — no network, no remote, no live service. `HERMETIC-ENV-89` carries the
  ambient-environment half.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`; this touches `scripts/`,
  `tests/` and a constitution pattern, and names no tool as a default.
- **`S2-HEDGE`** — `S2`'s `Hedge` governs the stack engine's CLI boundary; `mutate.sh` imports
  nothing from it.
