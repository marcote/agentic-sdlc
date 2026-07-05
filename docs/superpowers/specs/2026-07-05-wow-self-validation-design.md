# Design — WoW Self-Validation (`003-wow-self-validation`)

date: 2026-07-05 · status: approved in brainstorming, pending plan

## Problem

The harness proposes a Way of Working (WoW): `distill → plan → contract → tasks →
implement → verify → uat`, with deterministic gates, coverage as the source of truth, and
`/align` as the Measurability Gate. But **nothing validates that this WoW works**. An SDLC
that preaches discipline but does not submit itself to it is unproven.

The goal: for the SDLC to be **dogfooding** — that we self-validate the WoW we
propose. Chosen in brainstorming: **closed loop** (conformance + outcome +
self-improvement), with evidence produced by the **agentic part** of the flow (not by
human diligence), to eliminate human error.

### Honest Constraint: N=1

A methodology cannot be A/B-tested against itself in a single repo — there is no control
group. Therefore "outcome" does not rely on cross-feature statistics, but on **a falsifiable
claim per feature**: `/align` declares a measurable prediction up front, and the retro
issues the verdict on that prediction. The WoW self-validates feature by feature.

## Guiding Principle: the `align ↔ retro` column

Every measurable prediction that **opens** `/align` is **closed** by the retro. The retro
is not a loose artifact about "how it went"; it is the structural counterpart of the
Measurability Gate.

```
brief.md
  │
/align ──────────► alignment.md        PREDICTION: "pillar X advances via signal Y;
  │                 (verdict, scores,               scores ≥ threshold"
  │                  mapping, orphans)
  ▼
distill → contract → tasks → implement
  │
/verify + /uat ──► verification/reports/<feature>   the PRODUCT works
  │                 (BUILD ∧ TRAJECTORY ∧ UAT ∧ coverage 100%)
  ▼
/retro ──────────► specs/<feature>/retro.md   VERDICT on the align prediction
                                              + method signals (WoW)
```

### Extension of the DONE contract

```
feature DONE ⟺ BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100% ∧ retro ✅
```

`retro ✅` = the retro closed all three faces, **not** that "everything went well". A retro
that documents that the align prediction **failed** is a valid and closed retro — in fact
the most valuable, because it feeds the self-improvement loop.

## Components

### 1. `specs/_template/retro.md` — the artifact (three faces)

Lives co-located with the feature (respects "one feature = one folder"). Each field anchored
to an existing artifact so the agent can **derive** it, not invent it.

```markdown
# Retro — <feature> @ <commit>
closes: alignment.md · verification/reports/<feature> · date: <YYYY-MM-DD>

## Face A — Mission (closes the /align prediction)
Source: specs/<feature>/alignment.md

| Pillar (mapping) | Predicted signal | Verdict | Evidence (MANDATORY locator) |
|---|---|---|---|
| pillar-x | <North Star signal> | ✅ moved / ❌ did not move / ⏳ not yet observable | <value/SHA/coverage-row/URL — no prose> |

- Align calibration: did the predicted scores (pillarFit/scope/mission) hold up?
- Mission verdict: confirmed | refuted | pending-observation | n/a
  - if confirmed | refuted → the Evidence cell CANNOT be empty (Layer 2)
  - if pending-observation → re-check trigger: <when/what signal to look at>
  - if n/a → mandatory reason: <why it does not close against a signal>

## Face B — Method (validates the WoW) — DERIVED from artifacts, not drafted (Layer 1)
Each field shows its `[deriv: <locator>]` — where the figure came from. Without locator = invalid.

- Gaps caught by /distill: <N> `[deriv: coverage.md rows + git log from distill phase]`
- RED→GREEN discipline: <yes/no + exceptions> `[deriv: coverage.md state history + git]`
- Post-/verify rework: <N> · post-/uat: <N> `[deriv: gaps routed in verification/reports/<feature>]`
- Human escalations: <N> `[deriv: trace/git]` — <why>
- Friction from the WoW itself: <what got in the way or was missing> (qualitative; the only free-judgment field)

## Face C — Loop (self-improvement) — bridge, not subsystem
- Candidate rules → constitution: <rule or "none">
- Candidate amendments → North Star: <proposed ADR or "none">
```

**Decisions:**
- `pending-observation` is first-class: many `signal`s (e.g., "↑ conversion") cannot
  be measured on the closing day. Instead of faking certainty, deferred verdict with
  trigger. Does not block closure.
- `n/a` is a first-class verdict (not a hack): a pure refactor or tooling legitimately
  does not move any signal. **Requires mandatory reason** (avoids silent escape).
- Face B is mostly **auto-derivable** from artifacts (coverage, git, report), not from
  memory — that is where the agentic part eliminates human error.
