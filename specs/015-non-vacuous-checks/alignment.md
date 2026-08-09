# Alignment — 015-non-vacuous-checks

Measurability Gate (`/align`) over `brief.md` × `memory/north-star/north-star.md`
**as amended by ADR `0004`**. **Run deterministically by the 006 engine**
(`scripts/north-star/engine.py`): `schema-valid` → exit 0; `scope-reject` per objective →
exit 1 for all five (no `out_of_scope` hit); `align-verdict` → `aligned`.

## Verdict

**`aligned`** — all 3 dimensions ≥ threshold (3), no `out_of_scope` hit, no orphan.
`/distill` may proceed.

## Scores (minimum across objectives)

| Dimension | Score | Note |
|---|---|---|
| pillar fit | 4 | O1–O4 land squarely on `real-enforcement`, whose signal reads *"gates block closure when a condition is missing… and the harness proves it by dogfooding itself"* — a check that fails the suite when an assertion cannot report is that sentence implemented, and running it against the harness's own suite is the second clause. O2 and O5 also carry `measurable-impact`: an assertion that emits no result is a gap the harness did not catch, and `DEPFREE` is a recorded instance. Held at 4, not 5, by the **second half of O5** — *"state which shapes are enforced mechanically and which remain with review"* is a documentation property. It advances `real-enforcement` only in the sense of not over-claiming, which is a real virtue but an indirect mapping. In genuine doubt between 4 and 5; the rubric says prefer the lower. |
| scope compliance | 4 | `scope-reject` returned exit 1 on all five objectives. The predicate that could bite is *"stack-specific deterministic engine (provided by the adopter)"* — and the deliverable **is** stack-specific: bash reading `tests/check_*.sh`, the harness's own convention. It does not hit the predicate because it lands in `tests/`, which is **DROP** on vendoring, exactly where the harness's own self-validation already lives. Held at 4 rather than 5 because the artifact encodes harness-specific test conventions (`_pass`/`_fail`, criterion labels): benign in `tests/`, imposition the moment any of it migrates to `base/`. That is a watch item for `/uat`, not a violation today. |
| mission advancement | **3** | The honest penalty, and it is structural rather than incidental. **This feature's deliverable does not travel.** `tests/` is DROP, so an adopter inherits nothing from it — only the constitution pattern, which landed on 2026-08-09 and is not this feature's contribution. What advances is the harness's own self-validation, which the `real-enforcement` signal does explicitly count ("proves it by dogfooding itself"), but whose reach is bounded by construction. O1–O4 alone would score 4: existence, catching, and fixture-failure are all directly observable. Held to 3 by **O5's scope-split statement**, whose effect is *preventive* — it stops a future over-claim that has not happened. That is plausible-but-hard-to-measure, the rubric's 3, and the same shape 014's O4 was scored 3 for. |

## Objective→pillar mapping

| Objective (brief) | Pillars |
|---|---|
| O1 — Build the mechanical half of the non-vacuous-checks gate: a check that reads the suite's own check files and fails when an assertion is structurally incapable of reporting | `real-enforcement` |
| O2 — Mechanically enforce traceability: every criterion label declared in a check file emits a result in the run, with zero false positives against the current green suite | `real-enforcement`, `measurable-impact` |
| O3 — Mechanically constrain self-scanning checks: a check that greps its own source must assemble the forbidden literal at runtime | `real-enforcement` |
| O4 — The meta-check is itself proved non-vacuous: it fails on a negative fixture for each rule it enforces | `real-enforcement` |
| O5 — Run the meta-check against the suite as it stands, fix the instances it flags, and state which shapes are enforced mechanically and which remain with review | `real-enforcement`, `measurable-impact` |

## Orphans

None. Every objective maps to ≥1 pillar.

## Pillars deliberately NOT claimed

Naming these is part of the gate, because an unclaimed pillar is a claim about the feature's reach.

- **`agnostic-portability` — not claimed.** The meta-check lives in `tests/` (DROP). It never
  reaches an adopter, so it cannot make the contract more or less portable. 013 and 014 both
  claimed this pillar because their artifacts were KEEP; this one is not, and claiming it anyway
  would be the laundering `/retro` is supposed to catch.
- **`frictionless-adoption` — not claimed.** Adds zero adoption steps because it does not ship to
  adopters. Under the amended signal (ADR `0004`) that is neither a gain nor a cost. Claiming a
  pillar for *not affecting it* would be exactly the goalpost-moving the ADR was accused of.

## Gate note

`scope-reject` cleared all five objectives (exit 1) and `align-verdict` returned `aligned`
deterministically from `{pillarFit: 4, scopeCompliance: 4, missionAdvancement: 3}`. Falsification
run: dropping any single dimension to 2 returns `needs-amendment`, so the verdict is not an
artifact of a permissive aggregator.

Three things this gate flags for the feature to carry forward:

1. **`missionAdvancement: 3` is the reach ceiling, not a fixable defect.** Do not attempt to raise
   it by making the meta-check vendorable. The brief puts that out of scope deliberately, and the
   standing doctrine is *contract in the template, engine per-stack*. If `/retro` finds this
   feature advanced the mission more than 3 predicted, the interesting question is what carried
   it — most likely the defects it flagged in already-closed features.

2. **The falsification test, set before the result is known.** *Does the meta-check flag at least
   one real instance in the standing, green suite that was not already known?* `DEPFREE` in 008 is
   **already known** and already fixed, so it does not count — a scan that rediscovers only the
   defect that motivated it has proved a fixture, not a capability. If the answer at `/uat` is no,
   `measurable-impact` is `⏳`, not `✅`, no matter how green the build is.

3. **Zero false positives is a scored commitment.** The naive version of this scan reported 112.
   A meta-check that cries wolf on a known-good suite will be disabled within a week, and a
   disabled check is worse than an absent one because the coverage row still reads green.

4. **`D4` (gate bootstrap) applies and is not optional.** This feature ships a check that reads
   every `tests/check_*.sh` including its own. Per `D4` the exemption is from being *blocked*,
   never from being *run*: `plan.md` must declare it, task ordering must bring the feature into
   compliance with its own rules before the final verify, and the finished meta-check must emit a
   **real verdict** against its own file. A trivial pass proves nothing and does not discharge it.
