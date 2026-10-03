# Spec 037 — Verify last

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

Accept runs the suite, then writes lessons and the north star, then merges. Slices 035 and 036 both merged a red `main` this way. The rule the state of the art follows is simple: merge exactly the tree that passed the tests (`research.md` §1). This slice moves every write that can change a test result before the suite. It also closes the three open items of slice 036: the curator compares lessons with each other, a promoted check must exist as a check, and the suite gets fast again.

![Verify last](figures/verify-last.svg)

## 1. Glossary

| term | meaning |
| --- | --- |
| **verified commit** | The commit on which accept last ran the suite and every check passed. |
| **memory write** | A change accept makes to `memory/lessons.md` or to the north star: reflector deltas, curator conflicts, and the results write-back. |

## 2. Requirements

| id | requirement | kind | anchor | examples |
| --- | --- | --- | --- | --- |
| V1 | When accept runs, accept shall commit every **memory write** on the slice branch before it runs the suite. | mechanical | real-enforcement | E1 |
| V2 | When accept merges, the files that differ between the **verified commit** and `main` shall all be in the slice directory. | mechanical | real-enforcement | E2 |
| V3 | The test of the 036 migration shall check only the lessons that the migration table names. | mechanical | real-enforcement | E3 |
| V4 | If the curator names a conflict between two active lessons, then accept shall mark the lesson it names `proposed`, with the other lesson as the clause. | mechanical | real-enforcement | E4 |
| V5 | If a promoted check names a Python file, then the lessons check shall find a `def` of that name; if it names another file with a name, it shall find a heading that holds the name. | mechanical | real-enforcement | E5, E6 |
| V6 | The slice repos that the tests build shall run their task and suite commands with the Python that runs the tests, not through `uv run`. | mechanical | measurable-impact | E7 |
| V7 | The suite budget shall be 25 seconds. | mechanical | measurable-impact | E8 |

## 3. Examples

Each example becomes a test named `test_<id>_<words>`.

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | a slice repo whose test asserts that `memory/lessons.md` has no lesson rows, and a fake reflector that adds one lesson | accept runs | exit 1; the escalation names that test; `main` is unchanged |
| E2 | a slice that accept merges | the test compares the **verified commit** in the build report with `main` | every changed path starts with `specs/001-add/` |
| E3 | the real `memory/lessons.md`, which also holds L20–L24 | the test of the 036 migration runs | it passes, and it still fails when a lesson the table names has another status |
| E4 | active lessons `L3` and `L5`, and a fake curator that answers the conflict `L3` with `L5` | accept merges | on `main`, `L3` is proposed and its check starts with `conflict with L5:`; the curator prompt says a lesson can conflict with another active lesson |
| E5 | a promoted lesson whose check is `tests/test_x.py::test_a`, and the file names `test_a` only in a comment | the lessons check runs | exit 1; the finding `L1: check not found: tests/test_x.py::test_a` |
| E6 | a promoted lesson whose check is `memory/constitution/constitution.md::D7`, and the file names `D7` only in body text | the lessons check runs | exit 1; with the heading `### D7 — A semantic question goes to a model` it exits 0 |
| E7 | the `slice_repo` fixture | the test reads the slice repo's `harness.toml` | its `task` and `suite` commands hold no `uv run` and start with the running Python |
| E8 | `harness.toml` | the test reads `limits.suite_seconds` | it is 25 |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: `main` only moves to a tree that passed the suite (V1, V2). Accept checks it on every slice.
- reconciliation: the suite took 38.2 s on 2026-10-03 before this slice, and 15.7 s in the experiment of `research.md` §2.
- e2e run: accept on this slice runs its own reflector and curator before the suite, and merges green.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | accept runs the reflector, the curator and the write-back first, and commits them; then it runs the suite and the checks; it records the **verified commit** in the build report; after the suite it writes only the result page and the build report. Fix the 036 migration test to check only the rows the table names. | V1, V2, V3 | |
| T2 | the curator prompt also asks for conflicts between two active lessons, with the other lesson id in `with`. The lessons check finds a `def` in a Python file and a heading in any other file. | V4, V5 | T1 |
| T3 | the `slice_repo` fixture runs the task and suite commands with `sys.executable -m pytest`. `limits.suite_seconds` becomes 25. | V6, V7 | T1 |

| item | justification |
| --- | --- |

No new module and no new library.

## 6. Amendments

None.

## 7. Assumptions and open items

| item | label |
| --- | --- |
| The suite runs in about 16 s after T3, as in the experiment. | hypothesis |
| A memory write that breaks a test goes to the existing return to build (one FIX task), then escalates. It never merges. | decided |
| When accept escalates after its memory writes, the writes stay committed on the branch. A re-run of accept may add more lessons; the reflector prompt already says to add nothing the lessons say. | decided |
| L24 asks to restore the lint test of the closed spec 029. CI now lints only open specs, so it waits in the backlog. | decided |

## Memory applied

| lesson | applies |
| --- | --- |
| L3 | yes: the suite numbers come from runs on the real repo (`research.md` §2) |
| L4 | no: no table parser changes |
| L5 | yes: only the pending items of 036 are here; L24 goes to the backlog |
| L6 | yes: accept code moves inside `main()`; accept always runs the full suite |
| L7 | yes: every number comes from a command in `research.md` §2 |
| L9 | yes: a promoted check that is not found is a finding, never a pass |
| L10 | no: the prose joiner does not change |
| L12 | yes: E5 and E6 use a mention the current check accepts, so their tests fail before T2 |
| L14 | yes: V6 uses the Python the test runner already declares |
| L15 | no: build totals do not change |
| L18 | no: no CI step reads TOML in a new way |
| L20 | yes: E3 keeps the migration test strong: it still fails on a wrong status |
| L21 | yes: T2 changes the promoted check; the promoted rows already have checks that pass it |
| L22 | yes: V5 is this lesson |
| L23 | yes: E1 and E2 run in a temporary slice repo, not the real one |
| L24 | yes: it goes to the backlog (section 7) |

## Sources

| practice | source | implies |
| --- | --- | --- |
| A branch always passes its whole suite | NRSROSE, bors (`research.md` §1) | merge the **verified commit** |
| Test the exact combination that lands | GitHub merge queue docs (`research.md` §1) | memory writes come before the suite |
| uv locks an environment while it installs | uv cache docs (`research.md` §2) | slice repos call pytest directly |
| Find slow tests with `--durations` | pytest docs (`research.md` §2) | the measurements in `research.md` §2 |
| A new memory is compared with existing memories | Mem0 (`research.md` §3) | the curator compares lessons with each other |
| A test is judged by whether it can fail | mutation testing (`research.md` §4) | a promoted check must exist as a check |