- Face C only **proposes**; applying rules/ADRs follows the existing mechanisms
  (`memory/constitution/update-checklist.md`, `memory/north-star/base/amendment-protocol.md`).

### 2. `tests/check_90_retro.sh` — deterministic enforcement

Respects the rule "on-demand verification, no blocking git hooks per commit": the
enforcement lives in **CI** (`tests/` runs in `.github/workflows/verify.yml`), not a git
hook.

Two levels:
- **Template** (extends `check_20`): `specs/_template/retro.md` exists with the headers
  for all three faces.
- **Per-feature closure** (`check_90`), uniform logic, **no branches by feature number**:

```
for each specs/NNN-*/ whose verification/reports/NNN-* shows the DONE verdict:
  assert retro.md exists
  assert no unfilled placeholders _(…)_ / <…>
  assert mission verdict ∈ {confirmed, refuted, pending-observation, n/a}
  assert if verdict == n/a  →  there is a non-empty reason
  assert if verdict ∈ {confirmed, refuted}  →  Evidence cell not empty          (Layer 2)
          and "looks like" a locator (contains path / SHA / number / URL, not just prose)
  assert each Face B field carries its [deriv: <locator>]                            (Layer 1)
if NOT DONE: skip (feature in-flight)
```

Materializes `retro ✅` deterministically in CI: a feature declared DONE cannot be merged
without a complete retro. **Honest limit:** the check verifies presence + structure + verdict
token, **not the honesty** of the content — that is upheld by the agent running `/retro`
(the agentic bet).

**No hardcoding:** the bootstrap exemption (`002`) does not live in the test but as data
(`retro.md` with `n/a` + reason). `grep -r "n/a" specs/*/retro.md` lists all exemptions
with their reason. Zero housekeeping.

### 3. `/wow-report` — aggregation (observability)

On-demand skill (pattern `/verify`, `/uat`) that reads all `retro.md` + `alignment.md`
+ verification reports and **regenerates** `verification/wow-report.md` (committed
snapshot). Structure:

```markdown
# WoW Report — @ <date/commit>   (generated snapshot; do not edit manually)

## 1. Mission — is each North Star pillar actually being served?
   mapping (align) × signal verdict (retro) per pillar.
   pillar with features that promised to serve it but no signal moved = measurable DRIFT.

## 2. Pending re-checks (worklist)
   the pending-observation items with their triggers; marks the overdue ones.

## 3. Method — does the WoW add value? (N=<n>, small sample, no stats)
   per-feature: gaps caught, RED discipline, rework, escalations; + friction themes.

## 4. Loop — does the WoW improve itself?
   candidate rules proposed vs landed in constitution;
   amendments proposed vs approved (ADR).

## 5. Theater smells (human spot-check)  (Layer 4)
   flags suspicious retros: empty Evidence cells · all-green
   (zero gaps + zero rework + zero friction) · overdue pending-observation items
   never re-checked. An overly clean retro IS a signal.
```

**Decisions:**
- The center of gravity is the **rollup by pillar (§1)**: it answers the deepest question —
  is each North Star pillar actually advancing, or was it just promised? Measurable drift.
- `pending-observation` becomes an **actionable worklist (§2)**; it collects the debt of
  deferred measurement. Not automated with a scheduler now (YAGNI); just made visible.
- `/wow-report` **observes, never gates**. `check_90` is the enforcement mechanism (CI);
  the report is read-only synthesis for the human.
- Small N honesty: the report explicitly says "N=n, no statistics" and shows per-feature +
  totals, without faking trends.

### 4. The `/retro` skill

Command+skill pair (same pattern as `/align`):
- `.claude/commands/retro.md` (thin): invokes the `retro` skill; requires the feature's
  verification report in DONE; writes `specs/<feature>/retro.md`.
- `.claude/skills/retro/SKILL.md` (procedure — order `derive → self-challenge →
  write`, not the other way around):
  1. **Derive first** (Layer 1): every figure in Face B comes from an artifact with its
     `[deriv: <locator>]` (`coverage.md`, git, `verification/reports/<feature>`). Do not
     type figures from memory.
  2. read `alignment.md` → for each pillar in the `mapping`, find its `signal` and issue
     the verdict **with mandatory evidence locator** (Face A, Layer 2). Without locator for
     a `confirmed`/`refuted` → do not write it: it is `pending-observation`.
  3. **Adversarial self-challenge** (Layer 3): before writing, argue AGAINST your own
     draft — "the report says 0 rework: verify against `git log`; says the pillar-fit of
     align was exact: argue the opposite". Only what survives the challenge gets written.
     (Future reinforcement, YAGNI now: delegate the challenge to a separate skeptic
     subagent, not the one that drafted.)
  4. propose rules/ADRs (Face C);
  5. if a signal is not measurable at closure → `pending-observation` + trigger, or `n/a` +
     reason.

