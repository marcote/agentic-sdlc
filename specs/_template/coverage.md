# Coverage — <feature>

> Matriz de trazabilidad = fuente de verdad del estado de cada criterio y detector de
> gaps. Regla: todo objetivo → un criterio; todo criterio → un eval/UAT. Fila huérfana = gap.
> Cadena: **pilar → objetivo → criterio** — todo objetivo traza hasta un pilar del North Star
> (`memory/north-star/north-star.md`) vía el mapping objetivo→pilar de `specs/<feature>/alignment.md`.
> Una fila con la celda **Pillar** vacía es una señal de drift (ver el orphan check de `/align`).

**Leyenda de estado:** `sin contrato` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (no-determinista) · `[given]` (heredado de constitution) · `deferred` (gap justificado)

| Pillar | Objetivo (brief) | Requerimiento (spec) | Criterio (acceptance) | Origen | Test/Eval ligado | Estado |
|---|---|---|---|---|---|---|
| _(ej.)_ `pilar-a` | _(ej.)_ ↑ conversión | Guardar tarjeta 1-tap | token < 300ms | proyecto | `card_token.feature` | 🔴 red |
| — | — | (todas las escrituras) | audit-log actor+ts | `[given] base/audit-logging` | `audit.feature` | 🔴 red |
