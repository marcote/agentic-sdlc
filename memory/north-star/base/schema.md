# North-Star Schema (base)

> The **required shape** of a North Star. This file is the human-readable contract
> of the rules that a deterministic validator must enforce. The concrete executable
> validator (equivalent to `validateNorthStar`) is provided by each adopting stack —
> this repo specifies the shape, it does not implement it (see
> `specs/002-north-star-governance/plan.md` decision 2). Reference implementation:
> `poirot-fe scripts/north-star/schema.mjs`.

## Where the North Star lives

A project's North Star is `memory/north-star/north-star.md`: markdown for
humans (mission, rationale, prose) plus **one** ` ```json ` fenced block that is the
**canonical, machine-readable** North Star. The validator (per-stack) extracts that
block and parses it as JSON — the surrounding prose exists to explain it; nothing in
the flow reads it to make decisions. If prose and JSON block disagree, **the JSON block
wins**.

## Required shape

```json
{
  "mission": "string",
  "pillars": [
    { "id": "string", "statement": "string", "signal": "string" }
  ],
  "scope": {
    "in_scope": ["string"],
    "out_of_scope": ["string"]
  },
  "alignment": {
    "threshold": 3
  }
}
```

## Field rules

| Field | Rule |
|---|---|
| `mission` | required, non-empty string |
| `pillars` | required, array with **≥ 1** entry |
| `pillars[].id` | required, non-empty string — a short slug (e.g. `pillar-a`) |
| `pillars[].statement` | required, non-empty string — what the pillar means |
| `pillars[].signal` | required, non-empty string — a **measurable** indicator that the pillar is being served (this is what makes the North Star checkable, not just aspirational) |
| `scope.in_scope` | required, **non-empty** array of strings |
| `scope.out_of_scope` | required, **non-empty** array of strings — used by the scope predicate (`scopeReject`, per-stack) as hard rejection predicates |
| `alignment.threshold` | required, number — minimum score (0–5) that each rubric dimension must exceed to count as aligned (see `alignment-rubric.md`) |
| `alignment.rubric` | **optional** — pointer/path to the rubric file used for scoring (e.g. `alignment-rubric.md`); only `alignment.threshold` is required |

A North Star that fails any of these rules **is not schema-valid**, and by
the Measurability Gate (`specs/002-north-star-governance/acceptance.md`, criterion
MEAS-GATE) the flow must refuse to run against it — a non-measurable North Star
cannot govern anything.

## Validity, not truth

The validator only checks **shape** (presence, non-empty, type) — it has no opinion
on whether a mission is *good*. Judging quality is the work of the semantic layer
of the `/align` skill and the dimensions of `alignment-rubric.md`, not of this schema.
