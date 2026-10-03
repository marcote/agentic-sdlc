---
name: clean-wrong-number
description: "Un predicado que descarta lo que no puede parsear reporta un número más chico, más limpio y equivocado"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 96ad9343-288b-40b5-a447-b02a18691bfd
  modified: 2026-08-18T21:05:10.451Z
---

Cuando un check selecciona sus inputs matcheando texto, lo que no matchea **no falla: desaparece**.
El resultado se lee mejor que la verdad.

Medido en 022: exigir el literal `tests/check_` en la columna de test reportó **47** criterios sin
declarar. El número real era **137** — descartaba en silencio los doce features previos a 015,
que escriben `check_92_stack.sh` sin directorio.

**Why:** el fracaso y el éxito renderizan idénticos. Es la familia de `B5`, `B9` y `B11` en el repo:
`check_90` no evaluaba un retro porque el reporte decía `BUILD ✅` en vez de `BUILD: ✅`, y nadie
lo notó hasta que un feature mergeó sin gate.

**How to apply:** cuando escribas un predicado que resuelve referencias, tres baldes y ninguno
silencioso — resuelto, *excluido por regla y contado*, e **irresoluble que aborta nombrando la fila**.
Si algo parece una referencia y no resuelve, es un defecto en el artefacto, no una exención.

Ver [[feature-022-mutation-coverage]].
