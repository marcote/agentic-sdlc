---
name: uat
description: UAT guiado de un feature contra acceptance.md y el objetivo del brief. Usar tras un /verify en verde.
---

# UAT

## Procedimiento
1. Recorré `verification/uat-checklist.md` criterio por criterio contra `acceptance.md`.
2. Preguntá para cada criterio: cumplido, ¿mueve la métrica de éxito del brief?
   Si NO → gap de PRODUCTO → routeá a `/distill` (el spec estaba incompleto).
3. Actualizá `coverage.md` (→ ✅ uat) y la sección UAT + Verdicto del reporte en
   `verification/reports/`.
4. El feature cierra ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%.
