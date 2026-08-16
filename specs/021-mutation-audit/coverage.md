# Coverage — 021-mutation-audit

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 every criterion declares one | R1 | AUDIT-COVERAGE-COMPLETE | project | `tests/check_99_mutations.sh` | no contract |
| `real-enforcement`, `measurable-impact` | O3 survivors fixed or justified | R4 | AUDIT-ALL-PROVED | project | idem | no contract |
| `real-enforcement` | O1 the header gap that hid two | R2 · G-a | MUT-MULTILABEL-REJECTED | project | idem | no contract |
| `real-enforcement` | O3 the self-scan gap | R3 · G-b | MUT-SELFSCAN-SKIPS-DECLARATION | project | idem | no contract |
| `measurable-impact` | O5 reports corrected in place | R5 | AUDIT-REPORTS-CORRECTED | project | idem | no contract |
| `frictionless-adoption` | O6 the cost is measured | R6 | AUDIT-COST-REPORTED | project | idem | no contract |
| `measurable-impact` | O2 was it worth it | — | JUDGE-AUDIT-WORTH-IT | project | `evals/cases/audit-worth-it.md` | 📋 case |
| `real-enforcement` | O3 | a scan must not match its own declaration | check-no-self-match | `[given] base/non-vacuous-checks` | → MUT-SELFSCAN-SKIPS-DECLARATION | no contract |
| `real-enforcement` | O1 | rejection requires the diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → MUT-MULTILABEL-REJECTED | no contract |
| `real-enforcement` | O3 | each rule has a negative | check-can-fail | `[given] base/non-vacuous-checks` | → the 26 declarations themselves | no contract |
| `real-enforcement` | O1 | the runner names the file it read | check-names-its-tree | `[given] base/non-vacuous-checks` | → MUT-MULTILABEL-REJECTED | no contract |
| `agnostic-portability` | O6 | hermetic under CI conditions | HERMETIC-ENV-99 | `[given] base/hermetic-tests` | `tests/check_99_mutations.sh` | `[given]` carried by 020 |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |
| — | — | `S2` engine reachable only by CLI | S2-HEDGE | `[given] stack/S2 Hedge` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — no network, no remote, no live service.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`; this feature touches
  `memory/constitution/base/`, `scripts/` and `tests/`. `no-prescribe.sh` still runs at `/verify`.
- **`S2-HEDGE`** — no engine gains a capability. `mutate.sh` is a shell tool with its own CLI, and
  R2 changes its diagnostics rather than its surface.

## `check-no-self-match` is live here, and rarely is

The project override discharges it via `check_96`, which catches a check embedding a forbidden
literal inline. **It does not catch a scan reading a mutation declaration** — the declaration is a
legitimate comment that happens to contain the literal. G-b is a new instance of the family the
override was written for, outside what the override covers.

## UAT

Pending.

## RED state (`/contract`)

Pending.
