# Brief — 030-lead-time

## Objective
The owner is not happy with the speed of iteration, and wants to see it. Spec 029's result page said 1.7 h of lead time. The owner asked to review it: the number counted from the first spec commit, left out the design talk, and did not split the owner's time from the agents' time. The owner wants a lead time that runs from the brief to the merge, split by phase.

The slice also takes two minors from backlog B23 that can silently break build: the T0 commit lookup depends on git's regex mode, and examples added after T0 never get a failing test.

This is the first slice that runs through the new loop end to end, with real agents in build.

## Done means
- The result page shows lead time from the brief to the merge, and the time of each phase: brief to gate H1, gate H1 to the end of build, and build to the merge.
- Gate H1 approval is visible in git, so the phase split comes from git alone.
- With `grep.patternType=extended` set in git, a build re-run still resumes after T0.
- An example added to the spec after T0 gets a failing test before any task implements it.

## Out of this slice
- Lead time across several slices, or trends.
- The other B23 minors.
- Calibrating the token budget.
