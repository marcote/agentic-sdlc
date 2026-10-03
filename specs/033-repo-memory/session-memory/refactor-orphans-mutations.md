---
name: refactor-orphans-mutations
description: "Mover código deja las declaraciones [mut$] apuntando a la nada — y los criterios siguen verdes"
metadata:
  node_type: memory
  type: feedback
---

En 026 moví la resolución de columnas de `cases.sh` y `mutate.sh` a `matrix.sh`. **Cuatro
declaraciones de 022 y 023 quedaron editando código inexistente.** `sed` no matcheaba nada, los
criterios seguían pasando, y cuatro criterios probados quedaron **infalsificables sin que nadie
tocara una línea de ellos**.

Es la forma que 021 nombró — *"la mutación no se degradó por débil; el criterio cambió debajo"* —
pero acá se mudó la **implementación**.

**Why:** una declaración que no matchea se reporta igual que una mutación débil. Son fallas
distintas: una es *stale*, la otra es *floja*.

**How to apply:** después de mover código entre archivos, **corré la suite completa de mutaciones**,
no `--only`. Yo dejé de correrla al pasar a arreglar de a una, pasó local y **falló en CI**.
Candidato mecánico en `B22`: que `mutate.sh` reporte *"el edit no cambió ningún byte"* como
resultado propio.

Ver [[feature-026-matrix-parser]].
