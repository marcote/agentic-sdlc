# Alignment — 018-adoption-fixture

Measurability Gate over `brief.md` × `north-star.md` as amended by ADR `0004`. Run by the 006
engine: `schema-valid` exit 0; `scope-reject` exit 1 on all five objectives; `align-verdict`
`aligned`.

## Verdict

**`aligned`** — `{pillarFit: 5, scopeCompliance: 4, missionAdvancement: 4}`, threshold 3.
Falsification run: dropping `scopeCompliance` to 2 returns `needs-amendment`.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 5 | `agnostic-portability`'s signal is literally *"the contract remains intact when vendored onto an arbitrary repo/stack"*. Until now that was tested by checking which files landed. This tests whether the contract **holds** there. `real-enforcement` is equally direct: a gate that refuses on our charter and not on a foreign one is a gate that does not work. |
| scope compliance | 4 | The nearest predicate is *"application code or product features of an adopting project"*. The fixture contains a source file, so it touches the edge. It does not cross: no product behaviour is implemented, no product objective is pursued, and the file exists so a stack detector has something to detect. Held at 4 because the edge is real and a later contributor could grow the fixture into an application without noticing. `/uat` must check the fixture is still inert. |
| mission advancement | 4 | Directly observable: either the gates run against a foreign target or they do not. Held below 5 because it closes the **cheap half** of a gap the harness has named repeatedly. The expensive half — whether the workflow is worth its cost, and whether `/uat` works against a product objective — needs a real project and stays open. A 4 that claimed otherwise would be laundering. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — a fixture target repository the harness vendors onto and then governs | `agnostic-portability` |
| O2 — the real gates run against that target, inside the suite, with no manual step | `real-enforcement`, `agnostic-portability` |
| O3 — a gate behaving differently on a foreign target is caught | `real-enforcement`, `measurable-impact` |
| O4 — a `Guard` the fixture declares is run by name, the harness not knowing what it checks | `real-enforcement`, `agnostic-portability` |
| O5 — the fixture's own test command is invoked, its result kept out of the harness suite | `real-enforcement` |

## Pillar provenance (stamped by `/align`)

| Pillar | `since` |
|---|---|
| `real-enforcement` | `0001` |
| `agnostic-portability` | `0001` |
| `measurable-impact` | `0002` |
| `frictionless-adoption` | `0004` |

## Pillars deliberately NOT claimed

- **`frictionless-adoption` — not claimed.** The fixture is DROP and changes no adoption step. It
  neither helps nor costs an adopter, and claiming a pillar for not affecting it is the
  goalpost-moving ADR `0004` was accused of.

## Orphans

None.

## Gate note

1. **The fixture must stay inert.** It contains a source file so a stack detector has something to
   read. The moment it implements behaviour, `scopeCompliance` drops below threshold retroactively
   and the feature is out of scope. `/uat` checks this against the shipped fixture, not the brief.

2. **`S7` was sharpened three commits ago for exactly this design.** What runs in `tests/run.sh` is
   the harness's gates over the fixture. If the fixture's own suite result ever lands in that count,
   green means two things and `S7`'s falsifier has fired.

3. **The falsification test, set before the result is known.** *Does a gate behave differently on
   the fixture than on this repository?* The pin-id defect is **already known** and already fixed,
   so it does not count. The test is whether a **second, unknown** divergence appears. If none does,
   `measurable-impact` is `⏳`, not `✅` — the same discipline 016 and 017 applied.
