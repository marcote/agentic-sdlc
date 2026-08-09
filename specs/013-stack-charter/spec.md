# Spec — Stack Charter: no load-bearing decision stays mute

> WHAT is built. Produced by `/distill` from `brief.md`. Frozen when `coverage.md` has no
> orphan rows. Design: `docs/superpowers/specs/2026-08-08-stack-charter-design.md`.

## Functional requirements

### The artifact

1. **`memory/stack/` exists** as a third memory store, holding `stack.md` (the project
   charter), `base/pin-template.md` (canonical pin form + field semantics) and
   `base/README.md` (inclusion test, hedge admission test, the two pin kinds).
2. **A pin is well-formed only with `Confidence`, `Because`, `Buys`, `Forecloses` and
   `Falsifier`.** `Forecloses` is the price and `Falsifier` is the self-invalidation
   condition; a block missing either is not a pin.
3. **A `PROVISIONAL` pin carries a non-empty `Hedge`.** Declared uncertainty must buy an
   architectural hedge, emitted as a `[given]` row in the consuming feature's `coverage.md`.
4. **A `[stance]` pin names a `Guard`** — an executable command — and an `Injects` clause.
   Substrate pins carry neither.
5. **`S0` (rigor tier) is the first pin**, derived from blast-radius questions rather than
   chosen by label, and carries its own `Falsifier` so a rising tier is announced.
6. **The charter emits an exposure header** — pin counts by `Confidence` and the list of
   `PROVISIONAL` pin ids.
7. **Superseded pins stay inline** in `stack.md` marked `SUPERSEDED` with date, reason, and
   what tripped them. No separate ADR directory.

### The gates

8. **`/stack` command + skill** implement the elicitation procedure: derive `S0` → Draft
   (propose from the North Star, marking `inferred`/`assumed`/`unknown`, and *proactively*
   proposing asymmetric cost-now-zero pins) → Price → Grill (only where the agent cannot
   infer **and** the answer changes architecture) → accept "I don't know" as `PROVISIONAL` +
   mandatory `Hedge` → coherence objection over the complete set → write.
9. **`/stack` is positioned** after seeding the North Star and before the first brief, in
   `docs/workflow.md` and `CLAUDE.md`.
10. **`/plan` fails closed** and emits exactly one of `PASS` / `UNPINNED` / `TRIPPED`, never
    silence. On `PASS`, `plan.md` cites the pins it depends on.
11. **`UNPINNED` elicits the missing pin and appends it to the charter**, then proceeds — the
    accretion loop.
12. **`UNPINNED` that mints a `[stance]` pin bounces back to `/distill`**: `coverage.md`
    reopens to receive the pin's `Injects` rows and is re-frozen before `/plan` resumes.
13. **`TRIPPED` reports four things**: which criterion invalidated which pin; the *previously
    declared* reversal cost (not a fresh estimate); **whether the `Hedge` that was paid for
    actually exists in the code**; and the two paths — amend the pin, or narrow the criterion.
14. **`S0` scales scope only.** The `/contract` RED gate and 100% coverage apply identically
    at every tier; only the number of pins elicited and criteria produced varies.
15. **The floor does not scale.** `base/principles.md` P6 and `.claude/hooks/secret-scan.sh`
    hold identically at the lowest tier.

### Enforcement without prescription

16. **`/verify` runs each `[stance]` pin's named `Guard` command and requires green.** The
    harness enforces the *shape* — a named, runnable, passing check — and never the content.
17. **The harness names no tool, language, runtime or vendor as a required default** anywhere
    in `memory/stack/base/`. Example pins in the template are illustrative and live inside
    code fences.
18. **`/distill` step 1 additionally reads `[stance]` pins** and injects their `Injects` rows
    alongside `base/patterns/*.md`.
19. **`vendor.sh` ships `memory/stack/base/` as KEEP and `memory/stack/stack.md` as SEED**; a
    vendored target receives the mechanism, never the harness's own pins. The generated
    `CLAUDE.md` `## Stack` section points at the charter instead of a blank stub.
20. **`wow-report` reports charter health**: pins that tripped (the charter worked) vs
    decisions that caused rework with no pin (charter gap).

### Reflexive dogfood (D3)

21. **The harness's own charter is seeded** with the decisions live today: the py3 reference
    engine (006), the bash-only dependency-free baseline, and the impose-no-runtime stance.
22. **Re-running `/stack` over an existing charter is idempotent**: it proposes deltas, never
    silently drops or duplicates a pin, and preserves `SUPERSEDED` history.

## User stories

- As a **maintainer starting a project**, I want the harness to ask what it is about to assume
  — deploy target, datastore, runtime, interface shape — so a decision made by omission does
  not become a rewrite three features later.
- As a **maintainer who does not know an answer**, I want "I don't know, but this way" to be a
  first-class outcome that buys a cheap architectural escape, so being wrong stays cheap
  instead of blocking me into a guess I will regret.
- As a **maintainer mid-project**, I want the feature whose acceptance criteria invalidate an
  earlier decision to stop at the step that can still act on it, with the bill I already
  agreed to rather than a fresh surprise.
- As an **adopter on any stack**, I want my own technical opinions to become enforceable
  checks without the harness prescribing a single tool of its own.

## Edge cases (80% problem)

- **Stance pin born at `/plan`** — its `Injects` rows belong in a frozen `coverage.md`.
  Resolved: bounce to `/distill` (FR-12). Adds a workflow loop that does not exist today.
- **`NO-PRESCRIBE` false positives.** The pin template *must* contain example pins naming
  DuckDB, Postgres, Railway. A naive grep for tool names would fail on its own documentation.
  The check must be **code-span aware** — the same blind spot that bit `check_90` and was
  fixed in `e6bc658`. Reuse that idiom rather than rediscovering it.
- **A `Guard` that passes vacuously.** A named check that greps a directory which does not
  exist is green by construction. The `Guard` contract requires the command to be tied to an
  observable deliverable, per Principle 2.
- **`S0` rises mid-project** (script starts running on a server). Closed features are not
  re-verified at the new tier; the tier applies from the next feature forward, and the rise
  is announced because `S0` carries a `Falsifier`.
- **A `PROVISIONAL` pin whose `Hedge` is not free.** Rejected as premature abstraction; the
  pin is then fixed firmly (accepting the declared reversal cost) or the uncertainty is
  resolved first. Without this the mechanism becomes ports-and-adapters for a 200-line script.
- **An adopter with no charter yet.** `/plan`'s guard must degrade to a clear "run `/stack`
  first" rather than a crash or a silent pass — the same shape as `/distill`'s absent
  `alignment.md`.
- **Re-running `/stack`.** A repeatable write over an existing charter; must not clobber
  (FR-22).
- **`TRIPPED` where the hedge was skipped.** The guard must say so plainly rather than quote
  the optimistic reversal cost — the honest bill is the whole point of the mechanism.

## Open questions / deferred

- **Portable profile layer** — deferred by design (brief, Out of scope). The `Draft` step
  proposes from the model's own knowledge meanwhile; the slot is left open.
- **`hermetic-offline`** — `[given]` from `base/hermetic-tests`, marked `deferred`:
  `check_92_stack.sh` reaches no network or remote source, so there is no external dependency
  to put behind an override seam. `hermetic-env` applies and is kept.
- **Charter-health signal calibration** — `wow-report` will have `N=1` charter datapoint at
  close. The signal is emitted; whether the mechanism *pays for its ceremony* cannot be
  answered until several features have run through it. Recorded as the `/retro` prediction,
  together with the `frictionless-adoption` hit that `alignment.md` flagged.
