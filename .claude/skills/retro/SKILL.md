---
name: retro
description: Cierra la predicción de /align al cerrar un feature — dicta el veredicto sobre el signal del pilar y deriva las señales del WoW de artefactos. Escribe specs/<feature>/retro.md. Usar tras un /verify+/uat en verde, como paso final del cierre.
---

# Retro

Entrada: `specs/<feature>/alignment.md` + `coverage.md` + `verification/reports/<feature>` + git.
Salida: `specs/<feature>/retro.md` (plantilla en `specs/_template/retro.md`). Es la
**mitad trasera de la Measurability Gate**: `/align` abrió una predicción medible; el
retro la cierra. El feature no está DONE hasta que este retro cierra sus tres caras.

## Anti-teatro (por qué el orden importa)
Un check no puede probar honestidad. El procedimiento achica el lugar donde el relleno
"por cumplir" se esconde: **derivar → auto-desafiar → escribir**, nunca al revés.

## Procedimiento

1. **Derivá primero (Cara B, Capa 1).** No tipees cifras de memoria. Cada campo de
   Método sale de un artefacto con su `[deriv: <locator>]`:
   - Gaps cazados por /distill → filas de `coverage.md` + `git log` de la fase distill.
   - Disciplina RED→GREEN → historial de estados de `coverage.md` (🔴 antes de 🟢) + git.
   - Rework post-/verify y post-/uat → gaps ruteados en `verification/reports/<feature>`.
   - Escalaciones → traza / git.
   Solo "Fricción del propio WoW" es juicio libre; el resto es derivado.

2. **Dictá la Cara A con evidencia locator obligatoria (Capa 2).** Leé `alignment.md`:
   para cada pilar del `mapping`, buscá su `signal` en `north-star.md` y dictá veredicto
   (`✅ movió` / `❌ no movió` / `⏳ aún no observable`) con una celda de Evidencia que sea
   un **locator** (valor, SHA, fila de coverage, URL) — no prosa. Sin locator para un
   `confirmed`/`refuted`, el veredicto honesto es `pending-observation` con su trigger de
   re-chequeo. Anotá la **calibración de align** (¿los scores pillarFit/scope/mission
   acertaron?). Si el North Star del repo es placeholder (no schema-válido), la Cara A es
   `n/a` con razón — no hay signal real que cerrar.

3. **Auto-desafío adversarial (Capa 3).** Antes de escribir, argumentá EN CONTRA de tu
   propio borrador: "el report dice 0 rework — verificá contra `git log`; dice que el
   pillar-fit de align fue exacto — sostené lo opuesto". Solo lo que sobrevive al desafío
   se escribe. (Refuerzo futuro, no ahora: delegar el desafío a un subagente sképtico
   separado del que redactó.)

4. **Cara C (loop).** Proponé reglas candidatas → constitution y/o amendments → North
   Star. Solo proponé; aplicarlos sigue `update-checklist.md` / `amendment-protocol.md`.

5. **Veredicto de misión.** `confirmed` | `refuted` | `pending-observation` (+trigger) |
   `n/a` (+razón obligatoria). Escribí `specs/<feature>/retro.md` desde la plantilla.

## Gate
`tests/check_90_retro.sh` exige, para todo feature con reporte DONE: retro presente, sin
placeholders, veredicto de misión válido, evidencia no vacía para `confirmed`/`refuted`,
`[deriv:]` en cada campo de Cara B, y razón para `n/a`. El feature no está DONE sin
`retro ✅`.
