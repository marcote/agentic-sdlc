# Verification Report — 013-stack-charter @ 8d94208

spec: `specs/013-stack-charter/spec.md` (frozen at `086216d`) · date: 2026-08-08 ·
constitution: base (P1–P6) + project deltas D1–D3

## 1. Coverage snapshot

18 deterministic criteria · 3 non-deterministic (`📋 case`) · 1 `deferred`.
All 18 deterministic 🟢 GREEN, linked to `tests/check_92_stack.sh`. Full matrix:
`specs/013-stack-charter/coverage.md`.

`deferred`: `hermetic-offline` (`[given] base/hermetic-tests`) — 013 reaches no network or
remote source, so there is no external dependency to place behind an override seam.

## 2. Output eval (BUILD) — deterministic

`bash tests/run.sh` → **313 PASS / 0 FAIL**.
Trajectory of the suite across this feature: 244/0 (before 013) → 251/53 (at `/contract`, RED
proved) → 278/35 (T1–T4) → **313/0** (T5–T9).

- `check_92_stack.sh`: **69 assertions passing, 0 failing.**
- **Task success: 18/18 = 100%** (threshold 100%, non-negotiable) ✅

Evidence that the RED was real: at `/contract` every assertion touching a 013 artifact failed
because `memory/stack/`, `scripts/stack/engine.py` and the `/stack` command/skill did not
exist. `NO-PRESCRIBE` is an invariant tied to its deliverable (it cannot pass before there is a
directory to scan) — a genuine RED→GREEN arc, not green-by-construction.

**Hermeticity proved, not asserted.** The suite was re-run in a fresh clone with a **detached
HEAD**, **no local `main`**, **stdin closed** (no controlling terminal) and `LC_ALL=C`:
**313 PASS / 0 FAIL**. This discharges `HERMETIC-ENV` against the real conditions rather than
against a claim in the check.

## 3. Stance Guards (BUILD, cont.)

`python3 scripts/stack/engine.py guards memory/stack/stack.md` → 1 guard, run **by name only**:

| Guard | Exit | Verdict |
|---|---|---|
| `bash scripts/guards/no-prescribe.sh` | 0 | ✅ |

**Non-vacuity proved** (a `Guard` that cannot fail is a FAIL, not a pass): the same guard exits
**1** on a violating fixture and **2** on an empty target, where it refuses to report success
without having scanned anything.

## 4. Trajectory eval — LM judge over the trace

| Dimension | Result | Note |
|---|---|---|
| Tool use | ✅ | Every step ran its real instrument instead of being simulated: the 006 engine executed the `/align` verdict (`schema-valid`, `scope-reject` ×5, `align-verdict`); the `/tasks` gate was walked mechanically over `coverage.md` (18/3/1, 0 violations) rather than by eye; `status.sh` confirmed each phase transition. |
| Trajectory compliance | ✅ | No step skipped: brief → `/align` → `/distill` → `/plan` → `/contract` (RED proved before any implementation) → `/tasks` (gate) → implement → `/verify`. The `/contract` RED was proved by running the suite, not claimed. |
| Hallucination | **0** ✅ | `scripts/stack/engine.py` imports `sys`, `re`, `argparse` — stdlib only, no invented dependency. `assert_dep_free` green. No API was referenced that does not exist. |
| Response quality | deferred to `/uat` | The 3 `📋 case` rows are non-deterministic; per this skill's step 6 they are **not** closed here. |

**Self-reported trajectory defects** (found and fixed in-flight; recorded rather than hidden):

1. `HERMETIC-ENV` grepped its own source for a forbidden literal and **matched its own grep
   line**. Patterns are now assembled from fragments at runtime, with positive self-tests so a
   split pattern cannot silently go vacuous. Third occurrence of the `check_90` family
   (`e6bc658`) — flagged for a constitution rule, out of scope for 013.
2. `wow-report =~ /pin/` passed **vacuously** (the word already existed in the skill).
   Green-by-construction, rejected by Principle 2; replaced with three specific assertions.
3. The denylist was **unanchored**: `rails` matched "guardrails". Fixed to word boundaries
   *before* writing any prose, so it never produced a false positive.
