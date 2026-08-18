# Coverage — covgate clean fixture

> Every obliged row declares a mutation. The gate must exit 0 **and say how many it found** — a
> feature with nothing obliged and a feature fully declared must not produce the same silence.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 obliged, declares | R1 | FIXTURE-DECLARED | project | `tests/fixtures/covgate/check_fixture.sh` | 🟢 green |
| `real-enforcement` | O1 obliged via idem, declares | R1 | FIXTURE-IDEM | project | idem | ✅ uat |
