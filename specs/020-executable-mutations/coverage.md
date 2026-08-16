# Coverage — 020-executable-mutations

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 a parseable grammar | R1 · G-a | MUT-GRAMMAR | project | `tests/check_99_mutations.sh` | ✅ uat |
| `real-enforcement` | O1 malformed is rejected | R1 · edge 4 | MUT-UNBOUND-REJECTED | project | idem | ✅ uat |
| `real-enforcement` | O3 revert either way | R2 · G-b | MUT-SANDBOXED | project | idem | ✅ uat |
| `real-enforcement`, `measurable-impact` | O2 the mutation is applied and required to break it | R3 | MUT-REQUIRES-FAIL | project | idem | ✅ uat |
| `real-enforcement` | O4 the runner's own negative | R4 · gate note 2 | MUT-CATCHES-VACUOUS | project | idem | ✅ uat |
| `real-enforcement` | O4 name what was not proved | R3 · edge 1 | MUT-SILENCE-IS-NOT-FAILURE | project | idem | ✅ uat |
| `real-enforcement` | O4 name what was not proved | R3 · edge 9 | MUT-APPLY-ERROR-DISTINCT | project | idem | ✅ uat |
| `measurable-impact` | O5 the falsification test | R5 | MUT-REPLAY-019 | project | idem | ✅ uat |
| `measurable-impact` | O5 the falsification test | R5 | MUT-REPLAY-018 | project | idem | ✅ uat |
| `frictionless-adoption` | O6 the cost is measured | R6 | MUT-COST-REPORTED | project | idem | ✅ uat |
| `real-enforcement` | O2 | R7 · `D4` | MUT-SELF-APPLIED | project | idem | ✅ uat |
| `real-enforcement` | O2 | `D4` condition 4 | MUT-WIRED | project | idem | ✅ uat |
| `agnostic-portability` | O7 | `S3` | MUT-DEPFREE | `[given] stack/S3` | idem | ✅ uat |
| `measurable-impact` | O2 | G-e's stated limit | JUDGE-PREVENTS-THE-SIXTH | project | `evals/cases/prevents-the-sixth.md` | 📋 case |
| `agnostic-portability` | O7 | hermetic under CI conditions | HERMETIC-ENV-99 | `[given] base/hermetic-tests` | idem | ✅ uat |
| `real-enforcement` | O2 | this feature's own criteria | check-can-fail | `[given] base/non-vacuous-checks` | → MUT-SELF-APPLIED | ✅ uat |
| `real-enforcement` | O4 | rejection requires the diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → MUT-CATCHES-VACUOUS | ✅ uat |
| `real-enforcement` | O3 | the runner names the tree it mutated | check-names-its-tree | `[given] base/non-vacuous-checks` | → MUT-SANDBOXED | ✅ uat |
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

## UAT — 2026-08-16

Every row `✅ uat` except the three `deferred` ones and `JUDGE-PREVENTS-THE-SIXTH`, which cannot be
scored before a feature closes after this one.

**The falsification test passed.** 018's and 019's real vacuous criteria, replayed character-identical
from `3adc719^` and `babac0a^`, are both reported as surviving their own mutation.

**What this does not prove:** declaring is opt-in, so this makes the proving repeatable rather than
mandatory. It does not yet prevent the sixth instance.

## RED state (`/contract`)

Suite **493 PASS / 13 FAIL**, and `check_99` was **13 FAIL / 0 PASS**.

**The first feature in this repository with no green-by-construction exception.** Every previous
feature carried two to four criteria that could not have an honest red state — a *must-not*
criterion, or a scan whose subject is the check itself. Here every criterion asserts behaviour of a
deliverable that did not exist.

## GREEN state — 2026-08-16

Suite **507 PASS / 0 FAIL** (pre-020 baseline 493), plus **14 of 14 declared mutations proved**,
13.02s.

### Six of my own mutations broke nothing, and the runner said so

Its first real use found six weak assertions in the feature that shipped it. Each was a `sed`
matching a comment or a pattern absent from the file — `s/mut\$/muX\$/` never touched the awk
pattern `\[mut\$`, because the file carries a backslash the pattern did not.

### A reentrancy bug produced a *wrong* diagnostic

The runner wrote its capture to a fixed `/tmp` path, and the check file it executes invokes the
runner. The inner run clobbered the outer capture, so a criterion that **passed** under its
mutation was reported as `emitted no result` — which reads like a broken check rather than a vacuous
one. Fixed with per-invocation `mktemp -d` on both sides.

### The replays were right for the wrong reason, briefly

The fixtures were untracked, so they never entered the `git ls-files` sandbox. Both reported `not
proved` — the verdict I wanted — via `could not be applied` and `emitted no result`. Accepting that
would have shipped a passing falsification test that proved nothing. `MUT-REPLAY-*` now requires the
exact string `survived its own mutation`.
