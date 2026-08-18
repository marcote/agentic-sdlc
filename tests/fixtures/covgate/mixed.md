# Coverage — covgate mixed fixture

> Authored, not copied. This repository has **0** rows in the states this fixture carries, so the
> predicate's boundaries have no natural instance to test against.
>
> The undeclared row is deliberately the `idem` one: it can only be reported as a gap if `idem`
> resolved to the row above it. A fixture where the obliged rows both name their file would let
> `idem` resolution silently do nothing.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 obliged, declares | R1 | FIXTURE-DECLARED | project | `tests/fixtures/covgate/check_fixture.sh` | 🟢 green |
| `real-enforcement` | O1 obliged via idem, declares nothing | R1 | FIXTURE-BARE | project | idem | 🟢 green |
| `real-enforcement` | O2 inherited, owns no assertion | R2 | check-can-fail | `[given] base/non-vacuous-checks` | → FIXTURE-DECLARED | 🟢 green |
| `measurable-impact` | O3 scored by judgment | — | FIXTURE-JUDGE | project | `/uat` judgment | 📋 case |
| — | — | justified as absent | fixture-offline | `[given] base/hermetic-tests` | — | deferred |
