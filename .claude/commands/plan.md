---
description: Produce the technical plan (plan.md) grounded in the constitution, behind the fail-closed stack-charter gate.
---

## Stack gate (fail-closed — run before writing anything)

Inputs: `specs/<feature>/acceptance.md` (frozen by `/distill`) × `memory/stack/stack.md`.

**Charter absent, or present but empty (zero pins)** → refuse identically. Tell the human to run
`/stack` first, the same way `/distill` refuses without `alignment.md`. Never invent pins.

The two states are one refusal on purpose: vendoring seeds a **stub** charter, so a fresh
adopter never has "no charter" — they have a well-formed file with zero pins. Treating that as
a pass would let the very first feature of every adopted repo through the gate unexamined,
which is the mute assumption this whole mechanism exists to stop. `scripts/stack/engine.py`
reports it as **empty** (exit 3), distinct from **malformed** (exit 2), so the message can say
"run `/stack`" instead of sending someone hunting a bug that is not there.

Otherwise emit **exactly one** of the four verdicts below. **Silence is not a verdict** — an
unspoken pass is indistinguishable from not having looked, which is the mute assumption this
gate exists to prevent. Both classifications are your judgment, not a string match: apply the
inclusion test (*changing it later costs rework*) and read each criterion against the declared
`Falsifier` semantically.

### `UNCOVERED` — evaluated first
Run `python3 scripts/stack/engine.py ground-rules memory/stack/stack.md`. If any ground rule
reports `uncovered`, stop: the charter is below the floor and every other verdict is premature.
Name the uncovered rules and hand control to the `stack` skill, which walks them and — on a
charter that predates the ground rules — proposes which existing pin answers which rule and
where an `n/a` belongs.

There is **no grace period**. A warning that does not block is a mute assumption with extra
steps, and the first feature of every adopted repository is exactly where that would do the
most damage. The migration is what makes this friction justified rather than a wall: it states
what it prevents and hands over the fix.

### `PASS`
Every ground rule has a verdict, every load-bearing decision this plan needs is pinned, and no criterion trips a `Falsifier`.
Proceed, and **cite** in `plan.md` the pins each decision rests on.

### `UNPINNED`
The plan needs a load-bearing decision with no pin. Stop, run the `stack` skill scoped to that
single decision, append the pin to the charter, then resume. This is the accretion loop — the
charter grows from real features instead of from guessing.

If the new pin is `[stance]`, its `Injects` rows belong in a `coverage.md` that `/distill`
already froze. Bounce back to **`/distill`**: reopen coverage, take the new rows, re-freeze,
then resume here. Do not defer the rows to the next feature — a feature that ships without
verifying the stance it just created is green by construction.

### `TRIPPED`
An acceptance criterion matches a pin's `Falsifier`. Stop and report **all four**:

1. which criterion invalidated which pin;
2. the reversal cost **as the pin declared it** — quote `Forecloses`, do not re-estimate;
3. **whether the `Hedge` that was paid for actually exists in the code.** If the pin was
   `PROVISIONAL` with a hedge and the hedge is in place, say the swap is cheap and why. If the
   hedge was skipped, present the honest bill. This check is the entire reason a `PROVISIONAL`
   pin costs something up front;
4. the two paths — **amend** the pin (it keeps its id, gains `SUPERSEDED` with date, reason and
   what tripped it), or **narrow** the criterion so it no longer trips.

Never continue silently past a `TRIPPED`.

---

## The plan itself

With `spec.md` frozen and the gate satisfied, write `specs/<feature>/plan.md`. Every technical
decision must respect the non-negotiables, the `[given]` patterns, and the charter's pins; any
override requires explicit justification in `memory/constitution/constitution.md`.
