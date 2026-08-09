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
4. **Trajectory eval:** score against `evals/rubric.md` (tool use, skipped steps,
   hallucination). A flow that skipped verification is FAIL even if the build passes.
5. Update the states in `coverage.md` (🔴→🟢) and complete the Verdict.
6. If BUILD/TRAJECTORY fail → IMPLEMENTATION gap → go back to implement.
   Do NOT call UAT or closing non-deterministic evals from here.
