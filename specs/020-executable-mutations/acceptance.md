# Acceptance — 020-executable-mutations

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the UAT
> step. The deterministic portion materialises as a test in `/contract`.

## Criterion: MUT-GRAMMAR  (deterministic)
```gherkin
Given a check file with a [mut$ ... $] declaration under a criterion header
When the runner lists declarations
Then it binds the mutation to the criterion above it
And a declaration with no closing terminator is reported with its file and line
```

## Criterion: MUT-UNBOUND-REJECTED  (deterministic)
```gherkin
Given a declaration that follows no criterion header
When the runner lists declarations
Then it is rejected by name, not skipped
And skipping it would report zero mutations on a file full of them
```

## Criterion: MUT-SANDBOXED  (deterministic)
```gherkin
Given a mutation that edits a tracked file
When the runner applies it
Then the edit happens in a sandbox built from the working tree
And the real tree is byte-identical after the run
```

## Criterion: MUT-REQUIRES-FAIL  (deterministic)
```gherkin
Given a criterion whose declared mutation does break it
When the runner runs
Then the criterion emits FAIL in the sandbox and the runner reports it as proved failable
```

## Criterion: MUT-CATCHES-VACUOUS  (deterministic)
```gherkin
Given a fixture criterion whose declared mutation does NOT break it
When the runner runs
Then it reports the criterion and the mutation that failed to break it
And this is the runner's own negative, since a runner that applies nothing looks identical to one that works
```

## Criterion: MUT-SILENCE-IS-NOT-FAILURE  (deterministic)
```gherkin
Given a mutation that stops the criterion emitting anything at all
When the runner runs
Then it is reported as not proved, never as proved failable
And absent and failed are different observations
```

## Criterion: MUT-APPLY-ERROR-DISTINCT  (deterministic)
```gherkin
Given a declared mutation whose command exits non-zero
When the runner applies it
Then the diagnostic says the mutation could not be applied
And it is distinct from a mutation that applied but did not break its criterion
```

## Criterion: MUT-REPLAY-019  (deterministic)
```gherkin
Given 019's NS-PREDICATE-REACHABLE in the form actually shipped, which built its test input from the artifact under test
And the mutation that rewrites a predicate as an 18-word sentence
When the runner runs
Then it reports the criterion as not proved failable
```

## Criterion: MUT-REPLAY-018  (deterministic)
```gherkin
Given 018's ADOPT-REL-RESOLUTION in the form actually shipped, which compared two runs over copies of the same tree
And the mutation that reverts artifact-relative resolution
When the runner runs
Then it reports the criterion as not proved failable
```

## Criterion: MUT-COST-REPORTED  (deterministic)
```gherkin
Given a run with several declared mutations
When it finishes
Then it reports elapsed time per mutation and in total
And a mandatory cost that hides itself cannot be judged against ADR 0004
```

## Criterion: MUT-SELF-APPLIED  (deterministic)
```gherkin
Given every criterion this feature ships
When the runner runs against its own check file
Then each one declares a mutation and is proved failable by it
```

## Criterion: MUT-DEPFREE  (deterministic)
```gherkin
Given scripts/mutate.sh
When it is scanned
Then it invokes no installable toolchain
```

## Criterion: JUDGE-PREVENTS-THE-SIXTH  (non-deterministic → eval case)
_Declaring a mutation is opt-in, so this makes the proving repeatable rather than mandatory. Does it
prevent the next vacuous assertion, or only make the manual work auditable? Answerable at the first
feature after this one, not before._

## Inherited `[given]` criteria

### hermetic-env  (from `base/patterns/hermetic-tests.md`)
```gherkin
Given a detached-HEAD, no-terminal, no-local-branch checkout
When the suite runs
Then it is green and assumes no terminal and no local main
```
**Named explicitly this time.** 019 wrote this row into its coverage and then broke it with
`git show main:…`, caught by CI. The sandbox here is built with `git ls-files`, which needs no ref.

### check-can-fail · check-rejects-by-diagnostic · check-names-its-tree
From `base/patterns/non-vacuous-checks.md`. `check-can-fail` is the row this feature makes
executable, so it is carried in both forms: as the inherited row, and as `MUT-SELF-APPLIED`.

### S3-BASELINE  (from stack pin `S3`)
```gherkin
Given the runner
When it executes
Then it needs only bash, coreutils and python3, with no manifest, lockfile or install step
```
