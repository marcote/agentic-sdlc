# Spec 029 — The autonomous loop

Status: draft for gate H1. Date: 2026-10-02.

Every statement carries one label:

- **decided**: the owner chose it in the design conversation of 2026-10-02.
- **hypothesis**: a test must confirm it before anything depends on it.
- **open**: nobody decided it yet.
- **reported**: the repo says so, and nobody verified it here.

Writing rule: about 80% of ASD-STE100. One word has one meaning. A sentence has 25 words
or fewer. A procedure sentence has 20 words or fewer. Use the active voice. Give one
instruction in one sentence. Tables, code blocks and quotes are data, and the length limit
does not apply to them.

## 1. Problem

| fact | label |
| --- | --- |
| The workflow has 12 steps, and each step writes an artifact. | reported |
| The implement step has no rules. `docs/workflow.md` gives it to "the adopter". | reported |
| The model does what the owner asks, but it drifts in scope, size and reuse. | decided |
| The model skips workflow steps or does them badly. | decided |
| `/contract` writes one test per criterion. These tests cost much and prove little. | decided |
| Features 013 to 028 changed the harness itself, not a product. | reported |
| The adopter repo `stage-analysis-scanner` has 131 ADRs in four weeks and a hand-made EDGAR client. An official library exists. | reported |
| The owner confirms almost every operation. | decided |

## 2. Success criteria

The first two slices of the new trading repo measure this spec. Each threshold is a
**hypothesis** until those slices run.

| criterion | threshold |
| --- | --- |
| lead time | brief to merge in 2 working sessions or fewer |
| interventions | gate H1, plus 1 escalation or fewer per slice |
| autonomy | 0 owner confirmations between gate H1 and the end of accept |
| compounding | slice 2 extends 1 or more modules of slice 1, and the reviewer finds 0 duplicates |

## 3. Glossary

These terms have one meaning in this spec. The final glossary lives in the north star.

| term | meaning |
| --- | --- |
| **north star** | The document that says why the product exists. It is the only source of direction. |
| **anchor** | A reference from a requirement to one item of the north star: a pillar, a principle, or a decided item. |
| **amendment** | A proposed change to the north star or the charter. Only gate H1 approves it. |
| **charter** | The file of load-bearing technical decisions, including the libraries the project uses. |
| **brief** | The owner's statement of the objective of one feature. |
| **spec** | The document for one feature: glossary changes, requirements, examples, amendments and plan. |
| **requirement** | One sentence in EARS form. It has an anchor and one or more examples. |
| **EARS** | Requirement syntax: `When <trigger>, the <system> shall <response>`, or `If`, `While`, `Where`, or `The <system> shall`. |
| **example** | A concrete input and its expected output, with real values. An approved example becomes a test. |
| **judged requirement** | A requirement that no example can check. It has a rubric, and a different model scores it. |
| **invariant** | A property that every run must keep. It comes from a principle of the north star. |
| **reconciliation** | A test that compares an output with a published value from outside the repo. |
| **e2e run** | A small run through every layer of the product, with a fixed expected output. |
| **gate H1** | The one approval the owner gives. The owner approves the spec page. |
| **spec page** | The HTML page that shows the spec for gate H1. |
| **build** | The step that implements the plan without the owner. A script controls it. |
| **accept** | The step that verifies the result by machine and merges it. |
| **task** | One unit of the plan. It cites one or more requirements. |
| **role** | A job an agent does in build: `implementer` or `reviewer`. |
| **adapter** | The command template that runs one agent CLI for one role. |
| **assumption** | A choice the implementer makes where the spec is silent. It is `minor` or `structural`. |
| **escalation** | A stop that asks the owner for a decision. |
| **frozen test** | A test file that build locks after task 0. No later task may change it. |
| **module map** | The table of modules in `docs/modules.md`: layer, purpose, interface, anchors, status. |
| **verified module** | A module whose invariants and reconciliations pass. Other modules are `reported`. |
| **budget** | The maximum token spend for one slice. |
| **slice** | One feature, from brief to merge. |

## 4. Flow (decided)

```
setup, once    north star (with glossary and labels) · charter · module map
   ↓
1. brief       the owner writes it; the agent asks what is missing
   ↓
2. spec        the agent writes the spec → lint → spec page
   ⛩ gate H1   the owner approves the spec page
   ↓
3. build       a script runs the agents; no owner
   ↓
4. accept      machine checks → merge → results go back to the north star
```

## 5. Requirements

Each row gives its anchor (a pillar of the harness north star) and its examples.

