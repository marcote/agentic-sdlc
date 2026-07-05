# Retro — <feature> @ <commit>

cierra: `specs/<feature>/alignment.md` · `verification/reports/<feature>` · fecha: <YYYY-MM-DD>

> Cierra la predicción medible que abrió `/align` (columna align↔retro). Un feature no
> está DONE hasta que este retro cierra sus tres caras. Diseño:
> `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`.

## Cara A — Misión (cierra la predicción de /align)
Fuente: `specs/<feature>/alignment.md` (mapping objetivo→pilar) + `north-star.md` (signal por pilar).

| Pilar (mapping) | Signal predicho | Veredicto | Evidencia (locator OBLIGATORIO) |
|---|---|---|---|
| <pilar-id> | <signal del North Star> | ✅ movió / ❌ no movió / ⏳ aún no observable | <valor/SHA/fila-coverage/URL — no prosa> |

- **Calibración de align:** <los scores pillarFit/scope/mission de alignment.md, ¿acertaron en retrospectiva?>
- **Veredicto de misión:** <confirmed | refuted | pending-observation | n/a>
  - si `confirmed`/`refuted` → la(s) celda(s) Evidencia arriba NO pueden estar vacías.
  - si `pending-observation` → **trigger de re-chequeo:** <cuándo / qué señal mirar>
  - si `n/a` → **razón:** <por qué este feature no cierra contra ningún signal>

## Cara B — Método (valida el WoW) — DERIVADA de artefactos, no redactada
Cada campo trae su `[deriv: <locator>]`. Sin locator = inválido.

- **Gaps cazados por /distill:** <N> `[deriv: <coverage.md / git log de distill>]` — <los jugosos>
- **Disciplina RED→GREEN:** <sí / no + excepciones> `[deriv: <historial de estados coverage.md + git>]`
- **Rework post-/verify:** <N> · **post-/uat:** <N> `[deriv: <gaps ruteados en verification/reports/<feature>>]`
- **Escalaciones al humano:** <N> `[deriv: <traza / git>]` — <por qué>
- **Fricción del propio WoW:** <qué del harness estorbó o faltó> (único campo de juicio libre)

## Cara C — Loop (auto-mejora)
- **Reglas candidatas → constitution:** <regla o "ninguna"> (aplicar vía `memory/constitution/update-checklist.md`)
- **Amendments candidatos → North Star:** <ADR propuesto o "ninguno"> (vía `memory/north-star/base/amendment-protocol.md`)
