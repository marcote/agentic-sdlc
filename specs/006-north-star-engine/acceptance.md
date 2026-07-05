# Acceptance — North Star engine

> Measurable acceptance criteria in BDD. EACH criterion IS simultaneously the eval and the
> UAT step. The deterministic portion materialises as a test in `/contract`.
> This feature is **fully deterministic** — all criteria are tests; no non-deterministic
> eval cases (the engine has no LLM/semantic component; scoring stays with the `/align` judge).

## Criterion: SCHEMA-VALID  (deterministic)
```gherkin
Given a schema-valid north-star.md
When I run `engine.py schema-valid FILE`
Then it exits 0 with no error output
```

## Criterion: SCHEMA-INVALID  (deterministic)
```gherkin
Given a north-star.md that is well-formed JSON but schema-invalid (empty mission, a pillar
  missing id/statement/signal, an empty scope array, or a non-numeric threshold)
When I run `engine.py schema-valid FILE`
Then it exits 1 and prints a precise reason (the offending field) on stderr
```

## Criterion: SCHEMA-MALFORMED  (deterministic)
```gherkin
Given a file with broken JSON or no canonical ```json``` block
When I run `engine.py schema-valid FILE`
Then it exits 2 (error), distinct from the exit-1 "schema-invalid" answer
```

## Criterion: SETS-CHANGED  (deterministic)
```gherkin
Given OLD and NEW north-star files whose pillars or scope sets differ
When I run `engine.py sets-changed OLD NEW`
Then it prints "changed" and exits 0
```

## Criterion: SETS-SAME-PROSE  (deterministic)
```gherkin
Given OLD and NEW that differ only in surrounding prose, in mission wording that leaves the
  governed sets intact, or in alignment.threshold
When I run `engine.py sets-changed OLD NEW`
Then it prints "same" and exits 0
```

## Criterion: SETS-ORDER-AGNOSTIC  (deterministic)
```gherkin
Given OLD and NEW identical except that pillars or scope entries are reordered
When I run `engine.py sets-changed OLD NEW`
Then it prints "same" (comparison is set-based, not positional)
```

## Criterion: SCOPE-HIT  (deterministic)
```gherkin
Given an objective containing a full out_of_scope predicate as a contiguous substring
When I run `engine.py scope-reject OBJECTIVE`
Then it exits 0 and prints the matched predicate
```

## Criterion: SCOPE-MISS-PARTIAL  (deterministic)
```gherkin
Given an objective that only partially overlaps a predicate
  (e.g. "deterministic engine" vs the predicate "stack-specific deterministic engine")
When I run `engine.py scope-reject OBJECTIVE`
Then it exits 1 (no hit) — the match is conservative
```

## Criterion: SCOPE-NORMALIZE  (deterministic)
```gherkin
Given an objective that contains a full predicate modulo case and extra whitespace
When I run `engine.py scope-reject OBJECTIVE`
Then it exits 0 (normalization: lowercase + collapsed whitespace) and prints the predicate
```

## Criterion: VERDICT-REJECTED  (deterministic)
```gherkin
Given align-verdict input with scopeHit=true (even if all scores are 5)
When I pipe it to `engine.py align-verdict`
Then it prints "rejected"
```

## Criterion: VERDICT-BLOCKED  (deterministic)
```gherkin
Given align-verdict input with scopeHit=false and orphan=true
When I pipe it to `engine.py align-verdict`
Then it prints "blocked"
```

## Criterion: VERDICT-ALIGNED  (deterministic)
```gherkin
Given align-verdict input with no scopeHit, no orphan, and all three dimensions ≥ threshold
When I pipe it to `engine.py align-verdict`
Then it prints "aligned"
```

## Criterion: VERDICT-NEEDS-AMENDMENT  (deterministic)
```gherkin
Given align-verdict input with no scopeHit, no orphan, but some dimension below threshold
When I pipe it to `engine.py align-verdict`
Then it prints "needs-amendment"
```

## Criterion: ADR-PRESENT  (deterministic)
```gherkin
Given an added-files list including memory/north-star/decisions/NNNN-slug.md
When I run `engine.py has-adr-for --added "…"`
Then it exits 0 (an ADR is present for the change window)
```

## Criterion: ADR-ABSENT  (deterministic)
```gherkin
Given an added-files list with no decisions/NNNN-slug.md (README.md or 0001.md do not count)
When I run `engine.py has-adr-for --added "…"`
Then it exits 1 (no ADR present)
```

## Criterion: GATE-REUSE  (deterministic)
```gherkin
Given the rewired scripts/amendment-gate.sh
When I inspect it
Then it invokes scripts/north-star/engine.py and no longer embeds its own JSON
  parsing/validation heredoc or bash has_new_adr (single source of truth)
```

## Criterion: GATE-REGRESSION  (deterministic)
```gherkin
Given the existing amendment-gate scenarios (check_95_amendment_gate.sh)
When the suite runs after the rewire
Then every scenario still passes (behavior identical: same exit semantics and messages)
```

## Criterion: DEP-FREE  (deterministic, invariant tied to deliverable)
```gherkin
Given the engine module exists at scripts/north-star/engine.py
When I inspect its imports and the source path
Then it imports only python3 stdlib (no third-party, no Node/npm, no pip manifest)
```

## Criterion: SELF-CHECK  (deterministic)
```gherkin
Given tests/run.sh
When it runs
Then it includes a check that exercises engine.py and the whole suite is green
```