### 5.1 Spec

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| S1 | When the lint runs, the lint shall reject a bold term in a requirement that the glossary does not define. | real-enforcement | E1 |
| S2 | When the lint runs, the lint shall reject a prose sentence of more than 25 words. | real-enforcement | E2 |
| S3 | When the lint runs, the lint shall reject a requirement that does not have EARS form. | real-enforcement | E3 |
| S4 | When the lint runs, the lint shall reject a requirement that has no anchor. | real-enforcement | E4 |
| S5 | When the lint runs, the lint shall reject a requirement that has no example and no `judged` label. | measurable-impact | E5 |
| S6 | When the lint runs, the lint shall reject a task that cites no requirement. | real-enforcement | E6 |
| S7 | When the lint runs, the lint shall reject a new module or dependency without a justification. | measurable-impact | E7 |
| S8 | When the lint passes, the spec step shall write one spec page. | frictionless-adoption | E8 |
| S9 | If the spec changes the north star or the charter, then the spec page shall show each change in an amendments section. | real-enforcement | E9 |

The reviewer checks the 20-word limit on procedure sentences and the active voice.
These are **judged**. (decided)

### 5.2 Build

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| B1 | When build starts, build shall turn each example into a test and shall require each test to fail. | real-enforcement | E10 |
| B2 | If a task after task 0 changes a frozen test, then build shall reject the task. | real-enforcement | E11 |
| B3 | For each task, build shall run the implementer, the checks and the reviewer, in this order. | real-enforcement | E12 |
| B4 | If a task fails 3 attempts, or fails 2 times with the same failure, then build shall escalate the task. | measurable-impact | E13 |
| B5 | When the implementer reports a structural assumption, build shall block that task and continue with the independent tasks. | measurable-impact | E14 |
| B6 | When build ends with escalations, build shall show all escalations to the owner once. | frictionless-adoption | E14 |
| B7 | The reviewer shall check scope, the ponytail ladder, library-first, and module reuse. | measurable-impact | judged, rubric R1 |
| B8 | If the token spend exceeds the budget, then build shall stop and escalate. | measurable-impact | E15 |
| B9 | When build calls an agent, build shall give it only the task, its requirements, examples, glossary terms, map rows, charter and rules. | measurable-impact | E16 |
| B10 | When build ends, build shall write `build-report.json`. | measurable-impact | E17 |

**Ponytail ladder with library-first** (decided). The implementer stops at the first step that works:

1. Does the code need to exist?
2. Does the repo already have it? Use the module map.
3. Does the standard library do it?
4. Does the platform do it natively?
5. Does a library in the charter do it? An official SDK beats a hand-made client.
6. Can it be one line?
7. Only then: the minimum code that works.

A new library is an amendment to the charter. Gate H1 approves it.

**Rubric R1** (for B7). The reviewer gives `fix` when the diff does one or more of these:

- It adds behaviour that no cited requirement asks for.
- It writes code that a charter library or an official SDK already provides.
- It duplicates a module in the module map.
- It adds an abstraction with one implementation.
- It weakens a test.

### 5.3 Accept

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| A1 | When build ends, accept shall run the examples, invariants, reconciliations and the e2e run. | real-enforcement | E18 |
| A2 | If every check passes, then accept shall merge the feature branch into `main`. | frictionless-adoption | E18 |
| A3 | If a check fails, then accept shall return the slice to build once, and escalate on a second failure. | measurable-impact | E19 |
| A4 | When accept merges, accept shall append each result to the north star with the label `reported`. | measurable-impact | E20 |
| A5 | If a module directory has no row in the module map, or a row has no directory, then accept shall fail. | measurable-impact | E21 |
| A6 | When accept ends, accept shall write a result page with lead time, interventions, reused and new modules, and assumptions. | measurable-impact | E22 |
| A7 | When a requirement is judged, accept shall get its score from a model that is not the implementer's model. | real-enforcement | E23 |

The owner can read the result page. The owner does not approve it. (decided)

### 5.4 Tests pattern

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| Q1 | The spec template shall define four test kinds: example, invariant, reconciliation and e2e run. | measurable-impact | E24 |
| Q2 | The spec template shall not ask for one test per requirement or per function. | measurable-impact | E24 |

A test may use recorded real data. A test shall not mock the project's own code. (decided)

