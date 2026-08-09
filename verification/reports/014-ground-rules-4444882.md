# Verification Report — 014-ground-rules @ 4444882

spec: `specs/014-ground-rules/spec.md` · date: 2026-08-08 ·
constitution: base (P1–P6) + project deltas D1–D3 · North Star as amended by ADR `0004`

## 1. Coverage snapshot

14 deterministic criteria · 2 non-deterministic (`📋 case`) · 1 `deferred`.
All 14 deterministic 🟢 GREEN, linked to `tests/check_94_ground_rules.sh`. Full matrix:
`specs/014-ground-rules/coverage.md`.

`deferred`: `hermetic-offline` — 014 reaches no network or remote source.

**Two rows were injected by the charter, not by the constitution** — the first time 013's
mechanism constrained a feature that is not its own: `GR-NO-PRESCRIBE` from pin `S1`'s
`Injects`, and `ENGINE-CLI-ONLY` from pin `S2`'s `Hedge`. `GR-NO-PRESCRIBE` is precisely the
risk `/align` flagged at `scopeCompliance: 3`; nobody had to remember it.

## 2. Output eval (BUILD) — deterministic

`bash tests/run.sh` → **365 PASS / 0 FAIL**.
Trajectory across the feature: 327/0 (before 014) → **337/23** (at `/contract`, RED proved) →
345/21 → 358/8 → 361/5 → 367/1 → **365/0**.

- `check_94_ground_rules.sh`: **38 assertions passing, 0 failing.**
- **Task success: 14/14 = 100%** (threshold 100%, non-negotiable) ✅

**Hermeticity proved against committed state.** Re-run in a fresh clone with a detached HEAD, no
local `main`, stdin closed and `LC_ALL=C`: **365 PASS / 0 FAIL**. *The first attempt at this
check ran against uncommitted work and reported 337/23 — a false alarm from my own process, the
same shape as running the amendment gate over an empty commit range. Recorded because the
mistake is repeatable, not because it changed the result.*

**Every criterion emits a traceable result**, audited by name against `run.sh` output (T7).
`PLAN-UNCOVERED` initially emitted nothing traceable — its assertions used `assert_contains`,
which reports path and pattern but not the criterion — so its results could not be tied back to
a coverage row. Not a dead assertion; an unauditable one, which is the same problem one step
removed. Relabelled.

**Every rejection path is reachable and names what it rejected**, run individually:
`unknown ground rule GR9 claimed by pin S1` · `declination GR2 … is missing Falsifier` ·
`… omits base ground rule(s): GR6` · `uncovered ground rule(s): …`.

## 3. Guards (BUILD, cont.)

`engine.py guards` → 1 declared check, run **by name only**:

| Guard | Exit | Verdict |
|---|---|---|
| `bash scripts/guards/no-prescribe.sh` | 0 | ✅ |

Non-vacuity re-proved: exits **1** on a violating fixture, **2** on an empty target where it
refuses to report success without having scanned anything.

**Ground-rule coverage of the harness's own charter: exit 0, all six resolved** — `GR1`/`GR3`
→ `S5`, `GR2` → `S6`, `GR4` → `S2`, `GR5` → `S7`, `GR6` → `S8`.

## 4. Trajectory eval — LM judge over the trace

| Dimension | Result | Note |
|---|---|---|
| Tool use | ✅ | Every gate ran its real instrument: the 006 engine produced the `/align` verdict against the **amended** North Star; the `/tasks` gate was walked mechanically over `coverage.md` (14/2/1, 0 violations); the amendment gate was run over a real commit range and returned `amendment OK (new ADR + schema-valid + suite green)`; 013's `/plan` stack gate ran for the first time on a feature that is not its own. |
| Trajectory compliance | ✅ | No step skipped. The North Star amendment went through its own PR (#17) with an ADR rather than riding inside the feature — governance events do not travel hidden in feature branches. `/contract` proved RED by running the suite before any implementation. |
| Hallucination | **0** ✅ | `scripts/stack/engine.py` imports `os`, `re`, `sys`, `argparse` — stdlib only. No invented API. |
| Response quality | deferred to `/uat` | The 2 `📋 case` rows are non-deterministic; per step 6 they are **not** closed here. |

**Self-reported trajectory defects** (found and fixed in-flight, recorded rather than hidden):

1. **Three false passes at `/contract`.** `argparse` exits **2** for an unknown subcommand, and
   three "must be rejected" assertions checked only for exit 2 — so they passed because
   `ground-rules` **was not implemented**. All three would have stayed green against an empty
   implementation. Fixed by requiring the engine's own stderr diagnostic. **`plan.md` D10 warns
   about this class by name, and I wrote it two hours earlier.**
2. **A fence-blind counter.** `gr_ids` read the example declination inside `ground-rules.md`'s
   own fenced block as a seventh rule, failing `GR-SIX` against a correct file.
3. **A pattern that could not tell assertion from denial.** `MIGRATION` grepped for
   `grace period` and flagged `plan.md`'s own *"there is no grace period"* — the check
   objecting to its own fix.
4. **An unauditable assertion** (`PLAN-UNCOVERED`, above).
5. **A hermeticity check run against uncommitted work**, reporting a false 337/23.

Occurrences **6 through 10** of the same family across two features, plus `e6bc658`. None is a
BUILD failure; together they are the evidence that a written warning does not prevent this and
only a mechanical check will.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% (14/14 deterministic) · retro: ✅

**DONE.** Mission verdict `pending-observation`. The floor is built, enforced and dogfooded, but the falsification test set before the result was known came back negative: **nothing was rejected for lacking justification**, so ADR `0004` is unproven rather than vindicated. See `specs/014-ground-rules/retro.md`.

## 4b. UAT — against the brief's objective (2026-08-09)

Vendored onto a clean repository and walked the adopter's real path. **The hole 014 was built to
close is closed, on a real target rather than on the harness itself**: a one-pin charter that
`pin-valid` calls VALID now reports `GR1–GR6 uncovered` (exit 1), so `/plan` returns
`UNCOVERED`. Day-one behaviour from 013 still holds (`empty … run /stack`, exit 3), the
extension path is documented, and a missing project layer degrades to exit 1 rather than a crash.

**No product gap found.**

The one judgment no check can settle was escalated rather than self-certified: `GR-NO-PRESCRIBE`
proves no tool is *named*, but cannot prove a question does not *smuggle an answer*. Five of six
read as neutral; **`GR1` leans** — it asks whether the core is separable from its transport, and
its `Prevents` argues the asymmetry. **The maintainer ruled it a question; `GR1` stands.** The
tension is recorded, not resolved: it is the rule nearest the scope edge that `/align` scored at
3.

Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/014-ground-rules/retro.md`.

**Gaps routed:** none to implementation.

**Carried to `/uat`:** `scopeCompliance: 3` sits one point above rejection. `GR-NO-PRESCRIBE`
proves no tool is *named*; it cannot prove a **question does not smuggle an answer**. That
judgment is UAT's, against the shipped `ground-rules.md`, not against the brief's promise.

**Carried to `/retro`:** this is the first feature scored under the amended
`frictionless-adoption` signal, so the retro must rule on whether ADR `0004` was sound or
self-serving. Falsification test, recorded before the fact: **did any friction get *rejected*
for lacking justification, or does everything now qualify by construction?**
