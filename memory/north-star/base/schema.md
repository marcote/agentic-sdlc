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
    { "id": "string", "statement": "string", "signal": "string", "since": "NNNN" }
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

## `since` — per-pillar provenance

`since` is the **4-digit number of the ADR that last changed that pillar's `statement` or
`signal`**. Required. It answers a question the file could not answer before: reading a North Star,
you could not tell that a signal means something different than it did last month, because the only
record was the ADR list and a sentence of prose.

- **Not a path.** Paths break on rename; the ADR number is the stable identity the amendment
  protocol already uses.
- **Must resolve** to a file in `decisions/`. An id that does not resolve is rejected by name —
  silently accepting it records a provenance that does not exist.
- **`since` is metadata, not a governed field.** Changing it alone is not an amendment and needs no
  ADR: otherwise recording that ADR `0005` changed a signal would itself need ADR `0006`, forever.
  The governed sets stay `(id, statement, signal)` + `scope`.
- **The gate enforces the inverse**: a `statement` or `signal` moving while `since` stays put is
  rejected. That is what keeps the record self-maintaining rather than a convention someone
  remembers.
- **A purely mechanical change does not move it.** ADR `0003` renamed every pillar id and changed
  no meaning; no pillar records it. `since` means *last changed in meaning*, not *last touched*.

## Unfilled is not valid

A North Star still carrying the values a vendoring stub seeds is **unfilled**, and unfilled is not
valid. The validator reports it with an exit code **distinct from malformed**, because an adopter's
day-one state is a well-formed file with nothing in it, not a broken one — the message must say
*seed it*, not send someone hunting a bug that is not there.

The discriminator is **byte identity with the seeded values**, never the presence of a word like
`TODO`. A product whose domain is to-do lists writes `TODO` legitimately in its own scope, and
refusing that would be worse than the defect: it blocks real work. Unfilled detection catches *not
having done the step*; it cannot catch *having done it badly*.

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