### 5.5 Adapter

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| D1 | When build starts, build shall read the CLI of each role from `harness.toml`. | agnostic-portability | E25 |
| D2 | If an agent output fails its JSON schema, then build shall count it as a failed attempt. | real-enforcement | E26 |
| D3 | The adapters for `claude`, `codex` and `fake` shall run the same role prompts. | agnostic-portability | E27 |
| D4 | The instructions for the brief, spec and accept steps shall have one source for Claude Code and for Codex. | agnostic-portability | E28 |
| D5 | The harness scripts shall run with `uv run` and declare their dependencies inline. | frictionless-adoption | E29 |

### 5.6 Prune

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| P1 | When the new steps pass their tests, the harness shall not contain the files that section 8 marks delete. | frictionless-adoption | E30 |

## 6. Examples

Each example becomes a test in task 0 of build. The `fake` adapter runs every build example.
No example needs a real model, except E27.

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | spec with requirement S1 that uses **universe**; the glossary has no `universe` | the lint runs | exit 1; output has `S1: undefined term 'universe'` |
| E2 | spec with a prose sentence of 26 words | the lint runs | exit 1; output names the line and `26 words` |
| E3 | requirement `The data must be fresh.` | the lint runs | exit 1; output has `not EARS` |
| E4 | requirement row with an empty anchor cell | the lint runs | exit 1; output has `no anchor` |
| E5 | requirement row with an empty examples cell | the lint runs | exit 1; output has `no example`. With `judged, rubric R1` in the cell: exit 0 |
| E6 | task `T3` that cites no requirement | the lint runs | exit 1; output has `T3: cites no requirement` |
| E7 | plan row `new module: edgar_client` with no justification | the lint runs | exit 1; output has `edgar_client: no justification` |
| E8 | a spec that passes the lint | the spec step ends | one file `spec.html` exists; it has the glossary, requirements, examples and plan |
| E9 | a spec with one amendment to `out_of_scope` | the spec step ends | `spec.html` has an amendments section with that one change |
| E10 | example E1 as a test, and a lint that already rejects undefined terms | task 0 runs | the test passes before implementation; build marks it `vacuous` and escalates |
| E11 | task T2 diff changes `tests/test_e1.py`, which is frozen | the checks run | build rejects T2 with `frozen test changed: tests/test_e1.py` |
| E12 | `fake` adapter that logs each call | build runs one task | the log is `implementer, checks, reviewer`, in this order |
| E13 | `fake` implementer that fails the same test 2 times | build runs | after attempt 2, build escalates with the failure text |
| E14 | tasks T1 and T2 independent; `fake` implementer returns a structural assumption on T1 | build runs | T2 completes; T1 is blocked; the owner sees one escalation list at the end |
| E15 | budget 1000 tokens; `fake` reports 600 tokens per call | build runs | build stops after the second call with `budget exceeded` |
| E16 | plan with tasks T1 and T2 | build calls the implementer for T1 | the prompt has no text from T2 |
| E17 | a build run with one retry and one minor assumption | build ends | `build-report.json` passes its schema and records 1 retry and 1 assumption |
| E18 | every check passes | accept runs | `main` has the feature commits |
| E19 | the e2e run fails 2 times | accept runs | the slice goes to build once, then accept escalates |
| E20 | the spec tested hypothesis `H-3`, and the run returned a value | accept merges | the north star has a new `reported` line for `H-3` with the value and the date |
| E21 | directory `src/rule/`, and no `rule` row in `docs/modules.md` | accept runs | accept fails with `rule: not in module map` |
| E22 | a completed slice | accept ends | the result page shows lead time, interventions, reused and new modules, and assumptions |
| E23 | implementer `codex`; a judged requirement | accept scores it | the scoring call uses the `claude` adapter |
| E24 | the spec template | the owner reads it | it names the four test kinds; it has no "one test per criterion" rule |
| E25 | `harness.toml` sets `implementer = "fake"` | build runs | the fake agent receives the implementer call |
| E26 | `fake` implementer returns `{"status": 5}` | build validates it | the attempt counts as failed with `schema: status` |
| E27 | one toy task: add a function `add(a, b)` with its test | build runs once with `claude`, and once with `codex` | both runs return schema-valid JSON and a passing test |
| E28 | the spec step instructions | the owner opens Claude Code, then Codex | both read the same file |
| E29 | a clean machine with `uv` | the owner runs `uv run scripts/build.py --help` | the command exits 0 with no manual install |
| E30 | the harness after task T6 | the owner lists `scripts/mutate.sh` and `scripts/nvc.sh`, and runs the test suite | both files are absent; the suite passes |

## 7. Amendments

### 7.1 Harness north star

