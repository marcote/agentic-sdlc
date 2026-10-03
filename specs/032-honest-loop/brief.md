# Brief — 032-honest-loop

## Objective
The owner asked what we keep getting wrong. Slice 031 showed three failures. Its delete list was built by reading, not by tracing what depends on each path, so it deleted pin S1's live guard. The implementer rule froze every file under `tests/`, not only the tests T0 froze, so build escalated on a legal edit. And the result page reported 1 intervention and 71k tokens, when the truth was 5 interventions and about 1.01M tokens. Re-runs overwrite the report.

The owner wants the loop to stop depending on the agent's memory for these. The impact of a deletion is computed before gate H1. The frozen rule is exact. And the metrics come from git and from every run.

## Done means
- A spec that removes a path fails the lint while a live file still refers to that path and the spec does not name that file.
- The implementer sees the real list of frozen tests, and may edit any other test.
- The result page counts every owner decision, and the tokens of every build run.
- Spec 031 records its true numbers.

## Out of this slice
- Memory in the repo (slice 033).
- Rebuilding a test when an example changes after T0, and slice-scoped test names (033 backlog).
