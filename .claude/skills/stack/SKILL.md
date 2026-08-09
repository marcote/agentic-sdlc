---
name: stack
description: Elicits the project's stack charter — the load-bearing technical decisions, each with its price and its own invalidation condition. Use after seeding the North Star and before the first brief, and whenever /plan reports UNPINNED.
---

# Stack

Input: `memory/north-star/north-star.md` (+ the existing charter, if any).
Output: `memory/stack/stack.md`. Grammar: `memory/stack/base/pin-template.md`. Rules:
`memory/stack/base/README.md`.

**What this skill is for.** A workflow that never asks decides by omission. The job is *not*
to eliminate assumptions — it is to make sure no load-bearing assumption is **mute**. An
assumption stated out loud with its cost is not a surprise later, even when it turns out wrong.

**Inclusion test:** a decision is a pin iff **changing it later costs rework**.

## Procedure

### 0. Derive `S0`, the rigor tier
Ask the four blast-radius questions (`base/README.md`) — where it runs, who else uses it, what
it touches, whether a break is re-runnable. Do **not** ask the human to pick a tier label; the
tier is derived from answers they actually have. Write `S0` as the first pin, with a
`Falsifier` for what would raise it. `S0` caps how deep steps 1–5 go.

### 1. Draft — never start from a blank page
Read the North Star and **propose** the pin sheet with your own defaults, marking each entry
`inferred` / `assumed` / `unknown`.

**Obligation:** proactively propose the pins with the asymmetry **cost now ≈ 0 · cost later =
rewrite**, even though nobody asked. Returning a value instead of printing it costs nothing
today and a sprint later. The human will not request this class — they said they do not know
their own constraints, which is why you are here.

### 2. Price every proposal
Each proposed pin ships with `Buys` and `Forecloses`. `Forecloses` is not optional: the
expensive surprise is never the decision, it is the cost nobody stated. Pricing lets the human
object to the *price*, not only to the choice.

### 3. Grill — one question at a time
Ask **only** where you (a) cannot infer the answer **and** (b) the answer changes architecture.
Everything else you assume **out loud**, and the human overrides if they disagree.

**Ask about the world, not about the technology.** The human cannot answer what they do not
know, but they do know facts from which it follows:

> ❌ *"Which datastore?"* → "you decide" → a mute assumption
> ✅ *"Will one process write this, or several at once — today, and in six months?"* → "one
> today, no idea later" → you derive the pin, its `Falsifier`, and its `Hedge`.

You perform the translation domain → non-functional requirement → pin.

### 3b. Walk the six ground rules — the floor
`memory/stack/base/ground-rules.md` (plus any project layer) defines the **floor of the
charter**: aspects that must have a recorded rationale before implementation begins. Walk them
explicitly, by id, so the default path produces a covered charter instead of one that trips
`/plan`'s `UNCOVERED` verdict later:

- **`GR1` Consumption** — how does anything outside reach this, and is the core separable from
  the way it is reached?
- **`GR2` Persistence and concurrency** — what holds state, and how many things write to it at
  once?
- **`GR3` Deployment and topology** — where does it run, and in how many instances?
- **`GR4` Language, runtime and execution** — what is it written in, which version, how are
  dependencies declared, and how is it run?
- **`GR5` What "verified" means** — what does the verification command exercise, and what does a
  passing run prove?
- **`GR6` Failure posture** — when it breaks: retry, corrupt, alert, or continue silently?

Each resolves to a pin declaring `Answers: GR<n>`, or to a declination (`### GR<n> — n/a` with
`Because` + `Falsifier`). Declining is legitimate and cheap — but a decline that is *convenient*
rather than *true* is a defect, not a shortcut, and it is the easiest way to defeat the floor
without appearing to.

The floor does **not** scale with `S0`. At the most disposable tier the answers get shorter and
more of them are declines; the questions still get asked.

### 3c. Migrate a charter that predates the floor
On a charter below coverage — which is every charter written before the ground rules existed —
do not simply report `UNCOVERED`. Read the existing pins and **propose which one answers which
rule**, then ask where an `n/a` belongs. The gate itself does not soften; the migration is what
makes a hard gate justified friction rather than a wall.

Verify with `python3 scripts/stack/engine.py ground-rules memory/stack/stack.md` before
finishing: exit 0 means covered, exit 1 lists what is still open.

### 4. "I don't know" is a valid answer
It produces `Confidence: PROVISIONAL` plus a **mandatory** `Hedge`, and never blocks. If not
knowing blocked the interview, the human would invent an answer to get through it.

Apply the **hedge admission test**: a hedge must cost ~nothing now. If it costs real design
work it is premature abstraction, and the two honest moves are to pin firmly and accept the
declared reversal cost, or to resolve the uncertainty first. A `PROVISIONAL` pin without a
`Hedge` is a lie; a `PROVISIONAL` pin whose hedge is expensive is the mechanism eating itself.

### 5. Coherence objection over the complete set
Judge the pins **as a set**, and emit an explicit verdict — silence is not allowed, because
silence is indistinguishable from not having looked. Individually defensible pins can be
jointly absurd (an API-first delivery pace against a language with no practical HTTP
ecosystem). Name the conflicting pins and ask which one gives.

Do not maintain a compatibility matrix: it ages badly and cannot cover the future. This is your
judgment. An incompatibility that actually bites gets promoted to a written rule afterwards —
the constitution's existing accretion idiom.

### 6. Write — delta-based, never generative
On an existing charter, read it first and propose **only additions and amendments**. Preserve
pin ids, document order, and `SUPERSEDED` history verbatim; **never drop a pin** you did not
re-derive, and never renumber. Re-running with unchanged inputs must be a no-op.

An amended pin keeps its id, gains a `SUPERSEDED` marker, and records the date, the reason, and
what tripped it.

Then validate and regenerate — **never hand-write the exposure header**:

```sh
python3 scripts/stack/engine.py pin-valid memory/stack/stack.md
python3 scripts/stack/engine.py exposure memory/stack/stack.md
```

## When `/plan` reports `UNPINNED`

Run steps 1–5 scoped to that single decision, append the pin, and hand control back. This is
the accretion loop: the charter grows from real features instead of from guessing what the
future needs.

If the new pin is `[stance]`, its `Injects` rows belong in a `coverage.md` that `/distill`
already froze — so the feature **bounces back to `/distill`** to reopen coverage, take the new
rows, and re-freeze before `/plan` resumes.

## Contract in the template, engine per-stack

`scripts/stack/engine.py` is a **reference** implementation of the deterministic parts
(field completeness, `PROVISIONAL`⇒`Hedge`, `[stance]`⇒`Guard`, exposure, guard extraction). An
adopting repo may reimplement it in its own stack against the documented CLI contract, exactly
as `evals/README.md` leaves the eval runner to the adopter. The semantic parts — the inclusion
test, the domain→pin translation, the coherence objection, the hedge admission test — are this
skill's judgment and are covered by `evals/cases/stack-charter-judge.md`.
