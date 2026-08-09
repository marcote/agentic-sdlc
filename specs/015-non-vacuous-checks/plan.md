# Technical plan — The meta-check: an assertion must be able to fail, and be seen doing it

> HOW it is built. Grounded in the constitution. Produced by `/plan` over the frozen `spec.md`.

## Stack gate — verdict: `PASS`

`UNCOVERED` evaluated first, as the command requires:

```
python3 scripts/stack/engine.py ground-rules memory/stack/stack.md
GR1: pin S5 · GR2: pin S6 · GR3: pin S5 · GR4: pin S2 · GR5: pin S7 · GR6: pin S8   → exit 0
pin-valid → exit 0 · exposure → 9 pins · 8 PINNED · 1 PROVISIONAL
```

Charter above the floor. No criterion trips a `Falsifier`. Every load-bearing decision this plan
needs is pinned. **`PASS`**, with two strains recorded below — a strain is not a trip, and saying
so is the point of recording it.

### Pins this plan rests on

| Decision | Pin |
|---|---|
| Meta-check written in bash + coreutils, no new dependency | `S3` |
| Shipped as a file in `tests/`, executed in place, never installed | `S5` |
| Refuses rather than partially reporting on an unusable run (R6) | `S8` |
| Asserts about the harness's own checks, never about product code | `S7` |
| No persistent state; the captured run output is ephemeral | `S6` |

### Strain 1 — `S3` is being tested, by attempt rather than by prediction

`S3`'s `Falsifier` reads: *"a gate that cannot be expressed within this baseline without becoming
unmaintainable, **established by attempting it rather than by predicting it**."*

This plan is that attempt. Heredoc-aware declaration parsing, run capture and label
cross-referencing in awk/grep is the most ambitious thing the baseline has been asked to do. The
pin's own wording forbids me from calling it either way in advance.

**The threshold, set now so it is not negotiated afterwards:** if the parser needs a second
bespoke state machine beyond heredoc tracking, or if a criterion cannot be expressed without one,
`S3`'s falsifier has arrived. At that point the `S2-HEDGE` row in `coverage.md` stops being
`deferred` and the CLI contract applies — recorded there already, for exactly this.

### Strain 2 — `S1`, first strain since 014 sharpened it

`S1`'s `Falsifier` includes *"any artifact under `base/` stating an answer rather than a
question"*. `memory/constitution/base/patterns/non-vacuous-checks.md` landed yesterday and does
prescribe practice — *assemble the literal at runtime*, *require the named diagnostic* — under a
`base/`, inherited by every adopter.

**Not a trip, and the distinction is 014's own.** `S1` was sharpened to read: *a required question
is mechanism; a prescribed answer is an opinion.* "Can this assertion fail?" is a question about
the adopter's own work that names no tool, language, runtime or vendor. `no-prescribe.sh` scans
`memory/stack/base/` and stays green.

Recorded because this is the **first** `/plan` to read the charter since that pattern landed, and
because the strain belongs to yesterday's PR, not to this feature. If a future pattern under
`base/` names a tool, that is the falsifier and this note is where the trail starts.

### What I considered calling `UNPINNED`, and did not

**The suite must be re-entrant — runnable from inside itself.** R5 spawns the whole suite from
within a check. Every check from now on must tolerate a nested run, and a future check that breaks
that would make the meta-check emit a *traceability* diagnostic for a *re-entrancy* fault — a
confidently wrong verdict, the shape this feature exists to stop.

It is real, and I nearly pinned it. **It fails the inclusion test.** Abandoning re-entrancy costs
rewriting one file; a future check breaking it costs fixing that check. Compare the actual pins:
changing `S5` (delivery) or `S6` (state) costs the whole harness. A constraint local to `tests/`
is a plan decision, not a pin, and inflating it into one to make the charter look active would be
the self-deception this session has spent its time removing.

**Consequence: 013's `pending-observation` does not close here either.** Its trigger needs a real
`UNPINNED`/`TRIPPED` against a pre-existing pin. Two strains and a considered-and-rejected pin are
not that. Stays open, sweep date 2026-09-08 unchanged.

## `D4` — gate bootstrap, declared before implementation

This feature ships a check that reads **every** `tests/check_*.sh`, including its own file. Per
project delta `D4` the exemption is **from being blocked, never from being run**, on four
conditions, all four discharged here:

1. **Declared in `plan.md` before implementation** — this section.
2. **Runs retroactively against its own artifacts with a real verdict.** The meta-check must judge
   `check_96` itself and emit a genuine result. R5's partial guard is what makes this possible: in
   the inner run only the *spawn* step is skipped, so `check_96`'s own labels emit and are checked.
   A trivial pass because the check never examines itself proves nothing and does not discharge
   this condition.