4. The exposure header was hand-edited and drifted from the engine **twice**. Both times the
   generated value won.

None are BUILD failures; all four are evidence the checks were exercised rather than assumed.

## 4. UAT — against the brief's objective (2026-08-08)

UAT was run against the **objective**, not the spec: the harness verifying itself is a weak
test for a feature about adopters, so the walk was done by vendoring onto a clean repo and
inspecting what an adopter actually receives.

| Walked | Result |
|---|---|
| Adopter receives the mechanism | ✅ `base/README.md`, `base/pin-template.md`, both engines, the guard |
| The harness's own pins do **not** travel | ✅ target gets a stub with zero pins |
| The dead `## Stack` stub now points at the charter | ✅ hand-off names `/stack` |
| `NO-PRESCRIBE` against **shipped artifacts**, not the brief's promise | ✅ green — the scope edge `/align` scored at 4 was not crossed |
| Adopter's day-one state is coherent | ❌ **gap found** → routed, fixed, re-verified (below) |

**Product gap found and closed.** Vendoring never produces "no charter" — it seeds a stub, so
an adopter's day-one state is a well-formed file with **zero pins**. The engine called that
`malformed` (exit 2) and `/plan`'s gate only handled an *absent* charter. A fresh adopter's
first interaction with this feature was an error about a bug that did not exist, on the very
path `frictionless-adoption` measures.

This was a **missing criterion, not a failing one**, so it routed to `/distill` per the UAT
checklist rather than being patched quietly. `EMPTY-CHARTER` was specified, **proved 🔴 RED**
(4 failing assertions; a fifth passed as the control that an unreadable charter still exits 2,
without which the empty/malformed distinction would be meaningless), then implemented. Suite
315/4 → **320 PASS / 0 FAIL**.

A second **vacuous assertion** was caught in the same pass: `plan.md =~ /empty/` passed because
the word already appeared in an unrelated sentence. Replaced with assertions on the real
contract. That is the second vacuous-assertion catch in this feature and the fourth
self-scanning/vacuity defect overall — see §3.

**UAT verdict: ✅** — 19/19 deterministic criteria walked and observable, one product gap found
and closed through the proper route.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% (20/20 deterministic) · retro: ✅

*Re-verified after the post-UAT `SUBSTRATE-GUARD` correction: `bash tests/run.sh` → **327 PASS / 0 FAIL**.*

**DONE.** Mission verdict `pending-observation` — the charter mechanism is built and self-exercised, but it has prevented no rework yet because no feature has run through it. See `specs/013-stack-charter/retro.md` for the re-check trigger.

Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/013-stack-charter/retro.md` (closes the measurable prediction from `/align`).

**Gaps routed:** one product gap (`EMPTY-CHARTER`) found at `/uat`, routed to `/distill`,
proved RED and closed. None to implementation.

**Pending observation carried to `/retro`** (the three `📋` eval rows, deliberately not closed):
`JUDGE-TRIPPED`, `JUDGE-COHERENCE` and `JUDGE-HEDGE-COST` would have been scored by the same
model that authored them. That is not evidence, so they stay open with an explicit trigger:
**the first feature (014+) whose `/plan` gate emits a real `UNPINNED` or `TRIPPED`, or whose
`/stack` run produces a real coherence objection.** Until then their honest state is *unproven*,
not *passing*.

Two items carried to `/retro`:

- **`/uat` must check the scope edge on the shipped artifacts, not on the brief's promise.**
  `alignment.md` scored `scopeCompliance` at 4 because a charter's content *is* runtime and
  tooling decisions. If anything in `memory/stack/base/` names a tool as a default, the feature
  crossed from mechanism to imposition. `NO-PRESCRIBE` checks this automatically and is green.
- **`/retro` must rule on a trade this report cannot settle.** `frictionless-adoption` was
  deliberately not claimed: 013 adds a workflow step and a third `memory/` store, moving that
  signal the wrong way. The compensating `measurable-impact` gain has **N=1** of evidence — the
  `UNPINNED` verdict on 013's own plan, which minted `S4`. That is a real datapoint, not a
  simulated one, but it is one.
