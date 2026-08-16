# Eval case — JUDGE-BOUNDARY-CHANGES-A-VERDICT

**Feature:** 019-lifecycle-boundary · **Scored by:** an independent judge, not the model that
wrote the predicates · **Not before:** 2026-09-08

## Question

Does the lifecycle boundary in `scope.out_of_scope` ever change a verdict, or is it a line that
reads well?

## What counts as evidence

**Confirmed** — an `/align` run scores a brief's `scopeCompliance` below what it would have scored
without the four predicates, and the `alignment.md` cites one of them by name. A `rejected` verdict
from `scope-reject` firing on a real brief counts doubly, because twelve features never produced a
hit.

**Refuted** — the sweep arrives, briefs have been scored, and no `alignment.md` cites a lifecycle
predicate. Then the boundary is documentation, which is worth something but is not what was
claimed.

## Why it cannot be scored now

ADR `0005` records a boundary. Its payoff is a future brief judged differently *because* the lines
exist, and this repository writes roughly one brief a week. The honest verdict before then is
`pending-observation`.

## Trap

Do not score this against 019's own alignment. That was written before the amendment and could not
have cited it.
