# Code Review Checklist — código generado por IA

> "AI-generated code requires the same or greater scrutiny than human-written code."

- [ ] Imports/dependencias existen y son las correctas (sin paquetes alucinados).
- [ ] Error handling cubre modos de falla realistas, no solo el happy path.
- [ ] No hay secretos hardcodeados.
- [ ] El código cumple los patterns `[given]` aplicables (audit-log, rate-limit, idempotency…).
- [ ] La lógica "que parece correcta" fue verificada contra el criterio, no asumida.
- [ ] Cambios trazables a filas de `coverage.md`.
