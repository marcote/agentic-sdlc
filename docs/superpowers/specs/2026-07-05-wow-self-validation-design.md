# Diseño — WoW Self-Validation (`003-wow-self-validation`)

fecha: 2026-07-05 · estado: aprobado en brainstorming, pendiente de plan

## Problema

El harness propone una Way of Working (WoW): `distill → plan → contract → tasks →
implement → verify → uat`, con gates deterministas, coverage como fuente de verdad, y
`/align` como Measurability Gate. Pero **nada valida que esa WoW funcione**. Un SDLC
que predica disciplina pero no se somete a sí mismo no está probado.

El pedido: que el SDLC sea **dogfooding** — que nos autovalidemos el WoW que
proponemos. Elegido en brainstorming: **loop cerrado** (conformance + outcome +
auto-mejora), con la evidencia producida por la **parte agéntica** del flujo (no por
diligencia humana), para sacarle el error humano.

### Restricción honesta: N=1

Una metodología no se puede A/B-testear contra sí misma en un solo repo — no hay grupo
de control. Por lo tanto "outcome" no se apoya en estadística cruzada entre features,
sino en **una afirmación falsable por feature**: `/align` declara una predicción
medible arriba de todo, y el retro dicta el veredicto sobre esa predicción. El WoW se
auto-valida feature por feature.

## Principio rector: la columna `align ↔ retro`

Toda predicción medible que **abre** `/align` la **cierra** el retro. El retro no es un
artefacto suelto de "cómo nos fue"; es la contraparte estructural de la Measurability
Gate.

```
brief.md
  │
/align ──────────► alignment.md        PREDICCIÓN: "avanza pilar X vía signal Y;
  │                 (verdict, scores,               scores ≥ umbral"
  │                  mapping, orphans)
  ▼
distill → contract → tasks → implement
  │
/verify + /uat ──► verification/reports/<feature>   el PRODUCTO funciona
  │                 (BUILD ∧ TRAJECTORY ∧ UAT ∧ coverage 100%)
  ▼
/retro ──────────► specs/<feature>/retro.md   VEREDICTO sobre la predicción de align
                                              + señales del método (WoW)
```

### Extensión del contrato DONE

```
feature DONE ⟺ BUILD ✅ ∧ TRAJECTORY ✅ ∧ UAT ✅ ∧ coverage 100% ∧ retro ✅
```

`retro ✅` = el retro cerró sus tres caras, **no** que "salió todo bien". Un retro que
documenta que la predicción de align **falló** es un retro válido y cerrado — de hecho
el más valioso, porque alimenta el loop de auto-mejora.

## Componentes

### 1. `specs/_template/retro.md` — el artefacto (tres caras)

Vive co-locado con el feature (respeta "un feature = un folder"). Cada campo anclado a
un artefacto existente para que el agente lo **derive**, no lo invente.

```markdown
# Retro — <feature> @ <commit>
cierra: alignment.md · verification/reports/<feature> · fecha: <YYYY-MM-DD>

## Cara A — Misión (cierra la predicción de /align)
Fuente: specs/<feature>/alignment.md

| Pilar (mapping) | Signal predicho | Veredicto | Evidencia (locator OBLIGATORIO) |
|---|---|---|---|
| pilar-x | <signal del North Star> | ✅ movió / ❌ no movió / ⏳ aún no observable | <valor/SHA/fila-coverage/URL — no prosa> |

- Calibración de align: los scores predichos (pillarFit/scope/mission) ¿acertaron?
- Veredicto de misión: confirmed | refuted | pending-observation | n/a
  - si confirmed | refuted → la celda Evidencia NO puede estar vacía (Capa 2)
  - si pending-observation → trigger de re-chequeo: <cuándo/qué señal mirar>
  - si n/a → razón obligatoria: <por qué no cierra contra un signal>

## Cara B — Método (valida el WoW) — DERIVADA de artefactos, no redactada (Capa 1)
Cada campo muestra su `[deriv: <locator>]` — de dónde salió la cifra. Sin locator = inválido.

- Gaps cazados por /distill: <N> `[deriv: coverage.md filas + git log de distill]`
- Disciplina RED→GREEN: <sí/no + excepciones> `[deriv: historial de estados coverage.md + git]`
- Rework post-/verify: <N> · post-/uat: <N> `[deriv: gaps ruteados en verification/reports/<feature>]`
- Escalaciones al humano: <N> `[deriv: traza/git]` — <por qué>
- Fricción del propio WoW: <qué estorbó o faltó> (cualitativo; el único campo de juicio libre)

## Cara C — Loop (auto-mejora) — puente, no subsistema
- Reglas candidatas → constitution: <regla o "ninguna">
- Amendments candidatos → North Star: <ADR propuesto o "ninguno">
```

**Decisiones:**
- `pending-observation` es de primera clase: muchos `signal` (ej. "↑ conversión") no
  se pueden medir el día del cierre. En vez de fingir certeza, veredicto diferido con
  trigger. No bloquea el cierre.
