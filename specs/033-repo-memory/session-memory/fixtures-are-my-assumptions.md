---
name: fixtures-are-my-assumptions
description: "Un set de fixtures construido solo con las formas que espero es un inventario de mis supuestos, no una prueba"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 96ad9343-288b-40b5-a447-b02a18691bfd
  modified: 2026-08-18T21:29:56.665Z
---

En 023 escribí **siete fixtures** para el gate de casos. Todas con labels `UPPER-KEBAB`, porque
cada criterio del harness se ve así. El defecto lo encontró el **repo real** en la primera corrida:
`001-example` tiene un criterio en prosa, *"message clarity"*, y yo borraba espacios internos en vez
de recortar los de los bordes. Reportó `UNBOUND` contra un archivo correcto.

**Why:** ninguna de las siete podía haberlo agarrado. Las escribí desde las formas que ya tenía en
la cabeza, así que probaban mi modelo, no el mundo.

**How to apply:** cuando el artefacto real existe, **corré contra el artefacto real además de las
fixtures**, y hacelo temprano — no al final como confirmación. Las fixtures cubren los casos de
error que no ocurren naturalmente; el repo cubre las formas que no imaginé.

Corolario del mismo feature: un fixed-index parser sobre una tabla markdown **no falla** con otra
cantidad de columnas — lee la columna equivocada y reporta con confianza. Ver
[[clean-wrong-number]].
