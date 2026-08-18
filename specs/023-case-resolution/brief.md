# Brief — A `📋 case` row that names no case file renders exactly like one that does

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

A `📋 case` row is a criterion scored by judgment rather than by an assertion. The case file is what
an independent judge reads. Nothing checks that the row names one, or that the file it names exists.

**Measured on this branch, in both directions:**

| | |
|---|---|
| `📋 case` rows in `specs/*/coverage.md` | **14** |
| resolve to a case file that exists | 11 |
| name a file that **does not exist** | **2** |
| name **no path at all** | **1** |
| case files on disk cited by no row | 0 |

The two dangling citations are `evals/cases/audit-worth-it.md`, named by 021 and never written, and
`evals/cases/reject-msg.yaml`, named by `001-example`. The row naming nothing is 022's
`JUDGE-OBLIGATION-CAUGHT-ONE` — written two days ago, by the author of the gate that closes this
exact family for the other column.

This makes a `📋 case` row resolve, the same way 022 made a criterion's mutation resolve.

## Why / motivation

**The failure looks exactly like the success.** In the rendered matrix, a row whose case file was
never written and a row whose case is merely unscored are the same green-adjacent `📋 case`. That is
`B5`, `B9`, `B11` and now `B14` — the family this repository keeps paying for.

**`B14`'s own numbers were wrong, and that is the sharper finding.** The entry claims *32 rows, 21
pointing at no case file*. The real figures are 14 and 1. The 32 came from `grep -c '📋 case'` over
`specs/*/coverage.md`, which counts the **status-legend line present in all 19 files**. A count taken
from a loose grep, inside the backlog entry describing claims that point at nothing — `B10`'s family,
one level up. The corrected entry is part of this feature.

**It unblocks measuring `B2`.** `B2` is *"eval cases have never been scored"*, deferred until an
independent judge exists. That deferral is only honest if the set is known. With three rows
unresolvable, nobody could say how many cases there are to score.

**Why now.** 021 shipped a dangling citation and 022 shipped a row naming nothing. Two consecutive
features, both while building mechanisms against this family. The next feature inherits the same
matrix template.

## Success metrics

- **Every `📋 case` row resolves to a case file that exists**, and the three that do not are fixed:
  written, repointed, or the row changed to something honest.
- **A row that names no path is reported, not tolerated.** A promise to judge later is not a case;
  it is a row that will render as scored-pending forever.
- **A case file no row cites is reported too.** Zero today, and the check must be able to say so
  rather than only being able to say nothing.
- **The count is derived by the tool, never by a grep**, so `B14`'s own failure cannot recur in the
  entry that replaces it.
- **The gate runs where the other resolution gates run** — `/verify` and CI, never inside
  `tests/run.sh`.
- **The suite stays green and hermetic**, and the added cost is measured.

## Out of scope

- **Scoring the cases.** That is `B2`, and it needs an independent judge. This makes the set
  countable; it does not judge it.
- **Whether a case file is any good.** Existence is not quality — the same division 022 drew between
  *a declaration exists* and *a declaration works*.
- **`001-example`.** It is the deliberately partial template example and one of the two dangling
  citations is in it. Whether it should carry a real case file or stop pretending to is a decision
  about the example, taken in this feature and recorded, not assumed.

## Dependency

`scripts/mutate.sh coverage` and its three-bucket resolution discipline (022), the `coverage.md`
matrix format, `evals/cases/`, and the `/verify` skill.

**`D3` applies** — the tool governs this repository's own workflow. **`D4` applies**: this ships a
gate, so it is run against itself and its verdict recorded rather than asserted.

**Stated in advance:** the gap is **3 rows of 14**, not the 21 of 32 the backlog advertised. This is
a small feature and its value is the mechanism, not the cleanup. Saying so here means it cannot
later be presented as having closed a large hole.
