# Acceptance — 019-lifecycle-boundary

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the UAT
> step. The deterministic portion materialises as a test in `/contract`.

## Criterion: NS-LIFECYCLE-PREDICATES  (deterministic)
```gherkin
Given the amended North Star
When schema-valid runs
Then it exits 0
And out_of_scope carries the four lifecycle predicates
```

## Criterion: NS-BOUNDARY-BOUNDED  (deterministic)
```gherkin
Given the amended North Star
When in_scope, pillars, mission and alignment are compared with the previous version
Then none of them changed
And only out_of_scope grew
```

## Criterion: NS-PREDICATE-REACHABLE  (deterministic)
```gherkin
Given each of the four new predicates
When scope-reject runs against an objective that names it
Then it exits 0, naming the predicate it matched
And a predicate too long to appear verbatim in a brief would fail here
```

## Criterion: NS-ADOPTION-STAYS-IN-SCOPE  (deterministic)
```gherkin
Given objectives naming vendor.sh, bootstrap.sh and the in_scope adoption line
When scope-reject runs against the amended North Star
Then every one clears, exit 1
And the harness's own delivery is not excluded by a predicate about the adopter's
```

## Criterion: NS-REJECTS-NOTHING-BUILT  (deterministic)
```gherkin
Given every success-metric bullet of every brief in specs/
When each is scored by scope-reject against the amended North Star
Then no objective hits any predicate
And the number of objectives scored is reported, since zero hits and an empty run look identical
```

## Criterion: NS-ADR-0005-COMPLETE  (deterministic)
```gherkin
Given memory/north-star/decisions/0005-lifecycle-boundary.md
When it is read
Then Context, Decision, Scope-delta and Consequences are each present and non-empty
And it is the next sequential number, since since fields resolve by number
```

## Criterion: AMEND-LIFECYCLE-REFLEXIVE  (deterministic)
```gherkin
Given this feature's own before and after north-star.md
When the amendment gate runs with 0005 absent from the added files
Then it blocks, citing the missing ADR
And when 0005 is present it passes
```

## Criterion: AMEND-PROVENANCE-QUIET  (deterministic)
```gherkin
Given a scope change in which no pillar statement or signal moved
When the amendment gate runs
Then the 016 provenance staleness check does not fire
And a scope-only amendment is not asked to update a since it did not invalidate
```

## Criterion: JUDGE-BOUNDARY-CHANGES-A-VERDICT  (non-deterministic → eval case)
_Does the named boundary ever change a verdict, or is it a line that reads well? It pays when a
brief is scored differently because these predicates exist. Deferred to the 2026-09-08 sweep, with
013, 014, 016 and 017._

## Inherited `[given]` criteria

### hermetic-env  (from `base/patterns/hermetic-tests.md`)
```gherkin
Given a detached-HEAD, no-terminal, no-local-branch checkout
When the suite runs
Then it is green and assumes no terminal and no local main
```

### check-can-fail · check-rejects-by-diagnostic · check-names-its-tree
From `base/patterns/non-vacuous-checks.md` — three of five; `check-traceable` and
`check-no-self-match` are discharged by `check_96` per the project override in
`memory/constitution/constitution.md`.

### audit-logging  (from `base/patterns/audit-logging.md`)
```gherkin
Given a change to the governed sets of the North Star
When it lands
Then an ADR records who decided what and why, and the PR carries the reviewer and timestamp
```
**Live for this feature**, and rarely is. The amendment protocol names this pattern explicitly: the
"write" being audited is a change to the scope itself.
