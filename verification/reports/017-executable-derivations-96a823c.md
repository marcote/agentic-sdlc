# Verification Report — 017-executable-derivations @ 96a823c

date: 2026-08-09 · charter gate `PASS` · constitution: base + D1–D5 + the non-vacuous override

## 1. Coverage snapshot
13 deterministic 🟢 · 1 `📋 case` · 3 `deferred`.

## 2. Output eval (BUILD)
**13/13 = 100%.** Suite **450 PASS / 0 FAIL** (pre-017 baseline 436).
Guards: `no-prescribe.sh` exit 0. `nvc.sh`: traceability, selfscan, duplicates all exit 0.
Failability: M1 2 FAIL · M2 1 · M3 5 · M4 1.

## 3. Trajectory eval
| Dimension | Result | Note |
|---|---|---|
| Tool use | ✅ | Gates run with their real engines. |
| Trajectory compliance | ✅ | No step skipped. Real RED at 439/9 before implementation. |
| Hallucination | 0 | bash and coreutils only, no new engine. |
| Response quality | pending | `JUDGE-DERIV-HONEST` needs an independent judge. |

## 4. UAT
All criteria walked → ✅. R5 narrowed at implementation and routed back: nine retros exist, three
could be migrated. The other six have no countable section, and 013 cannot be reproduced at all.

**The falsification test set at `/align` is answered: no.** It asked whether the check would find a
number no human noticed, explicitly excluding 013. Across 014, 015 and 016 every derivation agrees.
So `measurable-impact` is **⏳**, not ✅ — the mechanism is built and has produced exactly one
finding, the one that motivated it.

## 5. Verdict
BUILD ✅ · TRAJECTORY ✅ · UAT ✅ · coverage 100% · retro ✅ → **DONE**

**Gaps routed:** one to `/distill` (product): R5's scope was wider than the artifacts allow.
