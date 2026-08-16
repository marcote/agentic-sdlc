# Coverage — covgate not-a-check fixture

> A row naming a script that matches no `check_*.sh` pattern at all — the typo path. Extraction
> finds nothing, so without the `.sh` fallback this row would become a silent exemption: the
> failure and the success would render identically, which is `B11`.

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `real-enforcement` | O2 a typo is not an exemption | R3 | FIXTURE-TYPO | project | `tests/chek_97_mutation_coverage.sh` | 🟢 green |
