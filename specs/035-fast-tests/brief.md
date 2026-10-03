# Brief — 035-fast-tests

## Objective
The owner fears the loop gets slow as tests grow: five minutes of code, twenty of tests, twenty more to run them. The numbers say the risk is real. The pytest suite takes 78 s for 116 tests, and a day earlier it had 19. Each build or accept test costs 2–4 s, mostly because each subprocess starts through `uv run`. T0 starts pytest once per example. And one test failed in CI on PR #42 and passed on a re-run, so it is flaky. The owner wants test time measured, kept under a budget, and cut now.

## Done means
- The result page shows the suite time and the test time of each build run.
- Accept fails when the suite runs over a budget set in `harness.toml`.
- The suite runs in about 20 s or less.
- The flaky test has its root cause removed.

## Out of this slice
- Onboarding and `/status` (slice 036).