- `n/a` es un veredicto de primera clase (no un hack): un refactor puro o tooling
  legítimamente no mueve ningún signal. **Requiere razón obligatoria** (evita el escape
  silencioso).
- La Cara B es mayormente **auto-derivable** de artefactos (coverage, git, report), no
  de memoria — ahí es donde la parte agéntica saca el error humano.
- La Cara C solo **propone**; aplicar reglas/ADRs sigue los mecanismos existentes
  (`memory/constitution/update-checklist.md`, `memory/north-star/base/amendment-protocol.md`).

### 2. `tests/check_90_retro.sh` — enforcement determinista

Respeta la regla "verificación on-demand, sin hooks bloqueantes por commit": el diente
lo pone **CI** (`tests/` corre en `.github/workflows/verify.yml`), no un hook de git.

Dos niveles:
- **Template** (extiende `check_20`): `specs/_template/retro.md` existe con los headers
  de las tres caras.
- **Cierre por-feature** (`check_90`), lógica uniforme, **sin ramas por número de
  feature**:

```
para cada specs/NNN-*/ cuyo verification/reports/NNN-* muestre el veredicto DONE:
  assert retro.md existe
  assert sin placeholders _(…)_ / <…> sin llenar
  assert veredicto de misión ∈ {confirmed, refuted, pending-observation, n/a}
  assert si veredicto == n/a  →  hay una razón no vacía
  assert si veredicto ∈ {confirmed, refuted}  →  celda Evidencia no vacía          (Capa 2)
          y "parece" locator (contiene path / SHA / número / URL, no solo prosa)
  assert cada campo de Cara B trae su [deriv: <locator>]                            (Capa 1)
si NO está DONE: skip (feature en vuelo)
```

Materializa `retro ✅` de forma determinista y en CI: no se puede mergear un feature
declarado DONE sin retro completo. **Límite honesto:** el check verifica presencia +
estructura + token de veredicto, **no la honestidad** del contenido — eso lo sostiene
el agente que corre `/retro` (la apuesta agéntica).

**Sin hardcodeo:** la exención de bootstrap (`002`) no vive en el test sino como dato
(`retro.md` con `n/a` + razón). `grep -r "n/a" specs/*/retro.md` lista todas las
exenciones con su razón. Cero housekeeping.

### 3. `/wow-report` — agregación (observabilidad)

Skill on-demand (patrón `/verify`, `/uat`) que lee todos los `retro.md` + `alignment.md`
+ reportes de verificación y **regenera** `verification/wow-report.md` (snapshot
commiteado). Estructura:

```markdown
# WoW Report — @ <fecha/commit>   (snapshot generado; no editar a mano)

## 1. Misión — ¿cada pilar del North Star está siendo servido de verdad?
   mapping (align) × veredicto de signal (retro) por pilar.
   pilar con features que dijeron servirlo pero ningún signal movido = DRIFT medible.

## 2. Re-chequeos pendientes (worklist)
   los pending-observation con su trigger; marca los vencidos.

## 3. Método — ¿el WoW agrega valor? (N=<n>, muestra chica, sin stats)
   por-feature: gaps cazados, disciplina RED, rework, escalaciones; + temas de fricción.

## 4. Loop — ¿el WoW se mejora a sí mismo?
   reglas candidatas propuestas vs aterrizadas en constitution;
   amendments propuestos vs aprobados (ADR).

## 5. Olores de teatro (spot-check humano)  (Capa 4)
   marca retros sospechosos: celdas de Evidencia vacías · all-green
   (cero gaps + cero rework + cero fricción) · pending-observation vencidos y
   nunca re-chequeados. Un retro demasiado limpio ES una señal.
```

**Decisiones:**
- El centro de gravedad es el **rollup por pilar (§1)**: responde lo más profundo —
  ¿cada pilar del North Star avanza de verdad, o solo se lo prometió? Drift medible.
- `pending-observation` se vuelve **worklist accionable (§2)**; cobra la deuda de la
  medición diferida. No se automatiza con scheduler ahora (YAGNI); solo se hace visible.
- `/wow-report` **observa, nunca gatea**. `check_90` es el diente (CI); el report es
  síntesis read-only para el humano.
- Honestidad del N chico: el report dice explícito "N=n, sin estadística" y muestra
  por-feature + totales, sin fingir tendencias.

### 4. La skill `/retro`

Par comando+skill (mismo patrón que `/align`):
- `.claude/commands/retro.md` (thin): invocá la skill `retro`; requiere el reporte de
  verificación del feature en DONE; escribe `specs/<feature>/retro.md`.
