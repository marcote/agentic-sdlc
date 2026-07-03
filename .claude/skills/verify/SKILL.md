---
name: verify
description: Verificación on-demand de un feature. Corre output + trajectory eval y emite el verification-report. Usar al cerrar la implementación de un feature.
---

# Verify

## Procedimiento
1. Copiá `verification/verification-report.md` a `verification/reports/<feature>-<ref>.md`.
2. **Output eval (BUILD):** corré los tests deterministas ligados en `coverage.md`.
   Task success = green/total. Umbral 100% (no-negociable).
3. **Trajectory eval:** puntuá contra `evals/rubric.md` (tool use, pasos saltados,
   hallucination). Un flujo que saltó verificación es FAIL aunque el build pase.
4. Actualizá los estados en `coverage.md` (🔴→🟢) y completá el Verdicto.
5. Si BUILD/TRAJECTORY fallan → gap de IMPLEMENTACIÓN → volvé a implementar.
   NO llames a UAT ni a evals no-deterministas de cierre desde aquí.
