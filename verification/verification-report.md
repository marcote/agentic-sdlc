# Verification Report — <feature> @ <commit/ref>

spec: <spec.md vN> · date: <YYYY-MM-DD> · constitution: base v<X> + project v<Y>

## 1. Coverage snapshot
_(copied from coverage.md: criterion → state → linked test/eval)_

## 2. Output eval (BUILD)  — deterministic, runs in /verify
_(per criterion: test → pass/fail | Task success: N/N = %)_

## 3. Trajectory eval  — non-deterministic, LM judge over the trace
_(tool use: score/threshold | skipped steps: … | hallucination: N)_

## 4. UAT  — appended by /uat, against acceptance.md
_(BDD scenario → walked → pass/fail → note; UAT failures are PRODUCT gaps → /distill)_

## 5. Verdict
BUILD: <✅/❌> · TRAJECTORY: <✅/❌> · UAT: <✅/❌> · coverage: <N%> · retro: <✅/pending>
Closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/<feature>/retro.md` (closes the measurable prediction from `/align`).
Gaps routed: _(to /verify=implementation, to /distill=product)_