| # | field | now | proposed | why |
| --- | --- | --- | --- | --- |
| M1 | mission | "…enforces a disciplined agentic SDLC (spec-driven, test-first, evidence-verified)…" | "…enforces a disciplined, autonomous agentic SDLC (spec-driven, test-first, evidence-verified), where the owner defines done and agents deliver it…" | Autonomy is now a success criterion. |
| M2 | out_of_scope | "imposing or naming a mandatory execution runtime" | "imposing a mandatory agent CLI, model or product stack" | Build is a runtime that the harness ships. It stays agnostic about the CLI. |
| M3 | out_of_scope | "runtime dependencies or frameworks" | "dependencies beyond `uv` and inline script dependencies" | The owner chose `uv`. |
| M4 | in_scope | "feature templates, coverage, and criterion state machine" | "feature templates, glossary, and module map" | Coverage and the state machine go away. |
| M5 | in_scope | "WoW self-validation (retro, wow-report) and method documentation" | "the autonomous build loop, its metrics, and method documentation" | The retro and the wow-report go away. Accept writes the metrics. |
| M6 | pillar `measurable-impact`, signal | gaps caught early and rework avoided, in the wow-report | lead time, interventions, and reused against new modules, per slice | These are the success criteria of section 2. |
| M7 | pillar `real-enforcement`, signal | "…dogfooding itself: retro ledger / wow-report" | "…the lint, build and accept gates; the owner approves only at gate H1" | Same pillar, new evidence. |
| M8 | new field | none | every north-star statement carries `decided`, `hypothesis`, `open` or `reported`; the glossary lives in the north star | This stops silent drift. |

### 7.2 Constitution

| # | now | proposed |
| --- | --- | --- |
| C1 | D5: sentences of 35 words or fewer | about 80% of ASD-STE100: 25 words, 20 for procedures |
| C2 | D4: a gate bootstrap exemption with four conditions | delete. Build applies the gates to every slice, and git keeps the history. |
| C3 | no rules for implementation | the ponytail ladder with library-first (section 5.2) |
| C4 | override of `non-vacuous-checks` that depends on `check_96` | delete with `check_96` |

## 8. Disposition of the current harness (decided)

| what | action |
| --- | --- |
| `scripts/north-star/engine.py` | keep; add labels, glossary and the anchor check |
| `scripts/stack/engine.py` | keep; library amendments go through gate H1 |
| `bootstrap.sh`, `scripts/vendor.sh` | keep; they install the harness in the new repo |
| `scripts/status.sh` | keep; change it to the four steps |
| `scripts/prose.sh` | merge into the spec lint |
| `tests/check_60_secret_scan.sh` | keep |
| `scripts/mutate.sh`, `nvc.sh`, `cases.sh`, `lib/matrix.sh` | delete |
| `tests/check_89, 91, 93, 96, 97, 99` | delete |
| commands and skills `align`, `distill`, `plan`, `contract`, `tasks`, `verify`, `uat`, `retro`, `wow-report` | delete; `spec`, `build` and `accept` replace them |
| `.github/workflows/amendment-gate.yml`, `scripts/amendment-gate.sh` | delete; gate H1 approves amendments |
| `specs/001` to `specs/027`, `verification/reports/` | keep as history; do not change |
| `specs/028-suite-hermeticity` | drop; it isolated a suite that this spec deletes |

The size of `scripts/` and `tests/` goes from about 6,000 lines to about 2,000. (hypothesis)

## 9. Plan

The implementation plan is a separate document. The tasks follow this order. (decided)

| task | does | requirements |
| --- | --- | --- |
| T1 | spec lint and spec page, then run them on this spec | S1–S9 |
| T2 | adapter spike: `claude`, `codex` and `fake` return valid JSON | D1–D3, D5 |
| T3 | `build.py` with the loop | B1–B10 |
| T4 | accept, the module map check and the north-star write-back | A1–A7 |
| T5 | templates, one-source instructions, constitution and north-star amendments | Q1, Q2, D4 |
| T6 | delete what section 8 lists | P1 |

## 10. Assumptions and open items

| item | label |
| --- | --- |
| `claude -p --output-format json` and `codex exec --output-schema` give schema-valid JSON. T2 tests it. | hypothesis |
| The spec page uses plain HTML. `interfig` draws its scenarios as animated SVG, with no runtime in the page. | decided |
| The thresholds of section 2. | hypothesis |
| Tasks run one at a time. Parallel tasks wait until sequential build is too slow. | decided |
| Accept merges into the local `main`. It does not push. | decided |
| The Claude Code Workflow tool is not used. It is not agnostic. | decided |
| Which models fill which roles by default. | open |
