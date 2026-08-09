# 0004 — `frictionless-adoption` measures unjustified friction, not friction

## Context

The `frictionless-adoption` signal has been, since the seed (`0001`):

> "Steps/time to adopt the harness in a project (lower = better)."

Read literally — and a signal exists to be read literally — it is **optimised by shipping
nothing.** A harness with no commands, no gates and no memory stores imposes zero adoption
steps and scores perfectly. A signal whose maximum is reached by doing nothing is not measuring
the thing it was written to protect.

It also puts the pillar in direct conflict with the mission that contains it:

> "…a harness that **enforces** a disciplined agentic SDLC (spec-driven, test-first,
> evidence-verified) on any project…"

Discipline is friction. Every governance capability the harness ships — the intake gate, the
RED contract, the retro, the stack charter — necessarily raises adoption cost. Under the
current wording each of them is structurally penalised by one of the harness's own pillars,
regardless of what it prevents.

This is not hypothetical. Feature 013 recorded `frictionless-adoption` as **"❌ did not move —
moved the wrong way"** for adding one workflow step and one memory store, while the same feature
*improved* the adoption path (the dead `## Stack` stub in the generated `CLAUDE.md` became a
real instruction, and `EMPTY-CHARTER` fixed a day-one error message). The signal could not
represent that, because it only counts steps.

Feature 014 (`ground rules`) would hit the same wall: six mandatory questions is real adoption
cost, and the current signal has no way to weigh it against a project that can no longer start
without a quality floor.

**Self-check on motive.** The obvious objection is that this amendment is being proposed because
the signal keeps grading recent work poorly — moving the goalposts. The reductio above is the
answer: the defect exists independently of any feature. A signal maximised by an empty
repository is wrong even if every feature scored 5 against it. The amendment narrows what
counts as a defect; it does not remove the measurement.

## Decision

Pillar `frictionless-adoption`, in `memory/north-star/north-star.md` (prose and canonical
JSON block).

**Before:**

```json
{
  "id": "frictionless-adoption",
  "statement": "Incorporating the harness into a new repo costs little.",
  "signal": "Steps/time to adopt the harness in a project (lower = better)."
}
```

**After:**

```json
{
  "id": "frictionless-adoption",
  "statement": "Incorporating the harness into a new repo costs little, and every cost it does impose is justified by what that cost prevents.",
  "signal": "Steps/time to adopt (lower = better), with every mandatory step carrying a recorded justification proportional to what it prevents. The defect is an unjustified step, not a step as such: friction that buys nothing is what is being measured."
}
```

No other pillar changes. `scope` is untouched. `mission` is untouched.

## Scope-delta

Nothing moves between `in_scope` and `out_of_scope`. No pillar is added or removed. One pillar
is **materially reformulated**: the quantity measured changes from *steps* to *steps without a
recorded justification*.

Impact radius: `/align` scoring of any brief that adds a mandatory step, and `/retro` Face A
verdicts against this pillar. Both become able to distinguish "this costs something and says
what it buys" from "this costs something and buys nothing" — a distinction the previous wording
could not express.

## Consequences

**Newly enabled.** A brief that adds a mandatory step can now score honestly against this
pillar by stating what the step prevents. Previously the only honest verdict for such a brief
was to not claim the pillar at all (which is what 013's `alignment.md` did) and to record a
negative at `/retro`.

**Newly prohibited.** A mandatory step with no recorded justification is now a *defect against
a pillar*, not merely inelegant. This is stricter than before, where an unjustified step and a
justified one were indistinguishable — both were just "+1 step".

**Judgment introduced, deliberately.** "Proportional to what it prevents" is not fully
mechanical, and the previous wording was brutal but unambiguous. This is a real cost of the
amendment and it is accepted: the alternative is a signal that is precise about the wrong
quantity. The mechanical half survives — steps are still counted, and whether a step carries a
recorded justification is checkable.

**Retroactive effect: none.** Closed features are not re-scored. 013's retro keeps its
`❌ did not move` verdict against the signal that was in force when it closed; re-grading past
work under a newly amended rule is exactly the goalpost-moving this ADR argues it is not doing.

**Follow-up.** Feature 014 (`ground rules`) runs `/align` against the amended North Star. Its
six mandatory questions must each state what they prevent — which the brief already requires of
them, and which this pillar now measures.
