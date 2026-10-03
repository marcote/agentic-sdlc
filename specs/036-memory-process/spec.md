# Spec 036 — Memory by process

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

Slice 034 answered a semantic question with a parser. The regex `stated_limits` compares a number and a unit in a lesson with the constitution. It flagged L18 ("3.11 or later") against D5 ("20 or fewer"), and `main` is red. No system in the state of the art uses a parser for this; a model judges meaning, and code keeps ids, counts and status (`research.md`). This slice deletes the regex and gives the semantic work to a model that never blocks. It also replaces the lesson statuses with a lifecycle that keeps every row, and makes each spec state its sources and its use of memory.

![Lesson lifecycle](figures/lifecycle.svg)

## 1. Glossary

| term | meaning |
| --- | --- |
| **active** | A lesson status: every build prompt holds the lesson. This is tier L1. |
| **proposed** | A lesson status: the lesson waits for the owner at the next gate H1. Its check cell says why. |
| **promoted** | A lesson status: a test, a check or a constitution clause enforces the lesson. Its check cell names it. This is tier L0. |
| **merged** | A lesson status: another lesson says the same thing. Its check cell names that lesson. |
| **curator** | The role that reads the active lessons and the constitution, and names each conflict with the clause it breaks. |
| **labeled case** | A row of `harness/curator-cases.md`: a lesson, a rule, and the owner's label `conflict` or `clean`. |
| **L1 cap** | The value `limits.lessons_bytes` in `harness.toml`: the most bytes of active lessons a prompt holds. |

## 2. Requirements

| id | requirement | kind | anchor | examples |
| --- | --- | --- | --- | --- |
| M1 | The lessons check shall not compare the numbers in a lesson with the numbers in the constitution. | mechanical | real-enforcement | E1 |
| M2 | If a lesson has a status other than **active**, **proposed**, **promoted** or **merged**, then the lessons check shall report it. | mechanical | real-enforcement | E2 |
| M3 | If a lesson is **promoted**, then the lessons check shall report it when its check cell names a file or a name that does not exist. | mechanical | real-enforcement | E3, E4 |
| M4 | If a lesson is **merged**, then the lessons check shall report it when its check cell names no lesson that exists. | mechanical | real-enforcement | E5 |
| M5 | The file `memory/lessons.md` shall hold the statuses of the migration table in section 8. | mechanical | measurable-impact | E6 |
| M6 | When accept applies a reflector delta, accept shall add a new lesson as **active**, or as **proposed** when its kind is `rule`, and a `helpful` or `harmful` delta shall change only its counter. | mechanical | measurable-impact | E7 |
| M7 | When build writes a prompt, build shall put in it every **active** lesson and no lesson of another status. | mechanical | real-enforcement | E8 |
| M8 | When accept has applied the reflector deltas, accept shall give the **curator** the constitution, the **active** lessons and each **labeled case**. | mechanical | real-enforcement | E9 |
| M9 | If the **curator** names a conflict for an **active** lesson, then accept shall mark it **proposed** with the clause and the reason, and accept shall still merge. | mechanical | real-enforcement | E9, E10 |
| M10 | When accept writes the result page, the page shall show the conflicts the **curator** found and missed on each **labeled case**, and its false alarms. | mechanical | measurable-impact | E11 |
| M11 | When accept writes the result page, the page shall show the lessons per status, and the bytes of **active** lessons against the **L1 cap**. | mechanical | measurable-impact | E12 |
| M12 | If a requirement has no kind, or a `semantic` requirement is not judged, then the spec lint shall report it. | mechanical | real-enforcement | E13, E14 |
| M13 | If an **active** lesson is not in the Memory applied table of a spec, then the spec lint shall report it. | mechanical | real-enforcement | E15 |
| M14 | If a spec has no Sources table, or a Sources row names no source, then the spec lint shall report it. | mechanical | real-enforcement | E16 |
| M15 | The brief step shall ask for a sourced review in `research.md`, and the spec step shall read the whole memory. | mechanical | real-enforcement | E17 |
| M16 | The CI lint step shall lint only the specs that have no result page. | mechanical | real-enforcement | E18 |

