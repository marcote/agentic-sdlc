# Verification Report — 018-adoption-fixture @ 3adc719

spec: `specs/018-adoption-fixture/spec.md` · date: 2026-08-09 · constitution: base + project (D1–D5)

## 1. Coverage snapshot

16 deterministic criteria + 2 inherited scans + 3 `[given]` non-vacuity rows, all 🟢 green.
2 rows `📋 case` for `/uat`. 2 rows `deferred` with reasons in `coverage.md`.

## 2. Output eval (BUILD)

`bash tests/run.sh` → **TOTAL PASS=474 FAIL=0**. Baseline before this feature: 456.

| Criterion | Result |
|---|---|
| ADOPT-FIXTURE-BUDGET | 🟢 product half 3 files / 25 lines, cap 4/40 |
| ADOPT-FIXTURE-DROP | 🟢 absent from a vendored target |
| ADOPT-VENDOR-APPLY | 🟢 governance landed on the fixture copy |
| ADOPT-SEED-PRESERVED | 🟢 charter, North Star and test.sh intact; `.harness-new` written |
| ADOPT-CHARTER-PINS | 🟢 4 pins under prefix `P` |
| ADOPT-NS-VALID | 🟢 exit 0 |
| ADOPT-GR-COVERED | 🟢 7 verdicts for 7 effective rules |
| ADOPT-REL-RESOLUTION | 🟢 judged by the target's own set, including `GR7`, from a rule-less cwd |
| ADOPT-NO-SILENT-EMPTY | 🟢 four gates each named the fixture's own artifacts |
| ADOPT-UNCOVERED-FIRES | 🟢 removing `P1` reports `GR4: uncovered`, exit 1 |
| ADOPT-GUARD-BY-NAME | 🟢 2 guards from the engine; no guard name written into the check |
| ADOPT-GUARD-CLEAN | 🟢 both exit 0 |
| ADOPT-GUARD-FAILS | 🟢 a guard rejects the violated copy |
| ADOPT-TESTCMD-INVOKED | 🟢 `adopter-suite: exit 0 (OK)` |
| ADOPT-TESTCMD-NOT-COUNTED | 🟢 harness totals unmoved |
| S2-HEDGE-98 · HERMETIC-ENV-98 · ADOPT-SANDBOX-CLEAN | 🟢 |

**Task success: 474/474 = 100%.**

### Guards (`S1`)

`python3 scripts/stack/engine.py guards memory/stack/stack.md` → `bash scripts/guards/no-prescribe.sh`,
exit 0. One declared guard, one executed.

### Meta-checks

`nvc.sh traceability` 0 · `duplicates` 0 · `selfscan` 0 · `prose.sh` 0.

### Failability, one mutation at a time

Each mutation was applied to a clean tree and reverted with `git checkout` (every mutated file is
tracked — the 015 lesson was untracked files, which none of these are).

| # | Mutation | Criteria that failed |
|---|---|---|
| M1 | R6 reverted to cwd resolution | `ADOPT-REL-RESOLUTION` |
| M2 | pin-id pattern narrowed back to `S\d+` | `ADOPT-CHARTER-PINS` + 7 others |
| M3 | a guard name hardcoded into the check | `ADOPT-GUARD-BY-NAME` |
| M4 | the violation script made a no-op | `ADOPT-GUARD-FAILS` |
| M5 | fixture grown 30 lines past the budget | `ADOPT-FIXTURE-BUDGET` |
| M6 | the adopter's `scripts/test.sh` deleted | `ADOPT-TESTCMD-INVOKED`, `ADOPT-SEED-PRESERVED` |
| M7 | fixture North Star mission re-seeded | `ADOPT-NS-VALID` |
| M8 | the fixture charter declares no `Guard` | `ADOPT-GUARD-BY-NAME` + 3 others |
| M9 | `GR4` loses its answering pin | `ADOPT-GR-COVERED` + 2 others |
| M10 | a mid-file scenario writes to the committed fixture | `ADOPT-SANDBOX-CLEAN` |
| M11 | the fixture's own result enters the harness count | `ADOPT-TESTCMD-NOT-COUNTED` |

**M2 is the one that matters.** The pin-id defect was found by hand three features ago. Under M2 the
fixture catches it in eight criteria, with the charter's own diagnostic naming `P1, P2, P3, P4`.

### One of my own assertions was vacuous, caught by mutation

`ADOPT-REL-RESOLUTION` originally compared the gate run from this repository's root against the run
from inside the target. **M1 produced no failure.** `base/` is KEEP, so both trees carry the same six
rules, and cwd-resolution returned identical output — the assertion could not discriminate.

