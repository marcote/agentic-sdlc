# Tasks — Stack Charter: no load-bearing decision stays mute

> Executable decomposition. `/tasks` GATE passed (machine-checked over `coverage.md`:
> 18 deterministic rows, all with a linked test in 🔴 RED; 3 `📋 case`; 1 `deferred`;
> 0 violations). Each task lists the criteria it turns 🟢.
>
> Order is dependency-driven: the engine and the base docs come first because the charter,
> the gates and the vendoring all read them. Re-run `bash tests/run.sh` after each task.
> Done when all 18 deterministic criteria are 🟢 **and** the full suite stays green
> (baseline before 013: 244 PASS / 0 FAIL).

## T1 — `memory/stack/base/` — pin grammar and the rules that govern it
Create `pin-template.md` (canonical pin form, field semantics for `Confidence` / `Because` /
`Buys` / `Forecloses` / `Falsifier` / `Hedge` / `Guard` / `Injects` / `Superseded`, with worked
examples **inside fenced blocks** — D4 depends on that fencing) and `README.md` (the
reversal-cost inclusion test, the hedge admission test, the two pin kinds, `S0` scales scope
only, and the floor — P6 + `secret-scan.sh` — does not scale).

**Write both in prose that names no tool, language, runtime or vendor.** Every concrete name
belongs inside a fence. This is the constraint `NO-PRESCRIBE` enforces, and getting it wrong
here is the single most likely way to fail this feature.
- Criteria: **PIN-SHAPE** (template half), **S0-SCOPE-ONLY**, **NO-PRESCRIBE**.

## T2 — `scripts/stack/engine.py` — the reference deterministic engine
Mirror `scripts/north-star/engine.py`: stdlib only, `argparse` subcommands.
- `pin-valid <charter>` → exit 0 iff every pin carries the five required fields, every
  `PROVISIONAL` pin has a non-empty `Hedge`, every `[stance]` pin has both `Guard` and
  `Injects`, and every `SUPERSEDED` pin records a date **and** a reason/trigger.
- `exposure <charter>` → the header line (counts by `Confidence` + the list of `PROVISIONAL`
  ids). Must be byte-stable across runs on unchanged input.
- `guards <charter>` → emit one `Guard` command per line, for `/verify` to execute.
- Criteria: **PROVISIONAL-HEDGE** (engine half), **STANCE-GUARD** (engine half),
  **AMEND-TRAIL**, **RERUN-IDEMPOTENT** (engine half), **HERMETIC-ENV** (dep-free half).

## T3 — `/stack` command + skill
`.claude/commands/stack.md` + `.claude/skills/stack/SKILL.md`. Document the seven ordered steps:
derive `S0` from the blast-radius questions → **Draft** (propose from the North Star, mark each
`inferred`/`assumed`/`unknown`, and *proactively* propose asymmetric cost-now-zero pins) →
**Price** (`Buys`/`Forecloses` on every proposal) → **Grill** (only where the agent cannot infer
**and** the answer changes architecture; one question at a time) → **"I don't know"** →
`PROVISIONAL` + mandatory `Hedge`, subject to the admission test, never blocking → **coherence
objection over the complete set**, which must produce an explicit verdict → **write**, delta-based:
propose only additions and amendments, preserve pin ids, ordering and `SUPERSEDED` history,
never regenerate.
- Criteria: **STACK-CMD** (command/skill half), **RERUN-IDEMPOTENT** (documented-delta half).

## T4 — Seed the harness's own charter (D3 reflexive dogfood)
Run `/stack` on this repo and write `memory/stack/stack.md`:
`S0` rigor tier (high — the harness is vendored into other people's repos; record the
blast-radius answers and a `Falsifier` for what would lower it); `S1 [stance]` impose no
runtime, whose **`Guard` is the `NO-PRESCRIBE` scan itself**; `S2 [substrate]` py3 reference
engine (006); `S3 [substrate]` bash + coreutils dependency-free baseline. Every pin well-formed
per T2's `pin-valid`. Regenerate the exposure header with `engine.py exposure`.
- Criteria: **PIN-SHAPE** (charter half), **S0-PIN**, **CHARTER-SEED**, **STANCE-GUARD**
  (charter half), **PROVISIONAL-HEDGE** (charter half).

## T5 — `/plan` guard
Rewrite `.claude/commands/plan.md` with the fail-closed gate: inputs `acceptance.md` + the
charter; **exactly one** of `PASS` / `UNPINNED` / `TRIPPED`, never silence; absent charter →
refuse with "run `/stack` first" (same shape as `/distill`'s absent `alignment.md`); `PASS`
requires `plan.md` to **cite** the pins it depends on; `UNPINNED` elicits and appends, and when
the new pin is `[stance]` **bounces back to `/distill`** so `coverage.md` reopens for its
`Injects` rows and re-freezes; `TRIPPED` reports all four — criterion × pin, the **declared**
reversal cost (not re-estimated), **whether the `Hedge` exists in the code**, and the two paths
(amend / narrow).
- Criteria: **PLAN-GATE**, **PLAN-BOUNCE** (plan half), **TRIPPED-BILL**.

## T6 — `/distill` and `/verify` skill updates
`distill/SKILL.md`: step 1 additionally reads `[stance]` pins and injects their `Injects` rows
alongside `base/patterns/*.md`; add the note describing the reopen/re-freeze when `/plan`
bounces. `verify/SKILL.md`: call `engine.py guards`, execute each command, require exit 0.
- Criteria: **DISTILL-STANCE**, **PLAN-BOUNCE** (distill half), **GUARD-RUNS** (skill half).

## T7 — `wow-report` charter health
`.claude/skills/wow-report/SKILL.md`: emit two signals — **pins that tripped** (the charter
worked) and **decisions that caused rework with no pin** covering them (charter gap). Say
plainly that at `N=1` neither signal is conclusive.
- Criteria: **WOW-HEALTH**.

## T8 — Vendoring + workflow docs
`scripts/vendor.sh`: `memory/stack/base/` → **KEEP**, `memory/stack/stack.md` → **SEED**;
rewrite the generated `CLAUDE.md` `## Stack` stub from the dead `_(your language/framework)_`
blank into a pointer at the charter plus "run `/stack`". Then place `/stack` in the loop in
`docs/workflow.md`, `CLAUDE.md` and `README.md` — after seeding the North Star, before the
first brief.
- Criteria: **VENDOR-STACK**, **STACK-CMD** (docs half).

## T9 — Close the RED, then the dogfood
Re-run `bash tests/run.sh`: all 18 deterministic criteria 🟢 and the suite ≥ 244 PASS / 0 FAIL.
Then discharge the two obligations `plan.md` recorded against the bootstrap exception:
run the finished `/plan` guard **retroactively** against this feature's own `acceptance.md` ×
the seeded charter, and record the verdict. **A trivial `PASS` means the dogfood proved
nothing** — if charter and criteria never touch, say so plainly in the `/uat` notes rather than
booking it as a success.
- Criteria: all 18 → 🟢; sets up `/verify` and `/uat`.

---

## Not in this breakdown

- **The three `📋 case` rows** (`JUDGE-TRIPPED`, `JUDGE-COHERENCE`, `JUDGE-HEDGE-COST`) are
  already present in `evals/cases/stack-charter-judge.md` (6 cases) and are exercised at
  `/verify`, not by an implementation task.
- **`hermetic-offline`** is `deferred` — 013 reaches no network or remote source.
