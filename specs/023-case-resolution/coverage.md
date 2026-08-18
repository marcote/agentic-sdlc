# Coverage — 023-case-resolution

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 a resolving row passes and says so | R1 · edge 7 | CASE-RESOLVES-CLEAN | project | `tests/check_93_case_resolution.sh` | ✅ uat |
| `real-enforcement` | O1 a named file that is gone | R1 · edge 1 | CASE-MISSING-FILE | project | idem | ✅ uat |
| `real-enforcement` | O2 a row naming nothing | R1 · edge 2 | CASE-NO-PATH | project | idem | ✅ uat |
| `real-enforcement` | O1 the row binds to its own case | R1 · edge 3 | CASE-LABEL-BINDS | project | idem | ✅ uat |
| `measurable-impact` | O3 the mirror direction | R2 · edge 4 | CASE-ORPHAN-FILE-REPORTED | project | idem | ✅ uat |
| `agnostic-portability` | O1 a matrix that is not seven columns | R3 · edge 5 | CASE-COLUMNS-BY-HEADER | project | idem | ✅ uat |
| `real-enforcement` | O1 a matrix it cannot understand | R3 | CASE-HEADER-UNREADABLE | project | idem | ✅ uat |
| `measurable-impact` | O4 the count that produced B14's 32 | R6 · edge 8 | CASE-LEGEND-NOT-COUNTED | project | idem | ✅ uat |
| `real-enforcement` | O1 one file, several rows | R1 · edge 6 | CASE-MULTI-ROW-FILE | project | idem | ✅ uat |
| `real-enforcement` | O1 the three broken rows are fixed | R4 | CASE-REPO-CLEAN | project | idem | ✅ uat |
| `real-enforcement` | O5 a gate accepted and never run | R5 | CASE-WIRED | project | idem | ✅ uat |
| `frictionless-adoption` | O6 no toolchain | R7 | CASE-DEPFREE | project | idem | ✅ uat |
| `frictionless-adoption` | O6 the cost is measured | R7 | CASE-COST-REPORTED | project | idem | ✅ uat |
| `measurable-impact` | O3 was the count ever the obstacle | — | JUDGE-CASES-NOW-COUNTABLE | project | `evals/cases/cases-now-countable.md` | 📋 case |
| `real-enforcement` | O1 | each rule has a negative | check-can-fail | `[given] base/non-vacuous-checks` | → the 13 declarations themselves | ✅ uat |
| `real-enforcement` | O1 | a criterion of this feature declares a mutation | mutation-declared | `[given] base/non-vacuous-checks` | → `mutate.sh coverage --spec` | ✅ uat |
| `real-enforcement` | O1 | rejection requires the named diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → CASE-HEADER-UNREADABLE | ✅ uat |
| `real-enforcement` | O3 | the tool names the tree it read | check-names-its-tree | `[given] base/non-vacuous-checks` | → CASE-ORPHAN-FILE-REPORTED | ✅ uat |
| `real-enforcement` | O1 | a scan must not match its own declaration | check-no-self-match | `[given] base/non-vacuous-checks` | → CASE-LEGEND-NOT-COUNTED | ✅ uat |
| `agnostic-portability` | O6 | hermetic under CI conditions | HERMETIC-ENV-93 | `[given] base/hermetic-tests` | `tests/check_93_case_resolution.sh` | ✅ uat |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |
| — | — | `S2` engine reachable only by CLI | S2-HEDGE | `[given] stack/S2 Hedge` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — no network, no remote, no live service. `HERMETIC-ENV-93` carries the
  ambient-environment half, which is the one this feature can violate.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`; this feature touches
  `scripts/`, `tests/`, `evals/cases/`, a skill and the backlog, and names no tool as a default.
- **`S2-HEDGE`** — `S2`'s `Hedge` governs the stack engine's CLI boundary; `cases.sh` is a shell
  script that imports nothing from it.

## The measurement this matrix is about

Taken at `/distill`, re-derivable with `scripts/cases.sh`:

| | |
|---|---|
| `📋 case` rows | **14** |
| resolve | 11 |
| name a file that does not exist | 2 |
| name no path | 1 |
| file does not name the row's criterion | 0 |
| case files cited by no row | 0 |

`B14` claimed **32** rows and **21** unresolvable. Both came from a grep that counted the
status-legend line in all 19 matrices.
