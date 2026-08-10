# Acceptance — 017-executable-derivations

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the UAT step.

## Criterion: DERIV-RUNS  (deterministic)
```gherkin
Given a retro field stating a number with an executable derivation
When the suite runs
Then the command is executed and its output compared to the number
And agreement passes
```

## Criterion: DERIV-MISMATCH  (deterministic)
```gherkin
Given a field claiming 8 whose command prints 10
When the suite runs
Then it fails, naming the retro, the field, the claim and the output
```

## Criterion: DERIV-BROKEN-CMD  (deterministic)
```gherkin
Given a derivation whose command exits non-zero or prints nothing
When the suite runs
Then it fails with a message distinct from a mismatch
And the message says the command failed, not that the number is wrong
```

## Criterion: DERIV-NON-INTEGER  (deterministic)
```gherkin
Given a derivation whose command prints text rather than an integer
When the suite runs
Then it fails, naming what was printed
```

## Criterion: DERIV-MULTI  (deterministic)
```gherkin
Given one line stating two numbers, each with its own derivation
When the suite runs
Then both commands run and both are compared
And a mismatch in the second is reported, not masked by the first
```

## Criterion: DERIV-PROSE-KEPT  (deterministic)
```gherkin
Given a field whose claim is not a number and carries a prose derivation
When the suite runs
Then the prose derivation is accepted and never executed
```

## Criterion: DERIV-BRACKET  (deterministic)
```gherkin
Given a derivation whose command contains a closing bracket
When the suite runs
Then it is rejected by name rather than parsed to the wrong command
```

## Criterion: DERIV-NON-VACUOUS  (deterministic)
```gherkin
Given the nine closed retros after migration
When the suite runs
Then the number of commands actually executed is at least ten
And a run that executed none fails, since a silent skip is the failure this repository has spent three features on
```

## Criterion: DERIV-MIGRATED  (deterministic)
```gherkin
Given every closed retro
When the check runs over all of them
Then every numeric Face B claim carries an executable derivation
And whatever disagreed has been fixed or explained in place
```

## Criterion: DERIV-SCOPE-STATED  (deterministic)
```gherkin
Given the retro template
When an author reads it
Then it says commands are executed, from where, and that this matches the charter Guard precedent
```

## Criterion: JUDGE-DERIV-HONEST  (non-deterministic → eval case)
_Did any derivation get written to match a number already decided, rather than the number read off
the command? A command chosen to produce the desired answer is filler-to-comply with extra steps.
Scored by an independent judge._

## Inherited `[given]` criteria

### hermetic-env  (from `base/patterns/hermetic-tests.md`)
```gherkin
Given a detached-HEAD, no-terminal checkout
When the suite runs the derivations
Then they need no terminal, no network and no local main
```

### check-can-fail · check-rejects-by-diagnostic · check-names-its-tree
From `base/patterns/non-vacuous-checks.md` — three of five. `check-traceable` and
`check-no-self-match` are discharged by `check_96` per the project override.
