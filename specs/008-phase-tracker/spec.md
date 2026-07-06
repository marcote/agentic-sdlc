# Spec — Derived phase-tracker (`scripts/status.sh`)

> WHAT is built. Produced by `/distill` from `brief.md`. Frozen when `coverage.md` has no
> orphan rows. Gate: `alignment.md` verdict = `aligned` (run on the 006 engine).

## Functional requirements

1. **`scripts/status.sh <feature>`.** Read-only. Resolves `specs/<feature>/` and
   `verification/reports/<feature>-*.md` relative to the repo root (CWD). Dependency-free
   (bash/coreutils + `python3` if needed). Prints a phase report; **never mutates**.
2. **Phase-done derivation (authoritative source per phase).** For each pipeline phase, the
   done signal is derived — not hard-coded — from:

   | Phase | Command | Done ⟺ |
   |---|---|---|
   | brief | (intake) | `brief.md` exists AND non-placeholder |
   | align | `/align` | `alignment.md` exists AND contains a `Verdict` line |
   | distill | `/distill` | `spec.md` + `acceptance.md` + `coverage.md` exist AND non-placeholder |
   | plan | `/plan` | `plan.md` exists AND non-placeholder |
   | contract | `/contract` | `coverage.md` has ≥1 criterion beyond `no contract` (a `🔴`/`🟢`/`✅` row) |
   | tasks | `/tasks` | `tasks.md` exists AND non-placeholder |
   | implement | (implement) | every deterministic criterion in `coverage.md` is `🟢` or `✅` (no `🔴`/`no contract`) |
   | verify | `/verify` | a `verification/reports/<feature>-*.md` exists with `BUILD: ✅` |
   | uat | `/uat` | that report has `UAT: ✅` |
   | retro | `/retro` | `retro.md` exists AND non-placeholder AND the report has `retro: ✅` |

   *non-placeholder* = the artifact has no unfilled template markers (`_(...)_` / `<...>`),
   the same test the retro gate (`check_90`) uses.
3. **Current phase + next command.** Report the **current phase** = the first phase (in
   pipeline order) that is not done, and the **next command** to run for it. If all phases
   are done → report the feature **DONE**.
4. **Anomaly detection.** If any phase is done while an **earlier** phase is not (a skip /
   out-of-order), flag it as a `⚠ anomaly` line naming the offending phases.
5. **Coverage gaps.** Surface, from `coverage.md`: criteria not yet `🟢`/`✅` (still
   `🔴`/`no contract`) and orphan rows (empty **Pillar** cell).
6. **Exit code.** Exit `0` when the state is coherent (including a normal in-progress
   feature); exit **non-zero only on a detected anomaly** (req. 4) — so a WIP feature does
   not "fail", but CI/scripts can catch skips.
7. **Shared DEPFREE helper (candidate B).** Factor the dependency-free assertion into a
   **shared, invocation-aware helper in `tests/lib.sh`** that distinguishes a real toolchain
   *invocation* from a test-command *string* (excludes comment/echo/data lines). `check_82`,
   `check_84`, `check_95`, and the new `check_86` all use it — no duplicated grep.

## User stories

- As the **agent/maintainer** I want the SDLC to compute a feature's phase state so that the
  tracklist is authoritative, not inferred by hand (a discipline leak).
- As an **adopter** I want to see where a feature is and what to run next so that the
  workflow is self-navigating.
- As **CI** I want a non-zero exit on an out-of-order pipeline so that skips are caught.

## Edge cases (80% problem)

- **Fresh scaffold (`cp -r _template`):** every artifact exists but as a placeholder →
  every phase reports PENDING (not done). This is why presence-only is insufficient.
- **Coverage with a red criterion:** implement is PENDING even though `plan.md`/`tasks.md`
  are filled — the authoritative source (coverage states) overrides doc presence.
- **Out-of-order:** `retro.md` filled but `coverage.md` still has a `🔴` → `⚠ anomaly` +
  non-zero exit.
- **Missing report:** verify/uat/retro pending if no `verification/reports/<feature>-*.md`.
- **Unknown feature:** `status.sh <nonexistent>` → a clear error, non-zero exit (not a crash).

## Open questions / deferred

- **`/next` or `/status` command wrapper:** deferred (brief out-of-scope) — a thin command
  can wrap the script later.
- **Global/multi-feature dashboard:** deferred — `wow-report` covers cross-feature retro
  aggregation; `status.sh` is per-feature.
- **Parsing coverage states in bash vs python3:** resolved in `/plan` (grep the emoji /
  `no contract` markers; `python3` only if a table parse is needed).
