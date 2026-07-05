---
name: verify
description: On-demand verification of a feature. Runs output + trajectory eval and emits the verification-report. Use when closing a feature's implementation.
---

# Verify

## Procedure
1. Copy `verification/verification-report.md` to `verification/reports/<feature>-<ref>.md`.
2. **Output eval (BUILD):** run the deterministic tests linked in `coverage.md`.
   Task success = green/total. Threshold 100% (non-negotiable).
3. **Trajectory eval:** score against `evals/rubric.md` (tool use, skipped steps,
   hallucination). A flow that skipped verification is FAIL even if the build passes.
4. Update the states in `coverage.md` (🔴→🟢) and complete the Verdict.
5. If BUILD/TRAJECTORY fail → IMPLEMENTATION gap → go back to implement.
   Do NOT call UAT or closing non-deterministic evals from here.
