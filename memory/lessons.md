# Lessons

One row per lesson. `learned`: its check exists. `captured`: judgment only, no check yet.

| id | lesson | check | source | helpful | harmful | status |
| --- | --- | --- | --- | --- | --- | --- |
| L1 | A spec that removes things lists every live reference from a full scan of tracked files. Do not list from memory. | tests/test_clear_sdlc.py::test_e11_harness_has_no_stale_name | prune-from-inventory | 0 | 0 | learned |
| L2 | Merged into L9. | none: retired into L9 | clean-wrong-number | 0 | 0 | retired |
| L3 | Fixtures hold your own assumptions. Run the check against the real artifact early, not only at the end. | none: judgment | fixtures-are-my-assumptions | 0 | 0 | captured |
| L4 | A fixed-index parser of a markdown table reads the wrong column when the column count changes. Read columns by header name. | tests/test_lesson_curation.py::test_e7_requirement_columns_read_by_header | fixtures-are-my-assumptions | 0 | 0 | learned |
| L5 | A finding made during a feature goes to `docs/backlog.md`. It does not become the next feature. | none: judgment | wow-backlog-discipline | 0 | 0 | captured |
| L6 | After you move code between files, run the full suite. Do not run only the changed part. | tests/test_accept.py::test_e19_fails_twice_then_escalates | refactor-orphans-mutations | 0 | 0 | learned |
| L7 | Write a number only after a command computed it. Do not write it from memory. | none: judgment | writing-terse | 0 | 0 | captured |
| L8 | Write one idea per sentence, at most 25 words. | tests/test_clear_sdlc.py::test_e6_workflow_prose_has_no_long_sentence | writing-terse | 1 | 0 | learned |
| L9 | A check that cannot read or parse its input must fail, not pass. A check that drops inputs reports a smaller number that is wrong: resolve, exclude with a count, or abort and name the row (dropped inputs). | tests/test_repo_memory.py::test_e17_prose_check_counts_across_line_breaks | 033-repo-memory | 0 | 0 | learned |
| L10 | A prose joiner that merges wrapped lines must start a new paragraph at each list bullet. Otherwise bullets without periods merge into one long false sentence. | none: judgment | 033-repo-memory | 0 | 0 | captured |
| L11 | A requirement id must not also be a task id in the same spec. The lint rejects it. | tests/test_lesson_curation.py::test_e3_id_both_requirement_and_task | 034-lesson-curation | 0 | 0 | learned |
| L12 | A negative example on code that exists must call the new behavior by name. Otherwise its test passes before implementation. | none: judgment | 034-lesson-curation | 0 | 0 | captured |
| L13 | When a source states the same limit twice with different values, the check reports the conflict. It does not silently keep the last value. | none: judgment | 034-lesson-curation | 0 | 0 | captured |
| L14 | Declare the test runner and its dependencies in the repo. Otherwise each implementer guesses the `uv run --with` list, and runs can differ. | none: judgment | 034-lesson-curation | 0 | 0 | captured |
| L15 | A resumed build run that does no work must not overwrite the slice totals. Here top-level test_seconds reads 0.0, while the suite took 40.4 s. | none: judgment | 035-fast-tests | 0 | 0 | captured |
| L16 | CI runs the same suite command as accept: the `[checks] suite` of `harness.toml`. CI has no test command of its own. | tests/test_fast_tests.py::test_e6_ci_runs_the_suite_command_of_harness_toml | 035-fast-tests | 0 | 0 | learned |
| L17 | The vacuity check judges only the tests its task wrote. A test of other existing behavior that already passes is not vacuous, and it must not escalate. | none: judgment | 035-fast-tests | 0 | 0 | proposed |
| L18 | A CI step that reads TOML with the runner's system python3 depends on Python 3.11 or later for tomllib. Pin the Python version, or run the step through uv. | none: judgment | 035-fast-tests | 0 | 0 | captured |
