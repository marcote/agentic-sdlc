# Technical plan — Stack Charter: no load-bearing decision stays mute

> HOW it is built. Grounded in the constitution. Produced by `/plan` over the frozen `spec.md`.

## Gate note — bootstrap exception (`/plan` guard)

The `/plan` guard this feature introduces **cannot gate the feature that introduces it**: there
is no charter to read and no guard to run at this point in the loop. This mirrors the explicit
`/align` bootstrap exception for `002-north-star-governance` and is declared here rather than
silently skipped.

D3 (reflexive dogfood) is satisfied instead by two obligations that **must complete before
close**, not by this exemption:

1. `/stack` is run on the harness itself, producing `memory/stack/stack.md` seeded with the
   decisions already live (D7 below).
2. The finished guard is run **retroactively against this feature's own `acceptance.md` ×
   that charter** at `/uat`, and must emit a real verdict. If it emits `PASS` trivially because
   the charter and the criteria never touch, the dogfood proved nothing and the criterion is
   not satisfied.

Every feature from 014 onward passes the guard normally, without exception.

## Technical decisions

- **D1 — The charter is one markdown file with a strict, parseable pin grammar.**
  `memory/stack/stack.md` holds an exposure header, then pin blocks:
  `### S<n> — <title>` followed by a bracketed kind tag `[stance]`/`[substrate]`, then
  `- <Field>: <value>` lines. Strict enough for a dependency-free parser, readable enough to
  edit by hand. Superseded pins stay inline, marked `SUPERSEDED`. *Why one file:* pin history
  and current state are read together at `/plan`, and a directory of ADRs is ceremony the
  design explicitly cut. Constrained by: `PIN-SHAPE`, `AMEND-TRAIL`, spec req. 1/7.

- **D2 — Deterministic validation lives in `scripts/stack/engine.py`, mirroring 006.**
  Subcommands: `pin-valid <charter>` (field completeness, `PROVISIONAL`⇒`Hedge`,
  `[stance]`⇒`Guard`+`Injects`), `exposure <charter>` (recompute the header),
  `guards <charter>` (emit the stance Guard commands for `/verify` to run). *Why py3 and not
  bash:* this is exactly the shape `scripts/north-star/engine.py` already occupies — a
  **reference** deterministic engine the adopter may reimplement in their own stack, per the
  "contract in the template, engine per-stack" doctrine. It does **not** make py3 a
  requirement, and this posture is itself pinned in the harness's own charter (D7).
  Constrained by: `PIN-SHAPE`, `PROVISIONAL-HEDGE`, `STANCE-GUARD`, principle 1.

- **D3 — `/verify` runs stance Guards by name, never by content.** `/verify` calls
  `engine.py guards` to obtain each `[stance]` pin's command, executes it, and requires exit 0.
  The harness asserts the **shape** — a named, runnable, passing check — and knows nothing
  about what the check inspects. This is what keeps `real-enforcement` real without crossing
  into prescribing a stack. Constrained by: `GUARD-RUNS`, `NO-PRESCRIBE`, `agnostic-portability`.

- **D4 — `NO-PRESCRIBE` scans prose only, code-span aware.** The pin template *necessarily*
  contains example pins naming DuckDB, Postgres, Railway; a naive grep would fail on its own
  documentation. The scan strips fenced blocks and inline code spans before matching a
  tool/language/runtime/vendor denylist. **This is the exact blind spot fixed in `check_90`
  (`e6bc658`) — reuse that idiom, do not rediscover it.** Constrained by: `NO-PRESCRIBE`,
  spec edge case 2.

- **D5 — `GUARD-RUNS` requires a negative fixture.** A Guard that greps a directory which does
  not exist passes vacuously, which is the very failure mode the criterion exists to prevent.
  The test builds a **violating** fixture tree and asserts the Guard exits non-zero on it, in
  addition to exiting 0 on the clean tree. Without both halves the criterion certifies nothing.
  Constrained by: `GUARD-RUNS`, principle 2 (invariants tied to an observable deliverable).

