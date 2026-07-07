# Verification Report — 009-bootstrap @ a572cfc (branch 009-bootstrap, working tree)

spec: spec.md v1 · date: 2026-07-06 · constitution: base v1 + project v1

## 1. Coverage snapshot
_(from coverage.md — 10 deterministic + 1 UAT)_

| Criterion | State | Linked test/eval |
|---|---|---|
| FETCH | 🟢 green | `check_88_bootstrap.sh` |
| PLAN-FIRST | 🟢 green | `check_88_bootstrap.sh` |
| APPLY-YES | 🟢 green | `check_88_bootstrap.sh` |
| NOTTY-ABORT | 🟢 green | `check_88_bootstrap.sh` |
| CLEANUP | 🟢 green | `check_88_bootstrap.sh` |
| GIT-REQUIRED | 🟢 green | `check_88_bootstrap.sh` |
| DROP-SELF | 🟢 green | `check_88_bootstrap.sh` |
| DEPFREE | 🟢 green | `check_88_bootstrap.sh` (invariant tied to deliverable) |
| HANDOFF-DOC | 🟢 green | `check_88_bootstrap.sh` |
| SELF-CHECK | 🟢 green | `tests/run.sh` + `check_88_bootstrap.sh` |
| CONFIRM-TTY | deferred → uat | `verification/uat-checklist.md` (interactive) |

## 2. Output eval (BUILD) — deterministic
`bash tests/run.sh` → **234 PASS / 0 FAIL** (was 223 PASS / 10 FAIL at `/contract` RED).
All 10 `check_88_bootstrap.sh` deterministic criteria pass; the rest of the suite (223) stays
green — no regression from the one-line `vendor.sh` DROP edit or the doc changes.

**Task success: 10/10 = 100%** ✅ (CONFIRM-TTY excluded — UAT-observed, no honest hermetic RED).

## 3. Trajectory eval — LM judge over the trace

- **Tool use (vs `tasks.md`):** ✅ T1–T7 executed in order. The wrapper reuses `scripts/vendor.sh`
  unchanged for classification/stack/provenance (D1); the only `vendor.sh` edit is the one-line
  DROP addition (T5/D8). Hermetic test uses the `HARNESS_REPO` local-checkout seam (offline) and
  the `TMPDIR` sandbox for cleanup — no network, no frameworks.
- **Trajectory compliance:** ✅ no steps skipped. Full flow walked:
  `/align` (aligned, engine-run) → `/distill` (grilling: North Star validated + 1 blocking
  ambiguity resolved — the `--yes`/no-TTY consent model) → `/plan` → `/contract` (**proved RED**:
  10 FAIL before any implementation) → `/tasks` (test-first gate passed) → implement → `/verify`.
  RED→GREEN arc is genuine, not green-by-construction.
- **Hallucination: 0.** No invented deps/APIs. `git` + bash/coreutils only (`assert_dep_free`
  green); reused real paths (`scripts/vendor.sh`, `scripts/north-star/engine.py`) verified to
  exist; no manifest introduced.

## 4. UAT — against acceptance.md + the brief objective
Walked against the OBJECTIVE (from-zero adoption), not just the spec:

- **Objective — one gesture lands the harness (UAT-1):** from an **empty `git init` repo**, a
  single `bootstrap.sh --yes` (sourcing the harness offline via `HARNESS_REPO`) landed the full
  governance layer — `.claude/commands/align.md`, `scripts/north-star/engine.py`,
  `memory/north-star/north-star.md` (SEED), `CLAUDE.md`, `scripts/test.sh` — stamped
  `.harness-provenance`, and cleaned up the temp clone. Batteries-included, no manual clone. ✅
- **CONFIRM-TTY (UAT-2) — interactive `[y/N]` over a real pty:** the prompt
  `Apply the harness to <target>? [y/N]` appears; **`y` → APPLIED**, **`n` → ABORTED** (nothing
  written). The one deterministically-untestable criterion, confirmed by hand. ✅
- **All 10 deterministic criteria:** ✅ uat (BUILD green + walked).

**Success metric moved?** Yes — `frictionless-adoption`'s signal is *steps/time to adopt*. From
"clone the harness by hand → find its `vendor.sh` → run it" (multi-step, undocumented folklore)
to a single documented `curl … | bash`. No product gap → no route to `/distill`.

## 5. Verdict
BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% (11/11) · retro: ✅ — **DONE**
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/009-bootstrap/retro.md` (closes the measurable prediction from `/align`).
Gaps routed: none (no BUILD/TRAJECTORY/UAT gap).
