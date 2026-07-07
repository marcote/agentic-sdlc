# Retro — 004-ci-amendment-gate @ cdf1abc

closes: `specs/004-ci-amendment-gate/alignment.md` · `verification/reports/004-ci-amendment-gate.md` · date: 2026-07-05

> Closes the measurable prediction opened by `/align` (align↔retro column). A feature is
> not DONE until this retro closes its three faces. Design:
> `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.

## Face A — Mission (closes the /align prediction)
Source: `alignment.md` (objective→pillar mapping) + `north-star.md` (signal per pillar).

| Pillar (mapping) | Predicted signal | Verdict | Evidence (locator REQUIRED) |
|---|---|---|---|
| real-enforcement | Gates block the close when a condition is missing; violations caught before the merge | ✅ moved | PR #2 check `amendment-gate` fail → `mergeStateStatus: BLOCKED`; direct push rejected `GH006`; `verification/reports/004-ci-amendment-gate.md` §4 |
| measurable-impact | Gaps caught early and late rework avoided; high = discipline prevents, does not bureaucratize | ✅ moved | Narrow block verified (DEV-UNBLOCKED 🟢 in `coverage.md`); the gate caught real drift pre-merge in PR #2 without slowing the feature throughput |
| agnostic-portability | The contract (schema, gates, artifacts) stays intact when vendored onto an arbitrary repo/stack | ⏳ not yet observable | Dep-free deliverable landed (DEP-FREE 🟢 in `coverage.md`; gate = bash+python3+Actions), but integrity-when-vendoring was not walked in this feature |

- **Align calibration:** accurate. pillarFit=4 nailed `real-enforcement` as the central fit (the real block confirms it) and marked `agnostic-portability` as indirect (4, not 5) — which materialized as `pending-observation`, exactly the caution that the 4 anticipated. scope=4 on the "per-stack deterministic engine" edge resolved well: the harness's *own* gate was built in bash, not the adopter's engine. mission=4 holds: measurable effect demonstrated on the `real-enforcement` signal. Honest nuance: including `agnostic-portability` in the mapping knowing its signal would not close this feature was somewhat generous.
- **Mission verdict:** confirmed
  - Closed by the central pillar `real-enforcement` with hard evidence (PR blocked + push rejected, gate live on `main`). `agnostic-portability` remains as an open sub-observation.
  - **re-check trigger** (portability): when vendoring the harness onto a real repo/stack, verify that `amendment-gate.yml` + `scripts/amendment-gate.sh` run intact (python3 stdlib present, `--range` derives correctly) without per-stack adjustments.
  - **re-check CLOSED (2026-07-06):** vendored onto a real persistent repo (`~/Code/porfolio-doctor`) via the live `curl|bash` bootstrap (source `@ c052a42`). The contract ran **intact and dependency-free with zero per-stack tweaks**: `engine.py schema-valid` exit 0 on the seeded North Star, `scope-reject`/`align-verdict`/`sets-changed` correct, and `amendment-gate.sh --files` returned `not applicable` (exit 0) orchestrating the vendored engine. Residual nuance: that repo is *stackless*, so `vendor.sh` stack-detection defaulted to `TODO` (by design) rather than matching a real manifest — the `--range` git-derivation path is still only exercised in the hermetic suite, not on this target. agnostic-portability now has **real-repo evidence**, no longer synthetic-only.

## Face B — Method (validates the WoW) — DERIVED from artifacts, not authored
Each field carries its `[deriv: …]` marker — the locator of where the figure came from.

- **Gaps caught by /distill:** 6 edge cases + 1 reframe `[deriv: spec.md "Edge cases (80% problem)" 6 bullets @ 3d13431; 12 criteria in coverage.md]` — the key ones: set-semantics (reformat ≠ change), schema-invalid-even-with-ADR, prose/threshold does not require ADR, editing an existing ADR does not count as `hasAdrFor`, and the DEP-FREE reframe toward "bash+python3 stdlib" (python3 is a system interpreter, not an installable dep) @ 7c3ad73.
- **Gap caught by the /tasks GATE:** 1 `[deriv: git faee99b + coverage.md note]` — DEP-FREE was green-by-construction (repo guardrail, no real RED); the machine-checkable gate bounced it and it was tied to the deliverable to give it a genuine RED phase.
- **RED→GREEN discipline:** yes, no exceptions `[deriv: coverage.md — 10 rows 🔴 red @ 8ff6cd2/faee99b, → 🟢 green @ e8c3b89; suite 15 FAIL in contract → 0 FAIL after impl]`.
- **Rework post-/verify:** 0 · **post-/uat:** 0 `[deriv: verification/reports/004-ci-amendment-gate.md §4-5 — BUILD/TRAJECTORY green on first pass, UAT with no product gap]`.
- **Escalations to human:** 1 `[deriv: session trace — AskUserQuestion "UAT scope"]` — outward-facing decision (real GitHub config); the user chose "full real walk".
- **Friction from the WoW itself:** the state machine `no contract → red → green` assumes every deterministic criterion has a RED→GREEN arc, but an **invariant** criterion (must-not-regress, like DEP-FREE) does not — it had to be tied to a deliverable so the `/tasks` gate would not reject it. Also, *GitHub config* criteria (AMEND-BLOCK-REAL/PUSH) are not hermetically unit-testable: they required a real outward-facing walk, which the harness does not validate in `tests/run.sh`.

## Face C — Loop (self-improvement)
- **Candidate rules → constitution:** an **invariant criterion (must-not-regress)** must be tied to an observable deliverable to have a genuine RED phase in `/contract`; `green-by-construction` does not count as red and the `/tasks` gate must reject it (as happened with DEP-FREE @ faee99b). Apply via `memory/constitution/update-checklist.md`.
- **Candidate amendments → North Star:** none — this feature operationalized the `real-enforcement` signal, did not touch `pillars`/`scope`. Adjacent note (constitution, not North Star): refining the literal wording of principle 4 toward "productivity-first" remains deferred (recorded in `spec.md` and in the constitution D1 delta).
