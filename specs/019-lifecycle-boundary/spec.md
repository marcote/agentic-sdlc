# Spec — The North Star names which parts of the lifecycle the harness governs

> WHAT is built, derived from `brief.md`. Frozen by `/distill` once no orphan rows remain.

## Deliverables

- `memory/north-star/decisions/0005-lifecycle-boundary.md` — the ADR.
- `memory/north-star/north-star.md` — four predicates added to `scope.out_of_scope`.
- `tests/check_80_north_star.sh` — the predicates are reachable, bounded, and reject nothing built.
- `tests/check_95_amendment_gate.sh` — the gate blocks this change without its ADR (`D3`).

## The four predicates

```json
"product discovery and demand validation",
"prioritisation, roadmapping or estimation across features",
"release, deployment or rollout of the software being built",
"production monitoring, incident response or usage analytics"
```

`out_of_scope` goes from 5 to 9. `in_scope`, `pillars` and `mission` are untouched.

## Resolved at grilling (5)

### G-a — Four short predicates, not one compound sentence

`scope-reject` is a contiguous-phrase match: `_norm(pred) in objective`. A twenty-word predicate
can never appear verbatim in a brief, so it would be a line only a human can apply.

**Measured, not assumed.** The control objective *"we will ship blocking commit hooks for every
adopter"* fires the existing short predicate at exit 0. Each of the four new predicates fires on an
objective that names it.

### G-b — Each predicate says whose lifecycle it excludes

`in_scope` names *"adoption tooling: install, vendoring, and harness inheritance"*. That **is**
delivery. A predicate reading *"release and deployment"* alone would exclude `vendor.sh` and
`bootstrap.sh` retroactively.

So the third predicate says *"of the software being built"* — the adopting project's product,
never the harness's own distribution. Verified against three adoption objectives, all clear.

### G-c — `measurable-impact`'s signal is not touched

Its signal measures gaps caught and rework avoided, which is process hygiene rather than outcome.
That observation motivated this brief and is recorded in it.

Rewriting it is a **second amendment with its own argument**, and bundling two decisions into one
ADR is how a scope-delta becomes unreadable. One ADR, one decision.

### G-d — `0005`, and the number is load-bearing

ADRs are sequential and `0004` is the last. `since` fields resolve by number, so a gap or a reuse
breaks provenance resolution for every pillar that points there.

### G-e — The boundary is proved right by what it does **not** reject

The immediate falsification is a corpus run: every `## Success metrics` bullet of every brief in
`specs/`, scored against the amended North Star. **Zero hits required.**

Measured during the grilling: **101 objectives, 0 hits**. A predicate broad enough to reject work
the harness already shipped is wrong, and this is the cheap way to find out.

## Requirements

### R1 — Four predicates in `out_of_scope`, and nothing else moves
`in_scope`, `pillars`, `mission` and `alignment` are byte-identical. The blast radius of an
amendment should be readable in the diff, not reconstructed from it.

### R2 — Every new predicate is reachable
Each fires `scope-reject` at exit 0 on an objective that names it. This proves the predicate is
well-formed and live — **not** that it catches every brief about that phase.

### R3 — The harness's own adoption tooling stays in scope
Objectives naming `vendor.sh`, `bootstrap.sh` and the `in_scope` adoption line all clear every
predicate. The false-positive risk points inward, at this repository.

### R4 — The boundary rejects nothing already built
The corpus of every brief's success metrics scores zero hits. Asserted over the real corpus, so it
grows with the repository instead of freezing at today's fourteen features.

### R5 — The amendment lands as the protocol requires
ADR `0005` carries Context, Decision, Scope-delta and Consequences, each non-empty. The ADR and the
`north-star.md` diff travel in one PR.

### R6 — The gate is proved against this feature's own diff (`D3`)
The amendment gate **blocks** the scope change when `0005` is absent from the added files, and
**passes** when it is present. Run on this feature's real before/after, not on a fixture.

## Edge cases (`/distill` expansion — 8)

1. **A predicate excludes the harness's own delivery.** The inward false positive. → R3, G-b.
2. **A predicate is too long to ever match.** → R2, G-a.
3. **A predicate is so broad it rejects closed work.** → R4, the 101-objective corpus.
4. **The corpus check passes because it scored nothing.** A zero-hit result and an empty run look
   identical from outside. The count of objectives scored is asserted, not just the hit count.
5. **`in_scope` or a pillar drifts in the same commit.** → R1; the gate would demand an ADR for it
   anyway, but the diff should not need archaeology.
6. **The ADR is a filled template with empty sections.** `adr-template.md` says an empty
   placeholder is not a real ADR. → R5, each section asserted non-empty.
7. **Provenance staleness fires wrongly.** No pillar `statement` or `signal` changes, so no `since`
   moves. The 016 inverse check must stay quiet. → R1.
8. **A future feature is now wrongly blocked.** Out of reach of a test today, and recorded as the
   deferred half of the falsification test. → `alignment.md` gate note 3, sweep 2026-09-08.

## Non-goals

Building discovery, prioritisation, release or monitoring; changing `measurable-impact`'s signal;
making `scope-reject` match semantically; treating the boundary as permanent.
