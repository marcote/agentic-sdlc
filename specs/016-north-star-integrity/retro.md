# Retro — 016-north-star-integrity @ 469b15e

closes: `specs/016-north-star-integrity/alignment.md` · `verification/reports/016-north-star-integrity-469b15e.md` · date: 2026-08-09

> Closes the measurable prediction that `/align` opened.

## Face A — Mission (closes the /align prediction)

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| `real-enforcement` | Gates block closure when a condition is missing | ✅ moved | A freshly vendored North Star now exits **3** instead of **0** (`NS-VENDORED-STUB-REJECTED`, run against a real vendored target). The amendment gate blocks a governed change with stale provenance (`AMEND-PROV-STALE`). `check_90` blocked this close for a missing retro |
| `agnostic-portability` | The contract stays intact when vendored onto an arbitrary repo/stack | ✅ moved | `NS-TODO-NOT-FALSE-POSITIVE`: a fully written North Star for a to-do-list product validates, and is refused the moment the discriminator becomes the bare word `TODO` (fixture F2). The check works on an arbitrary product domain, which is what this pillar means |
| `frictionless-adoption` | Steps to adopt, with every mandatory step carrying a recorded justification | ✅ moved | The from-zero path had a silent hole: seed skipped → `/align` scores a placeholder → green verdict that means nothing. It now stops with a message naming the seeded fields. **Migration cost measured at exactly what the brief claimed: one field per pillar**, 10 fixtures, no caller changed |
| `measurable-impact` | Gaps caught early, late rework avoided | ⏳ not yet observable | 12 gaps caught pre-implementation, 0 rework post-`/verify`. But **half B has produced no measurement yet and cannot before 2026-09-08** — see below |

**The falsification test, set at `/align` before the result was known** (gate note 3):

> *Does the provenance stamp ever change a verdict, or is it decoration that reads well?*

**Unanswerable today, by construction.** The stamp pays only when a `pending-observation` is swept
against a signal that moved, and the first sweep is **2026-09-08** — after this feature closed. The
gate note said in advance that `measurable-impact` therefore **cannot** be `✅` on the strength of
half B, and it is not. Half A moved three other pillars on its own evidence.

- **Align calibration:** `4/5/4` held. `scopeCompliance: 5` was the first 5 any brief has taken
  and it survived `/uat`: nothing was named, nothing was prescribed, both halves removed ambiguity
  from an existing contract. `missionAdvancement: 4` was correct to hold below 5 for exactly the
  reason given — half B's payoff is deferred, and it stayed deferred.
- **Mission verdict:** pending-observation
  - **re-check trigger:** the **2026-09-08 sweep**. If a `pending-observation` is closed against a
    pillar whose `since` differs from the one stamped in its `alignment.md`, and the retro says so,
    half B is confirmed. If the sweep passes and no retro consults a stamp, it is decoration and
    should be said plainly. Same date as 013's and 014's sweep, deliberately: one sweep, three
    verdicts.
  - **Sweep by: 2026-09-08.**

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted

- **Gaps caught by /distill:** 12 [deriv$ echo $(( $(grep -cE '^### G-' specs/016-north-star-integrity/spec.md) + $(awk '/^## Edge cases/,/^## Non-goals/' specs/016-north-star-integrity/spec.md | grep -cE '^[0-9]+\.') )) $] — the decisive one is G-a: byte identity rather than the word `TODO`, which is the difference between fixing the defect and shipping something worse than it.
- **RED→GREEN discipline:** yes `[deriv: coverage.md state history + 469b15e; 410/0 → 414/12 at /contract → 426/0 → 427/0]` — three assertions passed at RED and were documented in `coverage.md` at contract time: two *must-not-reject* criteria and one self-test.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/016-north-star-integrity-469b15e.md §5 — one gap routed to /distill, none to implementation]`.
- **Escalations to the human:** 1 `[deriv: one AskUserQuestion on feature scope — B3 alone vs B3 + provenance]` — the only genuine fork; the three grilling ambiguities each had a zero-risk answer and were resolved without asking, which is what the measurement was for.
- **Friction from the WoW itself:**
  **(1) Two of this feature's own assertions were vacuous, and `nvc.sh` caught neither.** `ALIGN-STAMPS-PROVENANCE` grepped for the word `since`. That is an ordinary English word, and it appeared in a scoring rationale, so the assertion passed against an `alignment.md` with no stamp at all. `AMEND-PROV-ONLY` cannot reach the code it claimed to test: a provenance-only edit leaves the governed sets unchanged, so the gate short-circuits at `sets-changed`. Proved by mutation, which left it green while breaking three unrelated criteria. **Second consecutive feature where the mechanical half missed the vacuity and reading caught it.** Both are semantic vacuity, which `base/patterns/non-vacuous-checks.md` places out of mechanical scope. The pattern is *accurate*. What that accuracy costs is now measured: two occurrences in two features.
  **(2) `status.sh` reported `feature DONE` while `check_90` was blocking the close.** The tracker trusts the report's `retro: ✅` line; the gate reads the retro file. I wrote the line before the file. Two trackers, two answers, and the wrong one is the reassuring one.

## Face C — Loop (self-improvement)

- **Candidate rules → constitution:** none. The obvious candidate is *"an assertion must not match an ordinary word"*. That is **semantic vacuity by definition**. The pattern already declares it out of mechanical scope, and two features have now confirmed it cannot be automated cheaply. Writing it as prose would be the third proposal of a rule this repository has measured as prose-resistant. It goes to `docs/backlog.md` instead, with the two occurrences as its evidence.
- **Candidate deltas → project:** one, small: **a report's `retro: ✅` must not be written before the retro file exists.** Deferred to backlog rather than written as a delta, for the same reason.
- **Candidate amendments → North Star:** none. `S2`'s hedge was **paid, not strained**: the new capability is a shell subcommand with its exit contract in the docstring (`NS-ENGINE-CLI-ONLY`), which is what `PROVISIONAL` was supposed to buy. **015 predicted this exact obligation and it arrived mechanically** — the accretion loop working across features without anyone remembering.

---

## Deferral hygiene

**Sweep by: 2026-09-08**, the same date as 013 and 014. Three verdicts, one sweep.
