# Spec 034 — Lesson curation

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

Slice 033 copied the lessons from one agent's store without checking them. One lesson contradicts the constitution, three name no check though one exists, and two say the same thing. A lesson that is wrong teaches every later slice the wrong thing. This slice fixes the table and adds the check that stops a lesson from contradicting the constitution.

## 1. Glossary

| term | meaning |
| --- | --- |
| **stated limit** | A number with its unit in prose, for example `25 words` or `3 attempts`. |

## 2. Requirements

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| C1 | If a lesson gives a **stated limit** whose unit the constitution also limits, with a different number, then the lessons check shall report it. | real-enforcement | E1, E2 |
| C2 | If a requirement id is also a task id in the same spec, then the lint shall reject it. | real-enforcement | E3 |
| C3 | The lessons table shall state the constitution's sentence limit in L8. | real-enforcement | E4 |
| C4 | The lessons table shall keep one lesson for dropped inputs: L9 covers it, and L2 is `retired`. | measurable-impact | E5 |
| C5 | The lessons table shall mark L4, L6 and the id-collision lesson as `learned`, each with its existing test. | measurable-impact | E6 |
| C6 | When the lint reads a requirements table whose columns are in another order, the lint shall read each column by its header. | real-enforcement | E7 |

## 3. Examples

Each example becomes a test named `test_<id>_<words>`.

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | a lesson `L8` that says `at most 35 words`, and a constitution that says `25 words or fewer` | the lessons check runs | the finding `L8: 35 words; the constitution says 25 words` |
| E2 | a lesson that says `at most 25 words`, and the same constitution | the lessons check runs | no finding |
| E3 | a spec with requirement `T1` and task `T1` | the lint runs | exit 1; the finding `T1: id is both a requirement and a task` |
| E4 | `memory/lessons.md` | the test reads row `L8` | it says `25 words`, and not `35 words` |
| E5 | `memory/lessons.md` | the test reads rows `L2` and `L9` | `L2` is `retired` and names `L9`; `L9` mentions dropped inputs and its check is `test_e17_` |
| E6 | `memory/lessons.md` | the test reads rows `L4`, `L6` and the id-collision lesson | each is `learned`, and each check names a test that exists |
| E7 | a requirements table with the header `id, anchor, examples, requirement` | the lint runs | it reads each requirement text and anchor from the right columns, and reports no `not EARS` finding for a valid row |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: no lesson contradicts a stated limit of the constitution (C1). The lessons check runs it on every suite run.
- reconciliation: none.
- e2e run: the suite runs the lessons check on the real `memory/lessons.md`.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | the lint rejects a requirement id that is also a task id; the lint reads requirement columns by header | C2, C6 | |
| T2 | curate `memory/lessons.md`: L8 says 25 words; merge L2 into L9; L4 names the test for C6, L6 names `tests/test_accept.py::test_e19_fails_twice_then_escalates`; add the id-collision lesson with the test for C2 | C3, C4, C5 | T1 |
| T3 | the lessons check reports a stated limit that differs from the constitution's | C1 | T2 |

| item | justification |
| --- | --- |

No new module and no new library.

## 6. Amendments

None.

## 7. Assumptions and open items

| item | label |
| --- | --- |
| The stated-limit check compares only units the constitution states, such as words and attempts. | open |
| L6 counts as learned because accept always runs the whole suite. | open |
