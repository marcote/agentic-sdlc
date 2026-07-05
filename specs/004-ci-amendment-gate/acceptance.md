# Acceptance — CI-gate for the North Star amendment

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the
> UAT step. The deterministic portion is materialized as a test in `/contract`.
> All script criteria are deterministic (bash + fixtures). The two real-blocking criteria
> (`AMEND-BLOCK-REAL`, `AMEND-BLOCK-PUSH`) are GitHub config → UAT.

## Criterion: AMEND-BLOCK-NO-ADR  (deterministic)
```gherkin
Given a base..head range whose diff changes the pillars/scope sets of the north-star.md JSON block
When there is no new memory/north-star/decisions/NNNN-*.md file in the range
Then the amendment-gate fails (exit ≠ 0) citing "amendment de pillars/scope sin ADR"
```

## Criterion: AMEND-PASS-WITH-ADR  (deterministic)
```gherkin
Given a range that changes pillars/scope and adds a new decisions/NNNN-*.md
When the resulting JSON block is schema-valid and tests/run.sh is green
Then the amendment-gate passes (exit 0)
```

## Criterion: AMEND-NO-ADR-FOR-PROSE  (deterministic)
```gherkin
Given a diff to north-star.md that only touches prose, mission wording that does not change the sets, or alignment.threshold
When there is no new ADR in the range
Then the amendment-gate passes (exit 0) — does not require an ADR
```

## Criterion: AMEND-SET-SEMANTICS  (deterministic)
```gherkin
Given a diff that reorders or reformats the JSON block without altering the pillars/scope set content
When the amendment-gate runs
Then it passes (exit 0) — detection is by sets, not by text, so there is no false positive
```

## Criterion: AMEND-SCHEMA-VALID  (deterministic)
```gherkin
Given a pillars/scope change that leaves the JSON block schema-invalid (empty statement/signal, empty scope array, etc.)
When the amendment-gate runs, even with a new ADR present
Then it fails (exit ≠ 0) citing "North Star schema-invalid"
```

## Criterion: AMEND-SUITE-GREEN  (deterministic)
```gherkin
Given a pillars/scope amendment with ADR and schema-valid
When tests/run.sh is red
Then the amendment-gate fails (exit ≠ 0) — requires the suite green in addition to ADR + schema
```

## Criterion: DEV-UNBLOCKED  (deterministic)
```gherkin
Given a range whose diff does NOT touch the pillars/scope sets of north-star.md (normal feature work)
When the amendment-gate runs
Then it passes (exit 0, not-applicable) — does not block development (preserves principle 4)
```

## Criterion: CONST-EXCEPTION  (deterministic)
```gherkin
Given memory/constitution/constitution.md after the feature
When it is inspected
Then it records that the blocking amendment gate is consistent with the productivity-first intent of principle 4 — the block is narrow (only North Star pillars/scope), feature development is not blocked
```

## Criterion: DEP-FREE  (deterministic)
```gherkin
Given the source after the feature
When it is inspected
Then there is no package.json/package-lock/node_modules nor installable toolchain (uv/pip/npm); only bash/coreutils + python3 stdlib + GitHub Actions
```

## Criterion: SELF-CHECK  (deterministic)
```gherkin
Given the harness after the feature
When tests/run.sh runs
Then it is green and covers the new layer (existence of the gate script + the workflow, and the base/head scenarios of the gate)
```

## Criterion: AMEND-BLOCK-REAL  (deterministic in outcome; verified in UAT — GitHub config)
```gherkin
Given branch protection on main requiring the amendment-gate status-check
When a PR has the amendment-gate red (pillars/scope change without ADR)
Then the PR is NOT mergeable
```

## Criterion: AMEND-BLOCK-PUSH  (deterministic in outcome; verified in UAT — GitHub config)
```gherkin
Given branch protection on main requiring the status-check and prohibiting bypass
When a direct pillars/scope change is pushed to main without passing the gate
Then the push is rejected
```
