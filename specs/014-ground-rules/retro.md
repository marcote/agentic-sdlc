# Retro — 014-ground-rules @ 893905c

closes: `specs/014-ground-rules/alignment.md` · `verification/reports/014-ground-rules-4444882.md` · date: 2026-08-09

> Closes the measurable prediction that `/align` opened (align↔retro column). A feature is not
> DONE until this retro closes its three faces.

## Face A — Mission (closes the /align prediction)
Source: `specs/014-ground-rules/alignment.md` (objective→pillar mapping) + `north-star.md` (signal per pillar, **as amended by ADR `0004`**).

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| `real-enforcement` | Gates block closure when a condition is missing; violations caught before merge; the harness proves it by dogfooding itself | ✅ moved | Three firings on real artifacts, not fixtures: `UNCOVERED` blocked a one-pin charter on a **vendored target** (`coverage.md` UAT table: `pin-valid` VALID → `ground-rules` GR1–GR6 uncovered, exit 1); the same gate blocked **this repository's own charter**, forcing pins `S5`–`S8` (`memory/stack/stack.md`, `4444882`); `check_90` blocked this very close for a missing retro (`tests/run.sh` 365/1) |
| `agnostic-portability` | The contract remains intact when vendored onto an arbitrary repo/stack | ✅ moved | `base/ground-rules.md` travels as KEEP; `no-prescribe.sh` green on the shipped artifact; the engine degrades to exit 1 rather than crashing when the project layer is absent (`coverage.md` UAT table). Same weakness as 013: the target was synthetic, weaker than `2602a36`'s real repo |
| `frictionless-adoption` | Steps/time to adopt, **with every mandatory step carrying a recorded justification proportional to what it prevents; the defect is an unjustified step** | ⏳ not yet observable | **6 of 6 ground rules carry `Prevents`** (`memory/stack/base/ground-rules.md`) — but they carry it because I wrote them knowing the requirement. **Nothing was rejected for lacking justification.** See the falsification test below |
| `measurable-impact` | Gaps caught early and late rework avoided, aggregated per feature | ⏳ not yet observable | 10 gaps caught pre-implementation, 0 rework post-`/verify` and post-`/uat` (`coverage.md`; report §5). But the ground rules have prevented **zero** real rework: nothing has been blocked by `UNCOVERED` except this repository's own charter, which is the feature's own deliverable |

**The falsification test, set before the result was known** (`alignment.md` gate note, `cbfc3f8`):

> *Did any real friction get **rejected** for lacking justification, or does everything now
> qualify by construction?*

**Answer: nothing was rejected. It qualified by construction.** Every ground rule has a
`Prevents` because the requirement was known while writing them; no candidate friction was ever
proposed and turned down. The amended signal's discriminating half — the half that makes it a
*measurement* rather than a formality — **was never exercised.**

So **ADR `0004` is unproven, not vindicated.** The amendment's own self-check worried it might
be goalpost-moving; this feature does not settle that, and claiming `✅ moved` here would be
precisely the laundering the ADR argued it was not doing. The reductio that justified the
amendment (a signal maximised by shipping nothing) still stands on its own; what remains untested
is whether the replacement can ever say *no*.

- **Align calibration:** **`4/3/3` held, and this is the first time the rubric's own doubt rule
  was applied rather than noted.** `scopeCompliance: 3` was **vindicated by `/uat`**: `GR1` does
  lean — it asks whether the core is separable from its transport and its `Prevents` argues the
  cost asymmetry — and the maintainer had to rule on it. Scoring 4 would have hidden a real
  edge. 013's retro recorded that I ignored *"when in doubt prefer the lower"*; applying it here
  is that lesson landing. `missionAdvancement: 3` also held: two of four pillars came back
  pending, which is what a 3 predicts. `pillarFit: 4` was, if anything, mildly generous.
- **Mission verdict:** pending-observation
  - **re-check trigger:** two distinct events, and the feature is not vindicated until both
    occur. **(a)** A proposed mandatory step is **rejected** — or forced to state a
    justification it lacked — under the amended `frictionless-adoption` signal. That is when
    ADR `0004` becomes a measurement instead of a formality. **(b)** A feature other than this
    one is stopped by `UNCOVERED` against ground rules that predate it, and the stop prevents
    rework that would otherwise have happened. That is when `measurable-impact` moves. The same
    trigger closes the two `📋` eval rows (`JUDGE-GR-ANSWERED`, `JUDGE-NA-HONEST`), left open
    because scoring them here would be the authoring model grading its own output.

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted

