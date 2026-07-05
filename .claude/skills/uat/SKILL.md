---
name: uat
description: Guided UAT of a feature against acceptance.md and the brief's objective. Use after a green /verify.
---

# UAT

## Procedure
1. Walk through `verification/uat-checklist.md` criterion by criterion against `acceptance.md`.
2. Ask for each criterion: fulfilled, does it move the success metric from the brief?
   If NO → PRODUCT gap → route to `/distill` (the spec was incomplete).
3. Update `coverage.md` (→ ✅ uat) and the UAT + Verdict section of the report in
   `verification/reports/`.
4. The feature closes ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
