# Acceptance — 016-north-star-integrity

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the UAT
> step. The deterministic portion materialises as a test in `/contract`.

## Criterion: NS-UNFILLED  (deterministic)
```gherkin
Given a North Star whose values are byte-identical to the seeded stub
When schema-valid runs
Then it exits 3, distinct from 1 (invalid) and 2 (malformed)
And the message names which fields are still seeded
```

## Criterion: NS-UNFILLED-PARTIAL  (deterministic)
```gherkin
Given a North Star with a real mission but pillars still seeded
When schema-valid runs
Then it exits 3 and names the pillars, not the mission
```

## Criterion: NS-TODO-NOT-FALSE-POSITIVE  (deterministic)
```gherkin
Given a fully written North Star for a product whose domain is to-do lists
And its scope legitimately contains the word TODO in prose
When schema-valid runs
Then it exits 0
```

## Criterion: NS-SEED-TABLE-SYNC  (deterministic)
```gherkin
Given the engine's SEEDED table and the stub vendor.sh actually writes
When they are compared
Then every seeded value in the stub appears in the table
And a table that has drifted from the stub fails, since the check would otherwise pass forever
```

## Criterion: NS-SINCE-REQUIRED  (deterministic)
```gherkin
Given a filled North Star whose pillar has no since field
When schema-valid runs
Then it exits 1 and names the pillar
```

## Criterion: NS-SINCE-RESOLVES  (deterministic)
```gherkin
Given a pillar whose since names an ADR with no file in decisions/
When schema-valid runs
Then it is rejected, and the diagnostic names the pillar and the unresolved id
```

## Criterion: NS-UNFILLED-BEFORE-SINCE  (deterministic)
```gherkin
Given a seeded North Star, whose since is seeded too
When schema-valid runs
Then the message says the North Star is unfilled
And it does not report an unresolved ADR id, which would send the reader hunting a bug that is not there
```

## Criterion: NS-OWN-MIGRATED  (deterministic)
```gherkin
Given this repository's own North Star
When schema-valid runs
Then it exits 0
And real-enforcement and agnostic-portability record 0001, measurable-impact 0002, frictionless-adoption 0004
And no pillar records 0003, which renamed ids without changing any statement or signal
```

## Criterion: AMEND-PROV-STALE  (deterministic)
```gherkin
Given a diff where a pillar's signal changes and its since does not
When the amendment gate runs
Then it blocks, citing that pillar
```

## Criterion: AMEND-PROV-ONLY  (deterministic)
```gherkin
Given a diff where only a pillar's since changes
When the amendment gate runs
Then it passes, because provenance is metadata and not a governed field
And requiring an ADR here would mean recording ADR 0005 needs ADR 0006, forever
```

## Criterion: ALIGN-REFUSES-UNFILLED  (deterministic)
```gherkin
Given the align skill's step 1
When its contract is read
Then it stops on exit 3 and tells the human to seed the North Star
And it does not describe an unfilled North Star as malformed
```

## Criterion: ALIGN-STAMPS-PROVENANCE  (deterministic)
```gherkin
Given the align skill writes alignment.md
When its contract is read
Then each mapped pillar is recorded with the ADR it came from
And this feature's own alignment.md carries that stamp
```

## Criterion: NS-VENDORED-STUB-REJECTED  (deterministic)
```gherkin
Given a repository freshly vendored by scripts/vendor.sh
When schema-valid runs against its seeded North Star
Then it exits 3
And this is checked against a real vendored target, not a fixture
```

## Criterion: NS-ENGINE-CLI-ONLY  (deterministic)
```gherkin
Given pin S2 is PROVISIONAL and its Hedge binds engines
When the engine's new capability is added
Then it is reachable only through the documented shell CLI, with no importable API
And the module docstring states the exit contract including 3 = unfilled
```

## Criterion: JUDGE-PROVENANCE-USEFUL  (non-deterministic → eval case)
_Does the provenance stamp ever change a verdict, or is it decoration that reads well? It pays only
when a pending-observation is swept against a signal that moved. Scored by an independent judge, not
before the first sweep on 2026-09-08._

## Inherited `[given]` criteria

### hermetic-env  (from `base/patterns/hermetic-tests.md`)
```gherkin
Given a detached-HEAD, no-terminal, no-local-branch checkout
When the suite runs
Then it is green and assumes no terminal and no local main
```

### check-can-fail · check-rejects-by-diagnostic · check-names-its-tree
_(from `base/patterns/non-vacuous-checks.md`)_ — three of five; `check-traceable` and
`check-no-self-match` are discharged by `check_96` per the project override in
`memory/constitution/constitution.md`.

### S2-HEDGE  (from stack pin `S2`, PROVISIONAL)
```gherkin
Given the engine gains a new capability
When it is invoked
Then it is reachable only as a shell subcommand with a documented exit contract
And no caller imports it as a module
```
**This row is live for this feature**, unlike in 015 where the deliverable was bash. 015's
`coverage.md` recorded that reaching for python3 would revive it; this feature does.
