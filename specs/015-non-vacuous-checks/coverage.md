# Coverage — 015-non-vacuous-checks

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → one criterion; every criterion → one eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** — every objective traces to a North Star pillar
> via the objective→pillar mapping in `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 mechanical half of the gate | R2 emission verification | NVC-DECLARED-EMITTED | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement` | O1 mechanical half of the gate | R1 declaration parsing | NVC-DECLARE-FORMS | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement`, `measurable-impact` | O2 traceability, zero false positives | R2 · D-a | NVC-ZERO-FP | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement` | O2 traceability | R4 label uniqueness | NVC-LABEL-UNIQUE | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement` | O2 traceability | R3 explicit skip | NVC-SKIP-EXPLICIT | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement` | O1 · `D4` gate bootstrap | R5 recursion guard, self-subjection | NVC-INNER-GUARD | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement` | O1 mechanical half of the gate | R6 fail closed on unusable run | NVC-RED-SUITE | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement` | O3 constrain self-scanning checks | R7 · D-b | NVC-SELFSCAN-ASSEMBLED | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement` | O3 constrain self-scanning checks | R7 · D-b | NVC-SELFSCAN-SELFTEST | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement`, `measurable-impact` | O5 run against the standing suite, fix what it flags | R8 | NVC-FIX-82 | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement` | O4 proved non-vacuous | R1–R7 negative fixtures | NVC-CAN-FAIL | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement` | O1 mechanical half of the gate | `S3` shell + coreutils | NVC-DEPFREE | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement`, `measurable-impact` | O5 state the scope split | R9 | NVC-SCOPE-STATED | project | `tests/check_96_non_vacuous.sh` | no contract |
| `real-enforcement`, `measurable-impact` | O5 state the scope split | R9 | JUDGE-SCOPE-HONEST | project | `evals/cases/non-vacuous-scope-judge.md` | 📋 case |
| `agnostic-portability` | — | hermetic under CI conditions | hermetic-env | `[given] base/hermetic-tests` | `tests/check_96_non_vacuous.sh` | no contract |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| `real-enforcement` | O4 proved non-vacuous | R1–R7 negative fixtures | check-can-fail | `[given] base/non-vacuous-checks` | → NVC-CAN-FAIL | no contract |
| `real-enforcement` | O2 traceability | R2 emission verification | check-traceable | `[given] base/non-vacuous-checks` | → NVC-DECLARED-EMITTED | no contract |
| `real-enforcement` | O1 mechanical half of the gate | R7 rejection names the file and literal | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → NVC-SELFSCAN-ASSEMBLED | no contract |
| `real-enforcement` | O3 constrain self-scanning checks | R7 · D-b | check-no-self-match | `[given] base/non-vacuous-checks` | → NVC-SELFSCAN-SELFTEST | no contract |
| `real-enforcement` | O1 · O5 | R6 names what it executed | check-names-its-tree | `[given] base/non-vacuous-checks` | → NVC-RED-SUITE | no contract |
| — | — | `S1` no tool/language/runtime named as a default in `memory/stack/base/` prose | S1-NO-PRESCRIBE | `[given] stack/S1 Injects` | — | deferred |
| — | — | `S2` engine reachable only via a documented shell CLI | S2-HEDGE | `[given] stack/S2 Hedge` | — | deferred |

## Deferral reasons (required)

- **`hermetic-offline`** — this feature reaches no network, remote repo or live service. Its
  spawned inner run executes the same local suite. Nothing to seam.
- **`S1-NO-PRESCRIBE`** — `S1`'s `Injects` clause governs artifacts under `memory/stack/base/`.
  This feature ships one file under `tests/` and touches nothing in that tree. Carrying the row
  and marking it `deferred` with this reason is the honest form; silently dropping it would make
  the stance pin's injection unauditable. `scripts/guards/no-prescribe.sh` still runs at `/verify`
  as `S1`'s `Guard`, so the stance is enforced regardless.
- **`S2-HEDGE`** — `S2` is `PROVISIONAL` and its `Hedge` binds *engines*. The deliverable is a
  bash check, not an engine, so there is no CLI contract to document. **If implementation reaches
  for python3, this row stops being deferred and the hedge applies** — recorded now so the
  decision cannot be made in silence later.

## Mapping note — the five inherited `[given]` rows

This is the first feature to carry `base/patterns/non-vacuous-checks.md`, and it is also the
feature that *implements* it. Each inherited row therefore points at a project criterion rather
than at a separate assertion. That is deliberate and is recorded here so it is auditable: a reader
can check whether the mapping is real or whether the rows were satisfied by restating them.

**The risk this creates, stated before it can be denied:** a feature whose subject is a rule is
the easiest place to satisfy that rule circularly. `/uat` must judge the five rows against the
delivered check's *behaviour on fixtures*, not against this table.

## UAT

Pending — filled at `/uat`. Every row must reach `✅ uat` except the `deferred` ones,
whose reasons are recorded above, and `JUDGE-SCOPE-HONEST`, which stays `📋 case` unless an
independent judge scores it.
