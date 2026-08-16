# 0005 — The North Star names which parts of the lifecycle the harness governs

Date: 2026-08-16 · Feature: `specs/019-lifecycle-boundary/` · Supersedes: nothing

## Context

The mission says the harness *"governs how software is **built**"*. Nothing said where *built*
ends.

`scope.out_of_scope` carried five predicates. Four are about technology neutrality — runtime,
engine, dependencies, hooks — and one forbids writing an adopting project's application code.
**None named a phase of the lifecycle.**

Twelve features have shipped through the workflow. It governs every phase between *what must this
do* and *what did we learn*. Four aspects of building a product have no step, no gate, and no
recorded exclusion:

| Aspect | Governed by |
|---|---|
| whether it is worth building | nothing — the brief enters as given |
| what comes first | `docs/backlog.md` collects; nothing orders |
| that it reaches anyone | nothing — the loop ends at `/retro` |
| whether it worked in real use | nothing |

The pressure that produced this ADR was a direct question about the last row. `measurable-impact`'s
signal reads *"gaps caught early and late rework avoided"*. That measures process hygiene, not
outcome — the pillar that sounds like impact measurement measures rework.

**This is not a decision that was taken and lost. It was never taken.** An unstated boundary is the
failure this harness exists to prevent, turned on itself: `/stack` exists because *"no load-bearing
technical decision is made in silence"*, and `/align` today has nothing to score a discovery or
release brief against.

## Decision

Four predicates are added to `scope.out_of_scope`. Nothing else in the canonical block changes.

**Before** — `scope.out_of_scope`, 5 entries:

```json
[
  "application code or product features of an adopting project",
  "stack-specific deterministic engine (provided by the adopter)",
  "imposing or naming a mandatory execution runtime",
  "blocking commit hooks",
  "runtime dependencies or frameworks"
]
```

**After** — 9 entries, the first five unchanged:

```json
[
  "application code or product features of an adopting project",
  "stack-specific deterministic engine (provided by the adopter)",
  "imposing or naming a mandatory execution runtime",
  "blocking commit hooks",
  "runtime dependencies or frameworks",
  "product discovery and demand validation",
  "prioritisation, roadmapping or estimation across features",
  "release, deployment or rollout of the software being built",
  "production monitoring, incident response or usage analytics"
]
```

`mission`, `pillars`, `scope.in_scope` and `alignment` are byte-identical. No pillar `statement` or
`signal` moved, so no `since` moves either.

**Why four short predicates rather than one sentence.** `scope-reject` is a contiguous-phrase
match, so a twenty-word predicate can never appear verbatim in a brief and would be a line only a
human could apply. Each of these fires the filter on an objective that names it.

**Why the third predicate says *"of the software being built"*.** `in_scope` names *"adoption
tooling: install, vendoring, and harness inheritance"*, which **is** delivery. A predicate reading
*"release and deployment"* alone would have excluded `vendor.sh` and `bootstrap.sh` retroactively.

## Scope-delta

**Moves from unstated to `out_of_scope`:** deciding whether to build something; deciding what comes
first; getting the result to users; learning whether it worked in production.

**Moves in either direction:** nothing. No predicate is removed, no predicate is narrowed, and
`in_scope` is untouched. Every one of the four aspects was previously **undecided**, not in scope —
so this records a boundary rather than shrinking the harness.

**Not in this ADR, deliberately:** `measurable-impact`'s signal is left exactly as it is. The
observation that it measures hygiene rather than outcome is real and motivated this change, but
rewriting a pillar is a second amendment with its own argument. Bundling two decisions is how a
scope-delta becomes unreadable.

## Consequences

**Newly prohibited.** A brief proposing discovery, prioritisation, release or production-monitoring
capability now has a line to be scored against under `scopeCompliance`, and a short enough
predicate that `scope-reject` can fire on an objective naming it. Before this, such a brief would
have scored on the judge's unrecorded intuition.

**Newly enabled:** nothing. That is the point — this ADR takes nothing away and adds no capability.

**No previously rejected brief becomes eligible, and none becomes ineligible.** Measured rather
than asserted: every `## Success metrics` bullet of every brief in `specs/` — **101 objectives** —
was scored against the amended North Star, at **zero hits**. A boundary that rejected work the
harness already shipped would be wrong, and this is the cheap way to find out.

**Follow-ups.**

1. Whether `measurable-impact` should measure outcome rather than rework is now an open question
   with a written cause. It needs its own ADR.
2. `scope-reject` has never produced a hit across twelve features. The deterministic filter is a
   high-confidence pre-filter by design and the judge is the intended enforcer of borderline cases,
   so this is not a defect — but it bounds what this ADR can promise, and it is recorded in
   `docs/backlog.md`.
3. The boundary is not permanent. Extending the harness to release or operation is a later ADR, and
   the argument for it should come from a real adopter rather than from this repository.