- **D6 — `/plan`'s guard is a documented procedure, not a script.** The three verdicts are
  model-judged (`UNPINNED` applies the reversal-cost inclusion test; `TRIPPED` reads a criterion
  against a declared `Falsifier` semantically). `check_92` therefore asserts the **contract** in
  `.claude/commands/plan.md` — that all three verdicts exist, that silence is disallowed, that
  an absent charter yields "run `/stack` first" — while the judgement quality is covered by the
  three eval cases. Same split as `/align`: deterministic aggregation in the engine, semantic
  mapping in the skill, judge quality in `evals/cases/`. Constrained by: `PLAN-GATE`,
  `TRIPPED-BILL`, `JUDGE-TRIPPED`.

- **D7 — The harness's own charter is seeded with live decisions, and its stance Guard is
  `NO-PRESCRIBE` itself.** Initial pins: `S0` rigor tier (derived from blast radius — the
  harness is vendored into other people's repos, so the tier is high); `S1 [stance]` impose no
  runtime, whose `Guard` **is** the `NO-PRESCRIBE` scan; `S2 [substrate]` py3 reference engine
  (006); `S3 [substrate]` bash + coreutils dependency-free baseline. *Why this is the strongest
  available dogfood:* S1's Guard is a check that already has to exist for this feature, so the
  harness's own stance is enforced by the same mechanism it ships. Constrained by:
  `CHARTER-SEED`, `S0-PIN`, D3 of the constitution.

- **D8 — `/stack`'s write step is delta-based, not generative.** On a charter that already
  exists, `/stack` reads it, proposes only additions and amendments, and rewrites the file
  preserving pin ids, ordering and `SUPERSEDED` history. Re-running with unchanged inputs is a
  no-op. *Why:* re-running an elicitation is a repeatable write, and a generative rewrite would
  silently drop pins the model did not re-derive. Constrained by:
  `[given] base/idempotency` → `RERUN-IDEMPOTENT`.

- **D9 — Vendoring: mechanism travels, pins do not.** `vendor.sh` gains `memory/stack/base/`
  in **KEEP** (copied verbatim, overwrites) and `memory/stack/stack.md` in **SEED** (stub if
  absent, never clobbered). The generated `CLAUDE.md` `## Stack` stub is rewritten from a dead
  `_(your language/framework)_` blank into a pointer at the charter plus the instruction to run
  `/stack`. An adopter receives the pin grammar and the gates; they never receive the harness's
  py3 or bash pins. Constrained by: `VENDOR-STACK`, `agnostic-portability`.

- **D10 — Hermetic tests via `mktemp -d` fixtures only.** `check_92_stack.sh` builds every
  charter fixture it needs under `mktemp -d`, reaches no network or remote source, assumes no
  controlling terminal, no local `main`, no locale and no clock. `run.sh` globs `check_*.sh`, so
  no wiring. Constrained by: `[given] base/hermetic-tests` → `HERMETIC-ENV`; `hermetic-offline`
  is `deferred` (nothing external to seam).

- **D11 — One eval file, three cases.** `evals/cases/stack-charter-judge.md` follows the
  `north-star-judge.md` shape: each case gives the judge an input and a FAIL condition.
  `JUDGE-TRIPPED` pairs a real falsifier match with a keyword-overlap decoy that must **not**
  fire — a gate that cries wolf gets ignored, so false positives are as much a FAIL as misses.
  Constrained by: `JUDGE-TRIPPED`, `JUDGE-COHERENCE`, `JUDGE-HEDGE-COST`.

## Components / modules

- **`memory/stack/stack.md`** → the harness's own charter (D1, D7). Exposure header + pins.
- **`memory/stack/base/pin-template.md`** → canonical pin form, field semantics, worked
  examples inside fenced blocks (D4 depends on the fencing).
- **`memory/stack/base/README.md`** → the reversal-cost inclusion test, the hedge admission
  test, the two pin kinds, and the S0-scales-scope-not-rules / floor-does-not-scale statements.
- **`scripts/stack/engine.py`** → `pin-valid` · `exposure` · `guards` (D2). Reference
  implementation, stdlib only, mirroring `scripts/north-star/engine.py`.
- **`.claude/commands/stack.md`** + **`.claude/skills/stack/SKILL.md`** → the seven-step
  elicitation procedure (spec req. 8), including the blast-radius questions and the
  "I don't know" → `PROVISIONAL` + mandatory `Hedge` path.
- **`.claude/commands/plan.md`** → the fail-closed guard: three verdicts, no silence, absent
  charter refusal, `PASS` must cite pins, `UNPINNED`-with-stance bounces to `/distill` (D6).
- **`.claude/skills/distill/SKILL.md`** → step 1 additionally injects `[stance]` pins' `Injects`
  rows; new note describing the re-freeze on a `/plan` bounce.
- **`.claude/skills/verify/SKILL.md`** → runs `engine.py guards` and requires each exit 0 (D3).
- **`.claude/skills/wow-report/SKILL.md`** → two charter-health signals (`WOW-HEALTH`).
- **`scripts/vendor.sh`** → KEEP/SEED entries + the `CLAUDE.md` `## Stack` stub rewrite (D9).
- **`docs/workflow.md`**, **`CLAUDE.md`**, **`README.md`** → `/stack` placed in the loop.
- **`tests/check_92_stack.sh`** → the 18 deterministic criteria, hermetic fixtures (D10),
  including the `GUARD-RUNS` negative fixture (D5) and the code-span-aware `NO-PRESCRIBE` scan
  (D4). Sourced automatically by `run.sh`.
- **`evals/cases/stack-charter-judge.md`** → the three judge cases (D11).

## Risks

- **The guard cannot gate its own feature.** → Mitigation: declared as a bootstrap exception
  above, with two concrete pre-close obligations (seed the charter, run the finished guard
  retroactively at `/uat`) so the exemption does not become a permanent hole.
- **`NO-PRESCRIBE` fails on its own documentation.** The template must name real tools to be
  useful. → Mitigation: D4 — strip fenced blocks and inline code spans before matching, reusing
  the `check_90` fix. If the scan is not span-aware it will either fail spuriously or be
  weakened to uselessness.
- **Vacuous Guards.** A stance Guard that inspects a non-existent path is green by construction
  — the exact theater Principle 2 rejects. → Mitigation: D5 — every Guard is proven against a
  violating fixture as well as a clean one.
- **Ceremony outgrows value.** A third `memory/` store plus a workflow step is real friction,
  and `alignment.md` recorded that `frictionless-adoption` moves the wrong way. → Mitigation:
  `S0` scales elicitation depth; `WOW-HEALTH` emits the evidence. **This risk is not resolved by
  this feature** — it is a prediction `/retro` must rule on, with `N=1` at close.
- **The `/plan`→`/distill` bounce is a new workflow loop.** No other step sends the flow
  backwards, and an adopter could read it as a dead end. → Mitigation: `PLAN-BOUNCE` asserts the
  path is documented in *both* `plan.md` and the `distill` skill, so it is discoverable from
  either side.
- **`engine.py` reads as "the harness now requires Python".** → Mitigation: it is a *reference*
  engine under the same doctrine as 006, the adopter may reimplement it, and the posture is
  pinned as `S1` with `NO-PRESCRIBE` as its enforcing Guard — the harness's own claim is checked
  by the harness's own mechanism.
- **Judge false positives on `TRIPPED`.** A gate that fires on keyword overlap becomes noise and
  gets ignored, which is worse than no gate. → Mitigation: D11 — the eval case pairs every true
  match with a decoy the judge must not fire on.
