# Spec 033 — Memory in the repo, and lessons that are learned

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

The lessons of this harness and the owner's way of working live today in one agent's local store. They are lost when the harness moves to another repo or another agent runs it. This slice moves them into the repo.

A lesson that is only written down is captured, not learned. A lesson is learned when it changes what the agents do, and there is evidence of it. This slice makes that difference visible and measured.

Agents read the constitution, the memory, the prompts and the steps. Ambiguity in that text becomes drift. So that text follows ASD-STE100 at about 80%, and a check enforces it. Documents for humans stay free.

![The memory loop](memory-loop.svg)

The input for the migration is the snapshot in `specs/033-repo-memory/session-memory/`, taken on 2026-10-03.

## 1. Glossary

| term | meaning |
| --- | --- |
| **lesson** | One row of `memory/lessons.md`: what to do, its check, its source slice, two counters and a status. |
| **captured lesson** | A lesson with status `captured`: written, with no evidence that it changes what agents do. |
| **learned lesson** | A lesson with status `learned`: its check exists and runs, or a later slice applied it (`helpful` is 1 or more). |
| **rule lesson** | A lesson that changes what is allowed. It has status `proposed` until the owner approves it at gate H1. |
| **reflector** | The role that reads a slice's build report and returns each lesson delta. |
| **lesson delta** | One change to the lessons: add a lesson, or add one to its `helpful` or `harmful` counter. |
| **owner file** | `memory/owner.md`: how the owner works with agents. |
| **agent-facing file** | A file that agents read as instructions: `AGENTS.md`, `memory/`, `harness/prompts/`, `harness/steps/` and each `specs/*/spec.md`. |

## 2. Requirements

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| A1 | The file `AGENTS.md` shall be the one index of the harness memory, and `CLAUDE.md` shall only import it. | agnostic-portability | E1 |
| A2 | The file `memory/lessons.md` shall hold every **lesson** in one table. | measurable-impact | E2 |
| A3 | The **owner file** shall hold the owner's working preferences from the snapshot. | agnostic-portability | E3 |
| A4 | When vendoring applies, the target shall get `AGENTS.md`, the `CLAUDE.md` import, an empty lessons table and an owner file stub. | agnostic-portability | E4 |
| K1 | When the suite runs, each **learned lesson** shall name a check that exists, or have `helpful` of 1 or more. | real-enforcement | E5, E6, E7 |
| K2 | When a lesson's check names a test that exists, the lessons check shall accept the status `learned` for it. | real-enforcement | E5 |
| R1 | When build rejects an attempt, the report shall record the reason as a finding of that task. | measurable-impact | E8 |
| R2 | When the checks of accept pass, accept shall apply each **lesson delta** that the **reflector** returns, before the merge. | measurable-impact | E9 |
| R3 | If a lesson delta adds a **rule lesson**, then accept shall add it with status `proposed`. | real-enforcement | E10 |
| R4 | When a lesson delta adds one to `helpful`, accept shall set that lesson to `learned`. | measurable-impact | E9 |
| R5 | When the spec step writes the spec page, the page shall list every proposed lesson for the owner. | real-enforcement | E11 |
| R6 | When build calls the implementer or the reviewer, the prompt shall include every lesson that is `captured` or `learned`. | measurable-impact | E12 |
| R7 | If the reflector call fails, then accept shall still merge and print the failure. | frictionless-adoption | E13 |
| R8 | When accept writes the result page, the page shall show the count of **captured lesson** and **learned lesson** rows. | measurable-impact | E14 |
| W1 | When the suite runs, the prose check shall cover each **agent-facing file** and skip `README.md` and `docs/`. | real-enforcement | E15, E16 |
| W2 | When the prose check reads a paragraph, it shall count each sentence across line breaks. | real-enforcement | E17 |
| W3 | The prose check shall skip the history paths of the shared list. | real-enforcement | E18 |

## 3. Examples

