# Acceptance — North-Star Governance + Measurability Gate

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the
> eval and the UAT step. The deterministic portion is materialized as a test in
> `/contract`. Criteria marked **documented contract — per-stack engine
> (deferred)** describe behavior of the deterministic engine (schema
> validation, scope predicates, verdict aggregation) that this repo specifies
> but does NOT implement or unit-test — see `plan.md` decision 2 and
> `poirot-fe scripts/north-star/*.mjs` as reference implementation.

## Criterion: NS-BASE — North-Star base layer present  (deterministic · structural)
```gherkin
Given the repo has the north-star-governance capability installed
When memory/north-star/base/{schema.md, alignment-rubric.md, amendment-protocol.md, adr-template.md, README.md} are listed
Then all 5 files exist
And README.md documents the extends: base mechanism
```

## Criterion: NS-PLACEHOLDER — north-star.md is a valid placeholder  (deterministic · structural)
```gherkin
Given memory/north-star/north-star.md
When its frontmatter is read
Then it contains "extends: base"
And it carries a ```json``` skeleton block marked "_(completar por proyecto)_"
```

## Criterion: NS-SCHEMA-CONTRACT — measurable form documented  (documented contract — per-stack engine, deferred)
```gherkin
Given schema.md documents mission, pillars[] (id+statement+signal),
  scope.in_scope/out_of_scope, and alignment.threshold as required fields
When an adopting repo implements its own validator (equivalent to validateNorthStar)
Then a north-star.md missing a required field fails validation with a clear reason
```
_(Not unit-tested in this repo — the concrete validator is per-stack;
`poirot-fe scripts/north-star/schema.mjs` is the reference implementation already
unit-tested there.)_

## Criterion: ALIGN-CMD — /align command+skill exist and document the model  (deterministic · structural)
```gherkin
Given .claude/commands/align.md and .claude/skills/align/SKILL.md
When they are read
Then they document: input brief.md + north-star.md, output alignment.md, and the
  3-layer model (scope predicates, orphan check, LLM-judge)
```

## Criterion: ALIGN-VERDICT-CONTRACT — verdict semantics  (documented contract — per-stack engine, deferred)
```gherkin
Given a brief objective and a schema-valid North Star
When scopeReject + orphan-check + alignVerdict are evaluated (per-stack)
Then an out_of_scope hit produces "rejected"; an orphan produces a block;
  all 3 dimensions ≥ threshold with no reject/orphan produce "aligned"; and
  being in-scope without orphan but below threshold produces "needs-amendment"
```
_(Not unit-tested in this repo — see `poirot-fe scripts/north-star/align.mjs`
(`scopeReject`, `alignVerdict`) + its suite
`tests/unit/north-star/align.node.spec.js`.)_

## Criterion: MEAS-GATE — /distill refuses without a measurable and aligned intent  (deterministic · structural)
```gherkin
Given .claude/skills/distill/SKILL.md
When its procedure is read
Then it contains a Step 0 that mentions "alignment.md" and "Measurability Gate"
And specifies that only the "aligned" verdict allows proceeding
And documents the bootstrap exception for the feature that introduces /align
```

## Criterion: AMEND-ADR — scope changes are auditable  (deterministic · structural · [given] audit-logging)
```gherkin
Given memory/north-star/base/amendment-protocol.md and adr-template.md
When they are read
Then they document that a change to scope/pillars requires an ADR in
  memory/north-star/decisions/NNNN-*.md and lands via PR
And that a change without a corresponding ADR is a flaggable governance violation
```

## Criterion: COVERAGE-PILLAR — traceability up to the north star  (deterministic · structural)
```gherkin
Given specs/_template/coverage.md
When its column layout is read
Then it includes a Pillar column linking each row pillar → objective → criterion
```

## Criterion: WOW-2LAYER — two-layer Way-of-Work  (non-deterministic → UAT)
_(The README/docs distinguish harness=governance from execution-runtime=adopter,
generically, without naming any specific runtime as required by the harness.
Validated by manual reading/UAT, not by grep — it is prose content, not
reliably grep-able structural form.)_

## Criterion: SELFCHECK — the capability is part of the harness integrity  (deterministic · structural)
```gherkin
Given the north-star-governance capability is fully installed
When bash tests/run.sh runs
Then tests/check_80_north_star.sh (auto-picked by the glob) passes
And the pre-existing checks 00–70 remain green
```

## Criterion: JUDGE-ALIGNMENT — the judge scores alignment sensibly  (non-deterministic → eval case)
_(An in-scope brief scores ≥3 on all 3 dimensions; a plausible-but-out-of-scope
brief scores <3 specifically on scope compliance, not as a diluted average.
Cases in `evals/cases/north-star-judge.md`, scored against
`memory/north-star/base/alignment-rubric.md`.)_

## Deferred (justified)
- `[given] base/idempotency` — deferred: no retries/webhooks (this layer is
  governance markdown).
- `[given] base/rate-limiting` — deferred: no network surface.
