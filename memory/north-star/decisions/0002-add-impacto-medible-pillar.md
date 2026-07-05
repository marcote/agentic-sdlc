# 0002 — Add `measurable-impact` pillar

> `pillars` amendment: adds a 4th pillar. Lands together with the `north-star.md`
> diff in the same PR (see `base/amendment-protocol.md`). A human reviews and approves.

## Context

The 3 pillars from the seed (`0001`) — `real-enforcement`, `agnostic-portability`,
`frictionless-adoption` — describe **properties of the harness**, but none measures the
**outcome for the developer**. The mission is "to enforce a disciplined SDLC", and the
real value of that discipline is *better software*: less rework, gaps caught before coding,
the human freed for the 20% conceptual (the *80% problem* from the whitepaper cited in the
README).

The pressure that motivates it: without an outcome pillar, the harness risks rewarding
**enforcement without impact** — gates that fire for the sake of firing. This is the same
anti-theater risk attacked at the retro level (`003`), now at the harness level as a whole:
we were measuring that we *enforced*, not that *enforcing was useful*. An adversarial review
of the seed itself surfaced it as the biggest gap.

## Decision

Add a pillar to the `pillars` array of the canonical block in `north-star.md`.

**Before** (3 pillars): `real-enforcement`, `agnostic-portability`,
`frictionless-adoption`.

**After** (4 pillars): the previous 3 **+**

```json
{
  "id": "measurable-impact",
  "statement": "The discipline the harness imposes must translate into better software: less rework and gaps caught before production, not gates that fire for the sake of firing.",
  "signal": "Gaps caught early (grilling/contract) and late rework avoided (post-verify/uat), aggregated per feature in the Method section of the wow-report; high = discipline prevents, not just bureaucratizes."
}
```

No changes to `mission`, `scope`, or `alignment.threshold`.

## Scope-delta

None. This amendment **does not** move predicates between `in_scope`/`out_of_scope`; it only
adds a pillar dimension. The impact radius is bounded: future briefs gain one more pillar
against which `/align` can map objectives.

**Overlap delta (declared explicitly to avoid confusion with `real-enforcement`):**
`real-enforcement` measures that the gate **fires** (discipline is enforced);
`measurable-impact` measures that **firing reduces rework / catches gaps** (discipline adds
value). One is "we enforced", the other is "enforcing was useful". They are distinct
dimensions deliberately not collapsed.

## Consequences

- **Enables** a brief to advance the mission via *demonstrable impact* (not just procedural
  rigor). Its `signal` relies on **already-existing** instrumentation: the "Method"
  section of the `wow-report` (gaps caught, post-verify/uat rework).
- No previous brief changes verdict (no `rejected`↔`aligned` reclassification; scope was
  not touched).
- **Follow-up:** when ≥2 features have closed with a real retro, the `wow-report §Method`
  should start populating the evidence for this pillar; until then it is a declared but
  still data-free pillar (honesty N=1).
