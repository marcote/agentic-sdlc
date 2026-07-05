# Verification Report — <feature> @ <commit/ref>

spec: <spec.md vN> · fecha: <YYYY-MM-DD> · constitution: base v<X> + proyecto v<Y>

## 1. Coverage snapshot
_(copiado de coverage.md: criterio → estado → test/eval ligado)_

## 2. Output eval (BUILD)  — determinista, corre en /verify
_(por criterio: test → pass/fail | Task success: N/N = %)_

## 3. Trajectory eval  — no-determinista, LM judge sobre la traza
_(tool use: score/umbral | pasos saltados: … | hallucination: N)_

## 4. UAT  — agregado por /uat, contra acceptance.md
_(escenario BDD → walked → pass/fail → nota; los fallos de UAT son gaps de PRODUCTO → /distill)_

## 5. Verdicto
BUILD: <✅/❌> · TRAJECTORY: <✅/❌> · UAT: <✅/❌> · coverage: <N%> · retro: <✅/pendiente>
Cierra ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅.
Retro: `specs/<feature>/retro.md` (cierra la predicción medible de `/align`).
Gaps ruteados: _(a /verify=implementación, a /distill=producto)_
