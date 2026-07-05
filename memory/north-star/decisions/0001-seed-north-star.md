# 0001 — Seed del North Star del harness

> ADR fundacional: el primer poblado del North Star de este repo (de placeholder a
> real). Registra el rationale del seed y sienta el precedente de que todo cambio
> posterior a `pillars`/`scope` va por `base/amendment-protocol.md`.

## Contexto

`memory/north-star/north-star.md` era un **placeholder** (`_(completar por proyecto)_`)
porque el repo se trataba como "la plantilla, el adoptante la completa". Pero el repo es
un **producto real** — un harness reutilizable de SDLC agéntico — y venía operando sin
declarar *para qué existe*. Dos presiones lo motivaron:

1. Sin North Star schema-válido, `/align` es fail-closed: no se puede gatear ningún brief
   contra la misión, y la **Cara A (Misión) del retro** cierra siempre `n/a` (ver
   `docs/superpowers/specs/2026-07-05-wow-self-validation-design.md`). El loop align↔retro
   quedaba estructuralmente incompleto.
2. Falta de un norte explícito para decidir qué features pertenecen al harness y cuáles
   no (p. ej. "install desde github" pertenece; "código de app del adoptante" no).

## Decisión

Poblar el bloque JSON canónico de `north-star.md`. **Before:** todos los campos en
`_(completar por proyecto)_` (no schema-válido). **After:**

- `mission`: "Un harness reutilizable y agnóstico de stack que hace cumplir un SDLC
  agéntico disciplinado … sin escribir código de producto." (ver el JSON en
  `north-star.md`).
- `pillars`: tres — `enforcement-real`, `portabilidad-agnostica`, `adopcion-sin-friccion`,
  cada uno con `statement` + `signal` medible. La auto-validación/dogfooding **no** es un
  pilar aparte: es el `signal` de `enforcement-real`.
- `scope.in_scope` / `scope.out_of_scope`: poblados (ver el JSON).
- `alignment.threshold`: 3.

## Scope-delta

Todo el `scope` entra por primera vez (before: vacío/placeholder). Predicados
`out_of_scope` que ahora son rechazo duro de `/align`: código de aplicación del adoptante;
motor determinista per-stack; imponer un runtime obligatorio; hooks bloqueantes por
commit; dependencias de runtime/frameworks. `in_scope`: el workflow de governance, la
gobernanza (constitution/North Star), plantillas/coverage, evals/verificación/UAT, tooling
de adopción, y la auto-validación del WoW.

## Consecuencias

- **Habilita** `/align` de verdad en este repo → destraba la **Cara A del retro** (deja de
  ser `n/a`; los features futuros del harness cierran su predicción de misión con datos
  reales). Completa el loop align↔retro.
- Los futuros briefs del harness ahora se puntúan contra estos 3 pilares. Ejemplos:
  "install desde github" → `adopcion-sin-friccion` (elegible); "escribir código de app del
  adoptante" → `out_of_scope` (rechazo duro).
- Pilares/scope quedan bajo control de cambios: crecer o reformular va por ADR + PR
  (`base/amendment-protocol.md`). Este ADR es el punto de partida (0001).
- **Follow-ups** (no en este cambio): el feature "install desde github"; la convención
  "comandos en inglés" (va a `constitution`, no al North Star).
