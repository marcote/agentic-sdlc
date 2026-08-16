# Tasks — Lifecycle boundary

> Done when all criteria are `✅ uat` and the suite is ≥ **488 PASS / 0 FAIL**.

**Written after implementation, for the second consecutive feature.** `coverage.md` was again the
work-list. That is now two data points for `B13`, which asks whether `/tasks` earns its place once
`/distill` has frozen a traced criterion matrix — and it is evidence, not an excuse.

## T1 — Contract in 🔴 RED
8 criteria asserted against a North Star that has no lifecycle predicates and an ADR that does not
exist. 6 red; the 2 that cannot be red recorded in `coverage.md`.

## T2 — ADR `0005` first, the diff second
The gate's first condition is that an ADR was **added** in the same change. Writing the diff first
is how a governance change becomes a commit retrofitted with its justification.

## T3 — Four predicates into `out_of_scope`
5 → 9. `mission`, `pillars`, `in_scope` and `alignment` byte-identical.

## T4 — The gate against this feature's own diff
Both directions on one diff: blocked without `0005`, passing with it. Then `--range main..HEAD`,
the mode CI actually uses.

## T5 — Close the RED, then break it on purpose
Eight mutations, one at a time. M2 exposed `NS-PREDICATE-REACHABLE` as vacuous.
