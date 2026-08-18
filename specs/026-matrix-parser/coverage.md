# Coverage — 026-matrix-parser

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `measurable-impact` | O1 the table is found by its header | R2 | MTX-HEADER-FOUND | project | `tests/check_91_matrix.sh` | ✅ uat |
| `agnostic-portability` | O2 layout does not change the answer | R2 · edge 1 | MTX-SIX-AND-SEVEN | project | idem | ✅ uat |
| `measurable-impact` | O1 rows come from the matrix only | R3 · edge 2 | MTX-SECOND-TABLE-EXCLUDED | project | idem | ✅ uat |
| `real-enforcement` | O3 a file with no matrix is reported | R4 · edge 3 | MTX-NO-TABLE-REPORTED | project | idem | ✅ uat |
| `measurable-impact` | O1 a label with spaces | R2 · edge 6 | MTX-LABEL-TRIMMED | project | idem | ✅ uat |
| `measurable-impact` | O1 idem stays in range | R3 · edge 5 | MTX-IDEM-IN-RANGE | project | idem | ✅ uat |
| `measurable-impact` | O2 the defect that shipped in 008 | R2 · defect 1 | STATUS-NAMES-CRITERION | project | idem | ✅ uat |
| `measurable-impact` | O2 the phantom orphan | R3 · defect 2 | STATUS-NO-PHANTOM-ORPHAN | project | idem | ✅ uat |
| `measurable-impact` | O1 one reader, three tools | R1 | MTX-SINGLE-READER | project | idem | ✅ uat |
| `measurable-impact` | O4 nothing else moves | R5 | MTX-COVERAGE-UNCHANGED | project | idem | ✅ uat |
| `measurable-impact` | O4 nothing else moves | R5 | MTX-CASES-UNCHANGED | project | idem | ✅ uat |
| `frictionless-adoption` | O5 no toolchain | R6 | MTX-DEPFREE | project | idem | ✅ uat |
| `frictionless-adoption` | O5 the cost is measured | R6 | MTX-COST-REPORTED | project | idem | ✅ uat |
| `measurable-impact` | O1 does one reader hold | — | JUDGE-ONE-READER-HELD | project | `evals/cases/one-reader-held.md` | 📋 case |
| `real-enforcement` | O1 | each rule has a negative | check-can-fail | `[given] base/non-vacuous-checks` | → the 13 declarations themselves | ✅ uat |
| `real-enforcement` | O1 | a criterion of this feature declares a mutation | mutation-declared | `[given] base/non-vacuous-checks` | → `mutate.sh coverage --spec` | ✅ uat |
| `real-enforcement` | O3 | rejection requires the named diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → MTX-NO-TABLE-REPORTED | ✅ uat |
| `real-enforcement` | O1 | the tool names the tree it read | check-names-its-tree | `[given] base/non-vacuous-checks` | → STATUS-NAMES-CRITERION | ✅ uat |
| `real-enforcement` | O1 | a scan must not match its own declaration | check-no-self-match | `[given] base/non-vacuous-checks` | → MTX-SINGLE-READER | ✅ uat |
| `agnostic-portability` | O5 | hermetic under CI conditions | HERMETIC-ENV-91 | `[given] base/hermetic-tests` | `tests/check_91_matrix.sh` | ✅ uat |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |
| — | — | `S2` engine reachable only by CLI | S2-HEDGE | `[given] stack/S2 Hedge` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — no network, no remote, no live service. `HERMETIC-ENV-91` carries the
  ambient-environment half.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`; this feature touches
  `scripts/` and `tests/`, and names no tool as a default.
- **`S2-HEDGE`** — `S2`'s `Hedge` governs the stack engine's CLI boundary; the reader is shell and
  imports nothing from it.