No requirement in this slice is semantic. The curator is semantic, but it never blocks: a false alarm costs the owner one look at H1. M10 measures it on every accept.

## 3. Examples

Each example becomes a test named `test_<id>_<words>`.

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | the real L18 row and the real constitution | the lessons check runs | exit 0; the module `lessons` has no attribute `stated_limits` |
| E2 | a lesson `L1` with status `learned` | the lessons check runs | exit 1; the finding `L1: unknown status learned` |
| E3 | a **promoted** lesson `L1` whose check is `tests/test_x.py::test_missing`, and the file has no `test_missing` | the lessons check runs | exit 1; the finding `L1: check not found: tests/test_x.py::test_missing` |
| E4 | a **promoted** lesson `L1` whose check is `memory/constitution/constitution.md::D7`, and the file holds `D7` | the lessons check runs | exit 0 |
| E5 | a **merged** lesson `L2` whose check is `merged into L99`, and no `L99` | the lessons check runs | exit 1; the finding `L2: merged into a lesson that does not exist` |
| E6 | the real `memory/lessons.md` | the test reads each row | each status equals the migration table in section 8, and no row has another status |
| E7 | an **active** lesson `L2`, and reflector deltas: add with kind `soft`, and `helpful` for `L2` | accept merges | the new row is **active**; `L2` has helpful 1 and is still **active** |
| E8 | lessons `L1` **active**, `L2` **proposed**, `L3` **promoted**, `L4` **merged**, each with a unique text | build writes the implementer prompt | the prompt holds the text of `L1` only |
| E9 | an **active** lesson `L2`, and a fake curator that answers the conflict `L2` with `D5` | accept merges | exit 0; the curator prompt holds the constitution, `L2` and the labeled cases; on `main`, `L2` is **proposed** and its check starts with `conflict with D5:` |
| E10 | a fake curator that crashes | accept runs | exit 0; the output holds `curator: agent: exit 7`; the lessons are unchanged |
| E11 | labeled cases `X1`–`X4` labeled conflict and `X5`–`X8` labeled clean, and a curator that answers conflicts for `X1`, `X2` and `X5` | accept writes the result page | the page has the row `Curator` with `2 of 4 found, 2 missed, 1 false alarm` |
| E12 | `lessons_bytes = 100`, two **active** lessons of 150 bytes in all, one **promoted**, one **merged** | accept writes the result page | the page has the row `Lessons` with `2 active (150 of 100 bytes), 0 proposed, 1 promoted, 1 merged` |
| E13 | a spec whose requirement `S1` has the kind `semantic` and the examples `E1` | the lint runs | exit 1; the finding `S1: semantic requirement needs a judge` |
| E14 | a spec whose requirements table has no `kind` column | the lint runs | exit 1; the finding `S1: no kind` |
| E15 | **active** lessons `L1` and `L3`, and a spec whose Memory applied table names `L1` only | the lint runs | exit 1; the finding `L3: not in Memory applied` |
| E16 | a spec with no Sources table | the lint runs | exit 1; the finding `no Sources table` |
| E17 | `harness/steps/brief.md`, `harness/steps/spec.md` and `memory/owner.md` | the test reads them | the brief step names `research.md`; the spec step names `memory/lessons.md`, `memory/owner.md` and the constitution; the owner file says `not intuition` |
| E18 | `.github/workflows/verify.yml` | the test reads the lint step | it skips a spec directory that holds `result.html` |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: no parser judges what a lesson means (M1). The lessons check runs on every suite run.
- reconciliation: the curator's result on the labeled cases (M10), compared with the owner's labels.
- e2e run: accept on this slice runs the real curator on the real lessons and the labeled cases, and its result page shows both.

