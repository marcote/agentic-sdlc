# Alignment — 023-case-resolution

Measurability Gate over `brief.md` × `north-star.md` as amended by ADR `0005`. Run by the 006
engine: `schema-valid` exit 0; `scope-reject` exit 1 on all six objectives; `align-verdict`
`aligned`. The filter was proved live in the same run — a control objective carrying the exact
predicate *"production monitoring, incident response or usage analytics"* fired at exit 0.

**A note on that control, because the first one I wrote did not fire.** `scope-reject` matches a
**contiguous predicate phrase inside the objective**, not the other way round. A paraphrase
(*"production monitoring and usage analytics"*) returns exit 1 and reads as a clean pass. The filter
is deliberately conservative and semantic scope violations are the judge's job — but a control that
does not fire proves nothing, and I nearly recorded one.

## Verdict

**`aligned`** — `{pillarFit: 5, scopeCompliance: 5, missionAdvancement: 3}`, threshold 3.
Falsification run: dropping `missionAdvancement` to 2 returns `needs-amendment`.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | **5** | `real-enforcement`'s statement is *"gates block closure when a condition is missing"*. A `📋 case` row naming a file that does not exist is a missing condition rendering as a present one. |
| scope compliance | **5** | `in_scope` names *"evals, verification, and UAT of the method"*. `evals/cases/` is that, literally. No `out_of_scope` predicate is approached. |
| mission advancement | **3** | **At threshold, and it should be.** The measured gap is **3 rows of 14**. 022 scored 4 for shipping a gate whose payoff was deferred; this one ships a gate whose payoff is deferred *and* whose backlog was 7× smaller than advertised. A 4 here would be scoring the mechanism's elegance rather than what it moves. The doubt rule says prefer the lower score, and this is the case it was written for. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — every `📋 case` row resolves to a case file that exists | `real-enforcement` |
| O2 — a row naming no path is reported, not tolerated | `real-enforcement` |
| O3 — a case file no row cites is reported too | `measurable-impact` |
| O4 — the count is derived by the tool, never by a grep | `measurable-impact` |
| O5 — the gate runs at `/verify` and in CI, never in the suite | `real-enforcement` |
| O6 — green, hermetic, cost measured | `frictionless-adoption`, `agnostic-portability` |

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

- **`frictionless-adoption` only by O6.** This adds a condition at `/verify`. Under ADR `0004`'s
  amended signal that is friction needing a recorded justification, not an advance.

## Gate note

1. **The backlog entry that motivated this feature was wrong by 7×, and the correction is the
   finding.** `B14` claimed 32 rows and 21 unresolvable; the true figures are 14 and 1. The 32 came
   from a `grep -c` that counted the status-legend line in all 19 matrices. **The entry describing
   claims that point at nothing carried a count derived from a loose grep** — `B10`'s family, in the
   place least able to afford it. Whatever this feature builds, that correction ships.

2. **Three rows is not a hole, and the report must not dress it as one.** The value is that the
   check cannot be opted out of by omission. Stating the size here means the retro cannot later
   present a small cleanup as a large one.

3. **The obvious rule is wrong and must not be adopted silently.** *"Every `📋 case` row must name a
   file"* would force a case file to exist before the judgment it describes is possible — 022's row
   is honestly *"next feature"*, because the thing to judge does not exist yet. A rule that turns an
   honest deferral into a stub file makes the matrix look more complete and mean less. The design
   has to distinguish *deferred with a trigger* from *pointing at nothing*, and if it cannot, the
   honest outcome is a narrower rule.

4. **Existence is not quality**, the same division 022 drew. A one-line case file passes this gate.
   Scoring is `B2` and needs an independent judge.
