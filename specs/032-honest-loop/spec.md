# Spec 032 — An honest loop

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

Slice 031 failed three times in ways the owner could not see at gate H1. Its delete list came from reading, so it removed pin S1's live guard. The implementer rule froze every test file, so build escalated on a legal edit. Its result page said 1 intervention and 71k tokens; the truth was 5 and about 1.01M. This slice moves each of those from the agent's memory into the machine.

![The impact check, on slice 031's mistake](impact.svg)

## 1. Glossary

| term | meaning |
| --- | --- |
| **removes table** | A spec table whose two columns are `removes` and `why`. Each row is one path the slice deletes or renames. |
| **referrer** | A live file whose text holds a removed path, or the last segment of that path without its extension. |
| **answer commit** | A commit with the subject `spec(<slice>): answer escalation …`. It records one owner decision after gate H1. |
| **build run** | One run of `scripts/build.py` on a slice. A slice can need several. |

## 2. Requirements

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| F1 | When build calls the implementer, the prompt shall list the frozen test files of the slice. | real-enforcement | E1 |
| F2 | The implementer rule shall forbid edits to frozen tests only. | real-enforcement | E2, E3 |
| I1 | When the spec has a **removes table**, the lint shall report each **referrer** that the spec does not name. | real-enforcement | E4, E5, E6 |
| I2 | The lint and the stale-name check shall read the history paths from one list. | real-enforcement | E7 |
| M1 | When accept writes the result page, the page shall count interventions as the H1 marker plus each **answer commit**. | measurable-impact | E8 |
| M2 | When build runs again, the report shall keep the tokens and escalations of each earlier **build run**. | measurable-impact | E9 |
| M3 | When accept writes the result page, the page shall show the tokens of all build runs and their count. | measurable-impact | E10 |
| M4 | The accept step shall tell the agent to commit each owner answer as an answer commit. | measurable-impact | E11 |
| M5 | The spec of slice 031 shall record its true interventions and tokens, labelled reported. | measurable-impact | E12 |

## 3. Examples

Each example becomes a test named `test_<id>_<words>`.

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | T0 froze `tests/test_e1_add.py` | build calls the implementer for T1 | the prompt has a `Frozen tests` section that lists `tests/test_e1_add.py` |
| E2 | `harness/prompts/implementer.md` | the test reads it | it has no `never edit a file under tests/ that exists already`; it says `never edit a frozen test` |
| E3 | T0 froze `tests/test_e1_add.py`; the T1 implementer edits `tests/check_00_skeleton.sh` and `calc.py` | build checks T1 | T1 is not rejected for a frozen test, and it is done |
| E4 | `memory/stack/stack.md` holds `scripts/guards/no-prescribe.sh`; the spec removes `scripts/guards/no-prescribe.sh` and never names `memory/stack/stack.md` | the lint runs | exit 1; `scripts/guards/no-prescribe.sh: referred by memory/stack/stack.md` |
| E5 | the case of E4, and the spec names `memory/stack/stack.md` | the lint runs | no finding for that path |
| E6 | the only referrer is `specs/015-x/spec.md` | the lint runs | no finding: `specs/` is history |
| E7 | `tests/stale_names.py` | the test reads it | it defines no history list of its own; it imports the list from `scripts/spec.py` |
| E8 | a slice branch with the H1 marker and two answer commits | accept writes the page | `Interventions 3` |
| E9 | build run 1 reports 600 tokens and one escalation; build run 2 reports 400 tokens | run 2 ends | the report has 2 runs, 1000 tokens in total, and run 1 keeps its escalation |
| E10 | the report of E9 | accept writes the page | `Tokens 1000 (2 build runs)` |
| E11 | `harness/steps/accept.md` | the test reads it | it names the subject `spec(<slice>): answer escalation` |
| E12 | `specs/031-clear-sdlc/spec.md` | the test reads it | it records `5 interventions` and `1,010,245 tokens` as reported |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: a deletion never reaches gate H1 with an unnamed live referrer. I1 checks it on every spec.
- reconciliation: E12 compares 031's numbers with the five build logs of 2026-10-03: 232,228 + 54,452 + 539,476 + 112,742 + 71,347 tokens.
- e2e run: the fake-agent build and accept tests.

The e2e run writes no `results.json` here.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | build lists the frozen tests in the implementer prompt; the implementer rule forbids edits to frozen tests only | F1, F2 | |
| T2 | the lint reads the removes table and reports unnamed live referrers; `scripts/spec.py` owns the history list and `tests/stale_names.py` imports it | I1, I2 | |
| T3 | the build report keeps a list of runs, each with its start, tokens and escalations | M2 | |
| T4 | the result page counts interventions from git and shows the tokens of all runs; `harness/steps/accept.md` names the answer commit | M1, M3, M4 | T3 |
| T5 | record 031's true numbers in its section 7 | M5 | |

| item | justification |
| --- | --- |

No new module and no new library.

## 6. Amendments

None.

## 7. Assumptions and open items

| item | label |
| --- | --- |
| A referrer match on the path's last segment can over-report, for example a common word. The spec then names the file and says why it stays. | open |
| Interventions before gate H1, during the brief and the spec, are not counted. | open |
| Slice 031 had 5 owner decisions after the brief: gate H1 and 4 answers. | reported |
