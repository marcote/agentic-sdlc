# Coverage — 020-executable-mutations

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 a parseable grammar | R1 · G-a | MUT-GRAMMAR | project | `tests/check_99_mutations.sh` | no contract |
| `real-enforcement` | O1 malformed is rejected | R1 · edge 4 | MUT-UNBOUND-REJECTED | project | idem | no contract |
| `real-enforcement` | O3 revert either way | R2 · G-b | MUT-SANDBOXED | project | idem | no contract |
| `real-enforcement`, `measurable-impact` | O2 the mutation is applied and required to break it | R3 | MUT-REQUIRES-FAIL | project | idem | no contract |
| `real-enforcement` | O4 the runner's own negative | R4 · gate note 2 | MUT-CATCHES-VACUOUS | project | idem | no contract |
| `real-enforcement` | O4 name what was not proved | R3 · edge 1 | MUT-SILENCE-IS-NOT-FAILURE | project | idem | no contract |
| `real-enforcement` | O4 name what was not proved | R3 · edge 9 | MUT-APPLY-ERROR-DISTINCT | project | idem | no contract |
| `measurable-impact` | O5 the falsification test | R5 | MUT-REPLAY-019 | project | idem | no contract |
| `measurable-impact` | O5 the falsification test | R5 | MUT-REPLAY-018 | project | idem | no contract |
| `frictionless-adoption` | O6 the cost is measured | R6 | MUT-COST-REPORTED | project | idem | no contract |
| `real-enforcement` | O2 | R7 · `D4` | MUT-SELF-APPLIED | project | idem | no contract |
| `agnostic-portability` | O7 | `S3` | MUT-DEPFREE | `[given] stack/S3` | idem | no contract |
| `measurable-impact` | O2 | G-e's stated limit | JUDGE-PREVENTS-THE-SIXTH | project | `evals/cases/prevents-the-sixth.md` | 📋 case |
| `agnostic-portability` | O7 | hermetic under CI conditions | HERMETIC-ENV-99 | `[given] base/hermetic-tests` | idem | no contract |
| `real-enforcement` | O2 | this feature's own criteria | check-can-fail | `[given] base/non-vacuous-checks` | → MUT-SELF-APPLIED | no contract |
| `real-enforcement` | O4 | rejection requires the diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → MUT-CATCHES-VACUOUS | no contract |
| `real-enforcement` | O3 | the runner names the tree it mutated | check-names-its-tree | `[given] base/non-vacuous-checks` | → MUT-SANDBOXED | no contract |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| — | — | `S1` no tool named as a default in `memory/stack/base/` | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |
| — | — | `S2` engine reachable only by CLI | S2-HEDGE | `[given] stack/S2 Hedge` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — the runner reaches no network. Its sandbox is a local tar of tracked
  files.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` governs `memory/stack/base/`; this feature touches
  `memory/constitution/base/` and `scripts/`. `no-prescribe.sh` still runs at `/verify`.
- **`S2-HEDGE`** — no engine gains a capability. `mutate.sh` is a new shell tool with its own
  documented CLI, not a change to either engine.

## Rows this feature does NOT carry, and why

`check-traceable` and `check-no-self-match` are **discharged by `check_96`** under the project
override in `memory/constitution/constitution.md`.

## The two rows that decide whether this was worth building

`MUT-REPLAY-018` and `MUT-REPLAY-019` replay the criteria **in the form actually shipped**. Every
other row can be satisfied by a runner that works on fixtures designed for it. These two cannot.

## UAT

Pending.

## RED state (`/contract`)

Pending.
