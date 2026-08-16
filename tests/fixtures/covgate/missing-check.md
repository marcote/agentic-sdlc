# Coverage — covgate missing-check fixture

> A row naming a check file that matches `check_*.sh` and does **not** exist. The gate must exit 2
> and name it, rather than dropping the row from the obligation.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O1 names a file that is gone | R3 | FIXTURE-MISSING | project | `tests/check_00_typo.sh` | 🟢 green |
