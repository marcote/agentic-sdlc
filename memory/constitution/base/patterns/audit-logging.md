# Pattern: Audit Logging (given practice)

**Principio:** toda operación que escribe estado deja rastro auditable.
**Aplica a:** cualquier feature con endpoints/acciones de escritura.
**Criterios inyectados:**
- `[given]` cada operación de escritura emite audit-log con `actor` + `timestamp` + `entidad`.
  → mapea a `eval: audit-trail`.
