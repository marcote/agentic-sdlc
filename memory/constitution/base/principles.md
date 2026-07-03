# Constitution — Base Principles (heredado, no-negociable)

Estos principios son la capa más estable del static context. Todo spec, plan y
verificación debe cumplirlos. Se heredan vía `extends: base`.

1. **Verificabilidad.** Todo requerimiento se expresa como criterio de aceptación
   medible (BDD). Lo que no se puede verificar, no se construye.
2. **Test-first.** La porción determinista de cada criterio existe como test en 🔴 RED
   antes de escribir implementación (gate de `/contract`).
3. **Trazabilidad total.** Todo objetivo del brief llega a un criterio; todo criterio
   mapea a un eval o paso de UAT. Filas huérfanas = gap que bloquea el freeze del spec.
4. **Productividad primero.** La verificación es on-demand; nada bloquea commit/push.
5. **Rastro auditable.** Cada verificación produce un reporte versionado.
6. **Seguridad por defecto.** Ningún secreto en el repo; los patterns heredados
   (abajo) aplican salvo override justificado en el `constitution.md` del proyecto.
