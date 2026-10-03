# Brief — 031-clear-sdlc

## Objective
The owner wants to review the whole SDLC before using it in the trading repo. The owner found `distill` still named in `evals/` and asked whether that is correct. It is not: spec 029 pruned the old commands, but a second layer of the 12-step flow survived. That layer is `evals/`, the `verification/` templates, the north star's alignment section and amendment protocol, and engine commands nobody calls. The owner also said the workflow "is not clear today", and wants it documented with interfig.

## Done means
- No live file names a step that no longer exists, and a check fails if one comes back.
- The north-star engine and the stack engine keep only the commands the four-step flow uses.
- `docs/workflow.md` shows the workflow, the build loop and accept as interfig figures, with little text.
- The README points to it.

## Out of this slice
- The trading repo.
- New behaviour in build or accept.
- The B23 minors.
