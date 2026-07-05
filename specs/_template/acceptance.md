# Acceptance — <feature>

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the
> eval and the UAT step. The deterministic portion materialises as a test in `/contract`.

## Criterion: <name>  (deterministic)
```gherkin
Given <precondition>
When <action>
Then <observable and measurable result>
```

## Criterion: <name>  (non-deterministic → eval case)
_(behaviour/quality that is not unit-tested; generates a case in `evals/cases/`)_