3. **Task ordering brings the feature into compliance before the final verify** — T5 before T6.
4. **Every subsequent check is subject, without exception.**

## Decisions

- **D1 — Detection at runtime (`declared → emitted`), not static branch pairing.** Constrained by
  `NVC-DECLARED-EMITTED`, `NVC-ZERO-FP`. Measured before choosing: naive static pairing over the
  standing suite produced one true positive and one false positive. Trade-off: the suite runs
  twice, roughly doubling wall-clock. Accepted because `tests/` is DROP, so no adopter pays it,
  and because a false-positive rate is the failure mode that gets a check disabled.

- **D2 — One file, `tests/check_96_non_vacuous.sh`, picked up by the existing glob.** Constrained
  by `S3`, `S5`. No new command, no runner change. `96` sorts last, after `95`.

- **D3 — `lib.sh` gains `_skip()`.** Constrained by `NVC-SKIP-EXPLICIT`. Silence is never a valid
  outcome, the same doctrine as `/plan`'s "exactly one verdict, never silence". Trade-off: touches
  the shared helper every check sources; mitigated by it being additive — no existing call
  changes.

- **D4-impl — The self-scan trigger is the *target set*, not the presence of a scan.** Constrained
  by `NVC-SELFSCAN-ASSEMBLED`. A scan whose target glob can contain the scanning file must use a
  runtime-assembled pattern; a closed, explicitly named target set that excludes the scanner is not
  flagged. Measured: `check_92`/`check_94` trigger and already comply; `check_86` does not trigger.
  Zero false positives on the standing suite.

- **D5 — Fail closed on an unusable inner run, naming what was executed.** Constrained by
  `NVC-RED-SUITE`, pin `S8`, `[given] check-names-its-tree`. A missing label and an aborted check
  are indistinguishable from the outside; reporting one as the other is the confident-false-verdict
  shape that hit twice on 2026-08-09.

- **D6 — Scope is the labelled criteria only.** Constrained by `NVC-SCOPE-STATED`. The 127 bare
  `assert_*` calls stay out. The limitation is stated in the shipped file, not only here — a check
  implying full coverage would repeat this feature's failure mode one level up.

- **D7 — Negative fixtures get one sandbox each.** Constrained by `NVC-CAN-FAIL`. Recorded because
  the failure is on the record twice in two days: a fixture harness that ran a check standalone
  emitted neither PASS nor FAIL, and a second leaked state because `git checkout` cannot restore an
  untracked file.

## Components

> **Deviation, recorded at `/contract` before any code.** This table originally put the scanner
> *inside* `tests/check_96_non_vacuous.sh`. That is not contractable: a check file cannot go 🔴 RED
> against itself, so every criterion would have been green-by-construction — the exact failure
> `base/principles.md` names. The scanner moves to `scripts/nvc.sh` and the check exercises it,
> which is also the shape every other feature here already uses (`status.sh` × `check_86`,
> `engine.py` × `check_82`). The brief's "no new command" holds: nothing new for a human to run.

| Unit | Responsibility | Interface |
|---|---|---|
| `scripts/nvc.sh` | **deliverable.** declaration parse · emission cross-reference · duplicate labels · self-scan rule | shell CLI, subcommands, exit 0 clean / 1 violations / 2 unusable |
| `tests/check_96_non_vacuous.sh` | exercises `nvc.sh` against negative fixtures and against the standing suite | sourced by `run.sh`; emits `_pass`/`_fail`/`_skip` |
| `tests/lib.sh` `_skip()` | third outcome so silence is never valid | `_skip "LABEL: reason"` |
| guard variable | suppresses only the spawn step in the inner run | env var read by `check_96` |
| `tests/check_82_north_star_engine.sh` | `DEP-FREE` gains its label (R8) | `assert_dep_free "$ENG" "DEP-FREE"` |

## Risks

| Risk | Mitigation |
|---|---|
| The parser becomes unmaintainable in bash | `S3`'s falsifier, with the threshold set above; `S2-HEDGE` revives |
| The meta-check is itself vacuous | `NVC-CAN-FAIL`: a negative fixture per rule, one sandbox each, each failing only its own rule |
| Nested run doubles wall-clock | `tests/` is DROP; no adopter pays it. Measured at `/verify`, reported not hidden |
| A future check breaks re-entrancy | Not pinned (see above); stated in the shipped file's header as a constraint on check authors |
| Circular satisfaction of the five `[given]` rows | `coverage.md` records that `/uat` must judge them against fixture behaviour, not the table |
