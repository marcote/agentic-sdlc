# Coverage — Guardar tarjeta con 1-tap

> Matriz de trazabilidad = fuente de verdad del estado de cada criterio y detector de
> gaps. Regla: todo objetivo → un criterio; todo criterio → un eval/UAT. Fila huérfana = gap.
>
> **Estado de este feature: a mitad de camino** — sirve para ver la matriz con estados
> mezclados. Todavía NO cierra (falta idempotencia en 🟢 y el UAT del pago). Recordá:
> `feature DONE ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%`.

**Leyenda de estado:** `sin contrato` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (no-determinista) · `[given]` (heredado de constitution) · `deferred` (gap justificado)

| Objetivo (brief) | Requerimiento (spec) | Criterio (acceptance) | Origen | Test/Eval ligado | Estado |
|---|---|---|---|---|---|
| Tokenización p95 < 300ms | Tokenizar y persistir token | token < 300ms, sin PAN | proyecto | `card_token.feature` | ✅ uat |
| 0 incidentes PCI | Nunca almacenar PAN | respuesta sin PAN en claro | proyecto | `card_token.feature` | 🟢 green |
| — (toda escritura) | Persistir token | audit-log actor+ts+entidad | `[given] base/audit-logging` | `audit.feature` | 🟢 green |
| — (reintentos) | Guardado repetible | idempotencia por key | `[given] base/idempotency` | `idempotency.feature` | 🔴 red |
| ↑ conversión 2da compra | Pago con tarjeta guardada | paga sin reingresar datos | proyecto | `one_tap_pay.feature` | 🟢 green |
| Calidad de UX ante error | Mensaje claro de rechazo | claridad del mensaje | proyecto | `evals/cases/reject-msg.yaml` | 📋 case |
| (fuera de alcance) | Multi-tarjeta | selección entre varias | proyecto | — | deferred |

**Gaps abiertos:** ninguno huérfano. Pendientes para cerrar: `idempotency.feature` a 🟢
(implementación en curso, ver `tasks.md` T4) y el pase de UAT sobre los criterios en 🟢.
