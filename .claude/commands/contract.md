---
description: Generar el contrato de tests (determinista) y eval cases (no-determinista) y probar que está RED.
---

Para cada criterio de `acceptance.md`:
- Determinista → generá el test (BDD) y ligalo en `coverage.md`. CORRÉ el suite: debe estar 🔴 RED
  (prueba que el test es real y el feature no existe). Registrá el test ligado por criterio.
- No-determinista → creá un case en `evals/cases/` (estado 📋).
No marques ninguna fila como lista hasta confirmar el estado RED (deterministas) o case presente.
