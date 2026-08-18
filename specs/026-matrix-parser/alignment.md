# Alignment — 026-matrix-parser

Measurability Gate over `brief.md` × `north-star.md` as amended by ADR `0005`. Run by the 006
engine: `schema-valid` exit 0; `scope-reject` exit 1 on all five objectives; `align-verdict`
`aligned`. Proved live in the same run — a control carrying the exact predicate *"release,
deployment or rollout of the software being built"* fired at exit 0.

## Verdict

**`aligned`** — `{pillarFit: 4, scopeCompliance: 5, missionAdvancement: 3}`, threshold 3.
Falsification run: dropping `missionAdvancement` to 2 returns `needs-amendment`.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | **4** | **Not 5.** `real-enforcement` is about gates blocking closure; this blocks nothing new. The pillar it genuinely serves is `measurable-impact` — a tool that names the wrong criterion makes the matrix's own numbers untrustworthy — but O1 and O3 are internal structure, and mapping structure to a pillar at 5 would be the loose mapping `/align` step 4 warns against. |
| scope compliance | **5** | `in_scope` names *"evals, verification, and UAT of the method"*. The matrix is the method's central artifact. No `out_of_scope` predicate is approached. |
| mission advancement | **3** | **At threshold, and it belongs there.** One user-visible defect is fixed. Everything else is a refactor whose declared success is that **no number moves**. Scoring 4 would be crediting tidiness. 023 scored 3 for a 3-row cleanup; this is smaller in user-visible terms and the scale has to stay honest across features. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — one parser, sourced by all three | `measurable-impact` |
| O2 — `status.sh` names the right criterion on a six-column matrix | `measurable-impact` |
| O3 — an unreadable header is reported by every consumer | `real-enforcement` |
| O4 — no verdict changes anywhere else | `measurable-impact` |
| O5 — green, hermetic, cost measured | `frictionless-adoption`, `agnostic-portability` |

## Pillar provenance (stamped by `/align`)

| Pillar | `since` |
|---|---|
| `real-enforcement` | `0001` |
| `agnostic-portability` | `0001` |
| `measurable-impact` | `0002` |
| `frictionless-adoption` | `0004` |

## Orphans

None.

## Pillars deliberately NOT claimed

- **`agnostic-portability` only by O5, and only as *stays hermetic*.** None of the three tools is
  vendored — measured while scoping, they are in neither `KEEP` nor `DROP` — so nothing here travels
  and claiming portability would be false.

## Gate note

1. **The success condition is that nothing moves, which makes this the easiest feature to fake.**
   A refactor is judged by its diff, and a diff always looks like work. The only honest test is the
   numbers **before** and **after**: `205 obliged, 137 undeclared, 0 unresolvable` and `15 case rows,
   15 resolved, 0 orphan`. They are recorded here, before the work, so they cannot be quietly
   re-derived from the new code and presented as agreement.

2. **`status.sh` already contains both the right idea and the wrong one.** Its status read uses
   `$(NF-1)` — layout-agnostic — and its criterion read uses `$5`. The fix is not new knowledge; it
   is applying what that file already knew in one place to the other. Worth stating because it makes
   the eight-day-old defect less a discovery than a failure to look.

3. **The temptation is to reformat `001-example`.** One file, six columns, and the whole class
   disappears from this repository. It would also delete the only instance that proves the class
   exists, and the next adopter writes whatever layout they like. The outlier is the test data.

4. **`mutate.sh coverage`'s current correctness is luck and must be described as such.** It reports
   the right answer on `001-example` because the cell it mistakes for Status is empty. A refactor
   that preserves the output without saying why the old output was right would be preserving a
   coincidence.
