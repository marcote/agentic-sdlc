# Workflow end-to-end

```
/constitution → (brief.md) → /align → /distill → /plan → /contract → /tasks → implement → /verify → /uat → /retro
```

| Comando | Entrada | Salida | Verificación |
|---|---|---|---|
| `/constitution` | — | `memory/constitution/` | semilla + filtro |
| (intake) | objetivo | `brief.md` | métricas de éxito |
| `/align` | `brief.md` + `north-star.md` | `alignment.md` | **Measurability Gate**: puntúa el brief contra el North Star; solo `aligned` avanza |
| `/distill` | `brief.md` + `alignment.md` | `spec` + `acceptance` + `coverage` | loop grilling, cero filas huérfanas; Paso 0 exige `aligned` |
| `/plan` | `spec` | `plan.md` | grounded en constitution |
| `/contract` | `acceptance` | tests 🔴 + eval cases 📋 | prueba que está RED |
| `/tasks` | `coverage` | `tasks.md` | GATE: rechaza si falta contrato RED |
| implement | `tasks` | código | inner loop 🔴→🟢 (budget → ESCALA) |
| `/verify` | código | `verification/reports/…` | output + trajectory eval |
| `/uat` | reporte | reporte completo | contra objetivo; gap → `/distill` |
| `/retro` | `alignment.md` + `verification/reports/…` | `retro.md` | cierra la predicción de `/align` (Cara Misión) + deriva señales del WoW (Cara Método) |
| `/wow-report` | todos los `retro.md` | `verification/wow-report.md` | agrega el ledger: drift por pilar, re-chequeos, salud del método, olores de teatro (observa, no gatea) |

## Tres loops
1. **Grilling** (en `/distill`): cierra gaps de especificación antes de codear.
2. **Inner loop** (implementación, por task): auto-corrige 🔴→🟢; escala al humano tras
   2 fallas idénticas o 3 intentos (tuneable en la constitution).
3. **Feedback** (`/verify`+`/uat`): fallo de verify → implementación; fallo de UAT → producto → `/distill`.

## Dos capas: governance vs execution-runtime
El flujo tiene dos capas con dueños distintos:
- **Governance (el harness):** los comandos + gates deterministas + la **constitution**
  (cómo se construye) + el **North Star** (para qué existe el producto). Versionado,
  revisado, el mismo para todo adoptante.
- **Execution-runtime (lo elige el adoptante):** los pasos que **no** son comandos —
  intake→`brief.md`, la implementación entre `/tasks` y `/verify`, y el finish. El
  harness no nombra ningún runtime como obligatorio; cualquiera sirve mientras respete
  los artefactos y gates de la capa de governance. Ver `README.md` (§ "Dos capas") y
  `memory/north-star/base/README.md` (contrato en la plantilla, motor por-stack).

## Cierre
`feature DONE ⟺ BUILD ✅ AND TRAJECTORY ✅ AND UAT ✅ AND coverage 100% AND retro ✅`.
