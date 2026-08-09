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

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: pending · coverage: 100% (18/18 deterministic) · retro: pending

Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/013-stack-charter/retro.md` (closes the measurable prediction from `/align`).

**Gaps routed:** none to implementation. Two items carried to `/uat` and `/retro`:

- **`/uat` must check the scope edge on the shipped artifacts, not on the brief's promise.**
  `alignment.md` scored `scopeCompliance` at 4 because a charter's content *is* runtime and
  tooling decisions. If anything in `memory/stack/base/` names a tool as a default, the feature
  crossed from mechanism to imposition. `NO-PRESCRIBE` checks this automatically and is green.
- **`/retro` must rule on a trade this report cannot settle.** `frictionless-adoption` was
  deliberately not claimed: 013 adds a workflow step and a third `memory/` store, moving that
  signal the wrong way. The compensating `measurable-impact` gain has **N=1** of evidence — the
  `UNPINNED` verdict on 013's own plan, which minted `S4`. That is a real datapoint, not a
  simulated one, but it is one.
