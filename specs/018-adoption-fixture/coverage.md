# Coverage — 018-adoption-fixture

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `agnostic-portability` | O1 a fixture adopter exists | R1 inert and small | ADOPT-FIXTURE-BUDGET | project | `tests/check_98_adoption.sh` | no contract |
| `agnostic-portability` | O1 the fixture is DROP | R1 | ADOPT-FIXTURE-DROP | project | idem | no contract |
| `real-enforcement`, `agnostic-portability` | O2 gates run there, no manual step | R2 | ADOPT-VENDOR-APPLY | project | idem | no contract |
| `real-enforcement`, `agnostic-portability` | O2 authored files survive | R2 | ADOPT-SEED-PRESERVED | project | idem | no contract |
| `agnostic-portability` | O2 hermetic, one sandbox per scenario | R2 | ADOPT-SANDBOX-CLEAN | project | idem | no contract |
| `real-enforcement`, `measurable-impact` | O3 divergence caught | R3 | ADOPT-CHARTER-PINS | project | idem | no contract |
| `real-enforcement`, `measurable-impact` | O3 divergence caught | R3 | ADOPT-NS-VALID | project | idem | no contract |
| `real-enforcement`, `measurable-impact` | O3 divergence caught | R3 | ADOPT-GR-COVERED | project | idem | no contract |
| `real-enforcement`, `measurable-impact` | O3 the divergence found at `/distill` | R6 | ADOPT-REL-RESOLUTION | project | idem | no contract |
| `real-enforcement`, `measurable-impact` | O3 the general shape of the defect | R3 | ADOPT-NO-SILENT-EMPTY | project | idem | no contract |
| `real-enforcement` | O2 `UNCOVERED` on a foreign charter | R4 | ADOPT-UNCOVERED-FIRES | project | idem | no contract |
| `real-enforcement`, `agnostic-portability` | O4 guard run by name | R5 · G-e | ADOPT-GUARD-BY-NAME | project | idem | no contract |
| `real-enforcement`, `agnostic-portability` | O4 guard run by name | R5 | ADOPT-GUARD-CLEAN | project | idem | no contract |
| `real-enforcement`, `agnostic-portability` | O4 its failure is observed | R5 | ADOPT-GUARD-FAILS | project | idem | no contract |
| `real-enforcement` | O5 the fixture's test command | R7 | ADOPT-TESTCMD-INVOKED | project | idem | no contract |
| `real-enforcement` | O5 its result stays out of the count | R7 · `S7` | ADOPT-TESTCMD-NOT-COUNTED | project | idem | no contract |
| `agnostic-portability` | O1 | R1 · gate note 1 | UAT-FIXTURE-INERT | project | `/uat` judgment | 📋 case |
| `measurable-impact` | O3 | falsification test | UAT-SECOND-DIVERGENCE | project | `/uat` judgment | 📋 case |
| `agnostic-portability` | — | hermetic under CI conditions | HERMETIC-ENV-98 | `[given] base/hermetic-tests` | `tests/check_98_adoption.sh` | no contract |
| `real-enforcement` | O3 · O4 | each rule has a negative | check-can-fail | `[given] base/non-vacuous-checks` | → ADOPT-GUARD-FAILS · ADOPT-UNCOVERED-FIRES | no contract |
| `real-enforcement` | O3 | rejection requires the diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → ADOPT-UNCOVERED-FIRES | no contract |
| `real-enforcement` | O2 | the check names the tree it ran against | check-names-its-tree | `[given] base/non-vacuous-checks` | → ADOPT-SANDBOX-CLEAN | no contract |
| `measurable-impact` | O3 | `S2` Hedge, weakest reading | S2-HEDGE-98 | `[given] stack/S2 Hedge` | `tests/check_98_adoption.sh` | no contract |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — this feature reaches no network, remote repo or live service. The
  fixture is a local directory and vendoring is a file copy.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`, which this feature does
  not touch. Carried and deferred rather than dropped, so the stance pin's injection stays
  auditable; `no-prescribe.sh` still runs at `/verify` as `S1`'s `Guard`.

  **Worth stating, because it looks like a violation and is not:** the fixture's charter names
  Python by design. `S1` forbids *this harness* prescribing a tool. An adopter naming their own
  stack in their own charter is the mechanism working.

## Rows this feature does NOT carry, and why

`check-traceable` and `check-no-self-match` are **discharged by `check_96`** under the project
override in `memory/constitution/constitution.md`.

## UAT

Pending. Filled at `/uat`, including the two `📋 case` rows, which are judgments this feature can
answer at close rather than deferring to a sweep.

## RED state (`/contract`)

Pending.
