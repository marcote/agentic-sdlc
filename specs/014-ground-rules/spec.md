# Spec — Ground rules: a project cannot start below the quality bar

> WHAT is built. Produced by `/distill` from `brief.md`. Frozen when `coverage.md` has no
> orphan rows.

## Functional requirements

### The six

1. **`memory/stack/base/ground-rules.md` ships exactly six ground rules**, ids `GR1`–`GR6`,
   universal and vendored:

   | id | Ground rule | The question it forces |
   |----|-------------|------------------------|
   | `GR1` | Consumption | How does anything outside reach this, and is the core separable from its transport? |
   | `GR2` | Persistence & concurrency | What holds state, and how many things write to it at once? |
   | `GR3` | Deployment & topology | Where does it run, and in how many instances? |
   | `GR4` | Language, runtime & execution | What is it written in, which version, how are dependencies declared, and how is it run? |
   | `GR5` | What "verified" means | What does the test command actually run, and what does a green run prove? |
   | `GR6` | Failure posture | When it breaks: does it retry, corrupt, alert, or fail silently? |

2. **Six is a hard cap.** A seventh may only enter by removing one. The count is asserted, not
   merely documented, so growth pressure fails loudly rather than quietly.
3. **Each ground rule names a question and no answer**, and states **what it prevents** — the
   justification the amended `frictionless-adoption` signal now measures.

### Answering

4. **A pin may declare `Answers: GRn`** (one or more ids). The field is optional on a pin — not
   every pin answers a ground rule — and an unknown id is rejected rather than ignored.
5. **A declined ground rule is declared with `Because` + `Falsifier`**, and is **not a pin**: no
   decision was taken, so there is nothing to price. Its `Falsifier` states when the decline
   stops being true, so an `n/a` written in week one cannot silently survive a project that
   changed underneath it. A declination missing either field is rejected.
6. **Coverage is reported deterministically**: `python3 scripts/stack/engine.py ground-rules
   <charter>` emits, per ground rule, `pin <id>` / `n/a` / `uncovered`. Stable across runs on
   unchanged input.

### The gate

7. **`/plan` gains a fourth verdict, `UNCOVERED`**, and refuses to proceed while any ground rule
   lacks a verdict. `PASS` / `UNPINNED` / `TRIPPED` / `UNCOVERED` — still exactly one, still
   never silence.
8. **`/stack` walks all six explicitly** during Grill, so the default path produces a covered
   charter rather than one that trips the gate later.
9. **A pre-existing charter below coverage gets a guided migration, not a wall.** `/stack`
   detects it, proposes which existing pin answers which ground rule, and asks where an `n/a`
   belongs. The gate does **not** soften: `UNCOVERED` applies from the first run, with no grace
   period. A warning that does not block is a mute assumption with extra steps.

### The floor

10. **Ground rules do not scale with `S0`.** `S0` scales how deep each answer goes and how many
    pins exist beyond the floor — never whether a ground rule is answered. This is the second
    floor alongside `P6`.
11. **A project may add ground rules, never remove one.** Same inheritance idiom as
    `constitution.md` extending `base`. The engine rejects an effective set missing any base
    ground rule. The escape hatch is `n/a` with a reason, which is auditable; removal would not
    be.

### Reflexive dogfood (D3)

12. **The harness's own charter resolves all six**, with `Answers:` retrofitted onto its five
    existing pins and `n/a` used honestly where a ground rule genuinely does not apply.

## User stories

- As a **maintainer starting a project**, I want the harness to refuse to plan while an aspect
  of the work has no recorded rationale, so the quality floor does not depend on my remembering
  to ask.
- As a **maintainer of a small, disposable project**, I want declining a ground rule to cost one
  line, so the floor does not turn a throwaway script into a ceremony.
- As a **maintainer six months in**, I want a decline I made in week one to expire when it stops
  being true, rather than silently outliving the conditions that justified it.
- As an **adopter on any stack**, I want the floor to name questions I can answer in my own
  terms, never a toolchain I did not choose.

## Edge cases (80% problem)

- **A pin answering several ground rules.** A single choice can settle consumption *and*
  deployment. `Answers:` accepts a list; coverage counts a ground rule as answered if any pin
  claims it.
- **A ground rule answered by a `SUPERSEDED` pin.** The pin is history, so it must **not** count
  as coverage — otherwise amending a pin silently drops the project below the bar.
- **An `n/a` that is an evasion.** *"No persistence"* on something that writes files is a
  decline that is simply false. Not mechanically detectable; covered by an eval case, not a
  deterministic check.
- **A pin that claims a ground rule it does not answer.** `Answers: GR6` on a pin about a
  logging library looks like coverage and is not. Also an eval case — the engine can only
  verify that the id exists, not that the claim is honest.
- **The harness's own charter blocks itself the moment this lands.** Intended, and the first
  real `UNCOVERED`. It is discharged inside this feature (FR-12), not deferred.
- **An unknown id in `Answers:`** (typo, or a ground rule removed by a later amendment) must be
  rejected loudly. Silently ignoring it would report `uncovered` for the real rule while the
  author believes it is answered — the accepted-then-never-run failure mode `SUBSTRATE-GUARD`
  taught in 013.
- **A project layer that omits a base ground rule.** Rejected: the floor is additive only.

## Open questions / deferred

- **Cross-project seeding of a charter** (copying pins between repositories) — a convenience,
  separable, not now.
- **`hermetic-offline`** — `[given]` from `base/hermetic-tests`, `deferred`: 014 reaches no
  network or remote source, so there is no external dependency to place behind an override seam.
- **Whether ADR `0004` was sound or self-serving.** This feature is the first scored under the
  amended `frictionless-adoption` signal. The falsification test is recorded in `alignment.md`
  and belongs to `/retro`: did any friction get *rejected* for lacking justification, or does
  everything now qualify by construction?
