# The stack charter — what it is and what governs it

> This store holds **how the work is built**: the load-bearing technical decisions of a
> project, each recorded with its price. Its siblings are `memory/north-star/` (**why** the
> product exists) and `memory/constitution/` (**how** the team works). The pin grammar lives in
> `pin-template.md`; the project's actual pins live in `../stack.md`.
>
> **Adopters:** `base/` is vendored and copied verbatim. `../stack.md` is yours — the harness
> ships the mechanism, never the opinions. Nothing in this directory names a tool, a language,
> a runtime or a vendor as a default; that is enforced by a check, not by good intentions.

## Why this store exists

A workflow that never asks decides by omission. Nobody is asked where the work deploys, how
many processes write at once, or whether the terminal is the only consumer — so the agent picks
something reasonable and moves on. Nothing turns red, coverage closes, the feature ships. The
bill arrives three features later as rework.

The purpose is **not to eliminate assumptions.** It is to ensure that no load-bearing
assumption is *mute*. An assumption stated out loud, with its cost, is not a surprise later —
even when it turns out to be wrong.

## The inclusion test

> **A decision is a pin if and only if changing it later costs rework.**

That test replaces an enumerated list of decisions, which could never cover the future. Deploy
target, datastore, interface stance, language and runtime: in. Formatter settings, log
verbosity: out.

One class deserves special attention, because it is the one nobody thinks to ask for:

> **cost now ≈ 0 · cost later = rewrite**

Returning a value instead of printing it costs nothing today; extracting it from forty print
statements costs a sprint. The elicitation step is obliged to *propose* pins of this class
proactively, not wait to be asked about them.

## The hedge admission test

Declared uncertainty (`Confidence: PROVISIONAL`) must buy a **hedge**: keep that seam cheap to
change. That is what turns *"I don't know, but this way"* from optimism into something already
paid for.

This mechanism can metastasise into layers of indirection wrapping a two-hundred-line script.
The counterweight is a hard rule:

> **A hedge must cost ~nothing now.** If it costs real design work, it is not a hedge — it is
> premature abstraction.

When the hedge is not free, there are exactly two honest moves: pin firmly and accept the
declared reversal cost, or resolve the uncertainty before proceeding. Without this rule, the
mechanism becomes the problem it was built to prevent.

## `S0` — the rigor tier

`S0` is always the first pin, and it calibrates the others. It is **derived, not chosen by
label**: the interview asks about the world rather than asking you to classify your project.

- Does it run on your own machine, or somewhere else?
- Does anyone besides you use it?
- Does it touch secrets, money, or third-party data?
- If it breaks, do you re-run it — or does state get corrupted?

The underlying axis is **blast radius**: who is harmed when it breaks, and whether it is
re-runnable. `S0` carries a `Falsifier` like any other pin, so a rising tier is *announced* —
the personal script that starts running on a schedule somewhere does not catch you off guard.

## What `S0` scales — and what it does not

`S0` scales **scope**: how many pins are elicited and how many acceptance criteria a feature
produces. At a low tier, three criteria instead of fifteen. Hedging is also rarer there — at low
blast radius the honest move is usually to pin firmly and accept the reversal cost, since
rework on a disposable artifact is cheap by definition.

`S0` does **not** scale the rules. Over whatever criteria exist:

- the test-first gate still applies — no deterministic criterion advances to implementation
  without a test in 🔴 RED;
- coverage is still **100%** at close.

One mode of operation, calibrated. Full coverage of three criteria is not theater; it means the
feature was small. If the tier could switch these off, *non-negotiable* would mean
*non-negotiable except when not*, and the constitution would stop working as a filter.

## The ground rules — the coverage floor

`ground-rules.md` holds the **floor of the charter**: aspects that must have a recorded
rationale before implementation begins. Each is answered by a pin declaring `Answers: GR<n>`, or
declined with an `n/a` block carrying `Because` + `Falsifier`. `/plan` refuses to proceed while
any ground rule lacks a verdict (`UNCOVERED`).

A ground rule names a **question**, never an answer — which is what lets the floor be universal
without imposing anything. `S0` scales how deep an answer goes and how many pins exist beyond
the floor; it never scales whether a ground rule is answered. Read the file itself for the six
and for how to extend the set (additive only).

## The floor does not scale at all

Some rules hold identically at every tier, including the most disposable one. They are **not
pins** — a pin is negotiable and these are not. They live in
`memory/constitution/base/principles.md` (**P6**, *Security by default*), enforced by the
repository's `secret-scan` hook.

No credential is hardcoded in a throwaway script either — and not because someone remembered to
ask for it.

## How the charter is enforced

| Moment | What happens |
| ------ | ------------ |
| Project start | The elicitation step derives `S0`, drafts pins from the North Star, prices each one, asks only what it cannot infer, accepts *"I don't know"* as `PROVISIONAL` + a hedge, and objects to the set as a whole. |
| Every feature's technical plan | A fail-closed gate reads the feature's acceptance criteria against the charter and emits exactly one verdict — never silence. An unpinned load-bearing decision stops the feature and is elicited on the spot; a criterion matching a declared `Falsifier` stops it and presents the previously declared cost, plus whether the hedge that was paid for actually exists. |
| Verification | Every pin that declares a `Guard` — of either kind — has that command executed, and it must exit 0. The harness asserts the *shape* — a named, runnable, passing check — and knows nothing about what it inspects. That is how a project's own opinions become enforceable without the harness prescribing any of its own. |

## Amendment

Changing a pin is not silent, and it is not gated in CI — productivity comes first, and a
technical pin is feature throughput, unlike a change to product governance. The superseded pin
keeps its id, gains a `SUPERSEDED` marker, and records the date, the reason, and what tripped
it. History stays in the same file; there is no separate decision directory to maintain.
