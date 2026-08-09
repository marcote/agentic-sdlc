# Verification Report — 015-non-vacuous-checks @ 83d3533

spec: `specs/015-non-vacuous-checks/spec.md` (R4 corrected at implementation) · date: 2026-08-09 ·
constitution: base (incl. `non-vacuous-checks`, landed 2026-08-09) + project D1–D4 ·
charter: `memory/stack/stack.md`, 9 pins, gate verdict `PASS`

## 1. Coverage snapshot

19 deterministic criteria 🟢 · 1 `📋 case` · 3 `deferred` (reasons in `coverage.md`).

| Criterion | State | Linked test |
|---|---|---|
| NVC-DECLARED-EMITTED · NVC-DECLARE-FORMS · NVC-ZERO-FP | 🟢 | `tests/check_96_non_vacuous.sh` |
| NVC-LABEL-SCOPED · NVC-LABEL-SAMEFILE | 🟢 | idem *(R4 corrected — see §5)* |
| NVC-SKIP-EXPLICIT · NVC-SKIP-EXPLICIT-HELPER | 🟢 | idem |
| NVC-INNER-GUARD · NVC-RED-SUITE | 🟢 | idem |
| NVC-SELFSCAN-ASSEMBLED · NVC-SELFSCAN-CLOSED · NVC-SELFSCAN-SELFTEST | 🟢 | idem |
| NVC-FIX-82 · NVC-CAN-FAIL · NVC-DEPFREE · NVC-SCOPE-STATED · NVC-SELF | 🟢 | idem |
| HERMETIC-ENV-96 · HERMETIC-ENV-96-SELF | 🟢 | idem |
| JUDGE-SCOPE-HONEST | 📋 case | `evals/cases/non-vacuous-scope-judge.md` |

## 2. Output eval (BUILD)

**Task success: 19/19 = 100%.** Suite **404 PASS / 0 FAIL** (pre-015 baseline 385).

The deliverable run against the standing suite — the check judging the tree it ships into:

```
scripts/nvc.sh traceability --tests tests --output <run log>   → exit 0, 97 labels
scripts/nvc.sh duplicates   --tests tests                      → exit 0
scripts/nvc.sh selfscan     --tests tests                      → exit 0
```

**Guards** (`stack/engine.py guards`, run by name only, never second-guessed):
`bash scripts/guards/no-prescribe.sh` → **exit 0**. One guard declared, one run, one green.

**Hermeticity:** fresh clone, `--detach HEAD`, local `main` deleted, stdin `/dev/null` →
**404 PASS / 0 FAIL**. Run against a *committed* tree, not the working copy — the operator error
that produced a false verdict on 2026-08-09.

**Failability, per rule, one isolated sandbox each:**

| fixture | mutation | result |
|---|---|---|
| F1 | traceability comparison neutered | 4 FAIL |
| F2 | heredoc stripping disabled | 2 FAIL |
| F3 | self-scan literal detection removed | 1 FAIL |
| F4 | fail-closed removed (**both** branches) | 2 FAIL |
| F5 | inner guard removed | recursion; the run hangs |

## 3. Trajectory eval

| Dimension | Result | Note |
|---|---|---|
| Tool use | **✅** | Every gate run with its real engine: `north-star/engine.py` for `/align`, `stack/engine.py` for the `/plan` gate, `no-prescribe.sh` as `S1`'s guard. `amendment-gate` run over a **verified non-empty** range. |
| Trajectory compliance | **✅** | brief → align → distill → plan → contract → tasks → implement → verify. No step skipped. `/contract` produced a real RED (386/17) before any implementation. |
| Hallucination | **0** | No dependency invented; `bash`, `awk`, `grep`, `sed` only. `assert_dep_free` confirms it. **One near-miss caught by measurement, not by review:** `timeout` was used in the first draft of the recursion guard — it does not exist on macOS, exits 127, and the assertion passed for an unrelated reason. Replaced by counting the runner's own section headers. |
| Response quality | **pending** | `JUDGE-SCOPE-HONEST` unscored — an independent judge is required, per 013 and 014's precedent. |

**Trajectory note, recorded because it is the honest reading:** one criterion was **corrected after
being frozen** (§5). The flow handled it as designed — routed back with the reason written down —
but a frozen criterion changing is a signal, not a neutral event, and `/retro` must judge whether
`/distill` should have caught it.

## 4. UAT

19/19 deterministic criteria walked → **✅**. Full table in `coverage.md`.

**The falsification test set at `/align`, answered: yes — fifteen previously unknown instances**
across `check_82`, `84`, `86`, `88`, `95`, from features 004, 006, 007, 008 and 009. Nine in
`check_95` alone, where `gate_pass`/`gate_block` printed `gate PASSES: <desc>` with no criterion
label, so every amendment-gate criterion had been untraceable since feature 004. All fifteen fixed.

**One PRODUCT gap, found at UAT and routed to `/distill`: `NVC-ZERO-FP` was itself vacuous.** It
ran `--declarations-only`, `selfscan` and `duplicates` but **never `traceability` against a real
run log** — so the suite read 404/0 while fifteen criteria were untraceable. Corrected to consume
the same real log as `NVC-INNER-GUARD`, and proved failable.

That defect was caught by hand, not by any assertion. It is the honest limit of the mechanical
half and it belongs in the retro.

## 5. Verdict

BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% (19/19 deterministic) · retro: ✅ → **DONE**

Suite **399 PASS / 0 FAIL** at close (404 mid-implementation; several bare `assert_*` calls were
consolidated into single labelled emissions — fewer assertions, same criteria, all attributable).

**Gaps routed:** two to `/distill` (**product**), none to implementation.

> **`NVC-LABEL-UNIQUE` → `NVC-LABEL-SCOPED`.** The frozen criterion demanded global label
> uniqueness. Against the standing green suite it fired **four times** — `HERMETIC-ENV`,
> `SELF-CHECK`, `DEP-FREE`, `DEPFREE` — and none were defects: an inherited `[given]` criterion is
> *supposed* to recur in every feature that carries it. `run.sh` already sections its log by file,
> so `(file, label)` attribution existed all along. The replacement is **stronger**: it catches a
> result emitted under the wrong file, which uniqueness could never detect.
>
> This is a **product gap**, not an implementation one: the spec was wrong, and working around it
> in code would have been the quiet relaxation this feature's `alignment.md` scored as a
> commitment.

**Three defects found by the deliverable during its own construction**, each in the family it
targets: fixture strings parsed as phantom declarations (110 labels instead of 97); `selfscan`
flagging `check_96` for a `grep` inside a fixture heredoc — the tool producing on its own file the
exact false positive it exists to catch; and a quoting slip that made `strip_heredocs` return
**zero** declarations, which every downstream assertion would then have satisfied vacuously.

**`D4` discharged.** `NVC-INNER-GUARD` confirms all 19 of `check_96`'s own labels emit inside the
nested run. The meta-check is judged by the rule it enforces, and the pass is not trivial: F2
made it fail by inflating its own declaration count to 36.
