---
name: verify
description: On-demand verification of a feature. Runs output + trajectory eval and emits the verification-report. Use when closing a feature's implementation.
---

# Verify

## Procedure
1. Copy `verification/verification-report.md` to `verification/reports/<feature>-<ref>.md`.
2. **Output eval (BUILD):** run the deterministic tests linked in `coverage.md`.
   Task success = green/total. Threshold 100% (non-negotiable).
3. **Guards (BUILD, cont.):** obtain every declared check — from pins of **either** kind — with
   `python3 scripts/stack/engine.py guards memory/stack/stack.md`, execute every command, and
   require exit 0. Run them **by name only** — never inspect or second-guess what a `Guard`
   checks; the harness asserts that a named, runnable check exists and passes, which is what
   lets a project's own stances be enforced without the harness prescribing any stack. A
   `Guard` that cannot fail on a violating tree is vacuous and counts as a FAIL, not a pass.
   No charter → no guards to run; that is not a failure, but say so rather than reporting green.
4. **Declared mutations (BUILD, cont.):** run `bash scripts/mutate.sh run --tests tests` and
   require exit 0. Each criterion that declares a `[mut$ … $]` edit must FAIL under it; one that
   survives is reported by name with the edit that failed to break it. This is `check-can-fail`
   executed rather than asserted.

   **Why here and not inside `tests/run.sh`:** the runner re-runs check files, and a check file
   that invoked the runner would re-enter it once per mutation — through `check_96`, which already
   re-runs the whole suite, the cost multiplies by the number of declarations. Mutations run where
   `Guard`s run: at `/verify` and in CI.

5. **Mutation coverage (BUILD, cont.):** run
   `bash scripts/mutate.sh coverage --tests tests --spec specs/<feature>` and require exit 0. Every
   criterion the feature's own `coverage.md` obliges — origin `project`, a deterministic status, and
   a linked test that resolves — must carry a `[mut$ … $]` declaration. Exit 1 names the criteria
   that carry none; exit 2 means a row names a check file that cannot be resolved, which is a defect
   in the matrix rather than a missing mutation.

   Then run `bash scripts/mutate.sh coverage --tests tests --all` and **record its TOTAL line in the
   report**. That is the standing debt across every closed feature, re-derived at this ref rather
   than read from a stored figure — a snapshot written into a report goes stale as features are
   added, and a stale number is worse than none.

   **Scope:** the gate binds the feature being verified. It does not gate closed features, and there
   is no baseline or exemption list — features from 018 on already sit at zero, so the forward-only
   line needs no record to maintain.

6. **Trajectory eval:** score against `evals/rubric.md` (tool use, skipped steps,
   hallucination). A flow that skipped verification is FAIL even if the build passes.
7. Update the states in `coverage.md` (🔴→🟢) and complete the Verdict.
8. If BUILD/TRAJECTORY fail → IMPLEMENTATION gap → go back to implement.
   Do NOT call UAT or closing non-deterministic evals from here.
