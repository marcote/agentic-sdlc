# Spec 030 — Lead time by phase

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

The result page of spec 029 said 1.7 h. It counted from the first spec commit, so it missed the design talk. It also mixed the owner's time with the agents' time. This slice measures from the brief to the merge, by phase, from git alone.

It also closes two B23 minors that can silently break build re-runs.

![The phases of a slice](lead-time.svg)

## 1. Glossary

| term | meaning |
| --- | --- |
| **lead time** | The time from the commit that adds the slice's `brief.md` to the accept run. |
| **phase** | One part of the lead time between two marker commits: brief to gate H1, gate H1 to build, build to accept. |
| **H1 marker** | The commit with subject `spec(<slice>): approved at H1`. The spec step makes it when the owner approves. |
| **late example** | An example in `spec.md` that no frozen test names. |

## 2. Requirements

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| L1 | When accept writes the result page, accept shall measure the **lead time** from the commit that adds the slice's brief. | measurable-impact | E1 |
| L2 | When accept writes the result page, the page shall show the duration of each **phase**. | measurable-impact | E2 |
| L3 | If a phase has no marker commit, then the page shall show that phase as unknown and keep the others. | measurable-impact | E3 |
| L4 | If the slice has no brief commit, then accept shall measure from the first branch commit and say so. | measurable-impact | E4 |
| L5 | When the owner approves the spec page, the spec step shall commit the **H1 marker**. | measurable-impact | E5 |
| G1 | While git sets `grep.patternType=extended`, build shall still find the slice's T0 commits. | real-enforcement | E6 |
| G2 | When build runs and the spec has a **late example**, build shall write a failing test for it before any task runs. | real-enforcement | E7 |
| G3 | When build commits tests for a late example, build shall freeze them together with the earlier frozen tests. | real-enforcement | E8 |

## 3. Examples

Each example becomes a test named `test_<id>_<words>`. Times are committer dates.

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | the brief commit is dated 3 hours before accept runs | accept writes the page | the page shows `Lead time 3.0 h` |
| E2 | brief commit at 2026-10-02T10:00:00Z, H1 marker at 11:00:00Z, last build commit at 13:30:00Z | accept writes the page | the page shows `Brief → H1 1.0 h` and `H1 → build 2.5 h`, and a `Build → accept` row |
| E3 | brief commit and build commits, and no H1 marker | accept writes the page | `Brief → H1 unknown` and `H1 → build unknown`; `Lead time` still shows hours |
| E4 | no brief commit; the first branch commit is dated 2 hours before accept runs | accept writes the page | the page shows `Lead time 2.0 h (from first commit)` |
| E5 | the file `harness/steps/spec.md` | the owner reads its approval step | it names the commit subject `spec(<slice>): approved at H1` |
| E6 | `git config grep.patternType extended`; T0 committed; T1 escalated in run 1 | build runs again | no T0 implementer call is made, and T1 is done |
| E7 | T0 committed tests for E1; then `spec.md` gains E2, committed | build runs again | one T0 implementer call names only E2; `test_e2_` fails before T2 runs; a commit `build(<slice>): T0 tests for E2` exists |
| E8 | the run of E7 finished | a later task changes `tests/test_e2_sub.py` | build rejects it with `frozen test changed: tests/test_e2_sub.py` |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: build never runs a task while a late example has no failing test. E7 checks it on every re-run path.
- reconciliation: none. No published value exists for a lead time.
- e2e run: the fake-agent build and accept tests in `tests/test_build.py` and `tests/test_accept.py`.

A test may use recorded real data. A test does not mock the project's own code.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | `done_on_branch` in `scripts/build.py`: pass `--basic-regexp`, and take the frozen set from every T0 commit of the slice | G1 | |
| T2 | build finds late examples from the frozen test files, and runs task 0 for them alone before any task | G2, G3 | T1 |
| T3 | `result_page` in `scripts/accept.py`: lead time from the brief commit, and one row per phase | L1, L2, L3, L4 | |
| T4 | `harness/steps/spec.md` step 6: commit the H1 marker after approval | L5 | |

| item | justification |
| --- | --- |

No new module and no new library.

## 6. Amendments

None.

## 7. Assumptions and open items

| item | label |
| --- | --- |
| Phase times come from committer dates, so a rebase moves them. | open |
| The build phase ends at the last `build(<slice>):` commit. | open |
| A frozen test names its example as `test_<id>_` in the file text. | open |
| This is the first slice built with real agents. The token budget of 3,000,000 may trip. | hypothesis |
