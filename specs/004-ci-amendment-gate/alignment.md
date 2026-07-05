# Alignment — 004-ci-amendment-gate

Measurability Gate (`/align`) sobre `brief.md` × `memory/north-star/north-star.md`.
North Star schema-válido (4 pilares) → el gate corre.

## Veredicto

**`aligned`** — las 3 dimensiones ≥ umbral (3), sin hit de `out_of_scope`, sin huérfano.
`/distill` puede avanzar.

## Scores (mínimo a través de objetivos)

| Dimensión | Score | Nota |
|---|---|---|
| pillar fit | 4 | Mapea limpio a `enforcement-real` (su `signal` — "gates bloquean el cierre; violaciones cazadas antes del merge" — es *literalmente* este feature). El objetivo dependency-free mapea a `portabilidad-agnostica` de forma plausible pero indirecta. |
| scope compliance | 4 | In-scope (gate de governance + auto-validación del WoW), pero **toca el borde** del predicado `out_of_scope` "motor determinista específico de un stack": construir un checker bash en el source. Resuelto como in-scope porque el harness implementa su **propia** gate en su **propio** stack (bash/coreutils + GitHub Actions, igual que `tests/check_*.sh` y `verify.yml`), no el motor del adoptante. Preferí 4 sobre 5 por el borde. |
| mission advancement | 4 | Efecto medible sobre el `signal` de `enforcement-real`: convierte el enforcement del amendment de convención a gate determinista que bloquea el drift antes del merge. |

## Mapping objetivo→pilar

| Objetivo (brief) | Pilares |
|---|---|
| Gatear amendments de `pillars`/`scope` por CI determinista (no approval humano) | `enforcement-real`, `impacto-medible` |
| Que la gate sea realmente bloqueante (branch protection exige el status-check) | `enforcement-real` |
| Mantener la capa dependency-free y el self-check verde | `portabilidad-agnostica` |

## Orphans

Ninguno. Todos los objetivos mapean a ≥1 pilar.

## Nota de gate

El único punto de fricción fue el borde de scope "motor determinista específico de un
stack". El predicado conservador (`scopeReject`, match por frase contigua) **no** dio hit
—el objetivo dice "CI determinista", no la frase literal— así que no hubo rechazo duro; la
evaluación del borde fue trabajo del judge en la dimensión scope compliance (score 4). El
distingo clave: el harness construyendo su **propia** gate de governance en su stack nativo
(bash) es in-scope (`comandos, gates y skills del workflow de governance` +
`auto-validación del WoW`); shippear el motor per-stack del **adoptante** sería out.
