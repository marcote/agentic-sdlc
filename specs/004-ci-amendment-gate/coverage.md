# Coverage — CI-gate del amendment del North Star

> Matriz de trazabilidad = fuente de verdad del estado de cada criterio y detector de
> gaps. Regla: todo objetivo → un criterio; todo criterio → un eval/UAT. Fila huérfana = gap.
> Cadena: **pilar → objetivo → criterio** vía el mapping de `alignment.md` (`aligned`).

**Leyenda de estado:** `sin contrato` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (no-determinista) · `[given]` (heredado de constitution) · `deferred` (gap justificado)
· `UAT (config)` = config de GitHub, no unit-testeable — validado en `/uat`, no en `/contract`.

Ningún `base/pattern` aplica como `[given]` (no hay writes/API/rate-limit en un checker bash).

| Pillar | Objetivo (brief) | Requerimiento (spec) | Criterio (acceptance) | Origen | Test/Eval ligado | Estado |
|---|---|---|---|---|---|---|
| `enforcement-real` · `impacto-medible` | Gatear amendments por CI determinista | Script gate: detecta cambio de sets pillars/scope, exige ADR | AMEND-BLOCK-NO-ADR | proyecto | `check_95_amendment_gate.sh` | sin contrato |
| `enforcement-real` · `impacto-medible` | Gatear amendments por CI determinista | Script gate: pasa con ADR + schema + suite | AMEND-PASS-WITH-ADR | proyecto | `check_95_amendment_gate.sh` | sin contrato |
| `enforcement-real` | Gatear amendments por CI determinista | Script gate: no exige ADR para prosa/threshold | AMEND-NO-ADR-FOR-PROSE | proyecto | `check_95_amendment_gate.sh` | sin contrato |
| `enforcement-real` | Gatear amendments por CI determinista | Script gate: detección por sets, no por texto | AMEND-SET-SEMANTICS | proyecto | `check_95_amendment_gate.sh` | sin contrato |
| `enforcement-real` · `impacto-medible` | Gatear amendments por CI determinista | Script gate: exige North Star schema-válido | AMEND-SCHEMA-VALID | proyecto | `check_95_amendment_gate.sh` | sin contrato |
| `enforcement-real` | Gatear amendments por CI determinista | Script gate: exige suite verde | AMEND-SUITE-GREEN | proyecto | `check_95_amendment_gate.sh` | sin contrato |
| `enforcement-real` | Bloqueo angosto (preserva principio 4) | Gate no bloquea trabajo que no toca pillars/scope | DEV-UNBLOCKED | proyecto | `check_95_amendment_gate.sh` | sin contrato |
| `enforcement-real` | Bloqueo angosto (preserva principio 4) | Delta de constitution declara la excepción | CONST-EXCEPTION | proyecto | `check_95_amendment_gate.sh` (grep constitution) | sin contrato |
| `portabilidad-agnostica` | Dependency-free + self-check verde | Sin deps de runtime nuevas | DEP-FREE | proyecto | `check_95_amendment_gate.sh` (no package.json) | sin contrato |
| `portabilidad-agnostica` | Dependency-free + self-check verde | Wiring cubierto (script + workflow existen) | SELF-CHECK | proyecto | `check_95_amendment_gate.sh` + `check_40/70` | sin contrato |
| `enforcement-real` | Realmente bloqueante (branch protection) | Action + branch protection exigen el status-check | AMEND-BLOCK-REAL | proyecto | UAT walk (PR rojo no mergeable) | UAT (config) |
| `enforcement-real` | Realmente bloqueante (branch protection) | Branch protection prohíbe bypass en push directo | AMEND-BLOCK-PUSH | proyecto | UAT walk (push directo rechazado) | UAT (config) |

**Sin filas huérfanas:** cada objetivo del brief mapea a ≥1 criterio con pilar; cada
criterio tiene test (`/contract`) o UAT walk. Spec congelable.
