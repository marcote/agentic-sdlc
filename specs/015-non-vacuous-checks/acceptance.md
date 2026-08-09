# Acceptance — 015-non-vacuous-checks

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the UAT
> step. The deterministic portion materialises as a test in `/contract`.

## Criterion: NVC-DECLARED-EMITTED  (deterministic)
```gherkin
Given a check file declaring a criterion label that never emits a result at runtime
When the meta-check runs
Then it fails, naming the file and the label
And a suite where every declared label emits leaves it green
```

## Criterion: NVC-DECLARE-FORMS  (deterministic)
```gherkin
Given a label declared only as a "# --- LABEL:" section header
And a second label declared only inside a heredoc body that writes a fixture file
When the meta-check parses declarations
Then the section-header label is treated as declared
And the heredoc-body label is not, so no phantom criterion is manufactured
```

## Criterion: NVC-ZERO-FP  (deterministic)
```gherkin
Given the standing suite, green, with check_82's DEP-FREE already fixed
When the meta-check runs against it
Then it reports zero violations
And the run is proved to be non-empty by asserting the number of labels it examined is > 50
```

## Criterion: NVC-LABEL-UNIQUE  (deterministic)
```gherkin
Given the same criterion label declared in two different check files
When the meta-check runs
Then it fails, naming both files and the duplicated label
```

## Criterion: NVC-SKIP-EXPLICIT  (deterministic)
```gherkin
Given lib.sh provides _skip and a criterion that cannot execute in this environment
When that criterion emits "SKIP: LABEL: <reason>"
Then the meta-check accepts it as emitted
And the same criterion emitting nothing at all is rejected
```

## Criterion: NVC-INNER-GUARD  (deterministic)
```gherkin
Given the meta-check spawns the suite from inside the suite
When it runs
Then the inner run terminates rather than recursing
And the meta-check's own criterion labels appear in the captured output
And it is therefore judged by the rule it enforces
```

## Criterion: NVC-RED-SUITE  (deterministic)
```gherkin
Given an inner run that produces no output, or is red for an unrelated reason
When the meta-check evaluates it
Then it reports that condition and names what it executed
And it emits no traceability verdict, neither pass nor fail, for the labels it could not judge
```

## Criterion: NVC-SELFSCAN-ASSEMBLED  (deterministic)
```gherkin
Given a check that scans a target which can include the scanning file itself
When that check passes an inline literal pattern instead of a runtime-assembled variable
Then the meta-check fails, naming the file and the literal
And a check scanning a closed, explicitly named target set that excludes itself is not flagged
```

## Criterion: NVC-SELFSCAN-SELFTEST  (deterministic)
```gherkin
Given a check whose scan target can include itself
When it declares no self-test criterion proving it is not matching its own source
Then the meta-check fails, naming the file
```

## Criterion: NVC-FIX-82  (deterministic)
```gherkin
Given check_82's DEP-FREE criterion, whose dep-free result was emitted with no label
When the suite runs after this feature
Then the run output ties that result to DEP-FREE
And the meta-check reports no violation for check_82
```

## Criterion: NVC-CAN-FAIL  (deterministic)
```gherkin
Given a negative fixture violating each rule the meta-check enforces
When the meta-check runs against each fixture in isolation
Then it fails on exactly that rule and stays green on the others
And each fixture runs in its own sandbox, since git cannot restore an untracked file
```

## Criterion: NVC-DEPFREE  (deterministic)
```gherkin
Given the shipped meta-check
When assert_dep_free examines it with its criterion label
Then it invokes no installable toolchain
```

## Criterion: NVC-SCOPE-STATED  (deterministic)
```gherkin
Given the shipped meta-check file
When its header is read
Then it names which shapes it enforces mechanically and which remain with review
And it states that an undeclared criterion is invisible to it
```

## Criterion: JUDGE-SCOPE-HONEST  (non-deterministic → eval case)
_Does the shipped scope statement over-claim? A file that lists its mechanical rules but implies
they cover the family would repeat, one level up, the failure this feature exists to stop.
Scored by an independent judge — the authoring model grading its own scope statement is exactly
the conflict this criterion is testing for._

## Inherited `[given]` criteria

### hermetic-env  (from `base/patterns/hermetic-tests.md`)
```gherkin
Given a detached-HEAD, no-terminal, no-local-branch checkout
When the suite runs including the meta-check and its spawned inner run
Then both are green and neither assumes a controlling terminal or a local main
```

### check-can-fail · check-traceable · check-rejects-by-diagnostic · check-no-self-match · check-names-its-tree
From `base/patterns/non-vacuous-checks.md` — see `coverage.md` for the row-by-row mapping.
This feature is the first to carry these rows, and it is also their subject: each maps onto a
criterion above rather than onto a separate assertion, which is recorded explicitly so the mapping
is auditable rather than assumed.
