# Acceptance — 018-adoption-fixture

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the UAT
> step. The deterministic portion materialises as a test in `/contract`.

## Criterion: ADOPT-FIXTURE-BUDGET  (deterministic)
```gherkin
Given the fixture adopter repository
When its product half is measured
Then it is at most 40 lines across at most 4 files
And the budget is what makes "it grew into an application" mechanically visible
```

## Criterion: ADOPT-FIXTURE-DROP  (deterministic)
```gherkin
Given a repository vendored by scripts/vendor.sh
When the target is inspected
Then it contains no tests/fixtures/adopter
```

## Criterion: ADOPT-VENDOR-APPLY  (deterministic)
```gherkin
Given a sandbox copy of the fixture
When vendor.sh --apply runs against it inside the suite
Then the governance layer lands, with no manual step between the copy and the gates
```

## Criterion: ADOPT-SEED-PRESERVED  (deterministic)
```gherkin
Given the fixture's authored charter, North Star and scripts/test.sh
When vendoring is applied on top of them
Then each file keeps its authored content
And a .harness-new sibling is written for each
```

## Criterion: ADOPT-SANDBOX-CLEAN  (deterministic)
```gherkin
Given the committed fixture at tests/fixtures/adopter
When every scenario in this check has run
Then the committed tree is byte-identical to what it was before
And each scenario used its own copy, since git checkout cannot restore an untracked file
```

## Criterion: ADOPT-CHARTER-PINS  (deterministic)
```gherkin
Given the vendored fixture's charter, whose pin ids use a prefix this repository does not use
When the exposure gate runs against it
Then it reports the fixture's four pins
And it does not report empty, which is what the pin-id defect reported
```

## Criterion: ADOPT-NS-VALID  (deterministic)
```gherkin
Given the vendored fixture's authored North Star
When schema-valid runs against it
Then it exits 0, not 3
And this is the positive paired with 016's NS-VENDORED-STUB-REJECTED
```

## Criterion: ADOPT-GR-COVERED  (deterministic)
```gherkin
Given the vendored fixture's charter and the ground rule file in that same target
When the ground-rules gate runs
Then all six rules have a verdict and none is uncovered
```

## Criterion: ADOPT-REL-RESOLUTION  (deterministic)
```gherkin
Given the ground-rules gate invoked from a cwd that is not the target
When it resolves the ground rule file
Then it finds the one beside the charter, not one relative to the process cwd
And an explicit --rules still overrides the default
```

## Criterion: ADOPT-NO-SILENT-EMPTY  (deterministic)
```gherkin
Given every gate this check runs against the fixture
When each result is read
Then it names at least one identifier the fixture itself owns
And a gate that returns empty or not-applicable on a foreign target fails here
```

## Criterion: ADOPT-UNCOVERED-FIRES  (deterministic)
```gherkin
Given a copy of the fixture charter with the pin answering GR4 removed
When the ground-rules gate runs
Then it reports GR4 uncovered, by name
```

## Criterion: ADOPT-GUARD-BY-NAME  (deterministic)
```gherkin
Given the guards gate emits the fixture's declared guard commands
When this check executes them
Then it executes the emitted string itself, never a path written into this check
And the harness never inspects what the command checks
```

## Criterion: ADOPT-GUARD-CLEAN  (deterministic)
```gherkin
Given the clean vendored fixture
When each emitted guard command runs with the target as cwd
Then every one exits 0
```

## Criterion: ADOPT-GUARD-FAILS  (deterministic)
```gherkin
Given a copy of the fixture that violates the stance its guard asserts
When the same emitted guard command runs
Then it exits non-zero
And a guard that cannot fail certifies nothing
```

## Criterion: ADOPT-TESTCMD-INVOKED  (deterministic)
```gherkin
Given the vendored fixture's own scripts/test.sh
When the harness invokes it
Then its exit code is observed and reported
And if python3 is unavailable the criterion emits a skip with its reason, never silence
```

## Criterion: ADOPT-TESTCMD-NOT-COUNTED  (deterministic)
```gherkin
Given the harness pass and fail totals before the fixture's suite is invoked
When they are compared after it returns
Then they moved only by this check's own criteria
And per S7 a green harness suite never also claims the fixture works
```

## Criterion: UAT-FIXTURE-INERT  (non-deterministic → UAT)
_Read the shipped fixture: is it still something to be governed, or has it started to work? The
budget in `ADOPT-FIXTURE-BUDGET` bounds size, not intent. `alignment.md` scored
`scopeCompliance: 4` on this exact edge._

## Criterion: UAT-SECOND-DIVERGENCE  (non-deterministic → UAT)
_The falsification test set in `alignment.md`: does a gate behave differently on the fixture than on
this repository, excluding the already-known pin-id defect? Answered at `/uat` against what the
build actually found, not against R6's expectation._

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

### S2-HEDGE  (from stack pin `S2`, PROVISIONAL)
```gherkin
Given the engine gains a new capability
When it is invoked
Then it is reachable only as a shell subcommand with a documented exit contract
And no caller imports it as a module
```
**Live, narrowly.** R6 changes existing resolution rather than adding a capability, so the row is
carried at its weakest reading: the fix must not open an importable seam.
