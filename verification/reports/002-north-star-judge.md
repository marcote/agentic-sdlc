# Eval result — north-star-judge (feature 002)

> Non-deterministic criterion **JUDGE-ALIGNMENT**. Cases in
> `evals/cases/north-star-judge.md`, scored against
> `memory/north-star/base/alignment-rubric.md`. Pillars are **illustrative**
> (`pilar-a`, `pilar-b`) — this repo is the template, `north-star.md` is a
> placeholder. Status: 📋 case.

## Case 1 — in-scope brief

Objective: read-only filter that shows which elements advance a `signal` of
`pilar-a`, without modifying data.

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 4 | maps to `pilar-a` via an explicit `signal`, no orphan |
| scope compliance | 5 | squarely in `in_scope` (read-only/visualization) |
| mission advancement | 4 | observable effect on the named `signal` |

Derived verdict: **`aligned`** (all 3 dimensions ≥ 3, no scope hit, no
orphan). **Matches** the expected behavior.

## Case 2 — plausible-but-out-of-scope brief

Objective: button that lets users mutate `north-star.md` (pillars/scope) from
the UI, without PR or review.

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 3 | mentions the North Star; superficially relevant |
| **scope compliance** | **1** | mutates scope/pillars without ADR or PR → violates `amendment-protocol.md`, hits `out_of_scope` |
| mission advancement | 2 | does not advance any `signal` |

Derived verdict: **`rejected`** — the scope hit cuts the aggregation regardless
of the other dimensions (`plan.md` decision 3). Scope compliance scores
specifically **< 3** (not a diluted average). **Matches** the expected behavior.

## Conclusion

Both cases match their expected verdict (`aligned` / `rejected`); Case 2
shows scope compliance `< 3` specifically. This is the **expected result
(illustrative — each adopting project runs this eval against its own real North
Star)**: `north-star.md` in this repo is a placeholder without real
`out_of_scope` predicates, so there is no "passing" eval in the strict sense
yet — what this document records is that the judge, scoring against the
illustrative pillars `pilar-a`/`pilar-b`, produces the verdict that the rubric
predicts. The deterministic aggregation engine (`alignVerdict`) is a per-stack
contract — not unit-tested here (criterion `ALIGN-VERDICT-CONTRACT`);
reference: `poirot-fe scripts/north-star/`.
