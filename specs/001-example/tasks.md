# Tasks — Guardar tarjeta con 1-tap

> Descomposición ejecutable. Producido por `/tasks`. GATE: no se emiten tasks de
> implementación mientras exista un criterio determinista sin test ligado en 🔴 RED.
> (El gate ya pasó: cada criterio determinista tiene su `.feature` ligado en `coverage.md`.)

## Tasks
- [x] T1: `TokenizationClient` con timeout 300ms — cubre: *token < 300ms*, *sin PAN* (🟢, en UAT ✅ el primero)
- [x] T2: Middleware de audit-log en escrituras — cubre: *audit-log* `[given]` (🟢)
- [x] T3: `OneTapPayHandler` (pago con tarjeta guardada) — cubre: *paga sin reingresar* (🟢)
- [ ] T4: Idempotencia por `idempotency-key` en `SaveCardHandler` — cubre: *idempotencia* `[given]` (🔴 → en curso)
- [ ] T5: Eval case de claridad del mensaje de rechazo — cubre: *mensaje claro* (📋 case a completar)

## Siguiente paso
Cerrar T4 (🔴→🟢), luego `/verify` sobre el feature y `/uat` contra `acceptance.md`.
El feature no cierra hasta BUILD ✅ + TRAJECTORY ✅ + UAT ✅ + coverage 100%.
