# Coverage — 018-adoption-fixture

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `agnostic-portability` | O1 a fixture adopter exists | R1 inert and small | ADOPT-FIXTURE-BUDGET | project | `tests/check_98_adoption.sh` | ✅ uat |
| `agnostic-portability` | O1 the fixture is DROP | R1 | ADOPT-FIXTURE-DROP | project | idem | ✅ uat |
| `real-enforcement`, `agnostic-portability` | O2 gates run there, no manual step | R2 | ADOPT-VENDOR-APPLY | project | idem | ✅ uat |
| `real-enforcement`, `agnostic-portability` | O2 authored files survive | R2 | ADOPT-SEED-PRESERVED | project | idem | ✅ uat |
| `agnostic-portability` | O2 hermetic, one sandbox per scenario | R2 | ADOPT-SANDBOX-CLEAN | project | idem | ✅ uat |
| `real-enforcement`, `measurable-impact` | O3 divergence caught | R3 | ADOPT-CHARTER-PINS | project | idem | ✅ uat |
| `real-enforcement`, `measurable-impact` | O3 divergence caught | R3 | ADOPT-NS-VALID | project | idem | ✅ uat |
| `real-enforcement`, `measurable-impact` | O3 divergence caught | R3 | ADOPT-GR-COVERED | project | idem | ✅ uat |
| `real-enforcement`, `measurable-impact` | O3 the divergence found at `/distill` | R6 | ADOPT-REL-RESOLUTION | project | idem | ✅ uat |
| `real-enforcement`, `measurable-impact` | O3 the general shape of the defect | R3 | ADOPT-NO-SILENT-EMPTY | project | idem | ✅ uat |
| `real-enforcement` | O2 `UNCOVERED` on a foreign charter | R4 | ADOPT-UNCOVERED-FIRES | project | idem | ✅ uat |
| `real-enforcement`, `agnostic-portability` | O4 guard run by name | R5 · G-e | ADOPT-GUARD-BY-NAME | project | idem | ✅ uat |
| `real-enforcement`, `agnostic-portability` | O4 guard run by name | R5 | ADOPT-GUARD-CLEAN | project | idem | ✅ uat |
| `real-enforcement`, `agnostic-portability` | O4 its failure is observed | R5 | ADOPT-GUARD-FAILS | project | idem | ✅ uat |
| `real-enforcement` | O5 the fixture's test command | R7 | ADOPT-TESTCMD-INVOKED | project | idem | ✅ uat |
| `real-enforcement` | O5 its result stays out of the count | R7 · `S7` | ADOPT-TESTCMD-NOT-COUNTED | project | idem | ✅ uat |
| `agnostic-portability` | O1 | R1 · gate note 1 | UAT-FIXTURE-INERT | project | `/uat` judgment | ✅ uat |
| `measurable-impact` | O3 | falsification test | UAT-SECOND-DIVERGENCE | project | `/uat` judgment | ✅ uat |
| `agnostic-portability` | — | hermetic under CI conditions | HERMETIC-ENV-98 | `[given] base/hermetic-tests` | `tests/check_98_adoption.sh` | ✅ uat |
| `real-enforcement` | O3 · O4 | each rule has a negative | check-can-fail | `[given] base/non-vacuous-checks` | → ADOPT-GUARD-FAILS · ADOPT-UNCOVERED-FIRES | ✅ uat |
| `real-enforcement` | O3 | rejection requires the diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → ADOPT-UNCOVERED-FIRES | ✅ uat |
| `real-enforcement` | O2 | the check names the tree it ran against | check-names-its-tree | `[given] base/non-vacuous-checks` | → ADOPT-SANDBOX-CLEAN | ✅ uat |
| `measurable-impact` | O3 | `S2` Hedge, weakest reading | S2-HEDGE-98 | `[given] stack/S2 Hedge` | `tests/check_98_adoption.sh` | ✅ uat |
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

## UAT — 2026-08-09

Every row `✅ uat` except the two `deferred` ones. Both judgments were answered at close rather
than deferred to a sweep.

- **`UAT-FIXTURE-INERT` — PASS.** 3 product files, 25 lines, no argument parsing, no configuration,
  no persistence. The fixture declares pin `P4` and implements nothing for it, which is the clearest
  evidence it is not trying to work. Boundary recorded in the report.
- **`UAT-SECOND-DIVERGENCE` — YES.** The cwd-resolution defect, found at `/distill`, unknown before
  this feature. `measurable-impact` therefore closes `✅` rather than `⏳`.

No product gap. Nothing routed back to `/distill`.

## RED state (`/contract`)

Suite **460 PASS / 14 FAIL** against a check written before the fixture existed.

**Four assertions passed at RED, recorded here rather than discovered at `/verify`:**

- `ADOPT-FIXTURE-DROP` — green by construction: a fixture that does not exist cannot leak into a
  vendored target. It becomes real the moment the fixture exists, and it stays a *must-not*
  criterion, which has no honest red state.
- `ADOPT-TESTCMD-NOT-COUNTED` — nothing was invoked, so nothing could move the count. Proved real
  by mutation M11, which leaks a `_pass` between the two snapshots.
- `S2-HEDGE-98` — a must-not-regress criterion: no importable caller existed before this feature
  and none may exist after it.
- `HERMETIC-ENV-98` — a scan whose subject is this check itself, the same documented exception
  013, 014, 015 and 016 all recorded.

## GREEN state — 2026-08-09

Suite **474 PASS / 0 FAIL** (pre-018 baseline 456). All 16 deterministic criteria plus the three
inherited rows are 🟢. Eleven mutations, one at a time, in
`verification/reports/018-adoption-fixture-3adc719.md`.

### `ADOPT-REL-RESOLUTION` was vacuous, and mutation testing proved it

The first version compared the gate run from this repository's root against the run from inside
the target. Reverting R6 produced **no failure**: `base/` is KEEP, so both trees carry the same six
ground rules and cwd-resolution returned byte-identical output.

The fix needed two changes. The fixture now extends the base six with `GR7` in its own layer, and
the gate is invoked from a third directory owning no rules. Only artifact-relative resolution can
then produce a seventh verdict.

The fourth vacuous assertion this harness has caught in its own work.
