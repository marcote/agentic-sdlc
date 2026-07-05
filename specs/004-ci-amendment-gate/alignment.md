# Alignment — 004-ci-amendment-gate

Measurability Gate (`/align`) over `brief.md` × `memory/north-star/north-star.md`.
North Star schema-valid (4 pillars) → gate runs.

## Verdict

**`aligned`** — all 3 dimensions ≥ threshold (3), no `out_of_scope` hit, no orphan.
`/distill` may proceed.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 4 | Maps cleanly to `real-enforcement` (its `signal` — "gates block the close; violations caught before the merge" — is *literally* this feature). The dependency-free objective maps to `agnostic-portability` plausibly but indirectly. |
| scope compliance | 4 | In-scope (governance gate + WoW self-validation), but **touches the edge** of the `out_of_scope` predicate "deterministic engine specific to a stack": building a bash checker in the source. Resolved as in-scope because the harness implements its **own** gate in its **own** stack (bash/coreutils + GitHub Actions, just like `tests/check_*.sh` and `verify.yml`), not the adopter's engine. Preferred 4 over 5 for the edge. |
| mission advancement | 4 | Measurable effect on the `signal` of `real-enforcement`: converts amendment enforcement from convention to a deterministic gate that blocks drift before the merge. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| Gate `pillars`/`scope` amendments by deterministic CI (not human approval) | `real-enforcement`, `measurable-impact` |
| Make the gate truly blocking (branch protection requires the status-check) | `real-enforcement` |
| Keep the layer dependency-free and self-check green | `agnostic-portability` |

## Orphans

None. All objectives map to ≥1 pillar.

## Gate note

The only friction point was the scope edge "deterministic engine specific to a
stack". The conservative predicate (`scopeReject`, contiguous-phrase match) did **not**
hit — the objective says "deterministic CI", not the literal phrase — so there was no
hard rejection; the edge evaluation was the judge's work on the scope compliance dimension
(score 4). The key distinction: the harness building its **own** governance gate in its
native stack (bash) is in-scope (`commands, gates, and skills of the governance workflow` +
`WoW self-validation`); shipping the **adopter**'s per-stack engine would be out.
