# Acceptance — Derived phase-tracker (`scripts/status.sh`)

> Measurable acceptance criteria in BDD. EACH criterion IS the eval and the UAT step. The
> deterministic portion materialises as a test in `/contract`.
> Fully deterministic — exercised hermetically via `check_86_status.sh` against temp repo
> fixtures (mini `specs/<feat>/` + `verification/reports/`). No non-deterministic eval cases.

## Criterion: PHASE-DERIVE  (deterministic)
```gherkin
Given a fixture feature whose brief/align/distill/plan artifacts are filled and the rest are absent
When I run `scripts/status.sh <feature>`
Then it reports brief/align/distill/plan as done and contract/tasks/implement/verify/uat/retro as pending
```

## Criterion: NON-PLACEHOLDER  (deterministic)
```gherkin
Given a fixture feature freshly scaffolded from _template (all artifacts present but placeholders)
When I run `scripts/status.sh <feature>`
Then every phase is reported PENDING (presence alone is not "done")
```

## Criterion: COVERAGE-DERIVED  (deterministic)
```gherkin
Given a fixture whose plan.md and tasks.md are filled but coverage.md still has a 🔴 criterion
When I run `scripts/status.sh <feature>`
Then implement is PENDING (the coverage state overrides doc presence)
```

## Criterion: CURRENT-NEXT  (deterministic)
```gherkin
Given a fixture done up to and including distill
When I run `scripts/status.sh <feature>`
Then it names the current phase as "plan" and the next command as "/plan"
```

## Criterion: DONE-FEATURE  (deterministic)
```gherkin
Given a fixture with every phase done (all coverage ✅, report BUILD/UAT/retro ✅, retro.md filled)
When I run `scripts/status.sh <feature>`
Then it reports the feature DONE and exits 0
```

## Criterion: ANOMALY-FLAG  (deterministic)
```gherkin
Given a fixture where retro.md is filled but coverage.md still has a 🔴 criterion (out-of-order)
When I run `scripts/status.sh <feature>`
Then it prints a "⚠ anomaly" line naming the offending phases and exits non-zero
```

## Criterion: NORMAL-EXIT0  (deterministic)
```gherkin
Given a coherent in-progress fixture (done up to distill, nothing later)
When I run `scripts/status.sh <feature>`
Then it exits 0 (a WIP feature does not "fail")
```

## Criterion: GAPS  (deterministic)
```gherkin
Given a fixture whose coverage.md has a 🔴 criterion and an orphan row (empty Pillar cell)
When I run `scripts/status.sh <feature>`
Then it surfaces the non-green criterion and the orphan row as coverage gaps
```

## Criterion: READONLY  (deterministic)
```gherkin
Given any fixture feature
When I run `scripts/status.sh <feature>`
Then the fixture is left byte-for-byte unchanged (read-only)
```

## Criterion: UNKNOWN-FEATURE  (deterministic)
```gherkin
Given no specs/<feature>/ directory
When I run `scripts/status.sh <feature>`
Then it prints a clear error and exits non-zero (no crash/stack trace)
```

## Criterion: DEPFREE  (deterministic, invariant tied to deliverable)
```gherkin
Given scripts/status.sh exists
When I inspect it with the shared dep-free helper
Then it invokes only bash/coreutils + python3 (no npm/node/uv/pip toolchain)
```

## Criterion: HELPER-SHARED  (deterministic)  — candidate B
```gherkin
Given tests/lib.sh
When I inspect it and the checks
Then it defines an invocation-aware dep-free assertion helper, and check_82 / check_84 /
  check_95 / check_86 use it instead of a duplicated inline grep
```

## Criterion: SELF-CHECK  (deterministic)
```gherkin
Given tests/run.sh
When it runs
Then it includes check_86_status.sh exercising status.sh and the suite is green
```
