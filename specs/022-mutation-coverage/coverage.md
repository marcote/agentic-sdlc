# Coverage — 022-mutation-coverage

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 the obligation is computed from the matrix | R1 | COV-OBLIGED-PREDICATE | project | `tests/check_97_mutation_coverage.sh` | ✅ uat |
| `real-enforcement` | O1 a gap blocks and is named | R1 | COV-GAP-NAMED | project | idem | ✅ uat |
| `real-enforcement` | O1 a complete feature passes | R1 · edge 5 | COV-CLEAN-PASSES | project | idem | ✅ uat |
| `real-enforcement` | O2 an unresolvable row is reported | R3 · edge 3 | COV-UNRESOLVABLE-REPORTED | project | idem | ✅ uat |
| `real-enforcement` | O2 a typo is not an exemption | R3 · edge 2 | COV-TYPO-NOT-EXEMPTION | project | idem | ✅ uat |
| `real-enforcement` | O3 exclusion is a number, not a silence | R4 | COV-NOT-OBLIGED-COUNTED | project | idem | ✅ uat |
| `real-enforcement` | O1 the matrix's own shorthand | R1 · edge 1 | COV-IDEM-RESOLVED | project | idem | ✅ uat |
| `measurable-impact` | O5 the standing debt is a figure | R2 · edge 7 | COV-ALL-REPORTS-DEBT | project | idem | ✅ uat |
| `agnostic-portability` | O1 no branch ref, no network | R5 | COV-NO-GIT | project | idem | ✅ uat |
| `real-enforcement` | O4 the gate is run against itself | R6 | COV-SELF | project | idem | ✅ uat |
| `real-enforcement` | O4 a gate accepted and never run | R7 | COV-WIRED | project | idem | ✅ uat |
| `frictionless-adoption` | O6 no toolchain | R8 | COV-DEPFREE | project | idem | ✅ uat |
| `frictionless-adoption` | O6 the cost is measured | R8 | COV-COST-REPORTED | project | idem | ✅ uat |
| `measurable-impact` | O4 did obliging catch one | — | JUDGE-OBLIGATION-CAUGHT-ONE | project | `evals/cases/obligation-caught-one.md` | 📋 case |
| `real-enforcement` | O2 | each rule has a negative | check-can-fail | `[given] base/non-vacuous-checks` | → the 13 declarations themselves | ✅ uat |
| `real-enforcement` | O2 | rejection requires the named diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → COV-UNRESOLVABLE-REPORTED | ✅ uat |
| `real-enforcement` | O1 | the tool names the tree it read | check-names-its-tree | `[given] base/non-vacuous-checks` | → COV-ALL-REPORTS-DEBT | ✅ uat |
| `real-enforcement` | O2 | a scan must not match its own declaration | check-no-self-match | `[given] base/non-vacuous-checks` | → COV-WIRED | ✅ uat |
| `agnostic-portability` | O6 | hermetic under CI conditions | HERMETIC-ENV-97 | `[given] base/hermetic-tests` | `tests/check_97_mutation_coverage.sh` | ✅ uat |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |
| — | — | `S2` engine reachable only by CLI | S2-HEDGE | `[given] stack/S2 Hedge` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — no network, no remote, no live service. `HERMETIC-ENV-97` carries the
  ambient-environment half, which is the one this feature can actually violate.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`; this feature touches
  `scripts/`, `tests/`, a skill and a constitution pattern, and names no tool as a default.
- **`S2-HEDGE`** — `S2`'s `Hedge` governs the stack engine's CLI boundary; `mutate.sh` is a shell
  script that imports nothing from it.

## The measurement this matrix is about

Taken by hand at `/distill`, then reproduced by the shipped tool. Re-derive with
`mutate.sh coverage --all`:

| | at `/distill`, by hand | `coverage --all`, after 022 |
|---|---|---|
| obliged | 179 | **192** (+13, this feature) |
| undeclared | **137** | **137** |
| excluded by rule | 8 | 100 |
| unresolvable | 0 | 0 |

**The two `excluded` figures are not the same measurement and neither is wrong.** The hand probe
counted only rows that survived an uppercase-label filter and reached the cell test; the tool counts
every criterion row the three conditions remove, including the lowercase `[given]` rows the probe
never saw. The number that matters — 137 undeclared — reproduced exactly, which is what made the
discrepancy worth chasing rather than rounding off.

002–017: 137 obliged, **137 undeclared**. 018–022: 55 obliged, **0 undeclared**.
