# Brief — The North Star names which parts of the lifecycle the harness governs

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

The mission says the harness *"governs how software is **built**"*. Nothing says where *built*
ends.

`scope.out_of_scope` has five predicates. Four are about technology neutrality — runtime, engine,
dependencies, hooks — and one forbids writing an adopting project's application code. **None names
a phase of the lifecycle.**

So the harness has no recorded answer to whether it covers deciding *what* to build, deciding what
comes *first*, getting the result *to users*, or finding out whether it *worked*. That is not a
decision that was taken and lost; it was never taken.

## Why / motivation

**Measured, and this is the whole argument.** Twelve features have shipped. Their workflow covers
brief → align → distill → plan → contract → tasks → implement → verify → uat → retro. Every phase
between *what must it do* and *did we learn* is governed.

Four aspects of building a product have no step, no gate, and no recorded exclusion:

| Aspect | Governed by |
|---|---|
| whether it is worth building | nothing — the brief enters as given |
| what comes first | `docs/backlog.md` collects; nothing orders |
| that it reaches anyone | nothing — the loop ends at `/retro` |
| whether it worked in real use | nothing |

**The last row is the sharpest.** `measurable-impact`'s signal is *"gaps caught early and late
rework avoided"*. That measures process hygiene, not outcome. The pillar that reads like impact
measurement measures rework.

**Why this is a defect and not a preference.** An unstated boundary is the exact failure this
harness exists to prevent, applied to itself. `/stack` was built because *"no load-bearing
technical decision is made in silence"*. The lifecycle boundary is a load-bearing product decision
made in silence, and `/align` today has nothing to score a discovery or release brief against.

## Success metrics

- **`out_of_scope` names the lifecycle boundary**, in predicates short enough to be read and cited
  rather than one compound sentence.
- **Each predicate says whose lifecycle it excludes.** The harness's own adoption tooling —
  `vendor.sh`, `bootstrap.sh` — is delivery, and must not become out of scope by accident.
- **The amendment lands as the protocol requires**: an ADR with Context, Decision, Scope-delta and
  Consequences, plus the `north-star.md` diff, in one PR that CI checks.
- **The gate is proved reflexively**: the amendment gate blocks this change without its ADR and
  passes with it, run against this feature's own diff rather than a fixture.
- **A brief naming an excluded phase is reachable by the gate**, so the predicate is not a
  sentence nobody can act on.
- **No existing in-scope work becomes rejected.** Checked against the twelve closed features, not
  asserted.

## Out of scope

- **Building any of the four excluded aspects.** This records a boundary; it implements no
  discovery, prioritisation, release or monitoring capability.
- **Changing `measurable-impact`'s signal.** The observation that it measures hygiene rather than
  outcome is real and is recorded, but re-writing a pillar is a second amendment with its own
  argument. One ADR, one decision.
- **Making `scope-reject` match semantically.** Its conservatism is deliberate and documented; the
  judge is the intended enforcer of borderline cases, per the `/align` skill.
- **Deciding the boundary is permanent.** An ADR is how it moves later.

## Dependency

`memory/north-star/north-star.md`, `memory/north-star/base/amendment-protocol.md` and its
`adr-template.md`, `scripts/amendment-gate.sh` and the CI workflow from feature 004.

**This changes a governed set that every adopter inherits.** Adopters replace the pins of
`memory/stack/stack.md` with their own, but they inherit this repository's North Star only as a
stub — so the risk here is to this repository's own future briefs, not to theirs.

**`D3` applies, not `D4`.** The gate this feature must satisfy already exists; the feature ships
no new gate that would judge itself.
