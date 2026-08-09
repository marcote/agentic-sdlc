# Brief — Stack Charter: no load-bearing decision stays mute

> ORIGIN of development. Describes the OBJECTIVE and the WHY, not the solution.

## Product objective

Close the hole where the workflow **silently decides** the things that are expensive to
undo. Today no step in `/constitution → brief → /align → /distill → /plan → /contract →
/tasks` asks where this deploys, how many processes write concurrently, or whether stdout
is the only consumer. The agent picks something reasonable and moves on; nothing is red,
coverage closes, the feature ships. The bill arrives three features later as rework.

The deliverable is a **stack charter** — a governed set of *pins*, each carrying its price
and its own invalidation condition — plus the two gates that keep it honest: an elicitation
step at project init (`/stack`) and a **fail-closed guard at `/plan`** that stops when a
feature needs an unpinned decision or when a new acceptance criterion invalidates an
existing one.

The framing: the harness's job is **not** to eliminate assumptions, it is to ensure no
load-bearing assumption is *mute*. An assumption stated out loud with its cost is not a
surprise later, even when it turns out wrong.

Design: `docs/superpowers/specs/2026-08-08-stack-charter-design.md`.

## Why / motivation

The harness is stack-agnostic by design, and that agnosticism currently has an unpaid cost:
**it leaves the highest-reversal-cost decisions to be made by omission.** Two failure shapes
neither the constitution nor the North Star catches:

- **The mute assumption.** Start on DuckDB, discover concurrent read/write three features
  in, end on Postgres. Build everything in `println`, then need to expose it over REST and
  face a near-rewrite because compute and transport were fused by default. Neither is a
  *mistake* the agent detects, so the existing "add a rule when the agent repeats a mistake"
  accretion never fires. This is precisely the class of gap the `measurable-impact` pillar
  exists to measure — late rework that discipline should have prevented.
- **The incoherent set.** Decisions can each be defensible while their combination is not
  (*API-first in Assembler*). Nothing in the loop ever evaluates the decisions as a set.

The hole is already visible in the repo: `CLAUDE.md` carries a `## Stack` section that
`vendor.sh` stubs as `_(your language/framework)_`. Nothing obliges anyone to fill it and no
command reads it — a declared extension point that was never wired.

This also protects `agnostic-portability` rather than threatening it. The harness does not
gain opinions; it gains the mechanism that forces the **adopter** to declare theirs, in a
file the adopter owns. Prescribing tooling in `base/` was considered and rejected for
exactly this reason.

## Success metrics

- **`/stack` exists and runs at init**, positioned after seeding the North Star and before
  the first brief; `docs/workflow.md` and `CLAUDE.md` document the loop with it in place.
- **A pin is rejected as malformed unless it carries its price and its invalidation
  condition** — `Confidence`, `Because`, `Buys`, `Forecloses`, `Falsifier`. A pin without
  `Forecloses` is not a pin.
- **A `PROVISIONAL` pin without a `Hedge` is rejected.** Declared uncertainty must buy an
  architectural hedge, and that hedge is emitted as a `[given]` row in `coverage.md` — so it
  is verified, not merely written.
- **A `Hedge` that is not ~free is rejected** as premature abstraction; the pin is then
  either fixed firmly (accepting the declared reversal cost) or the uncertainty is resolved
  first. Without this the mechanism becomes ports-and-adapters for a 200-line script.
- **`/plan` fails closed** and emits exactly one of three verdicts, never silence:
  `PASS` (proceeds, and `plan.md` cites the pins it depends on), `UNPINNED` (stops, elicits
  the missing pin, appends it to the charter, proceeds), `TRIPPED` (stops, reports which
  criterion invalidated which pin, the *previously declared* reversal cost, and **whether
  the hedge that was paid for actually exists in the code**, then offers amend-pin or
  narrow-criterion).
- **`UNPINNED` demonstrably grows the charter from a real feature**, not from guessing —
  this is the accretion loop, and it is what makes the mechanism survive decisions nobody
  enumerated in advance.
- **A stance pin's `Guard` is an executable check in the suite** picked up by `/verify`, not
  prose. Without it, `Injects` is a coverage row ticked by eye and the stance erodes.
- **`S0` (rigor tier) is derived from blast-radius questions, not chosen by label**, and
  scales **scope only** — the number of pins elicited and criteria produced. The `/contract`
  RED gate and 100% coverage still apply to whatever criteria exist.
- **The floor does not scale with `S0`.** `base/principles.md` P6 and `secret-scan.sh` hold
  identically at the lowest tier — no hardcoded credentials in a throwaway script either.
- **`wow-report` reports charter health**: pins that tripped (the charter worked) vs
  decisions that caused rework with no pin (charter gap). Without this there is no evidence
  the mechanism earns its ceremony.
- **The harness prescribes no stack.** No tool, language, runtime, or vendor is named as
  required anywhere in `base/`; the charter is filled by the adopter.
- **Dependency-free and non-blocking**: no new runtime dependency, and the guard is a
  workflow-step gate (like `/distill`'s `MEAS-GATE`), never a commit hook.

## Out of scope

- **The portable profile layer.** The design is conceptually two layers — portable defaults
  that seed, project pins that bind. Only the charter ships. `Draft` still proposes sensible
  defaults from the model's own knowledge; it just does not yet know a given maintainer's
  idiosyncrasies. Added when there is evidence of repeated answers across repos; the slot is
  left open.
- **Prescribing specific tooling.** No `uv`, no framework, no vendor named as a harness
  default. Doing so would hit the North Star's `out_of_scope` on imposing a runtime, and
  would break `agnostic-portability`.
- **An enumerated compatibility matrix.** Coherence is judged by the model over the full
  set; matrices age badly and cannot cover the future. Only incompatibilities that actually
  bite get promoted to written rules — the constitution's existing accretion idiom.
- **A separate stack-ADR directory.** Superseded pins stay inline in the charter with date
  and reason. Split only if it becomes unwieldy.
- **A CI gate on pin amendment.** Principle 4 (productivity first). Deliberately unlike the
  North Star `amendment-gate`, which protects *product* governance; a technical pin is
  feature throughput.
- **Re-planning this repo's closed features.** Features 001–012 are not reopened, re-briefed,
  or re-verified against the charter. *(Distinct from seeding: see Dependency below — the
  harness's own charter **is** seeded in 013 with the decisions that are live today. Recording
  a decision that already governs the repo is not retrofitting a spec onto a closed feature.)*

## Reflexive dogfood (D3)

Per constitution delta D3, this feature is workflow tooling and must run against **its own
in-flight feature** before closing. Concretely:

- `/stack` is run on the harness itself, seeding `memory/stack/stack.md` with the decisions
  that are **already live and load-bearing**: the py3 reference engine (006), the bash-only
  dependency-free baseline, and the "impose no runtime" stance. Some of these were contested
  when taken; if the mechanism cannot articulate decisions already known to have been made, it
  will not articulate future ones.
- 013's own `/plan` passes through the new `/plan` guard and must emit a real verdict.

## Dependency

None hard. Reuses existing machinery rather than adding: `/distill`'s grilling idiom and its
`[given]` injection from `base/patterns/*.md`, `/distill`'s `MEAS-GATE` as the fail-closed
precedent, `/verify`'s suite pickup for `Guard` checks, and `wow-report`'s ledger for health
signals. `vendor.sh` gains `memory/stack/base/` as KEEP and `memory/stack/stack.md` as SEED.
