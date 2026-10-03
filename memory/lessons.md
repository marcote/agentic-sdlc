# Lessons

One row per lesson. `learned`: its check exists. `captured`: judgment only, no check yet.

| id | lesson | check | source | helpful | harmful | status |
| --- | --- | --- | --- | --- | --- | --- |
| L1 | A spec that removes things lists every live reference from a full scan of tracked files. Do not list from memory. | tests/test_clear_sdlc.py::test_e11_harness_has_no_stale_name | prune-from-inventory | 0 | 0 | learned |
| L2 | A check that drops inputs it cannot parse reports a smaller number that is wrong. Resolve, exclude with a count, or abort and name the row. | none: judgment | clean-wrong-number | 0 | 0 | captured |
| L3 | Fixtures hold your own assumptions. Run the check against the real artifact early, not only at the end. | none: judgment | fixtures-are-my-assumptions | 0 | 0 | captured |
| L4 | A fixed-index parser of a markdown table reads the wrong column when the column count changes. Read columns by header name. | none: judgment | fixtures-are-my-assumptions | 0 | 0 | captured |
| L5 | A finding made during a feature goes to `docs/backlog.md`. It does not become the next feature. | none: judgment | wow-backlog-discipline | 0 | 0 | captured |
| L6 | After you move code between files, run the full suite. Do not run only the changed part. | none: judgment | refactor-orphans-mutations | 0 | 0 | captured |
| L7 | Write a number only after a command computed it. Do not write it from memory. | none: judgment | writing-terse | 0 | 0 | captured |
| L8 | Write one idea per sentence, at most 35 words. | tests/test_clear_sdlc.py::test_e6_workflow_prose_has_no_long_sentence | writing-terse | 0 | 0 | learned |
| L9 | A check that cannot read its input must fail, not pass. | tests/test_repo_memory.py::test_e17_prose_check_counts_across_line_breaks | 033-repo-memory | 0 | 0 | learned |
