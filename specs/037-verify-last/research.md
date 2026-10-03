# Research — 037-verify-last

## 1. Keep `main` green: test exactly what lands

- The Not Rocket Science Rule of Software Engineering (NRSROSE): a branch "is automatically guaranteed to always pass the entire test suite". bors-ng implements it; so does a protected branch that requires the branch to be up to date before merge. https://forum.bors.tech/t/other-apps-that-implement-the-nrsrose/51
- A GitHub merge queue tests "the latest version of the base_branch as well as changes from pull requests ahead of it", and merges only when the required checks pass on that combination. https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue

Our accept breaks this rule. It runs the suite, then writes `memory/lessons.md` (reflector, curator) and `memory/north-star/north-star.md` (write-back), then merges. Slice 035 (L18) and slice 036 (E6) both merged a red tree this way.

Implication: accept writes everything that can change a test result before the suite runs, and merges the commit the suite passed. Only accept's own report files in `specs/<slice>/` change after the suite.

## 2. Why the suite is slow (measured 2026-10-03, branch 037-verify-last, 10 cores)

| run | wall | CPU (user + sys) |
| --- | --- | --- |
| `-n auto` (10 workers) | 38.2 s | 95.6 s |
| `-n 4` | 40 s | not measured |
| `-n 6` | 39 s | not measured |
| serial, sum of test call times | 90.3 s | not measured |
| `-n auto`, slice repos call `python -m pytest` instead of `uv run --with … pytest` (experiment, not committed) | 15.7 s | 119.8 s |

- The parallel suite used about 2.5 of 10 cores, and more workers did not help. The suite waited, it did not compute.
- The slowest tests are build and accept tests: 8–17 s each under 10 workers, 3.8 s for the slowest one alone.
- uv locks the target environment when it installs, to stop concurrent changes across processes. https://docs.astral.sh/uv/concepts/cache
- Each build or accept test starts nested `uv run --python 3.12 --with pytest …` commands from the slice repo's `harness.toml`. With the running Python instead, the same suite took 15.7 s and used about 7.6 cores.
- pytest reports the slowest tests with `--durations`. https://docs.pytest.org/en/stable/how-to/usage.html

## 3. Lessons against each other

- Mem0 compares each new memory with the most similar existing memories, and an LLM decides ADD, UPDATE, DELETE or NOOP. https://arxiv.org/html/2504.19413 (036 `research.md` §1)
- Our curator prompt defines a conflict only against a constitution clause. Two active lessons that contradict each other are not checked.

## 4. A check that proves it runs

- L22 (reflector, slice 036): a promoted check that matches its name as plain text passes on any mention.
- Mutation testing judges a test by whether it fails when the code is broken. https://en.wikipedia.org/wiki/Mutation_testing
- The meaning of a promotion (does this check enforce this lesson?) is semantic: the owner approves it at H1 (D7). The existence of the check is mechanical: a test function is a `def`, a constitution clause is a heading, a script is a file.
