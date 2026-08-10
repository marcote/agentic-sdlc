# Technical plan — 018-adoption-fixture

> HOW it is built. Produced by `/plan`, behind the fail-closed stack-charter gate.

## Stack gate

Run deterministically over `acceptance.md` × `memory/stack/stack.md`.

```
$ python3 scripts/stack/engine.py ground-rules memory/stack/stack.md   # exit 0, all six covered
$ python3 scripts/stack/engine.py pin-valid    memory/stack/stack.md   # exit 0
```

**Verdict: `UNPINNED`, then `PASS`.** The charter had no pin for *how this repository proves
portability*. The decision is load-bearing under the inclusion test: going from one worked adopter
to a stack matrix means restructuring the check and every adopter-shaped assertion in it.

`S9` was minted and appended, per the accretion loop. It is `[substrate]`, so it carries no
`Injects` and `coverage.md` did not have to reopen. Charter now reads **10 pins · 8 PINNED ·
2 PROVISIONAL**.

### Criteria read against each declared `Falsifier`

| Pin | Reading |
|---|---|
| `S7` | The closest call, and the reason `S7` was sharpened three commits ago. Its falsifier fires when a check in `tests/run.sh` asserts an application's behaviour. `ADOPT-TESTCMD-INVOKED` asserts the **seam**: that the fixture's command was found, executed, and reported a result. It must not require exit 0 — see decision D3. Not tripped, but one edit away from tripping. |
| `S1` | Its falsifier covers artifacts under `base/`. The fixture is under `tests/fixtures/`, and its charter names Python because an **adopter** named it. That is the mechanism working, not a prescription. Not tripped. |
| `S3` | The fixture's test command is `python3` with the standard library, which is what the suite already runs. No manifest, no lockfile, no install step. Not tripped, and `uv` was rejected at grilling for exactly this reason (`G-c`). |
| `S2` | The engines gain no capability. R6 changes how an existing default resolves, and the fix stays inside the CLI. Not tripped; `S2-HEDGE-98` carries the row at its weakest reading. |
| `S5`, `S6`, `S8` | Files in a repository, copied in place, failing closed. Untouched. |
| `S9` | Minted here, so it cannot be tripped here. Its falsifier is an adopter report or a second fixture. |

## Technical decisions

**D1 — The fixture is a directory, not a git repository.** `vendor.sh` only needs a target
directory; `provenance_line` reads git from the **source**, not the target. A nested `.git` would
also have to be scrubbed from every sandbox copy. Constrained by `S6` — state is files, and a
fixture repository would be state the harness cannot see in its own diff.

**D2 — One sandbox copy per scenario, via `mktemp -d`.** Not one shared sandbox. Two fixture
harnesses leaked state on 2026-08-09, and `git checkout` cannot restore an untracked file. The
committed fixture is asserted byte-identical afterwards (`ADOPT-SANDBOX-CLEAN`).

**D3 — The fixture's test command is invoked for its seam, never for its verdict.** The check
requires the command to be found and to emit its own result line. It does **not** require exit 0.
Requiring it would make a green harness suite also claim the fixture works, which is precisely
`S7`'s falsifier.

**D4 — Guards are executed as the string `guards` emitted.** Read the engine's stdout, run each
line with the target as cwd. No path is written into the check. This is `S9`'s `Hedge` in its first
use and `G-e` in `spec.md`.

**D5 — R6 changes the default resolution only.** `_effective_rules` gains the charter's own
directory as its search root, walking up to the repository root the same way the North Star engine
resolves `decisions/`. An explicit `--rules` still wins. Constrained by `S8`: on finding nothing it
still raises `Malformed`, it does not guess.

**D6 — The fixture's markdown is exempt from `D5` (the 35-word cap).** It sits outside
`prose.sh`'s scan roots already; the plan records that as intent. An adopter inherits the harness's
artifacts, not its prose conventions.

## Components / modules

| Unit | Responsibility | Interface |
|---|---|---|
| `tests/fixtures/adopter/` | be a small, inert adopter repository with authored governance | files on disk |
| ├ `pyproject.toml` | the stack marker `vendor.sh` detects | presence |
| ├ `ledger.py` + `test_ledger.py` | the inert product half, under the budget | `python3` |
| ├ `scripts/test.sh` | the adopter's own verification command | exit code + one result line |
| ├ `memory/stack/stack.md` | four pins `P1`–`P4`, two declines, two guards | the charter engine |
| ├ `scripts/guards/*.sh` | the fixture's own stances, checkable | exit 0 / non-zero |
| └ `memory/north-star/` | a filled North Star plus one ADR | the North Star engine |
| `tests/check_98_adoption.sh` | vendor onto a copy, run the gates, report | `_pass` / `_fail` / `_skip` |
| `scripts/stack/engine.py` | R6 — resolve companion files from the artifact | unchanged CLI |

## Risks

**The fixture grows into an application.** `alignment.md` scored `scopeCompliance: 4` on this
edge. Mitigated by `ADOPT-FIXTURE-BUDGET` for size and by `UAT-FIXTURE-INERT` for intent, which is
the half a budget cannot judge.

**R6 breaks the existing callers.** `/plan`, `check_92` and the `stack` skill all invoke
`ground-rules` from the repository root. The change only adds a fallback when cwd resolution finds
nothing, so those paths keep their current behaviour. Asserted from a non-target cwd, which is the
only cwd where old and new differ.

**The check tests our knowledge of the fixture rather than the seam.** The failure mode of every
fixture harness. Mitigated by D4 and by `S9`'s `Hedge`: identifiers come from the fixture, so a
renamed pin fails the check instead of silently passing it.

**One fixture hides stack-shaped blind spots.** Stated as `S9`'s `Forecloses` rather than
mitigated. That is what the pin is for.

## Gate bootstrap (`D4`)

Not applicable. This feature ships no gate that would judge itself; it runs existing gates against
a new input. `D3` (reflexive dogfood) **does** apply and is discharged by construction: the check
runs inside `tests/run.sh` on its own feature branch before close.
