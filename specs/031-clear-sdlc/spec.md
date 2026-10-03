# Spec 031 — One clear SDLC

Status: draft for gate H1. Labels: decided, hypothesis, open, reported.

Spec 029 pruned the old commands, but its disposition table came from a partial listing. A second layer of the 12-step flow survived in `evals/`, `verification/`, the north star and two engines. Nothing in the four-step flow uses it. This slice removes it, adds a check so it cannot come back in silence, and documents the flow with interfig.

![The workflow](../../docs/figures/workflow.svg)

![The build loop](../../docs/figures/build-loop.svg)

![Accept](../../docs/figures/accept.svg)

## 1. Glossary

| term | meaning |
| --- | --- |
| **live file** | A tracked file outside the history paths: `specs/`, `verification/reports/`, `docs/superpowers/`, `memory/north-star/decisions/`, `docs/backlog.md` and `tests/`. |
| **removed name** | A name of the old flow: `/align`, `/distill`, `distill`, `/contract`, `/tasks`, `/verify`, `/uat`, `/retro`, `wow-report`, `coverage.md`, `acceptance.md`, `alignment.md`, `mutate.sh`, `nvc.sh`, `amendment-gate`, `alignment-rubric`, `amendment-protocol`. |
| **stale-name check** | The test that lists every live file that holds a removed name. |

## 2. Requirements

| id | requirement | anchor | examples |
| --- | --- | --- | --- |
| P1 | When the slice ends, the harness shall not contain the legacy files that section 5 lists for T1. | frictionless-adoption | E1 |
| N1 | The north-star engine shall offer only the `schema-valid` command. | frictionless-adoption | E2 |
| N2 | When the north star has no alignment block, the north-star engine shall accept it as schema-valid. | frictionless-adoption | E3 |
| S1 | The stack engine shall offer only the `pin-valid`, `exposure` and `ground-rules` commands. | frictionless-adoption | E4 |
| D1 | The file `docs/workflow.md` shall show the workflow, the build loop and accept as interfig figures. | measurable-impact | E5 |
| D2 | The prose of `docs/workflow.md` shall have no sentence over 25 words. | measurable-impact | E6 |
| D3 | The README shall show the workflow figure and link `docs/workflow.md`. | measurable-impact | E7 |
| V1 | When vendoring applies, the target shall get `docs/workflow.md` and `docs/figures/`. | agnostic-portability | E8 |
| C1 | When the suite runs, the **stale-name check** shall fail and name each **live file** that holds a **removed name**. | real-enforcement | E9, E10, E11 |

## 3. Examples

Each example becomes a test named `test_<id>_<words>`.

| id | given | when | then |
| --- | --- | --- | --- |
| E1 | the harness after T1 | the test lists `evals/`, `verification/uat-checklist.md`, `memory/north-star/base/alignment-rubric.md`, `memory/north-star/base/amendment-protocol.md`, `.claude/commands/constitution.md`, `memory/constitution/base/patterns/non-vacuous-checks.md` | none of them exists |
| E2 | the north-star engine | it runs `align-verdict` | exit 2; `schema-valid memory/north-star/north-star.md` exits 0 |
| E3 | a north star whose JSON block has `mission`, `pillars` and `scope`, and no `alignment` | `schema-valid` runs on it | exit 0 |
| E4 | the stack engine | it runs `guards` | exit 2; `pin-valid`, `exposure` and `ground-rules` on `memory/stack/stack.md` exit 0 |
| E5 | `docs/workflow.md` | the test reads it | it links `figures/workflow.svg`, `figures/build-loop.svg` and `figures/accept.svg`; each file holds `<metadata id="figure-spec">` |
| E6 | `docs/workflow.md` | `uv run scripts/spec.py lint docs/workflow.md` runs | no finding has `words` |
| E7 | `README.md` | the test reads it | it shows `docs/figures/workflow.svg` and links `docs/workflow.md` |
| E8 | an empty target directory | `vendor.sh --apply` runs | the target has `docs/workflow.md` and `docs/figures/workflow.svg` |
| E9 | a copy of a repo with `docs/notes.md` that says `run /distill first` | the stale-name check runs on it | it reports `docs/notes.md: /distill` |
| E10 | the same text in `specs/015-x/brief.md` | the stale-name check runs on it | no finding |
| E11 | this harness repo after T1–T4 | the stale-name check runs | no finding |

## 4. Tests

Four kinds. Write no other kind.

- example: section 3, one test per example.
- invariant: no live file names a removed step. E11 checks it on every suite run, from now on.
- reconciliation: none. No published value exists here.
- e2e run: `tests/check_84_vendor.sh` applies vendoring to a sandbox (E8).

The figures are approved here at gate H1 and committed with this spec. Build only links them.

## 5. Plan

| task | does | requirements | needs |
| --- | --- | --- | --- |
| T1 | delete `evals/`, `verification/` templates (not `reports/`), `alignment-rubric.md`, `amendment-protocol.md`, the `non-vacuous-checks` pattern, `/constitution`, `tests/fixtures/amendment-gate/`; drop them from `vendor.sh` and docs | P1 | |
| T2 | north-star engine keeps `schema-valid` only; the schema no longer requires `alignment`; the north star loses its Alignment section and block; `check_82` follows | N1, N2 | T1 |
| T3 | stack engine keeps `pin-valid`, `exposure`, `ground-rules`; delete `scripts/guards/`; `check_92` follows | S1 | T1 |
| T4 | write `docs/workflow.md` around the three figures; README shows the workflow figure; vendor keeps `docs/figures/` | D1, D2, D3, V1 | |
| T5 | add the stale-name check to `tests/test_harness.py`; clean every live hit it still finds | C1 | T1, T2, T3, T4 |

| item | justification |
| --- | --- |

No new module and no new library.

## 6. Amendments

| # | target | change | why |
| --- | --- | --- | --- |
| A1 | north star | delete the Alignment section and the `alignment` JSON block | `/align` is gone; the spec lint checks anchors |
| A2 | north-star base | delete `alignment-rubric.md` and `amendment-protocol.md` | amendments go through gate H1 since spec 029 |
| A3 | constitution | delete the `non-vacuous-checks` pattern and the `/constitution` command | the pattern rules coverage rows that no longer exist; constitution changes are amendments at gate H1 |
| A4 | constitution | add D7: a spec that removes a step, file or command names every live file that refers to it, from the stale-name check, not from memory | spec 029 missed this layer because its list came from memory |

## 7. Assumptions and open items

| item | label |
| --- | --- |
| The figures show slice 030's real times. | reported |
| `tests/` is exempt from the stale-name check, because a test may name a removed path to prove it is gone. | open |
| `verification/reports/` and `specs/001`–`030` stay as history. | open |
