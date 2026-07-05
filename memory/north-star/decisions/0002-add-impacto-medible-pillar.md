# 0002 — Agregar pilar `impacto-medible`

> Amendment de `pillars`: suma un 4º pilar. Aterriza junto al diff de `north-star.md`
> en el mismo PR (ver `base/amendment-protocol.md`). Un humano revisa y aprueba.

## Contexto

Los 3 pilares del seed (`0001`) — `enforcement-real`, `portabilidad-agnostica`,
`adopcion-sin-friccion` — describen **propiedades del harness**, pero ninguno mide el
**outcome para el desarrollador**. La misión es "hacer cumplir un SDLC disciplinado", y el
valor real de esa disciplina es *mejor software*: menos rework, gaps cazados antes de
codear, el humano liberado para el 20% conceptual (el *80% problem* del whitepaper que cita
el README).

La presión que lo motiva: sin un pilar de outcome, el harness corre el riesgo de premiar
**enforcement sin impacto** — gates que disparan por disparar. Es el mismo riesgo
anti-teatro que atacamos a nivel del retro (`003`), ahora a nivel del harness entero:
medíamos que *enforçáramos*, no que *enforçar sirviera*. Un review adversarial del propio
seed lo destapó como el hueco más grande.

## Decisión

Agregar un pilar al array `pillars` del bloque canónico de `north-star.md`.

**Before** (3 pilares): `enforcement-real`, `portabilidad-agnostica`,
`adopcion-sin-friccion`.

**After** (4 pilares): los 3 anteriores **+**

```json
{
  "id": "impacto-medible",
  "statement": "La disciplina que el harness impone tiene que traducirse en mejor software: menos rework y gaps cazados antes de producción, no gates que disparan por disparar.",
  "signal": "Gaps cazados temprano (grilling/contract) y rework tardío evitado (post-verify/uat), agregados por feature en la sección Método del wow-report; alto = la disciplina previene, no solo burocratiza."
}
```

Sin cambios en `mission`, `scope`, ni `alignment.threshold`.

## Scope-delta

Ninguno. Este amendment **no** mueve predicados entre `in_scope`/`out_of_scope`; solo
agrega una dimensión de pilar. El radio de impacto es acotado: los briefs futuros ganan un
pilar más contra el cual `/align` puede mapear objetivos.

**Delta de solapamiento (declarado explícito para no confundir con `enforcement-real`):**
`enforcement-real` mide que la gate **dispare** (la disciplina se hace cumplir);
`impacto-medible` mide que **disparar reduzca rework / cace gaps** (la disciplina agrega
valor). Uno es "enforçamos", el otro es "enforçar sirvió". Son dimensiones distintas y
deliberadamente no colapsadas.

## Consecuencias

- **Habilita** que un brief avance la misión por vía de *impacto demostrable* (no solo de
  rigor procesal). Su `signal` se apoya en instrumentación **ya existente**: la sección
  "Método" del `wow-report` (gaps cazados, rework post-verify/uat).
- Ningún brief previo cambia de veredicto (no hay reclasificación `rejected`↔`aligned`; el
  scope no se tocó).
- **Follow-up:** cuando haya ≥2 features cerrados con retro real, el `wow-report §Método`
  debería empezar a poblar la evidencia de este pilar; hasta entonces es un pilar
  declarado pero aún sin serie de datos (honestidad N=1).