A test may use recorded real data. A test does not mock the project's own code.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | `scripts/lessons.py`: delete `stated_limits` and `numbers`; check the four statuses, a promoted check (a `path::name` exists when the file holds the name), and a merged target; `apply` adds active or proposed and changes counters only. Migrate `memory/lessons.md` by section 8. Update the old tests that assert `learned`, `captured`, `retired` or `stated_limits`, and the comment in `tests/check_94_lessons.sh`. | M1, M2, M3, M4, M5, M6 | |
| T2 | build prompts hold the active lessons only. The result page shows the lessons per status and the active bytes against `limits.lessons_bytes = 25_000`. | M7, M11 | T1 |
| T3 | add the role `curator`: `harness/prompts/curator.md`, `harness/schemas/curator.json` (`conflicts`: id, with, why), `harness/curator-cases.md` with the cases of section 9, and `curator = "claude-ro"` in `harness.toml`. Accept calls it once after the reflector, marks each conflicted active lesson proposed, never blocks on it, and shows the case counts on the result page. The reflector prompt also gets the constitution. | M8, M9, M10 | T2 |
| T4 | the spec lint checks the `kind` column, the Memory applied table and the Sources table. The template gets the column and both sections. The CI lint step skips specs with `result.html`. | M12, M13, M14, M16 | T1 |
| T5 | the brief step asks for a sourced review in `research.md`; the spec step reads `memory/lessons.md`, `memory/owner.md` and the constitution. Add to `memory/owner.md`: design from process, not intuition. Apply amendment K1. | M15 | T4 |

| item | justification |
| --- | --- |
| role: curator | ACE, Mem0 and Zep give the semantic check to a model, apart from the role that writes lessons (`research.md` §1, §3) |
| file: harness/curator-cases.md | a judge is trusted only after it is measured on labeled data (`research.md` §5) |

## 6. Amendments

| # | target | change | why |
| --- | --- | --- | --- |
| K1 | constitution | add D7: a semantic question goes to a model, and the owner resolves what the model flags; a parser never answers it, and a model never blocks alone | the 034 regex; every system in `research.md` §3 uses a model for meaning |

## 7. Assumptions and open items

| item | label |
| --- | --- |
| The curator finds at least 3 of the 4 labeled conflicts, with at most 1 false alarm. | hypothesis |
| An L1 cap of 25,000 bytes keeps prompts useful. Claude Code loads 25 KB of its memory index. | hypothesis |
| L2 on-demand lessons wait until the active lessons cross the L1 cap. | decided |
| A re-run of the lessons check after the reflector, as planned before, would never fail: `apply` cannot write an invalid row. The curator covers the real failure, a lesson whose meaning conflicts. | decided |
| `helpful` and `harmful` stay as counters. They change no status; a later L2 slice may use them to move lessons between tiers. | decided |
| A model review of the spec before H1 goes to the backlog. | decided |

## 8. Migration

The owner approves each row at H1. A lesson is promoted only when its check enforces the whole lesson, not one case of it.

| lesson | now | becomes | check, and why |
| --- | --- | --- | --- |
| L1 | learned | promoted | `tests/test_honest_loop.py::test_e4_lint_reports_unnamed_referrer`: the lint scans all tracked files for each removed path |
| L2 | retired | merged | `merged into L9` |
| L3 | captured | active | text grows: "…and measure its false alarms before it may block." The 034 regex broke this lesson. |
| L4 | learned | active | the test covers one parser, not every parser |
| L5 | captured | active | judgment |
| L6 | learned | active | test e19 does not check that the full suite ran after a move |
| L7 | captured | active | judgment |
| L8 | learned | promoted | `tests/check_96_prose.sh`: the prose check runs on every agent-facing file |
| L9 | learned | active | the test covers one check, not every check |
| L10 | captured | active | no test covers bullets |
| L11 | learned | promoted | `tests/test_lesson_curation.py::test_e3_id_both_requirement_and_task` |
| L12 | captured | active | judgment |
| L13 | captured | merged | `merged into L9`: keeping the last of two values drops an input |
| L14 | captured | active | judgment |
| L15 | captured | active | an open defect; also a backlog item (L5) |
| L16 | learned | promoted | `tests/test_fast_tests.py::test_e6_ci_runs_the_suite_command_of_harness_toml` |
| L17 | proposed | promoted | `tests/test_build.py::test_t0_ignores_same_named_tests_of_other_slices`; the owner approved this fix in slice 035 |
| L18 | captured | active | judgment |
| L19 | new | promoted | `memory/constitution/constitution.md::D7`. Text: "A semantic question goes to a model, and the owner resolves what it flags. A parser never answers it." |

