---
name: writing-terse
description: "Precisos, no elocuentes — una oración una idea, máx 35 palabras, negrita solo si cambia una decisión"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 96ad9343-288b-40b5-a447-b02a18691bfd
  modified: 2026-08-10T00:16:45.522Z
---

Marcos, en dos pasos: *"tendriamos que ser mas como hemingway"* y después *"tenemos que buscar ser
precisos, no elocuentes porque nos perdemos"*.

**Precisión y brevedad son palancas distintas.** Corto no es exacto. Los tres errores que cometí en
la sesión del 2026-08-09 eran frases claras, cortas y equivocadas: "3 de 5 filas" (eran 2), el
propósito de `AMEND-PROV-ONLY` (falso), "12 gaps" en 013 (eran 8). Ninguno era vago.

**Qué los causó:** escribir una cifra de memoria en vez de correr el comando que la calcula.
**Qué los evita:** derivar primero, escribir después, y dejar el locator. Está en `docs/backlog.md`
B10 porque no le encontré forma mecánica.

**How to apply:**
- Una oración, una idea. Máx 35 palabras (regla `D5`, chequeada por `scripts/prose.sh`).
- Negrita solo para el dato que cambia una decisión. Medido: había 71 negritas por 100 líneas de
  prosa, una cada 1,4 líneas. Cuando todo está enfatizado el énfasis no informa.
- La raya larga (—) casi siempre son dos oraciones. Medido: 21,6 por 100 líneas.
- Nada de cierres aforísticos. Suenan a conclusión y no aportan.
- Un número, un locator, o decir explícitamente que es juicio.
- Si el mensaje tiene tres párrafos de contexto y una conclusión, borrar los tres párrafos. Se
  quejó dos veces: *"mucho texto, poca info"* y *"no te sigo"*.

**Trampa a evitar:** responder a este feedback metiendo otra regla en el repo. Ya va una por turno,
y la queja es que nos perdemos.

Ver [[working-style]] y [[wow-backlog-discipline]].