- `.claude/skills/retro/SKILL.md` (procedimiento — orden `derivar → auto-desafiar →
  escribir`, no al revés):
  1. **Derivá primero** (Capa 1): cada cifra de Cara B sale de un artefacto con su
     `[deriv: <locator>]` (`coverage.md`, git, `verification/reports/<feature>`). No
     tipees cifras de memoria.
  2. leé `alignment.md` → para cada pilar del `mapping`, buscá su `signal` y dictá
     veredicto **con evidencia locator obligatoria** (Cara A, Capa 2). Sin locator para
     un `confirmed`/`refuted` → no lo escribas: es `pending-observation`.
  3. **Auto-desafío adversarial** (Capa 3): antes de escribir, argumentá EN CONTRA de tu
     propio borrador — "el report dice 0 rework: verificá contra `git log`; dice que el
     pillar-fit de align fue exacto: sostené lo opuesto". Solo lo que sobrevive al
     desafío se escribe. (Refuerzo futuro, YAGNI ahora: delegar el desafío a un subagente
     sképtico separado, no al que redactó.)
  4. proponé reglas/ADRs (Cara C);
  5. si un signal no es medible al cierre → `pending-observation` + trigger, o `n/a` +
     razón.

## Anti-teatro: defensa en profundidad (4 capas)

El mayor riesgo del diseño: que el agente llene el retro **por cumplir**. Un check
determinista **no puede probar honestidad** (un grep pasa con relleno plausible —
Goodhart). No lo resolvemos con una defensa sino achicando el lugar donde el teatro se
esconde. Cuatro capas, de más barata a más potente:

1. **Derivar, no redactar** (Cara B + skill paso 1). Cada campo del Método es una
   consulta contra un artefacto (`coverage.md`, git, report) con su `[deriv: <locator>]`.
   Si el campo es una cifra derivada, no hay nada que "inventar por cumplir": el número
   es el que es. Deja un solo campo de juicio libre (fricción), a propósito.
2. **Evidence-or-it-didn't-happen** (Cara A + `check_90`). Un veredicto
   `confirmed`/`refuted` exige celda de Evidencia no vacía con forma de locator
   (path/SHA/número/URL). Esto **sí es checkeable** en CI: la prosa infalsificable está
   prohibida. Sin evidencia → el veredicto honesto es `pending-observation`.
3. **Auto-desafío adversarial** (skill paso 3). El mismo agente que construyó tiene sesgo
   de auto-calificarse; el procedimiento le exige argumentar en contra de su propio
   borrador antes de escribir. Reusa el patrón "juez sobre la traza" que `/verify` ya
   tiene (trajectory eval). Refuerzo futuro: subagente sképtico separado (YAGNI ahora).
4. **El report huele lo demasiado-limpio** (`/wow-report` §5). Un retro all-green es en
   sí una señal; el agregador marca evidencia vacía, all-green y `pending-observation`
   vencidos para spot-check humano. El trigger de re-chequeo es lo que **cobra** un
   `confirmed` que después no se sostiene.

**Lo honesto:** es defensa en profundidad, no una prueba. El residuo — que el agente
evalúe de verdad — sigue siendo la apuesta agéntica. Pero entre derivar en vez de
redactar, evidencia obligatoria y checkeable, auto-desafío, y el report que huele lo
limpio, el espacio para el teatro queda chico e incómodo.

## Bootstrap recursivo

- `/align` no pudo gatear `002` porque corre **al inicio** del flujo. `/retro` corre **al
  cierre** → para cuando `003-wow-self-validation` está cerrando, `/retro` **ya existe**.
  Por lo tanto `003` **se retro-ea a sí mismo**: la primera entrada real del ledger es
  este feature validándose con su propia capacidad.
- Solo `002` (que precede a todo) cierra con `n/a: precede a /retro (bootstrap)`.
  `001-example` es fixture, no un feature real.

## Manifiesto de archivos

| Acción | Archivo |
|---|---|
| nuevo template | `specs/_template/retro.md` |
| nuevo comando | `.claude/commands/retro.md`, `.claude/commands/wow-report.md` |
| nueva skill | `.claude/skills/retro/SKILL.md`, `.claude/skills/wow-report/SKILL.md` |
| nuevo check | `tests/check_90_retro.sh` |
| editar checks | `check_20` (+retro template), `check_40` (+retro, wow-report), `check_50` (+retro, wow-report) |
| editar contrato DONE | `CLAUDE.md`, `docs/workflow.md`, `verification/verification-report.md` |
| generado (commiteado) | `verification/wow-report.md` |
| bootstrap | `specs/002-north-star-governance/retro.md` (`n/a`) |
| dogfood | `specs/003-wow-self-validation/` completo (brief→align→…→retro propio) |

## No-objetivos (YAGNI)

- **No** scheduler/automatización de re-chequeos de `pending-observation` (solo
  visibilidad en el report).
- **No** estadística cruzada entre features / dashboards de tendencia (N=1 lo prohíbe
  honestamente).
- **No** hook de git bloqueante (el enforcement es CI, on-demand).
- **No** motor determinista nuevo: `check_90` es grep sobre artefactos, como el resto.

## Riesgos

- **Retro de baja calidad** (el agente llena por cumplir): ver "Anti-teatro: defensa en
  profundidad (4 capas)". El check no puede probar honestidad — es explícito.
- **`n/a` abusado** como escape: mitiga la razón obligatoria + visibilidad por grep.
- **`pending-observation` que nunca se re-chequea**: mitiga la worklist con "vencidos"
  en `/wow-report`.
