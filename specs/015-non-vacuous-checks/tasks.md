# Tasks — The meta-check

> Executable decomposition. Order is dependency-driven, and **T5 precedes T6 deliberately**: `D4`
> requires the feature to be in compliance with its own rule before the final verify, not after.
> Re-run `bash tests/run.sh` after each. Done when all 19 deterministic criteria are 🟢 and the
> suite is ≥ **385 PASS / 0 FAIL** (the pre-015 baseline).

## T1 — `tests/check_96_non_vacuous.sh` in 🔴 RED (`/contract`)
All 19 deterministic criteria as assertions against `scripts/nvc.sh`, which does not exist yet.
Each criterion gets a negative fixture in its **own sandbox** (D7) — a shared sandbox is how two
fixture harnesses leaked state on 2026-08-09.
- Criteria: all 19 → 🔴.

## T2 — `scripts/nvc.sh`: declarations, duplicates
Parse `# --- LABEL:` headers and `_pass`/`_fail "LABEL:` calls, **excluding heredoc bodies**.
Reject a label declared in two files, naming both.
- Criteria: **NVC-DECLARE-FORMS**, **NVC-LABEL-UNIQUE**.

## T3 — `scripts/nvc.sh`: traceability, fail-closed
Cross-reference declarations against a captured run log. Accept `PASS:`/`FAIL:`/`SKIP:`. On an
empty or unusable log, **name what was executed and emit no verdict** (`S8`).
Add `_skip()` to `tests/lib.sh`.
- Criteria: **NVC-DECLARED-EMITTED**, **NVC-SKIP-EXPLICIT**, **NVC-RED-SUITE**.

## T4 — `scripts/nvc.sh`: the self-scan rule
Trigger on the **target set**, not the presence of a scan: a scan whose target glob can contain the
scanning file must use a runtime-assembled pattern and declare a self-test. A closed, explicitly
named target set that excludes the scanner is not flagged.
- Criteria: **NVC-SELFSCAN-ASSEMBLED**, **NVC-SELFSCAN-SELFTEST**.

## T5 — Bring the suite into compliance (`D4` condition 3, before T6)
Fix `check_82`'s `DEP-FREE` (label the `assert_dep_free` call). Wire the inner run with its partial
guard. Run `nvc.sh` against the real suite until clean — **including `check_96` and `nvc.sh`
themselves**. A trivial pass because the check never examines itself does not discharge `D4`.
- Criteria: **NVC-FIX-82**, **NVC-INNER-GUARD**, **NVC-ZERO-FP**.

## T6 — Close the RED and re-verify
`NVC-CAN-FAIL` proved per rule, one sandbox each. `NVC-DEPFREE` via the shared helper **with its
criterion label** — the 008 defect this feature exists to catch. `NVC-SCOPE-STATED` in the shipped
file's header, including that an undeclared criterion is invisible to it.
- Criteria: **NVC-CAN-FAIL**, **NVC-DEPFREE**, **NVC-SCOPE-STATED**, `hermetic-env`; all 19 → 🟢.

---

## Not in this breakdown
- **`JUDGE-SCOPE-HONEST`** is a `📋 case` in `evals/cases/`, exercised at `/verify`, and stays open
  past close unless an independent judge scores it — 013 and 014's precedent, same reasoning.
- **The three `deferred` rows** (`hermetic-offline`, `S1-NO-PRESCRIBE`, `S2-HEDGE`) carry their
  reasons in `coverage.md`. `S2-HEDGE` revives if implementation reaches for python3.