## Anti-theater: defense in depth (4 layers)

The greatest design risk: that the agent fills in the retro **just to comply**. A
deterministic check **cannot prove honesty** (a grep passes with plausible filler —
Goodhart). We do not solve this with a single defense but by shrinking the space where
theater can hide. Four layers, from cheapest to most powerful:

1. **Derive, don't write** (Face B + skill step 1). Each Method field is a query against
   an artifact (`coverage.md`, git, report) with its `[deriv: <locator>]`.
   If the field is a derived figure, there is nothing to "invent to comply": the number
   is what it is. Leaves only one free-judgment field (friction), intentionally.
2. **Evidence-or-it-didn't-happen** (Face A + `check_90`). A `confirmed`/`refuted`
   verdict requires a non-empty Evidence cell in locator form (path/SHA/number/URL). This
   **is checkable** in CI: unfalsifiable prose is forbidden. Without evidence → the honest
   verdict is `pending-observation`.
3. **Adversarial self-challenge** (skill step 3). The same agent that built has a bias
   toward self-grading; the procedure requires it to argue against its own draft before
   writing. Reuses the "judge over the trace" pattern that `/verify` already has (trajectory
   eval). Future reinforcement: separate skeptic subagent (YAGNI now).
4. **The report smells what is too clean** (`/wow-report` §5). An all-green retro is
   itself a signal; the aggregator flags empty evidence, all-green, and expired
   `pending-observation` for human spot-check. The re-check trigger is what **collects**
   on a `confirmed` that later cannot be sustained.

**The honest truth:** this is defense in depth, not a proof. The residual — that the agent
genuinely evaluates — remains the agentic bet. But between deriving instead of writing,
mandatory and checkable evidence, self-challenge, and the report that smells what is clean,
the space for theater is left small and uncomfortable.

## Recursive Bootstrap

- `/align` could not gate `002` because it runs **at the start** of the flow. `/retro`
  runs **at the close** → by the time `003-wow-self-validation` is closing, `/retro`
  **already exists**. Therefore `003` **retros itself**: the first real ledger entry is
  this feature validating itself with its own capability.
- **No bootstrap needed for `002`.** `check_90` detects "closed" by *"has a report with
  DONE verdict"* (`BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100%`).
  `002` only has `verification/reports/002-north-star-judge.md` (an eval result,
  not a DONE verdict) → the uniform detector **does not flag it**; it remains "in flight"
  and is skipped. No hardcode and no filler `n/a` — cleaner than an exception. The
  `n/a` verdict remains a valid state for future real features (pure refactor, tooling),
  with its mandatory reason. `001-example` is a fixture, not a real feature.

## Constraint: template repo vs adopter repo

This repo is the harness **template**: its `north-star.md` is a non-schema-valid
placeholder. `/align` is fail-closed → **it does not truly run here**. Therefore the
retro's **Face A (Mission)** can only be closed with real data in an **adopter repo**
(with its own North Star). In the template repo:
- Face A = `n/a` (+ reason: "North Star placeholder; align↔retro runs in adopter").
- Face B (Method) = real and derived (truly dogfooded when building features here).
- The full machinery (template, skills, `check_90`, `/wow-report`) is exercised and
  tested all the same; the only thing deferred to the adopter is the actual signal
  measurement.

## File Manifest

| Action | File |
|---|---|
| new template | `specs/_template/retro.md` |
| new command | `.claude/commands/retro.md`, `.claude/commands/wow-report.md` |
| new skill | `.claude/skills/retro/SKILL.md`, `.claude/skills/wow-report/SKILL.md` |
| new check | `tests/check_90_retro.sh` |
| edit checks | `check_20` (+retro template), `check_40` (+retro, wow-report), `check_50` (+retro, wow-report) |
| edit DONE contract | `CLAUDE.md`, `docs/workflow.md`, `verification/verification-report.md` |
| generated (committed) | `verification/wow-report.md` |
| bootstrap | — (none: `002` has no DONE report → `check_90` skips it; no hardcode or `n/a`) |
| dogfood | `specs/003-wow-self-validation/` complete (brief→align→…→own retro) |

## Non-goals (YAGNI)

- **No** scheduler/automation for `pending-observation` re-checks (visibility in report
  only).
- **No** cross-feature statistics / trend dashboards (N=1 honestly prohibits it).
- **No** blocking git hook (enforcement is CI, on-demand).
- **No** new deterministic engine: `check_90` is a grep over artifacts, like the rest.

## Risks

- **Low-quality retro** (the agent fills in to comply): see "Anti-theater: defense in
  depth (4 layers)". The check cannot prove honesty — this is explicit.
- **`n/a` abused** as an escape: mitigated by the mandatory reason + grep visibility.
- **`pending-observation` that never gets re-checked**: mitigated by the worklist with
  "expired" items in `/wow-report`.