## 9. Labeled cases

The owner labels each case at H1. The curator sees the lesson and the rule, never the label.

| id | lesson | rule | label |
| --- | --- | --- | --- |
| X1 | Write one idea per sentence, at most 35 words. | A sentence has 25 words or fewer. | conflict |
| X2 | Escalate to the owner after 5 identical failures. | Escalate after 2 identical failures or 3 total attempts per task. | conflict |
| X3 | Write specs and memory in Spanish, the owner's language. | All repo artifacts are written in English. | conflict |
| X4 | After a refactor, run only the tests of the changed module. | After you move code between files, run the full suite. | conflict |
| X5 | A CI step that reads TOML with system python3 needs Python 3.11 or later. | A procedure sentence has 20 words or fewer. | clean |
| X6 | Write one idea per sentence, at most 25 words. | A sentence has 25 words or fewer. | clean |
| X7 | A step file sentence has 15 words or fewer. | A procedure sentence has 20 words or fewer. | clean |
| X8 | Give the reviewer the full diff, not a summary. | Use the active voice. | clean |

## 10. Memory applied

| lesson | applies |
| --- | --- |
| L3 | yes: the curator is measured on labeled cases (M10), and its first real run is this slice's accept |
| L4 | yes: the lint reads the new `kind` column by its header |
| L5 | yes: the spec review by a model goes to the backlog, not into this slice |
| L6 | no: this slice moves no code between files |
| L7 | yes: every number in this spec comes from `research.md` or from a command |
| L9 | yes: an unknown status, a missing check and a missing merge target are findings, not skips |
| L10 | no: the prose joiner does not change |
| L12 | yes: E1 calls `stated_limits` by name; E2 uses a status the old check accepts |
| L14 | no: the test runner does not change |
| L15 | no: build totals do not change |
| L18 | yes: E18 reads `verify.yml`, and the lint step keeps its Python |

## 11. Sources

| practice | source | implies |
| --- | --- | --- |
| Code keeps ids, counts and status; a model judges meaning | ACE, Mem0, Zep (`research.md` §1) | delete `stated_limits`; add the curator |
| Itemized delta updates, never a full rewrite | ACE; Dynamic Cheatsheet collapse (`research.md` §2) | the reflector still emits row operations |
| Invalidate or version, never delete | Zep, Voyager (`research.md` §1) | `merged` and `promoted` keep every row |
| A judge flags, a human resolves | Claude Code prompt-audit, Devin (`research.md` §3) | a conflict makes a lesson proposed for H1 |
| Conflict detection is 87–91% F1, and models stay silent | ConInstruct (`research.md` §3) | the curator must name the clause; we measure it |
| Always-loaded memory has a cap | Claude Code, Codex, Cursor, Chroma (`research.md` §2) | the L1 cap; promotion moves a lesson to L0 |
| A must-hold rule goes to a check, not a prompt | Claude Code memory docs, OpenAI harness (`research.md` §4) | `promoted` is the end of a lesson's life |
| Validate a check on labeled data before trust | Anthropic evals, Husain, Shankar (`research.md` §5) | the labeled cases |
| No source tracks captured versus used | `research.md` §4 | drop `learned` and `captured` |
