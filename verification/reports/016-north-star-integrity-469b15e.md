# Verification Report — 016-north-star-integrity @ 469b15e

spec: `specs/016-north-star-integrity/spec.md` · date: 2026-08-09 ·
constitution: base + D1–D4 + the `non-vacuous-checks` override · charter: 9 pins, gate `PASS`

## 1. Coverage snapshot
20 deterministic 🟢 · 1 `📋 case` · 2 `deferred`. Full table in `coverage.md`.

## 2. Output eval (BUILD)
**20/20 = 100%.** Suite **427 PASS / 0 FAIL** (pre-016 baseline 410).
Guards: `no-prescribe.sh` exit 0 — one declared, one run, one green.
`nvc.sh`: traceability 0 · selfscan 0 · duplicates 0 over the whole tree.
Hermeticity: fresh clone, detached HEAD, no local `main`, stdin `/dev/null`.

Failability per rule, one isolated sandbox each: F1 4 FAIL · F2 1 · F3 1 · F4 1 · F5 1+3.

## 3. Trajectory eval
| Dimension | Result | Note |
|---|---|---|
| Tool use | ✅ | Every gate run with its real engine; `amendment-gate` over a verified non-empty range. |
| Trajectory compliance | ✅ | brief → align → distill → plan → contract → tasks → implement → verify → uat. Real RED at 414/12 before implementation. |
| Hallucination | 0 | No dependency invented; python3 stdlib + bash/coreutils. |
| Response quality | pending | `JUDGE-PROVENANCE-USEFUL` unscored — cannot be judged before the 2026-09-08 sweep. |

## 4. UAT
20/20 walked → ✅. Both gate-note risks tested against the real thing, not the happy path:
a to-do-domain North Star validates (and is refused the moment the discriminator becomes the bare
word `TODO`), and migration cost was **one field per pillar**, as the brief claimed.

**Two of this feature's own assertions were vacuous and both were caught** (`coverage.md`):
`ALIGN-STAMPS-PROVENANCE` grepped an ordinary English word; `AMEND-PROV-ONLY` cannot reach the
code it claimed to test, proved by mutation. `AMEND-PROV-FRESH` was added as the real paired
positive. Neither was found by `nvc.sh` — both are semantic vacuity, which the pattern states is
out of mechanical scope. **That is the second consecutive feature where the mechanical half missed
the vacuity and reading caught it.**

## 5. Verdict
BUILD: ✅ · TRAJECTORY: ✅ · UAT: ✅ · coverage: 100% (20/20) · retro: ✅ → **DONE**

**Gaps routed:** one to `/distill` (**product**) — `AMEND-PROV-ONLY`'s stated purpose was wrong in
`coverage.md` and needed a new criterion, not a code change. None to implementation.
