---
name: wow-report
description: Agrega el ledger de retros en verification/wow-report.md — drift por pilar (mapping × veredicto de signal), re-chequeos pendientes, salud del método y olores de teatro. Observabilidad on-demand, nunca gatea. Usar para responder "¿está funcionando el WoW?".
---

# WoW Report

Entrada: todos los `specs/*/retro.md`, sus `alignment.md`, y `verification/reports/*`.
Salida: `verification/wow-report.md` (snapshot generado y commiteado). **Observa, nunca
gatea** — el diente determinista es `tests/check_90_retro.sh`; esto es síntesis para el
humano.

## Procedimiento
Regenerá `verification/wow-report.md` con cinco secciones:

1. **Misión — ¿cada pilar del North Star está siendo servido?** Cruzá el `mapping`
   objetivo→pilar de cada `alignment.md` con el veredicto de signal del `retro.md`. Tabla
   por pilar: features que dijeron servirlo × si el signal se movió. **Un pilar con
   features que lo prometieron pero ningún signal movido = drift medible** (destacalo).

2. **Re-chequeos pendientes (worklist).** Juntá los `pending-observation` con su trigger;
   marcá los vencidos.

3. **Método — ¿el WoW agrega valor?** (N=<n>, muestra chica, sin estadística). Tabla
   por-feature: gaps cazados, disciplina RED, rework verify/uat, escalaciones. Agrupá
   temas de fricción recurrentes.

4. **Loop — ¿el WoW se mejora a sí mismo?** Reglas candidatas propuestas vs aterrizadas
   en constitution; amendments propuestos vs aprobados (ADR).

5. **Olores de teatro (spot-check humano, Capa 4).** Marcá retros sospechosos: celdas de
   Evidencia vacías, all-green (cero gaps + cero rework + cero fricción),
   `pending-observation` vencidos. Un retro demasiado limpio ES una señal.

## Honestidad del N=1
El reporte declara explícito "N=<n>, muestra chica, sin estadística". No finge
tendencias; muestra por-feature + totales + temas.
