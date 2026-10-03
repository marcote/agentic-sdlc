# Spec 035 — Fast tests

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

The pytest suite takes 78 s for 116 tests. A day earlier it had 19 tests. Most of the cost is process start: each script and each fake agent call starts through `uv run`, and T0 starts pytest once per example. Build runs tests many times per slice, so this cost grows with every slice. This slice measures test time, sets a budget, and cuts the start cost.

## 1. Glossary

| term | meaning |
| --- | --- |
| **suite time** | The seconds that the `[checks] suite` command takes in one accept run. |
| **suite budget** | The value `limits.suite_seconds` in `harness.toml`. |

## 2. Requirements

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| S1 | When accept writes the result page, the page shall show the **suite time** and the test time of each build run. | measurable-impact | E1 |
| S2 | If the suite time is over the **suite budget**, then accept shall fail and name both numbers. | measurable-impact | E2 |
| S3 | The tests and the fake adapter shall start scripts with the Python that runs them, not through `uv run`. | measurable-impact | E3 |
| S4 | When T0 checks its tests, build shall run them in one test run and read each example's result. | measurable-impact | E4 |
| S5 | The suite command shall run the pytest tests in parallel. | measurable-impact | E5 |
| S6 | The test `test_revert_drops_staged_code_of_escalated_task` shall not depend on timing or test order. | real-enforcement | judged, rubric R1 |
| S7 | The CI workflow shall run the `[checks] suite` command of `harness.toml`, not a command of its own. | real-enforcement | E6 |
| S8 | When build compares two failures of a task, build shall compare their failed test names, not the raw output. | measurable-impact | E7 |

Rubric R1 (for S6): the fix names the root cause in a code comment at the fix. It adds no sleep, retry or skip.

## 3. Examples

Each example becomes a test named `test_<id>_<words>`.

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | a slice whose build report has two runs with test times 12 s and 4 s | accept writes the page | the page has a `Suite` row with seconds, and a `Test time` row with `12 s, 4 s` |
| E2 | `suite_seconds = 1`, and a suite with one test that sleeps 2 s | accept runs | exit 1; the output names `suite took` and `budget 1 s`; `main` is unchanged |
| E3 | `harness.toml` and `tests/conftest.py` | the test reads them | the `fake` and `fake-judge` commands and the script helpers in `conftest.py` contain no `uv run` |
| E4 | a slice with examples E1 and E2, and a task command that appends one line to `.runs` each time it starts | build runs T0 | `.runs` has 1 line after T0 |
| E5 | `harness.toml` | the test reads `[checks] suite` | it contains `-n auto` |
| E6 | `.github/workflows/verify.yml` | the test reads it | it has no `pytest` command of its own; it runs the `suite` value read from `harness.toml` |
| E7 | two failure outputs of the same test, one with `[gw0]` and one with `[gw3]`, and different durations | build compares them | it reports them as the same failure |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: the suite time stays under the suite budget. Accept checks it on every slice (S2).
- reconciliation: the suite time before this slice was 78 s for 116 tests, measured on 2026-10-03.
- e2e run: accept on this slice reports its own suite time.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | tests and the fake adapter start scripts with the running Python (a `{python}` placeholder in `harness.toml`) | S3 | |
| T2 | T0 runs all example tests in one run and reads each result from the runner output | S4 | T1 |
| T3 | the suite runs pytest with `-n auto`; tests that share a path or a port are made safe to run in parallel | S5 | T1 |
| T4 | accept measures the suite time and fails over `limits.suite_seconds = 30`; build records test time per run; the page shows both | S1, S2 | T3 |
| T5 | remove the root cause of the flaky revert test | S6 | T3 |
| T6 | `verify.yml` runs the suite command from `harness.toml`; build compares failures by their `FAILED <test>` lines; add the lesson: CI runs the same suite command as accept | S7, S8 | T5 |

| item | justification |
| --- | --- |
| dep: pytest-xdist | parallel test runs; the standard pytest plugin for it; no code of our own to keep |

## 6. Amendments

| # | target | change | why |
| --- | --- | --- | --- |
| K1 | charter | pin S3 allows `pytest-xdist` as a test-time dependency, through `uv run --with` | parallel runs cut suite time; tests only, never at runtime |

## 7. Assumptions and open items

| item | label |
| --- | --- |
| The suite runs in 20 s or less after this slice. | hypothesis |
| A budget of 30 s leaves room for growth and still fails fast. | open |
| The flaky test fails from shared state or timing; T5 finds which. | hypothesis |
| Escalation from accept, answered by the owner: the suite took 39.8 s, down from 78 s. The 20 s hypothesis is refuted. The budget becomes 45 s; profiling the remaining time goes to the backlog. | decided |
| Escalation from accept, answered by the owner: build writes commit messages, so R1 now asks for a code comment at the fix. Putting the implementer's summary in the commit body goes to the backlog. | decided |
| Escalation from CI on PR #43, answered by the owner: CI lacked `markdown` because `verify.yml` had its own command, and xdist worker ids made two equal failures look different. T6 fixes both. | decided |
