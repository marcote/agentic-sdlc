# Checklist para actualizar la constitution

Cuando el agente comete un error repetible o cambia una regla:

- [ ] ¿Es un principio universal? → `base/principles.md`. ¿O una práctica con criterios? → nuevo `base/patterns/<x>.md`.
- [ ] Si es un pattern: incluí la sección `**Criterios inyectados:**` con al menos un `[given]`.
- [ ] ¿Es específico del proyecto? → `constitution.md` (deltas/overrides).
- [ ] Actualizá la fecha/razón en el commit.
- [ ] Re-copiá `base/` a los proyectos que la heredan (vendored).
