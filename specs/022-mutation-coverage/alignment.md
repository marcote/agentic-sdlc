# Alignment — 022-mutation-coverage

Measurability Gate over `brief.md` × `north-star.md` as amended by ADR `0005`. Run by the 006
engine: `schema-valid` exit 0; `scope-reject` exit 1 on all six objectives; `align-verdict`
`aligned`. The filter was proved live in the same run — the control objective *"blocking commit
hooks"* fired at exit 0.

## Verdict

**`aligned`** — `{pillarFit: 5, scopeCompliance: 5, missionAdvancement: 4}`, threshold 3.
Falsification run: dropping `missionAdvancement` to 2 returns `needs-amendment`.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | **5** | `real-enforcement`'s statement is *"gates block closure when a condition is missing"*. This is that sentence with a condition that was previously optional. No inference required. |
| scope compliance | **5** | `in_scope` names *"evals, verification, and UAT of the method"*. The gate runs at `/verify` and its subject is the coverage matrix. No `out_of_scope` predicate is approached, including ADR `0005`'s four lifecycle ones. |
| mission advancement | **4** | **Not 5, deliberately.** 021 scored 5 because its number existed before it closed. This feature's own gate verdict will be 0 by construction — I write the declarations, then the gate confirms I wrote them. Whether *obliging* catches a criterion its author would not have declared is unobservable until a later feature runs under it. The debt figure (137) is real today; the enforcement claim is not yet. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — the obligation is computed from `coverage.md`, no branch ref, no network | `real-enforcement`, `agnostic-portability` |
| O2 — an unresolvable row is reported, never silently skipped | `real-enforcement` |
| O3 — rows that cannot declare are excluded by rule, not by exception | `real-enforcement` |
| O4 — this feature's own criteria pass the gate it ships (`D4`) | `real-enforcement` |
| O5 — the standing debt is reported as a figure, where it is read again | `measurable-impact` |
| O6 — green, hermetic, and the added cost measured | `frictionless-adoption`, `agnostic-portability` |

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

- **`frictionless-adoption` is claimed only by O6.** This *adds* a mandatory condition at `/verify`,
  which under ADR `0004`'s amended signal is friction that must carry a recorded justification. The
  justification is B15's measurement, and the cost is bounded per feature rather than per repo —
  but claiming this pillar as *advanced* would be backwards.

## Gate note

1. **The predicate is derived from the matrix, and the matrix is not uniform.** Measuring the debt
   on this branch produced three different answers — 157, 47, 137 — as the predicate was corrected.
   The 47 came from requiring `tests/check_` in the linked-test column, which silently dropped every
   feature before 015 because they write `check_92_stack.sh` with no directory. **A predicate that
   drops what it cannot parse reports a smaller, cleaner, wrong number.** That is `B11`, and O2
   exists because I walked into it while writing this brief.

2. **The gate's own verdict on this feature proves almost nothing, and the report must say so.**
   `D4` requires the gate be run against itself; it does not make that run evidence of enforcement.
   The distinction matters because 020's report was careful about exactly this — an opt-in
   capability claimed as a closed family would have been the sixth instance, one level up.

3. **The debt figure will decay if it is only written here.** 137 recorded in a brief is a number
   nobody reads again. It has to land where a reader already looks — the `wow-report` or the
   verification report — or O5 is decoration. This is the same failure the sweep dates were
   invented to fix.

4. **The obligation must not be satisfiable by a worthless declaration.** `[mut$ true $]` would
   pass this gate and fail `mutate.sh run`, which is the correct division: this feature asks whether
   a declaration exists, 020 asks whether it works. Both run at `/verify`, so the loophole is
   closed by the pair, not by either alone. Stated here so no later reader mistakes it for an
   oversight.