- **Gaps caught by /distill:** 10 `[deriv: 3 grilling ambiguities in 7181d2c + 7 bullets under the "Edge cases" section of specs/014-ground-rules/spec.md, section-scoped]` — the notable ones are structural, not cosmetic. A `SUPERSEDED` pin must not count as coverage: otherwise amending a pin silently drops a project below the floor. And an unknown id in `Answers:` must be rejected loudly, because silently ignoring it reports the real rule uncovered while the author believes it answered. *The derivation is section-scoped deliberately: 013's retro inflated the same field by grepping bullets across the whole file, and the `[deriv:]` locator made the wrong number look verified.*
- **RED→GREEN discipline:** yes `[deriv: coverage.md state history + c6afbeb → 4444882; suite 327/0 → 337/23 at /contract → 345/21 → 358/8 → 361/5 → 365/0]` — ten assertions passed at RED by design (fixture-detectability meta-assertions, preconditions 013 left green, non-vacuity self-tests), all documented in `coverage.md`. Every assertion touching a 014 artifact was red.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/014-ground-rules-4444882.md §5 "Gaps routed: none to implementation" + coverage.md UAT section "No product gap found"]` — better than 013, which had one. Plausibly because 013's UAT taught where to look: this UAT went straight to a vendored target rather than testing the harness against itself.
- **Escalations to the human:** 4 `[deriv: trace — GR↔pin link, n/a form, pre-existing charters, and GR1's neutrality at /uat]` — all genuine decision forks; the inner-loop budget was never reached. The fourth is the important one: it was escalated **because I was judging my own text**, not because I was stuck.
- **Friction from the WoW itself:** Two, and the first is now the dominant finding of both features.
  **(1) Nothing prevents a check from being vacuous, and prose does not help.** Five more defects here. Three false passes where `argparse` exits 2 for an unknown subcommand, so "must be rejected" assertions passed because the capability *did not exist*. A fence-blind counter that read a documented example as a seventh rule. And a pattern that could not tell assertion from denial, so it flagged `plan.md`'s own *"there is no grace period"*. **Occurrences 6–10, and `plan.md` D10 warned about this class by name, two hours before I stepped in it.** That is the whole argument: a written warning did not prevent it.
  **(2) A check run against the wrong tree reports a false verdict, and it happened twice.** The amendment gate reported *"not applicable"* over an empty commit range with the change staged but uncommitted; the hermeticity check reported a false `337/23` against a clone of uncommitted work. Neither is a tool defect — both are the same operator error, and both were caught by luck rather than by anything structural.

## Face C — Loop (self-improvement)

- **Candidate rules → constitution:** two, both now overdue (per `memory/constitution/update-checklist.md`):
  1. **`base/patterns/non-vacuous-checks.md`** — carried from 013 and **strengthened by the evidence rather than merely repeated**. Ten occurrences across two features plus `e6bc658`, and the decisive new datapoint: **013's retro proposed this rule, 014's plan restated it as D10, and occurrences 6–10 happened anyway.** Prose in a plan does not prevent it; only a mechanical check will. Injected criteria: every check ships a negative fixture on which it exits non-zero; a check that scans its own source assembles the forbidden literal at runtime; a newly declared check is confirmed present in what the runner actually executes; **a rejection assertion requires the diagnostic, not only the exit code** (new, from occurrences 6–8); and **a check that reports on a tree must state which tree** (new, from the two operator errors above).
  2. **A project delta for the gate-bootstrap exception** — carried unchanged from 013 and reinforced: 014 introduced `UNCOVERED` and its own charter was subject to it, handled ad hoc by task ordering (T6 before T7). Third occurrence of a situation still negotiated case by case.
**Landed 2026-08-09** — both candidates are now in the constitution: `memory/constitution/base/patterns/non-vacuous-checks.md` (five injected `[given]` criteria, each with the occurrences it prevents) and project delta **`D4`** (gate bootstrap, four conditions). Asserted by `tests/check_10_constitution.sh` and proved failable against four isolated fixtures. They landed only after `verification/wow-report.md` §4 counted *proposed twice, landed zero*.

- **Candidate amendments → North Star:** none. ADR `0004` is three days old and **unproven** rather than wrong; amending it again before its discriminating half has ever fired would be thrashing. `S2` was strained a second time (`plan.md` gate note) with the threshold recorded: **a third strain is the falsifier arriving, not another near-miss.**

---

## Deferral hygiene (added 2026-08-09)

**Sweep by: 2026-09-08** — a date, not only an event, whichever comes first. On that date the
verdict is either closed with evidence or re-deferred with a *new* date and a stated reason.

Added because feature 006 sat `pending-observation` for **35 days after its evidence already
existed**: its trigger fired when 007 merged on 2026-07-05 and nobody swept the ledger.
`wow-report` §2 exists to list overdue re-checks and had never been run across eight features.
A deferral mechanism nobody sweeps loses findings while the ledger still reads as rigorous —
which is a worse failure than an open item, because it is invisible.
