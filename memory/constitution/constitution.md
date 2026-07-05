---
extends: base
---

# Constitution — Proyecto

Extiende `base` (ver `base/principles.md`). Agregá aquí principios y overrides
específicos del proyecto. Overridear un `base/pattern` requiere justificación explícita.

## Deltas del proyecto

### D1 — El `amendment-gate` es la única excepción angosta al principio 4

El principio 4 (base) dice "la verificación es on-demand; **nada bloquea commit/push**".
El **`amendment-gate`** (CI + branch protection, feature 004) es la **única excepción**
a esa regla, y es **angosta por diseño**: bloquea *solo* cuando un commit/push cambia los
sets **`pillars`/`scope`** del bloque JSON canónico del North Star sin cumplir el protocolo
(ADR nuevo + schema-válido + suite verde). El desarrollo normal de features — que no toca
los sets pillars/scope — **no se bloquea**: el gate sale `exit 0` (no-aplica).

**Por qué no contradice el principio 4:** la *intención* del principio 4 es
**productividad primero** (no frenar el throughput de features con gates por-commit). Un
amendment del North Star no es throughput de features: es un evento de gobernanza que
`base/amendment-protocol.md` ya declara gateado (ADR + PR). Gatearlo en CI hace cumplir
ese protocolo cuando un mantenedor solo no puede darse el approval — es **consistente con
la intención**, no un override de ella.

*Deferred:* afinar la redacción **literal** del principio 4 hacia "productividad-primero"
(para que un gate de governance angosto no lea como contradicción textual) es un amendment
de constitution aparte; este delta solo registra la reconciliación.

## Overrides de patterns heredados
_(ninguno — para desactivar un pattern, listalo aquí con su justificación)_

## Presupuesto del inner loop (tuneable)
- Escalar al humano tras **2 fallas idénticas** o **3 intentos totales** por task.
