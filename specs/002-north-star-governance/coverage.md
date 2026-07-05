# Coverage — Gobernanza North-Star + Measurability Gate

> Matriz de trazabilidad = fuente de verdad del estado de cada criterio y detector de
> gaps. Regla: todo objetivo → un criterio; todo criterio → un eval/UAT. Fila huérfana = gap.

**Leyenda de estado:** `sin contrato` → `🔴 red` → `🟢 green` → `✅ uat`  ·
`📋 case` (no-determinista) · `[given]` (heredado de constitution) ·
`deferred` (gap justificado) · `contrato documentado (deferred)` (motor per-stack,
fuera de alcance de este repo — ver `plan.md` decisión 2)

**Leyenda de objetivos (brief → "Métricas de éxito"):** O1 = out-of-scope bloqueado
duro · O2 = cero objetivos huérfanos · O3 = Measurability Gate (sin North Star
medible/alineado, el flujo no corre) · O4 = alineación cuantificada (score vs
rúbrica) · O5 = drift gobernado (ADR + PR) · O6 = self-check del harness cubre la
capa nueva, plantilla stack-agnóstica/dependency-free.

> **Bootstrap:** esta feature introduce el North Star del harness; el harness en sí
> (a diferencia de un proyecto adoptante) no tiene pilares propios — `north-star.md`
> es un placeholder. Por eso la columna **Pilar** es `— (bootstrap)` en todas las
> filas: no hay North Star del harness contra el cual mapear. `/align` se **saltea
> para esta feature** (no puede gatearse a sí misma), igual que el bootstrap
> original del harness salteó sus propios gates — ver `plan.md` decisión 8 y
> `acceptance.md` criterio MEAS-GATE. Desde la próxima feature en adelante,
> `/align` corre antes de `/distill`.

| Pilar | Objetivo (brief) | Requerimiento (spec) | Criterio (acceptance) | Origen | Test/Eval ligado | Estado |
|---|---|---|---|---|---|---|
| — (bootstrap) | O3 | Capa base North-Star (schema, rúbrica, protocolo, ADR template, README) | NS-BASE | proyecto | `tests/check_80_north_star.sh` | 🟢 green |
| — (bootstrap) | O3 | `north-star.md` placeholder, `extends: base` | NS-PLACEHOLDER | proyecto | `tests/check_80_north_star.sh` | 🟢 green |
| — (bootstrap) | O3 / O4 | Forma medible del schema (mission/pillars/scope/alignment) | NS-SCHEMA-CONTRACT | proyecto | contrato documentado — motor per-stack (`poirot-fe scripts/north-star/schema.mjs`, ref.) | contrato documentado (deferred) |
| — (bootstrap) | O1 / O2 | Comando+skill `/align` (modelo de 3 capas) | ALIGN-CMD | proyecto | `tests/check_80_north_star.sh` | 🟢 green |
| — (bootstrap) | O1 / O2 / O4 | Semántica del veredicto (scopeReject/orphan-check/alignVerdict) | ALIGN-VERDICT-CONTRACT | proyecto | contrato documentado — motor per-stack (`poirot-fe scripts/north-star/align.mjs`, ref.) | contrato documentado (deferred) |
| — (bootstrap) | O3 | Paso 0 — Measurability Gate en `/distill` | MEAS-GATE | proyecto | `tests/check_80_north_star.sh` (grep `alignment.md` + `Measurability Gate` + `aligned`) | 🟢 green |
| — (bootstrap) | O5 | `amendment-protocol.md` + `adr-template.md` (ADR + PR) | AMEND-ADR | `[given] base/audit-logging` | `tests/check_80_north_star.sh` | 🟢 green |
| — (bootstrap) | O6 | Columna Pillar en `specs/_template/coverage.md` | COVERAGE-PILLAR | proyecto | `tests/check_80_north_star.sh` (grep `Pillar`) | 🟢 green |
| — (bootstrap) | O6 | Way-of-Work de dos capas (governance vs execution-runtime) | WOW-2LAYER | proyecto | UAT (lectura manual `README.md` / `docs/workflow.md`) | ✅ uat |
| — (bootstrap) | O6 | Self-check bash cubre la capa nueva | SELFCHECK | proyecto | `tests/check_80_north_star.sh` (vía `tests/run.sh`) | 🟢 green |
| — (bootstrap) | O1 / O4 | El judge puntúa alineación con sensatez | JUDGE-ALIGNMENT | proyecto | `evals/cases/north-star-judge.md` (resultado: `verification/reports/002-north-star-judge.md`) | 📋 case |
| — | (sin escrituras/reintentos: capa de gobernanza en markdown) | — | `[given] base/idempotency` | heredado | — | deferred (sin escrituras/reintentos) |
| — | (sin superficie de red) | — | `[given] base/rate-limiting` | heredado | — | deferred (sin endpoints/red) |

## Notas
- **Sin filas huérfanas:** todo objetivo (O1–O6) tiene ≥1 criterio; todo criterio
  mapea a un test/eval/UAT o está `deferred`/`contrato documentado` con
  justificación explícita.
- `[given] base/audit-logging` **aplica**: un amendment del North Star (cambio de
  `scope`/`pillars`) es una escritura de estado de gobernanza → satisfecho por
  AMEND-ADR (ADR + PR = el rastro auditable `actor`+`timestamp`+`entidad`, git-nativo
  vía autor/fecha del commit y reviewer del PR).
- `[given] base/idempotency` y `[given] base/rate-limiting` → **deferred**: esta
  capa no tiene reintentos/webhooks/pagos ni superficie de red expuesta (es
  markdown + comandos/skills leídos por un agente local).
- Los criterios `NS-SCHEMA-CONTRACT` y `ALIGN-VERDICT-CONTRACT` describen el motor
  determinista (contrato-en-la-plantilla, motor por-stack): están **documentados
  aquí, no unit-testeados en este repo** — la GATE de `/tasks` (ver `tasks.md`) los
  excluye del requisito "🔴 red con test ligado" porque no son deterministas
  *estructurales* verificables por bash; son contrato semántico deferred a cada
  adoptante, con `poirot-fe` como reference implementation ya verde allí.
- `WOW-2LAYER` es contenido de prosa (README/docs), no forma estructural
  grep-eable de forma confiable → se cierra por UAT, no por `check_80`.
- Diseño: `docs/superpowers/specs/2026-07-04-north-star-governance-design.md`.
