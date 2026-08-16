# Acceptance — 021-mutation-audit

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the UAT
> step. The deterministic portion materialises as a test in `/contract`.

## Criterion: AUDIT-COVERAGE-COMPLETE  (deterministic)
```gherkin
Given every criterion of features 018 and 019
When the runner lists declarations for their check files
Then each criterion has exactly one
And the seven that never had a recorded mutation are among them
```

## Criterion: AUDIT-ALL-PROVED  (deterministic)
```gherkin
Given the audited set of declarations
When the runner runs
Then every one breaks its criterion, and the run exits 0
```

## Criterion: MUT-MULTILABEL-REJECTED  (deterministic)
```gherkin
Given a criterion header naming two labels separated by a middle dot
When the runner lists criteria
Then it is rejected by name with its file and line, exit 2
And it is not skipped, which is how two criteria went uncounted
```

## Criterion: MUT-SELFSCAN-SKIPS-DECLARATION  (deterministic)
```gherkin
Given a criterion that scans its own file for a forbidden literal
And a mutation declaration in that file containing exactly that literal
When the criterion runs
Then it does not report the declaration as the defect
And the pattern file states this, since a declaration lives inside what it mutates
```

## Criterion: AUDIT-REPORTS-CORRECTED  (deterministic)
```gherkin
Given the verification reports of 018 and 019
When they are read
Then each records what this audit found about its own mutation table
And neither feature is reopened
```

## Criterion: AUDIT-COST-REPORTED  (deterministic)
```gherkin
Given the full audited run
When it finishes
Then it reports the total elapsed time
And the figure is measured rather than estimated
```

## Criterion: JUDGE-AUDIT-WORTH-IT  (non-deterministic → eval case)
_The prediction was 7 or 8 failures; the result was 1. Did the audit earn its cost, or did it
confirm what was already true? The answer depends on the two defects it found in 020 and on whether
the declarations stay green as the checks change._

## Inherited `[given]` criteria

### hermetic-env  (from `base/patterns/hermetic-tests.md`)
```gherkin
Given a detached-HEAD, no-terminal, no-local-branch checkout
When the suite runs
Then it is green and assumes no terminal and no local main
```

### check-can-fail · check-rejects-by-diagnostic · check-no-self-match · check-names-its-tree
From `base/patterns/non-vacuous-checks.md`. **`check-no-self-match` is live for this feature and
rarely is** — G-b is a new instance of exactly that family, and the project override that discharges
it via `check_96` does not cover a scan reading a mutation declaration.
