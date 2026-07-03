---
description: Descomponer en tasks ejecutables. GATE test-first — rechaza si falta contrato RED.
---

GATE (machine-checkable, no discrecional): recorré `coverage.md`. Para CADA fila
determinista, exigí `test ligado != vacío AND estado == 🔴 RED`. Si alguna no cumple,
NO emitas tasks de implementación: reportá las filas faltantes y frená.
Solo si el gate pasa, escribí `specs/<feature>/tasks.md` (cada task liga sus filas de coverage).