The fix has two parts, and both were needed. The fixture now extends the base six with `GR7` in its
own layer, and the gate is invoked from a third directory that owns no rules at all. Only
artifact-relative resolution can then produce a seventh verdict.

Recorded rather than quietly fixed: this is the fourth vacuous assertion the harness has caught in
its own work, after two in 016 and one in 015.

## 3. Trajectory eval

| Dimension | Score | Note |
|---|---|---|
| Tool use | ✅ | Every gate run deterministically; every count in this report derived from a command, not from memory. |
| Skipped steps | ⚠️ one, recorded | brief → align → distill → plan → contract (RED at 14 FAIL) → **implement** → verify → uat. `/tasks` was written **after** implementation, not before. The `UNPINNED` verdict was honoured rather than waved through: `S9` was minted before the plan was written. |
| Hallucination | 0 | The one number I nearly asserted from memory — that the fixture would catch the pin-id defect — was proved with M2 instead of claimed. |

**The RED state was real:** 14 of 18 criteria failed before the fixture existed. The 4 that passed at
RED are documented in `coverage.md` rather than discovered here.

**The `/tasks` deviation, stated plainly.** The work-list this feature ran on was `coverage.md` —
16 criteria, each a unit of work, already frozen and already traced. `tasks.md` was written
afterwards and says so in its own first paragraph. Backdating it would have been the cheaper move
and the dishonest one.

Scored as a deviation rather than a skip because the substance was present and the artifact was
not. Whether `/tasks` earns its place when `coverage.md` is already the work-list is a real
question about the workflow, not an excuse for this run: filed as `B13`.

## 4. UAT — 2026-08-09

Walked criterion by criterion against `acceptance.md`. All 16 deterministic scenarios executed as
written; observable results match every `Then`. The two judgments follow.

### UAT-FIXTURE-INERT — **PASS**, with the boundary written down

Read with fresh eyes: 10 files, 3 of them the product half. `ledger.py` is a docstring, one import,
a two-line `total()` and a three-line `main()`. There is no argument parsing, no configuration, no
persistence and no error handling.

The strongest evidence it is not trying to work: the fixture **declares** pin `P4` (fail closed) and
implements nothing for it. Every line serves being governed — the marker so a stack detector fires,
the imports so a guard has something to inspect, the test so `scripts/test.sh` has something to run.

**The boundary, so this cannot rot into an application by accident.** It has crossed the moment it
gains argument parsing, configuration, a second product module, or a branch that exists for a user
rather than for a gate. The 15 lines of headroom under the budget are where that would happen.

### UAT-SECOND-DIVERGENCE — **YES**, found at `/distill`

The falsification test `alignment.md` set before the work began: *does a gate behave differently on
the fixture than on this repository, excluding the already-known pin-id defect?*

It does. `ground-rules` resolved `memory/stack/base/ground-rules.md` against the process cwd, so
pointing it at a vendored target reported `no ground rule file found` for a file sitting beside the
charter. Unknown before this feature, found in under a minute, fixed as R6.

**Severity stated rather than inflated.** `/plan` runs the command from the adopter's own root,
where cwd and artifact coincide, so no adopter had been misled. What the fixture proved is that the
gate could not survive being pointed anywhere else, which is the portability claim itself.

### Does each criterion move the brief's success metrics?

| Brief metric | Moved by | Evidence |
|---|---|---|
| a fixture exists, readable in one sitting | `ADOPT-FIXTURE-BUDGET` | 3 files / 25 lines |
| the harness vendors onto it and runs its gates, no manual step | `ADOPT-VENDOR-APPLY`, `ADOPT-GR-COVERED` | one `tests/run.sh` invocation |
| a gate behaving differently on a foreign target is caught | `ADOPT-REL-RESOLUTION`, mutation M2 | R6; 8 criteria fail under M2 |
| `UNCOVERED` fires on someone else's charter | `ADOPT-UNCOVERED-FIRES` | `GR4: uncovered`, exit 1 |
| a declared `Guard` is executed by name and its failure observed | `ADOPT-GUARD-BY-NAME/CLEAN/FAILS` | 2 guards, clean 0, violated non-zero |
| the fixture's test command runs, its result stays out of the count | `ADOPT-TESTCMD-INVOKED/NOT-COUNTED` | `adopter-suite: exit 0 (OK)`; totals unmoved |
| the fixture is DROP, suite green and hermetic | `ADOPT-FIXTURE-DROP`, `HERMETIC-ENV-98` | 474/0 |

No product gap found. Nothing routed to `/distill`.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ (one recorded deviation, `/tasks` written after implementation) · UAT: ✅ · coverage: 100% · retro: ✅
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/018-adoption-fixture/retro.md`.
Gaps routed: none.
