# Tasks — North Star integrity

> Order is dependency-driven. Done when all 19 deterministic criteria are 🟢 and the suite is
> ≥ **410 PASS / 0 FAIL** (the pre-016 baseline).

## T1 — Contract in 🔴 RED (`/contract`)
All deterministic criteria as assertions, each with its own fixture. Negative fixtures get their
own sandbox.
- Criteria: all → 🔴.

## T2 — Schema: `since` + the unfilled rule
`memory/north-star/base/schema.md`: `since` field rules, the unfilled definition, exit 3.
- Criteria: supports **NS-UNFILLED**, **NS-SINCE-REQUIRED**.

## T3 — Engine: `SEEDED`, unfilled, `since`
Exit 3 before any `since` validation (D4-impl). Every rejection names what it rejected. Docstring
states the exit contract — that docstring **is** the CLI contract `S2`'s hedge depends on.
- Criteria: **NS-UNFILLED**, **NS-UNFILLED-PARTIAL**, **NS-TODO-NOT-FALSE-POSITIVE**,
  **NS-SEED-TABLE-SYNC**, **NS-SINCE-REQUIRED**, **NS-SINCE-RESOLVES**,
  **NS-UNFILLED-BEFORE-SINCE**, **NS-ENGINE-CLI-ONLY**.

## T4 — Amendment gate: provenance staleness
Additive; governed hash unchanged. Names the pillar it blocked on.
- Criteria: **AMEND-PROV-STALE**, **AMEND-PROV-ONLY**.

## T5 — Skill contracts
`/align` step 1 stops on exit 3 with a *seed it* message; writes the provenance stamp.
- Criteria: **ALIGN-REFUSES-UNFILLED**, **ALIGN-STAMPS-PROVENANCE**.

## T6 — Migrate the harness's own North Star and the stub (`D3`)
`0001` / `0001` / `0002` / `0004`; **not** `0003`. Stub gains a seeded `since`.
- Criteria: **NS-OWN-MIGRATED**, **NS-VENDORED-STUB-REJECTED**.

## T7 — Close the RED and re-verify
Every rule proved failable on its own fixture; suite ≥ 410/0; `nvc.sh` clean on all three rules.
- Criteria: all → 🟢, plus `HERMETIC-ENV-80` and the three inherited `[given]`.

---

## Not in this breakdown
- **`JUDGE-PROVENANCE-USEFUL`** stays `📋 case` — it cannot be scored before the first sweep on
  2026-09-08, and scoring it here would be the authoring model grading its own output.
- **Two `deferred` rows** carry their reasons in `coverage.md`.
