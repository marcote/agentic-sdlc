---
name: wow-backlog-discipline
description: "Los hallazgos van a docs/backlog.md, no al próximo feature — causa raíz de la no-convergencia"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 96ad9343-288b-40b5-a447-b02a18691bfd
  modified: 2026-08-09T15:23:49.668Z
---

Cuando aparece un hallazgo real durante un feature, **no encadenarlo al feature siguiente**.
Va a `docs/backlog.md` con estado, tamaño y por qué se difiere. Sale de ahí sólo de dos formas:
se convierte en `specs/NNN-*`, o se dropea **con razón escrita**. El silencio no es una
disposición.

**Why:** Marcos frenó la sesión con *"arreglamos, algo no salió, pero van el próximo. y así
sucesivamente. no terminamos más"*. La causa raíz no era que los hallazgos fueran malos — era
que cada uno se convertía en el próximo feature, así que el loop nunca convergía. Corolario que
Marcos rechazó explícitamente: **no** proponerle parar el harness para construir un proyecto
real como prueba empírica. El harness tiene que brindar gobierno; eso es un reclamo analítico,
no uno que necesite evidencia de campo.

**How to apply:** ante un hallazgo mid-feature, escribir la línea de backlog y seguir con el
feature en curso. Y para lo ya diferido: un `pending-observation` sin fecha se pierde — 006
estuvo 35 días con la evidencia ya disponible. Todo diferimiento lleva **evento + fecha de
barrido**, lo que llegue primero.

Ver [[feature-013-stack-charter]] y [[working-style]].
