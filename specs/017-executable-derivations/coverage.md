# Coverage — 017-executable-derivations

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Chain: **pillar → objective → criterion**, per `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat` ·
`📋 case` · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement`, `measurable-impact` | O1 executable derivation, run by the suite | R1 · R2 | DERIV-RUNS | project | `tests/check_90_retro.sh` | 🟢 green |
| `real-enforcement` | O2 disagreement fails, naming it | R2 | DERIV-MISMATCH | project | idem | 🟢 green |
| `real-enforcement` | O2 failure modes distinguished | R3 | DERIV-BROKEN-CMD | project | idem | 🟢 green |
| `real-enforcement` | O2 failure modes distinguished | R3 | DERIV-NON-INTEGER | project | idem | 🟢 green |
| `real-enforcement` | O1 several claims per line | G-b | DERIV-MULTI | project | idem | 🟢 green |
| `frictionless-adoption` | O4 prose stays prose | R4 | DERIV-PROSE-KEPT | project | idem | 🟢 green |
| `real-enforcement` | O2 bracket delimiter | G-c | DERIV-BRACKET | project | idem | 🟢 green |
| `real-enforcement`, `measurable-impact` | O3 the check is not vacuous | R5 · edge 8 | DERIV-NON-VACUOUS | project | idem | 🟢 green |
| `real-enforcement`, `measurable-impact` | O3 every migrated derivation agrees | R5 · `D3` | DERIV-MIGRATED | project | idem | 🟢 green |
| `real-enforcement`, `measurable-impact` | O3 014 onward carry one | R5 (narrowed) | DERIV-FROM-014 | project | idem | 🟢 green |
| `measurable-impact` | O3 013's finding stays written | R5 (narrowed) | DERIV-013-RECORDED | project | idem | 🟢 green |
| `agnostic-portability` | — | the hermetic scan's pattern is not vacuous | HERMETIC-ENV-90-SELF | `[given] base/non-vacuous-checks` | idem | 🟢 green |
| `agnostic-portability`, `frictionless-adoption` | O5 the surface is stated | R6 | DERIV-SCOPE-STATED | project | idem | 🟢 green |
| `measurable-impact` | O3 | R5 | JUDGE-DERIV-HONEST | project | `evals/cases/derivation-judge.md` | 📋 case |
| `agnostic-portability` | — | hermetic under CI conditions | HERMETIC-ENV-90 | `[given] base/hermetic-tests` | `tests/check_90_retro.sh` | 🟢 green |
| `real-enforcement` | O2 | negative fixture per rule | check-can-fail | `[given] base/non-vacuous-checks` | → DERIV-* fixtures | 🟢 green |
| `real-enforcement` | O2 | rejection requires the diagnostic | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → DERIV-BROKEN-CMD | 🟢 green |
| `real-enforcement` | O2 | the check names what it ran | check-names-its-tree | `[given] base/non-vacuous-checks` | → DERIV-MISMATCH | 🟢 green |
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

## GREEN + UAT — 2026-08-09

Suite **450 PASS / 0 FAIL** (pre-017 baseline 436). All criteria 🟢 → **✅ uat**.

### R5 narrowed at implementation, and the reason is the feature's own finding

R5 said *every* closed retro is migrated. Nine exist; **three** could be.

- **004–009 have no countable `Edge cases` section.** Their specs predate the format. There is
  nothing for a command to read, so the exclusion is a fact rather than a decision.
- **013 cannot be reproduced at all.** Its prose derivation says nine bullets minus one, and also
  plus three grilling ambiguities, while claiming eight. The section now holds ten. No combination
  yields eight. The number was already corrected once, from twelve to eight, and that correction is
  what made it look verified.

**013 is not corrected here, because the correct value is unknown.** Writing a command that prints
eight would be the filler-to-comply this feature exists to stop. It is recorded in 013's retro, and
`DERIV-013-RECORDED` fails if that record is removed.

### Three metacharacter bugs, all caught at `/contract`

A `case` pattern read `[deriv$` as a character class. `grep` read a trailing `$` as end-of-line.
`printf '- **A:**…'` read the leading dash as an option, so every fixture file was empty. All three
made assertions fail for the wrong reason, which still reads as red — the argument for a real RED
phase rather than writing the check and the implementation together.

### The constraint the spec imposed was broken by its own first use

`G-c` forbade `]` inside a command. The first real derivation was
`grep -cE '^[0-9]+\.'`, which contains one, so the command was truncated mid-pattern. The
terminator became `$]`. `DERIV-BRACKET` now uses that exact command as its fixture.

### Failability, one sandbox per rule

| mutation | result |
|---|---|
| M1 comparison disabled | 2 FAIL |
| M2 broken command reported as disagreement | 1 FAIL |
| M3 terminator back to `]` | 5 FAIL |
| M4 a real derivation pointed at a missing file | 1 FAIL, printing 3 against a claimed 10 |

### A fourth parser bug, found by this retro on itself

Writing the friction section tripped the parser: a **mention** of the form inside a code span was
read as a derivation. Code spans are now stripped first, the same blind spot `has_placeholder()`
and `prose_only()` already carry and document.

The retro describing the parser's bugs contained a fourth one. Four commands now run, not three.
