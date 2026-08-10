# Retro — 017-executable-derivations @ 96a823c

closes: `specs/017-executable-derivations/alignment.md` · `verification/reports/017-executable-derivations-96a823c.md` · date: 2026-08-09

## Face A — Mission

| Pillar | Predicted signal | Verdict | Evidence (locator MANDATORY) |
|---|---|---|---|
| `real-enforcement` | Gates block closure when a condition is missing | ✅ moved | A number disagreeing with its command fails the suite (`DERIV-MISMATCH`). M4 proves it on a real derivation: pointing 014's command at a missing file makes it print 3 against a claimed 10, and the suite goes red |
| `agnostic-portability` | The contract survives vendoring onto an arbitrary stack | ✅ moved | The form is a template field and a shell command the author writes. No engine ships, nothing is named. `specs/_template/retro.md` travels as KEEP |
| `frictionless-adoption` | Steps to adopt, each with a recorded justification | ✅ moved | One line per numeric field. Prose derivations are untouched, so a claim that is not a count costs nothing new. The template states what the cost buys |
| `measurable-impact` | Gaps caught early, late rework avoided | ⏳ not yet observable | See the falsification test |

**The falsification test, set at `/align` before the result was known:**

> *Does the check find a number that no human noticed? 013 does not count — it motivated the
> feature.*

**Answer: no.** Across 014, 015 and 016 every derivation agrees. The mechanism is built and has
produced exactly one finding, the one that prompted it. Claiming `measurable-impact` on that would
be counting the motivating case twice.

- **Align calibration:** `5/5/4` mostly held. `pillarFit: 5` was right. `missionAdvancement: 4`
  was **generous**: it predicted a real but bounded gain, and the bound turned out tighter than the
  brief assumed. Three of nine retros could be migrated, not nine. A 4 that rests on a scope the
  artifacts cannot support is a 3.
- **Mission verdict:** pending-observation
  - **re-check trigger:** the first derivation that goes red on its own, without being mutated —
    either a spec edited after close, or a number written wrong in a future retro.
  - **Sweep by: 2026-09-08**, with 013, 014 and 016.

## Face B — Method — DERIVED from artifacts

- **Gaps caught by /distill:** 11 [deriv$ echo $(( $(grep -cE '^### G-' specs/017-executable-derivations/spec.md) + $(awk '/^## Edge cases/,/^## Non-goals/' specs/017-executable-derivations/spec.md | grep -cE '^[0-9]+\.') )) $]
- **RED→GREEN discipline:** yes `[deriv: coverage.md state history; suite 436/0 → 439/9 at /contract → 450/0]` — the RED phase earned its keep here, see friction (1).
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: report §5, one gap routed to /distill, none to implementation]`
- **Escalations to the human:** 0 `[deriv: trace — the three grilling decisions were resolved by measuring the nine retros]`
- **Friction from the WoW itself:**
  **(1) Three metacharacter bugs in one block, all caught at `/contract`.** A `case` pattern read
  `[deriv$` as a character class. `grep` read a trailing `$` as end-of-line. `printf` read a
  leading dash as an option, so every fixture file was empty. Each made assertions fail for the
  **wrong reason**, which still reads as red. That is the argument for a real RED phase: at
  `/verify` they would have looked like a working check.
  **(2) The constraint the spec imposed was broken by its own first use.** `G-c` forbade `]`
  inside a command. The first real derivation was `grep -cE '^[0-9]+\.'`, which contains one. The
  terminator became `$]`. The rule was written from nine existing derivations, all bracket-clean,
  and none of them were the kind this feature would create.
  **(3) The migration scope was wrong and had to be narrowed.** R5 said every closed retro; three
  could be. Knowable at `/distill` by looking at the older specs, and I did not look.

## Face C — Loop

- **Candidate rules → constitution:** none. The lesson of friction (2) — *a constraint derived from
  existing data may not survive the data you are about to create* — is real and has one occurrence.
  One is an anecdote. It goes nowhere until it recurs.
- **Candidate deltas → project:** none.
- **Candidate amendments → North Star:** none. `S2` untouched: no engine was added, so its `Hedge`
  stayed deferred, as `/plan` predicted.

---

## Deferral hygiene

**Sweep by: 2026-09-08**, with 013, 014 and 016. Four verdicts, one sweep.
