# Coverage — 017-executable-derivations

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement`, `measurable-impact` | O1 executable derivation, run by the suite | R1 · R2 | DERIV-RUNS | project | `tests/check_90_retro.sh` | no contract |
| `real-enforcement` | O2 disagreement fails, naming it | R2 | DERIV-MISMATCH | project | idem | no contract |
| `real-enforcement` | O2 failure modes distinguished | R3 | DERIV-BROKEN-CMD | project | idem | no contract |
| `real-enforcement` | O2 failure modes distinguished | R3 | DERIV-NON-INTEGER | project | idem | no contract |
| `real-enforcement` | O1 several claims per line | G-b | DERIV-MULTI | project | idem | no contract |
| `frictionless-adoption` | O4 prose stays prose | R4 | DERIV-PROSE-KEPT | project | idem | no contract |
| `real-enforcement` | O2 bracket delimiter | G-c | DERIV-BRACKET | project | idem | no contract |
| `real-enforcement`, `measurable-impact` | O3 the check is not vacuous | R5 · edge 8 | DERIV-NON-VACUOUS | project | idem | no contract |
| `real-enforcement`, `measurable-impact` | O3 every closed retro migrated | R5 · `D3` | DERIV-MIGRATED | project | idem | no contract |
| `agnostic-portability`, `frictionless-adoption` | O5 the surface is stated | R6 | DERIV-SCOPE-STATED | project | idem | no contract |
| `measurable-impact` | O3 | R5 | JUDGE-DERIV-HONEST | project | `evals/cases/derivation-judge.md` | 📋 case |
| `agnostic-portability` | — | hermetic under CI conditions | HERMETIC-ENV-90 | `[given] base/hermetic-tests` | `tests/check_90_retro.sh` | no contract |
| `real-enforcement` | O2 | negative fixture per rule | check-can-fail | `[given] base/non-vacuous-checks` | → DERIV-* fixtures | no contract |
| `real-enforcement` | O2 | rejection requires the diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → DERIV-BROKEN-CMD | no contract |
| `real-enforcement` | O2 | the check names what it ran | check-names-its-tree | `[given] base/non-vacuous-checks` | → DERIV-MISMATCH | no contract |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |
| — | — | `S2` engine reachable only via a documented shell CLI | S2-HEDGE | `[given] stack/S2 Hedge` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — no network, remote repo or live service is reached. The derivations read
  files in this repository.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`, which this feature does not
  touch. Carried and deferred rather than dropped, so the stance pin's injection stays auditable.
- **`S2-HEDGE`** — `S2`'s `Hedge` binds engines. This feature ships no engine: the deliverable is a
  template field and a check. If implementation reaches for a python3 engine, this row revives.

## UAT

Pending.