Each example becomes a test named `test_<id>_<words>`.

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | the harness repo | the test reads `AGENTS.md` and `CLAUDE.md` | `CLAUDE.md` is exactly `@AGENTS.md`; `AGENTS.md` links `memory/lessons.md` and `memory/owner.md` |
| E2 | `memory/lessons.md` | the test parses its table | the header is `id, lesson, check, source, helpful, harmful, status`; rows exist whose source names `prune-from-inventory`, `clean-wrong-number` and `fixtures-are-my-assumptions` |
| E3 | `memory/owner.md` | the test reads it | it says the owner chats in Spanish and artifacts are in English; it names gate H1 as the one approval; it names interfig for spec pages |
| E4 | an empty target directory | `vendor.sh --apply` runs | the target has `AGENTS.md`, `CLAUDE.md` equal to `@AGENTS.md`, `memory/lessons.md` with the header and no rows, and `memory/owner.md` |
| E5 | lesson `L1`, status `learned`, check `tests/test_spec.py::test_e1_undefined_bold_term` | the lessons check runs | no finding |
| E6 | lesson `L3`, status `learned`, check `tests/test_x.py::test_missing` | the lessons check runs | the finding `L3: check not found: tests/test_x.py::test_missing` |
| E7 | lesson `L5`, status `learned`, check `none: judgment`, helpful 0 | the lessons check runs | the finding `L5: learned without evidence` |
| E8 | a fake reviewer returns `fix` with the finding `R1 scope: calc.py adds mul` | build ends | the report has the finding `{"task": "T1", "text": "R1 scope: calc.py adds mul"}` |
| E9 | lesson `L2` is `captured` with helpful 0; a fake reflector returns one soft add and a `helpful` delta for `L2` | accept passes its checks | the new row has status `captured`; `L2` has helpful 1 and status `learned`; both reach `main` |
| E10 | a fake reflector returns an add of kind `rule` | accept passes its checks | the new row has status `proposed` |
| E11 | `memory/lessons.md` has one `proposed` row | `scripts/spec.py page` runs on a spec | the page has a `Proposed lessons` section with that row's text |
| E12 | rows `L1` learned, `L2` captured, `L3` proposed, `L4` retired | build calls the implementer | the prompt has a `Lessons` section with `L1` and `L2`, and without `L3` or `L4` |
| E13 | the fake reflector exits 7 | accept passes its checks | exit 0; the slice is on `main`; the output names `reflector: agent: exit 7` |
| E14 | 6 lessons: 4 `learned`, 2 `captured` | accept writes the page | `Lessons 4 learned / 6` |
| E15 | `memory/owner.md` has a prose sentence of 30 words | the suite runs | the prose check names `memory/owner.md` and `30 words` |
| E16 | `docs/workflow.md` has a prose sentence of 30 words | the suite runs | no prose finding for `docs/workflow.md` |
| E17 | `memory/owner.md` has one sentence of 30 words, wrapped over 3 lines of 10 words | the prose check runs | it names `memory/owner.md` and `30 words` |
| E18 | `memory/north-star/decisions/0004-x.md` has a sentence of 40 words | the prose check runs | no finding for that file |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: no learned lesson lacks evidence (K1), and no agent-facing sentence runs over 25 words (W1). Both run on every suite run.
- reconciliation: none.
- e2e run: the fake-agent accept tests run the reflector role through `scripts/fake_agent.py`.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | write `memory/lessons.md` and `memory/owner.md` from the snapshot, in English at about 80% ASD-STE100; a lesson whose test exists is `learned`, the rest `captured`; fold `CLAUDE.md` into `AGENTS.md`; `CLAUDE.md` becomes `@AGENTS.md` | A1, A2, A3 | |
| T2 | add the lessons check to the suite | K1, K2 | T1 |
| T3 | build records each rejected attempt's reason as a finding | R1 | |
| T4 | add the reflector role, prompt and schema; accept runs it after its checks, applies each delta, and sets `learned` on a helpful delta | R2, R3, R4, R7 | T3 |
| T5 | build adds captured and learned lessons to prompts; the spec page lists proposed lessons; the result page counts learned lessons | R5, R6, R8 | T4 |
| T6 | the prose check covers every agent-facing file; rewrite the agent-facing prose that fails it, constitution and charter included | W1 | T1 |
| T7 | vendoring seeds `AGENTS.md`, the `CLAUDE.md` import, an empty lessons table and an owner file stub | A4 | T1 |
| T8 | the prose check joins the lines of a paragraph and skips history; rewrite every agent-facing sentence that then fails; the shell checks that read `CLAUDE.md` read `AGENTS.md`; add the lesson: a check that cannot read its input must fail, not pass, with check `test_e17_` | W2, W3 | T6, T7 |

| item | justification |
| --- | --- |

No new module and no new library. The reflector is a role in `harness.toml`, not a module.

## 6. Amendments

| # | target | change | why |
| --- | --- | --- | --- |
| C5 | constitution | add D8: the harness memory lives in the repo, and `AGENTS.md` is its index. A lesson is captured when written and learned only with evidence: a running check, or a later slice that applied it. | the owner: memory in one agent's store is lost; a written lesson is not yet learned |
| C6 | constitution | `CLAUDE.md` becomes a one-line import of `AGENTS.md`; its rules move into `AGENTS.md` | one source for every agent |
| C7 | constitution | D5 (ASD-STE100) covers every agent-facing file, not only specs; documents for humans stay free | ambiguity in what agents read becomes drift |

## 7. Assumptions and open items

| item | label |
| --- | --- |
| The reflector runs on Claude Opus, like the judge. | open |
| Soft lessons land as `captured` without the owner. Only rule lessons wait for gate H1. | open |
| A lesson with no helpful delta in its next 5 slices becomes `retired`. Retiring is left for a later slice. | open |
| Build gives every captured and learned lesson to every prompt, until the table grows. | open |
| Feature history in the snapshot (features 003–027) stays in git and specs; it does not become lessons. | decided |
| After merge, the agent's local memory becomes a pointer to `AGENTS.md`, with the owner's consent. | open |
| Pre-accept finding, approved by the owner: since spec 029 the prose check counted words per physical line, so wrapped prose passed with 43 sentences over 25 words. T8 fixes the check and the prose. | decided |
| First proposed lesson, from writing this spec: the lint must reject a requirement id that is also a task id. This spec first named a requirement `T1`. | open |
