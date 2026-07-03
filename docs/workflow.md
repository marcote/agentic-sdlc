# Workflow end-to-end

```
/constitution → (brief.md) → /distill → /plan → /contract → /tasks → implement → /verify → /uat
```

| Comando | Entrada | Salida | Verificación |
|---|---|---|---|
| `/constitution` | — | `memory/constitution/` | semilla + filtro |
| (intake) | objetivo | `brief.md` | métricas de éxito |
| `/distill` | `brief.md` | `spec` + `acceptance` + `coverage` | loop grilling, cero filas huérfanas |
| `/plan` | `spec` | `plan.md` | grounded en constitution |
| `/contract` | `acceptance` | tests 🔴 + eval cases 📋 | prueba que está RED |
| `/tasks` | `coverage` | `tasks.md` | GATE: rechaza si falta contrato RED |
| implement | `tasks` | código | inner loop 🔴→🟢 (budget → ESCALA) |
| `/verify` | código | `verification/reports/…` | output + trajectory eval |
| `/uat` | reporte | reporte completo | contra objetivo; gap → `/distill` |

## Tres loops
1. **Grilling** (en `/distill`): cierra gaps de especificación antes de codear.
2. **Inner loop** (implementación, por task): auto-corrige 🔴→🟢; escala al humano tras
   2 fallas idénticas o 3 intentos (tuneable en la constitution).
3. **Feedback** (`/verify`+`/uat`): fallo de verify → implementación; fallo de UAT → producto → `/distill`.

## Cierre
`feature DONE ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100%`.
