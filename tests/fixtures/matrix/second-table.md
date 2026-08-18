# Coverage — with a measurement table below

| Pillar | Objective (brief) | Requirement (spec) | Criterion (acceptance) | Origin | Linked test/eval | Status |
|---|---|---|---|---|---|---|
| `p` | O1 | R1 | MTX-ALPHA | project | `tests/check_x.sh` | 🟢 green |

## The measurement this matrix is about

> Deliberately as wide as the matrix: with a narrow second table the criterion column falls in an
> empty cell and the row filter drops it, so the RANGE rule is never the thing under test.

| metric | at /distill | after | delta | note | source | when |
|---|---|---|---|---|---|---|
| obliged | 179 | MTX-LEAKED | +13 | — | tool | 2026-08 |
| undeclared | 137 | MTX-LEAKED-2 | 0 | — | tool | 2026-08 |
