---
extends: base
---

# Constitution — Proyecto

Extiende `base` (ver `base/principles.md`). Agregá aquí principios y overrides
específicos del proyecto. Overridear un `base/pattern` requiere justificación explícita.

## Deltas del proyecto

### D1 — El `amendment-gate`: instancia de la excepción de governance angosta (principio 4)

El principio 4 (base) admite **una** excepción a "nada frena el push": un *gate de
governance angosto sobre la rama de integración protegida*. El **`amendment-gate`**
(CI + branch protection, feature 004) es la **instancia concreta** de esa excepción en
este proyecto, y es **angosta por diseño**: bloquea *solo* cuando un commit/push cambia los
sets **`pillars`/`scope`** del bloque JSON canónico del North Star sin cumplir el protocolo
(ADR nuevo + schema-válido + suite verde). El desarrollo normal de features — que no toca
los sets pillars/scope — **no se bloquea**: el gate sale `exit 0` (no-aplica).

**Por qué encaja con el principio 4:** su intención es **productividad primero** (no frenar
el throughput de features). Un amendment del North Star no es throughput de features: es un
evento de gobernanza que `base/amendment-protocol.md` ya declara gateado (ADR + PR).
Gatearlo en CI hace cumplir ese protocolo cuando un mantenedor solo no puede darse el
approval — usa exactamente la excepción que el principio 4 ahora carve-outea, sin frenar el
throughput.

*Nota de branch protection:* al hacer el status-check `amendment-gate` *required* en `main`,
GitHub gatea **todo** push directo a `main` (deben pasar por PR + CI), no solo los
amendments. Eso preserva el principio 4 —commit local y push a ramas de trabajo siguen
libres— pero conviene tenerlo explícito: `main` es un punto de integración protegido para
todo, no solo para cambios de `pillars`/`scope`.

## Overrides de patterns heredados
_(ninguno — para desactivar un pattern, listalo aquí con su justificación)_

## Presupuesto del inner loop (tuneable)
- Escalar al humano tras **2 fallas idénticas** o **3 intentos totales** por task.
