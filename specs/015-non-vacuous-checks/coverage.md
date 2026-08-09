# Coverage — 015-non-vacuous-checks

> Traceability matrix = source of truth for the state of each criterion and gap detector.
> Rule: every objective → one criterion; every criterion → one eval/UAT. Orphan row = gap.
> Chain: **pillar → objective → criterion** — every objective traces to a North Star pillar
> via the objective→pillar mapping in `alignment.md`.

**Status legend:** `no contract` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (non-deterministic) · `[given]` (inherited) · `deferred` (justified gap)

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 mechanical half of the gate | R2 emission verification | NVC-DECLARED-EMITTED | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O1 mechanical half of the gate | R1 declaration parsing | NVC-DECLARE-FORMS | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement`, `measurable-impact` | O2 traceability, zero false positives | R2 · D-a | NVC-ZERO-FP | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O2 traceability | R4 section-scoped traceability | NVC-LABEL-SCOPED | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O2 traceability | R3 explicit skip | NVC-SKIP-EXPLICIT | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O1 · `D4` gate bootstrap | R5 recursion guard, self-subjection | NVC-INNER-GUARD | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O1 mechanical half of the gate | R6 fail closed on unusable run | NVC-RED-SUITE | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O3 constrain self-scanning checks | R7 · D-b | NVC-SELFSCAN-ASSEMBLED | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O3 constrain self-scanning checks | R7 · D-b | NVC-SELFSCAN-SELFTEST | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement`, `measurable-impact` | O5 run against the standing suite, fix what it flags | R8 | NVC-FIX-82 | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O4 proved non-vacuous | R1–R7 negative fixtures | NVC-CAN-FAIL | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O1 mechanical half of the gate | `S3` shell + coreutils | NVC-DEPFREE | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement`, `measurable-impact` | O5 state the scope split | R9 | NVC-SCOPE-STATED | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement`, `measurable-impact` | O5 state the scope split | R9 | JUDGE-SCOPE-HONEST | project | `evals/cases/non-vacuous-scope-judge.md` | 📋 case |
| `real-enforcement` | O2 traceability | R3 explicit skip | NVC-SKIP-EXPLICIT-HELPER | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `real-enforcement` | O3 constrain self-scanning checks | R7 · D-b (the false positive to avoid) | NVC-SELFSCAN-CLOSED | project | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `agnostic-portability` | — | hermetic under CI conditions | HERMETIC-ENV-96 | `[given] base/hermetic-tests` | `tests/check_96_non_vacuous.sh` | 🟢 green |
| `agnostic-portability` | — | the hermetic scan's own pattern is not vacuous | HERMETIC-ENV-96-SELF | `[given] base/non-vacuous-checks` | `tests/check_96_non_vacuous.sh` | 🟢 green |
| — | — | no network or remote source reached | hermetic-offline | `[given] base/hermetic-tests` | — | deferred |
| `real-enforcement` | O4 proved non-vacuous | R1–R7 negative fixtures | check-can-fail | `[given] base/non-vacuous-checks` | → NVC-CAN-FAIL | 🟢 green |
| `real-enforcement` | O2 traceability | R2 emission verification | check-traceable | `[given] base/non-vacuous-checks` | → NVC-DECLARED-EMITTED | 🟢 green |
| `real-enforcement` | O1 mechanical half of the gate | R7 rejection names the file and literal | check-rejects-by-diagnostic | `[given] base/non-vacuous-checks` | → NVC-SELFSCAN-ASSEMBLED | 🟢 green |
| `real-enforcement` | O3 constrain self-scanning checks | R7 · D-b | check-no-self-match | `[given] base/non-vacuous-checks` | → NVC-SELFSCAN-SELFTEST | 🟢 green |
| `real-enforcement` | O1 · O5 | R6 names what it executed | check-names-its-tree | `[given] base/non-vacuous-checks` | → NVC-RED-SUITE | 🟢 green |
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

## RED state (`/contract`, 2f95fb3 → contract)

Suite **386 PASS / 17 FAIL**. All 17 assertions touching a 015 artifact are 🔴 against an absent
`scripts/nvc.sh`.

**One assertion passes at RED, by design and documented here rather than discovered later:**
`HERMETIC-ENV-96-SELF` proves that `HERMETIC-ENV-96`'s runtime-assembled pattern actually matches
a genuine occurrence. It is a non-vacuity self-test of a *scan*, not of the deliverable, so it has
no red state — the same documented exception 013 and 014 recorded for their own self-tests. Its
value is precisely that it would fail if the assembled pattern were broken, which is the failure
mode that made `HERMETIC-ENV` vacuous in 013.

## Spec gap routed back at implementation (2026-08-09)

**`NVC-LABEL-UNIQUE` → `NVC-LABEL-SCOPED`.** The criterion as frozen demanded global label
uniqueness. Run against the standing green suite it produced **four hits**, all legitimate: an
inherited `[given]` criterion recurs across every feature that carries it, which is the
constitution's injection working as designed.

The gap is in the spec, not the implementation, so it was routed back rather than worked around —
and the replacement is **stronger**, not weaker: section-scoping catches a result emitted under the
wrong file, which uniqueness could never detect. Zero false positives on the standing suite.

Recorded here because this feature's `alignment.md` made zero-false-positives a scored commitment,
and quietly relaxing a criterion that fired would be the failure mode it was scored against.

## GREEN state (implementation)

Suite **404 PASS / 0 FAIL** (pre-015 baseline was 385). `nvc.sh` clean on the standing suite:
`traceability` exit 0 over 97 declared labels, `duplicates` exit 0, `selfscan` exit 0.

**Failability proved per rule, one isolated sandbox each** (`NVC-CAN-FAIL`, `[given] check-can-fail`):

| fixture | mutation | result |
|---|---|---|
| F1 | traceability comparison neutered | 4 FAIL |
| F2 | heredoc stripping disabled → phantom criteria | 2 FAIL |
| F3 | self-scan literal detection removed | 1 FAIL |
| F4 | fail-closed removed (**both** branches) | 2 FAIL |
| F5 | inner guard removed | recursion — the run hangs, which is the failure the guard prevents |

**F4 is worth recording rather than smoothing over.** The first F4 attempt removed only the
empty-log branch and everything stayed green, which reads exactly like a vacuous assertion. It is
not: the rule is defended twice, and an empty log also fails the "no PASS/FAIL/SKIP lines" branch.
The fixture was wrong, not the assertion — but the two are indistinguishable until you build the
fixture that isolates the rule, which is the entire argument for `check-can-fail` being mechanical
rather than a matter of care.

Three defects were found by this feature's own tooling during implementation, all in the shape it
targets: the fixture strings of `check_96` parsed as phantom declarations (110 labels instead of
97); `selfscan` flagging `check_96` for a `grep` living inside a fixture heredoc — the tool
producing, on its own file, the exact false positive it exists to catch; and `strip_heredocs`
returning zero declarations after a quoting slip, which every downstream assertion would then have
satisfied vacuously.
