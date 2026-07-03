# UAT Checklist — <feature>

> Se recorre en `/uat`, contra `acceptance.md`. El UAT valida contra el OBJETIVO
> (brief), no solo contra el spec — por eso puede revelar gaps de producto.

Por cada criterio de aceptación:
- [ ] Escenario BDD ejecutado tal como está escrito.
- [ ] Resultado observable coincide con el `Then`.
- [ ] ¿El criterio, cumplido, mueve la métrica de éxito del brief? (si no → GAP de producto → `/distill`)
- [ ] Estado actualizado en `coverage.md` (→ ✅ uat).
